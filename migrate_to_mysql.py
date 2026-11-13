import os
import sys
import sqlite3
from datetime import datetime

SQLITE_DB = r"C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner.db"
OUTPUT_SQL = r"C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner_mysql.sql"

TABLE_DEFINITIONS = [
    ("roles", """CREATE TABLE IF NOT EXISTS `roles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `display_name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) NULL,
    `permissions_json` LONGTEXT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("users", """CREATE TABLE IF NOT EXISTS `users` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("courses", """CREATE TABLE IF NOT EXISTS `courses` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("chapters", """CREATE TABLE IF NOT EXISTS `chapters` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("lessons", """CREATE TABLE IF NOT EXISTS `lessons` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("exercises", """CREATE TABLE IF NOT EXISTS `exercises` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("test_cases", """CREATE TABLE IF NOT EXISTS `test_cases` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `exercise_id` INT NOT NULL,
    `input_data` LONGTEXT NOT NULL,
    `expected_output` LONGTEXT NOT NULL,
    `points` INT NOT NULL DEFAULT 2,
    `is_hidden` TINYINT NOT NULL DEFAULT 0,
    `order_index` INT NOT NULL DEFAULT 1,
    CONSTRAINT `fk_testcases_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("submissions", """CREATE TABLE IF NOT EXISTS `submissions` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("entrance_questions", """CREATE TABLE IF NOT EXISTS `entrance_questions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `topic` VARCHAR(100) NOT NULL,
    `question_text` TEXT NOT NULL,
    `code_snippet` TEXT,
    `options_json` LONGTEXT NOT NULL,
    `correct_answer` INT NOT NULL,
    `explanation` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("entrance_test_results", """CREATE TABLE IF NOT EXISTS `entrance_test_results` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("topic_weaknesses", """CREATE TABLE IF NOT EXISTS `topic_weaknesses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `topic` VARCHAR(100) NOT NULL,
    `mastery_percentage` FLOAT NOT NULL DEFAULT 0,
    `total_attempts` INT NOT NULL DEFAULT 0,
    `correct_attempts` INT NOT NULL DEFAULT 0,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_topic_weaknesses` (`student_id`, `topic`),
    CONSTRAINT `fk_topicweaknesses_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("lesson_progress", """CREATE TABLE IF NOT EXISTS `lesson_progress` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `lesson_id` INT NOT NULL,
    `completed` TINYINT NOT NULL DEFAULT 1,
    `completed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_lesson_progress` (`student_id`, `lesson_id`),
    CONSTRAINT `fk_lessonprogress_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_lessonprogress_lesson` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("course_enrollments", """CREATE TABLE IF NOT EXISTS `course_enrollments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `progress_percentage` FLOAT NOT NULL DEFAULT 0,
    `enrolled_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `last_accessed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_course_enrollments` (`student_id`, `course_id`),
    CONSTRAINT `fk_courseenrollments_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_courseenrollments_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("forum_categories", """CREATE TABLE IF NOT EXISTS `forum_categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NOT NULL,
    `icon` VARCHAR(50) DEFAULT 'message-square',
    `order_index` INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("forum_threads", """CREATE TABLE IF NOT EXISTS `forum_threads` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("forum_replies", """CREATE TABLE IF NOT EXISTS `forum_replies` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("forum_likes", """CREATE TABLE IF NOT EXISTS `forum_likes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `thread_id` INT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_forum_likes` (`user_id`, `thread_id`),
    CONSTRAINT `fk_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_likes_thread` FOREIGN KEY (`thread_id`) REFERENCES `forum_threads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("saved_posts", """CREATE TABLE IF NOT EXISTS `saved_posts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `thread_id` INT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_saved_posts` (`user_id`, `thread_id`),
    CONSTRAINT `fk_savedposts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_savedposts_thread` FOREIGN KEY (`thread_id`) REFERENCES `forum_threads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("forum_reports", """CREATE TABLE IF NOT EXISTS `forum_reports` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `target_type` VARCHAR(30) NOT NULL,
    `target_id` INT NOT NULL,
    `reason` TEXT NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'pending',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_reports_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("notifications", """CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `link` VARCHAR(255) DEFAULT '',
    `is_read` TINYINT NOT NULL DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("moderator_assignments", """CREATE TABLE IF NOT EXISTS `moderator_assignments` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("expert_reviews", """CREATE TABLE IF NOT EXISTS `expert_reviews` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("assessments", """CREATE TABLE IF NOT EXISTS `assessments` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("assessment_questions", """CREATE TABLE IF NOT EXISTS `assessment_questions` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("assessment_attempts", """CREATE TABLE IF NOT EXISTS `assessment_attempts` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("certificates", """CREATE TABLE IF NOT EXISTS `certificates` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("regrade_requests", """CREATE TABLE IF NOT EXISTS `regrade_requests` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("submission_events", """CREATE TABLE IF NOT EXISTS `submission_events` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("audit_logs", """CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `action` VARCHAR(100) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` INT NULL,
    `details` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_auditlogs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("system_settings", """CREATE TABLE IF NOT EXISTS `system_settings` (
    `key` VARCHAR(100) PRIMARY KEY,
    `value` TEXT NOT NULL,
    `description` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("exercise_rubrics", """CREATE TABLE IF NOT EXISTS `exercise_rubrics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `exercise_id` INT NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `max_points` FLOAT NOT NULL DEFAULT 25.0,
    `weight` FLOAT NOT NULL DEFAULT 1.0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_rubrics_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("course_reviews", """CREATE TABLE IF NOT EXISTS `course_reviews` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("learning_goals", """CREATE TABLE IF NOT EXISTS `learning_goals` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("programming_topics", """CREATE TABLE IF NOT EXISTS `programming_topics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'active',
    `order_index` INT DEFAULT 1,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("system_backups", """CREATE TABLE IF NOT EXISTS `system_backups` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `filename` VARCHAR(255) NOT NULL,
    `backup_type` VARCHAR(50) NOT NULL DEFAULT 'full',
    `file_size_bytes` BIGINT DEFAULT 0,
    `status` VARCHAR(30) NOT NULL DEFAULT 'success',
    `notes` TEXT NULL,
    `created_by` INT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_backups_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("system_alerts", """CREATE TABLE IF NOT EXISTS `system_alerts` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""),

    ("course_instructors", """CREATE TABLE IF NOT EXISTS `course_instructors` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;""")
]

def escape_mysql_value(val):
    if val is None:
        return "NULL"
    elif isinstance(val, (int, float)):
        return str(val)
    elif isinstance(val, bool):
        return "1" if val else "0"
    else:
        s = str(val)
        s = s.replace("\\", "\\\\")
        s = s.replace("'", "\\'")
        s = s.replace("\n", "\\n")
        s = s.replace("\r", "\\r")
        return f"'{s}'"

def generate_mysql_dump():
    if not os.path.exists(SQLITE_DB):
        print(f"Error: SQLite database {SQLITE_DB} does not exist.")
        return

    conn = sqlite3.connect(SQLITE_DB)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    lines = []
    lines.append("-- ========================================================")
    lines.append("-- CODEBEGINNER PLATFORM - COMPLETE MYSQL DATABASE DUMP")
    lines.append(f"-- Generated At: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- Compatible with MySQL 5.7+, 8.0+ and MariaDB 10+")
    lines.append(f"-- Total Tables: {len(TABLE_DEFINITIONS)}")
    lines.append("-- ========================================================")
    lines.append("")
    lines.append("SET FOREIGN_KEY_CHECKS = 0;")
    lines.append("SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';")
    lines.append("SET NAMES utf8mb4;")
    lines.append("")
    lines.append("CREATE DATABASE IF NOT EXISTS `codebeginner` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    lines.append("USE `codebeginner`;")
    lines.append("")

    for table_name, create_sql in TABLE_DEFINITIONS:
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"-- Table structure for `{table_name}`")
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"DROP TABLE IF EXISTS `{table_name}`;")
        lines.append(create_sql)
        lines.append("")

        cursor.execute(f"SELECT * FROM `{table_name}`")
        rows = cursor.fetchall()

        if rows:
            columns = [desc[0] for desc in cursor.description]
            col_list_str = ", ".join([f"`{c}`" for c in columns])

            lines.append(f"-- Dumping data for table `{table_name}` ({len(rows)} records)")
            lines.append(f"INSERT INTO `{table_name}` ({col_list_str}) VALUES")

            val_rows = []
            for row in rows:
                val_strs = [escape_mysql_value(row[c]) for c in columns]
                val_rows.append(f"  ({', '.join(val_strs)})")

            lines.append(",\n".join(val_rows) + ";")
            lines.append("")
        else:
            lines.append(f"-- No records for table `{table_name}`")
            lines.append("")

    lines.append("SET FOREIGN_KEY_CHECKS = 1;")

    conn.close()

    full_sql = "\n".join(lines)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as f:
        f.write(full_sql)

    print(f"[*] Exported successfully to: {OUTPUT_SQL}")
    print(f"[*] Total file size: {len(full_sql.encode('utf-8')):,} bytes")
    return OUTPUT_SQL

if __name__ == "__main__":
    generate_mysql_dump()
