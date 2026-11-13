-- ========================================================
-- CODEBEGINNER PLATFORM - COMPLETE MICROSOFT SQL SERVER SCHEMA & DATA
-- Generated At: 2026-11-11 21:33:46
-- Compatible with SQL Server 2017+, 2019+, 2022+, Azure SQL
-- Total Tables: 37
-- ========================================================

USE [master];
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'codebeginner')
BEGIN
    CREATE DATABASE [codebeginner] COLLATE Vietnamese_CI_AS;
END
GO

USE [codebeginner];
GO

-- --------------------------------------------------------
-- Table structure for [roles]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[roles]', N'U') IS NOT NULL DROP TABLE [dbo].[roles];
GO
CREATE TABLE [dbo].[roles] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(50) NOT NULL UNIQUE,
    [display_name] NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(255) NULL,
    [permissions_json] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE()
);
GO

-- Dumping data for table [roles] (4 records)
SET IDENTITY_INSERT [dbo].[roles] ON;
GO
INSERT INTO [dbo].[roles] ([id], [name], [display_name], [description], [permissions_json], [created_at]) VALUES
  (1, N'admin', N'Quản trị viên', N'Toàn quyền quản trị hệ thống, quản lý người dùng, cấu hình và báo cáo', N'["all", "manage_users", "manage_courses", "view_audit_logs", "manage_settings"]', N'2026-11-10 15:05:21'),
  (2, N'expert', N'Chuyên gia nội dung', N'Biên soạn khóa học, bài học, bài tập lập trình, duyệt nội dung và chấm phúc khảo', N'["create_course", "create_exercise", "review_content", "regrade_submissions"]', N'2026-11-10 15:05:21'),
  (3, N'learner', N'Học viên', N'Tham gia học tập, làm bài kiểm tra, nộp bài tập lập trình và thảo luận trên diễn đàn', N'["enroll_courses", "submit_code", "take_assessments", "create_threads", "request_regrade"]', N'2026-11-10 15:05:21'),
  (4, N'moderator', N'Kiểm duyệt viên', N'Kiểm duyệt nội dung diễn đàn, báo cáo vi phạm và hỗ trợ rà soát chất lượng', N'["review_forum_reports", "lock_threads", "review_content"]', N'2026-11-10 15:05:21');
GO
SET IDENTITY_INSERT [dbo].[roles] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [users]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[users]', N'U') IS NOT NULL DROP TABLE [dbo].[users];
GO
CREATE TABLE [dbo].[users] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [username] NVARCHAR(100) NOT NULL UNIQUE,
    [password_hash] NVARCHAR(255) NOT NULL,
    [email] NVARCHAR(150) NOT NULL UNIQUE,
    [full_name] NVARCHAR(150) NOT NULL,
    [role] NVARCHAR(30) NOT NULL DEFAULT 'learner',
    [status] NVARCHAR(30) NOT NULL DEFAULT 'active',
    [avatar] NVARCHAR(255) DEFAULT '/static/img/default-avatar.png',
    [bio] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [role_id] INT NULL,
    [phone] NVARCHAR(20) DEFAULT '',
    [failed_login_attempts] INT DEFAULT 0,
    [locked_until] DATETIME2 NULL,
    [force_password_change] TINYINT DEFAULT 0,
    [reset_token] NVARCHAR(100) NULL,
    [reset_token_expiry] DATETIME2 NULL,
    CONSTRAINT [fk_users_role] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([id]) ON DELETE SET NULL
);
GO

-- Dumping data for table [users] (7 records)
SET IDENTITY_INSERT [dbo].[users] ON;
GO
INSERT INTO [dbo].[users] ([id], [username], [password_hash], [email], [full_name], [role], [status], [avatar], [bio], [created_at], [role_id], [phone], [failed_login_attempts], [locked_until], [force_password_change], [reset_token], [reset_token_expiry]) VALUES
  (1, N'admin', N'scrypt:32768:8:1$ogmf4iWZM1XzA5mP$a8767c5cb6c64c75d296816715e376f42a01d53ae09d73ac5a6be907f33fc11f2bcb86ea1248a9341819d544dccf9038364ccca04381e984ac09217084ccc8da', N'admin@codebeginner.edu.vn', N'Quản Trị Viên Hệ Thống', N'admin', N'active', N'/static/img/default-avatar.png', N'Quản trị viên toàn hệ thống CodeBeginner', N'2026-10-15 06:38:05', 1, N'', 0, NULL, 0, NULL, NULL),
  (2, N'expert', N'scrypt:32768:8:1$hZaqZ5PO40aDI0KM$cae05ea123cd57284a48293ac47f40dfb93c0447abf54f91ab077a1ff25e2d306687cf5d6d1e8d558a821b512184cef592a1e9bdbaa57b70366e0aec2581c815', N'expert@codebeginner.edu.vn', N'ThS. Nguyễn Văn Chuyên Gia', N'expert', N'active', N'/static/img/default-avatar.png', N'Giảng viên chuyên ngành Khoa học Máy tính & Lập trình C++', N'2026-10-15 06:38:05', 2, N'', 0, NULL, 0, NULL, NULL),
  (3, N'learner', N'scrypt:32768:8:1$759muifO2C3yG0O7$c5cb50218b8c8e5e38d5e0e1d32278bd5ce68d9a777be6888d4b0d9b8f35aeaf217f92200e36cbf7c2df18e558b9f523b15d9b57d58335e94e9c489c0f8fecc4', N'learner@gmail.com', N'Trần Văn Học Viên', N'learner', N'active', N'/static/img/default-avatar.png', N'Người mới bắt đầu khám phá thế giới lập trình C++', N'2026-10-15 06:38:05', 3, N'', 0, NULL, 0, NULL, NULL),
  (4, N'tien', N'scrypt:32768:8:1$5WDk6Ssa3bKHCkxc$b3bd4c167dcf905add3ddb7dc135b139ac5be45350b68538b6f1048c9c37328e40df3f56054dbb7114f52bb38914ee4e1db2f1170ce5f4e429d34c482d6b2cb8', N'tientientien@gmail.com', N'Nguyễn Văn Tiên', N'learner', N'active', N'/static/img/default-avatar.png', N'', N'2026-10-15 07:05:35', 3, N'', 0, NULL, 0, NULL, NULL),
  (5, N'Nha', N'scrypt:32768:8:1$HqA5OjiJX21jl64l$22f3a8d0fa88bfa907dfbe723afda92c22ef4b6146a5c337abd28e1a8366d8705021b40d45449673d00b8bafc47eca9a3734851927ab938d9122c350df933b63', N'nha@g.com', N'Nha', N'learner', N'active', N'/static/img/default-avatar.png', N'', N'2026-10-15 07:25:00', 3, N'', 0, NULL, 0, NULL, NULL),
  (6, N'sdf', N'scrypt:32768:8:1$dRV8wMnVLjl8PUDz$7dfed5dae01f5222da4d5fe46d7df2854e48a480a78d2f7c08f2a4640c039dacb8d0f6afd0c86ac9cc3988be8208f9eb9fd4614dfb538b938227671b77a634cd', N'vana@gmail.com', N'dsf', N'learner', N'active', N'/static/img/default-avatar.png', N'', N'2026-10-15 07:41:08', 3, N'', 0, NULL, 0, NULL, NULL),
  (7, N'Web', N'scrypt:32768:8:1$LuKaubIVe34C3vYw$664b66feb56a5c104baff030014279e919e4c2ed3150f1bb3e75d9b10d9864e276ac1e9915f82e052a8529ce2704fce5cc8be8bc1cb7f1e3b0650dea0d6c7f7b', N'web@gmail.com', N'Nguyễn Văn Web', N'learner', N'active', N'/static/img/default-avatar.png', N'', N'2026-10-23 04:51:27', 3, N'', 0, NULL, 0, NULL, NULL);
