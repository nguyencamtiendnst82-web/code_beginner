-- ========================================================
-- CODEBEGINNER PLATFORM - COMPLETE MYSQL DATABASE DUMP
-- Generated At: 2026-11-11 21:38:07
-- Compatible with MySQL 5.7+, 8.0+ and MariaDB 10+
-- Total Tables: 37
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `codebeginner` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `codebeginner`;

-- --------------------------------------------------------
-- Table structure for `roles`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `display_name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) NULL,
    `permissions_json` LONGTEXT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `roles` (4 records)
INSERT INTO `roles` (`id`, `name`, `display_name`, `description`, `permissions_json`, `created_at`) VALUES
  (1, 'admin', 'Quản trị viên', 'Toàn quyền quản trị hệ thống, quản lý người dùng, cấu hình và báo cáo', '["all", "manage_users", "manage_courses", "view_audit_logs", "manage_settings"]', '2026-11-10 15:05:21'),
  (2, 'expert', 'Chuyên gia nội dung', 'Biên soạn khóa học, bài học, bài tập lập trình, duyệt nội dung và chấm phúc khảo', '["create_course", "create_exercise", "review_content", "regrade_submissions"]', '2026-11-10 15:05:21'),
  (3, 'learner', 'Học viên', 'Tham gia học tập, làm bài kiểm tra, nộp bài tập lập trình và thảo luận trên diễn đàn', '["enroll_courses", "submit_code", "take_assessments", "create_threads", "request_regrade"]', '2026-11-10 15:05:21'),
  (4, 'moderator', 'Kiểm duyệt viên', 'Kiểm duyệt nội dung diễn đàn, báo cáo vi phạm và hỗ trợ rà soát chất lượng', '["review_forum_reports", "lock_threads", "review_content"]', '2026-11-10 15:05:21');

-- --------------------------------------------------------
-- Table structure for `users`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `full_name` VARCHAR(150) NOT NULL,
    `role` VARCHAR(30) NOT NULL DEFAULT 'learner',
    `status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `avatar` VARCHAR(255) DEFAULT '/static/img/default-avatar.png',
    `bio` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `role_id` INT NULL,
    `phone` VARCHAR(20) DEFAULT '',
    `failed_login_attempts` INT DEFAULT 0,
    `locked_until` DATETIME NULL,
    `force_password_change` TINYINT DEFAULT 0,
    `reset_token` VARCHAR(100) NULL,
    `reset_token_expiry` DATETIME NULL,
    CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `users` (7 records)
INSERT INTO `users` (`id`, `username`, `password_hash`, `email`, `full_name`, `role`, `status`, `avatar`, `bio`, `created_at`, `role_id`, `phone`, `failed_login_attempts`, `locked_until`, `force_password_change`, `reset_token`, `reset_token_expiry`) VALUES
  (1, 'admin', 'scrypt:32768:8:1$ogmf4iWZM1XzA5mP$a8767c5cb6c64c75d296816715e376f42a01d53ae09d73ac5a6be907f33fc11f2bcb86ea1248a9341819d544dccf9038364ccca04381e984ac09217084ccc8da', 'admin@codebeginner.edu.vn', 'Quản Trị Viên Hệ Thống', 'admin', 'active', '/static/img/default-avatar.png', 'Quản trị viên toàn hệ thống CodeBeginner', '2026-10-15 06:38:05', 1, '', 0, NULL, 0, NULL, NULL),
  (2, 'expert', 'scrypt:32768:8:1$hZaqZ5PO40aDI0KM$cae05ea123cd57284a48293ac47f40dfb93c0447abf54f91ab077a1ff25e2d306687cf5d6d1e8d558a821b512184cef592a1e9bdbaa57b70366e0aec2581c815', 'expert@codebeginner.edu.vn', 'ThS. Nguyễn Văn Chuyên Gia', 'expert', 'active', '/static/img/default-avatar.png', 'Giảng viên chuyên ngành Khoa học Máy tính & Lập trình C++', '2026-10-15 06:38:05', 2, '', 0, NULL, 0, NULL, NULL),
  (3, 'learner', 'scrypt:32768:8:1$759muifO2C3yG0O7$c5cb50218b8c8e5e38d5e0e1d32278bd5ce68d9a777be6888d4b0d9b8f35aeaf217f92200e36cbf7c2df18e558b9f523b15d9b57d58335e94e9c489c0f8fecc4', 'learner@gmail.com', 'Trần Văn Học Viên', 'learner', 'active', '/static/img/default-avatar.png', 'Người mới bắt đầu khám phá thế giới lập trình C++', '2026-10-15 06:38:05', 3, '', 0, NULL, 0, NULL, NULL),
  (4, 'tien', 'scrypt:32768:8:1$5WDk6Ssa3bKHCkxc$b3bd4c167dcf905add3ddb7dc135b139ac5be45350b68538b6f1048c9c37328e40df3f56054dbb7114f52bb38914ee4e1db2f1170ce5f4e429d34c482d6b2cb8', 'tientientien@gmail.com', 'Nguyễn Văn Tiên', 'learner', 'active', '/static/img/default-avatar.png', '', '2026-10-15 07:05:35', 3, '', 0, NULL, 0, NULL, NULL),
  (5, 'Nha', 'scrypt:32768:8:1$HqA5OjiJX21jl64l$22f3a8d0fa88bfa907dfbe723afda92c22ef4b6146a5c337abd28e1a8366d8705021b40d45449673d00b8bafc47eca9a3734851927ab938d9122c350df933b63', 'nha@g.com', 'Nha', 'learner', 'active', '/static/img/default-avatar.png', '', '2026-10-15 07:25:00', 3, '', 0, NULL, 0, NULL, NULL),
  (6, 'sdf', 'scrypt:32768:8:1$dRV8wMnVLjl8PUDz$7dfed5dae01f5222da4d5fe46d7df2854e48a480a78d2f7c08f2a4640c039dacb8d0f6afd0c86ac9cc3988be8208f9eb9fd4614dfb538b938227671b77a634cd', 'vana@gmail.com', 'dsf', 'learner', 'active', '/static/img/default-avatar.png', '', '2026-10-15 07:41:08', 3, '', 0, NULL, 0, NULL, NULL),
  (7, 'Web', 'scrypt:32768:8:1$LuKaubIVe34C3vYw$664b66feb56a5c104baff030014279e919e4c2ed3150f1bb3e75d9b10d9864e276ac1e9915f82e052a8529ce2704fce5cc8be8bc1cb7f1e3b0650dea0d6c7f7b', 'web@gmail.com', 'Nguyễn Văn Web', 'learner', 'active', '/static/img/default-avatar.png', '', '2026-10-23 04:51:27', 3, '', 0, NULL, 0, NULL, NULL);

