# CodeBeginner – Hệ Thống Hỗ Trợ Học & Luyện Tập Lập Trình C++ Trực Tuyến

**CodeBeginner** là nền tảng Web full-stack hoàn chỉnh, phục vụ học tập, thi thử đánh giá đầu vào, phân tích điểm yếu học tập, luyện tập lập trình tương tác trực tuyến với bộ chấm tự động sử dụng trình biên dịch **GCC C++17** thực tế, kèm phân quyền 3 vai trò: **Học viên (Learner)**, **Chuyên gia / Giáo viên (Expert)** và **Quản trị viên (Admin)**.

---

## I. TỔNG QUAN HỆ THỐNG & TÍNH NĂNG NỔI BẬT

1. **Phân quyền 3 vai trò (Role-Based Access Control - RBAC)**:
   - **Học viên (Learner)**: Đăng ký tài khoản công khai, làm bài kiểm tra đầu vào xác định năng lực, xem radar điểm yếu, học lý thuyết theo lộ trình, viết mã nguồn C++ trên trình soạn thảo trực tuyến, nộp bài nhận kết quả chấm tự động ngay tức thì, tham gia diễn đàn hỏi đáp.
   - **Chuyên gia (Expert)**: Quản lý ngân hàng bài tập (độ khó: Dễ, Trung bình, Nâng cao; 8 chủ đề cốt lõi), cấu hình test case ẩn/công khai, đối chiếu kiểm tra bộ test với lời giải tham chiếu, xem xét các ca nộp bài gặp lỗi của học viên, phê duyệt/từ chối nội dung lý thuyết bài học.
   - **Quản trị viên (Admin)**: Quản lý tài khoản toàn hệ thống, cấp tài khoản Chuyên gia, khóa/mở khóa tài khoản, quản trị danh mục khóa học, xem báo cáo thống kê theo khoảng thời gian tùy chọn với biểu đồ thời gian thực từ cơ sở dữ liệu.

2. **Bộ chấm mã nguồn an toàn (Subprocess Sandbox GCC)**:
   - Sử dụng trình biên dịch `g++.exe` chuẩn C++17.
   - Cơ chế cách ly thư mục tạm thời (`tempfile.TemporaryDirectory`).
   - Giới hạn thời gian chạy (2.5 giây/test case) chống vòng lặp vô tận (Time Limit Exceeded).
   - Bắt và hiển thị lỗi biên dịch chi tiết (Compile Error), lỗi khi chạy (Runtime Error).
   - Bảo mật test case: Ẩn toàn bộ input/output của test case bí mật đối với học viên.

3. **Đánh giá đầu vào & Phân tích điểm yếu thông minh**:
   - Bài test đầu vào gồm 15 câu hỏi trắc nghiệm chia theo 8 chủ đề: *Biến và kiểu dữ liệu*, *Nhập/xuất*, *Toán tử*, *If/Else*, *Vòng lặp*, *Mảng*, *Chuỗi*, *Hàm*.
   - Biểu đồ mạng nhện (Radar Chart) và thanh tiến trình thể hiện % thành thạo từng chủ đề.
   - Tự động sinh lộ trình khắc phục điểm yếu: gợi ý bài học lý thuyết cần ôn tập và bài tập Dễ/Trung bình tương ứng.

4. **Diễn đàn Hỏi đáp & Trao đổi**:
   - 6 chuyên mục: C++, Thuật toán, Web/JS, Python, Cơ sở dữ liệu, Hỏi đáp chung.
   - Thảo luận hỗ trợ khối mã nguồn C++, chức năng Thích bài viết, Lưu bài viết (Bookmark), tác giả đánh dấu *Câu trả lời được chấp nhận*.

---

## II. THÔNG TIN ĐĂNG NHẬP THỬ NGHIỆM

Hệ thống đã được nạp sẵn dữ liệu mẫu (Seeded Data) với 3 tài khoản cho 3 vai trò:

