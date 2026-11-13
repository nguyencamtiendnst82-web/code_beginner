# HƯỚNG DẪN MỞ VÀ SỬ DỤNG CƠ SỞ DỮ LIỆU MYSQL CHO CODEBEGINNER

Hệ thống đã xuất toàn bộ cơ sở dữ liệu và cấu trúc 23 bảng sang định dạng **MySQL**:
- File SQL: `codebeginner_mysql.sql`
- Đường dẫn: `C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner_mysql.sql`
- Kích thước: ~125 KB, chuẩn UTF-8, đầy đủ dữ liệu người dùng, bài tập, câu hỏi thi đầu vào và bộ test cases.

---

## 1. Cách Mở Bằng MySQL Workbench (Đã cài sẵn trên máy bạn)

Trên máy tính của bạn đã có sẵn **MySQL Workbench 8.0 CE**:

### Bước 1: Khởi động MySQL Workbench
- Nhấn phím `Windows`, gõ tìm kiếm **MySQL Workbench** và mở lên.

### Bước 2: Kết nối vào MySQL
- Nhấp vào kết nối máy chủ của bạn (ví dụ: **Local instance MySQL80** hoặc **Localhost:3306**).
- Nhập mật khẩu tài khoản `root` nếu được yêu cầu.

### Bước 3: Mở và Thực thi file SQL
1. Trên thanh menu trên cùng, chọn: **File** -> **Open SQL Script...** (hoặc bấm tổ hợp phím `Ctrl + Shift + O`).
2. Trỏ tới file:
   `C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner_mysql.sql`
3. Nhấp vào biểu tượng **Tia sét ⚡ (Execute)** trên thanh công cụ để thực thi toàn bộ script.
4. Quá trình tạo database `codebeginner` và nạp dữ liệu sẽ hoàn tất trong 2 giây!

### Bước 4: Xem Dữ liệu Trực Quan
- Ở khung bên trái mục **Navigator / Schemas**, nhấp chuột phải chọn **Refresh All**.
- Bạn sẽ thấy database **`codebeginner`** xuất hiện.
- Mở rộng mục **Tables**, bạn sẽ thấy đầy đủ danh sách 23 bảng:
  - `users`: Danh sách tài khoản học viên, quản trị viên, chuyên gia.
  - `exercises`: Danh sách bài tập C++.
  - `test_cases`: Các bộ test case chấm điểm.
  - `entrance_questions`: 15 câu trắc nghiệm đầu vào.
  - `submissions`: Lịch sử nộp bài và chấm điểm.
- Để xem dữ liệu bảng nào, bạn chỉ cần di chuột vào tên bảng và bấm vào **biểu tượng bảng tính nhỏ (View Data)** ở góc phải của tên bảng.

---

## 2. Cách Nhập (Import) Bằng XAMPP / phpMyAdmin (Nếu dùng XAMPP)

Nếu bạn dùng XAMPP hoặc Laragon:
1. Mở trình duyệt vào trang: `http://localhost/phpmyadmin`
2. Bấm vào tab **Import** (Nhập).
3. Bấm **Choose File** (Chọn tệp) và chọn file `codebeginner_mysql.sql`.
4. Cuộn xuống dưới cùng và bấm nút **Import** (Thực hiện).

---

## 3. Cấu Hình Ứng Dụng Chạy Trực Tiếp Với MySQL

File cấu hình kết nối nằm tại:
`C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\db_config.json`

Nội dung cấu hình:
`json
{
  "db_type": "mysql",
  "mysql": {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": "codebeginner",
    "charset": "utf8mb4"
  },
  "sqlite": {
    "db_path": "codebeginner.db"
  }
}
`

- Nếu MySQL của bạn có mật khẩu, hãy điền vào ô `"password"`.
- Nếu cổng MySQL của bạn khác 3306 (ví dụ: 3307), hãy sửa lại ở ô `"port"`.
- Khi MySQL Server đang chạy, ứng dụng CodeBeginner sẽ tự động kết nối và lưu dữ liệu trực tiếp vào MySQL!
- Nếu MySQL chưa bật, hệ thống sẽ tự động dùng SQLite dự phòng để website không bao giờ bị sập.

---

## 4. Cập Nhật Lại Dữ Liệu MySQL Sau Này

Nếu sau này bạn có thêm dữ liệu mới trong SQLite và muốn xuất lại sang file MySQL:
`powershell
python migrate_to_mysql.py
`
Script sẽ tự động quét cơ sở dữ liệu hiện tại và cập nhật lại file `codebeginner_mysql.sql`!
