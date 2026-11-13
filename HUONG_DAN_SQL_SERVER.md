# HƯỚNG DẪN MỞ & XEM DỮ LIỆU BẰNG SQL SERVER MANAGEMENT STUDIO (SSMS)

Toàn bộ hệ thống cơ sở dữ liệu **CodeBeginner** đã được chuẩn hóa và chuyển đổi hoàn toàn sang **Microsoft SQL Server**. Hệ thống hiện bao gồm đầy đủ **30 bảng dữ liệu** theo tài liệu phân tích nghiệp vụ LMS/EdTech, được nạp trực tiếp vào máy chủ SQL Server nội bộ trên máy tính của bạn (`localhost\SQLEXPRESS05`).

Dưới đây là các bước chi tiết để mở, xem bảng và duyệt dữ liệu.

---

## 1. Thông Tin Kết Nối SQL Server

- **Server Name (Tên máy chủ):** `localhost\SQLEXPRESS05` (hoặc `.\SQLEXPRESS05`)
- **Authentication (Xác thực):** `Windows Authentication`
- **Database (Tên cơ sở dữ liệu):** `codebeginner`
- **Tập tin script sao lưu T-SQL:** `codebeginner_sqlserver.sql` (hơn 1.800 dòng mã chuẩn T-SQL)

---

## 2. Cách Mở Bằng SQL Server Management Studio (SSMS 20)

### Bước 1: Khởi động SSMS
- Nhấn phím **Windows** trên bàn phím, gõ **SSMS** hoặc **SQL Server Management Studio 20** và bấm **Open**.
- *(Đường dẫn SSMS trên máy: `C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE\Ssms.exe`)*

### Bước 2: Đăng nhập vào Server
Khi cửa sổ **Connect to Server** hiện lên:
1. **Server type:** Chọn `Database Engine`.
2. **Server name:** Điền hoặc chọn `localhost\SQLEXPRESS05` (hoặc `.\SQLEXPRESS05`).
3. **Authentication:** Chọn `Windows Authentication`.
4. Nhấn nút **Connect**.

### Bước 3: Xem 30 Bảng Dữ Liệu Trong CSDL
1. Ở cột bên trái màn hình (**Object Explorer**):
   - Mở rộng mục **Databases** (nhấn dấu `+`).
   - Bạn sẽ thấy CSDL tên là **`codebeginner`**.
   - Mở rộng **`codebeginner`** &rarr; mở rộng mục **`Tables`**.
2. Toàn bộ **30 bảng dữ liệu** của website sẽ hiện ra:

| Nhóm Nghiệp Vụ | Các Bảng Trong SQL Server | Ý Nghĩa / Mục Đích |
| :--- | :--- | :--- |
| **Phân quyền & Người dùng** | `dbo.roles`, `dbo.users` | Quản lý vai trò (admin, expert, learner, moderator) & quyền hạn động |
| **Khóa học & Bài học** | `dbo.courses`, `dbo.chapters`, `dbo.lessons`, `dbo.lesson_progress`, `dbo.course_enrollments` | Khóa học C++, giáo trình, chương mục và tiến độ học viên |
| **Bài tập & Chấm code** | `dbo.exercises`, `dbo.test_cases`, `dbo.submissions` | Ngân hàng bài tập, bộ test cases ẩn/hiện, kết quả chấm code tự động |
| **Yêu cầu chấm lại** | `dbo.regrade_requests` | Quản lý học viên khiếu nại/xin phúc khảo bài nộp và phản hồi của giảng viên |
| **Giám sát & Chống gian lận** | `dbo.submission_events` | Ghi nhận bất thường khi làm bài (chuyển tab, paste code, rời màn hình) |
| **Khung kiểm tra & Đề thi** | `dbo.assessments`, `dbo.assessment_questions`, `dbo.assessment_attempts` | Chuẩn hóa ngân hàng đề thi tổng quát, danh mục câu hỏi và lượt làm bài |
| **Thi đầu vào (Hiện có)** | `dbo.entrance_questions`, `dbo.entrance_test_results`, `dbo.topic_weaknesses` | Đề thi phân loại đầu vào, kết quả và phân tích điểm yếu học viên |
| **Chứng chỉ** | `dbo.certificates` | Cấp phát và tra cứu mã chứng chỉ hoàn thành khóa học có mã hash |
| **Kiểm duyệt & Audit** | `dbo.moderator_assignments`, `dbo.expert_reviews`, `dbo.audit_logs` | Phân công kiểm duyệt, lịch sử phê duyệt nội dung và nhật ký hệ thống |
| **Diễn đàn hỏi đáp** | `dbo.forum_categories`, `dbo.forum_threads`, `dbo.forum_replies`, `dbo.forum_likes`, `dbo.saved_posts`, `dbo.forum_reports` | Diễn đàn cộng đồng học viên và giảng viên |
| **Hệ thống** | `dbo.notifications`, `dbo.system_settings` | Thông báo người dùng và cấu hình website |

3. **Cách xem dữ liệu trong bảng bất kỳ:**
   - Nhấp **chuột phải** vào bảng muốn xem (ví dụ: `dbo.roles`, `dbo.regrade_requests`, `dbo.certificates`).
   - Chọn **Select Top 1000 Rows**.
   - Kết quả bảng dữ liệu sẽ hiện ra ngay lập tức ở khung phía dưới bên phải.
4. **Cách sửa dữ liệu trực tiếp bằng giao diện:**
   - Nhấp **chuột phải** vào bảng &rarr; Chọn **Edit Top 200 Rows**.
   - Bạn có thể chỉnh sửa, thêm, xóa dòng trực tiếp trên giao diện lưới như Excel.

---

## 3. Cách Mở & Chạy Tập Tin Script `codebeginner_sqlserver.sql`

Nếu bạn muốn xem toàn bộ câu lệnh tạo 30 bảng, khóa ngoại và dữ liệu mẫu dưới dạng mã SQL:
1. Trong SSMS, bấm menu **File** &rarr; **Open** &rarr; **File...** (hoặc phím tắt **Ctrl + O**).
2. Tìm đến thư mục dự án và chọn file:
   `codebeginner_sqlserver.sql`
3. Tập lệnh T-SQL hoàn chỉnh (hơn 1.800 dòng mã) sẽ được mở trong cửa sổ truy vấn của SSMS.
4. Nhấn phím **F5** (hoặc bấm nút **Execute**) nếu muốn chạy lại toàn bộ kịch bản khởi tạo database từ đầu.

---

## 4. Cấu Hình Đa Nền Tảng (Multi-engine Configuration)

Website hiện hỗ trợ linh hoạt giữa Microsoft SQL Server, MySQL và SQLite qua file `db_config.json`:
- Khi `"db_type": "sqlserver"`: Website kết nối trực tiếp đến Microsoft SQL Server qua ODBC Driver.
- Nếu máy chủ SQL Server chưa bật hoặc gặp sự cố, hệ thống sẽ tự động chuyển dự phòng (fallback) sang SQLite cục bộ mà không làm gián đoạn website.

---

## 5. Danh Sách Tài Khoản Mặc Định

Tất cả tài khoản và dữ liệu đã được đồng bộ nguyên vẹn trong SQL Server:
- **Admin (Quản trị viên):** `admin` / Mật khẩu: `Admin@123` (Role ID: 1)
- **Expert (Chuyên gia/Giảng viên):** `expert1` / Mật khẩu: `Expert@123` (Role ID: 2)
- **Learner (Học viên):** `student1` / Mật khẩu: `Student@123` (Role ID: 3)
