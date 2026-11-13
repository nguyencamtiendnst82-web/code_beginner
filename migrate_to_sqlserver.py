import os
import sys
import sqlite3
from datetime import datetime

SQLITE_DB = r"C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner.db"
OUTPUT_SQL = r"C:\Users\LENOVO\.gemini\antigravity\scratch\codebeginner\codebeginner_sqlserver.sql"

# 37 Bảng chuẩn cú pháp T-SQL Microsoft SQL Server (đã kiểm soát ON DELETE NO ACTION chống cycle)
SQLSERVER_TABLE_DEFINITIONS = [
    ("roles", """CREATE TABLE [dbo].[roles] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(50) NOT NULL UNIQUE,
    [display_name] NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(255) NULL,
    [permissions_json] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE()
);"""),

    ("users", """CREATE TABLE [dbo].[users] (
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
);"""),

    ("courses", """CREATE TABLE [dbo].[courses] (
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
);"""),

    ("chapters", """CREATE TABLE [dbo].[chapters] (
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
);"""),

    ("lessons", """CREATE TABLE [dbo].[lessons] (
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
);"""),

    ("exercises", """CREATE TABLE [dbo].[exercises] (
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
);"""),

    ("test_cases", """CREATE TABLE [dbo].[test_cases] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [exercise_id] INT NOT NULL,
    [input_data] NVARCHAR(MAX) NOT NULL,
    [expected_output] NVARCHAR(MAX) NOT NULL,
    [points] INT NOT NULL DEFAULT 2,
    [is_hidden] TINYINT NOT NULL DEFAULT 0,
    [order_index] INT NOT NULL DEFAULT 1,
    CONSTRAINT [fk_testcases_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE CASCADE
);"""),

    ("submissions", """CREATE TABLE [dbo].[submissions] (
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
);"""),

    ("entrance_questions", """CREATE TABLE [dbo].[entrance_questions] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [topic] NVARCHAR(100) NOT NULL,
    [question_text] NVARCHAR(MAX) NOT NULL,
    [code_snippet] NVARCHAR(MAX) NULL,
    [options_json] NVARCHAR(MAX) NOT NULL,
    [correct_answer] INT NOT NULL,
    [explanation] NVARCHAR(MAX) NULL
);"""),

    ("entrance_test_results", """CREATE TABLE [dbo].[entrance_test_results] (
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
);"""),

    ("topic_weaknesses", """CREATE TABLE [dbo].[topic_weaknesses] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [topic] NVARCHAR(100) NOT NULL,
    [mastery_percentage] FLOAT NOT NULL DEFAULT 0,
    [total_attempts] INT NOT NULL DEFAULT 0,
    [correct_attempts] INT NOT NULL DEFAULT 0,
    [updated_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_topic_weaknesses] UNIQUE ([student_id], [topic]),
    CONSTRAINT [fk_topicweaknesses_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);"""),

    ("lesson_progress", """CREATE TABLE [dbo].[lesson_progress] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [lesson_id] INT NOT NULL,
    [completed] TINYINT NOT NULL DEFAULT 1,
    [completed_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_lesson_progress] UNIQUE ([student_id], [lesson_id]),
    CONSTRAINT [fk_lessonprogress_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_lessonprogress_lesson] FOREIGN KEY ([lesson_id]) REFERENCES [dbo].[lessons] ([id]) ON DELETE NO ACTION
);"""),

    ("course_enrollments", """CREATE TABLE [dbo].[course_enrollments] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [progress_percentage] FLOAT NOT NULL DEFAULT 0,
    [enrolled_at] DATETIME2 DEFAULT GETDATE(),
    [last_accessed_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_course_enrollments] UNIQUE ([student_id], [course_id]),
    CONSTRAINT [fk_courseenrollments_student] FOREIGN KEY ([student_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_courseenrollments_course] FOREIGN KEY ([course_id]) REFERENCES [dbo].[courses] ([id]) ON DELETE NO ACTION
);"""),

    ("forum_categories", """CREATE TABLE [dbo].[forum_categories] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [slug] NVARCHAR(100) NOT NULL UNIQUE,
    [description] NVARCHAR(MAX) NOT NULL,
    [icon] NVARCHAR(50) DEFAULT 'message-square',
    [order_index] INT DEFAULT 1
);"""),

    ("forum_threads", """CREATE TABLE [dbo].[forum_threads] (
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
);"""),

    ("forum_replies", """CREATE TABLE [dbo].[forum_replies] (
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
);"""),

    ("forum_likes", """CREATE TABLE [dbo].[forum_likes] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [thread_id] INT NOT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_forum_likes] UNIQUE ([user_id], [thread_id]),
    CONSTRAINT [fk_likes_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_likes_thread] FOREIGN KEY ([thread_id]) REFERENCES [dbo].[forum_threads] ([id]) ON DELETE NO ACTION
);"""),

    ("saved_posts", """CREATE TABLE [dbo].[saved_posts] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [thread_id] INT NOT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [uq_saved_posts] UNIQUE ([user_id], [thread_id]),
    CONSTRAINT [fk_savedposts_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [fk_savedposts_thread] FOREIGN KEY ([thread_id]) REFERENCES [dbo].[forum_threads] ([id]) ON DELETE NO ACTION
);"""),

    ("forum_reports", """CREATE TABLE [dbo].[forum_reports] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [target_type] NVARCHAR(30) NOT NULL,
    [target_id] INT NOT NULL,
    [reason] NVARCHAR(MAX) NOT NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'pending',
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_reports_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);"""),

    ("notifications", """CREATE TABLE [dbo].[notifications] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL,
    [title] NVARCHAR(255) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [link] NVARCHAR(255) DEFAULT '',
    [is_read] TINYINT NOT NULL DEFAULT 0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_notifications_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);"""),

    ("moderator_assignments", """CREATE TABLE [dbo].[moderator_assignments] (
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
);"""),

    ("expert_reviews", """CREATE TABLE [dbo].[expert_reviews] (
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
);"""),

    ("assessments", """CREATE TABLE [dbo].[assessments] (
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
);"""),

    ("assessment_questions", """CREATE TABLE [dbo].[assessment_questions] (
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
);"""),

    ("assessment_attempts", """CREATE TABLE [dbo].[assessment_attempts] (
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
);"""),

    ("certificates", """CREATE TABLE [dbo].[certificates] (
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
);"""),

    ("regrade_requests", """CREATE TABLE [dbo].[regrade_requests] (
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
);"""),

    ("submission_events", """CREATE TABLE [dbo].[submission_events] (
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
);"""),

    ("audit_logs", """CREATE TABLE [dbo].[audit_logs] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NULL,
    [action] NVARCHAR(100) NOT NULL,
    [target_type] NVARCHAR(50) NOT NULL,
    [target_id] INT NULL,
    [details] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_auditlogs_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL
);"""),

    ("system_settings", """CREATE TABLE [dbo].[system_settings] (
    [key] NVARCHAR(100) PRIMARY KEY,
    [value] NVARCHAR(MAX) NOT NULL,
    [description] NVARCHAR(MAX) NULL
);"""),

    ("exercise_rubrics", """CREATE TABLE [dbo].[exercise_rubrics] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [exercise_id] INT NOT NULL,
    [name] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [max_points] FLOAT NOT NULL DEFAULT 25.0,
    [weight] FLOAT NOT NULL DEFAULT 1.0,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_rubrics_exercise] FOREIGN KEY ([exercise_id]) REFERENCES [dbo].[exercises] ([id]) ON DELETE CASCADE
);"""),

    ("course_reviews", """CREATE TABLE [dbo].[course_reviews] (
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
);"""),

    ("learning_goals", """CREATE TABLE [dbo].[learning_goals] (
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
);"""),

    ("programming_topics", """CREATE TABLE [dbo].[programming_topics] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL UNIQUE,
    [description] NVARCHAR(255) NULL,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'active',
    [order_index] INT DEFAULT 1,
    [created_at] DATETIME2 DEFAULT GETDATE()
);"""),

    ("system_backups", """CREATE TABLE [dbo].[system_backups] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [filename] NVARCHAR(255) NOT NULL,
    [backup_type] NVARCHAR(50) NOT NULL DEFAULT 'full',
    [file_size_bytes] BIGINT DEFAULT 0,
    [status] NVARCHAR(30) NOT NULL DEFAULT 'success',
    [notes] NVARCHAR(MAX) NULL,
    [created_by] INT NULL,
    [created_at] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [fk_backups_user] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL
);"""),

    ("system_alerts", """CREATE TABLE [dbo].[system_alerts] (
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
);"""),

    ("course_instructors", """CREATE TABLE [dbo].[course_instructors] (
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
);""")
]