-- --------------------------------------------------------
-- Table structure for `courses`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `courses`;
CREATE TABLE IF NOT EXISTS `courses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `language` VARCHAR(50) NOT NULL DEFAULT 'C++',
    `level` VARCHAR(50) NOT NULL,
    `image_url` VARCHAR(255) DEFAULT '',
    `status` VARCHAR(30) NOT NULL DEFAULT 'published',
    `expert_id` INT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `parent_course_id` INT NULL,
    `order_in_chain` INT DEFAULT 1,
    `prerequisite_course_id` INT NULL,
    `start_date` DATETIME NULL,
    `end_date` DATETIME NULL,
    `is_public_view` TINYINT DEFAULT 1,
    `allow_self_enroll` TINYINT DEFAULT 1,
    `forum_enabled` TINYINT DEFAULT 1,
    `min_lesson_pct` FLOAT DEFAULT 80.0,
    `min_exercise_count` INT DEFAULT 5,
    `min_final_score` FLOAT DEFAULT 60.0,
    `certificate_enabled` TINYINT DEFAULT 1,
    CONSTRAINT `fk_courses_expert` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_courses_parent` FOREIGN KEY (`parent_course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_courses_prereq` FOREIGN KEY (`prerequisite_course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `courses` (2 records)
INSERT INTO `courses` (`id`, `title`, `description`, `language`, `level`, `image_url`, `status`, `expert_id`, `created_at`, `parent_course_id`, `order_in_chain`, `prerequisite_course_id`, `start_date`, `end_date`, `is_public_view`, `allow_self_enroll`, `forum_enabled`, `min_lesson_pct`, `min_exercise_count`, `min_final_score`, `certificate_enabled`) VALUES
  (1, 'C++ Cơ Bản & Nền Tảng Cho Người Mới Bắt Đầu', 'Khóa học nhập môn lập trình bài bản từ biến, kiểu dữ liệu, nhập xuất, điều kiện rẽ nhánh đến vòng lặp và hàm. Phù hợp tuyệt đối cho người chưa biết lập trình.', 'C++', 'Cơ bản', 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=800&auto=format&fit=crop&q=60', 'published', 2, '2026-10-15 06:38:05', NULL, 1, NULL, NULL, NULL, 1, 1, 1, 80.0, 5, 60.0, 1),
  (2, 'C++ Cấu Trúc Dữ Liệu & Thuật Toán Cơ Bản Đến Nâng Cao', 'Khám phá mảng, chuỗi, đệ quy, sắp xếp, tìm kiếm và các cấu trúc dữ liệu nền tảng như Stack, Queue, Cây nhị phân và Quy hoạch động.', 'C++', 'Nâng cao', 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=60', 'published', 2, '2026-10-15 06:38:05', NULL, 1, NULL, NULL, NULL, 1, 1, 1, 80.0, 5, 60.0, 1);

-- --------------------------------------------------------
-- Table structure for `chapters`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `chapters`;
CREATE TABLE IF NOT EXISTS `chapters` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `order_index` INT NOT NULL DEFAULT 1,
    `description` TEXT NULL,
    `is_sequential` TINYINT DEFAULT 0,
    `passing_rule` VARCHAR(100) DEFAULT 'all_passed',
    `min_exercises_to_pass` INT DEFAULT 0,
    `status` VARCHAR(30) DEFAULT 'published',
    CONSTRAINT `fk_chapters_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `chapters` (7 records)
INSERT INTO `chapters` (`id`, `course_id`, `title`, `order_index`, `description`, `is_sequential`, `passing_rule`, `min_exercises_to_pass`, `status`) VALUES
  (1, 1, 'Chương 1: Khởi động với Lập trình & C++', 1, '', 0, 'all_passed', 0, 'published'),
  (2, 1, 'Chương 2: Cấu trúc Rẽ nhánh & Điều kiện', 2, '', 0, 'all_passed', 0, 'published'),
  (3, 1, 'Chương 3: Cấu trúc Vòng lặp', 3, '', 0, 'all_passed', 0, 'published'),
  (4, 1, 'Chương 4: Hàm và Tổ chức Chương trình', 4, '', 0, 'all_passed', 0, 'published'),
  (5, 2, 'Chương 1: Mảng và Chuỗi ký tự', 1, '', 0, 'all_passed', 0, 'published'),
  (6, 2, 'Chương 2: Thuật toán Tìm kiếm & Sắp xếp', 2, '', 0, 'all_passed', 0, 'published'),
  (7, 2, 'Chương 3: Đệ quy & Cấu trúc Dữ liệu Nâng cao', 3, '', 0, 'all_passed', 0, 'published');

-- --------------------------------------------------------
-- Table structure for `lessons`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `lessons`;
CREATE TABLE IF NOT EXISTS `lessons` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `chapter_id` INT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `syntax_guide` TEXT,
    `example_code` TEXT,
    `example_output` TEXT,
    `quiz_data` LONGTEXT,
    `order_index` INT NOT NULL DEFAULT 1,
    `status` VARCHAR(30) NOT NULL DEFAULT 'approved',
    `reject_reason` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `is_trial` TINYINT DEFAULT 0,
    `video_url` VARCHAR(255) NULL,
    `image_url` VARCHAR(255) NULL,
    CONSTRAINT `fk_lessons_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_lessons_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `chapters` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `lessons` (7 records)
INSERT INTO `lessons` (`id`, `course_id`, `chapter_id`, `title`, `content`, `syntax_guide`, `example_code`, `example_output`, `quiz_data`, `order_index`, `status`, `reject_reason`, `created_at`, `is_trial`, `video_url`, `image_url`) VALUES
  (1, 1, 1, 'Giới thiệu C++ và Cấu trúc chương trình chuẩn', 'C++ là ngôn ngữ lập trình đa nền tảng mạnh mẽ được phát triển bởi Bjarne Stroustrup từ năm 1979 tại Bell Labs. C++ kết hợp cả đặc tính hướng thủ tục và hướng đối tượng, cho phép quản lý bộ nhớ trực tiếp và đạt hiệu năng tối đa trong phát triển hệ thống, trò chơi và thuật toán thi đấu.', '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Khối mã lệnh ở đây\n    return 0;\n}', '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Chao mung den voi CodeBeginner!" << endl;\n    return 0;\n}', 'Chao mung den voi CodeBeginner!', '[{"question": "Lệnh nào sau đây dùng để xuất dữ liệu ra màn hình trong C++?", "options": ["cin", "cout", "printf_s", "output"], "correct": 1, "explanation": "cout kết hợp toán tử << được dùng để in thông tin ra màn hình."}]', 1, 'approved', '', '2026-10-15 06:38:05', 1, '', ''),
  (2, 1, 1, 'Biến, Kiểu dữ liệu và Nhập/Xuất trong C++', 'Biến là vùng nhớ được đặt tên dùng để lưu trữ dữ liệu trong quá trình chạy chương trình. Các kiểu dữ liệu cơ bản bao gồm:\n- int: số nguyên (ví dụ: -5, 0, 100)\n- double / float: số thực có dấu chấm động (ví dụ: 3.14, -0.05)\n- char: ký tự đơn đặt trong dấu nháy đơn (ví dụ: \'a\', \'Z\')\n- bool: giá trị logic (true hoặc false)\n- string: chuỗi ký tự (cần #include <string>).\n\nSử dụng cin >> ten_bien để nhận dữ liệu từ bàn phím và cout << gia_tri để xuất ra màn hình.', 'Kieu_Du_Lieu ten_bien = gia_tri_khoi_tao;\ncin >> ten_bien;\ncout << "Gia tri: " << ten_bien;', '#include <iostream>\nusing namespace std;\n\nint main() {\n    int tuoi;\n    cout << "Nhap tuoi cua ban: ";\n    if (cin >> tuoi) {\n        cout << "Ban " << tuoi << " tuoi." << endl;\n    }\n    return 0;\n}', 'Nhap tuoi cua ban: 20\nBan 20 tuoi.', '[{"question": "Kiểu dữ liệu nào lưu trữ số nguyên 4 byte phổ biến nhất trong C++?", "options": ["float", "double", "int", "char"], "correct": 2, "explanation": "Kiểu int thường dùng để lưu số nguyên và có kích thước 4 byte trên hệ thống hiện đại."}]', 2, 'approved', '', '2026-10-15 06:38:05', 0, '', ''),
  (3, 1, 2, 'Câu lệnh điều kiện If - Else & Toán tử so sánh', 'Câu lệnh if/else dùng để kiểm tra điều kiện logic và phân nhánh luồng thực thi của chương trình. Các toán tử so sánh gồm: == (bằng), != (khác), > (lớn hơn), < (nhỏ hơn), >= (lớn hơn hoặc bằng), <= (nhỏ hơn hoặc bằng). Các toán tử logic gồm: && (VÀ), || (HOẶC), ! (PHỦ ĐỊNH).', 'if (dieu_kien) {\n    // Thuc hien khi dieu kien dung\n} else {\n    // Thuc hien khi dieu kien sai\n}', '#include <iostream>\nusing namespace std;\n\nint main() {\n    int diem = 8;\n    if (diem >= 5) {\n        cout << "Dat yeu cau!";\n    } else {\n        cout << "Can hoc lai!";\n    }\n    return 0;\n}', 'Dat yeu cau!', '[{"question": "Trong câu lệnh if-else, khối lệnh else sẽ được thực hiện khi nào?", "options": ["Khi điều kiện if trả về true", "Khi điều kiện if trả về false", "Luôn luôn được thực hiện", "Không bao giờ được thực hiện"], "correct": 1, "explanation": "Khối lệnh else chỉ chạy khi biểu thức điều kiện trong if sai (false)."}]', 3, 'approved', '', '2026-10-15 06:38:05', 0, '', ''),
  (4, 1, 3, 'Vòng lặp For, While và Do-While', 'Vòng lặp cho phép thực hiện lặp lại một đoạn code nhiều lần cho đến khi thỏa mãn một điều kiện dừng nhất định.\n- Vòng lặp for: Phù hợp khi biết trước số lần lặp cụ thể.\n- Vòng lặp while: Phù hợp khi chưa biết trước số lần lặp, kiểm tra điều kiện trước.\n- Vòng lặp do-while: Luôn thực hiện thân vòng lặp ít nhất 1 lần trước khi kiểm tra điều kiện.', 'for (khoi_tao; dieu_kien; buoc_nhay) {\n    // Than vong lap\n}\n\nwhile (dieu_kien) {\n    // Than vong lap\n}', '#include <iostream>\nusing namespace std;\n\nint main() {\n    int tong = 0;\n    for (int i = 1; i <= 5; i++) {\n        tong += i;\n    }\n    cout << "Tong tu 1 den 5 la: " << tong << endl;\n    return 0;\n}', 'Tong tu 1 den 5 la: 15', '[{"question": "Vòng lặp while kiểm tra điều kiện vào thời điểm nào?", "options": ["Sau khi chạy hết thân vòng lặp", "Trước khi chạy thân vòng lặp", "Ở giữa thân vòng lặp", "Không bao giờ kiểm tra"], "correct": 1, "explanation": "Vòng lặp while là vòng lặp kiểm tra trước, nếu điều kiện đúng mới thực hiện thân vòng lặp."}]', 4, 'approved', '', '2026-10-15 06:38:05', 0, '', ''),
  (5, 1, 4, 'Hàm (Function) và Tổ chức chương trình', 'Hàm là một khối lệnh độc lập được đặt tên, nhận các tham số đầu vào và trả về một kết quả. Hàm giúp tái sử dụng mã nguồn, chia nhỏ bài toán phức tạp thành các phần tử dễ quản lý.\nCần phân biệt giữa truyền tham trị (truyền bản sao) và truyền tham chiếu (sử dụng dấu & để thay đổi trực tiếp biến gốc).', 'Kieu_Tra_Ve Ten_Ham(Danh_Sach_Tham_So) {\n    // Than ham\n    return gia_tri;\n}', '#include <iostream>\nusing namespace std;\n\nint tinhTong(int a, int b) {\n    return a + b;\n}\n\nint main() {\n    int ketQua = tinhTong(15, 25);\n    cout << "Ket qua: " << ketQua << endl;\n    return 0;\n}', 'Ket qua: 40', '[]', 5, 'approved', '', '2026-10-15 06:38:05', 0, '', ''),
  (6, 2, 5, 'Mảng một chiều (One-Dimensional Array) trong C++', 'Mảng một chiều là tập hợp các phần tử có cùng kiểu dữ liệu được lưu trữ liên tiếp trong bộ nhớ máy tính. Mỗi phần tử trong mảng được định danh bằng chỉ số (index), bắt đầu từ chỉ số 0 đến n - 1.', 'Kieu_Du_Lieu ten_mang[Kich_Thuoc];\nten_mang[0] = gia_tri;', '#include <iostream>\nusing namespace std;\n\nint main() {\n    int a[5] = {2, 4, 6, 8, 10};\n    for (int i = 0; i < 5; i++) {\n        cout << a[i] << " ";\n    }\n    return 0;\n}', '2 4 6 8 10', '[]', 6, 'approved', '', '2026-10-15 06:38:05', 0, '', ''),
  (7, 2, 5, 'Chuỗi ký tự std::string trong C++', 'std::string trong C++ là lớp đối tượng biểu diễn chuỗi ký tự linh hoạt hơn rất nhiều so với chuỗi ký tự kiểu mảng C-string char[]. Nó hỗ trợ nối chuỗi bằng toán tử +, tính độ dài bằng .length() hoặc .size(), lấy ký tự theo chỉ mục.', '#include <string>\nstring s = "Hello";\ns += " World";', '#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string s = "CodeBeginner";\n    cout << "Do dai: " << s.length() << endl;\n    cout << "Ky tu dau: " << s[0] << endl;\n    return 0;\n}', 'Do dai: 12\nKy tu dau: C', '[]', 7, 'approved', '', '2026-10-15 06:38:05', 0, '', '');

-- --------------------------------------------------------
-- Table structure for `exercises`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `exercises`;
CREATE TABLE IF NOT EXISTS `exercises` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NULL,
    `lesson_id` INT NULL,
    `title` VARCHAR(255) NOT NULL,
    `description` LONGTEXT NOT NULL,
    `input_description` TEXT NOT NULL,
    `output_description` TEXT NOT NULL,
    `sample_input` TEXT NOT NULL,
    `sample_output` TEXT NOT NULL,
    `explanation` TEXT,
    `constraints` TEXT,
    `difficulty` VARCHAR(50) NOT NULL DEFAULT 'Dễ',
    `topic` VARCHAR(100) NOT NULL,
    `reference_solution` LONGTEXT,
    `points` INT NOT NULL DEFAULT 10,
    `time_limit` FLOAT NOT NULL DEFAULT 2.0,
    `memory_limit` INT NOT NULL DEFAULT 128,
    `status` VARCHAR(30) NOT NULL DEFAULT 'approved',
    `expert_id` INT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `reference_solution_tested` TINYINT DEFAULT 0,
    `custom_checker_code` LONGTEXT NULL,
    `custom_checker_lang` VARCHAR(50) DEFAULT 'C++',
    `hints_json` LONGTEXT NULL,
    CONSTRAINT `fk_exercises_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_exercises_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_exercises_expert` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `exercises` (8 records)
INSERT INTO `exercises` (`id`, `course_id`, `lesson_id`, `title`, `description`, `input_description`, `output_description`, `sample_input`, `sample_output`, `explanation`, `constraints`, `difficulty`, `topic`, `reference_solution`, `points`, `time_limit`, `memory_limit`, `status`, `expert_id`, `created_at`, `reference_solution_tested`, `custom_checker_code`, `custom_checker_lang`, `hints_json`) VALUES
  (1, 1, 2, 'Tính tổng hai số nguyên', 'Viết chương trình đọc vào hai số nguyên a và b từ bàn phím, sau đó in ra tổng của hai số đó.', 'Một dòng duy nhất chứa hai số nguyên a và b cách nhau bởi dấu cách (-10^9 <= a, b <= 10^9).', 'In ra một số nguyên duy nhất là tổng a + b.', '5 7', '12', '5 + 7 = 12.', '-10^9 <= a, b <= 10^9', 'Dễ', 'Nhập/xuất', '#include <iostream>\nusing namespace std;\nint main() {\n    long long a, b;\n    if (cin >> a >> b) {\n        cout << (a + b) << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 1, '', 'C++', '["Gợi ý 1: Số chẵn là số chia hết cho 2 (dư 0).", "Gợi ý 2: Sử dụng toán tử % trong C++: if (n % 2 == 0)"]'),
  (2, 1, 3, 'Kiểm tra tính chẵn lẻ', 'Viết chương trình nhập vào một số nguyên n. Nếu n là số chẵn in ra CHAN, ngược lại in ra LE.', 'Số nguyên n (-10^9 <= n <= 10^9).', 'In ra CHAN hoặc LE trên một dòng.', '8', 'CHAN', '8 chia hết cho 2 nên in ra CHAN.', '-10^9 <= n <= 10^9', 'Dễ', 'If/Else', '#include <iostream>\nusing namespace std;\nint main() {\n    long long n;\n    if (cin >> n) {\n        if (n % 2 == 0) cout << "CHAN" << endl;\n        else cout << "LE" << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (3, 1, 3, 'Tìm số lớn nhất trong ba số', 'Viết chương trình nhập vào ba số nguyên a, b, c và in ra số lớn nhất trong ba số đó.', 'Một dòng chứa ba số nguyên a, b, c cách nhau bởi dấu cách.', 'In ra giá trị lớn nhất.', '4 9 2', '9', 'Trong ba số 4, 9, 2 thì số lớn nhất là 9.', '-10^9 <= a, b, c <= 10^9', 'Dễ', 'If/Else', '#include <iostream>\n#include <algorithm>\nusing namespace std;\nint main() {\n    long long a, b, c;\n    if (cin >> a >> b >> c) {\n        cout << max({a, b, c}) << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (4, 1, 4, 'Tính tổng từ 1 đến N', 'Cho số nguyên dương n. Hãy tính và in ra tổng S = 1 + 2 + 3 + ... + n.', 'Một số nguyên dương n (1 <= n <= 10^6).', 'In ra giá trị của tổng S.', '5', '15', '1 + 2 + 3 + 4 + 5 = 15.', '1 <= n <= 10^6', 'Dễ', 'Vòng lặp', '#include <iostream>\nusing namespace std;\nint main() {\n    long long n;\n    if (cin >> n) {\n        long long s = n * (n + 1) / 2;\n        cout << s << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (5, 1, 4, 'Kiểm tra số nguyên tố', 'Số nguyên tố là số nguyên lớn hơn 1 chỉ có đúng 2 ước là 1 và chính nó. Viết chương trình nhập vào số nguyên n. Nếu n là số nguyên tố in YES, ngược lại in NO.', 'Số nguyên n (-10^9 <= n <= 10^9).', 'In YES hoặc NO.', '7', 'YES', '7 là số nguyên tố.', '-10^9 <= n <= 10^9', 'Trung bình', 'Vòng lặp', '#include <iostream>\nusing namespace std;\nbool isPrime(long long n) {\n    if (n <= 1) return false;\n    if (n <= 3) return true;\n    if (n % 2 == 0 || n % 3 == 0) return false;\n    for (long long i = 5; i * i <= n; i += 6) {\n        if (n % i == 0 || n % (i + 2) == 0) return false;\n    }\n    return true;\n}\nint main() {\n    long long n;\n    if (cin >> n) {\n        if (isPrime(n)) cout << "YES" << endl;\n        else cout << "NO" << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (6, 1, 4, 'Tính giai thừa của N', 'Viết chương trình tính N! = 1 * 2 * 3 * ... * N. Quy ước 0! = 1.', 'Số nguyên N (0 <= N <= 20).', 'In ra kết quả N!.', '5', '120', '5! = 1 * 2 * 3 * 4 * 5 = 120.', '0 <= N <= 20', 'Dễ', 'Vòng lặp', '#include <iostream>\nusing namespace std;\nint main() {\n    int n;\n    if (cin >> n) {\n        long long ans = 1;\n        for (int i = 1; i <= n; i++) ans *= i;\n        cout << ans << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (7, 2, 6, 'Tính tổng các phần tử trong mảng', 'Cho một mảng gồm n số nguyên. Hãy tính và in ra tổng của tất cả các phần tử trong mảng.', 'Dòng 1 chứa số nguyên n (1 <= n <= 10^5).\nDòng 2 chứa n số nguyên cách nhau bởi dấu cách.', 'In ra tổng các phần tử.', '4\n1 3 5 7', '16', '1 + 3 + 5 + 7 = 16.', '1 <= n <= 10^5, -10^9 <= a[i] <= 10^9', 'Dễ', 'Mảng', '#include <iostream>\nusing namespace std;\nint main() {\n    int n;\n    if (cin >> n) {\n        long long sum = 0;\n        for (int i = 0; i < n; i++) {\n            long long x;\n            cin >> x;\n            sum += x;\n        }\n        cout << sum << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]'),
  (8, 2, 7, 'Đảo ngược chuỗi ký tự', 'Cho một chuỗi s chỉ gồm các ký tự chữ cái và số không chứa dấu cách. Hãy in ra chuỗi đảo ngược của s.', 'Một chuỗi s có độ dài không quá 1000 ký tự.', 'In ra chuỗi đảo ngược.', 'hello', 'olleh', 'Chuỗi đảo ngược của hello là olleh.', '1 <= length(s) <= 1000', 'Dễ', 'Chuỗi', '#include <iostream>\n#include <string>\n#include <algorithm>\nusing namespace std;\nint main() {\n    string s;\n    if (cin >> s) {\n        reverse(s.begin(), s.end());\n        cout << s << endl;\n    }\n    return 0;\n}', 10, 2.0, 128, 'approved', 2, '2026-10-15 06:38:05', 0, '', 'C++', '[]');

-- --------------------------------------------------------
-- Table structure for `test_cases`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `test_cases`;
CREATE TABLE IF NOT EXISTS `test_cases` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `exercise_id` INT NOT NULL,
    `input_data` LONGTEXT NOT NULL,
    `expected_output` LONGTEXT NOT NULL,
    `points` INT NOT NULL DEFAULT 2,
    `is_hidden` TINYINT NOT NULL DEFAULT 0,
    `order_index` INT NOT NULL DEFAULT 1,
    CONSTRAINT `fk_testcases_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `test_cases` (33 records)
INSERT INTO `test_cases` (`id`, `exercise_id`, `input_data`, `expected_output`, `points`, `is_hidden`, `order_index`) VALUES
  (1, 1, '5 7', '12', 2, 0, 1),
  (2, 1, '-10 25', '15', 3, 0, 2),
  (3, 1, '1000000000 2000000000', '3000000000', 3, 1, 3),
  (4, 1, '-500 -700', '-1200', 2, 1, 4),
  (5, 2, '8', 'CHAN', 2, 0, 1),
  (6, 2, '13', 'LE', 3, 0, 2),
  (7, 2, '0', 'CHAN', 3, 1, 3),
  (8, 2, '-7', 'LE', 2, 1, 4),
  (9, 3, '4 9 2', '9', 2, 0, 1),
  (10, 3, '15 15 10', '15', 3, 0, 2),
  (11, 3, '-5 -2 -8', '-2', 3, 1, 3),
  (12, 3, '100 200 500', '500', 2, 1, 4),
  (13, 4, '5', '15', 2, 0, 1),
  (14, 4, '1', '1', 3, 0, 2),
  (15, 4, '100', '5050', 3, 1, 3),
  (16, 4, '1000000', '500000500000', 2, 1, 4),
  (17, 5, '7', 'YES', 2, 0, 1),
  (18, 5, '1', 'NO', 2, 0, 2),
  (19, 5, '4', 'NO', 2, 0, 3),
  (20, 5, '999999937', 'YES', 2, 1, 4),
  (21, 5, '-17', 'NO', 2, 1, 5),
  (22, 6, '5', '120', 2, 0, 1),
  (23, 6, '0', '1', 3, 0, 2),
  (24, 6, '10', '3628800', 3, 1, 3),
  (25, 6, '20', '2432902008176640000', 2, 1, 4),
  (26, 7, '4\n1 3 5 7', '16', 2, 0, 1),
  (27, 7, '3\n-5 10 -2', '3', 3, 0, 2),
  (28, 7, '5\n0 0 0 0 0', '0', 3, 1, 3),
  (29, 7, '6\n100 200 300 400 500 600', '2100', 2, 1, 4),
  (30, 8, 'hello', 'olleh', 2, 0, 1),
  (31, 8, 'CodeBeginner', 'rennigebedoC', 3, 0, 2),
  (32, 8, 'a', 'a', 3, 1, 3),
  (33, 8, '123456789', '987654321', 2, 1, 4);

-- --------------------------------------------------------
-- Table structure for `submissions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `submissions`;
CREATE TABLE IF NOT EXISTS `submissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `exercise_id` INT NOT NULL,
    `source_code` LONGTEXT NOT NULL,
    `language` VARCHAR(50) NOT NULL DEFAULT 'C++',
    `status` VARCHAR(50) NOT NULL,
    `score` FLOAT NOT NULL DEFAULT 0,
    `passed_tests` INT NOT NULL DEFAULT 0,
    `total_tests` INT NOT NULL DEFAULT 0,
    `execution_time` FLOAT DEFAULT 0,
    `compile_error` TEXT,
    `test_details` LONGTEXT,
    `submitted_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `typing_data_json` LONGTEXT NULL,
    `anomaly_flag` TINYINT DEFAULT 0,
    `anomaly_score` FLOAT DEFAULT 0.0,
    `anomaly_status` VARCHAR(30) DEFAULT 'normal',
    `anomaly_review_notes` TEXT NULL,
    `anomaly_reviewer_id` INT NULL,
    `rubric_scores_json` LONGTEXT NULL,
    CONSTRAINT `fk_submissions_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_submissions_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `submissions` (39 records)
INSERT INTO `submissions` (`id`, `student_id`, `exercise_id`, `source_code`, `language`, `status`, `score`, `passed_tests`, `total_tests`, `execution_time`, `compile_error`, `test_details`, `submitted_at`, `typing_data_json`, `anomaly_flag`, `anomaly_score`, `anomaly_status`, `anomaly_review_notes`, `anomaly_reviewer_id`, `rubric_scores_json`) VALUES
  (1, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            int a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.559, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.559, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.004, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 06:56:06', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (2, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.576, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.576, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 06:57:36', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (3, 4, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a, b;\n    cin>>a>>b;\n    cout<<a+b;\n    \n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.566, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.566, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.015, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:17:58', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (4, 1, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a, b;\n    cin>>a>>b;\n    cout<<a+b;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.603, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.603, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.017, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:20:09', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (5, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.493, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.493, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.005, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.005, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:33:26', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (6, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.538, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.538, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:34:04', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (7, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.547, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.547, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:34:39', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (8, 5, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a,b;\n    cin >>a>>b;\n    cout<<a+b;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.562, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.562, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:36:29', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (9, 5, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a,b;\n    cin >>a>>b;\n    cout<<a-b;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.519, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.519, "input": "5 7", "expected": "12", "actual": "-2", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.006, "input": "-10 25", "expected": "15", "actual": "-35", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.006, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.006, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 07:37:18', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (10, 5, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    long a,b;\n    cin >>a>>b;\n    cout<<a+b;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.651, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.651, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:37:29', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (11, 5, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    long long a,b;\n    cin >>a>>b;\n    cout<<a+b;\n    return 0;\n}\n', 'C++', 'Accepted', 10.0, 4, 4, 0.537, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.537, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.007, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:38:19', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (12, 4, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a, b;\n    cin>>a>>b;\n    cout<<a+b;\n    \n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.494, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.494, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 07:53:04', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (13, 4, 1, '#include <iostream>\nusing namespace std;\n\nint main() {\n    // Viết giải pháp của bạn ở đây\n    int a, b;\n    cin>>a>>b;\n    cout<<a+b;\n    \n    return 0;\n}\n', 'C++', 'Wrong Answer', 7.0, 3, 4, 0.564, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.564, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:04:07', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (14, 3, 2, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    if (n % 2 ==0){\n        cout << "CHAN";\n    }\n    else cout << "LE";\n    \n    return 0;\n}\n', 'C++', 'Wrong Answer', 5.0, 2, 4, 0.522, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.522, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.01, "input": "13", "expected": "LE", "actual": "CHAN", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:15:33', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (15, 3, 2, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    cin >> n;\n    if (n % 2 ==0){\n        cout << "CHAN";\n    }\n    else cout << "LE";\n}\n', 'C++', 'Accepted', 10.0, 4, 4, 0.543, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.543, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "13", "expected": "LE", "actual": "LE", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:18:11', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (16, 3, 2, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    if (n % 2 ==0){\n        cout << "CHAN";\n    }\n    else cout << "LE";\n}\n', 'C++', 'Wrong Answer', 5.0, 2, 4, 0.495, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.495, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.012, "input": "13", "expected": "LE", "actual": "CHAN", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.017, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:18:40', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (17, 3, 2, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    cin >>n;\n    if (n % 2 ==0){\n        cout << "CHAN";\n    }\n    else cout << "LE";\n}\n', 'C++', 'Accepted', 10.0, 4, 4, 0.507, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.507, "input": "8", "expected": "CHAN", "actual": "CHAN", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "13", "expected": "LE", "actual": "LE", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:19:22', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (18, 3, 3, '#include <iostream>\n#include <algorithm>\nusing namespace std;\n\nint main() {\n	int a,b,c;\n    cin >>a >>b>>c;\n    cout << max(a,b,c);\n    return 0;\n}\n', 'C++', 'Compile Error', 0.0, 0, 4, 0.0, 'In file included from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/char_traits.h:39,\n                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/ios:40,\n                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/ostream:38,\n                 from C:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/iostream:39,\n                 from C:\\Users\\LENOVO\\AppData\\Local\\Temp\\tmpy05leh6m\\submission.cpp:1:\nC:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/stl_algobase.h: In instantiation of \'constexpr const _Tp& std::max(const _Tp&, const _Tp&, _Compare) [with _Tp = int; _Compare = int]\':\nC:\\Users\\LENOVO\\AppData\\Local\\Temp\\tmpy05leh6m\\submission.cpp:8:22:   required from here\nC:/TDM-GCC-64/lib/gcc/x86_64-w64-mingw32/10.3.0/include/c++/bits/stl_algobase.h:303:17: error: \'__comp\' cannot be used as a function\n  303 |       if (__comp(__a, __b))\n      |           ~~~~~~^~~~~~~~~~\n', '[]', '2026-10-15 08:20:51', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (19, 3, 3, '#include <iostream>\n#include <algorithm>\n\nusing namespace std;\n\nint main() {\n    int a, b, c;\n    cin >> a >> b >> c;\n    int max_num = max({a, b, c});\n\n    cout<< max_num << endl;\n\n    return 0;\n}', 'C++', 'Accepted', 10.0, 4, 4, 0.738, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.738, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:25:48', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (20, 3, 3, '#include <iostream>\n#include <algorithm>\n\nusing namespace std;\n\nint main() {\n    int a, b, c;\n    int max_num = max({a, b, c});\n\n    cout<< max_num << endl;\n\n    return 0;\n}', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.575, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.575, "input": "4 9 2", "expected": "9", "actual": "62", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.009, "input": "15 15 10", "expected": "15", "actual": "62", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.009, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:26:05', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (21, 3, 3, '#include <iostream>\n#include <algorithm>\n\nusing namespace std;\n\nint main() {\n    int a, b, c;\n    cin >> a >> b >> c;\n    int max_num = max({a, b, c});\n\n    cout<< max_num << endl;\n\n    return 0;\n}', 'C++', 'Accepted', 10.0, 4, 4, 0.679, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.679, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:26:11', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (22, 3, 3, '#include <iostream>\n#include <algorithm>\n\nusing namespace std;\n\nint main() {\n    int a, b, c;\n    cin >> a >> b >> c;\n    int max_num = max({a, b, c});\n\n    cout<< max_num << endl;\n\n    return 0;\n}', 'C++', 'Accepted', 10.0, 4, 4, 0.62, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.62, "input": "4 9 2", "expected": "9", "actual": "9", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "15 15 10", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:28:40', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (23, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    cin >> n;\n    sum=0;\n    for (int i=1 ; i<= n; i++){\n        sum+=i;\n    }\n    cout << sum;\n    return 0;\n}\n', 'C++', 'Compile Error', 0.0, 0, 4, 0.0, 'C:\\Users\\LENOVO\\AppData\\Local\\Temp\\tmpcq_ofvx4\\submission.cpp: In function \'int main()\':\nC:\\Users\\LENOVO\\AppData\\Local\\Temp\\tmpcq_ofvx4\\submission.cpp:7:5: error: \'sum\' was not declared in this scope\n    7 |     sum=0;\n      |     ^~~\n', '[]', '2026-10-15 08:31:27', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (24, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n,sum;\n    cin >> n;\n    sum=0;\n    for (int i=1 ; i<= n; i++){\n        sum+=i;\n    }\n    cout << sum;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 8.0, 3, 4, 0.682, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.682, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.016, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:31:39', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (25, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n,sum;\n    cin >> n;\n    sum=0;\n    for (int i=1 ; i<= n; i++){\n        sum+=i;\n    }\n    cout << sum;\n    return 0;\n}\n', 'C++', 'Wrong Answer', 8.0, 3, 4, 0.596, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.596, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:32:10', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (26, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    int n,sum;\n    cin >> n;\n    sum=0;\n    for (int i=1 ; i<= n; i++){\n        sum+=i;\n    }\n    cout << sum;\n}\n', 'C++', 'Wrong Answer', 8.0, 3, 4, 0.609, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.609, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.013, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:32:42', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (27, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    long n,sum;\n    cin >> n;\n    sum=0;\n    for (int i=1 ; i<= n; i++){\n        sum+=i;\n    }\n    cout << sum;\n}\n', 'C++', 'Wrong Answer', 8.0, 3, 4, 0.519, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.519, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.015, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "[Kết quả thực tế không hiển thị cho test ẩn]", "error": ""}]', '2026-10-15 08:33:02', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (28, 3, 4, '#include <iostream>\nusing namespace std;\n\nint main() {\n    long long n;\n    cin >> n;\n    long long sum = n * (n + 1) / 2;\n    \n    cout << sum;\n    return 0;\n}\n', 'C++', 'Accepted', 10.0, 4, 4, 0.511, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.511, "input": "5", "expected": "15", "actual": "15", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "1", "expected": "1", "actual": "1", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.012, "input": "[Test case ẩn]", "expected": "[Test case ẩn]", "actual": "", "error": ""}]', '2026-10-15 08:34:11', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (29, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.586, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.586, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.014, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.013, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-10-22 15:26:38', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (30, 3, 2, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            int n;\n            if (n % 2 == 0) cout << "CHAN";\n            else cout << "LE";\n            return 0;\n        }\n        ', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.0, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', '2026-10-22 15:26:38', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (31, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.521, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.521, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.009, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.008, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-10-22 15:26:40', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (32, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.561, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.561, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.005, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-10-22 15:28:13', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (33, 3, 2, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            int n;\n            if (n % 2 == 0) cout << "CHAN";\n            else cout << "LE";\n            return 0;\n        }\n        ', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.0, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', '2026-10-22 15:28:14', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (34, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.547, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.547, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.006, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-10-22 15:28:15', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (35, 3, 2, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            int n;\n            if (n % 2 == 0) cout << "CHAN";\n            else cout << "LE";\n            return 0;\n        }\n        ', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.0, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', '2026-11-06 04:06:31', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (36, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.612, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.612, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.011, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.012, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.012, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-11-06 04:06:39', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (37, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.414, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.414, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.01, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.008, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.01, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-11-06 04:07:40', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (38, 3, 2, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            int n;\n            if (n % 2 == 0) cout << "CHAN";\n            else cout << "LE";\n            return 0;\n        }\n        ', 'C++', 'Wrong Answer', 0.0, 0, 4, 0.0, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "8", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "13", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Wrong Answer", "execution_time": 0.0, "input": "0", "expected": "CHAN", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Wrong Answer", "execution_time": 0.0, "input": "-7", "expected": "LE", "actual": "", "error": "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu \'cin >>\' hoặc \'scanf\'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"}]', '2026-11-06 04:07:41', '{}', 0, 0.0, 'normal', '', NULL, '[]'),
  (39, 3, 1, '\n        #include <iostream>\n        using namespace std;\n        int main() {\n            long long a, b;\n            if (cin >> a >> b) {\n                cout << (a + b) << endl;\n            }\n            return 0;\n        }\n        ', 'C++', 'Accepted', 10.0, 4, 4, 0.467, '', '[{"test_index": 1, "is_hidden": false, "points": 2, "status": "Passed", "execution_time": 0.467, "input": "5 7", "expected": "12", "actual": "12", "error": ""}, {"test_index": 2, "is_hidden": false, "points": 3, "status": "Passed", "execution_time": 0.009, "input": "-10 25", "expected": "15", "actual": "15", "error": ""}, {"test_index": 3, "is_hidden": true, "points": 3, "status": "Passed", "execution_time": 0.007, "input": "1000000000 2000000000", "expected": "3000000000", "actual": "3000000000", "error": ""}, {"test_index": 4, "is_hidden": true, "points": 2, "status": "Passed", "execution_time": 0.062, "input": "-500 -700", "expected": "-1200", "actual": "-1200", "error": ""}]', '2026-11-06 04:07:43', '{}', 0, 0.0, 'normal', '', NULL, '[]');

-- --------------------------------------------------------
-- Table structure for `entrance_questions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `entrance_questions`;
CREATE TABLE IF NOT EXISTS `entrance_questions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `topic` VARCHAR(100) NOT NULL,
    `question_text` TEXT NOT NULL,
    `code_snippet` TEXT,
    `options_json` LONGTEXT NOT NULL,
    `correct_answer` INT NOT NULL,
    `explanation` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `entrance_questions` (15 records)
INSERT INTO `entrance_questions` (`id`, `topic`, `question_text`, `code_snippet`, `options_json`, `correct_answer`, `explanation`) VALUES
  (1, 'Biến và kiểu dữ liệu', 'Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?', '/* Khai bao bien x */ x = 3.1415926535;', '["int", "double", "char", "bool"]', 1, 'Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa).'),
  (2, 'Biến và kiểu dữ liệu', 'Đoạn mã sau in ra giá trị gì trên màn hình?', 'int a = 7;\nint b = 2;\ncout << a / b;', '["3.5", "3", "4", "Báo lỗi biên dịch"]', 1, 'Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3).'),
  (3, 'Nhập/xuất', 'Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?', 'int x;\ncin ?? x;', '["<<", ">>", "<=", ">="]', 1, 'Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin.'),
  (4, 'Nhập/xuất', 'Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?', 'cout << "Hello" ??', '[">> endl;", "<< endl;", "<< newline;", ">> return;"]', 1, 'endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<.'),
  (5, 'Toán tử', 'Toán tử \'%\' trong C++ thực hiện phép toán nào?', 'int r = 17 % 5;', '["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"]', 2, '17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2.'),
  (6, 'Toán tử', 'Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?', 'bool res = (5 > 3) && (2 >= 4);', '["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"]', 1, '(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false.'),
  (7, 'If/Else', 'Đoạn mã sau in ra kết quả gì?', 'int x = 10;\nif (x < 5) {\n    cout << "A";\n} else if (x < 15) {\n    cout << "B";\n} else {\n    cout << "C";\n}', '["A", "B", "C", "B C"]', 1, 'x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc.'),
  (8, 'If/Else', 'Câu lệnh điều kiện if sau đây sẽ in ra gì?', 'int a = 0;\nif (a == 5) {\n    cout << "Dung";\n} else {\n    cout << "Sai";\n}', '["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"]', 0, 'Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'.'),
  (9, 'Vòng lặp', 'Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?', 'for (int i = 0; i < 5; i++) {\n    cout << i << " ";\n}', '["4 lần", "5 lần", "6 lần", "Vô hạn lần"]', 1, 'Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần).'),
  (10, 'Vòng lặp', 'Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?', 'while (true) {\n    if (dieu_kien) break;\n}', '["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"]', 1, '\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất.'),
  (11, 'Mảng', 'Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:', 'int arr[10];', '["1 và 10", "0 và 9", "0 và 10", "1 và 9"]', 1, 'Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9].'),
  (12, 'Mảng', 'Giá trị của arr[2] sau đoạn code sau là bao nhiêu?', 'int arr[4] = {10, 20, 30, 40};\narr[2] += 5;', '["25", "35", "30", "45"]', 1, 'arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35.'),
  (13, 'Chuỗi', 'Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?', 'string s = "LapTrinh";', '["s.count()", "s.length()", "sizeof(s)", "s.elements()"]', 1, 'Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi.'),
  (14, 'Hàm', 'Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?', '?? inLoiChao() {\n    cout << "Xin chao!";\n}', '["null", "empty", "void", "none"]', 2, 'Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục).'),
  (15, 'Hàm', 'Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:', 'void hoanVi(int ??a, int ??b) { ... }', '["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"]', 0, 'Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc.');

-- --------------------------------------------------------
-- Table structure for `entrance_test_results`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `entrance_test_results`;
CREATE TABLE IF NOT EXISTS `entrance_test_results` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `total_score` FLOAT NOT NULL,
    `max_score` FLOAT NOT NULL,
    `percentage` FLOAT NOT NULL,
    `topic_breakdown_json` LONGTEXT NOT NULL,
    `weak_topics_json` LONGTEXT NOT NULL,
    `summary` TEXT NOT NULL,
    `details_json` LONGTEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_entranceresults_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `entrance_test_results` (17 records)
INSERT INTO `entrance_test_results` (`id`, `student_id`, `total_score`, `max_score`, `percentage`, `topic_breakdown_json`, `weak_topics_json`, `summary`, `created_at`, `details_json`) VALUES
  (1, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-15 06:56:06', '[]'),
  (2, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-15 06:57:36', '[]'),
  (3, 5, 4.0, 15.0, 26.7, '{"Biến và kiểu dữ liệu": 50.0, "Nhập/xuất": 100.0, "Toán tử": 50.0, "If/Else": 0.0, "Vòng lặp": 0.0, "Mảng": 0.0, "Chuỗi": 0.0, "Hàm": 0.0}', '["Biến và kiểu dữ liệu", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Chuỗi", "Hàm"]', 'Bạn đã nắm vững các chủ đề: Nhập/xuất. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm.', '2026-10-15 07:31:34', '[]'),
  (4, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-15 07:33:26', '[]'),
  (5, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-15 07:34:04', '[]'),
  (6, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-15 07:34:39', '[]'),
  (7, 4, 11.0, 15.0, 73.3, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 100.0, "Mảng": 50.0, "Chuỗi": 0.0, "Hàm": 50.0}', '["If/Else", "Mảng", "Chuỗi", "Hàm"]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Vòng lặp. Các kiến thức còn yếu cần củng cố gồm: If/Else, Mảng, Chuỗi, Hàm.', '2026-10-15 07:44:32', '[]'),
  (8, 3, 4.0, 15.0, 26.7, '{"Biến và kiểu dữ liệu": 0.0, "Nhập/xuất": 0.0, "Toán tử": 0.0, "If/Else": 50.0, "Vòng lặp": 0.0, "Mảng": 50.0, "Chuỗi": 100.0, "Hàm": 50.0}', '["Biến và kiểu dữ liệu", "Nhập/xuất", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Hàm"]', 'Bạn đã nắm vững các chủ đề: Chuỗi. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Hàm.', '2026-10-15 07:48:04', '[]'),
  (9, 3, 4.0, 15.0, 26.7, '{"Biến và kiểu dữ liệu": 0.0, "Nhập/xuất": 0.0, "Toán tử": 50.0, "If/Else": 0.0, "Vòng lặp": 0.0, "Mảng": 50.0, "Chuỗi": 100.0, "Hàm": 50.0}', '["Biến và kiểu dữ liệu", "Nhập/xuất", "Toán tử", "If/Else", "Vòng lặp", "Mảng", "Hàm"]', 'Bạn đã nắm vững các chủ đề: Chuỗi. Các kiến thức còn yếu cần củng cố gồm: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Hàm.', '2026-10-15 07:51:45', '[]'),
  (10, 4, 13.0, 15.0, 86.7, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 50.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '["If/Else", "Vòng lặp"]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Mảng, Chuỗi, Hàm. Các kiến thức còn yếu cần củng cố gồm: If/Else, Vòng lặp.', '2026-10-15 07:59:04', '[]'),
  (11, 4, 14.0, 15.0, 93.3, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '["If/Else"]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, Vòng lặp, Mảng, Chuỗi, Hàm. Các kiến thức còn yếu cần củng cố gồm: If/Else.', '2026-10-15 08:03:10', '[]'),
  (12, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-22 14:59:03', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (13, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-22 15:26:38', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (14, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-10-22 15:28:13', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (15, 7, 8.0, 15.0, 53.3, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 50.0, "Vòng lặp": 0.0, "Mảng": 0.0, "Chuỗi": 0.0, "Hàm": 50.0}', '["If/Else", "Vòng lặp", "Mảng", "Chuỗi", "Hàm"]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử. Các kiến thức còn yếu cần củng cố gồm: If/Else, Vòng lặp, Mảng, Chuỗi, Hàm.', '2026-10-23 04:54:52', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 2, "user_answer_text": "C", "correct_answer": 1, "correct_answer_text": "B", "is_correct": false, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 0, "user_answer_text": "4 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": false, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 0, "user_answer_text": "Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": false, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 0, "user_answer_text": "1 và 10", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": false, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 0, "user_answer_text": "25", "correct_answer": 1, "correct_answer_text": "35", "is_correct": false, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 3, "user_answer_text": "s.elements()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": false, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 1, "user_answer_text": "empty", "correct_answer": 2, "correct_answer_text": "void", "is_correct": false, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (16, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-11-06 04:06:29', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]'),
  (17, 3, 15.0, 15.0, 100.0, '{"Biến và kiểu dữ liệu": 100.0, "Nhập/xuất": 100.0, "Toán tử": 100.0, "If/Else": 100.0, "Vòng lặp": 100.0, "Mảng": 100.0, "Chuỗi": 100.0, "Hàm": 100.0}', '[]', 'Bạn đã nắm vững các chủ đề: Biến và kiểu dữ liệu, Nhập/xuất, Toán tử, If/Else, Vòng lặp, Mảng, Chuỗi, Hàm. Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!', '2026-11-06 04:07:40', '[{"question_id": 1, "topic": "Biến và kiểu dữ liệu", "question_text": "Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?", "code_snippet": "/* Khai bao bien x */ x = 3.1415926535;", "options": ["int", "double", "char", "bool"], "user_answer": 1, "user_answer_text": "double", "correct_answer": 1, "correct_answer_text": "double", "is_correct": true, "explanation": "Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa)."}, {"question_id": 2, "topic": "Biến và kiểu dữ liệu", "question_text": "Đoạn mã sau in ra giá trị gì trên màn hình?", "code_snippet": "int a = 7;\\nint b = 2;\\ncout << a / b;", "options": ["3.5", "3", "4", "Báo lỗi biên dịch"], "user_answer": 1, "user_answer_text": "3", "correct_answer": 1, "correct_answer_text": "3", "is_correct": true, "explanation": "Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3)."}, {"question_id": 3, "topic": "Nhập/xuất", "question_text": "Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?", "code_snippet": "int x;\\ncin ?? x;", "options": ["<<", ">>", "<=", ">="], "user_answer": 1, "user_answer_text": ">>", "correct_answer": 1, "correct_answer_text": ">>", "is_correct": true, "explanation": "Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin."}, {"question_id": 4, "topic": "Nhập/xuất", "question_text": "Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?", "code_snippet": "cout << \\"Hello\\" ??", "options": [">> endl;", "<< endl;", "<< newline;", ">> return;"], "user_answer": 1, "user_answer_text": "<< endl;", "correct_answer": 1, "correct_answer_text": "<< endl;", "is_correct": true, "explanation": "endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<."}, {"question_id": 5, "topic": "Toán tử", "question_text": "Toán tử \'%\' trong C++ thực hiện phép toán nào?", "code_snippet": "int r = 17 % 5;", "options": ["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"], "user_answer": 2, "user_answer_text": "Chia lấy phần dư", "correct_answer": 2, "correct_answer_text": "Chia lấy phần dư", "is_correct": true, "explanation": "17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2."}, {"question_id": 6, "topic": "Toán tử", "question_text": "Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?", "code_snippet": "bool res = (5 > 3) && (2 >= 4);", "options": ["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"], "user_answer": 1, "user_answer_text": "false (0)", "correct_answer": 1, "correct_answer_text": "false (0)", "is_correct": true, "explanation": "(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false."}, {"question_id": 7, "topic": "If/Else", "question_text": "Đoạn mã sau in ra kết quả gì?", "code_snippet": "int x = 10;\\nif (x < 5) {\\n    cout << \\"A\\";\\n} else if (x < 15) {\\n    cout << \\"B\\";\\n} else {\\n    cout << \\"C\\";\\n}", "options": ["A", "B", "C", "B C"], "user_answer": 1, "user_answer_text": "B", "correct_answer": 1, "correct_answer_text": "B", "is_correct": true, "explanation": "x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc."}, {"question_id": 8, "topic": "If/Else", "question_text": "Câu lệnh điều kiện if sau đây sẽ in ra gì?", "code_snippet": "int a = 0;\\nif (a == 5) {\\n    cout << \\"Dung\\";\\n} else {\\n    cout << \\"Sai\\";\\n}", "options": ["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"], "user_answer": 0, "user_answer_text": "Sai", "correct_answer": 0, "correct_answer_text": "Sai", "is_correct": true, "explanation": "Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'."}, {"question_id": 9, "topic": "Vòng lặp", "question_text": "Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?", "code_snippet": "for (int i = 0; i < 5; i++) {\\n    cout << i << \\" \\";\\n}", "options": ["4 lần", "5 lần", "6 lần", "Vô hạn lần"], "user_answer": 1, "user_answer_text": "5 lần", "correct_answer": 1, "correct_answer_text": "5 lần", "is_correct": true, "explanation": "Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần)."}, {"question_id": 10, "topic": "Vòng lặp", "question_text": "Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?", "code_snippet": "while (true) {\\n    if (dieu_kien) break;\\n}", "options": ["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"], "user_answer": 1, "user_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "correct_answer": 1, "correct_answer_text": "Thoát ngay lập tức khỏi vòng lặp chứa nó", "is_correct": true, "explanation": "\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất."}, {"question_id": 11, "topic": "Mảng", "question_text": "Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:", "code_snippet": "int arr[10];", "options": ["1 và 10", "0 và 9", "0 và 10", "1 và 9"], "user_answer": 1, "user_answer_text": "0 và 9", "correct_answer": 1, "correct_answer_text": "0 và 9", "is_correct": true, "explanation": "Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9]."}, {"question_id": 12, "topic": "Mảng", "question_text": "Giá trị của arr[2] sau đoạn code sau là bao nhiêu?", "code_snippet": "int arr[4] = {10, 20, 30, 40};\\narr[2] += 5;", "options": ["25", "35", "30", "45"], "user_answer": 1, "user_answer_text": "35", "correct_answer": 1, "correct_answer_text": "35", "is_correct": true, "explanation": "arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35."}, {"question_id": 13, "topic": "Chuỗi", "question_text": "Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?", "code_snippet": "string s = \\"LapTrinh\\";", "options": ["s.count()", "s.length()", "sizeof(s)", "s.elements()"], "user_answer": 1, "user_answer_text": "s.length()", "correct_answer": 1, "correct_answer_text": "s.length()", "is_correct": true, "explanation": "Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi."}, {"question_id": 14, "topic": "Hàm", "question_text": "Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?", "code_snippet": "?? inLoiChao() {\\n    cout << \\"Xin chao!\\";\\n}", "options": ["null", "empty", "void", "none"], "user_answer": 2, "user_answer_text": "void", "correct_answer": 2, "correct_answer_text": "void", "is_correct": true, "explanation": "Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục)."}, {"question_id": 15, "topic": "Hàm", "question_text": "Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:", "code_snippet": "void hoanVi(int ??a, int ??b) { ... }", "options": ["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"], "user_answer": 0, "user_answer_text": "Truyền tham chiếu bằng dấu &", "correct_answer": 0, "correct_answer_text": "Truyền tham chiếu bằng dấu &", "is_correct": true, "explanation": "Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc."}]');

-- --------------------------------------------------------
-- Table structure for `topic_weaknesses`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `topic_weaknesses`;
CREATE TABLE IF NOT EXISTS `topic_weaknesses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `topic` VARCHAR(100) NOT NULL,
    `mastery_percentage` FLOAT NOT NULL DEFAULT 0,
    `total_attempts` INT NOT NULL DEFAULT 0,
    `correct_attempts` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_topic_weaknesses` (`student_id`, `topic`),
    CONSTRAINT `fk_topicweaknesses_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `topic_weaknesses` (33 records)
INSERT INTO `topic_weaknesses` (`id`, `student_id`, `topic`, `mastery_percentage`, `total_attempts`, `correct_attempts`, `updated_at`) VALUES
  (1, 3, 'Nhập/xuất', 86.1, 36, 31, '2026-11-06 04:07:43'),
  (2, 3, 'Biến và kiểu dữ liệu', 100.0, 24, 20, '2026-11-06 04:07:40'),
  (4, 3, 'Toán tử', 100.0, 24, 21, '2026-11-06 04:07:40'),
  (5, 3, 'If/Else', 70.3, 37, 26, '2026-11-06 04:07:41'),
  (6, 3, 'Vòng lặp', 100.0, 30, 21, '2026-11-06 04:07:40'),
  (7, 3, 'Mảng', 100.0, 24, 22, '2026-11-06 04:07:40'),
  (8, 3, 'Chuỗi', 100.0, 12, 12, '2026-11-06 04:07:40'),
  (9, 3, 'Hàm', 100.0, 24, 22, '2026-11-06 04:07:40'),
  (19, 4, 'Nhập/xuất', 66.7, 9, 6, '2026-10-15 08:04:07'),
  (20, 1, 'Nhập/xuất', 0.0, 1, 0, '2026-10-15 07:20:09'),
  (21, 5, 'Biến và kiểu dữ liệu', 50.0, 2, 1, '2026-10-15 07:31:34'),
  (22, 5, 'Nhập/xuất', 50.0, 6, 3, '2026-10-15 07:38:19'),
  (23, 5, 'Toán tử', 50.0, 2, 1, '2026-10-15 07:31:34'),
  (24, 5, 'If/Else', 0.0, 2, 0, '2026-10-15 07:31:34'),
  (25, 5, 'Vòng lặp', 0.0, 2, 0, '2026-10-15 07:31:34'),
  (26, 5, 'Mảng', 0.0, 2, 0, '2026-10-15 07:31:34'),
  (27, 5, 'Chuỗi', 0.0, 1, 0, '2026-10-15 07:31:34'),
  (28, 5, 'Hàm', 0.0, 2, 0, '2026-10-15 07:31:34'),
  (60, 4, 'Biến và kiểu dữ liệu', 100.0, 6, 6, '2026-10-15 08:03:10'),
  (62, 4, 'Toán tử', 100.0, 6, 6, '2026-10-15 08:03:10'),
  (63, 4, 'If/Else', 50.0, 6, 3, '2026-10-15 08:03:10'),
  (64, 4, 'Vòng lặp', 100.0, 6, 5, '2026-10-15 08:03:10'),
  (65, 4, 'Mảng', 100.0, 6, 5, '2026-10-15 08:03:10'),
  (66, 4, 'Chuỗi', 100.0, 3, 2, '2026-10-15 08:03:10'),
  (67, 4, 'Hàm', 100.0, 6, 5, '2026-10-15 08:03:10'),
  (147, 7, 'Biến và kiểu dữ liệu', 100.0, 2, 2, '2026-10-23 04:54:52'),
  (148, 7, 'Nhập/xuất', 100.0, 2, 2, '2026-10-23 04:54:52'),
  (149, 7, 'Toán tử', 100.0, 2, 2, '2026-10-23 04:54:52'),
  (150, 7, 'If/Else', 50.0, 2, 1, '2026-10-23 04:54:52'),
  (151, 7, 'Vòng lặp', 0.0, 2, 0, '2026-10-23 04:54:52'),
  (152, 7, 'Mảng', 0.0, 2, 0, '2026-10-23 04:54:52'),
  (153, 7, 'Chuỗi', 0.0, 1, 0, '2026-10-23 04:54:52'),
  (154, 7, 'Hàm', 50.0, 2, 1, '2026-10-23 04:54:52');

-- --------------------------------------------------------
-- Table structure for `lesson_progress`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `lesson_progress`;
CREATE TABLE IF NOT EXISTS `lesson_progress` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `lesson_id` INT NOT NULL,
    `completed` TINYINT NOT NULL DEFAULT 1,
    `completed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_lesson_progress` (`student_id`, `lesson_id`),
    CONSTRAINT `fk_lessonprogress_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_lessonprogress_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No records for table `lesson_progress`

-- --------------------------------------------------------
-- Table structure for `course_enrollments`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `course_enrollments`;
CREATE TABLE IF NOT EXISTS `course_enrollments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `progress_percentage` FLOAT NOT NULL DEFAULT 0,
    `enrolled_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `last_accessed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_course_enrollments` (`student_id`, `course_id`),
    CONSTRAINT `fk_courseenrollments_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_courseenrollments_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `course_enrollments` (5 records)
INSERT INTO `course_enrollments` (`id`, `student_id`, `course_id`, `progress_percentage`, `enrolled_at`, `last_accessed_at`) VALUES
  (1, 3, 1, 0.0, '2026-10-15 07:24:03', '2026-10-15 08:42:45'),
  (2, 4, 1, 0.0, '2026-10-15 07:24:03', '2026-10-15 07:24:03'),
  (3, 5, 1, 0.0, '2026-10-15 07:32:42', '2026-10-15 07:32:42'),
  (4, 6, 1, 0.0, '2026-10-15 07:41:08', '2026-10-15 07:41:08'),
  (7, 7, 1, 0.0, '2026-10-23 04:51:27', '2026-10-23 04:51:27');

-- --------------------------------------------------------
-- Table structure for `forum_categories`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `forum_categories`;
CREATE TABLE IF NOT EXISTS `forum_categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NOT NULL,
    `icon` VARCHAR(50) DEFAULT 'message-square',
    `order_index` INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `forum_categories` (6 records)
INSERT INTO `forum_categories` (`id`, `name`, `slug`, `description`, `icon`, `order_index`) VALUES
  (1, 'C++', 'cpp', 'Thảo luận về cú pháp C++, con trỏ, STL, hướng đối tượng và tối ưu hóa mã nguồn', 'code', 1),
  (2, 'Thuật toán & Cấu trúc dữ liệu', 'algorithms', 'Trao đổi về giải thuật tìm kiếm, sắp xếp, quy hoạch động, cây và đồ thị', 'cpu', 2),
  (3, 'JavaScript & Web', 'javascript', 'Thảo luận phát triển giao diện web, tương tác DOM và lập trình JavaScript', 'globe', 3),
  (4, 'Python', 'python', 'Học tập Python cơ bản, xử lý dữ liệu và tự động hóa', 'terminal', 4),
  (5, 'Cơ sở dữ liệu', 'database', 'Truy vấn SQL, thiết kế cơ sở dữ liệu quan hệ và tối ưu bảng', 'database', 5),
  (6, 'Hỏi đáp chung & Thảo luận', 'general', 'Giao lưu học tập, kinh nghiệm rèn luyện kỹ năng code và giải đáp thắc mắc', 'message-circle', 6);

-- --------------------------------------------------------
-- Table structure for `forum_threads`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `forum_threads`;
CREATE TABLE IF NOT EXISTS `forum_threads` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `tags` VARCHAR(255) DEFAULT '',
    `status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `views_count` INT DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `moderation_status` VARCHAR(30) DEFAULT 'approved',
    `moderated_by` INT NULL,
    `reject_reason` TEXT NULL,
    `is_expert_answer` TINYINT DEFAULT 0,
    `course_id` INT NULL,
    `exercise_id` INT NULL,
    `lesson_id` INT NULL,
    CONSTRAINT `fk_threads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_threads_category` FOREIGN KEY (`category_id`) REFERENCES `forum_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `forum_threads` (2 records)
INSERT INTO `forum_threads` (`id`, `user_id`, `category_id`, `title`, `content`, `tags`, `status`, `views_count`, `created_at`, `moderation_status`, `moderated_by`, `reject_reason`, `is_expert_answer`, `course_id`, `exercise_id`, `lesson_id`) VALUES
  (1, 3, 1, 'Tại sao vòng lặp for của em bị chạy vô tận khi duyệt số nguyên?', 'Em viết đoạn mã kiểm tra chia hết từ n giảm về 0 nhưng chương trình cứ chạy mãi không dừng. Nhờ các anh chị chuyên gia xem giúp lỗi ở đâu ạ!\n\n```cpp\nfor (unsigned int i = 10; i >= 0; i--) {\n    cout << i << " ";\n}\n```', 'cpp,vòng-lặp,unsigned-int', 'active', 24, '2026-10-15 06:38:05', 'approved', NULL, '', 0, NULL, NULL, NULL),
  (2, 3, 2, 'Làm thế nào để phân biệt khi nào nên dùng DFS và khi nào nên dùng BFS?', 'Chào mọi người, em đang học đồ thị và phân vân bài toán tìm đường đi ngắn nhất không trọng số thì nên dùng BFS hay DFS và tại sao ạ?', 'thuật-toán,đồ-thị,bfs,dfs', 'active', 45, '2026-10-15 06:38:05', 'approved', NULL, '', 0, NULL, NULL, NULL);

-- --------------------------------------------------------
-- Table structure for `forum_replies`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `forum_replies`;
CREATE TABLE IF NOT EXISTS `forum_replies` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `thread_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `content` LONGTEXT NOT NULL,
    `is_accepted` TINYINT NOT NULL DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `moderation_status` VARCHAR(30) DEFAULT 'approved',
    `moderated_by` INT NULL,
    `reject_reason` TEXT NULL,
    `is_expert_answer` TINYINT DEFAULT 0,
    CONSTRAINT `fk_replies_thread` FOREIGN KEY (`thread_id`) REFERENCES `forum_threads` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_replies_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `forum_replies` (2 records)
INSERT INTO `forum_replies` (`id`, `thread_id`, `user_id`, `content`, `is_accepted`, `created_at`, `moderation_status`, `moderated_by`, `reject_reason`, `is_expert_answer`) VALUES
  (1, 1, 2, 'Chào bạn! Nguyên nhân là do bạn khai báo `unsigned int i`. Kiểu `unsigned int` là số nguyên không dấu nên giá trị nhỏ nhất của nó là 0. Khi i = 0 mà bị trừ đi 1 (i--), giá trị sẽ bị tràn số (underflow) nhảy lên giá trị cực đại 4294967295, do đó điều kiện `i >= 0` luôn luôn đúng! Để khắc phục, bạn chỉ cần đổi sang kiểu `int i` bình thường nhé.', 1, '2026-10-15 06:38:05', 'approved', NULL, '', 0),
  (2, 2, 2, 'Đối với bài toán tìm đường đi ngắn nhất trên đồ thị không trọng số (hoặc đồ thị mà tất cả các cạnh có trọng số bằng nhau là 1), bạn nên dùng **BFS (Tìm kiếm theo chiều rộng)**. Vì BFS duyệt theo từng mức (level), đỉnh nào được thăm trước chắc chắn sẽ có khoảng cách từ đỉnh xuất phát ngắn nhất.', 1, '2026-10-15 06:38:05', 'approved', NULL, '', 0);

-- --------------------------------------------------------
-- Table structure for `forum_likes`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `forum_likes`;
CREATE TABLE IF NOT EXISTS `forum_likes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `thread_id` INT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_forum_likes` (`user_id`, `thread_id`),
    CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_likes_thread` FOREIGN KEY (`thread_id`) REFERENCES `forum_threads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No records for table `forum_likes`

-- --------------------------------------------------------
-- Table structure for `saved_posts`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `saved_posts`;
CREATE TABLE IF NOT EXISTS `saved_posts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `thread_id` INT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_saved_posts` (`user_id`, `thread_id`),
    CONSTRAINT `fk_savedposts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_savedposts_thread` FOREIGN KEY (`thread_id`) REFERENCES `forum_threads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No records for table `saved_posts`

-- --------------------------------------------------------
-- Table structure for `forum_reports`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `forum_reports`;
CREATE TABLE IF NOT EXISTS `forum_reports` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `target_type` VARCHAR(30) NOT NULL,
    `target_id` INT NOT NULL,
    `reason` TEXT NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_reports_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No records for table `forum_reports`

-- --------------------------------------------------------
-- Table structure for `notifications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `link` VARCHAR(255) DEFAULT '',
    `is_read` TINYINT NOT NULL DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- No records for table `notifications`

-- --------------------------------------------------------
-- Table structure for `moderator_assignments`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `moderator_assignments`;
CREATE TABLE IF NOT EXISTS `moderator_assignments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `moderator_id` INT NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` INT NOT NULL,
    `assigned_by` INT NULL,
    `assigned_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `deadline` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'assigned',
    `notes` TEXT NULL,
    `completed_at` DATETIME NULL,
    CONSTRAINT `fk_modassign_moderator` FOREIGN KEY (`moderator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_modassign_assignedby` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `moderator_assignments` (2 records)
INSERT INTO `moderator_assignments` (`id`, `moderator_id`, `target_type`, `target_id`, `assigned_by`, `assigned_at`, `deadline`, `status`, `notes`, `completed_at`) VALUES
  (1, 2, 'exercise', 1, 1, '2026-11-10 15:05:21', NULL, 'completed', 'Kiểm tra lại bộ test cases và độ khó của bài toán Chẵn Lẻ', NULL),
  (2, 2, 'regrade_request', 1, 1, '2026-11-10 15:05:21', NULL, 'in_progress', 'Xem xét đơn xin phúc khảo của học viên student1', NULL);

-- --------------------------------------------------------
-- Table structure for `expert_reviews`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `expert_reviews`;
CREATE TABLE IF NOT EXISTS `expert_reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `expert_id` INT NOT NULL,
    `assignment_id` INT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` INT NOT NULL,
    `review_type` VARCHAR(50) NOT NULL DEFAULT 'content_moderation',
    `review_status` VARCHAR(30) NOT NULL,
    `comment` TEXT NOT NULL,
    `changes_requested` TEXT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_expertreviews_expert` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_expertreviews_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `moderator_assignments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `expert_reviews` (1 records)
INSERT INTO `expert_reviews` (`id`, `expert_id`, `target_type`, `target_id`, `review_status`, `comment`, `created_at`, `assignment_id`, `review_type`, `changes_requested`) VALUES
  (1, 2, 'exercise', 1, 'approved', 'Bài tập đạt chuẩn chất lượng, test cases đầy đủ các trường hợp biên.', '2026-11-10 15:05:21', 1, 'content_moderation', '');

-- --------------------------------------------------------
-- Table structure for `assessments`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `assessments`;
CREATE TABLE IF NOT EXISTS `assessments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `type` VARCHAR(50) NOT NULL DEFAULT 'entrance',
    `course_id` INT NULL,
    `duration_minutes` INT NOT NULL DEFAULT 30,
    `passing_percentage` FLOAT NOT NULL DEFAULT 60.0,
    `total_questions` INT NOT NULL DEFAULT 10,
    `status` VARCHAR(30) NOT NULL DEFAULT 'published',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_assessments_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `assessments` (2 records)
INSERT INTO `assessments` (`id`, `title`, `description`, `type`, `course_id`, `duration_minutes`, `passing_percentage`, `total_questions`, `status`, `created_at`) VALUES
  (1, 'Đánh giá Năng lực Lập trình Đầu vào (C++)', 'Bài kiểm tra 15 câu trắc nghiệm xác định năng lực và phân lớp học cho người mới bắt đầu.', 'entrance', NULL, 30, 60.0, 15, 'published', '2026-11-10 15:05:21'),
  (2, 'Trắc nghiệm Kiến thức Cơ bản C++ (Chương 1)', 'Kiểm tra mức độ nắm vững biến, kiểu dữ liệu và cú pháp nhập xuất căn bản.', 'chapter_quiz', 1, 15, 70.0, 5, 'published', '2026-11-10 15:05:21');

-- --------------------------------------------------------
-- Table structure for `assessment_questions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `assessment_questions`;
CREATE TABLE IF NOT EXISTS `assessment_questions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `assessment_id` INT NULL,
    `topic` VARCHAR(100) NOT NULL,
    `question_text` LONGTEXT NOT NULL,
    `code_snippet` TEXT NULL,
    `options_json` LONGTEXT NOT NULL,
    `correct_answer` INT NOT NULL,
    `explanation` TEXT NULL,
    `difficulty` VARCHAR(50) NOT NULL DEFAULT 'Cơ bản',
    `points` FLOAT NOT NULL DEFAULT 1.0,
    `order_index` INT NOT NULL DEFAULT 1,
    CONSTRAINT `fk_assessmentquestions_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `assessment_questions` (15 records)
INSERT INTO `assessment_questions` (`id`, `assessment_id`, `topic`, `question_text`, `code_snippet`, `options_json`, `correct_answer`, `explanation`, `difficulty`, `points`, `order_index`) VALUES
  (1, 1, 'Biến và kiểu dữ liệu', 'Để khai báo một biến lưu trữ số thực với độ chính xác kép trong C++, ta sử dụng từ khóa nào?', '/* Khai bao bien x */ x = 3.1415926535;', '["int", "double", "char", "bool"]', 1, 'Kiểu double trong C++ có kích thước 8 byte và lưu số thực độ chính xác kép (khoảng 15-17 chữ số có nghĩa).', 'Cơ bản', 1.0, 1),
  (2, 1, 'Biến và kiểu dữ liệu', 'Đoạn mã sau in ra giá trị gì trên màn hình?', 'int a = 7;\nint b = 2;\ncout << a / b;', '["3.5", "3", "4", "Báo lỗi biên dịch"]', 1, 'Khi chia hai số nguyên int với nhau trong C++, kết quả sẽ là phép chia lấy phần nguyên (7 / 2 = 3).', 'Cơ bản', 1.0, 2),
  (3, 1, 'Nhập/xuất', 'Toán tử nào được sử dụng cùng với đối tượng \'cin\' để đọc dữ liệu từ luồng đầu vào?', 'int x;\ncin ?? x;', '["<<", ">>", "<=", ">="]', 1, 'Toán tử trích xuất luồng >> (stream extraction operator) được dùng với cin.', 'Cơ bản', 1.0, 3),
  (4, 1, 'Nhập/xuất', 'Để in dữ liệu ra màn hình và sau đó xuống dòng mới, ta có thể dùng cú pháp nào?', 'cout << "Hello" ??', '[">> endl;", "<< endl;", "<< newline;", ">> return;"]', 1, 'endl chèn ký tự xuống dòng và xả bộ đệm (flush buffer) qua toán tử <<.', 'Cơ bản', 1.0, 4),
  (5, 1, 'Toán tử', 'Toán tử \'%\' trong C++ thực hiện phép toán nào?', 'int r = 17 % 5;', '["Tính phần trăm", "Chia lấy phần nguyên", "Chia lấy phần dư", "Lũy thừa"]', 2, '17 chia 5 được 3 dư 2, nên 17 % 5 bằng 2.', 'Cơ bản', 1.0, 5),
  (6, 1, 'Toán tử', 'Biểu thức logic \'(5 > 3) && (2 >= 4)\' trả về giá trị gì?', 'bool res = (5 > 3) && (2 >= 4);', '["true (1)", "false (0)", "Không xác định", "Lỗi cú pháp"]', 1, '(5 > 3) là true, nhưng (2 >= 4) là false. Phép toán && (VÀ) yêu cầu cả 2 vế đều đúng nên kết quả là false.', 'Cơ bản', 1.0, 6),
  (7, 1, 'If/Else', 'Đoạn mã sau in ra kết quả gì?', 'int x = 10;\nif (x < 5) {\n    cout << "A";\n} else if (x < 15) {\n    cout << "B";\n} else {\n    cout << "C";\n}', '["A", "B", "C", "B C"]', 1, 'x = 10 không nhỏ hơn 5, chuyển sang nhánh tiếp theo: 10 < 15 là đúng, nên in ra \'B\' và kết thúc.', 'Cơ bản', 1.0, 7),
  (8, 1, 'If/Else', 'Câu lệnh điều kiện if sau đây sẽ in ra gì?', 'int a = 0;\nif (a == 5) {\n    cout << "Dung";\n} else {\n    cout << "Sai";\n}', '["Sai", "Dung", "Báo lỗi biên dịch", "Không in gì"]', 0, 'Toán tử \'==\' là phép so sánh bằng. Biểu thức (a == 5) so sánh a (giá trị 0) với 5 cho kết quả false, do đó nhánh else được thực thi và in \'Sai\'.', 'Cơ bản', 1.0, 8),
  (9, 1, 'Vòng lặp', 'Vòng lặp sau thực hiện in ra màn hình bao nhiêu lần?', 'for (int i = 0; i < 5; i++) {\n    cout << i << " ";\n}', '["4 lần", "5 lần", "6 lần", "Vô hạn lần"]', 1, 'Biến i nhận các giá trị: 0, 1, 2, 3, 4 (tổng cộng 5 lần).', 'Cơ bản', 1.0, 9),
  (10, 1, 'Vòng lặp', 'Lệnh \'break\' đặt trong thân vòng lặp có tác dụng gì?', 'while (true) {\n    if (dieu_kien) break;\n}', '["Bỏ qua lần lặp hiện tại và sang lần lặp kế tiếp", "Thoát ngay lập tức khỏi vòng lặp chứa nó", "Khởi động lại vòng lặp từ đầu", "Dừng toàn bộ chương trình"]', 1, '\'break\' dùng để chấm dứt ngay lập tức vòng lặp trong cùng gần nó nhất.', 'Cơ bản', 1.0, 10),
  (11, 1, 'Mảng', 'Chỉ số (index) của phần tử đầu tiên và phần tử cuối cùng trong mảng \'int arr[10];\' lần lượt là:', 'int arr[10];', '["1 và 10", "0 và 9", "0 và 10", "1 và 9"]', 1, 'Trong C++, chỉ số mảng bắt đầu từ 0 đến N - 1, nên phần tử đầu là arr[0] và cuối là arr[9].', 'Cơ bản', 1.0, 11),
  (12, 1, 'Mảng', 'Giá trị của arr[2] sau đoạn code sau là bao nhiêu?', 'int arr[4] = {10, 20, 30, 40};\narr[2] += 5;', '["25", "35", "30", "45"]', 1, 'arr[2] ban đầu có giá trị 30. Sau phép cộng arr[2] += 5, giá trị trở thành 35.', 'Cơ bản', 1.0, 12),
  (13, 1, 'Chuỗi', 'Hàm hoặc phương thức nào dùng để lấy số lượng ký tự trong đối tượng \'string s\' của thư viện chuẩn C++?', 'string s = "LapTrinh";', '["s.count()", "s.length()", "sizeof(s)", "s.elements()"]', 1, 'Đối tượng string cung cấp phương thức s.length() hoặc s.size() để trả về độ dài chuỗi.', 'Cơ bản', 1.0, 13),
  (14, 1, 'Hàm', 'Từ khóa nào được dùng ở vị trí kiểu trả về nếu hàm không cần trả về bất kỳ giá trị nào?', '?? inLoiChao() {\n    cout << "Xin chao!";\n}', '["null", "empty", "void", "none"]', 2, 'Từ khóa \'void\' chỉ ra rằng hàm không trả về giá trị (thủ tục).', 'Cơ bản', 1.0, 14),
  (15, 1, 'Hàm', 'Để hàm có thể thay đổi trực tiếp giá trị của biến đối số truyền vào từ bên ngoài, ta cần:', 'void hoanVi(int ??a, int ??b) { ... }', '["Truyền tham chiếu bằng dấu &", "Truyền tham trị bình thường", "Sử dụng từ khóa const", "Khai báo kiểu float"]', 0, 'Truyền tham chiếu (pass by reference) bằng ký hiệu & cho phép hàm thao tác trực tiếp trên vùng nhớ của biến gốc.', 'Cơ bản', 1.0, 15);

-- --------------------------------------------------------
-- Table structure for `assessment_attempts`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `assessment_attempts`;
CREATE TABLE IF NOT EXISTS `assessment_attempts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `assessment_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    `attempt_number` INT NOT NULL DEFAULT 1,
    `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `end_time` DATETIME NULL,
    `duration_seconds` INT NULL,
    `total_score` FLOAT NOT NULL DEFAULT 0,
    `max_score` FLOAT NOT NULL DEFAULT 10,
    `percentage` FLOAT NOT NULL DEFAULT 0,
    `passed` TINYINT NOT NULL DEFAULT 0,
    `status` VARCHAR(30) NOT NULL DEFAULT 'in_progress',
    `answers_json` LONGTEXT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_attempts_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_attempts_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `assessment_attempts` (1 records)
INSERT INTO `assessment_attempts` (`id`, `assessment_id`, `student_id`, `attempt_number`, `start_time`, `end_time`, `duration_seconds`, `total_score`, `max_score`, `percentage`, `passed`, `status`, `answers_json`, `created_at`) VALUES
  (1, 1, 3, 1, '2026-11-10 15:05:21', NULL, NULL, 10.0, 15.0, 66.7, 1, 'completed', '{"answers": [0, 1, 2, 0, 1, 3, 2, 1, 0, 2]}', '2026-11-10 15:05:21');

-- --------------------------------------------------------
-- Table structure for `certificates`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `certificates`;
CREATE TABLE IF NOT EXISTS `certificates` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `certificate_code` VARCHAR(50) NOT NULL UNIQUE,
    `student_id` INT NOT NULL,
    `course_id` INT NULL,
    `assessment_id` INT NULL,
    `title` VARCHAR(255) NOT NULL,
    `final_score` FLOAT NULL,
    `issue_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expiry_date` DATETIME NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `cert_hash` VARCHAR(64) NULL,
    CONSTRAINT `fk_certificates_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_certificates_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_certificates_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `certificates` (1 records)
INSERT INTO `certificates` (`id`, `certificate_code`, `student_id`, `course_id`, `assessment_id`, `title`, `final_score`, `issue_date`, `expiry_date`, `status`, `cert_hash`) VALUES
  (1, 'CB-CERT-2026-0001', 3, 1, NULL, 'Chứng chỉ Hoàn thành Xuất sắc Khóa học C++ Cơ bản', 95.5, '2026-11-10 15:05:21', NULL, 'active', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');

-- --------------------------------------------------------
-- Table structure for `regrade_requests`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `regrade_requests`;
CREATE TABLE IF NOT EXISTS `regrade_requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `submission_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    `exercise_id` INT NOT NULL,
    `reason` LONGTEXT NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `reviewer_id` INT NULL,
    `reviewer_feedback` LONGTEXT NULL,
    `old_score` FLOAT NOT NULL,
    `new_score` FLOAT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` DATETIME NULL,
    CONSTRAINT `fk_regrade_submission` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_regrade_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_regrade_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_regrade_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `regrade_requests` (2 records)
INSERT INTO `regrade_requests` (`id`, `submission_id`, `student_id`, `exercise_id`, `reason`, `status`, `reviewer_id`, `reviewer_feedback`, `old_score`, `new_score`, `created_at`, `resolved_at`) VALUES
  (1, 1, 3, 1, 'Em thấy code của em đúng nhưng test case 2 bị báo Wrong Answer do thừa dấu xuống dòng.', 'in_review', 2, '', 8.0, NULL, '2026-11-10 15:05:21', NULL),
  (2, 2, 3, 2, 'Em xin phúc khảo vì em dùng cin >> a >> b thay vì scanf.', 'approved', 2, 'Đã xem xét và chấp nhận. Điểm cập nhật lại 10/10.', 5.0, 10.0, '2026-11-10 15:05:21', '2026-11-10 15:05:21');

-- --------------------------------------------------------
-- Table structure for `submission_events`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `submission_events`;
CREATE TABLE IF NOT EXISTS `submission_events` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `submission_id` INT NULL,
    `attempt_id` INT NULL,
    `student_id` INT NOT NULL,
    `exercise_id` INT NULL,
    `event_type` VARCHAR(50) NOT NULL,
    `event_data_json` LONGTEXT NULL,
    `ip_address` VARCHAR(45) NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_subevents_submission` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_subevents_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_subevents_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_subevents_attempt` FOREIGN KEY (`attempt_id`) REFERENCES `assessment_attempts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `submission_events` (2 records)
INSERT INTO `submission_events` (`id`, `submission_id`, `attempt_id`, `student_id`, `exercise_id`, `event_type`, `event_data_json`, `ip_address`, `created_at`) VALUES
  (1, 1, NULL, 3, 1, 'tab_switch', '{"duration_ms": 4200, "tab_title": "Google Search"}', '127.0.0.1', '2026-11-10 15:05:21'),
  (2, 1, NULL, 3, 1, 'paste_code', '{"characters_pasted": 85, "speed_wpm": 450}', '127.0.0.1', '2026-11-10 15:05:21');

-- --------------------------------------------------------
-- Table structure for `audit_logs`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `action` VARCHAR(100) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` INT NULL,
    `details` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_auditlogs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `audit_logs` (2 records)
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `target_type`, `target_id`, `details`, `created_at`) VALUES
  (1, 1, 'TOGGLE_USER_STATUS', 'user', 5, 'Changed status of Nha to locked', '2026-10-23 04:57:08'),
  (2, 1, 'TOGGLE_USER_STATUS', 'user', 5, 'Changed status of Nha to active', '2026-10-23 04:57:46');

-- --------------------------------------------------------
-- Table structure for `system_settings`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE IF NOT EXISTS `system_settings` (
    `key` VARCHAR(100) PRIMARY KEY,
    `value` TEXT NOT NULL,
    `description` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `system_settings` (5 records)
INSERT INTO `system_settings` (`key`, `value`, `description`) VALUES
  ('site_name', 'CodeBeginner', 'Tên nền tảng hiển thị'),
  ('site_description', 'Hệ thống hỗ trợ học và luyện tập lập trình C++ từ cơ bản đến nâng cao', 'Mô tả tóm tắt'),
  ('default_time_limit', '2.0', 'Thời gian chạy tối đa mặc định cho mỗi test case (giây)'),
  ('default_memory_limit', '128', 'Bộ nhớ tối đa cho phép (MB)'),
  ('supported_languages', 'C++ (g++ 10.3 / C++17)', 'Danh sách môi trường biên dịch hỗ trợ');

-- --------------------------------------------------------
-- Table structure for `exercise_rubrics`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `exercise_rubrics`;
CREATE TABLE IF NOT EXISTS `exercise_rubrics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `exercise_id` INT NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `max_points` FLOAT NOT NULL DEFAULT 25.0,
    `weight` FLOAT NOT NULL DEFAULT 1.0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_rubrics_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `exercise_rubrics` (6 records)
INSERT INTO `exercise_rubrics` (`id`, `exercise_id`, `name`, `description`, `max_points`, `weight`, `created_at`) VALUES
  (1, 1, 'Đọc dữ liệu đúng định dạng', 'Nhập đúng giá trị số nguyên n từ bàn phím', 30.0, 1.0, '2026-11-11 14:24:42'),
  (2, 1, 'Xử lý logic chẵn/lẻ chính xác', 'Sử dụng phép chia lấy dư n % 2 chuẩn xác', 40.0, 1.0, '2026-11-11 14:24:42'),
  (3, 1, 'In kết quả đúng định dạng', 'In đúng CHAN hoặc LE theo yêu cầu đề bài', 30.0, 1.0, '2026-11-11 14:24:42'),
  (4, 2, 'Nhập đúng hai số nguyên a, b', 'Đọc dữ liệu dòng đầu vào chính xác', 30.0, 1.0, '2026-11-11 14:24:42'),
  (5, 2, 'Tính toán tổng chính xác', 'Thực hiện phép cộng a + b không tràn số', 40.0, 1.0, '2026-11-11 14:24:42'),
  (6, 2, 'Xuất kết quả đúng định dạng', 'In ra giá trị tổng chuẩn xác', 30.0, 1.0, '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `course_reviews`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `course_reviews`;
CREATE TABLE IF NOT EXISTS `course_reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    `rating` INT NOT NULL,
    `comment` TEXT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'visible',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_course_reviews` (`course_id`, `student_id`),
    CONSTRAINT `fk_coursereviews_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_coursereviews_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `course_reviews` (1 records)
INSERT INTO `course_reviews` (`id`, `course_id`, `student_id`, `rating`, `comment`, `status`, `created_at`, `updated_at`) VALUES
  (1, 1, 3, 5, 'Khóa học C++ rất dễ hiểu cho người mới bắt đầu! Bài tập có máy chấm tự động siêu tiện.', 'visible', '2026-11-11 14:24:42', '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `learning_goals`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `learning_goals`;
CREATE TABLE IF NOT EXISTS `learning_goals` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `sessions_per_week` INT DEFAULT 3,
    `target_completion_date` DATE NULL,
    `reminder_time` VARCHAR(10) DEFAULT '19:00',
    `email_reminder_enabled` TINYINT DEFAULT 1,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_learning_goals` (`student_id`, `course_id`),
    CONSTRAINT `fk_learninggoals_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_learninggoals_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `learning_goals` (1 records)
INSERT INTO `learning_goals` (`id`, `student_id`, `course_id`, `sessions_per_week`, `target_completion_date`, `reminder_time`, `email_reminder_enabled`, `created_at`) VALUES
  (1, 3, 1, 4, NULL, '20:00', 1, '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `programming_topics`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `programming_topics`;
CREATE TABLE IF NOT EXISTS `programming_topics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `order_index` INT DEFAULT 1,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `programming_topics` (10 records)
INSERT INTO `programming_topics` (`id`, `name`, `description`, `status`, `order_index`, `created_at`) VALUES
  (1, 'Biến và kiểu dữ liệu', 'Khái niệm biến, hằng số, các kiểu dữ liệu nguyên thủy trong C++', 'active', 1, '2026-11-11 14:24:42'),
  (2, 'Nhập/xuất dữ liệu', 'Cú pháp cin, cout, định dạng dữ liệu vào ra', 'active', 2, '2026-11-11 14:24:42'),
  (3, 'Toán tử và biểu thức', 'Toán tử số học, so sánh, logic và độ ưu tiên toán tử', 'active', 3, '2026-11-11 14:24:42'),
  (4, 'Cấu trúc rẽ nhánh (If/Else)', 'Câu lệnh if, else if, else, toán tử 3 ngôi và switch case', 'active', 4, '2026-11-11 14:24:42'),
  (5, 'Vòng lặp (Loops)', 'Vòng lặp for, while, do-while, break và continue', 'active', 5, '2026-11-11 14:24:42'),
  (6, 'Mảng 1 chiều và 2 chiều', 'Khai báo mảng, duyệt phần tử, ma trận trong C++', 'active', 6, '2026-11-11 14:24:42'),
  (7, 'Chuỗi ký tự (Strings)', 'Xâu ký tự std::string, các hàm xử lý chuỗi', 'active', 7, '2026-11-11 14:24:42'),
  (8, 'Hàm và tham số (Functions)', 'Định nghĩa hàm, truyền tham trị và tham chiếu', 'active', 8, '2026-11-11 14:24:42'),
  (9, 'Đệ quy (Recursion)', 'Kỹ thuật đệ quy, điểm dừng và bài toán quay lui', 'active', 9, '2026-11-11 14:24:42'),
  (10, 'Con trỏ và cấp phát động', 'Địa chỉ ô nhớ, toán tử con trỏ *, &, new và delete', 'active', 10, '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `system_backups`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `system_backups`;
CREATE TABLE IF NOT EXISTS `system_backups` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `filename` VARCHAR(255) NOT NULL,
    `backup_type` VARCHAR(50) NOT NULL DEFAULT 'full',
    `file_size_bytes` BIGINT DEFAULT 0,
    `status` VARCHAR(30) NOT NULL DEFAULT 'success',
    `notes` TEXT NULL,
    `created_by` INT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_backups_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `system_backups` (1 records)
INSERT INTO `system_backups` (`id`, `filename`, `backup_type`, `file_size_bytes`, `status`, `notes`, `created_by`, `created_at`) VALUES
  (1, 'backup_codebeginner_init.sql', 'full', 170553, 'success', 'Bản sao lưu CSDL ban đầu trước khi nâng cấp chức năng.', NULL, '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `system_alerts`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `system_alerts`;
CREATE TABLE IF NOT EXISTS `system_alerts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `component` VARCHAR(50) NOT NULL,
    `severity` VARCHAR(30) NOT NULL DEFAULT 'warning',
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'open',
    `resolved_by` INT NULL,
    `resolved_at` DATETIME NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_alerts_user` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `system_alerts` (1 records)
INSERT INTO `system_alerts` (`id`, `component`, `severity`, `title`, `message`, `status`, `resolved_by`, `resolved_at`, `created_at`) VALUES
  (1, 'judge_service', 'normal', 'Máy chấm hoạt động bình thường', 'Tất cả 10 workers đang sẵn sàng nhận mã nguồn.', 'resolved', NULL, NULL, '2026-11-11 14:24:42');

-- --------------------------------------------------------
-- Table structure for `course_instructors`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `course_instructors`;
CREATE TABLE IF NOT EXISTS `course_instructors` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_id` INT NOT NULL,
    `instructor_id` INT NOT NULL,
    `assigned_lesson_ids_json` LONGTEXT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'instructor',
    `assigned_by` INT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_instructors_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_instructors_user` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_instructors_assignedby` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table `course_instructors` (1 records)
INSERT INTO `course_instructors` (`id`, `course_id`, `instructor_id`, `assigned_lesson_ids_json`, `role`, `assigned_by`, `created_at`) VALUES
  (1, 1, 2, '[]', 'lead_expert', 1, '2026-11-11 14:24:42');

SET FOREIGN_KEY_CHECKS = 1;