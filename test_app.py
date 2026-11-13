import unittest
import json
from app import app
from database import get_db

class CodeBeginnerTestSuite(unittest.TestCase):
    def setUp(self):
        app.config['TESTING'] = True
        app.config['WTF_CSRF_ENABLED'] = False
        self.client = app.test_client()

    def test_01_homepage_and_public_routes(self):
        """Kiểm tra trang chủ và danh sách khóa học, bài tập"""
        res = self.client.get('/')
        self.assertEqual(res.status_code, 200)
        self.assertIn('CodeBeginner'.encode('utf-8'), res.data)

        res_courses = self.client.get('/courses')
        self.assertEqual(res_courses.status_code, 200)

        res_exercises = self.client.get('/exercises')
        self.assertEqual(res_exercises.status_code, 200)

    def test_02_authentication_and_rbac(self):
        """Kiểm tra đăng nhập và phân quyền RBAC"""
        # 1. Đăng nhập học viên
        res_login = self.client.post('/login', data={
            'identifier': 'learner',
            'password': 'Learner@123'
        }, follow_redirects=True)
        self.assertEqual(res_login.status_code, 200)

        # 2. Học viên truy cập trang Admin -> Phải bị chặn 403 Forbidden
        res_admin_forbidden = self.client.get('/admin/dashboard')
        self.assertEqual(res_admin_forbidden.status_code, 403)

        # 3. Đăng xuất
        self.client.get('/logout')

    def test_03_code_practice_and_judge(self):
        """Kiểm tra chạy thử và nộp code C++ chấm tự động"""
        # Đăng nhập learner
        self.client.post('/login', data={'identifier': 'learner', 'password': 'Learner@123'})

        # 1. Chạy thử custom input
        code = """
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        """
        run_res = self.client.post('/api/run-code',
            data=json.dumps({'source_code': code, 'input_data': '15 35\n', 'language': 'C++'}),
            content_type='application/json'
        )
        self.assertEqual(run_res.status_code, 200)
        run_data = json.loads(run_res.data)
        self.assertEqual(run_data['status'], 'Success')
        self.assertIn('50', run_data['output'])

        # 2. Nộp bài tập 1 (Tính tổng hai số nguyên)
        sub_res = self.client.post('/api/submit-code',
            data=json.dumps({'exercise_id': 1, 'source_code': code, 'language': 'C++'}),
            content_type='application/json'
        )
        self.assertEqual(sub_res.status_code, 200)
        sub_data = json.loads(sub_res.data)
        self.assertEqual(sub_data['status'], 'Accepted')
        self.assertEqual(sub_data['score'], 10.0)
        self.assertEqual(sub_data['passed_tests'], sub_data['total_tests'])

    def test_04_entrance_test_evaluation(self):
        """Kiểm tra làm bài kiểm tra đầu vào và phân tích điểm yếu"""
        self.client.post('/login', data={'identifier': 'learner', 'password': 'Learner@123'})

        # Lấy câu hỏi đầu vào
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT id, correct_answer FROM entrance_questions")
        questions = cursor.fetchall()
        conn.close()

        form_data = {}
        for q in questions:
            # Chọn đúng cho các câu hỏi
            form_data[f"q_{q['id']}"] = q['correct_answer']

        test_res = self.client.post('/entrance-test', data=form_data, follow_redirects=True)
        self.assertEqual(test_res.status_code, 200)

        # Kiểm tra trang phân tích điểm yếu
        weak_res = self.client.get('/weakness-analysis')
        self.assertEqual(weak_res.status_code, 200)

    def test_05_admin_operations(self):
        """Kiểm tra chức năng Quản trị viên"""
        self.client.post('/login', data={'identifier': 'admin', 'password': 'Admin@123'})

        res_dashboard = self.client.get('/admin/dashboard')
        self.assertEqual(res_dashboard.status_code, 200)

        res_users = self.client.get('/admin/users')
        self.assertEqual(res_users.status_code, 200)

        res_reports = self.client.get('/admin/reports')
        self.assertEqual(res_reports.status_code, 200)

    def test_06_expert_operations(self):
        """Kiểm tra chức năng Chuyên gia"""
        self.client.post('/login', data={'identifier': 'expert', 'password': 'Expert@123'})

        res_dashboard = self.client.get('/expert/dashboard')
        self.assertEqual(res_dashboard.status_code, 200)

        res_exercises = self.client.get('/expert/exercises')
        self.assertEqual(res_exercises.status_code, 200)

        res_reviews = self.client.get('/expert/lesson-reviews')
        self.assertEqual(res_reviews.status_code, 200)

    def test_07_student_management_and_entrance_render(self):
        """Kiểm tra hiển thị đề thi đầu vào và danh sách học viên cho Expert/Admin"""
        # 1. Kiểm tra Learner truy cập trang thi đầu vào -> Phải trả về 200 và có đủ câu hỏi
        self.client.post('/login', data={'identifier': 'learner', 'password': 'Learner@123'})
        res_entrance = self.client.get('/entrance-test')
        self.assertEqual(res_entrance.status_code, 200)
        self.assertIn('entrance-exam-form'.encode('utf-8'), res_entrance.data)

        # 2. Đăng xuất học viên và đăng nhập Expert xem danh sách học viên
        self.client.get('/logout')
        self.client.post('/login', data={'identifier': 'expert', 'password': 'Expert@123'})
        res_expert_students = self.client.get('/expert/students')
        self.assertEqual(res_expert_students.status_code, 200)
        self.assertIn('learner'.encode('utf-8'), res_expert_students.data)

        # 3. Đăng xuất chuyên gia và đăng nhập Admin xem danh sách học viên
        self.client.get('/logout')
        self.client.post('/login', data={'identifier': 'admin', 'password': 'Admin@123'})
        res_admin_students = self.client.get('/admin/students')
        self.assertEqual(res_admin_students.status_code, 200)
        self.assertIn('learner'.encode('utf-8'), res_admin_students.data)

    def test_08_no_cin_zero_score_check(self):
        """Kiểm tra: Bài tập yêu cầu input nhưng code không cin/scanf phải bị 0 điểm"""
        self.client.post('/login', data={'identifier': 'learner', 'password': 'Learner@123'})

        # Nộp bài tập 2 (Kiểm tra chẵn lẻ) nhưng không cin
        code_without_cin = """
        #include <iostream>
        using namespace std;
        int main() {
            int n;
            if (n % 2 == 0) cout << "CHAN";
            else cout << "LE";
            return 0;
        }
        """
        sub_res = self.client.post('/api/submit-code',
            data=json.dumps({'exercise_id': 2, 'source_code': code_without_cin, 'language': 'C++'}),
            content_type='application/json'
        )
        self.assertEqual(sub_res.status_code, 200)
        sub_data = json.loads(sub_res.data)
        self.assertEqual(sub_data['status'], 'Wrong Answer')
        self.assertEqual(sub_data['score'], 0.0)
        self.assertEqual(sub_data['passed_tests'], 0)
        self.assertIn('Chương trình chưa có lệnh đọc dữ liệu đầu vào', sub_data['test_details'][0]['error'])

    def test_09_hidden_testcases_admin_vs_learner(self):
        """Kiểm tra: Học viên không thấy testcase ẩn, Quản trị viên/Chuyên gia thấy đầy đủ"""
        self.client.post('/login', data={'identifier': 'learner', 'password': 'Learner@123'})

        # Nộp bài tập 1
        valid_code = """
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        """
        sub_res = self.client.post('/api/submit-code',
            data=json.dumps({'exercise_id': 1, 'source_code': valid_code, 'language': 'C++'}),
            content_type='application/json'
        )
        sub_data = json.loads(sub_res.data)
        submission_id = sub_data['submission_id']

        # Học viên nhận kết quả JSON -> hidden test phải bị che
        hidden_tests = [t for t in sub_data['test_details'] if t.get('is_hidden')]
        self.assertGreater(len(hidden_tests), 0)
        self.assertEqual(hidden_tests[0]['input'], '[Test case ẩn]')

        # Học viên xem trang chi tiết submission -> không lộ thông tin ẩn
        res_learner_view = self.client.get(f'/submissions/{submission_id}')
        self.assertEqual(res_learner_view.status_code, 200)
        self.assertNotIn('Test case ẩn (Chế độ Quản trị viên/GV)'.encode('utf-8'), res_learner_view.data)

        # Đăng xuất học viên, đăng nhập Admin xem trang chi tiết submission -> phải thấy chế độ Admin và input ẩn
        self.client.get('/logout')
        self.client.post('/login', data={'identifier': 'admin', 'password': 'Admin@123'})
        res_admin_view = self.client.get(f'/submissions/{submission_id}')
        self.assertEqual(res_admin_view.status_code, 200)
        self.assertIn('Test case ẩn (Chế độ Quản trị viên/GV)'.encode('utf-8'), res_admin_view.data)

    def test_10_entrance_test_q8_comparison(self):
        """Kiểm tra: Câu hỏi phép gán trong bài test đầu vào đã đổi thành phép so sánh =="""
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT question_text, code_snippet, correct_answer FROM entrance_questions WHERE id = 8")
        row = cursor.fetchone()
        conn.close()

        self.assertIsNotNone(row)
        self.assertIn("a == 5", row["code_snippet"])
        self.assertEqual(row["correct_answer"], 0)

if __name__ == '__main__':
    unittest.main()