def escape_sqlserver_value(val):
    if val is None:
        return "NULL"
    elif isinstance(val, (int, float)):
        return str(val)
    elif isinstance(val, bool):
        return "1" if val else "0"
    else:
        s = str(val)
        s = s.replace("'", "''")
        return f"N'{s}'"

def generate_sqlserver_dump():
    if not os.path.exists(SQLITE_DB):
        print(f"Error: SQLite database {SQLITE_DB} does not exist.")
        return

    conn = sqlite3.connect(SQLITE_DB)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    lines = []
    lines.append("-- ========================================================")
    lines.append("-- CODEBEGINNER PLATFORM - COMPLETE MICROSOFT SQL SERVER SCHEMA & DATA")
    lines.append(f"-- Generated At: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- Compatible with SQL Server 2017+, 2019+, 2022+, Azure SQL")
    lines.append(f"-- Total Tables: {len(SQLSERVER_TABLE_DEFINITIONS)}")
    lines.append("-- ========================================================")
    lines.append("")
    lines.append("USE [master];")
    lines.append("GO")
    lines.append("")
    lines.append("IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'codebeginner')")
    lines.append("BEGIN")
    lines.append("    CREATE DATABASE [codebeginner] COLLATE Vietnamese_CI_AS;")
    lines.append("END")
    lines.append("GO")
    lines.append("")
    lines.append("USE [codebeginner];")
    lines.append("GO")
    lines.append("")

    for table_name, create_sql in SQLSERVER_TABLE_DEFINITIONS:
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"-- Table structure for [{table_name}]")
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"IF OBJECT_ID(N'[dbo].[{table_name}]', N'U') IS NOT NULL DROP TABLE [dbo].[{table_name}];")
        lines.append("GO")
        lines.append(create_sql)
        lines.append("GO")
        lines.append("")

        cursor.execute(f"SELECT * FROM `{table_name}`")
        rows = cursor.fetchall()

        if rows:
            columns = [desc[0] for desc in cursor.description]
            col_list_str = ", ".join([f"[{c}]" for c in columns])

            lines.append(f"-- Dumping data for table [{table_name}] ({len(rows)} records)")
            has_identity = (table_name != "system_settings")
            if has_identity:
                lines.append(f"SET IDENTITY_INSERT [dbo].[{table_name}] ON;")
                lines.append("GO")
            
            batch_size = 50
            for i in range(0, len(rows), batch_size):
                batch = rows[i:i + batch_size]
                val_rows = []
                for row in batch:
                    val_strs = [escape_sqlserver_value(row[c]) for c in columns]
                    val_rows.append(f"  ({', '.join(val_strs)})")
                insert_stmt = f"INSERT INTO [dbo].[{table_name}] ({col_list_str}) VALUES\n" + ",\n".join(val_rows) + ";"
                lines.append(insert_stmt)
                lines.append("GO")
            
            if has_identity:
                lines.append(f"SET IDENTITY_INSERT [dbo].[{table_name}] OFF;")
                lines.append("GO")
            lines.append("")
        else:
            lines.append(f"-- No records for table [{table_name}]")
            lines.append("")

    conn.close()

    full_sql = "\n".join(lines)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as f:
        f.write(full_sql)

    print(f"[*] Exported successfully to: {OUTPUT_SQL}")
    print(f"[*] Total file size: {len(full_sql.encode('utf-8')):,} bytes")
    return OUTPUT_SQL