| Vai trò | Tên đăng nhập | Mật khẩu | Email | Quyền hạn |
| :--- | :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin` | `Admin@123` | `admin@codebeginner.edu.vn` | Toàn quyền quản trị tài khoản, khóa học, báo cáo, cài đặt |
| **Chuyên gia (Expert)** | `expert` | `Expert@123` | `expert@codebeginner.edu.vn` | Quản lý bài tập, bộ test case, duyệt lý thuyết, soát xét bài nộp |
| **Học viên mẫu (Learner)** | `learner` | `Learner@123` | `learner@gmail.com` | Học lý thuyết, làm test đầu vào, giải bài tập, tham gia diễn đàn |

*(Người dùng mới có thể tự do đăng ký tài khoản Học viên mới từ trang Đăng ký)*

---

## III. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
codebeginner/
├── app.py                      # Bộ điều khiển chính (Flask Controllers, RBAC, REST APIs)
├── database.py                 # Định nghĩa cấu trúc 22 bảng SQLite và kết nối CSDL
├── judge_service.py            # Dịch vụ biên dịch & chấm code C++ sandbox an toàn với GCC
├── analytics_service.py        # Động cơ phân tích năng lực, điểm yếu & đề xuất lộ trình
├── seed_data.py                # Script nạp dữ liệu khởi tạo chuẩn đồ án
├── run.bat                     # File chạy 1-click trên môi trường Windows
├── README.md                   # Tài liệu hướng dẫn sử dụng và kiến trúc
├── codebeginner.db             # Cơ sở dữ liệu SQLite thực tế
├── templates/                  # Bộ giao diện HTML responsive
│   ├── base.html               # Khung layout chung, thanh điều hướng, Drawer menu (☰)
│   ├── index.html              # Trang chủ giới thiệu, lộ trình 4 cấp độ, khóa học tiêu biểu
│   ├── auth/                   # Đăng nhập, đăng ký
│   ├── learner/                # Khóa học, bài học lý thuyết, test đầu vào, editor code, điểm yếu, tiến độ
│   ├── forum/                  # Diễn đàn, chuyên mục, chi tiết câu hỏi, bài của tôi, thông báo
│   ├── expert/                 # Dashboard chuyên gia, quản lý bài tập, test cases, duyệt lý thuyết
│   ├── admin/                  # Dashboard quản trị, người dùng, báo cáo theo ngày, cài đặt
│   └── errors/                 # Trang lỗi 403, 404, 500
└── static/
    ├── css/style.css           # Tùy biến kiểu dáng và CodeMirror
    └── js/main.js              # Script hỗ trợ client-side
```

---

## IV. HƯỚNG DẪN CÀI ĐẶT & CHẠY DỰ ÁN

### Yêu cầu môi trường:
- **Python**: Phiên bản 3.10 trở lên (Đã có sẵn `Python 3.12.10` và thư viện `Flask 3.1.3`).
- **Trình biên dịch C++**: `g++` (TDM-GCC hoặc MinGW đã được tích hợp sẵn trong PATH).

### Cách 1: Chạy nhanh bằng file Batch (Khuyên dùng trên Windows)
Nhấp đúp chuột vào file:
```cmd
run.bat
```

### Cách 2: Chạy thủ công bằng Terminal / PowerShell
1. Mở PowerShell hoặc Command Prompt tại thư mục dự án:
   ```powershell
   cd C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner
   ```
2. Khởi tạo cơ sở dữ liệu mẫu:
   ```powershell
   python seed_data.py
   ```
3. Khởi chạy máy chủ:
   ```powershell
   python app.py
   ```
4. Mở trình duyệt Web và truy cập:
   ```text
   http://127.0.0.1:5000
   ```

---

## V. CÁC LUỒNG NGHIỆP VỤ ĐÃ HOÀN THIỆN & KIỂM THỬ

1. **Luồng 1 - Học viên mới**: Đăng ký &rarr; Đăng nhập &rarr; Thi đầu vào (15 câu) &rarr; Nhận phân tích radar 8 chủ đề &rarr; Xem lộ trình học đề xuất &rarr; Học lý thuyết với code mẫu &rarr; Hoàn thành bài học.
2. **Luồng 2 - Nộp bài & Chấm điểm tự động**: Chọn bài tập &rarr; Viết code C++ trên trình soạn thảo &rarr; Chạy thử với dữ liệu tự chọn (Custom Input) &rarr; Nộp bài chính thức &rarr; GCC biên dịch an toàn &rarr; Chấm toàn bộ bộ test case (ẩn/công khai) &rarr; Nhận điểm số và bảng chi tiết test case &rarr; Cập nhật tiến độ và điểm yếu.
3. **Luồng 3 - Phân tích điểm yếu**: Tự động tổng hợp kết quả test và bài nộp &rarr; Phát hiện chủ đề < 60% &rarr; Gợi ý bài học ôn tập và bài tập Dễ &rarr; Trung bình.
4. **Luồng 4 - Chuyên gia**: Đăng nhập &rarr; Tổng quan &rarr; Tạo bài tập &rarr; Cấu hình test case &rarr; Bấm "Kiểm tra bộ test với Lời giải mẫu" để thẩm định &rarr; Xem xét bài nộp gặp lỗi &rarr; Duyệt lý thuyết bài học.
5. **Luồng 5 - Quản trị viên**: Đăng nhập &rarr; Quản lý tài khoản &rarr; Cấp quyền Chuyên gia mới &rarr; Khóa/Mở khóa tài khoản &rarr; Quản trị khóa học &rarr; Báo cáo thống kê toàn hệ thống có bộ lọc theo khoảng ngày.
