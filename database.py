import sqlite3
import os
import json
import re
import time
import decimal
from datetime import datetime, date

try:
    import pymysql
    import pymysql.cursors
    HAS_PYMYSQL = True
except ImportError:
    HAS_PYMYSQL = False

try:
    import pyodbc
    HAS_PYODBC = True
except ImportError:
    HAS_PYODBC = False

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "codebeginner.db")
CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "db_config.json")

_MYSQL_WARNED = False
_LAST_MYSQL_FAIL_TIME = 0
_SQLSERVER_WARNED = False
_LAST_SQLSERVER_FAIL_TIME = 0

def load_db_config():
    default_config = {
        "db_type": "sqlserver",
        "sqlserver": {
            "server": "localhost\\SQLEXPRESS05",
            "database": "codebeginner",
            "trusted_connection": "yes",
            "driver": "ODBC Driver 17 for SQL Server"
        },
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
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                loaded = json.load(f)
                default_config.update(loaded)
        except Exception:
            pass
    return default_config

def _sanitize_val(v):
    if isinstance(v, (datetime, date)):
        return v.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(v, decimal.Decimal):
        return float(v)
    return v

class MySQLRow(dict):
    """
    Adapter row hỗ trợ cả truy cập theo tên cột (row['username'])
    và theo vị trí chỉ số (row[0]), tương đương sqlite3.Row.
    """
    def __init__(self, data_dict, description=None):
        sanitized = {k: _sanitize_val(v) for k, v in data_dict.items()}
        super().__init__(sanitized)
        self._keys = [col[0] for col in description] if description else list(sanitized.keys())

    def __getitem__(self, item):
        if isinstance(item, int):
            key = self._keys[item]
            return super().__getitem__(key)
        return super().__getitem__(item)

class MySQLCursorWrapper:
    """
    Wrapper cho PyMySQL cursor:
    - Tự động chuyển đổi placeholder '?' sang '%s'
    - Trả về đối tượng MySQLRow tương thích 100% với sqlite3.Row
    - Hỗ trợ lastrowid, rowcount, description
    """
    def __init__(self, cursor):
        self._cursor = cursor

    @property
    def lastrowid(self):
        return self._cursor.lastrowid

    @property
    def rowcount(self):
        return self._cursor.rowcount

    @property
    def description(self):
        return self._cursor.description

    def _convert_query(self, query, params):
        if params is not None and len(params) > 0 and '?' in query:
            parts = query.split('?')
            escaped_parts = [p.replace('%', '%%') for p in parts]
            return '%s'.join(escaped_parts)
        return query

    def execute(self, query, params=None):
        conv_query = self._convert_query(query, params)
        if params is not None:
            if not isinstance(params, (tuple, list)):
                params = (params,)
            self._cursor.execute(conv_query, params)
        else:
            self._cursor.execute(conv_query)
        return self

    def executemany(self, query, seq_of_params):
        if seq_of_params and '?' in query:
            parts = query.split('?')
            escaped_parts = [p.replace('%', '%%') for p in parts]
            conv_query = '%s'.join(escaped_parts)
            self._cursor.executemany(conv_query, seq_of_params)
        else:
            self._cursor.executemany(query, seq_of_params)
        return self

    def fetchone(self):
        row = self._cursor.fetchone()
        if row is None:
            return None
        return MySQLRow(row, self._cursor.description)

    def fetchall(self):
        rows = self._cursor.fetchall()
        if not rows:
            return []
        desc = self._cursor.description
        return [MySQLRow(r, desc) for r in rows]

    def fetchmany(self, size=None):
        rows = self._cursor.fetchmany(size)
        if not rows:
            return []
        desc = self._cursor.description
        return [MySQLRow(r, desc) for r in rows]

    def close(self):
        self._cursor.close()

class MySQLConnectionWrapper:
    """
    Wrapper cho PyMySQL connection:
    - Cung cấp phương thức execute() trực tiếp tương thích sqlite3.Connection
    - Hỗ trợ commit(), rollback(), close()
    """
    def __init__(self, raw_conn):
        self._conn = raw_conn

    def cursor(self):
        return MySQLCursorWrapper(self._conn.cursor())

    def commit(self):
        self._conn.commit()

    def rollback(self):
        self._conn.rollback()

    def close(self):
        self._conn.close()

    def execute(self, query, params=None):
        cur = self.cursor()
        cur.execute(query, params)
        return cur

class SQLServerRow(dict):
    """
    Adapter row hỗ trợ cả truy cập theo tên cột (row['username'])
    và theo vị trí chỉ số (row[0]), tương đương sqlite3.Row.
    """
    def __init__(self, data_dict, description=None):
        sanitized = {k: _sanitize_val(v) for k, v in data_dict.items()}
        super().__init__(sanitized)
        self._keys = [col[0] for col in description] if description else list(sanitized.keys())

    def __getitem__(self, item):
        if isinstance(item, int):
            key = self._keys[item]
            return super().__getitem__(key)
        return super().__getitem__(item)

class SQLServerCursorWrapper:
    """
    Wrapper cho pyodbc cursor:
    - Tự động chuyển đổi cú pháp LIMIT N sang T-SQL OFFSET FETCH
    - Trả về đối tượng SQLServerRow tương thích 100% với sqlite3.Row
    - Tự động lấy @@IDENTITY cho câu lệnh INSERT
    """
    def __init__(self, cursor):
        self._cursor = cursor
        self._lastrowid = None

    @property
    def lastrowid(self):
        return self._lastrowid

    @property
    def rowcount(self):
        return self._cursor.rowcount

    @property
    def description(self):
        return self._cursor.description

    def _transform(self, query):
        q = query
        if "LIMIT" in q.upper():
            pattern = re.compile(
                r'\bORDER\s+BY\s+((?:(?!\bORDER\s+BY\b|\bLIMIT\b)[\s\S])+?)\s+LIMIT\s+(\d+)(?:\s+OFFSET\s+(\d+))?',
                re.IGNORECASE
            )
            def repl(m):
                order_expr = m.group(1).strip()
                limit = m.group(2)
                offset = m.group(3) if m.group(3) else "0"
                return f"ORDER BY {order_expr} OFFSET {offset} ROWS FETCH NEXT {limit} ROWS ONLY"

            q = pattern.sub(repl, q)

            limit_no_order = re.compile(r'\bLIMIT\s+(\d+)(?:\s+OFFSET\s+(\d+))?', re.IGNORECASE)
            def repl_no_order(m):
                limit = m.group(1)
                offset = m.group(2) if m.group(2) else "0"
                return f"ORDER BY (SELECT NULL) OFFSET {offset} ROWS FETCH NEXT {limit} ROWS ONLY"

            q = limit_no_order.sub(repl_no_order, q)

        if "system_settings" in q.lower():
            q = re.sub(r'(?<!\[)\bkey\b(?!\])', '[key]', q, flags=re.IGNORECASE)
        return q

    def execute(self, query, params=None):
        trans_query = self._transform(query)
        if params is not None:
            if not isinstance(params, (tuple, list)):
                params = (params,)
            self._cursor.execute(trans_query, params)
        else:
            self._cursor.execute(trans_query)

        if query.strip().upper().startswith("INSERT "):
            try:
                self._cursor.execute("SELECT @@IDENTITY")
                row = self._cursor.fetchone()
                if row and row[0] is not None:
                    self._lastrowid = int(row[0])
            except Exception:
                pass
        return self

    def executemany(self, query, seq_of_params):
        trans_query = self._transform(query)
        if seq_of_params:
            self._cursor.executemany(trans_query, seq_of_params)
        else:
            self._cursor.executemany(trans_query, [])
        return self

    def fetchone(self):
        row = self._cursor.fetchone()
        if row is None:
            return None
        cols = [c[0] for c in self._cursor.description]
        row_dict = dict(zip(cols, row))
        return SQLServerRow(row_dict, self._cursor.description)

    def fetchall(self):
        rows = self._cursor.fetchall()
        if not rows:
            return []
        cols = [c[0] for c in self._cursor.description]
        desc = self._cursor.description
        return [SQLServerRow(dict(zip(cols, r)), desc) for r in rows]

    def fetchmany(self, size=None):
        rows = self._cursor.fetchmany(size) if size is not None else self._cursor.fetchmany()
        if not rows:
            return []
        cols = [c[0] for c in self._cursor.description]
        desc = self._cursor.description
        return [SQLServerRow(dict(zip(cols, r)), desc) for r in rows]

    def close(self):
        self._cursor.close()

class SQLServerConnectionWrapper:
    """
    Wrapper cho pyodbc connection
    """
    def __init__(self, raw_conn):
        self._conn = raw_conn

    def cursor(self):
        return SQLServerCursorWrapper(self._conn.cursor())

    def commit(self):
        self._conn.commit()

    def rollback(self):
        self._conn.rollback()

    def close(self):
        self._conn.close()

    def execute(self, query, params=None):
        cur = self.cursor()
        cur.execute(query, params)
        return cur

def get_db():
    global _MYSQL_WARNED, _LAST_MYSQL_FAIL_TIME, _SQLSERVER_WARNED, _LAST_SQLSERVER_FAIL_TIME
    cfg = load_db_config()
    db_type = cfg.get("db_type", "sqlserver").lower()

    now = time.time()

    # 1. Microsoft SQL Server
    if db_type == "sqlserver" and HAS_PYODBC and (now - _LAST_SQLSERVER_FAIL_TIME > 15):
        ss_cfg = cfg.get("sqlserver", {})
        server = ss_cfg.get("server", "localhost\\SQLEXPRESS05")
        database = ss_cfg.get("database", "codebeginner")
        trusted = ss_cfg.get("trusted_connection", "yes")
        driver = ss_cfg.get("driver", "ODBC Driver 17 for SQL Server")
        conn_str = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};Trusted_Connection={trusted};TrustServerCertificate=yes;"
        try:
            raw_conn = pyodbc.connect(conn_str, timeout=3, autocommit=False)
            return SQLServerConnectionWrapper(raw_conn)
        except Exception as e:
            _LAST_SQLSERVER_FAIL_TIME = now
            if not _SQLSERVER_WARNED:
                print(f"[*] [SQL Server Notice] Cannot connect to SQL Server ({e}).")
                print("[*] Falling back to SQLite (codebeginner.db). Start SQLEXPRESS05 and import codebeginner_sqlserver.sql to use SQL Server.")
                _SQLSERVER_WARNED = True

    # 2. MySQL
    can_try_mysql = (db_type == "mysql" and HAS_PYMYSQL and (now - _LAST_MYSQL_FAIL_TIME > 15))
    if can_try_mysql:
        mysql_cfg = cfg.get("mysql", {})
        try:
            raw_conn = pymysql.connect(
                host=mysql_cfg.get("host", "localhost"),
                port=int(mysql_cfg.get("port", 3306)),
                user=mysql_cfg.get("user", "root"),
                password=mysql_cfg.get("password", ""),
                database=mysql_cfg.get("database", "codebeginner"),
                charset=mysql_cfg.get("charset", "utf8mb4"),
                cursorclass=pymysql.cursors.DictCursor,
                connect_timeout=1,
                autocommit=False
            )
            return MySQLConnectionWrapper(raw_conn)
        except Exception as e:
            _LAST_MYSQL_FAIL_TIME = now
            if not _MYSQL_WARNED:
                print(f"[*] [MySQL Notice] Cannot connect to MySQL server ({e}).")
                print("[*] Falling back to SQLite (codebeginner.db). Start MySQL and import codebeginner_mysql.sql to use MySQL.")
                _MYSQL_WARNED = True

    # 3. Fallback to SQLite
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

