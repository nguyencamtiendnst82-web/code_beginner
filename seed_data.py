import json
import sqlite3
from werkzeug.security import generate_password_hash
from database import get_db, init_db

def seed_all():
    init_db()
    conn = get_db()
    cursor = conn.cursor()

    # Xóa dữ liệu cũ để reset sạch sẽ nếu cần
    cursor.execute("SELECT COUNT(*) as count FROM users")
    if cursor.fetchone()['count'] > 0:
        print("Database already has data. Skipping re-seed.")
        conn.close()
        return

    print("Seeding initial data for CodeBeginner...")

    # 1. USERS
    admin_hash = generate_password_hash("Admin@123")
    expert_hash = generate_password_hash("Expert@123")
    learner_hash = generate_password_hash("Learner@123")

    cursor.execute("""
    INSERT INTO users (username, password_hash, email, full_name, role, status, bio) VALUES
    ('admin', ?, 'admin@codebeginner.edu.vn', 'Quản Trị Viên Hệ Thống', 'admin', 'active', 'Quản trị viên toàn hệ thống CodeBeginner'),
    ('expert', ?, 'expert@codebeginner.edu.vn', 'ThS. Nguyễn Văn Chuyên Gia', 'expert', 'active', 'Giảng viên chuyên ngành Khoa học Máy tính & Lập trình C++'),
    ('learner', ?, 'learner@gmail.com', 'Trần Văn Học Viên', 'learner', 'active', 'Người mới bắt đầu khám phá thế giới lập trình C++')
    """, (admin_hash, expert_hash, learner_hash))

    admin_id = 1
    expert_id = 2
    learner_id = 3

    # 2. COURSES
    cursor.execute("""
    INSERT INTO courses (id, title, description, language, level, image_url, status, expert_id) VALUES
    (1, 'C++ Cơ Bản & Nền Tảng Cho Người Mới Bắt Đầu',
     'Khóa học nhập môn lập trình bài bản từ biến, kiểu dữ liệu, nhập xuất, điều kiện rẽ nhánh đến vòng lặp và hàm. Phù hợp tuyệt đối cho người chưa biết lập trình.',
     'C++', 'Cơ bản', 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&auto=format&fit=crop&q=60', 'published', ?),
    (2, 'C++ Cấu Trúc Dữ Liệu & Thuật Toán Cơ Bản Đến Nâng Cao',
     'Khám phá mảng, chuỗi, đệ quy, sắp xếp, tìm kiếm và các cấu trúc dữ liệu nền tảng như Stack, Queue, Cây nhị phân và Quy hoạch động.',
     'C++', 'Nâng cao', 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=60', 'published', ?)
    """, (expert_id, expert_id))

    # 3. CHAPTERS for Course 1
    cursor.execute("""
    INSERT INTO chapters (id, course_id, title, order_index) VALUES
    (1, 1, 'Chương 1: Khởi động với Lập trình & C++', 1),
    (2, 1, 'Chương 2: Cấu trúc Rẽ nhánh & Điều kiện', 2),
    (3, 1, 'Chương 3: Cấu trúc Vòng lặp', 3),
    (4, 1, 'Chương 4: Hàm và Tổ chức Chương trình', 4)
    """)

    # CHAPTERS for Course 2
    cursor.execute("""
    INSERT INTO chapters (id, course_id, title, order_index) VALUES
    (5, 2, 'Chương 1: Mảng và Chuỗi ký tự', 1),
    (6, 2, 'Chương 2: Thuật toán Tìm kiếm & Sắp xếp', 2),
    (7, 2, 'Chương 3: Đệ quy & Cấu trúc Dữ liệu Nâng cao', 3)
    """)

    # 4. LESSONS
    # Lessons for Course 1
    lesson1_quiz = json.dumps([
        {
            "question": "Lệnh nào sau đây dùng để xuất dữ liệu ra màn hình trong C++?",
            "options": ["cin", "cout", "printf_s", "output"],
            "correct": 1,
            "explanation": "cout kết hợp toán tử << được dùng để in thông tin ra màn hình."
        }
    ], ensure_ascii=False)

    lesson2_quiz = json.dumps([
        {
            "question": "Kiểu dữ liệu nào lưu trữ số nguyên 4 byte phổ biến nhất trong C++?",
            "options": ["float", "double", "int", "char"],
            "correct": 2,
            "explanation": "Kiểu int thường dùng để lưu số nguyên và có kích thước 4 byte trên hệ thống hiện đại."
        }
    ], ensure_ascii=False)

    lesson3_quiz = json.dumps([
        {
            "question": "Trong câu lệnh if-else, khối lệnh else sẽ được thực hiện khi nào?",
            "options": ["Khi điều kiện if trả về true", "Khi điều kiện if trả về false", "Luôn luôn được thực hiện", "Không bao giờ được thực hiện"],
            "correct": 1,
            "explanation": "Khối lệnh else chỉ chạy khi biểu thức điều kiện trong if sai (false)."
        }
    ], ensure_ascii=False)

    lesson4_quiz = json.dumps([
        {
            "question": "Vòng lặp while kiểm tra điều kiện vào thời điểm nào?",
            "options": ["Sau khi chạy hết thân vòng lặp", "Trước khi chạy thân vòng lặp", "Ở giữa thân vòng lặp", "Không bao giờ kiểm tra"],
            "correct": 1,
            "explanation": "Vòng lặp while là vòng lặp kiểm tra trước, nếu điều kiện đúng mới thực hiện thân vòng lặp."
        }
    ], ensure_ascii=False)

    cursor.execute("""
    INSERT INTO lessons (id, course_id, chapter_id, title, content, syntax_guide, example_code, example_output, quiz_data, order_index, status) VALUES
    (1, 1, 1, 'Giới thiệu C++ và Cấu trúc chương trình chuẩn',
     'C++ là ngôn ngữ lập trình đa nền tảng mạnh mẽ được phát triển bởi Bjarne Stroustrup từ năm 1979 tại Bell Labs. C++ kết hợp cả đặc tính hướng thủ tục và hướng đối tượng, cho phép quản lý bộ nhớ trực tiếp và đạt hiệu năng tối đa trong phát triển hệ thống, trò chơi và thuật toán thi đấu.',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Khối mã lệnh ở đây\n    return 0;\n}',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Chao mung den voi CodeBeginner!" << endl;\n    return 0;\n}',
     'Chao mung den voi CodeBeginner!',
     ?, 1, 'approved'),

    (2, 1, 1, 'Biến, Kiểu dữ liệu và Nhập/Xuất trong C++',
     'Biến là vùng nhớ được đặt tên dùng để lưu trữ dữ liệu trong quá trình chạy chương trình. Các kiểu dữ liệu cơ bản bao gồm:\n- int: số nguyên (ví dụ: -5, 0, 100)\n- double / float: số thực có dấu chấm động (ví dụ: 3.14, -0.05)\n- char: ký tự đơn đặt trong dấu nháy đơn (ví dụ: ''a'', ''Z'')\n- bool: giá trị logic (true hoặc false)\n- string: chuỗi ký tự (cần #include <string>).\n\nSử dụng cin >> ten_bien để nhận dữ liệu từ bàn phím và cout << gia_tri để xuất ra màn hình.',
     'Kieu_Du_Lieu ten_bien = gia_tri_khoi_tao;\ncin >> ten_bien;\ncout << "Gia tri: " << ten_bien;',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    int tuoi;\n    cout << "Nhap tuoi cua ban: ";\n    if (cin >> tuoi) {\n        cout << "Ban " << tuoi << " tuoi." << endl;\n    }\n    return 0;\n}',
     'Nhap tuoi cua ban: 20\nBan 20 tuoi.',
     ?, 2, 'approved'),

    (3, 1, 2, 'Câu lệnh điều kiện If - Else & Toán tử so sánh',
     'Câu lệnh if/else dùng để kiểm tra điều kiện logic và phân nhánh luồng thực thi của chương trình. Các toán tử so sánh gồm: == (bằng), != (khác), > (lớn hơn), < (nhỏ hơn), >= (lớn hơn hoặc bằng), <= (nhỏ hơn hoặc bằng). Các toán tử logic gồm: && (VÀ), || (HOẶC), ! (PHỦ ĐỊNH).',
     'if (dieu_kien) {\n    // Thuc hien khi dieu kien dung\n} else {\n    // Thuc hien khi dieu kien sai\n}',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    int diem = 8;\n    if (diem >= 5) {\n        cout << "Dat yeu cau!";\n    } else {\n        cout << "Can hoc lai!";\n    }\n    return 0;\n}',
     'Dat yeu cau!',
     ?, 3, 'approved'),

    (4, 1, 3, 'Vòng lặp For, While và Do-While',
     'Vòng lặp cho phép thực hiện lặp lại một đoạn code nhiều lần cho đến khi thỏa mãn một điều kiện dừng nhất định.\n- Vòng lặp for: Phù hợp khi biết trước số lần lặp cụ thể.\n- Vòng lặp while: Phù hợp khi chưa biết trước số lần lặp, kiểm tra điều kiện trước.\n- Vòng lặp do-while: Luôn thực hiện thân vòng lặp ít nhất 1 lần trước khi kiểm tra điều kiện.',
     'for (khoi_tao; dieu_kien; buoc_nhay) {\n    // Than vong lap\n}\n\nwhile (dieu_kien) {\n    // Than vong lap\n}',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    int tong = 0;\n    for (int i = 1; i <= 5; i++) {\n        tong += i;\n    }\n    cout << "Tong tu 1 den 5 la: " << tong << endl;\n    return 0;\n}',
     'Tong tu 1 den 5 la: 15',
     ?, 4, 'approved'),

    (5, 1, 4, 'Hàm (Function) và Tổ chức chương trình',
     'Hàm là một khối lệnh độc lập được đặt tên, nhận các tham số đầu vào và trả về một kết quả. Hàm giúp tái sử dụng mã nguồn, chia nhỏ bài toán phức tạp thành các phần tử dễ quản lý.\nCần phân biệt giữa truyền tham trị (truyền bản sao) và truyền tham chiếu (sử dụng dấu & để thay đổi trực tiếp biến gốc).',
     'Kieu_Tra_Ve Ten_Ham(Danh_Sach_Tham_So) {\n    // Than ham\n    return gia_tri;\n}',
     '#include <iostream>\nusing namespace std;\n\nint tinhTong(int a, int b) {\n    return a + b;\n}\n\nint main() {\n    int ketQua = tinhTong(15, 25);\n    cout << "Ket qua: " << ketQua << endl;\n    return 0;\n}',
     'Ket qua: 40',
     '[]', 5, 'approved'),

    (6, 2, 5, 'Mảng một chiều (One-Dimensional Array) trong C++',
     'Mảng một chiều là tập hợp các phần tử có cùng kiểu dữ liệu được lưu trữ liên tiếp trong bộ nhớ máy tính. Mỗi phần tử trong mảng được định danh bằng chỉ số (index), bắt đầu từ chỉ số 0 đến n - 1.',
     'Kieu_Du_Lieu ten_mang[Kich_Thuoc];\nten_mang[0] = gia_tri;',
     '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a[5] = {2, 4, 6, 8, 10};\n    for (int i = 0; i < 5; i++) {\n        cout << a[i] << " ";\n    }\n    return 0;\n}',
     '2 4 6 8 10',
     '[]', 6, 'approved'),

    (7, 2, 5, 'Chuỗi ký tự std::string trong C++',
     'std::string trong C++ là lớp đối tượng biểu diễn chuỗi ký tự linh hoạt hơn rất nhiều so với chuỗi ký tự kiểu mảng C-string char[]. Nó hỗ trợ nối chuỗi bằng toán tử +, tính độ dài bằng .length() hoặc .size(), lấy ký tự theo chỉ mục.',
     '#include <string>\nstring s = "Hello";\ns += " World";',
     '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string s = "CodeBeginner";\n    cout << "Do dai: " << s.length() << endl;\n    cout << "Ky tu dau: " << s[0] << endl;\n    return 0;\n}',
     'Do dai: 12\nKy tu dau: C',
     '[]', 7, 'approved')
    """, (lesson1_quiz, lesson2_quiz, lesson3_quiz, lesson4_quiz))

    # 5. EXERCISES & TEST CASES
    exercises_data = [
        {
            "id": 1,
            "course_id": 1,
            "lesson_id": 2,
            "title": "Tính tổng hai số nguyên",
            "description": "Viết chương trình đọc vào hai số nguyên a và b từ bàn phím, sau đó in ra tổng của hai số đó.",
            "input_description": "Một dòng duy nhất chứa hai số nguyên a và b cách nhau bởi dấu cách (-10^9 <= a, b <= 10^9).",
            "output_description": "In ra một số nguyên duy nhất là tổng a + b.",
            "sample_input": "5 7",
            "sample_output": "12",
            "explanation": "5 + 7 = 12.",
            "constraints": "-10^9 <= a, b <= 10^9",
            "difficulty": "Dễ",
            "topic": "Nhập/xuất",
            "reference_solution": "#include <iostream>\nusing namespace std;\nint main() {\n    long long a, b;\n    if (cin >> a >> b) {\n        cout << (a + b) << endl;\n    }\n    return 0;\n}",
            "points": 10,
            "tests": [
                {"input": "5 7", "output": "12", "points": 2, "hidden": 0},
                {"input": "-10 25", "output": "15", "points": 3, "hidden": 0},
                {"input": "1000000000 2000000000", "output": "3000000000", "points": 3, "hidden": 1},
                {"input": "-500 -700", "output": "-1200", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 2,
            "course_id": 1,
            "lesson_id": 3,
            "title": "Kiểm tra tính chẵn lẻ",
            "description": "Viết chương trình nhập vào một số nguyên n. Nếu n là số chẵn in ra CHAN, ngược lại in ra LE.",
            "input_description": "Số nguyên n (-10^9 <= n <= 10^9).",
            "output_description": "In ra CHAN hoặc LE trên một dòng.",
            "sample_input": "8",
            "sample_output": "CHAN",
            "explanation": "8 chia hết cho 2 nên in ra CHAN.",
            "constraints": "-10^9 <= n <= 10^9",
            "difficulty": "Dễ",
            "topic": "If/Else",
            "reference_solution": "#include <iostream>\nusing namespace std;\nint main() {\n    long long n;\n    if (cin >> n) {\n        if (n % 2 == 0) cout << \"CHAN\" << endl;\n        else cout << \"LE\" << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "8", "output": "CHAN", "points": 2, "hidden": 0},
                {"input": "13", "output": "LE", "points": 3, "hidden": 0},
                {"input": "0", "output": "CHAN", "points": 3, "hidden": 1},
                {"input": "-7", "output": "LE", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 3,
            "course_id": 1,
            "lesson_id": 3,
            "title": "Tìm số lớn nhất trong ba số",
            "description": "Viết chương trình nhập vào ba số nguyên a, b, c và in ra số lớn nhất trong ba số đó.",
            "input_description": "Một dòng chứa ba số nguyên a, b, c cách nhau bởi dấu cách.",
            "output_description": "In ra giá trị lớn nhất.",
            "sample_input": "4 9 2",
            "sample_output": "9",
            "explanation": "Trong ba số 4, 9, 2 thì số lớn nhất là 9.",
            "constraints": "-10^9 <= a, b, c <= 10^9",
            "difficulty": "Dễ",
            "topic": "If/Else",
            "reference_solution": "#include <iostream>\n#include <algorithm>\nusing namespace std;\nint main() {\n    long long a, b, c;\n    if (cin >> a >> b >> c) {\n        cout << max({a, b, c}) << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "4 9 2", "output": "9", "points": 2, "hidden": 0},
                {"input": "15 15 10", "output": "15", "points": 3, "hidden": 0},
                {"input": "-5 -2 -8", "output": "-2", "points": 3, "hidden": 1},
                {"input": "100 200 500", "output": "500", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 4,
            "course_id": 1,
            "lesson_id": 4,
            "title": "Tính tổng từ 1 đến N",
            "description": "Cho số nguyên dương n. Hãy tính và in ra tổng S = 1 + 2 + 3 + ... + n.",
            "input_description": "Một số nguyên dương n (1 <= n <= 10^6).",
            "output_description": "In ra giá trị của tổng S.",
            "sample_input": "5",
            "sample_output": "15",
            "explanation": "1 + 2 + 3 + 4 + 5 = 15.",
            "constraints": "1 <= n <= 10^6",
            "difficulty": "Dễ",
            "topic": "Vòng lặp",
            "reference_solution": "#include <iostream>\nusing namespace std;\nint main() {\n    long long n;\n    if (cin >> n) {\n        long long s = n * (n + 1) / 2;\n        cout << s << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "5", "output": "15", "points": 2, "hidden": 0},
                {"input": "1", "output": "1", "points": 3, "hidden": 0},
                {"input": "100", "output": "5050", "points": 3, "hidden": 1},
                {"input": "1000000", "output": "500000500000", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 5,
            "course_id": 1,
            "lesson_id": 4,
            "title": "Kiểm tra số nguyên tố",
            "description": "Số nguyên tố là số nguyên lớn hơn 1 chỉ có đúng 2 ước là 1 và chính nó. Viết chương trình nhập vào số nguyên n. Nếu n là số nguyên tố in YES, ngược lại in NO.",
            "input_description": "Số nguyên n (-10^9 <= n <= 10^9).",
            "output_description": "In YES hoặc NO.",
            "sample_input": "7",
            "sample_output": "YES",
            "explanation": "7 là số nguyên tố.",
            "constraints": "-10^9 <= n <= 10^9",
            "difficulty": "Trung bình",
            "topic": "Vòng lặp",
            "reference_solution": "#include <iostream>\nusing namespace std;\nbool isPrime(long long n) {\n    if (n <= 1) return false;\n    if (n <= 3) return true;\n    if (n % 2 == 0 || n % 3 == 0) return false;\n    for (long long i = 5; i * i <= n; i += 6) {\n        if (n % i == 0 || n % (i + 2) == 0) return false;\n    }\n    return true;\n}\nint main() {\n    long long n;\n    if (cin >> n) {\n        if (isPrime(n)) cout << \"YES\" << endl;\n        else cout << \"NO\" << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "7", "output": "YES", "points": 2, "hidden": 0},
                {"input": "1", "output": "NO", "points": 2, "hidden": 0},
                {"input": "4", "output": "NO", "points": 2, "hidden": 0},
                {"input": "999999937", "output": "YES", "points": 2, "hidden": 1},
                {"input": "-17", "output": "NO", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 6,
            "course_id": 1,
            "lesson_id": 4,
            "title": "Tính giai thừa của N",
            "description": "Viết chương trình tính N! = 1 * 2 * 3 * ... * N. Quy ước 0! = 1.",
            "input_description": "Số nguyên N (0 <= N <= 20).",
            "output_description": "In ra kết quả N!.",
            "sample_input": "5",
            "sample_output": "120",
            "explanation": "5! = 1 * 2 * 3 * 4 * 5 = 120.",
            "constraints": "0 <= N <= 20",
            "difficulty": "Dễ",
            "topic": "Vòng lặp",
            "reference_solution": "#include <iostream>\nusing namespace std;\nint main() {\n    int n;\n    if (cin >> n) {\n        long long ans = 1;\n        for (int i = 1; i <= n; i++) ans *= i;\n        cout << ans << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "5", "output": "120", "points": 2, "hidden": 0},
                {"input": "0", "output": "1", "points": 3, "hidden": 0},
                {"input": "10", "output": "3628800", "points": 3, "hidden": 1},
                {"input": "20", "output": "2432902008176640000", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 7,
            "course_id": 2,
            "lesson_id": 6,
            "title": "Tính tổng các phần tử trong mảng",
            "description": "Cho một mảng gồm n số nguyên. Hãy tính và in ra tổng của tất cả các phần tử trong mảng.",
            "input_description": "Dòng 1 chứa số nguyên n (1 <= n <= 10^5).\nDòng 2 chứa n số nguyên cách nhau bởi dấu cách.",
            "output_description": "In ra tổng các phần tử.",
            "sample_input": "4\n1 3 5 7",
            "sample_output": "16",
            "explanation": "1 + 3 + 5 + 7 = 16.",
            "constraints": "1 <= n <= 10^5, -10^9 <= a[i] <= 10^9",
            "difficulty": "Dễ",
            "topic": "Mảng",
            "reference_solution": "#include <iostream>\nusing namespace std;\nint main() {\n    int n;\n    if (cin >> n) {\n        long long sum = 0;\n        for (int i = 0; i < n; i++) {\n            long long x;\n            cin >> x;\n            sum += x;\n        }\n        cout << sum << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "4\n1 3 5 7", "output": "16", "points": 2, "hidden": 0},
                {"input": "3\n-5 10 -2", "output": "3", "points": 3, "hidden": 0},
                {"input": "5\n0 0 0 0 0", "output": "0", "points": 3, "hidden": 1},
                {"input": "6\n100 200 300 400 500 600", "output": "2100", "points": 2, "hidden": 1}
            ]
        },
        {
            "id": 8,
            "course_id": 2,
            "lesson_id": 7,
            "title": "Đảo ngược chuỗi ký tự",
            "description": "Cho một chuỗi s chỉ gồm các ký tự chữ cái và số không chứa dấu cách. Hãy in ra chuỗi đảo ngược của s.",
            "input_description": "Một chuỗi s có độ dài không quá 1000 ký tự.",
            "output_description": "In ra chuỗi đảo ngược.",
            "sample_input": "hello",
            "sample_output": "olleh",
            "explanation": "Chuỗi đảo ngược của hello là olleh.",
            "constraints": "1 <= length(s) <= 1000",
            "difficulty": "Dễ",
            "topic": "Chuỗi",
            "reference_solution": "#include <iostream>\n#include <string>\n#include <algorithm>\nusing namespace std;\nint main() {\n    string s;\n    if (cin >> s) {\n        reverse(s.begin(), s.end());\n        cout << s << endl;\n    }\n    return 0;\n}",
            "tests": [
                {"input": "hello", "output": "olleh", "points": 2, "hidden": 0},
                {"input": "CodeBeginner", "output": "rennigebedoC", "points": 3, "hidden": 0},
                {"input": "a", "output": "a", "points": 3, "hidden": 1},
                {"input": "123456789", "output": "987654321", "points": 2, "hidden": 1}
            ]
        }
    ]

    for ex in exercises_data:
        cursor.execute("""
        INSERT INTO exercises (id, course_id, lesson_id, title, description, input_description, output_description, sample_input, sample_output, explanation, constraints, difficulty, topic, reference_solution, points, expert_id, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'approved')
        """, (ex['id'], ex['course_id'], ex['lesson_id'], ex['title'], ex['description'], ex['input_description'], ex['output_description'], ex['sample_input'], ex['sample_output'], ex['explanation'], ex['constraints'], ex['difficulty'], ex['topic'], ex['reference_solution'], ex.get('points', 10), expert_id))

        for idx, tc in enumerate(ex['tests'], 1):
            cursor.execute("""
            INSERT INTO test_cases (exercise_id, input_data, expected_output, points, is_hidden, order_index)
            VALUES (?, ?, ?, ?, ?, ?)
            """, (ex['id'], tc['input'], tc['output'], tc['points'], tc['hidden'], idx))

    # 6. ENTRANCE QUESTIONS (16 câu hỏi trắc nghiệm chia theo 8 chủ đề chuẩn)
    entrance_questions = [
        # Biến và kiểu dữ liệu
        {
            "topic": "Biến và kiểu dữ liệu",
            "question": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?",
            "code": "/* Khai bao bien x */ x = 3.1415926535;",
            "options": ["int", "double", "char", "bool"],
            "correct": 1,
            "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."
        },
        {
            "topic": "Biến và kiểu dữ liệu",
            "question": "Đoạn mã sau in ra giá trị gì trên màn hình?",
            "code": "int a = 7;\nint b = 2;\ncout << a / b;",
            "options": ["3.5", "3", "4", "Báo lỗi biên dịch"],
            "correct": 1,
            "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."
        },
        # Nhập/xuất
        {
            "topic": "Nhập/xuất",
            "question": "Toán tử nào được sử dụng cùng với đối tượng 'cin' để đọc dữ liệu từ luồng đầu vào?",
            "code": "int x;\ncin ?? x;",
            "options": ["<<", ">>", "<=", ">="],
            "correct": 1,
            "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."
        },
        {
            "topic": "Nhập/xuất",
            "question": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?",
            "code": "cout << \"Hello\" ??",
            "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"],
            "correct": 1,
            "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."
        },
        # Toán tử
        {
            "topic": "Toán tử",
            "question": "Toán tử '%' trong C++ thực hiện phép toán nào?",
            "code": "int r = 17 % 5;",
            "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"],
            "correct": 2,
            "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."
        },
        {
            "topic": "Toán tử",
            "question": "Biểu thức logic '(5 > 3) && (2 >= 4)' trả về giá trị gì?",
            "code": "bool res = (5 > 3) && (2 >= 4);",
            "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"],
            "correct": 1,
            "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."
        },
        # If/Else
        {
            "topic": "If/Else",
            "question": "Đoạn mã sau in ra kết quả gì?",
            "code": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}",
            "options": ["A", "B", "C", "B C"],
            "correct": 1,
            "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra 'B' và kết thúc."
        },
        {
            "topic": "If/Else",
            "question": "Câu lệnh điều kiện if sau đây sẽ in ra gì?",
            "code": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}",
            "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"],
            "correct": 0,
            "explanation": "Toán tử '==' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in 'Sai'."
        },
        # Vòng lặp
        {
            "topic": "Vòng lặp",
            "question": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?",
            "code": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}",
            "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"],
            "correct": 1,
            "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."
        },
        {
            "topic": "Vòng lặp",
            "question": "Lệnh 'break' đặt trong thân vòng lặp có tác dụng gì?",
            "code": "while (true) {\n    if (dieu_kien) break;\n}",
            "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"],
            "correct": 1,
            "explanation": "'break' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."
        },
        # Mảng
        {
            "topic": "Mảng",
            "question": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng 'int arr[10];' lần lượt là:",
            "code": "int arr[10];",
            "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"],
            "correct": 1,
            "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."
        },
        {
            "topic": "Mảng",
            "question": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?",
            "code": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;",
            "options": ["25", "35", "30", "45"],
            "correct": 1,
            "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."
        },
        # Chuỗi
        {
            "topic": "Chuỗi",
            "question": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng 'string s' của thư viện chuẩn C++?",
            "code": "string s = \"LapTrinh\";",
            "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"],
            "correct": 1,
            "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."
        },
        # Hàm
        {
            "topic": "Hàm",
            "question": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?",
            "code": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}",
            "options": ["null", "empty", "void", "none"],
            "correct": 2,
            "explanation": "Từ khóa 'void' chỉ ra rằng hàm không trả về giá trị (thủ tục)."
        },
        {
            "topic": "Hàm",
            "question": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:",
            "code": "void hoanVi(int ??a, int ??b) { ... }",
            "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"],
            "correct": 0,
            "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."
        }
    ]

    for q in entrance_questions:
        cursor.execute("""
        INSERT INTO entrance_questions (topic, question_text, code_snippet, options_json, correct_answer, explanation)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (q['topic'], q['question'], q['code'], json.dumps(q['options'], ensure_ascii=False), q['correct'], q['explanation']))

    # 7. FORUM CATEGORIES
    cursor.execute("""
    INSERT INTO forum_categories (id, name, slug, description, icon, order_index) VALUES
    (1, 'C++', 'cpp', 'Thảo luận về cú pháp C++, con trỏ, STL, hướng đối tượng và tối ưu hóa mã nguồn', 'code', 1),
    (2, 'Thuật toán & Cấu trúc dữ liệu', 'algorithms', 'Trao đổi về giải thuật tìm kiếm, sắp xếp, quy hoạch động, cây và đồ thị', 'cpu', 2),
    (3, 'JavaScript & Web', 'javascript', 'Thảo luận phát triển giao diện web, tương tác DOM và lập trình JavaScript', 'globe', 3),
    (4, 'Python', 'python', 'Học tập Python cơ bản, xử lý dữ liệu và tự động hóa', 'terminal', 4),
    (5, 'Cơ sở dữ liệu', 'database', 'Truy vấn SQL, thiết kế cơ sở dữ liệu quan hệ và tối ưu bảng', 'database', 5),
    (6, 'Hỏi đáp chung & Thảo luận', 'general', 'Giao lưu học tập, kinh nghiệm rèn luyện kỹ năng code và giải đáp thắc mắc', 'message-circle', 6)
    """)

    # 8. SAMPLE FORUM THREADS & REPLIES
    cursor.execute("""
    INSERT INTO forum_threads (id, user_id, category_id, title, content, tags, views_count) VALUES
    (1, ?, 1, 'Tại sao vòng lặp for của em bị chạy vô tận khi duyệt số nguyên?',
     'Em viết đoạn mã kiểm tra chia hết từ n giảm về 0 nhưng chương trình cứ chạy mãi không dừng. Nhờ các anh chị chuyên gia xem giúp lỗi ở đâu ạ!\n\n```cpp\nfor (unsigned int i = 10; i >= 0; i--) {\n    cout << i << \" \";\n}\n```',
     'cpp,vòng-lặp,unsigned-int', 24),
    (2, ?, 2, 'Làm thế nào để phân biệt khi nào nên dùng DFS và khi nào nên dùng BFS?',
     'Chào mọi người, em đang học đồ thị và phân vân bài toán tìm đường đi ngắn nhất không trọng số thì nên dùng BFS hay DFS và tại sao ạ?',
     'thuật-toán,đồ-thị,bfs,dfs', 45)
    """, (learner_id, learner_id))

    cursor.execute("""
    INSERT INTO forum_replies (id, thread_id, user_id, content, is_accepted) VALUES
    (1, 1, ?, 'Chào bạn! Nguyên nhân là do bạn khai báo `unsigned int i`. Kiểu `unsigned int` là số nguyên không dấu nên giá trị nhỏ nhất của nó là 0. Khi i = 0 mà bị trừ đi 1 (i--), giá trị sẽ bị tràn số (underflow) nhảy lên giá trị cực đại 4294967295, do đó điều kiện `i >= 0` luôn luôn đúng! Để khắc phục, bạn chỉ cần đổi sang kiểu `int i` bình thường nhé.', 1),
    (2, 2, ?, 'Đối với bài toán tìm đường đi ngắn nhất trên đồ thị không trọng số (hoặc đồ thị mà tất cả các cạnh có trọng số bằng nhau là 1), bạn nên dùng **BFS (Tìm kiếm theo chiều rộng)**. Vì BFS duyệt theo từng mức (level), đỉnh nào được thăm trước chắc chắn sẽ có khoảng cách từ đỉnh xuất phát ngắn nhất.', 1)
    """, (expert_id, expert_id))

    # 9. SYSTEM SETTINGS
    cursor.execute("""
    INSERT INTO system_settings (key, value, description) VALUES
    ('site_name', 'CodeBeginner', 'Tên nền tảng hiển thị'),
    ('site_description', 'Hệ thống hỗ trợ học và luyện tập lập trình C++ từ cơ bản đến nâng cao', 'Mô tả tóm tắt'),
    ('default_time_limit', '2.0', 'Thời gian chạy tối đa mặc định cho mỗi test case (giây)'),
    ('default_memory_limit', '128', 'Bộ nhớ tối đa cho phép (MB)'),
    ('supported_languages', 'C++ (g++ 10.3 / C++17)', 'Danh sách môi trường biên dịch hỗ trợ')
    """)

    conn.commit()
    conn.close()
    print("Seed data completed successfully!")

if __name__ == "__main__":
    seed_all()