GO
SET IDENTITY_INSERT [dbo].[users] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [courses]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[courses]', N'U') IS NOT NULL DROP TABLE [dbo].[courses];
GO
CREATE TABLE [dbo].[courses] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NOT NULL,
    [language] NVARCHAR(50) NOT NULL DEFAULT 'C++',
    [level] NVARCHAR(50) NOT NULL,
    [image_url] NVARCHAR(255) DEFAULT '',
    [status] NVARCHAR(30) NOT NULL DEFAULT 'published',
    [expert_id] INT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [parent_course_id] INT NULL,
    [order_in_chain] INT DEFAULT 1,
    [prerequisite_course_id] INT NULL,
    [start_date] DATETIME2 NULL,
    [end_date] DATETIME2 NULL,
    [is_public_view] TINYINT DEFAULT 1,
    [allow_self_enroll] TINYINT DEFAULT 1,
    [forum_enabled] TINYINT DEFAULT 1,
    [min_lesson_pct] FLOAT DEFAULT 80.0,
    [min_exercise_count] INT DEFAULT 5,
    [min_final_score] FLOAT DEFAULT 60.0,
    [certificate_enabled] TINYINT DEFAULT 1,
    CONSTRAINT [fk_courses_expert] FOREIGN KEY ([expert_id]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL,
    CONSTRAINT [fk_courses_parent] FOREIGN KEY ([parent_course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_courses_prereq] FOREIGN KEY ([prerequisite_course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [courses] (2 records)
SET IDENTITY_INSERT [dbo].[courses] ON;
GO
INSERT INTO [dbo].[courses] ([id], [title], [description], [language], [level], [image_url], [status], [expert_id], [created_at], [parent_course_id], [order_in_chain], [prerequisite_course_id], [start_date], [end_date], [is_public_view], [allow_self_enroll], [forum_enabled], [min_lesson_pct], [min_exercise_count], [min_final_score], [certificate_enabled]) VALUES
  (1, N'C++ Cơ Bản & Nền Tảng Cho Người Mới Bắt Đầu', N'Khóa học nhập môn lập trình bài bản từ biến, kiểu dữ liệu, nhập xuất, điều kiện rẽ nhánh đến vòng lặp và hàm. Phù hợp tuyệt đối cho người chưa biết lập trình.', N'C++', N'Cơ bản', N'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&auto=format&fit=crop&q=60', N'published', 2, N'2026-10-15 06:38:05', NULL, 1, NULL, NULL, NULL, 1, 1, 1, 80.0, 5, 60.0, 1),
  (2, N'C++ Cấu Trúc Dữ Liệu & Thuật Toán Cơ Bản Đến Nâng Cao', N'Khám phá mảng, chuỗi, đệ quy, sắp xếp, tìm kiếm và các cấu trúc dữ liệu nền tảng như Stack, Queue, Cây nhị phân và Quy hoạch động.', N'C++', N'Nâng cao', N'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=60', N'published', 2, N'2026-10-15 06:38:05', NULL, 1, NULL, NULL, NULL, 1, 1, 1, 80.0, 5, 60.0, 1);
GO
SET IDENTITY_INSERT [dbo].[courses] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [chapters]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[chapters]', N'U') IS NOT NULL DROP TABLE [dbo].[chapters];
GO
CREATE TABLE [dbo].[chapters] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [course_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [order_index] INT NOT NULL DEFAULT 1,
    [description] NVARCHAR(MAX) NULL,
    [is_sequential] TINYINT DEFAULT 0,
    [passing_rule] NVARCHAR(100) DEFAULT 'all_passed',
    [min_exercises_to_pass] INT DEFAULT 0,
    [status] NVARCHAR(30) DEFAULT 'published',
    CONSTRAINT [fk_chapters_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [chapters] (7 records)
SET IDENTITY_INSERT [dbo].[chapters] ON;
GO
INSERT INTO [dbo].[chapters] ([id], [course_id], [title], [order_index], [description], [is_sequential], [passing_rule], [min_exercises_to_pass], [status]) VALUES
  (1, 1, N'Chương 1: Khởi động với Lập trình & C++', 1, N'', 0, N'all_passed', 0, N'published'),
  (2, 1, N'Chương 2: Cấu trúc Rẽ nhánh & Điều kiện', 2, N'', 0, N'all_passed', 0, N'published'),
  (3, 1, N'Chương 3: Cấu trúc Vòng lặp', 3, N'', 0, N'all_passed', 0, N'published'),
  (4, 1, N'Chương 4: Hàm và Tổ chức Chương trình', 4, N'', 0, N'all_passed', 0, N'published'),
  (5, 2, N'Chương 1: Mảng và Chuỗi ký tự', 1, N'', 0, N'all_passed', 0, N'published'),
  (6, 2, N'Chương 2: Thuật toán Tìm kiếm & Sắp xếp', 2, N'', 0, N'all_passed', 0, N'published'),
  (7, 2, N'Chương 3: Đệ quy & Cấu trúc Dữ liệu Nâng cao', 3, N'', 0, N'all_passed', 0, N'published');
GO
SET IDENTITY_INSERT [dbo].[chapters] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [lessons]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[lessons]', N'U') IS NOT NULL DROP TABLE [dbo].[lessons];
GO
CREATE TABLE [dbo].[lessons] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [course_id] INT NOT NULL,
    [chapter_id] INT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [syntax_guide] NVARCHAR(MAX) NULL,
    [example_code] NVARCHAR(MAX) NULL,
    [example_output] NVARCHAR(MAX) NULL,
    [quiz_data] NVARCHAR(MAX) NULL,
    [order_index] INT NOT NULL DEFAULT 1,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'approved',
    [reject_reason] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [is_trial] TINYINT DEFAULT 0,
    [video_url] NVARCHAR(255) NULL,
    [image_url] NVARCHAR(255) NULL,
    CONSTRAINT [fk_lessons_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_lessons_chapter] FOREIGN KEY ([chapter_id]) REFERENCES [dbo].[chapters] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [lessons] (7 records)
SET IDENTITY_INSERT [dbo].[lessons] ON;
GO
INSERT INTO [dbo].[lessons] ([id], [course_id], [chapter_id], [title], [content], [syntax_guide], [example_code], [example_output], [quiz_data], [order_index], [status], [reject_reason], [created_at], [is_trial], [video_url], [image_url]) VALUES
  (1, 1, 1, N'Giới thiệu C++ và Cấu trúc chương trình chuẩn', N'C++ là ngôn ngữ lập trình đa nền tảng mạnh mẽ được phát triển bởi Bjarne Stroustrup từ năm 1979 tại Bell Labs. C++ kết hợp cả đặc tính hướng thủ tục và hướng đối tượng, cho phép quản lý bộ nhớ trực tiếp và đạt hiệu năng tối đa trong phát triển hệ thống, trò chơi và thuật toán thi đấu.', N'#include <iostream>
using namespace std;

int main() {
    // Khối mã lệnh ở đây
    return 0;
}', N'#include <iostream>
using namespace std;

int main() {
    cout << "Chao mung den voi CodeBeginner!" << endl;
    return 0;
}', N'Chao mung den voi CodeBeginner!', N'[{"question": "Lệnh nào sau đây dùng để xuất dữ liệu ra màn hình trong C++?", "options": ["cin", "cout", "printf_s", "output"], "correct": 1, "explanation": "cout kết hợp toán tử << được dùng để in thông tin ra màn hình."}]', 1, N'approved', N'', N'2026-10-15 06:38:05', 1, N'', N''),
  (2, 1, 1, N'Biến, Kiểu dữ liệu và Nhập/Xuất trong C++', N'Biến là vùng nhớ được đặt tên dùng để lưu trữ dữ liệu trong quá trình chạy chương trình. Các kiểu dữ liệu cơ bản bao gồm:
- int: số nguyên (ví dụ: -5, 0, 100)
- double / float: số thực có dấu chấm động (ví dụ: 3.14, -0.05)
- char: ký tự đơn đặt trong dấu nháy đơn (ví dụ: ''a'', ''Z'')
- bool: giá trị logic (true hoặc false)
- string: chuỗi ký tự (cần #include <string>).

Sử dụng cin >> ten_bien để nhận dữ liệu từ bàn phím và cout << gia_tri để xuất ra màn hình.', N'Kieu_Du_Lieu ten_bien = gia_tri_khoi_tao;
cin >> ten_bien;
cout << "Gia tri: " << ten_bien;', N'#include <iostream>
using namespace std;

int main() {
    int tuoi;
    cout << "Nhap tuoi cua ban: ";
    if (cin >> tuoi) {
        cout << "Ban " << tuoi << " tuoi." << endl;
    }
    return 0;
}', N'Nhap tuoi cua ban: 20
Ban 20 tuoi.', N'[{"question": "Kiểu dữ liệu nào lưu trữ số nguyên 4 byte phổ biến nhất trong C++?", "options": ["float", "double", "int", "char"], "correct": 2, "explanation": "Kiểu int thường dùng để lưu số nguyên và có kích thước 4 byte trên hệ thống hiện đại."}]', 2, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N''),
  (3, 1, 2, N'Câu lệnh điều kiện If - Else & Toán tử so sánh', N'Câu lệnh if/else dùng để kiểm tra điều kiện logic và phân nhánh luồng thực thi của chương trình. Các toán tử so sánh gồm: == (bằng), != (khác), > (lớn hơn), < (nhỏ hơn), >= (lớn hơn hoặc bằng), <= (nhỏ hơn hoặc bằng). Các toán tử logic gồm: && (VÀ), || (HOẶC), ! (PHỦ ĐỊNH).', N'if (dieu_kien) {
    // Thuc hien khi dieu kien dung
} else {
    // Thuc hien khi dieu kien sai
}', N'#include <iostream>
using namespace std;

int main() {
    int diem = 8;
    if (diem >= 5) {
        cout << "Dat yeu cau!";
    } else {
        cout << "Can hoc lai!";
    }
    return 0;
}', N'Dat yeu cau!', N'[{"question": "Trong câu lệnh if-else, khối lệnh else sẽ được thực hiện khi nào?", "options": ["Khi điều kiện if trả về true", "Khi điều kiện if trả về false", "Luôn luôn được thực hiện", "Không bao giờ được thực hiện"], "correct": 1, "explanation": "Khối lệnh else chỉ chạy khi biểu thức điều kiện trong if sai (false)."}]', 3, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N''),
  (4, 1, 3, N'Vòng lặp For, While và Do-While', N'Vòng lặp cho phép thực hiện lặp lại một đoạn code nhiều lần cho đến khi thỏa mãn một điều kiện dừng nhất định.
- Vòng lặp for: Phù hợp khi biết trước số lần lặp cụ thể.
- Vòng lặp while: Phù hợp khi chưa biết trước số lần lặp, kiểm tra điều kiện trước.
- Vòng lặp do-while: Luôn thực hiện thân vòng lặp ít nhất 1 lần trước khi kiểm tra điều kiện.', N'for (khoi_tao; dieu_kien; buoc_nhay) {
    // Than vong lap
}

while (dieu_kien) {
    // Than vong lap
}', N'#include <iostream>
using namespace std;

int main() {
    int tong = 0;
    for (int i = 1; i <= 5; i++) {
        tong += i;
    }
    cout << "Tong tu 1 den 5 la: " << tong << endl;
    return 0;
}', N'Tong tu 1 den 5 la: 15', N'[{"question": "Vòng lặp while kiểm tra điều kiện vào thời điểm nào?", "options": ["Sau khi chạy hết thân vòng lặp", "Trước khi chạy thân vòng lặp", "Ở giữa thân vòng lặp", "Không bao giờ kiểm tra"], "correct": 1, "explanation": "Vòng lặp while là vòng lặp kiểm tra trước, nếu điều kiện đúng mới thực hiện thân vòng lặp."}]', 4, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N''),
  (5, 1, 4, N'Hàm (Function) và Tổ chức chương trình', N'Hàm là một khối lệnh độc lập được đặt tên, nhận các tham số đầu vào và trả về một kết quả. Hàm giúp tái sử dụng mã nguồn, chia nhỏ bài toán phức tạp thành các phần tử dễ quản lý.
Cần phân biệt giữa truyền tham trị (truyền bản sao) và truyền tham chiếu (sử dụng dấu & để thay đổi trực tiếp biến gốc).', N'Kieu_Tra_Ve Ten_Ham(Danh_Sach_Tham_So) {
    // Than ham
    return gia_tri;
}', N'#include <iostream>
using namespace std;

int tinhTong(int a, int b) {
    return a + b;
}

int main() {
    int ketQua = tinhTong(15, 25);
    cout << "Ket qua: " << ketQua << endl;
    return 0;
}', N'Ket qua: 40', N'[]', 5, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N''),
  (6, 2, 5, N'Mảng một chiều (One-Dimensional Array) trong C++', N'Mảng một chiều là tập hợp các phần tử có cùng kiểu dữ liệu được lưu trữ liên tiếp trong bộ nhớ máy tính. Mỗi phần tử trong mảng được định danh bằng chỉ số (index), bắt đầu từ chỉ số 0 đến n - 1.', N'Kieu_Du_Lieu ten_mang[Kich_Thuoc];
ten_mang[0] = gia_tri;', N'#include <iostream>
using namespace std;

int main() {
    int a[5] = {2, 4, 6, 8, 10};
    for (int i = 0; i < 5; i++) {
        cout << a[i] << " ";
    }
    return 0;
}', N'2 4 6 8 10', N'[]', 6, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N''),
  (7, 2, 5, N'Chuỗi ký tự std::string trong C++', N'std::string trong C++ là lớp đối tượng biểu diễn chuỗi ký tự linh hoạt hơn rất nhiều so với chuỗi ký tự kiểu mảng C-string char[]. Nó hỗ trợ nối chuỗi bằng toán tử +, tính độ dài bằng .length() hoặc .size(), lấy ký tự theo chỉ mục.', N'#include <string>
string s = "Hello";
s += " World";', N'#include <iostream>
#include <string>
using namespace std;

int main() {
    string s = "CodeBeginner";
    cout << "Do dai: " << s.length() << endl;
    cout << "Ky tu dau: " << s[0] << endl;
    return 0;
}', N'Do dai: 12
Ky tu dau: C', N'[]', 7, N'approved', N'', N'2026-10-15 06:38:05', 0, N'', N'');
GO
SET IDENTITY_INSERT [dbo].[lessons] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [exercises]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[exercises]', N'U') IS NOT NULL DROP TABLE [dbo].[exercises];
GO
CREATE TABLE [dbo].[exercises] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [course_id] INT NULL,
    [lesson_id] INT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NOT NULL,
    [input_description] NVARCHAR(MAX) NOT NULL,
    [output_description] NVARCHAR(MAX) NOT NULL,
    [sample_input] NVARCHAR(MAX) NOT NULL,
    [sample_output] NVARCHAR(MAX) NOT NULL,
    [explanation] NVARCHAR(MAX) NULL,
    [constraints] NVARCHAR(MAX) NULL,
    [difficulty] NVARCHAR(50) NOT NULL DEFAULT N'Dễ',
    [topic] NVARCHAR(100) NOT NULL,
    [reference_solution] NVARCHAR(MAX) NULL,
    [points] INT NOT NULL DEFAULT 10,
    [time_limit] FLOAT NOT NULL DEFAULT 2.0,
    [memory_limit] INT NOT NULL DEFAULT 128,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'approved',
    [expert_id] INT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [reference_solution_tested] TINYINT DEFAULT 0,
    [custom_checker_code] NVARCHAR(MAX) NULL,
    [custom_checker_lang] NVARCHAR(50) DEFAULT 'C++',
    [hints_json] NVARCHAR(MAX) DEFAULT '[]',
    CONSTRAINT [fk_exercises_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_exercises_lesson] FOREIGN KEY ([lesson_id]) REFERENCES [dbo].[lessons] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_exercises_expert] FOREIGN KEY ([expert_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [exercises] (8 records)
SET IDENTITY_INSERT [dbo].[exercises] ON;
GO
INSERT INTO [dbo].[exercises] ([id], [course_id], [lesson_id], [title], [description], [input_description], [output_description], [sample_input], [sample_output], [explanation], [constraints], [difficulty], [topic], [reference_solution], [points], [time_limit], [memory_limit], [status], [expert_id], [created_at], [reference_solution_tested], [custom_checker_code], [custom_checker_lang], [hints_json]) VALUES
  (1, 1, 2, N'Tính tổng hai số nguyên', N'Viết chương trình đọc vào hai số nguyên a và b từ bàn phím, sau đó in ra tổng của hai số đó.', N'Một dòng duy nhất chứa hai số nguyên a và b cách nhau bởi dấu cách (-10^9 <= a, b <= 10^9).', N'In ra một số nguyên duy nhất là tổng a + b.', N'5 7', N'12', N'5 + 7 = 12.', N'-10^9 <= a, b <= 10^9', N'Dễ', N'Nhập/xuất', N'#include <iostream>
using namespace std;
int main() {
    long long a, b;
    if (cin >> a >> b) {
        cout << (a + b) << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 1, N'', N'C++', N'["Gợi ý 1: Số chẵn là số chia hết cho 2 (dư 0).", "Gợi ý 2: Sử dụng toán tử % trong C++: if (n % 2 == 0)"]'),
  (2, 1, 3, N'Kiểm tra tính chẵn lẻ', N'Viết chương trình nhập vào một số nguyên n. Nếu n là số chẵn in ra CHAN, ngược lại in ra LE.', N'Số nguyên n (-10^9 <= n <= 10^9).', N'In ra CHAN hoặc LE trên một dòng.', N'8', N'CHAN', N'8 chia hết cho 2 nên in ra CHAN.', N'-10^9 <= n <= 10^9', N'Dễ', N'If/Else', N'#include <iostream>
using namespace std;
int main() {
    long long n;
    if (cin >> n) {
        if (n % 2 == 0) cout << "CHAN" << endl;
        else cout << "LE" << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (3, 1, 3, N'Tìm số lớn nhất trong ba số', N'Viết chương trình nhập vào ba số nguyên a, b, c và in ra số lớn nhất trong ba số đó.', N'Một dòng chứa ba số nguyên a, b, c cách nhau bởi dấu cách.', N'In ra giá trị lớn nhất.', N'4 9 2', N'9', N'Trong ba số 4, 9, 2 thì số lớn nhất là 9.', N'-10^9 <= a, b, c <= 10^9', N'Dễ', N'If/Else', N'#include <iostream>
#include <algorithm>
using namespace std;
int main() {
    long long a, b, c;
    if (cin >> a >> b >> c) {
        cout << max({a, b, c}) << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (4, 1, 4, N'Tính tổng từ 1 đến N', N'Cho số nguyên dương n. Hãy tính và in ra tổng S = 1 + 2 + 3 + ... + n.', N'Một số nguyên dương n (1 <= n <= 10^6).', N'In ra giá trị của tổng S.', N'5', N'15', N'1 + 2 + 3 + 4 + 5 = 15.', N'1 <= n <= 10^6', N'Dễ', N'Vòng lặp', N'#include <iostream>
using namespace std;
int main() {
    long long n;
    if (cin >> n) {
        long long s = n * (n + 1) / 2;
        cout << s << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (5, 1, 4, N'Kiểm tra số nguyên tố', N'Số nguyên tố là số nguyên lớn hơn 1 chỉ có đúng 2 ước là 1 và chính nó. Viết chương trình nhập vào số nguyên n. Nếu n là số nguyên tố in YES, ngược lại in NO.', N'Số nguyên n (-10^9 <= n <= 10^9).', N'In YES hoặc NO.', N'7', N'YES', N'7 là số nguyên tố.', N'-10^9 <= n <= 10^9', N'Trung bình', N'Vòng lặp', N'#include <iostream>
using namespace std;
bool isPrime(long long n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (long long i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
}
int main() {
    long long n;
    if (cin >> n) {
        if (isPrime(n)) cout << "YES" << endl;
        else cout << "NO" << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (6, 1, 4, N'Tính giai thừa của N', N'Viết chương trình tính N! = 1 * 2 * 3 * ... * N. Quy ước 0! = 1.', N'Số nguyên N (0 <= N <= 20).', N'In ra kết quả N!.', N'5', N'120', N'5! = 1 * 2 * 3 * 4 * 5 = 120.', N'0 <= N <= 20', N'Dễ', N'Vòng lặp', N'#include <iostream>
using namespace std;
int main() {
    int n;
    if (cin >> n) {
        long long ans = 1;
        for (int i = 1; i <= n; i++) ans *= i;
        cout << ans << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (7, 2, 6, N'Tính tổng các phần tử trong mảng', N'Cho một mảng gồm n số nguyên. Hãy tính và in ra tổng của tất cả các phần tử trong mảng.', N'Dòng 1 chứa số nguyên n (1 <= n <= 10^5).
Dòng 2 chứa n số nguyên cách nhau bởi dấu cách.', N'In ra tổng các phần tử.', N'4
1 3 5 7', N'16', N'1 + 3 + 5 + 7 = 16.', N'1 <= n <= 10^5, -10^9 <= a[i] <= 10^9', N'Dễ', N'Mảng', N'#include <iostream>
using namespace std;
int main() {
    int n;
    if (cin >> n) {
        long long sum = 0;
        for (int i = 0; i < n; i++) {
            long long x;
            cin >> x;
            sum += x;
        }
        cout << sum << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]'),
  (8, 2, 7, N'Đảo ngược chuỗi ký tự', N'Cho một chuỗi s chỉ gồm các ký tự chữ cái và số không chứa dấu cách. Hãy in ra chuỗi đảo ngược của s.', N'Một chuỗi s có độ dài không quá 1000 ký tự.', N'In ra chuỗi đảo ngược.', N'hello', N'olleh', N'Chuỗi đảo ngược của hello là olleh.', N'1 <= length(s) <= 1000', N'Dễ', N'Chuỗi', N'#include <iostream>
#include <string>
#include <algorithm>
using namespace std;
int main() {
    string s;
    if (cin >> s) {
        reverse(s.begin(), s.end());
        cout << s << endl;
    }
    return 0;
}', 10, 2.0, 128, N'approved', 2, N'2026-10-15 06:38:05', 0, N'', N'C++', N'[]');
GO
SET IDENTITY_INSERT [dbo].[exercises] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [test_cases]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[test_cases]', N'U') IS NOT NULL DROP TABLE [dbo].[test_cases];
GO
CREATE TABLE [dbo].[test_cases] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [exercise_id] INT NOT NULL,
    [input_data] NVARCHAR(MAX) NOT NULL,
    [expected_output] NVARCHAR(MAX) NOT NULL,
    [points] INT NOT NULL DEFAULT 2,
    [is_hidden] TINYINT NOT NULL DEFAULT 0,
    [order_index] INT NOT NULL DEFAULT 1,
    CONSTRAINT [fk_testcases_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [test_cases] (33 records)
SET IDENTITY_INSERT [dbo].[test_cases] ON;
GO
INSERT INTO [dbo].[test_cases] ([id], [exercise_id], [input_data], [expected_output], [points], [is_hidden], [order_index]) VALUES
  (1, 1, N'5 7', N'12', 2, 0, 1),
  (2, 1, N'-10 25', N'15', 3, 0, 2),
  (3, 1, N'1000000000 2000000000', N'3000000000', 3, 1, 3),
  (4, 1, N'-500 -700', N'-1200', 2, 1, 4),
  (5, 2, N'8', N'CHAN', 2, 0, 1),
  (6, 2, N'13', N'LE', 3, 0, 2),
  (7, 2, N'0', N'CHAN', 3, 1, 3),
  (8, 2, N'-7', N'LE', 2, 1, 4),
  (9, 3, N'4 9 2', N'9', 2, 0, 1),
  (10, 3, N'15 15 10', N'15', 3, 0, 2),
  (11, 3, N'-5 -2 -8', N'-2', 3, 1, 3),
  (12, 3, N'100 200 500', N'500', 2, 1, 4),
  (13, 4, N'5', N'15', 2, 0, 1),
  (14, 4, N'1', N'1', 3, 0, 2),
  (15, 4, N'100', N'5050', 3, 1, 3),
  (16, 4, N'1000000', N'500000500000', 2, 1, 4),
  (17, 5, N'7', N'YES', 2, 0, 1),
  (18, 5, N'1', N'NO', 2, 0, 2),
  (19, 5, N'4', N'NO', 2, 0, 3),
  (20, 5, N'999999937', N'YES', 2, 1, 4),
  (21, 5, N'-17', N'NO', 2, 1, 5),
  (22, 6, N'5', N'120', 2, 0, 1),
  (23, 6, N'0', N'1', 3, 0, 2),
  (24, 6, N'10', N'3628800', 3, 1, 3),
  (25, 6, N'20', N'2432902008176640000', 2, 1, 4),
  (26, 7, N'4
1 3 5 7', N'16', 2, 0, 1),
  (27, 7, N'3
-5 10 -2', N'3', 3, 0, 2),
  (28, 7, N'5
0 0 0 0 0', N'0', 3, 1, 3),
  (29, 7, N'6
100 200 300 400 500 600', N'2100', 2, 1, 4),
  (30, 8, N'hello', N'olleh', 2, 0, 1),
  (31, 8, N'CodeBeginner', N'rennigebedoC', 3, 0, 2),
  (32, 8, N'a', N'a', 3, 1, 3),
  (33, 8, N'123456789', N'987654321', 2, 1, 4);
GO
SET IDENTITY_INSERT [dbo].[test_cases] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [submissions]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[submissions]', N'U') IS NOT NULL DROP TABLE [dbo].[submissions];
GO
CREATE TABLE [dbo].[submissions] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [exercise_id] INT NOT NULL,
    [source_code] NVARCHAR(MAX) NOT NULL,
    [language] NVARCHAR(50) NOT NULL DEFAULT 'C++',
    [status] NVARCHAR(50) NOT NULL,
    [score] FLOAT NOT NULL DEFAULT 0,
    [passed_tests] INT NOT NULL DEFAULT 0,
    [total_tests] INT NOT NULL DEFAULT 0,
    [execution_time] FLOAT DEFAULT 0,
    [compile_error] NVARCHAR(MAX) NULL,
    [test_details] NVARCHAR(MAX) NULL,
    [submitted_at] DATETIME2 DEFAULT GETDATE(),
    [typing_data_json] NVARCHAR(MAX) NULL,
    [anomaly_flag] TINYINT DEFAULT 0,
    [anomaly_score] FLOAT DEFAULT 0.0,
    [anomaly_status] NVARCHAR(30) DEFAULT 'normal',
    [anomaly_review_notes] NVARCHAR(MAX) NULL,
    [anomaly_reviewer_id] INT NULL,
    [rubric_scores_json] NVARCHAR(MAX) NULL,
    CONSTRAINT [fk_submissions_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_submissions_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_submissions_reviewer] FOREIGN KEY ([anomaly_reviewer_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [submissions] (39 records)
SET IDENTITY_INSERT [dbo].[submissions] ON;
GO
INSERT INTO [dbo].[submissions] ([id], [student_id], [exercise_id], [source_code], [language], [status], [score], [passed_tests], [total_tests], [execution_time], [compile_error], [test_details], [submitted_at], [typing_data_json], [anomaly_flag], [anomaly_score], [anomaly_status], [anomaly_review_notes], [anomaly_reviewer_id], [rubric_scores_json]) VALUES
  (1, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            int a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.559, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.559, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.004, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 06:56:06', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (2, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.576, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.576, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 06:57:36', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (3, 4, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a, b;
    cin>>a>>b;
    cout<<a+b;
    
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.566, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.566, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.015, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:17:58', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (4, 1, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a, b;
    cin>>a>>b;
    cout<<a+b;
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.603, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.603, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.017, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:20:09', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (5, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.493, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.493, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.005, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.005, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:33:26', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (6, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.538, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.538, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:34:04', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (7, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.547, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.547, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:34:39', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (8, 5, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a,b;
    cin >>a>>b;
    cout<<a+b;
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.562, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.562, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:36:29', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (9, 5, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a,b;
    cin >>a>>b;
    cout<<a-b;
    return 0;
}
', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.519, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.519, "input": "5 7", "expected": "12", "actual": "-2", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.006, "input": "-10 25", "expected": "15", "actual": "-35", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.006, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.006, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 07:37:18', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (10, 5, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    long a,b;
    cin >>a>>b;
    cout<<a+b;
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.651, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.651, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:37:29', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (11, 5, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    long long a,b;
    cin >>a>>b;
    cout<<a+b;
    return 0;
}
', N'C++', N'Accepted', 10.0, 4, 4, 0.537, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.537, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:38:19', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (12, 4, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a, b;
    cin>>a>>b;
    cout<<a+b;
    
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.494, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.494, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 07:53:04', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (13, 4, 1, N'#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    int a, b;
    cin>>a>>b;
    cout<<a+b;
    
    return 0;
}
', N'C++', N'Wrong Answer', 7.0, 3, 4, 0.564, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.564, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:04:07', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (14, 3, 2, N'#include <iostream>
using namespace std;

int main() {
    int n;
    if (n % 2 ==0){
        cout << "CHAN";
    }
    else cout << "LE";
    
    return 0;
}
', N'C++', N'Wrong Answer', 5.0, 2, 4, 0.522, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.522, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.01, "input": "13", "expected": "LE", "actual": "CHAN", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:15:33', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (15, 3, 2, N'#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    if (n % 2 ==0){
        cout << "CHAN";
    }
    else cout << "LE";
}
', N'C++', N'Accepted', 10.0, 4, 4, 0.543, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.543, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "13", "expected": "LE", "actual": "LE", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:18:11', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (16, 3, 2, N'#include <iostream>
using namespace std;

int main() {
    int n;
    if (n % 2 ==0){
        cout << "CHAN";
    }
    else cout << "LE";
}
', N'C++', N'Wrong Answer', 5.0, 2, 4, 0.495, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.495, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.012, "input": "13", "expected": "LE", "actual": "CHAN", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.017, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:18:40', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (17, 3, 2, N'#include <iostream>
using namespace std;

int main() {
    int n;
    cin >>n;
    if (n % 2 ==0){
        cout << "CHAN";
    }
    else cout << "LE";
}
', N'C++', N'Accepted', 10.0, 4, 4, 0.507, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.507, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "13", "expected": "LE", "actual": "LE", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:19:22', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (18, 3, 3, N'#include <iostream>
#include <algorithm>
using namespace std;

int main() {
	int a,b,c;
    cin >>a >>b>>c;
    cout << max(a,b,c);
    return 0;
}
', N'C++', N'Compile Error', 0.0, 0, 4, 0.0, N'In file included from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/char_traits.h:39,
                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/ios:40,
                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/ostream:38,
                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/iostream:39,
                 from C:\Users\LENOVO\AppData\Local\Temp\tmpy05leh6m\submission.cpp:1:
C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/stl_algobase.h: In instantiation of ''constexpr const _Tp& std::max(const _Tp&, const _Tp&, _Compare) [with _Tp = int; _Compare = int]'':
C:\Users\LENOVO\AppData\Local\Temp\tmpy05leh6m\submission.cpp:8:22:   required from here
C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/stl_algobase.h:303:17: error: ''__comp'' cannot be used as a function
  303 |       if (__comp(__a, __b))
      |           ~~~~~~^~~~~~~~~~
', N'[]', N'2026-10-15 08:20:51', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (19, 3, 3, N'#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    int max_num = max({a, b, c});

    cout<< max_num << endl;

    return 0;
}', N'C++', N'Accepted', 10.0, 4, 4, 0.738, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.738, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:25:48', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (20, 3, 3, N'#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int a, b, c;
    int max_num = max({a, b, c});

    cout<< max_num << endl;

    return 0;
}', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.575, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.575, "input": "4 9 2", "expected": "9", "actual": "62", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.009, "input": "15 15 10", "expected": "15", "actual": "62", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:26:05', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (21, 3, 3, N'#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    int max_num = max({a, b, c});

    cout<< max_num << endl;

    return 0;
}', N'C++', N'Accepted', 10.0, 4, 4, 0.679, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.679, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:26:11', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (22, 3, 3, N'#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int a, b, c;
    cin >> a >> b >> c;
    int max_num = max({a, b, c});

    cout<< max_num << endl;

    return 0;
}', N'C++', N'Accepted', 10.0, 4, 4, 0.62, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.62, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:28:40', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (23, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    int n;
    cin >> n;
    sum=0;
    for (int i=1 ; i<= n; i++){
        sum+=i;
    }
    cout << sum;
    return 0;
}
', N'C++', N'Compile Error', 0.0, 0, 4, 0.0, N'C:\Users\LENOVO\AppData\Local\Temp\tmpcq_ofvx4\submission.cpp: In function ''int main()'':
C:\Users\LENOVO\AppData\Local\Temp\tmpcq_ofvx4\submission.cpp:7:5: error: ''sum'' was not declared in this scope
    7 |     sum=0;
      |     ^~~
', N'[]', N'2026-10-15 08:31:27', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (24, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    int n,sum;
    cin >> n;
    sum=0;
    for (int i=1 ; i<= n; i++){
        sum+=i;
    }
    cout << sum;
    return 0;
}
', N'C++', N'Wrong Answer', 8.0, 3, 4, 0.682, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.682, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.016, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:31:39', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (25, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    int n,sum;
    cin >> n;
    sum=0;
    for (int i=1 ; i<= n; i++){
        sum+=i;
    }
    cout << sum;
    return 0;
}
', N'C++', N'Wrong Answer', 8.0, 3, 4, 0.596, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.596, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:32:10', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (26, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    int n,sum;
    cin >> n;
    sum=0;
    for (int i=1 ; i<= n; i++){
        sum+=i;
    }
    cout << sum;
}
', N'C++', N'Wrong Answer', 8.0, 3, 4, 0.609, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.609, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:32:42', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (27, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    long n,sum;
    cin >> n;
    sum=0;
    for (int i=1 ; i<= n; i++){
        sum+=i;
    }
    cout << sum;
}
', N'C++', N'Wrong Answer', 8.0, 3, 4, 0.519, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.519, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.015, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', N'2026-10-15 08:33:02', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (28, 3, 4, N'#include <iostream>
using namespace std;

int main() {
    long long n;
    cin >> n;
    long long sum = n * (n + 1) / 2;
    
    cout << sum;
    return 0;
}
', N'C++', N'Accepted', 10.0, 4, 4, 0.511, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.511, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', N'2026-10-15 08:34:11', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (29, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.586, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.586, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-10-22 15:26:38', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (30, 3, 2, N'
        #include <iostream>
        using namespace std;
        int main() {
            int n;
            if (n % 2 == 0) cout << "CHAN";
            else cout << "LE";
            return 0;
        }
        ', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.0, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', N'2026-10-22 15:26:38', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (31, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.521, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.521, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.009, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.008, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-10-22 15:26:40', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (32, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.561, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.561, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.005, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-10-22 15:28:13', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (33, 3, 2, N'
        #include <iostream>
        using namespace std;
        int main() {
            int n;
            if (n % 2 == 0) cout << "CHAN";
            else cout << "LE";
            return 0;
        }
        ', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.0, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', N'2026-10-22 15:28:14', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (34, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.547, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.547, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.006, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-10-22 15:28:15', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (35, 3, 2, N'
        #include <iostream>
        using namespace std;
        int main() {
            int n;
            if (n % 2 == 0) cout << "CHAN";
            else cout << "LE";
            return 0;
        }
        ', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.0, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', N'2026-11-06 04:06:31', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (36, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.612, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.612, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.012, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-11-06 04:06:39', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (37, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.414, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.414, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-11-06 04:07:40', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (38, 3, 2, N'
        #include <iostream>
        using namespace std;
        int main() {
            int n;
            if (n % 2 == 0) cout << "CHAN";
            else cout << "LE";
            return 0;
        }
        ', N'C++', N'Wrong Answer', 0.0, 0, 4, 0.0, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu ''cin >>'' hoặc ''scanf''). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', N'2026-11-06 04:07:41', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]'),
  (39, 3, 1, N'
        #include <iostream>
        using namespace std;
        int main() {
            long long a, b;
            if (cin >> a >> b) {
                cout << (a + b) << endl;
            }
            return 0;
        }
        ', N'C++', N'Accepted', 10.0, 4, 4, 0.467, N'', N'[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.467, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.009, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.062, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', N'2026-11-06 04:07:43', N'{}', 0, 0.0, N'normal', N'', NULL, N'[]');
GO
SET IDENTITY_INSERT [dbo].[submissions] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [entrance_questions]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[entrance_questions]', N'U') IS NOT NULL DROP TABLE [dbo].[entrance_questions];
GO
CREATE TABLE [dbo].[entrance_questions] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [topic] NVARCHAR(100) NOT NULL,
    [question_text] NVARCHAR(MAX) NOT NULL,
    [code_snippet] NVARCHAR(MAX) NULL,
    [options_json] NVARCHAR(MAX) NOT NULL,
    [correct_answer] INT NOT NULL,
    [explanation] NVARCHAR(MAX) NULL
);
GO

-- Dumping data for table [entrance_questions] (15 records)
SET IDENTITY_INSERT [dbo].[entrance_questions] ON;
GO
INSERT INTO [dbo].[entrance_questions] ([id], [topic], [question_text], [code_snippet], [options_json], [correct_answer], [explanation]) VALUES
  (1, N'Biến và kiểu dữ liệu', N'Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?', N'/* Khai bao bien x */ x = 3.1415926535;', N'["int", "double", "char", "bool"]', 1, N'Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa).'),
  (2, N'Biến và kiểu dữ liệu', N'Đoạn mã sau in ra giá trị gì trên màn hình?', N'int a = 7;
int b = 2;
cout << a / b;', N'["3.5", "3", "4", "Báo lỗi biên dịch"]', 1, N'Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3).'),
  (3, N'Nhập/xuất', N'Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?', N'int x;
cin ?? x;', N'["<<", ">>", "<=", ">="]', 1, N'Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin.'),
  (4, N'Nhập/xuất', N'Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?', N'cout << "Hello" ??', N'[">> endl;", "<< endl;", "<< newline;", ">> return;"]', 1, N'endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<.'),
  (5, N'Toán tử', N'Toán tử ''%'' trong C++ thực hiện phép toán nào?', N'int r = 17 % 5;', N'["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"]', 2, N'17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2.'),
  (6, N'Toán tử', N'Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?', N'bool res = (5 > 3) && (2 >= 4);', N'["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"]', 1, N'(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false.'),
  (7, N'If/Else', N'Đoạn mã sau in ra kết quả gì?', N'int x = 10;
if (x < 5) {
    cout << "A";
} else if (x < 15) {
    cout << "B";
} else {
    cout << "C";
}', N'["A", "B", "C", "B C"]', 1, N'x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc.'),
  (8, N'If/Else', N'Câu lệnh điều kiện if sau đây sẽ in ra gì?', N'int a = 0;
if (a == 5) {
    cout << "Dung";
} else {
    cout << "Sai";
}', N'["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"]', 0, N'Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''.'),
  (9, N'Vòng lặp', N'Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?', N'for (int i = 0; i < 5; i++) {
    cout << i << " ";
}', N'["4 lần", "5 lần", "6 lần", "Vô hạn lần"]', 1, N'Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần).'),
  (10, N'Vòng lặp', N'Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?', N'while (true) {
    if (dieu_kien) break;
}', N'["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"]', 1, N'''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất.'),
  (11, N'Mảng', N'Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:', N'int arr[10];', N'["1 và 10", "0 và 9", "0 và 10", "1 và 9"]', 1, N'Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9].'),
  (12, N'Mảng', N'Giá trị của arr[2] sau đoạn code sau là bao nhiêu?', N'int arr[4] = {10, 20, 30, 40};
arr[2] += 5;', N'["25", "35", "30", "45"]', 1, N'arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35.'),
  (13, N'Chuỗi', N'Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?', N'string s = "LapTrinh";', N'["s.count()", "s.length()", "sizeof(s)", "s.elements()"]', 1, N'Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi.'),
  (14, N'Hàm', N'Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?', N'?? inLoiChao() {
    cout << "Xin chao!";
}', N'["null", "empty", "void", "none"]', 2, N'Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục).'),
  (15, N'Hàm', N'Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:', N'void hoanVi(int ??a, int ??b) { ... }', N'["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"]', 0, N'Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc.');
GO
SET IDENTITY_INSERT [dbo].[entrance_questions] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [entrance_test_results]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[entrance_test_results]', N'U') IS NOT NULL DROP TABLE [dbo].[entrance_test_results];
GO
CREATE TABLE [dbo].[entrance_test_results] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [total_score] FLOAT NOT NULL,
    [max_score] FLOAT NOT NULL,
    [percentage] FLOAT NOT NULL,
    [topic_breakdown_json] NVARCHAR(MAX) NOT NULL,
    [weak_topics_json] NVARCHAR(MAX) NOT NULL,
    [summary] NVARCHAR(MAX) NOT NULL,
    [details_json] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_entranceresults_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [entrance_test_results] (17 records)
SET IDENTITY_INSERT [dbo].[entrance_test_results] ON;
GO
INSERT INTO [dbo].[entrance_test_results] ([id], [student_id], [total_score], [max_score], [percentage], [topic_breakdown_json], [weak_topics_json], [summary], [created_at], [details_json]) VALUES
  (1, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-15 06:56:06', N'[]'),
  (2, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-15 06:57:36', N'[]'),
  (3, 5, 4.0, 15.0, 26.7, N'{"Biến và kiểu dữ liệu": 50.0, "Nhập/xuất": 100.0, "Toán tử": 50.0, "If/Else": 0.0, "Vòng lặp": 0.0, "Mảng": 0.0, "Chuỗi": 0.0, "Hàm": 0.0}', N'["Biến và kiểu dữ liệu", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Chuỗi", "Hàm"]', N'Bạn đã nắm vững các chủ đề: Nhập/xuất. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm.', N'2026-10-15 07:31:34', N'[]'),
  (4, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-15 07:33:26', N'[]'),
  (5, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-15 07:34:04', N'[]'),
  (6, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-15 07:34:39', N'[]'),
  (7, 4, 11.0, 15.0, 73.3, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 100.0, "Mảng": 50.0, "Chuỗi": 0.0, "Hàm": 50.0}', N'["If/Else", "Mảng", "Chuỗi", "Hàm"]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Vòng lặp. Các kiến thức còn yếu cần củng cố gồm: If/Else, Mảng, Chuỗi, Hàm.', N'2026-10-15 07:44:32', N'[]'),
  (8, 3, 4.0, 15.0, 26.7, N'{"Biến và kiểu dữ liệu": 0.0, "Nhập/xuất": 0.0, "Toán tử": 0.0, "If/Else": 50.0, "Vòng lặp": 0.0, "Mảng": 50.0, "Chuỗi": 100.0, "Hàm": 50.0}', N'["Biến và kiểu dữ liệu", "Nhập/xuất", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Hàm"]', N'Bạn đã nắm vững các chủ đề: Chuỗi. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Hàm.', N'2026-10-15 07:48:04', N'[]'),
  (9, 3, 4.0, 15.0, 26.7, N'{"Biến và kiểu dữ liệu": 0.0, "Nhập/xuất": 0.0, "Toán tử": 50.0, "If/Else": 0.0, "Vòng lặp": 0.0, "Mảng": 50.0, "Chuỗi": 100.0, "Hàm": 50.0}', N'["Biến và kiểu dữ liệu", "Nhập/xuất", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Hàm"]', N'Bạn đã nắm vững các chủ đề: Chuỗi. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Hàm.', N'2026-10-15 07:51:45', N'[]'),
  (10, 4, 13.0, 15.0, 86.7, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 50.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'["If/Else", "Vòng lặp"]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Mảng, Chuỗi, Hàm. Các kiến thức còn yếu cần củng cố gồm: If/Else, Vòng lặp.', N'2026-10-15 07:59:04', N'[]'),
  (11, 4, 14.0, 15.0, 93.3, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'["If/Else"]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Vòng lặp, Mảng, Chuỗi, Hàm. Các kiến thức còn yếu cần củng cố gồm: If/Else.', N'2026-10-15 08:03:10', N'[]'),
  (12, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-22 14:59:03', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (13, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-22 15:26:38', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (14, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-10-22 15:28:13', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (15, 7, 8.0, 15.0, 53.3, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 0.0, "Mảng": 0.0, "Chuỗi": 0.0, "Hàm": 50.0}', N'["If/Else", "Vòng lặp", "Mảng", "Chuỗi", "Hàm"]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử. Các kiến thức còn yếu cần củng cố gồm: If/Else, Vòng lặp, Mảng, Chuỗi, Hàm.', N'2026-10-23 04:54:52', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 2, "user_answer_text": "C", "correct_answer": 1, "correct_answer_text": "B", "is_correct": false, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 0, "user_answer_text": "4 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": false, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 0, "user_answer_text": "Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": false, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 0, "user_answer_text": "1 và 10", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": false, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 0, "user_answer_text": "25", "correct_answer": 1, "correct_answer_text": "35", "is_correct": false, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 3, "user_answer_text": "s.elements()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": false, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 1, "user_answer_text": "empty", "correct_answer": 2, "correct_answer_text": "void", "is_correct": false, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (16, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-11-06 04:06:29', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (17, 3, 15.0, 15.0, 100.0, N'{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', N'[]', N'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', N'2026-11-06 04:07:40', N'[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\nint b = 2;\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \"Hello\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử ''%'' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\nif (x < 5) {\n    cout << \"A\";\n} else if (x < 15) {\n    cout << \"B\";\n} else {\n    cout << \"C\";\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\nif (a == 5) {\n    cout << \"Dung\";\n} else {\n    cout << \"Sai\";\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\n    cout << i << \" \";\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\n    if (dieu_kien) break;\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?", "code_snippet": "string s = \"LapTrinh\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\n    cout << \"Xin chao!\";\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]');
GO
SET IDENTITY_INSERT [dbo].[entrance_test_results] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [topic_weaknesses]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[topic_weaknesses]', N'U') IS NOT NULL DROP TABLE [dbo].[topic_weaknesses];
GO
CREATE TABLE [dbo].[topic_weaknesses] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [topic] NVARCHAR(100) NOT NULL,
    [mastery_percentage] FLOAT NOT NULL DEFAULT 0,
    [total_attempts] INT NOT NULL DEFAULT 0,
    [correct_attempts] INT NOT NULL DEFAULT 0,
    [updated_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_topic_weaknesses] UNIQUE ([student_id], [topic]),
    CONSTRAINT [fk_topicweaknesses_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [topic_weaknesses] (33 records)
SET IDENTITY_INSERT [dbo].[topic_weaknesses] ON;
GO
INSERT INTO [dbo].[topic_weaknesses] ([id], [student_id], [topic], [mastery_percentage], [total_attempts], [correct_attempts], [updated_at]) VALUES
  (1, 3, N'Nhập/xuất', 86.1, 36, 31, N'2026-11-06 04:07:43'),
  (2, 3, N'Biến và kiểu dữ liệu', 100.0, 24, 20, N'2026-11-06 04:07:40'),
  (4, 3, N'Toán tử', 100.0, 24, 21, N'2026-11-06 04:07:40'),
  (5, 3, N'If/Else', 70.3, 37, 26, N'2026-11-06 04:07:41'),
  (6, 3, N'Vòng lặp', 100.0, 30, 21, N'2026-11-06 04:07:40'),
  (7, 3, N'Mảng', 100.0, 24, 22, N'2026-11-06 04:07:40'),
  (8, 3, N'Chuỗi', 100.0, 12, 12, N'2026-11-06 04:07:40'),
  (9, 3, N'Hàm', 100.0, 24, 22, N'2026-11-06 04:07:40'),
  (19, 4, N'Nhập/xuất', 66.7, 9, 6, N'2026-10-15 08:04:07'),
  (20, 1, N'Nhập/xuất', 0.0, 1, 0, N'2026-10-15 07:20:09'),
  (21, 5, N'Biến và kiểu dữ liệu', 50.0, 2, 1, N'2026-10-15 07:31:34'),
  (22, 5, N'Nhập/xuất', 50.0, 6, 3, N'2026-10-15 07:38:19'),
  (23, 5, N'Toán tử', 50.0, 2, 1, N'2026-10-15 07:31:34'),
  (24, 5, N'If/Else', 0.0, 2, 0, N'2026-10-15 07:31:34'),
  (25, 5, N'Vòng lặp', 0.0, 2, 0, N'2026-10-15 07:31:34'),
  (26, 5, N'Mảng', 0.0, 2, 0, N'2026-10-15 07:31:34'),
  (27, 5, N'Chuỗi', 0.0, 1, 0, N'2026-10-15 07:31:34'),
  (28, 5, N'Hàm', 0.0, 2, 0, N'2026-10-15 07:31:34'),
  (60, 4, N'Biến và kiểu dữ liệu', 100.0, 6, 6, N'2026-10-15 08:03:10'),
  (62, 4, N'Toán tử', 100.0, 6, 6, N'2026-10-15 08:03:10'),
  (63, 4, N'If/Else', 50.0, 6, 3, N'2026-10-15 08:03:10'),
  (64, 4, N'Vòng lặp', 100.0, 6, 5, N'2026-10-15 08:03:10'),
  (65, 4, N'Mảng', 100.0, 6, 5, N'2026-10-15 08:03:10'),
  (66, 4, N'Chuỗi', 100.0, 3, 2, N'2026-10-15 08:03:10'),
  (67, 4, N'Hàm', 100.0, 6, 5, N'2026-10-15 08:03:10'),
  (147, 7, N'Biến và kiểu dữ liệu', 100.0, 2, 2, N'2026-10-23 04:54:52'),
  (148, 7, N'Nhập/xuất', 100.0, 2, 2, N'2026-10-23 04:54:52'),
  (149, 7, N'Toán tử', 100.0, 2, 2, N'2026-10-23 04:54:52'),
  (150, 7, N'If/Else', 50.0, 2, 1, N'2026-10-23 04:54:52'),
  (151, 7, N'Vòng lặp', 0.0, 2, 0, N'2026-10-23 04:54:52'),
  (152, 7, N'Mảng', 0.0, 2, 0, N'2026-10-23 04:54:52'),
  (153, 7, N'Chuỗi', 0.0, 1, 0, N'2026-10-23 04:54:52'),
  (154, 7, N'Hàm', 50.0, 2, 1, N'2026-10-23 04:54:52');
GO
SET IDENTITY_INSERT [dbo].[topic_weaknesses] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [lesson_progress]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[lesson_progress]', N'U') IS NOT NULL DROP TABLE [dbo].[lesson_progress];
GO
CREATE TABLE [dbo].[lesson_progress] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [lesson_id] INT NOT NULL,
    [completed] TINYINT NOT NULL DEFAULT 1,
    [completed_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_lesson_progress] UNIQUE ([student_id], [lesson_id]),
    CONSTRAINT [fk_lessonprogress_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_lessonprogress_lesson] FOREIGN KEY ([lesson_id]) REFERENCES [dbo].[lessons] ([id]) ON DELETE NO ACTION
);
GO

-- No records for table [lesson_progress]

-- --------------------------------------------------------
-- Table structure for [course_enrollments]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[course_enrollments]', N'U') IS NOT NULL DROP TABLE [dbo].[course_enrollments];
GO
CREATE TABLE [dbo].[course_enrollments] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [progress_percentage] FLOAT NOT NULL DEFAULT 0,
    [enrolled_at] DATETIME2 DEFAULT GETDATE(),
    [last_accessed_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_course_enrollments] UNIQUE ([student_id], [course_id]),
    CONSTRAINT [fk_courseenrollments_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_courseenrollments_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [course_enrollments] (5 records)
SET IDENTITY_INSERT [dbo].[course_enrollments] ON;
GO
INSERT INTO [dbo].[course_enrollments] ([id], [student_id], [course_id], [progress_percentage], [enrolled_at], [last_accessed_at]) VALUES
  (1, 3, 1, 0.0, N'2026-10-15 07:24:03', N'2026-10-15 08:42:45'),
  (2, 4, 1, 0.0, N'2026-10-15 07:24:03', N'2026-10-15 07:24:03'),
  (3, 5, 1, 0.0, N'2026-10-15 07:32:42', N'2026-10-15 07:32:42'),
  (4, 6, 1, 0.0, N'2026-10-15 07:41:08', N'2026-10-15 07:41:08'),
  (7, 7, 1, 0.0, N'2026-10-23 04:51:27', N'2026-10-23 04:51:27');
GO
SET IDENTITY_INSERT [dbo].[course_enrollments] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [forum_categories]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[forum_categories]', N'U') IS NOT NULL DROP TABLE [dbo].[forum_categories];
GO
CREATE TABLE [dbo].[forum_categories] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [slug] NVARCHAR(100) NOT NULL UNIQUE,
    [description] NVARCHAR(MAX) NOT NULL,
    [icon] NVARCHAR(50) DEFAULT 'message-square',
    [order_index] INT DEFAULT 1
);
GO

-- Dumping data for table [forum_categories] (6 records)
SET IDENTITY_INSERT [dbo].[forum_categories] ON;
GO
INSERT INTO [dbo].[forum_categories] ([id], [name], [slug], [description], [icon], [order_index]) VALUES
  (1, N'C++', N'cpp', N'Thảo luận về cú pháp C++, con trỏ, STL, hướng đối tượng và tối ưu hóa mã nguồn', N'code', 1),
  (2, N'Thuật toán & Cấu trúc dữ liệu', N'algorithms', N'Trao đổi về giải thuật tìm kiếm, sắp xếp, quy hoạch động, cây và đồ thị', N'cpu', 2),
  (3, N'JavaScript & Web', N'javascript', N'Thảo luận phát triển giao diện web, tương tác DOM và lập trình JavaScript', N'globe', 3),
  (4, N'Python', N'python', N'Học tập Python cơ bản, xử lý dữ liệu và tự động hóa', N'terminal', 4),
  (5, N'Cơ sở dữ liệu', N'database', N'Truy vấn SQL, thiết kế cơ sở dữ liệu quan hệ và tối ưu bảng', N'database', 5),
  (6, N'Hỏi đáp chung & Thảo luận', N'general', N'Giao lưu học tập, kinh nghiệm rèn luyện kỹ năng code và giải đáp thắc mắc', N'message-circle', 6);
GO
SET IDENTITY_INSERT [dbo].[forum_categories] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [forum_threads]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[forum_threads]', N'U') IS NOT NULL DROP TABLE [dbo].[forum_threads];
GO
CREATE TABLE [dbo].[forum_threads] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [category_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [tags] NVARCHAR(255) DEFAULT '',
    [status] NVARCHAR(30) NOT NULL DEFAULT 'active',
    [views_count] INT DEFAULT 0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [moderation_status] NVARCHAR(30) DEFAULT 'approved',
    [moderated_by] INT NULL,
    [reject_reason] NVARCHAR(MAX) NULL,
    [is_expert_answer] TINYINT DEFAULT 0,
    [course_id] INT NULL,
    [exercise_id] INT NULL,
    [lesson_id] INT NULL,
    CONSTRAINT [fk_threads_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_threads_category] FOREIGN KEY ([category_id]) REFERENCES [dbo].[forum_categories] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_threads_mod] FOREIGN KEY ([moderated_by]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_threads_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_threads_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_threads_lesson] FOREIGN KEY ([lesson_id]) REFERENCES [dbo].[lessons] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [forum_threads] (2 records)
SET IDENTITY_INSERT [dbo].[forum_threads] ON;
GO
INSERT INTO [dbo].[forum_threads] ([id], [user_id], [category_id], [title], [content], [tags], [status], [views_count], [created_at], [moderation_status], [moderated_by], [reject_reason], [is_expert_answer], [course_id], [exercise_id], [lesson_id]) VALUES
  (1, 3, 1, N'Tại sao vòng lặp for của em bị chạy vô tận khi duyệt số nguyên?', N'Em viết đoạn mã kiểm tra chia hết từ n giảm về 0 nhưng chương trình cứ chạy mãi không dừng. Nhờ các anh chị chuyên gia xem giúp lỗi ở đâu ạ!

```cpp
for (unsigned int i = 10; i >= 0; i--) {
    cout << i << " ";
}
```', N'cpp,vòng-lặp,unsigned-int', N'active', 24, N'2026-10-15 06:38:05', N'approved', NULL, N'', 0, NULL, NULL, NULL),
  (2, 3, 2, N'Làm thế nào để phân biệt khi nào nên dùng DFS và khi nào nên dùng BFS?', N'Chào mọi người, em đang học đồ thị và phân vân bài toán tìm đường đi ngắn nhất không trọng số thì nên dùng BFS hay DFS và tại sao ạ?', N'thuật-toán,đồ-thị,bfs,dfs', N'active', 45, N'2026-10-15 06:38:05', N'approved', NULL, N'', 0, NULL, NULL, NULL);
GO
SET IDENTITY_INSERT [dbo].[forum_threads] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [forum_replies]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[forum_replies]', N'U') IS NOT NULL DROP TABLE [dbo].[forum_replies];
GO
CREATE TABLE [dbo].[forum_replies] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [thread_id] INT NOT NULL,
    [user_id] INT NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [is_accepted] TINYINT NOT NULL DEFAULT 0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [moderation_status] NVARCHAR(30) DEFAULT 'approved',
    [moderated_by] INT NULL,
    [reject_reason] NVARCHAR(MAX) NULL,
    [is_expert_answer] TINYINT DEFAULT 0,
    CONSTRAINT [fk_replies_thread] FOREIGN KEY ([thread_id]) REFERENCES [dbo].[forum_threads] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_replies_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_replies_mod] FOREIGN KEY ([moderated_by]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [forum_replies] (2 records)
SET IDENTITY_INSERT [dbo].[forum_replies] ON;
GO
INSERT INTO [dbo].[forum_replies] ([id], [thread_id], [user_id], [content], [is_accepted], [created_at], [moderation_status], [moderated_by], [reject_reason], [is_expert_answer]) VALUES
  (1, 1, 2, N'Chào bạn! Nguyên nhân là do bạn khai báo `unsigned int i`. Kiểu `unsigned int` là số nguyên không dấu nên giá trị nhỏ nhất của nó là 0. Khi i = 0 mà bị trừ đi 1 (i--), giá trị sẽ bị tràn số (underflow) nhảy lên giá trị cực đại 4294967295, do đó điều kiện `i >= 0` luôn luôn đúng! Để khắc phục, bạn chỉ cần đổi sang kiểu `int i` bình thường nhé.', 1, N'2026-10-15 06:38:05', N'approved', NULL, N'', 0),
  (2, 2, 2, N'Đối với bài toán tìm đường đi ngắn nhất trên đồ thị không trọng số (hoặc đồ thị mà tất cả các cạnh có trọng số bằng nhau là 1), bạn nên dùng **BFS (Tìm kiếm theo chiều rộng)**. Vì BFS duyệt theo từng mức (level), đỉnh nào được thăm trước chắc chắn sẽ có khoảng cách từ đỉnh xuất phát ngắn nhất.', 1, N'2026-10-15 06:38:05', N'approved', NULL, N'', 0);
GO
SET IDENTITY_INSERT [dbo].[forum_replies] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [forum_likes]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[forum_likes]', N'U') IS NOT NULL DROP TABLE [dbo].[forum_likes];
GO
CREATE TABLE [dbo].[forum_likes] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [thread_id] INT NOT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_forum_likes] UNIQUE ([user_id], [thread_id]),
    CONSTRAINT [fk_likes_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_likes_thread] FOREIGN KEY ([thread_id]) REFERENCES [dbo].[forum_threads] ([id]) ON DELETE NO ACTION
);
GO

-- No records for table [forum_likes]

-- --------------------------------------------------------
-- Table structure for [saved_posts]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[saved_posts]', N'U') IS NOT NULL DROP TABLE [dbo].[saved_posts];
GO
CREATE TABLE [dbo].[saved_posts] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [thread_id] INT NOT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_saved_posts] UNIQUE ([user_id], [thread_id]),
    CONSTRAINT [fk_savedposts_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_savedposts_thread] FOREIGN KEY ([thread_id]) REFERENCES [dbo].[forum_threads] ([id]) ON DELETE NO ACTION
);
GO

-- No records for table [saved_posts]

-- --------------------------------------------------------
-- Table structure for [forum_reports]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[forum_reports]', N'U') IS NOT NULL DROP TABLE [dbo].[forum_reports];
GO
CREATE TABLE [dbo].[forum_reports] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [target_type] NVARCHAR(30) NOT NULL,
    [target_id] INT NOT NULL,
    [reason] NVARCHAR(MAX) NOT NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'pending',
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_reports_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
GO

-- No records for table [forum_reports]

-- --------------------------------------------------------
-- Table structure for [notifications]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[notifications]', N'U') IS NOT NULL DROP TABLE [dbo].[notifications];
GO
CREATE TABLE [dbo].[notifications] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [link] NVARCHAR(255) DEFAULT '',
    [is_read] TINYINT NOT NULL DEFAULT 0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_notifications_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
GO

-- No records for table [notifications]

-- --------------------------------------------------------
-- Table structure for [moderator_assignments]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[moderator_assignments]', N'U') IS NOT NULL DROP TABLE [dbo].[moderator_assignments];
GO
CREATE TABLE [dbo].[moderator_assignments] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [moderator_id] INT NOT NULL,
    [target_type] NVARCHAR(50) NOT NULL,
    [target_id] INT NOT NULL,
    [assigned_by] INT NULL,
    [assigned_at] DATETIME2 DEFAULT GETDATE(),
    [deadline] DATETIME2 NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'assigned',
    [notes] NVARCHAR(MAX) NULL,
    [completed_at] DATETIME2 NULL,
    CONSTRAINT [fk_modassign_moderator] FOREIGN KEY ([moderator_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_modassign_assignedby] FOREIGN KEY ([assigned_by]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [moderator_assignments] (2 records)
SET IDENTITY_INSERT [dbo].[moderator_assignments] ON;
GO
INSERT INTO [dbo].[moderator_assignments] ([id], [moderator_id], [target_type], [target_id], [assigned_by], [assigned_at], [deadline], [status], [notes], [completed_at]) VALUES
  (1, 2, N'exercise', 1, 1, N'2026-11-10 15:05:21', NULL, N'completed', N'Kiểm tra lại bộ test cases và độ khó của bài toán Chẵn Lẻ', NULL),
  (2, 2, N'regrade_request', 1, 1, N'2026-11-10 15:05:21', NULL, N'in_progress', N'Xem xét đơn xin phúc khảo của học viên student1', NULL);
GO
SET IDENTITY_INSERT [dbo].[moderator_assignments] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [expert_reviews]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[expert_reviews]', N'U') IS NOT NULL DROP TABLE [dbo].[expert_reviews];
GO
CREATE TABLE [dbo].[expert_reviews] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [expert_id] INT NOT NULL,
    [assignment_id] INT NULL,
    [target_type] NVARCHAR(50) NOT NULL,
    [target_id] INT NOT NULL,
    [review_type] NVARCHAR(50) NOT NULL DEFAULT 'content_moderation',
    [review_status] NVARCHAR(30) NOT NULL,
    [comment] NVARCHAR(MAX) NOT NULL,
    [changes_requested] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_expertreviews_expert] FOREIGN KEY ([expert_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_expertreviews_assignment] FOREIGN KEY ([assignment_id]) REFERENCES [dbo].[moderator_assignments] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [expert_reviews] (1 records)
SET IDENTITY_INSERT [dbo].[expert_reviews] ON;
GO
INSERT INTO [dbo].[expert_reviews] ([id], [expert_id], [target_type], [target_id], [review_status], [comment], [created_at], [assignment_id], [review_type], [changes_requested]) VALUES
  (1, 2, N'exercise', 1, N'approved', N'Bài tập đạt chuẩn chất lượng, test cases đầy đủ các trường hợp biên.', N'2026-11-10 15:05:21', 1, N'content_moderation', N'');
GO
SET IDENTITY_INSERT [dbo].[expert_reviews] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [assessments]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[assessments]', N'U') IS NOT NULL DROP TABLE [dbo].[assessments];
GO
CREATE TABLE [dbo].[assessments] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [type] NVARCHAR(50) NOT NULL DEFAULT 'entrance',
    [course_id] INT NULL,
    [duration_minutes] INT NOT NULL DEFAULT 30,
    [passing_percentage] FLOAT NOT NULL DEFAULT 60.0,
    [total_questions] INT NOT NULL DEFAULT 10,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'published',
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_assessments_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [assessments] (2 records)
SET IDENTITY_INSERT [dbo].[assessments] ON;
GO
INSERT INTO [dbo].[assessments] ([id], [title], [description], [type], [course_id], [duration_minutes], [passing_percentage], [total_questions], [status], [created_at]) VALUES
  (1, N'Đánh giá Năng lực Lập trình Đầu vào (C++)', N'Bài kiểm tra 15 câu trắc nghiệm xác định năng lực và phân lớp học cho người mới bắt đầu.', N'entrance', NULL, 30, 60.0, 15, N'published', N'2026-11-10 15:05:21'),
  (2, N'Trắc nghiệm Kiến thức Cơ bản C++ (Chương 1)', N'Kiểm tra mức độ nắm vững biến, kiểu dữ liệu và cú pháp nhập xuất căn bản.', N'chapter_quiz', 1, 15, 70.0, 5, N'published', N'2026-11-10 15:05:21');
GO
SET IDENTITY_INSERT [dbo].[assessments] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [assessment_questions]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[assessment_questions]', N'U') IS NOT NULL DROP TABLE [dbo].[assessment_questions];
GO
CREATE TABLE [dbo].[assessment_questions] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [assessment_id] INT NULL,
    [topic] NVARCHAR(100) NOT NULL,
    [question_text] NVARCHAR(MAX) NOT NULL,
    [code_snippet] NVARCHAR(MAX) NULL,
    [options_json] NVARCHAR(MAX) NOT NULL,
    [correct_answer] INT NOT NULL,
    [explanation] NVARCHAR(MAX) NULL,
    [difficulty] NVARCHAR(50) NOT NULL DEFAULT N'Cơ bản',
    [points] FLOAT NOT NULL DEFAULT 1.0,
    [order_index] INT NOT NULL DEFAULT 1,
    CONSTRAINT [fk_assessmentquestions_assessment] FOREIGN KEY ([assessment_id]) REFERENCES [dbo].[assessments] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [assessment_questions] (15 records)
SET IDENTITY_INSERT [dbo].[assessment_questions] ON;
GO
INSERT INTO [dbo].[assessment_questions] ([id], [assessment_id], [topic], [question_text], [code_snippet], [options_json], [correct_answer], [explanation], [difficulty], [points], [order_index]) VALUES
  (1, 1, N'Biến và kiểu dữ liệu', N'Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?', N'/* Khai bao bien x */ x = 3.1415926535;', N'["int", "double", "char", "bool"]', 1, N'Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa).', N'Cơ bản', 1.0, 1),
  (2, 1, N'Biến và kiểu dữ liệu', N'Đoạn mã sau in ra giá trị gì trên màn hình?', N'int a = 7;
int b = 2;
cout << a / b;', N'["3.5", "3", "4", "Báo lỗi biên dịch"]', 1, N'Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3).', N'Cơ bản', 1.0, 2),
  (3, 1, N'Nhập/xuất', N'Toán tử nào được sử dụng cùng với đối tượng ''cin'' để đọc dữ liệu từ luồng đầu vào?', N'int x;
cin ?? x;', N'["<<", ">>", "<=", ">="]', 1, N'Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin.', N'Cơ bản', 1.0, 3),
  (4, 1, N'Nhập/xuất', N'Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?', N'cout << "Hello" ??', N'[">> endl;", "<< endl;", "<< newline;", ">> return;"]', 1, N'endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<.', N'Cơ bản', 1.0, 4),
  (5, 1, N'Toán tử', N'Toán tử ''%'' trong C++ thực hiện phép toán nào?', N'int r = 17 % 5;', N'["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"]', 2, N'17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2.', N'Cơ bản', 1.0, 5),
  (6, 1, N'Toán tử', N'Biểu thức logic ''(5 > 3) && (2 >= 4)'' trả về giá trị gì?', N'bool res = (5 > 3) && (2 >= 4);', N'["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"]', 1, N'(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false.', N'Cơ bản', 1.0, 6),
  (7, 1, N'If/Else', N'Đoạn mã sau in ra kết quả gì?', N'int x = 10;
if (x < 5) {
    cout << "A";
} else if (x < 15) {
    cout << "B";
} else {
    cout << "C";
}', N'["A", "B", "C", "B C"]', 1, N'x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra ''B'' và kết thúc.', N'Cơ bản', 1.0, 7),
  (8, 1, N'If/Else', N'Câu lệnh điều kiện if sau đây sẽ in ra gì?', N'int a = 0;
if (a == 5) {
    cout << "Dung";
} else {
    cout << "Sai";
}', N'["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"]', 0, N'Toán tử ''=='' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in ''Sai''.', N'Cơ bản', 1.0, 8),
  (9, 1, N'Vòng lặp', N'Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?', N'for (int i = 0; i < 5; i++) {
    cout << i << " ";
}', N'["4 lần", "5 lần", "6 lần", "Vô hạn lần"]', 1, N'Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần).', N'Cơ bản', 1.0, 9),
  (10, 1, N'Vòng lặp', N'Lệnh ''break'' đặt trong thân vòng lặp có tác dụng gì?', N'while (true) {
    if (dieu_kien) break;
}', N'["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"]', 1, N'''break'' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất.', N'Cơ bản', 1.0, 10),
  (11, 1, N'Mảng', N'Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng ''int arr[10];'' lần lượt là:', N'int arr[10];', N'["1 và 10", "0 và 9", "0 và 10", "1 và 9"]', 1, N'Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9].', N'Cơ bản', 1.0, 11),
  (12, 1, N'Mảng', N'Giá trị của arr[2] sau đoạn code sau là bao nhiêu?', N'int arr[4] = {10, 20, 30, 40};
arr[2] += 5;', N'["25", "35", "30", "45"]', 1, N'arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35.', N'Cơ bản', 1.0, 12),
  (13, 1, N'Chuỗi', N'Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng ''string s'' của thư viện chuẩn C++?', N'string s = "LapTrinh";', N'["s.count()", "s.length()", "sizeof(s)", "s.elements()"]', 1, N'Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi.', N'Cơ bản', 1.0, 13),
  (14, 1, N'Hàm', N'Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?', N'?? inLoiChao() {
    cout << "Xin chao!";
}', N'["null", "empty", "void", "none"]', 2, N'Từ khóa ''void'' chỉ ra rằng hàm không trả về giá trị (thủ tục).', N'Cơ bản', 1.0, 14),
  (15, 1, N'Hàm', N'Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:', N'void hoanVi(int ??a, int ??b) { ... }', N'["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"]', 0, N'Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc.', N'Cơ bản', 1.0, 15);
GO
SET IDENTITY_INSERT [dbo].[assessment_questions] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [assessment_attempts]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[assessment_attempts]', N'U') IS NOT NULL DROP TABLE [dbo].[assessment_attempts];
GO
CREATE TABLE [dbo].[assessment_attempts] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [assessment_id] INT NOT NULL,
    [student_id] INT NOT NULL,
    [attempt_number] INT NOT NULL DEFAULT 1,
    [start_time] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [end_time] DATETIME2 NULL,
    [duration_seconds] INT NULL,
    [total_score] FLOAT NOT NULL DEFAULT 0,
    [max_score] FLOAT NOT NULL DEFAULT 10,
    [percentage] FLOAT NOT NULL DEFAULT 0,
    [passed] TINYINT NOT NULL DEFAULT 0,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'in_progress',
    [answers_json] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_attempts_assessment] FOREIGN KEY ([assessment_id]) REFERENCES [dbo].[assessments] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_attempts_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [assessment_attempts] (1 records)
SET IDENTITY_INSERT [dbo].[assessment_attempts] ON;
GO
INSERT INTO [dbo].[assessment_attempts] ([id], [assessment_id], [student_id], [attempt_number], [start_time], [end_time], [duration_seconds], [total_score], [max_score], [percentage], [passed], [status], [answers_json], [created_at]) VALUES
  (1, 1, 3, 1, N'2026-11-10 15:05:21', NULL, NULL, 10.0, 15.0, 66.7, 1, N'completed', N'{"answers": [0, 1, 2, 0, 1, 3, 2, 1, 0, 2]}', N'2026-11-10 15:05:21');
GO
SET IDENTITY_INSERT [dbo].[assessment_attempts] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [certificates]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[certificates]', N'U') IS NOT NULL DROP TABLE [dbo].[certificates];
GO
CREATE TABLE [dbo].[certificates] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [certificate_code] NVARCHAR(50) NOT NULL UNIQUE,
    [student_id] INT NOT NULL,
    [course_id] INT NULL,
    [assessment_id] INT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [final_score] FLOAT NULL,
    [issue_date] DATETIME2 DEFAULT GETDATE(),
    [expiry_date] DATETIME2 NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'active',
    [cert_hash] NVARCHAR(64) NULL,
    CONSTRAINT [fk_certificates_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_certificates_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_certificates_assessment] FOREIGN KEY ([assessment_id]) REFERENCES [dbo].[assessments] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [certificates] (1 records)
SET IDENTITY_INSERT [dbo].[certificates] ON;
GO
INSERT INTO [dbo].[certificates] ([id], [certificate_code], [student_id], [course_id], [assessment_id], [title], [final_score], [issue_date], [expiry_date], [status], [cert_hash]) VALUES
  (1, N'CB-CERT-2026-0001', 3, 1, NULL, N'Chứng chỉ Hoàn thành Xuất sắc Khóa học C++ Cơ bản', 95.5, N'2026-11-10 15:05:21', NULL, N'active', N'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
GO
SET IDENTITY_INSERT [dbo].[certificates] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [regrade_requests]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[regrade_requests]', N'U') IS NOT NULL DROP TABLE [dbo].[regrade_requests];
GO
CREATE TABLE [dbo].[regrade_requests] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [submission_id] INT NOT NULL,
    [student_id] INT NOT NULL,
    [exercise_id] INT NOT NULL,
    [reason] NVARCHAR(MAX) NOT NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'pending',
    [reviewer_id] INT NULL,
    [reviewer_feedback] NVARCHAR(MAX) NULL,
    [old_score] FLOAT NOT NULL,
    [new_score] FLOAT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [resolved_at] DATETIME2 NULL,
    CONSTRAINT [fk_regrade_submission] FOREIGN KEY ([submission_id]) REFERENCES [dbo].[submissions] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_regrade_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_regrade_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_regrade_reviewer] FOREIGN KEY ([reviewer_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [regrade_requests] (2 records)
SET IDENTITY_INSERT [dbo].[regrade_requests] ON;
GO
INSERT INTO [dbo].[regrade_requests] ([id], [submission_id], [student_id], [exercise_id], [reason], [status], [reviewer_id], [reviewer_feedback], [old_score], [new_score], [created_at], [resolved_at]) VALUES
  (1, 1, 3, 1, N'Em thấy code của em đúng nhưng test case 2 bị báo Wrong Answer do thừa dấu xuống dòng.', N'in_review', 2, N'', 8.0, NULL, N'2026-11-10 15:05:21', NULL),
  (2, 2, 3, 2, N'Em xin phúc khảo vì em dùng cin >> a >> b thay vì scanf.', N'approved', 2, N'Đã xem xét và chấp nhận. Điểm cập nhật lại 10/10.', 5.0, 10.0, N'2026-11-10 15:05:21', N'2026-11-10 15:05:21');
GO
SET IDENTITY_INSERT [dbo].[regrade_requests] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [submission_events]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[submission_events]', N'U') IS NOT NULL DROP TABLE [dbo].[submission_events];
GO
CREATE TABLE [dbo].[submission_events] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [submission_id] INT NULL,
    [attempt_id] INT NULL,
    [student_id] INT NOT NULL,
    [exercise_id] INT NULL,
    [event_type] NVARCHAR(50) NOT NULL,
    [event_data_json] NVARCHAR(MAX) NULL,
    [ip_address] NVARCHAR(45) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_subevents_submission] FOREIGN KEY ([submission_id]) REFERENCES [dbo].[submissions] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_subevents_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_subevents_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_subevents_attempt] FOREIGN KEY ([attempt_id]) REFERENCES [dbo].[assessment_attempts] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [submission_events] (2 records)
SET IDENTITY_INSERT [dbo].[submission_events] ON;
GO
INSERT INTO [dbo].[submission_events] ([id], [submission_id], [attempt_id], [student_id], [exercise_id], [event_type], [event_data_json], [ip_address], [created_at]) VALUES
  (1, 1, NULL, 3, 1, N'tab_switch', N'{"duration_ms": 4200, "tab_title": "Google Search"}', N'127.0.0.1', N'2026-11-10 15:05:21'),
  (2, 1, NULL, 3, 1, N'paste_code', N'{"characters_pasted": 85, "speed_wpm": 450}', N'127.0.0.1', N'2026-11-10 15:05:21');
GO
SET IDENTITY_INSERT [dbo].[submission_events] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [audit_logs]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[audit_logs]', N'U') IS NOT NULL DROP TABLE [dbo].[audit_logs];
GO
CREATE TABLE [dbo].[audit_logs] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NULL,
    [action] NVARCHAR(100) NOT NULL,
    [target_type] NVARCHAR(50) NOT NULL,
    [target_id] INT NULL,
    [details] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_auditlogs_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL
);
GO

-- Dumping data for table [audit_logs] (2 records)
SET IDENTITY_INSERT [dbo].[audit_logs] ON;
GO
INSERT INTO [dbo].[audit_logs] ([id], [user_id], [action], [target_type], [target_id], [details], [created_at]) VALUES
  (1, 1, N'TOGGLE_USER_STATUS', N'user', 5, N'Changed status of Nha to locked', N'2026-10-23 04:57:08'),
  (2, 1, N'TOGGLE_USER_STATUS', N'user', 5, N'Changed status of Nha to active', N'2026-10-23 04:57:46');
GO
SET IDENTITY_INSERT [dbo].[audit_logs] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [system_settings]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[system_settings]', N'U') IS NOT NULL DROP TABLE [dbo].[system_settings];
GO
CREATE TABLE [dbo].[system_settings] (
    [key] NVARCHAR(100) PRIMARY KEY,
    [value] NVARCHAR(MAX) NOT NULL,
    [description] NVARCHAR(MAX) NULL
);
GO

-- Dumping data for table [system_settings] (5 records)
INSERT INTO [dbo].[system_settings] ([key], [value], [description]) VALUES
  (N'site_name', N'CodeBeginner', N'Tên nền tảng hiển thị'),
  (N'site_description', N'Hệ thống hỗ trợ học và luyện tập lập trình C++ từ cơ bản đến nâng cao', N'Mô tả tóm tắt'),
  (N'default_time_limit', N'2.0', N'Thời gian chạy tối đa mặc định cho mỗi test case (giây)'),
  (N'default_memory_limit', N'128', N'Bộ nhớ tối đa cho phép (MB)'),
  (N'supported_languages', N'C++ (g++ 10.3 / C++17)', N'Danh sách môi trường biên dịch hỗ trợ');
GO

-- --------------------------------------------------------
-- Table structure for [exercise_rubrics]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[exercise_rubrics]', N'U') IS NOT NULL DROP TABLE [dbo].[exercise_rubrics];
GO
CREATE TABLE [dbo].[exercise_rubrics] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [exercise_id] INT NOT NULL,
    [name] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [max_points] FLOAT NOT NULL DEFAULT 25.0,
    [weight] FLOAT NOT NULL DEFAULT 1.0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_rubrics_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE CASCADE
);
GO

-- Dumping data for table [exercise_rubrics] (6 records)
SET IDENTITY_INSERT [dbo].[exercise_rubrics] ON;
GO
INSERT INTO [dbo].[exercise_rubrics] ([id], [exercise_id], [name], [description], [max_points], [weight], [created_at]) VALUES
  (1, 1, N'Đọc dữ liệu đúng định dạng', N'Nhập đúng giá trị số nguyên n từ bàn phím', 30.0, 1.0, N'2026-11-11 14:24:42'),
  (2, 1, N'Xử lý logic chẵn/lẻ chính xác', N'Sử dụng phép chia lấy dư n % 2 chuẩn xác', 40.0, 1.0, N'2026-11-11 14:24:42'),
  (3, 1, N'In kết quả đúng định dạng', N'In đúng CHAN hoặc LE theo yêu cầu đề bài', 30.0, 1.0, N'2026-11-11 14:24:42'),
  (4, 2, N'Nhập đúng hai số nguyên a, b', N'Đọc dữ liệu dòng đầu vào chính xác', 30.0, 1.0, N'2026-11-11 14:24:42'),
  (5, 2, N'Tính toán tổng chính xác', N'Thực hiện phép cộng a + b không tràn số', 40.0, 1.0, N'2026-11-11 14:24:42'),
  (6, 2, N'Xuất kết quả đúng định dạng', N'In ra giá trị tổng chuẩn xác', 30.0, 1.0, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[exercise_rubrics] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [course_reviews]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[course_reviews]', N'U') IS NOT NULL DROP TABLE [dbo].[course_reviews];
GO
CREATE TABLE [dbo].[course_reviews] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [course_id] INT NOT NULL,
    [student_id] INT NOT NULL,
    [rating] INT NOT NULL CHECK([rating] >= 1 AND [rating] <= 5),
    [comment] NVARCHAR(MAX) NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'visible',
    [created_at] DATETIME2 DEFAULT GETDATE(),
    [updated_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_course_reviews] UNIQUE ([course_id], [student_id]),
    CONSTRAINT [fk_coursereviews_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_coursereviews_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [course_reviews] (1 records)
SET IDENTITY_INSERT [dbo].[course_reviews] ON;
GO
INSERT INTO [dbo].[course_reviews] ([id], [course_id], [student_id], [rating], [comment], [status], [created_at], [updated_at]) VALUES
  (1, 1, 3, 5, N'Khóa học C++ rất dễ hiểu cho người mới bắt đầu! Bài tập có máy chấm tự động siêu tiện.', N'visible', N'2026-11-11 14:24:42', N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[course_reviews] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [learning_goals]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[learning_goals]', N'U') IS NOT NULL DROP TABLE [dbo].[learning_goals];
GO
CREATE TABLE [dbo].[learning_goals] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [sessions_per_week] INT DEFAULT 3,
    [target_completion_date] DATE NULL,
    [reminder_time] NVARCHAR(10) DEFAULT '19:00',
    [email_reminder_enabled] TINYINT DEFAULT 1,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_learning_goals] UNIQUE ([student_id], [course_id]),
    CONSTRAINT [fk_learninggoals_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_learninggoals_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [learning_goals] (1 records)
SET IDENTITY_INSERT [dbo].[learning_goals] ON;
GO
INSERT INTO [dbo].[learning_goals] ([id], [student_id], [course_id], [sessions_per_week], [target_completion_date], [reminder_time], [email_reminder_enabled], [created_at]) VALUES
  (1, 3, 1, 4, NULL, N'20:00', 1, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[learning_goals] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [programming_topics]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[programming_topics]', N'U') IS NOT NULL DROP TABLE [dbo].[programming_topics];
GO
CREATE TABLE [dbo].[programming_topics] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL UNIQUE,
    [description] NVARCHAR(255) NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'active',
    [order_index] INT DEFAULT 1,
    [created_at] DATETIME2 DEFAULT GETDATE()
);
GO

-- Dumping data for table [programming_topics] (10 records)
SET IDENTITY_INSERT [dbo].[programming_topics] ON;
GO
INSERT INTO [dbo].[programming_topics] ([id], [name], [description], [status], [order_index], [created_at]) VALUES
  (1, N'Biến và kiểu dữ liệu', N'Khái niệm biến, hằng số, các kiểu dữ liệu nguyên thủy trong C++', N'active', 1, N'2026-11-11 14:24:42'),
  (2, N'Nhập/xuất dữ liệu', N'Cú pháp cin, cout, định dạng dữ liệu vào ra', N'active', 2, N'2026-11-11 14:24:42'),
  (3, N'Toán tử và biểu thức', N'Toán tử số học, so sánh, logic và độ ưu tiên toán tử', N'active', 3, N'2026-11-11 14:24:42'),
  (4, N'Cấu trúc rẽ nhánh (If/Else)', N'Câu lệnh if, else if, else, toán tử 3 ngôi và switch case', N'active', 4, N'2026-11-11 14:24:42'),
  (5, N'Vòng lặp (Loops)', N'Vòng lặp for, while, do-while, break và continue', N'active', 5, N'2026-11-11 14:24:42'),
  (6, N'Mảng 1 chiều và 2 chiều', N'Khai báo mảng, duyệt phần tử, ma trận trong C++', N'active', 6, N'2026-11-11 14:24:42'),
  (7, N'Chuỗi ký tự (Strings)', N'Xâu ký tự std::string, các hàm xử lý chuỗi', N'active', 7, N'2026-11-11 14:24:42'),
  (8, N'Hàm và tham số (Functions)', N'Định nghĩa hàm, truyền tham trị và tham chiếu', N'active', 8, N'2026-11-11 14:24:42'),
  (9, N'Đệ quy (Recursion)', N'Kỹ thuật đệ quy, điểm dừng và bài toán quay lui', N'active', 9, N'2026-11-11 14:24:42'),
  (10, N'Con trỏ và cấp phát động', N'Địa chỉ ô nhớ, toán tử con trỏ *, &, new và delete', N'active', 10, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[programming_topics] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [system_backups]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[system_backups]', N'U') IS NOT NULL DROP TABLE [dbo].[system_backups];
GO
CREATE TABLE [dbo].[system_backups] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [filename] NVARCHAR(255) NOT NULL,
    [backup_type] NVARCHAR(50) NOT NULL DEFAULT 'full',
    [file_size_bytes] BIGINT DEFAULT 0,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'success',
    [notes] NVARCHAR(MAX) NULL,
    [created_by] INT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_backups_user] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL
);
GO

-- Dumping data for table [system_backups] (1 records)
SET IDENTITY_INSERT [dbo].[system_backups] ON;
GO
INSERT INTO [dbo].[system_backups] ([id], [filename], [backup_type], [file_size_bytes], [status], [notes], [created_by], [created_at]) VALUES
  (1, N'backup_codebeginner_init.sql', N'full', 170553, N'success', N'Bản sao lưu CSDL ban đầu trước khi nâng cấp chức năng.', NULL, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[system_backups] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [system_alerts]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[system_alerts]', N'U') IS NOT NULL DROP TABLE [dbo].[system_alerts];
GO
CREATE TABLE [dbo].[system_alerts] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [component] NVARCHAR(50) NOT NULL,
    [severity] NVARCHAR(30) NOT NULL DEFAULT 'warning',
    [title] NVARCHAR(255) NOT NULL,
    [message] NVARCHAR(MAX) NOT NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'open',
    [resolved_by] INT NULL,
    [resolved_at] DATETIME2 NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_alerts_user] FOREIGN KEY ([resolved_by]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL
);
GO

-- Dumping data for table [system_alerts] (1 records)
SET IDENTITY_INSERT [dbo].[system_alerts] ON;
GO
INSERT INTO [dbo].[system_alerts] ([id], [component], [severity], [title], [message], [status], [resolved_by], [resolved_at], [created_at]) VALUES
  (1, N'judge_service', N'normal', N'Máy chấm hoạt động bình thường', N'Tất cả 10 workers đang sẵn sàng nhận mã nguồn.', N'resolved', NULL, NULL, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[system_alerts] OFF;
GO

-- --------------------------------------------------------
-- Table structure for [course_instructors]
-- --------------------------------------------------------
IF OBJECT_ID(N'[dbo].[course_instructors]', N'U') IS NOT NULL DROP TABLE [dbo].[course_instructors];
GO
CREATE TABLE [dbo].[course_instructors] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [course_id] INT NOT NULL,
    [instructor_id] INT NOT NULL,
    [assigned_lesson_ids_json] NVARCHAR(MAX) DEFAULT '[]',
    [role] NVARCHAR(50) NOT NULL DEFAULT 'instructor',
    [assigned_by] INT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_instructors_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_instructors_user] FOREIGN KEY ([instructor_id]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION,
    CONSTRAINT [fk_instructors_assignedby] FOREIGN KEY ([assigned_by]) REFERENCES [dbo].[users] ([id]) ON DELETE NO ACTION
);
GO

-- Dumping data for table [course_instructors] (1 records)
SET IDENTITY_INSERT [dbo].[course_instructors] ON;
GO
INSERT INTO [dbo].[course_instructors] ([id], [course_id], [instructor_id], [assigned_lesson_ids_json], [role], [assigned_by], [created_at]) VALUES
  (1, 1, 2, N'[]', N'lead_expert', 1, N'2026-11-11 14:24:42');
GO
SET IDENTITY_INSERT [dbo].[course_instructors] OFF;
GO