def init_db():
    cfg = load_db_config()
    db_type = cfg.get("db_type", "mysql").lower()

    if db_type == "mysql" and HAS_PYMYSQL:
        mysql_cfg = cfg.get("mysql", {})
        try:
            # Connect to MySQL server (without DB first) to ensure DB exists
            admin_conn = pymysql.connect(
                host=mysql_cfg.get("host", "localhost"),
                port=int(mysql_cfg.get("port", 3306)),
                user=mysql_cfg.get("user", "root"),
                password=mysql_cfg.get("password", ""),
                charset=mysql_cfg.get("charset", "utf8mb4"),
                autocommit=True
            )
            with admin_conn.cursor() as cur:
                cur.execute(f"CREATE DATABASE IF NOT EXISTS `{mysql_cfg.get('database', 'codebeginner')}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
            admin_conn.close()

            # Execute schema in MySQL
            sql_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "codebeginner_mysql.sql")
            if os.path.exists(sql_file):
                print(f"[*] Initializing MySQL from {sql_file}...")
                conn = get_db()
                with open(sql_file, "r", encoding="utf-8") as f:
                    sql_content = f.read()
                # Split and execute statements
                for stmt in sql_content.split(";"):
                    stmt = stmt.strip()
                    if stmt:
                        try:
                            conn.execute(stmt)
                        except Exception as e:
                            pass
                conn.commit()
                conn.close()
                print("[*] MySQL database initialized successfully.")
        except Exception as e:
            print(f"[*] [MySQL Init Notice] Cannot connect to MySQL ({e}). Initializing SQLite fallback.")

    # Always initialize SQLite as well
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    cursor = conn.cursor()

    # 0. Roles
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        display_name TEXT NOT NULL,
        description TEXT DEFAULT '',
        permissions_json TEXT DEFAULT '[]',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # 1. Users
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'learner', -- 'learner', 'expert', 'admin'
        status TEXT NOT NULL DEFAULT 'active', -- 'active', 'locked'
        avatar TEXT DEFAULT '/static/img/default-avatar.png',
        bio TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        role_id INTEGER,
        FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL
    )
    """)

    # 2. Courses
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'C++',
        level TEXT NOT NULL, -- 'Cơ bản', 'Nền tảng', 'Trung cấp', 'Nâng cao'
        image_url TEXT DEFAULT '',
        status TEXT NOT NULL DEFAULT 'published', -- 'draft', 'published'
        expert_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (expert_id) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 3. Chapters
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
    )
    """)

    # 4. Lessons
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        chapter_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        syntax_guide TEXT DEFAULT '',
        example_code TEXT DEFAULT '',
        example_output TEXT DEFAULT '',
        quiz_data TEXT DEFAULT '[]', -- JSON string of quiz questions
        order_index INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'approved', -- 'draft', 'pending', 'approved', 'rejected'
        reject_reason TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE SET NULL
    )
    """)

    # 5. Exercises
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER,
        lesson_id INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        input_description TEXT NOT NULL,
        output_description TEXT NOT NULL,
        sample_input TEXT NOT NULL,
        sample_output TEXT NOT NULL,
        explanation TEXT DEFAULT '',
        constraints TEXT DEFAULT '',
        difficulty TEXT NOT NULL DEFAULT 'Dễ', -- 'Dễ', 'Trung bình', 'Nâng cao'
        topic TEXT NOT NULL, -- 'Biến và kiểu dữ liệu', 'Nhập/xuất', 'Toán tử', 'If/Else', 'Vòng lặp', 'Mảng', 'Chuỗi', 'Hàm', 'Đệ quy', 'Cấu trúc dữ liệu'
        reference_solution TEXT DEFAULT '',
        points INTEGER NOT NULL DEFAULT 10,
        time_limit REAL NOT NULL DEFAULT 2.0, -- seconds
        memory_limit INTEGER NOT NULL DEFAULT 128, -- MB
        status TEXT NOT NULL DEFAULT 'approved', -- 'draft', 'pending', 'approved'
        expert_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL,
        FOREIGN KEY (expert_id) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 6. Test Cases
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS test_cases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        input_data TEXT NOT NULL,
        expected_output TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 2,
        is_hidden INTEGER NOT NULL DEFAULT 0, -- 0: public, 1: hidden
        order_index INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    )
    """)

    # 7. Submissions
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        source_code TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'C++',
        status TEXT NOT NULL, -- 'Accepted', 'Wrong Answer', 'Compile Error', 'Runtime Error', 'Time Limit Exceeded'
        score REAL NOT NULL DEFAULT 0,
        passed_tests INTEGER NOT NULL DEFAULT 0,
        total_tests INTEGER NOT NULL DEFAULT 0,
        execution_time REAL DEFAULT 0,
        compile_error TEXT DEFAULT '',
        test_details TEXT DEFAULT '[]', -- JSON string of test case results
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    )
    """)

    # 8. Entrance Questions
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS entrance_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic TEXT NOT NULL,
        question_text TEXT NOT NULL,
        code_snippet TEXT DEFAULT '',
        options_json TEXT NOT NULL, -- JSON array of 4 options
        correct_answer INTEGER NOT NULL, -- 0-3
        explanation TEXT DEFAULT ''
    )
    """)

    # 9. Entrance Test Results
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS entrance_test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        total_score REAL NOT NULL,
        max_score REAL NOT NULL,
        percentage REAL NOT NULL,
        topic_breakdown_json TEXT NOT NULL, -- JSON object topic -> percentage
        weak_topics_json TEXT NOT NULL, -- JSON list of weak topics
        summary TEXT NOT NULL,
        details_json TEXT DEFAULT '[]', -- JSON list of question results
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 10. Topic Weaknesses
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS topic_weaknesses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        topic TEXT NOT NULL,
        mastery_percentage REAL NOT NULL DEFAULT 0,
        total_attempts INTEGER NOT NULL DEFAULT 0,
        correct_attempts INTEGER NOT NULL DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, topic),
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 11. Lesson Progress
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS lesson_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        lesson_id INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1,
        completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, lesson_id),
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
    )
    """)

    # 12. Course Enrollments
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS course_enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        progress_percentage REAL NOT NULL DEFAULT 0,
        enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, course_id),
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
    )
    """)

    # 13. Forum Categories
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS forum_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        description TEXT NOT NULL,
        icon TEXT DEFAULT 'message-square',
        order_index INTEGER DEFAULT 1
    )
    """)

    # 14. Forum Threads
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS forum_threads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT DEFAULT '',
        status TEXT NOT NULL DEFAULT 'active', -- 'active', 'hidden', 'locked'
        views_count INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES forum_categories(id) ON DELETE CASCADE
    )
    """)

    # 15. Forum Replies
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS forum_replies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        is_accepted INTEGER NOT NULL DEFAULT 0, -- 1: accepted answer
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 16. Forum Likes
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS forum_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        thread_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, thread_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
    """)

    # 17. Saved Posts
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS saved_posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        thread_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, thread_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
    """)

    # 18. Forum Reports
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS forum_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        target_type TEXT NOT NULL, -- 'thread', 'reply'
        target_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'resolved', 'dismissed'
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 19. Notifications
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        link TEXT DEFAULT '',
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 20. Moderator Assignments
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS moderator_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moderator_id INTEGER NOT NULL,
        target_type TEXT NOT NULL, -- 'course', 'exercise', 'lesson', 'regrade_request', 'forum_report'
        target_id INTEGER NOT NULL,
        assigned_by INTEGER,
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deadline TIMESTAMP,
        status TEXT NOT NULL DEFAULT 'assigned', -- 'assigned', 'in_progress', 'completed', 'revoked'
        notes TEXT DEFAULT '',
        completed_at TIMESTAMP,
        FOREIGN KEY (moderator_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 21. Expert Reviews (Enhanced with moderator assignment link)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS expert_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expert_id INTEGER NOT NULL,
        assignment_id INTEGER,
        target_type TEXT NOT NULL, -- 'exercise', 'lesson', 'submission', 'regrade_request'
        target_id INTEGER NOT NULL,
        review_type TEXT NOT NULL DEFAULT 'content_moderation',
        review_status TEXT NOT NULL, -- 'approved', 'rejected', 'needs_revision'
        comment TEXT NOT NULL,
        changes_requested TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (expert_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (assignment_id) REFERENCES moderator_assignments(id) ON DELETE SET NULL
    )
    """)

    # 22. Assessments (General Assessment Framework)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        type TEXT NOT NULL DEFAULT 'entrance', -- 'entrance', 'chapter_quiz', 'course_final', 'practice'
        course_id INTEGER,
        duration_minutes INTEGER NOT NULL DEFAULT 30,
        passing_percentage REAL NOT NULL DEFAULT 60.0,
        total_questions INTEGER NOT NULL DEFAULT 10,
        status TEXT NOT NULL DEFAULT 'published', -- 'draft', 'published', 'archived'
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL
    )
    """)

    # 23. Assessment Questions
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS assessment_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id INTEGER,
        topic TEXT NOT NULL,
        question_text TEXT NOT NULL,
        code_snippet TEXT DEFAULT '',
        options_json TEXT NOT NULL,
        correct_answer INTEGER NOT NULL,
        explanation TEXT DEFAULT '',
        difficulty TEXT NOT NULL DEFAULT 'Cơ bản',
        points REAL NOT NULL DEFAULT 1.0,
        order_index INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE
    )
    """)

    # 24. Assessment Attempts
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS assessment_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        attempt_number INTEGER NOT NULL DEFAULT 1,
        start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        end_time TIMESTAMP,
        duration_seconds INTEGER,
        total_score REAL NOT NULL DEFAULT 0,
        max_score REAL NOT NULL DEFAULT 10,
        percentage REAL NOT NULL DEFAULT 0,
        passed INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'in_progress', -- 'in_progress', 'completed', 'timed_out', 'abandoned'
        answers_json TEXT DEFAULT '[]',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 25. Certificates
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        certificate_code TEXT UNIQUE NOT NULL,
        student_id INTEGER NOT NULL,
        course_id INTEGER,
        assessment_id INTEGER,
        title TEXT NOT NULL,
        final_score REAL,
        issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expiry_date TIMESTAMP,
        status TEXT NOT NULL DEFAULT 'active', -- 'active', 'revoked'
        cert_hash TEXT DEFAULT '',
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
        FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE SET NULL
    )
    """)

    # 26. Regrade Requests
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS regrade_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        submission_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'in_review', 'approved', 'rejected'
        reviewer_id INTEGER,
        reviewer_feedback TEXT DEFAULT '',
        old_score REAL NOT NULL,
        new_score REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        resolved_at TIMESTAMP,
        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
        FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 27. Submission Events (Anti-cheat & Proctoring logs)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS submission_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        submission_id INTEGER,
        attempt_id INTEGER,
        student_id INTEGER NOT NULL,
        exercise_id INTEGER,
        event_type TEXT NOT NULL, -- 'tab_switch', 'window_blur', 'paste_code', 'copy_attempt', 'fullscreen_exit', 'unusual_typing_speed'
        event_data_json TEXT DEFAULT '{}',
        ip_address TEXT DEFAULT '127.0.0.1',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE SET NULL,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE SET NULL,
        FOREIGN KEY (attempt_id) REFERENCES assessment_attempts(id) ON DELETE SET NULL
    )
    """)

    # 28. Audit Logs
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        target_type TEXT NOT NULL,
        target_id INTEGER,
        details TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 29. System Settings
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS system_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        description TEXT DEFAULT ''
    )
    """)

    # 30. Exercise Rubrics
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS exercise_rubrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        max_points REAL NOT NULL DEFAULT 25.0,
        weight REAL NOT NULL DEFAULT 1.0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
    )
    """)

    # 31. Course Reviews
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS course_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
        comment TEXT DEFAULT '',
        status TEXT NOT NULL DEFAULT 'visible',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(course_id, student_id),
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
    )
    """)

    # 32. Learning Goals
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS learning_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        sessions_per_week INTEGER DEFAULT 3,
        target_completion_date DATE,
        reminder_time TEXT DEFAULT '19:00',
        email_reminder_enabled INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, course_id),
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
    )
    """)

    # 33. Programming Topics
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS programming_topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT DEFAULT '',
        status TEXT NOT NULL DEFAULT 'active',
        order_index INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # 34. System Backups
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS system_backups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT NOT NULL,
        backup_type TEXT NOT NULL DEFAULT 'full',
        file_size_bytes INTEGER DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'success',
        notes TEXT DEFAULT '',
        created_by INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 35. System Alerts
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS system_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        component TEXT NOT NULL,
        severity TEXT NOT NULL DEFAULT 'warning',
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        resolved_by INTEGER,
        resolved_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 36. Course Instructors
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS course_instructors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        instructor_id INTEGER NOT NULL,
        assigned_lesson_ids_json TEXT DEFAULT '[]',
        role TEXT NOT NULL DEFAULT 'instructor',
        assigned_by INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
        FOREIGN KEY (instructor_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # Migration checks & alters for existing databases
    for migration_sql in [
        "ALTER TABLE users ADD COLUMN role_id INTEGER REFERENCES roles(id)",
        "ALTER TABLE users ADD COLUMN phone TEXT DEFAULT ''",
        "ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0",
        "ALTER TABLE users ADD COLUMN locked_until TIMESTAMP NULL",
        "ALTER TABLE users ADD COLUMN force_password_change INTEGER DEFAULT 0",
        "ALTER TABLE users ADD COLUMN reset_token TEXT NULL",
        "ALTER TABLE users ADD COLUMN reset_token_expiry TIMESTAMP NULL",
        "ALTER TABLE courses ADD COLUMN parent_course_id INTEGER REFERENCES courses(id)",
        "ALTER TABLE courses ADD COLUMN order_in_chain INTEGER DEFAULT 1",
        "ALTER TABLE courses ADD COLUMN prerequisite_course_id INTEGER REFERENCES courses(id)",
        "ALTER TABLE courses ADD COLUMN start_date TIMESTAMP NULL",
        "ALTER TABLE courses ADD COLUMN end_date TIMESTAMP NULL",
        "ALTER TABLE courses ADD COLUMN is_public_view INTEGER DEFAULT 1",
        "ALTER TABLE courses ADD COLUMN allow_self_enroll INTEGER DEFAULT 1",
        "ALTER TABLE courses ADD COLUMN forum_enabled INTEGER DEFAULT 1",
        "ALTER TABLE courses ADD COLUMN min_lesson_pct REAL DEFAULT 80.0",
        "ALTER TABLE courses ADD COLUMN min_exercise_count INTEGER DEFAULT 5",
        "ALTER TABLE courses ADD COLUMN min_final_score REAL DEFAULT 60.0",
        "ALTER TABLE courses ADD COLUMN certificate_enabled INTEGER DEFAULT 1",
        "ALTER TABLE chapters ADD COLUMN description TEXT DEFAULT ''",
        "ALTER TABLE chapters ADD COLUMN is_sequential INTEGER DEFAULT 0",
        "ALTER TABLE chapters ADD COLUMN passing_rule TEXT DEFAULT 'all_passed'",
        "ALTER TABLE chapters ADD COLUMN min_exercises_to_pass INTEGER DEFAULT 0",
        "ALTER TABLE chapters ADD COLUMN status TEXT DEFAULT 'published'",
        "ALTER TABLE lessons ADD COLUMN is_trial INTEGER DEFAULT 0",
        "ALTER TABLE lessons ADD COLUMN video_url TEXT DEFAULT ''",
        "ALTER TABLE lessons ADD COLUMN image_url TEXT DEFAULT ''",
        "ALTER TABLE exercises ADD COLUMN reference_solution_tested INTEGER DEFAULT 0",
        "ALTER TABLE exercises ADD COLUMN custom_checker_code TEXT DEFAULT ''",
        "ALTER TABLE exercises ADD COLUMN custom_checker_lang TEXT DEFAULT 'C++'",
        "ALTER TABLE exercises ADD COLUMN hints_json TEXT DEFAULT '[]'",
        "ALTER TABLE submissions ADD COLUMN typing_data_json TEXT DEFAULT '{}'",
        "ALTER TABLE submissions ADD COLUMN anomaly_flag INTEGER DEFAULT 0",
        "ALTER TABLE submissions ADD COLUMN anomaly_score REAL DEFAULT 0.0",
        "ALTER TABLE submissions ADD COLUMN anomaly_status TEXT DEFAULT 'normal'",
        "ALTER TABLE submissions ADD COLUMN anomaly_review_notes TEXT DEFAULT ''",
        "ALTER TABLE submissions ADD COLUMN anomaly_reviewer_id INTEGER REFERENCES users(id)",
        "ALTER TABLE submissions ADD COLUMN rubric_scores_json TEXT DEFAULT '[]'",
        "ALTER TABLE forum_threads ADD COLUMN moderation_status TEXT DEFAULT 'approved'",
        "ALTER TABLE forum_threads ADD COLUMN moderated_by INTEGER REFERENCES users(id)",
        "ALTER TABLE forum_threads ADD COLUMN reject_reason TEXT DEFAULT ''",
        "ALTER TABLE forum_threads ADD COLUMN is_expert_answer INTEGER DEFAULT 0",
        "ALTER TABLE forum_threads ADD COLUMN course_id INTEGER REFERENCES courses(id)",
        "ALTER TABLE forum_threads ADD COLUMN exercise_id INTEGER REFERENCES exercises(id)",
        "ALTER TABLE forum_threads ADD COLUMN lesson_id INTEGER REFERENCES lessons(id)",
        "ALTER TABLE forum_replies ADD COLUMN moderation_status TEXT DEFAULT 'approved'",
        "ALTER TABLE forum_replies ADD COLUMN moderated_by INTEGER REFERENCES users(id)",
        "ALTER TABLE forum_replies ADD COLUMN reject_reason TEXT DEFAULT ''",
        "ALTER TABLE forum_replies ADD COLUMN is_expert_answer INTEGER DEFAULT 0",
        "ALTER TABLE entrance_test_results ADD COLUMN details_json TEXT DEFAULT '[]'",
        "ALTER TABLE expert_reviews ADD COLUMN assignment_id INTEGER REFERENCES moderator_assignments(id)",
        "ALTER TABLE expert_reviews ADD COLUMN review_type TEXT DEFAULT 'content_moderation'",
        "ALTER TABLE expert_reviews ADD COLUMN changes_requested TEXT DEFAULT ''"
    ]:
        try:
            cursor.execute(migration_sql)
        except Exception:
            pass

    # Ensure default roles exist
    cursor.execute("SELECT COUNT(*) FROM roles")
    if cursor.fetchone()[0] == 0:
        cursor.executemany(
            "INSERT OR IGNORE INTO roles (id, name, display_name, description, permissions_json) VALUES (?, ?, ?, ?, ?)",
            [
                (1, "admin", "Quản trị viên", "Toàn quyền quản trị hệ thống, quản lý người dùng, cấu hình và báo cáo", '["all", "manage_users", "manage_courses", "view_audit_logs", "manage_settings"]'),
                (2, "expert", "Chuyên gia nội dung", "Biên soạn khóa học, bài học, bài tập lập trình, duyệt nội dung và chấm phúc khảo", '["create_course", "create_exercise", "review_content", "regrade_submissions"]'),
                (3, "learner", "Học viên", "Tham gia học tập, làm bài kiểm tra, nộp bài tập lập trình và thảo luận trên diễn đàn", '["enroll_courses", "submit_code", "take_assessments", "create_threads", "request_regrade"]'),
                (4, "moderator", "Kiểm duyệt viên", "Kiểm duyệt nội dung diễn đàn, báo cáo vi phạm và hỗ trợ rà soát chất lượng", '["review_forum_reports", "lock_threads", "review_content"]')
            ]
        )
        cursor.execute("UPDATE users SET role_id = 1 WHERE role = 'admin' AND role_id IS NULL")
        cursor.execute("UPDATE users SET role_id = 2 WHERE role = 'expert' AND role_id IS NULL")
        cursor.execute("UPDATE users SET role_id = 3 WHERE role = 'learner' AND role_id IS NULL")

    conn.commit()
    conn.close()
    print("Database initialized successfully.")

if __name__ == "__main__":
    init_db()