def migrate_directly_to_sqlserver():
    """Tự động kết nối tới SQL Server localhost\\SQLEXPRESS05 và thực thi trực tiếp"""
    try:
        import pyodbc
    except ImportError:
        print("[!] pyodbc is not installed. Please run: pip install pyodbc")
        return False

    server_conn_str = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost\\SQLEXPRESS05;"
        "DATABASE=master;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    print("[*] Connecting to SQL Server (localhost\\SQLEXPRESS05)...")
    try:
        conn = pyodbc.connect(server_conn_str, autocommit=True, timeout=5)
        cur = conn.cursor()
        print("[*] Ensuring database [codebeginner] exists...")
        cur.execute("IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'codebeginner') CREATE DATABASE [codebeginner] COLLATE Vietnamese_CI_AS;")
        conn.close()

        # Connect to codebeginner db
        db_conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "SERVER=localhost\\SQLEXPRESS05;"
            "DATABASE=codebeginner;"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;"
        )
        conn = pyodbc.connect(db_conn_str, autocommit=True, timeout=5)
        cur = conn.cursor()

        print("[*] Creating 37 tables and importing data directly into SQL Server...")
        
        sq_conn = sqlite3.connect(SQLITE_DB)
        sq_conn.row_factory = sqlite3.Row
        sq_cur = sq_conn.cursor()

        # Disable all constraints before dropping
        cur.execute("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'")
        for table_name, _ in reversed(SQLSERVER_TABLE_DEFINITIONS):
            cur.execute(f"IF OBJECT_ID(N'[dbo].[{table_name}]', N'U') IS NOT NULL DROP TABLE [dbo].[{table_name}];")

        # Create tables and insert data
        for table_name, create_sql in SQLSERVER_TABLE_DEFINITIONS:
            cur.execute(create_sql)

            sq_cur.execute(f"SELECT * FROM `{table_name}`")
            rows = sq_cur.fetchall()
            if rows:
                cols = [desc[0] for desc in sq_cur.description]
                col_names_str = ", ".join([f"[{c}]" for c in cols])
                placeholders = ", ".join(["?" for _ in cols])
                
                # Check if table has IDENTITY
                has_identity = (table_name != "system_settings")
                if has_identity:
                    cur.execute(f"SET IDENTITY_INSERT [dbo].[{table_name}] ON;")
                for r in rows:
                    val_tuple = tuple(r[c] for c in cols)
                    cur.execute(f"INSERT INTO [dbo].[{table_name}] ({col_names_str}) VALUES ({placeholders})", val_tuple)
                if has_identity:
                    cur.execute(f"SET IDENTITY_INSERT [dbo].[{table_name}] OFF;")

        sq_conn.close()
        conn.close()
        print("[*] Direct SQL Server migration of 37 tables completed successfully!")
        return True

    except Exception as e:
        print(f"[!] Migration to SQL Server failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    generate_sqlserver_dump()
    migrate_directly_to_sqlserver()