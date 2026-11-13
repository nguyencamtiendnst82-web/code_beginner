import os
import json
import sqlite3
import secrets
import shutil
import zipfile
from datetime import datetime, timedelta
from functools import wraps
from flask import (
    Flask, render_template, request, redirect, url_for,
    session, flash, jsonify, abort, send_file
)
from werkzeug.security import generate_password_hash, check_password_hash

from database import get_db, init_db
from judge_service import run_custom_code, judge_submission
from analytics_service import (
    evaluate_entrance_test, get_student_weakness_report,
    update_weakness_on_submission, CORE_TOPICS
)

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "codebeginner-secret-key-deepmind-2026")

# ==========================================
# AUTH HELPERS & CONTEXT PROCESSORS
# ==========================================

def get_current_user():
    user_id = session.get("user_id")
    if not user_id:
        return None
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, username, email, full_name, role, status, avatar, bio, phone, force_password_change, failed_login_attempts, locked_until FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    conn.close()
    if user and user["status"] == "locked":
        session.clear()
        return None
    return dict(user) if user else None

@app.context_processor
def inject_global_data():
    user = get_current_user()
    unread_count = 0
    settings = {}
    conn = get_db()
    cursor = conn.cursor()
    if user:
        cursor.execute("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0", (user["id"],))
        unread_count = cursor.fetchone()[0]

    cursor.execute("SELECT [key], [value] FROM system_settings")
    for row in cursor.fetchall():
        settings[row["key"]] = row["value"]
    conn.close()

    return {
        "current_user": user,
        "unread_count": unread_count,
        "site_settings": settings,
        "now_year": datetime.now().year
    }

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get("user_id"):
            flash("Vui lòng đăng nhập để tiếp tục.", "warning")
            return redirect(url_for("login", next=request.path))
        return f(*args, **kwargs)
    return decorated_function

def role_required(*allowed_roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = get_current_user()
            if not user:
                flash("Vui lòng đăng nhập để tiếp tục.", "warning")
                return redirect(url_for("login", next=request.path))
            if user["role"] not in allowed_roles:
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def log_audit(user_id, action, target_type, target_id, details=""):
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("""
        INSERT INTO audit_logs (user_id, action, target_type, target_id, details)
        VALUES (?, ?, ?, ?, ?)
        """, (user_id, action, target_type, target_id, details))
        conn.commit()
        conn.close()
    except Exception as e:
        print("Audit log error:", e)

# ==========================================
# PUBLIC & AUTH ROUTES
# ==========================================

@app.route("/")
def index():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    # Khóa học nổi bật
    cursor.execute("""
    SELECT c.*, u.full_name as expert_name,
           (SELECT COUNT(*) FROM lessons WHERE course_id = c.id) as lesson_count,
           (SELECT COUNT(*) FROM exercises WHERE course_id = c.id) as exercise_count
    FROM courses c
    LEFT JOIN users u ON c.expert_id = u.id
    WHERE c.status = 'published'
    ORDER BY c.id ASC
    """)
    courses = [dict(r) for r in cursor.fetchall()]

    # Bài tập nổi bật / đề xuất
    cursor.execute("""
    SELECT e.*, c.title as course_title
    FROM exercises e
    LEFT JOIN courses c ON e.course_id = c.id
    WHERE e.status = 'approved'
    ORDER BY e.id ASC LIMIT 6
    """)
    exercises = [dict(r) for r in cursor.fetchall()]

    learner_stats = None
    if user and user["role"] == "learner":
        cursor.execute("""
        SELECT COUNT(DISTINCT exercise_id) FROM submissions
        WHERE student_id = ? AND status = 'Accepted'
        """, (user["id"],))
        solved_count = cursor.fetchone()[0]

        cursor.execute("""
        SELECT COUNT(*) FROM lesson_progress WHERE student_id = ? AND completed = 1
        """, (user["id"],))
        completed_lessons = cursor.fetchone()[0]

        # Kiểm tra xem đã làm bài test đầu vào chưa
        cursor.execute("""
        SELECT * FROM entrance_test_results WHERE student_id = ? ORDER BY created_at DESC LIMIT 1
        """, (user["id"],))
        entrance_res = cursor.fetchone()

        learner_stats = {
            "solved_count": solved_count,
            "completed_lessons": completed_lessons,
            "has_entrance": bool(entrance_res),
            "entrance_score": entrance_res["percentage"] if entrance_res else None
        }

    conn.close()
    return render_template("index.html", courses=courses, exercises=exercises, learner_stats=learner_stats)

@app.route("/login", methods=["GET", "POST"])
def login():
    if session.get("user_id"):
        user = get_current_user()
        if user:
            if user["role"] == "admin":
                return redirect(url_for("admin_dashboard"))
            elif user["role"] == "expert":
                return redirect(url_for("expert_dashboard"))
            elif user["role"] == "moderator":
                return redirect(url_for("moderator_queue"))
            return redirect(url_for("learner_dashboard"))

    if request.method == "POST":
        identifier = request.form.get("identifier", "").strip()
        password = request.form.get("password", "").strip()

        if not identifier or not password:
            flash("Vui lòng điền đầy đủ tên đăng nhập/email và mật khẩu.", "danger")
            return render_template("auth/login.html")

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE (username = ? OR email = ?)", (identifier, identifier))
        user = cursor.fetchone()

        if not user:
            conn.close()
            flash("Tên đăng nhập, email hoặc mật khẩu không chính xác.", "danger")
            return render_template("auth/login.html")

        # 1. Kiểm tra tài khoản bị khóa vĩnh viễn bởi Quản trị viên
        if user["status"] == "locked":
            conn.close()
            flash("Tài khoản của bạn đã bị khóa bởi Quản trị viên.", "danger")
            return render_template("auth/login.html")

        # 2. Kiểm tra khóa tạm thời 15 phút do nhập sai 5 lần liên tiếp
        locked_until_str = user.get("locked_until")
        if locked_until_str:
            try:
                if isinstance(locked_until_str, str):
                    locked_until_dt = datetime.strptime(str(locked_until_str)[:19], "%Y-%m-%d %H:%M:%S")
                else:
                    locked_until_dt = locked_until_str
                if locked_until_dt > datetime.now():
                    diff = locked_until_dt - datetime.now()
                    rem_mins = max(1, int(diff.total_seconds() // 60))
                    conn.close()
                    flash(f"Tài khoản đang bị tạm khóa an toàn do nhập sai 5 lần liên tiếp. Vui lòng thử lại sau {rem_mins} phút.", "danger")
                    return render_template("auth/login.html")
            except Exception:
                pass

        # 3. Kiểm tra mật khẩu
        if not check_password_hash(user["password_hash"], password):
            failed = (user.get("failed_login_attempts") or 0) + 1
            if failed >= 5:
                lock_time = (datetime.now() + timedelta(minutes=15)).strftime("%Y-%m-%d %H:%M:%S")
                cursor.execute("UPDATE users SET failed_login_attempts = ?, locked_until = ? WHERE id = ?", (failed, lock_time, user["id"]))
                conn.commit()
                conn.close()
                flash("Bạn đã nhập sai mật khẩu 5 lần liên tiếp! Tài khoản tạm thời bị khóa 15 phút để bảo vệ an toàn.", "danger")
            else:
                cursor.execute("UPDATE users SET failed_login_attempts = ? WHERE id = ?", (failed, user["id"]))
                conn.commit()
                conn.close()
                flash(f"Mật khẩu không chính xác. Bạn còn {5 - failed} lần thử trước khi bị tạm khóa.", "danger")
            return render_template("auth/login.html")

        # Đăng nhập thành công -> reset failed_login_attempts và gỡ locked_until
        cursor.execute("UPDATE users SET failed_login_attempts = 0, locked_until = NULL WHERE id = ?", (user["id"],))
        conn.commit()
        conn.close()

        session["user_id"] = user["id"]
        session["user_role"] = user["role"]
        session["user_name"] = user["full_name"]

        # 4. Kiểm tra cờ bắt buộc đổi mật khẩu lần đầu (do Admin cấp)
        if user.get("force_password_change") == 1:
            session["force_password_change"] = True
            flash("Tài khoản được cấp mới bởi Quản trị viên. Vui lòng thiết lập mật khẩu mới bảo mật để tiếp tục.", "warning")
            return redirect(url_for("force_change_password"))

        flash(f"Đăng nhập thành công! Chào mừng {user['full_name']} quay trở lại.", "success")

        next_url = request.args.get("next")
        if next_url and next_url.startswith("/"):
            return redirect(next_url)

        if user["role"] == "admin":
            return redirect(url_for("admin_dashboard"))
        elif user["role"] == "expert":
            return redirect(url_for("expert_dashboard"))
        elif user["role"] == "moderator":
            return redirect(url_for("moderator_queue"))
        return redirect(url_for("learner_dashboard"))

    return render_template("auth/login.html")

@app.route("/register", methods=["GET", "POST"])
def register():
    if session.get("user_id"):
        return redirect(url_for("index"))

    if request.method == "POST":
        full_name = request.form.get("full_name", "").strip()
        username = request.form.get("username", "").strip()
        email = request.form.get("email", "").strip()
        phone = request.form.get("phone", "").strip()
        password = request.form.get("password", "")
        confirm_password = request.form.get("confirm_password", "")

        errors = []
        if not full_name or not username or not email or not password:
            errors.append("Vui lòng nhập đầy đủ các trường bắt buộc.")
        if len(username) < 3:
            errors.append("Tên đăng nhập phải có ít nhất 3 ký tự.")
        if "@" not in email or "." not in email:
            errors.append("Định dạng email không hợp lệ.")
        if len(password) < 8 or not any(c.isalpha() for c in password) or not any(c.isdigit() for c in password):
            errors.append("Mật khẩu phải có độ dài tối thiểu 8 ký tự và bao gồm cả chữ và số.")
        if password != confirm_password:
            errors.append("Mật khẩu xác nhận không trùng khớp.")

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM users WHERE username = ?", (username,))
        if cursor.fetchone():
            errors.append("Tên đăng nhập này đã được sử dụng. Vui lòng chọn tên khác.")
        cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
        if cursor.fetchone():
            errors.append("Email này đã được đăng ký tài khoản.")

        if errors:
            conn.close()
            for err in errors:
                flash(err, "danger")
            return render_template("auth/register.html")

        pwd_hash = generate_password_hash(password)
        cursor.execute("""
        INSERT INTO users (username, password_hash, email, full_name, phone, role, status, failed_login_attempts)
        VALUES (?, ?, ?, ?, ?, 'learner', 'active', 0)
        """, (username, pwd_hash, email, full_name, phone or None))
        new_user_id = cursor.lastrowid

        try:
            cursor.execute("""
            INSERT INTO course_enrollments (student_id, course_id, progress_percentage, enrolled_at, last_accessed_at)
            VALUES (?, 1, 0.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            """, (new_user_id,))
        except Exception:
            pass

        conn.commit()
        conn.close()

        flash("Đăng ký tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.", "success")
        return redirect(url_for("login"))

    return render_template("auth/register.html")

@app.route("/force-change-password", methods=["GET", "POST"])
def force_change_password():
    user = get_current_user()
    if not user:
        return redirect(url_for("login"))

    if request.method == "POST":
        new_password = request.form.get("new_password", "")
        confirm_password = request.form.get("confirm_password", "")

        if len(new_password) < 8 or not any(c.isalpha() for c in new_password) or not any(c.isdigit() for c in new_password):
            flash("Mật khẩu mới phải có ít nhất 8 ký tự và chứa cả chữ lẫn số.", "danger")
            return render_template("auth/force_change_password.html")

        if new_password != confirm_password:
            flash("Mật khẩu xác nhận không khớp.", "danger")
            return render_template("auth/force_change_password.html")

        pwd_hash = generate_password_hash(new_password)
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("UPDATE users SET password_hash = ?, force_password_change = 0 WHERE id = ?", (pwd_hash, user["id"]))
        conn.commit()
        conn.close()

        session.pop("force_password_change", None)
        flash("Đổi mật khẩu thành công! Bạn đã có thể sử dụng đầy đủ chức năng hệ thống.", "success")
        if user["role"] == "admin":
            return redirect(url_for("admin_dashboard"))
        elif user["role"] == "expert":
            return redirect(url_for("expert_dashboard"))
        elif user["role"] == "moderator":
            return redirect(url_for("moderator_queue"))
        return redirect(url_for("learner_dashboard"))

    return render_template("auth/force_change_password.html")

@app.route("/forgot-password", methods=["GET", "POST"])
def forgot_password():
    if request.method == "POST":
        email = request.form.get("email", "").strip()
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT id, full_name FROM users WHERE email = ?", (email,))
        user = cursor.fetchone()
        if not user:
            conn.close()
            flash("Email không tồn tại trong hệ thống.", "danger")
            return render_template("auth/forgot_password.html")

        token = secrets.token_urlsafe(32)
        expiry = (datetime.now() + timedelta(minutes=30)).strftime("%Y-%m-%d %H:%M:%S")
        cursor.execute("UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE id = ?", (token, expiry, user["id"]))
        conn.commit()
        conn.close()

        reset_link = url_for("reset_password", token=token, _external=True)
        flash(f"Liên kết đặt lại mật khẩu đã được tạo (hiệu lực 30 phút): {reset_link}", "info")
        return redirect(url_for("login"))

    return render_template("auth/forgot_password.html")

@app.route("/reset-password/<token>", methods=["GET", "POST"])
def reset_password(token):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, full_name, reset_token_expiry FROM users WHERE reset_token = ?", (token,))
    user = cursor.fetchone()

    if not user:
        conn.close()
        flash("Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.", "danger")
        return redirect(url_for("forgot_password"))

    expiry_str = user["reset_token_expiry"]
    try:
        if isinstance(expiry_str, str):
            exp_dt = datetime.strptime(str(expiry_str)[:19], "%Y-%m-%d %H:%M:%S")
        else:
            exp_dt = expiry_str
        if exp_dt < datetime.now():
            conn.close()
            flash("Liên kết đặt lại mật khẩu đã hết hạn (quá 30 phút).", "danger")
            return redirect(url_for("forgot_password"))
    except Exception:
        pass

    if request.method == "POST":
        new_password = request.form.get("new_password", "")
        confirm_password = request.form.get("confirm_password", "")

        if len(new_password) < 8 or not any(c.isalpha() for c in new_password) or not any(c.isdigit() for c in new_password):
            conn.close()
            flash("Mật khẩu mới phải có tối thiểu 8 ký tự, bao gồm cả chữ và số.", "danger")
            return render_template("auth/reset_password.html", token=token, user=user)

        if new_password != confirm_password:
            conn.close()
            flash("Mật khẩu xác nhận không khớp.", "danger")
            return render_template("auth/reset_password.html", token=token, user=user)

        pwd_hash = generate_password_hash(new_password)
        cursor.execute("UPDATE users SET password_hash = ?, reset_token = NULL, reset_token_expiry = NULL WHERE id = ?", (pwd_hash, user["id"]))
        conn.commit()
        conn.close()

        flash("Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới.", "success")
        return redirect(url_for("login"))

    conn.close()
    return render_template("auth/reset_password.html", token=token, user=user)

@app.route("/logout")
def logout():
    session.clear()
    flash("Bạn đã đăng xuất an toàn.", "info")
    return redirect(url_for("index"))

@app.route("/profile", methods=["GET", "POST"])
@login_required
def profile():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        full_name = request.form.get("full_name", "").strip()
        bio = request.form.get("bio", "").strip()
        if not full_name:
            flash("Họ và tên không được để trống.", "danger")
        else:
            cursor.execute("UPDATE users SET full_name = ?, bio = ? WHERE id = ?", (full_name, bio, user["id"]))
            conn.commit()
            flash("Cập nhật thông tin cá nhân thành công!", "success")
            user["full_name"] = full_name
            user["bio"] = bio

    # Lấy thông tin thành tích học tập
    cursor.execute("""
    SELECT COUNT(DISTINCT exercise_id) FROM submissions WHERE student_id = ? AND status = 'Accepted'
    """, (user["id"],))
    solved_exercises = cursor.fetchone()[0]

    cursor.execute("""
    SELECT COUNT(*) FROM lesson_progress WHERE student_id = ? AND completed = 1
    """, (user["id"],))
    completed_lessons = cursor.fetchone()[0]

    cursor.execute("""
    SELECT c.id, c.title, c.level, ce.progress_percentage, ce.enrolled_at
    FROM course_enrollments ce
    JOIN courses c ON ce.course_id = c.id
    WHERE ce.student_id = ?
    """, (user["id"],))
    enrolled_courses = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("learner/profile.html", user=user, solved_exercises=solved_exercises, completed_lessons=completed_lessons, enrolled_courses=enrolled_courses)

@app.route("/change-password", methods=["POST"])
@login_required
def change_password():
    user = get_current_user()
    old_password = request.form.get("old_password", "")
    new_password = request.form.get("new_password", "")
    confirm_new_password = request.form.get("confirm_new_password", "")

    if len(new_password) < 6:
        flash("Mật khẩu mới phải có ít nhất 6 ký tự.", "danger")
        return redirect(url_for("profile"))

    if new_password != confirm_new_password:
        flash("Mật khẩu mới xác nhận không khớp.", "danger")
        return redirect(url_for("profile"))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT password_hash FROM users WHERE id = ?", (user["id"],))
    curr_hash = cursor.fetchone()["password_hash"]

    if not check_password_hash(curr_hash, old_password):
        conn.close()
        flash("Mật khẩu hiện tại không chính xác.", "danger")
        return redirect(url_for("profile"))

    new_hash = generate_password_hash(new_password)
    cursor.execute("UPDATE users SET password_hash = ? WHERE id = ?", (new_hash, user["id"]))
    conn.commit()
    conn.close()

    flash("Đổi mật khẩu thành công!", "success")
    return redirect(url_for("profile"))

# ==========================================
# LEARNER ROUTES
# ==========================================

@app.route("/dashboard")
@login_required
def learner_dashboard():
    user = get_current_user()
    if user["role"] == "admin":
        return redirect(url_for("admin_dashboard"))
    elif user["role"] == "expert":
        return redirect(url_for("expert_dashboard"))

    conn = get_db()
    cursor = conn.cursor()

    # Thống kê tổng quan
    cursor.execute("SELECT COUNT(DISTINCT exercise_id) FROM submissions WHERE student_id = ? AND status = 'Accepted'", (user["id"],))
    solved_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM submissions WHERE student_id = ?", (user["id"],))
    total_submissions = cursor.fetchone()[0]

    cursor.execute("SELECT AVG(score) FROM submissions WHERE student_id = ?", (user["id"],))
    avg_score = cursor.fetchone()[0] or 0.0

    cursor.execute("SELECT COUNT(*) FROM lesson_progress WHERE student_id = ? AND completed = 1", (user["id"],))
    completed_lessons = cursor.fetchone()[0]

    # Kiểm tra bài test đầu vào
    cursor.execute("SELECT * FROM entrance_test_results WHERE student_id = ? ORDER BY created_at DESC LIMIT 1", (user["id"],))
    entrance_result = cursor.fetchone()

    # Khóa học đang học
    cursor.execute("""
    SELECT c.*, ce.progress_percentage
    FROM course_enrollments ce
    JOIN courses c ON ce.course_id = c.id
    WHERE ce.student_id = ?
    ORDER BY ce.last_accessed_at DESC LIMIT 3
    """, (user["id"],))
    my_courses = [dict(r) for r in cursor.fetchall()]

    # Bài nộp gần đây
    cursor.execute("""
    SELECT s.*, e.title as exercise_title, e.topic, e.difficulty
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    WHERE s.student_id = ?
    ORDER BY s.submitted_at DESC LIMIT 5
    """, (user["id"],))
    recent_submissions = [dict(r) for r in cursor.fetchall()]

    conn.close()

    # Lấy phân tích điểm yếu & đề xuất
    weakness_report = get_student_weakness_report(user["id"])

    return render_template("learner/dashboard.html",
                           solved_count=solved_count,
                           total_submissions=total_submissions,
                           avg_score=round(avg_score, 1),
                           completed_lessons=completed_lessons,
                           entrance_result=entrance_result,
                           my_courses=my_courses,
                           recent_submissions=recent_submissions,
                           weakness_report=weakness_report)

@app.route("/courses")
def course_list():
    keyword = request.args.get("q", "").strip()
    level = request.args.get("level", "").strip()
    lang = request.args.get("lang", "").strip()

    conn = get_db()
    cursor = conn.cursor()

    query = """
    SELECT c.*, u.full_name as expert_name,
           (SELECT COUNT(*) FROM lessons WHERE course_id = c.id) as lesson_count,
           (SELECT COUNT(*) FROM exercises WHERE course_id = c.id) as exercise_count
    FROM courses c
    LEFT JOIN users u ON c.expert_id = u.id
    WHERE c.status = 'published'
    """
    params = []
    if keyword:
        query += " AND (c.title LIKE ? OR c.description LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%"])
    if level:
        query += " AND c.level = ?"
        params.append(level)
    if lang:
        query += " AND c.language = ?"
        params.append(lang)

    query += " ORDER BY c.id ASC"
    cursor.execute(query, params)
    courses = [dict(r) for r in cursor.fetchall()]

    user = get_current_user()
    enrolled_ids = []
    if user:
        cursor.execute("SELECT course_id FROM course_enrollments WHERE student_id = ?", (user["id"],))
        enrolled_ids = [r["course_id"] for r in cursor.fetchall()]

    conn.close()
    return render_template("learner/courses.html", courses=courses, enrolled_ids=enrolled_ids, keyword=keyword, level=level, lang=lang)

@app.route("/courses/<int:course_id>")
def course_detail(course_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT c.*, u.full_name as expert_name, u.bio as expert_bio
    FROM courses c
    LEFT JOIN users u ON c.expert_id = u.id
    WHERE c.id = ? AND c.status = 'published'
    """, (course_id,))
    course = cursor.fetchone()
    if not course:
        conn.close()
        abort(404)

    # Chapters & lessons
    cursor.execute("SELECT * FROM chapters WHERE course_id = ? ORDER BY order_index ASC", (course_id,))
    chapters = [dict(ch) for ch in cursor.fetchall()]

    for ch in chapters:
        cursor.execute("SELECT id, title, order_index, status FROM lessons WHERE chapter_id = ? ORDER BY order_index ASC", (ch["id"],))
        ch["lessons"] = [dict(l) for l in cursor.fetchall()]

    # Kiểm tra trạng thái ghi danh của user
    user = get_current_user()
    enrollment = None
    completed_lesson_ids = []
    has_entrance_test = False

    if user:
        cursor.execute("SELECT * FROM course_enrollments WHERE student_id = ? AND course_id = ?", (user["id"], course_id))
        enrollment = cursor.fetchone()

        cursor.execute("SELECT lesson_id FROM lesson_progress WHERE student_id = ? AND completed = 1", (user["id"],))
        completed_lesson_ids = [r["lesson_id"] for r in cursor.fetchall()]

        cursor.execute("SELECT id FROM entrance_test_results WHERE student_id = ? LIMIT 1", (user["id"],))
        has_entrance_test = bool(cursor.fetchone())

    # Lấy đánh giá khóa học
    cursor.execute("""
    SELECT r.*, u.full_name as student_name
    FROM course_reviews r
    JOIN users u ON r.student_id = u.id
    WHERE r.course_id = ? AND r.status = 'visible'
    ORDER BY r.id DESC
    """, (course_id,))
    reviews = [dict(r) for r in cursor.fetchall()]
    avg_rating = round(sum(r["rating"] for r in reviews) / len(reviews), 1) if reviews else 5.0

    # Lấy mục tiêu học tập
    user_goal = None
    if user:
        cursor.execute("SELECT * FROM learning_goals WHERE student_id = ? AND course_id = ?", (user["id"], course_id))
        ug = cursor.fetchone()
        if ug:
            user_goal = dict(ug)

    conn.close()
    return render_template("learner/course_detail.html",
                           course=dict(course),
                           chapters=chapters,
                           enrollment=enrollment,
                           completed_lesson_ids=completed_lesson_ids,
                           has_entrance_test=has_entrance_test,
                           reviews=reviews,
                           avg_rating=avg_rating,
                           user_goal=user_goal)

@app.route("/courses/<int:course_id>/enroll", methods=["POST"])
@login_required
def enroll_course(course_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM course_enrollments WHERE student_id = ? AND course_id = ?", (user["id"], course_id))
    existing = cursor.fetchone()
    if existing:
        cursor.execute("UPDATE course_enrollments SET last_accessed_at = CURRENT_TIMESTAMP WHERE id = ?", (existing["id"],))
    else:
        cursor.execute("INSERT INTO course_enrollments (student_id, course_id, progress_percentage, enrolled_at, last_accessed_at) VALUES (?, ?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", (user["id"], course_id))
    conn.commit()
    conn.close()
    flash("Bạn đã bắt đầu tham gia khóa học thành công!", "success")
    return redirect(url_for("course_detail", course_id=course_id))

@app.route("/lessons/<int:lesson_id>")
def lesson_view(lesson_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT l.*, c.title as course_title, ch.title as chapter_title, ch.order_index as chapter_order, ch.is_sequential, ch.id as curr_chapter_id
    FROM lessons l
    JOIN courses c ON l.course_id = c.id
    LEFT JOIN chapters ch ON l.chapter_id = ch.id
    WHERE l.id = ?
    """, (lesson_id,))
    lesson = cursor.fetchone()
    if not lesson:
        conn.close()
        abort(404)

    # 1. Chế độ khách vãng lai học thử (Guest trial)
    is_trial_guest = False
    if not user:
        if lesson.get("is_trial") == 1:
            is_trial_guest = True
        else:
            conn.close()
            flash("Bài học này yêu cầu đăng nhập tài khoản học viên để truy cập.", "warning")
            return redirect(url_for("login", next=request.path))

    # 2. Học viên đăng nhập
    is_completed = False
    completed_ids = []
    if user:
        cursor.execute("SELECT id FROM course_enrollments WHERE student_id = ? AND course_id = ?", (user["id"], lesson["course_id"]))
        existing = cursor.fetchone()
        if existing:
            cursor.execute("UPDATE course_enrollments SET last_accessed_at = CURRENT_TIMESTAMP WHERE id = ?", (existing["id"],))
        else:
            cursor.execute("INSERT INTO course_enrollments (student_id, course_id, progress_percentage, enrolled_at, last_accessed_at) VALUES (?, ?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)", (user["id"], lesson["course_id"]))
        conn.commit()

        # Kiểm tra học tuần tự nếu chapter có is_sequential = 1
        if lesson.get("is_sequential") == 1 and lesson.get("curr_chapter_id") and user["role"] == "learner":
            cursor.execute("""
            SELECT l2.id FROM lessons l2
            JOIN chapters ch2 ON l2.chapter_id = ch2.id
            WHERE ch2.course_id = ? AND ch2.order_index < ?
            AND l2.id NOT IN (SELECT lesson_id FROM lesson_progress WHERE student_id = ? AND completed = 1)
            """, (lesson["course_id"], lesson.get("chapter_order") or 0, user["id"]))
            uncompleted_prev = cursor.fetchall()
            if uncompleted_prev:
                conn.close()
                flash("Chương này đang bị khóa tuần tự! Bạn cần hoàn thành tất cả bài học của chương trước trước khi tiếp tục.", "warning")
                return redirect(url_for("course_detail", course_id=lesson["course_id"]))

        # Kiểm tra trạng thái hoàn thành bài hiện tại
        cursor.execute("SELECT completed FROM lesson_progress WHERE student_id = ? AND lesson_id = ?", (user["id"], lesson_id))
        prog = cursor.fetchone()
        is_completed = bool(prog and prog["completed"])

        cursor.execute("SELECT lesson_id FROM lesson_progress WHERE student_id = ? AND completed = 1", (user["id"],))
        completed_ids = [r["lesson_id"] for r in cursor.fetchall()]

    # Toàn bộ danh sách bài học làm mục lục
    cursor.execute("""
    SELECT l.id, l.title, l.order_index, l.chapter_id, l.is_trial, ch.title as chapter_title
    FROM lessons l
    LEFT JOIN chapters ch ON l.chapter_id = ch.id
    WHERE l.course_id = ?
    ORDER BY ch.order_index ASC, l.order_index ASC
    """, (lesson["course_id"],))
    all_lessons = [dict(r) for r in cursor.fetchall()]

    # Bài tập liên quan
    cursor.execute("SELECT * FROM exercises WHERE lesson_id = ? AND status = 'approved'", (lesson_id,))
    related_exercises = [dict(r) for r in cursor.fetchall()]

    # Điều hướng trước / sau
    prev_lesson = None
    next_lesson = None
    curr_idx = -1
    for i, l in enumerate(all_lessons):
        if l["id"] == lesson_id:
            curr_idx = i
            break
    if curr_idx > 0:
        prev_lesson = all_lessons[curr_idx - 1]
    if curr_idx != -1 and curr_idx < len(all_lessons) - 1:
        next_lesson = all_lessons[curr_idx + 1]

    quiz_items = []
    try:
        if lesson["quiz_data"]:
            quiz_items = json.loads(lesson["quiz_data"])
    except Exception:
        quiz_items = []

    conn.close()
    return render_template("learner/lesson.html",
                           lesson=dict(lesson),
                           all_lessons=all_lessons,
                           is_completed=is_completed,
                           completed_ids=completed_ids,
                           related_exercises=related_exercises,
                           prev_lesson=prev_lesson,
                           next_lesson=next_lesson,
                           quiz_items=quiz_items,
                           is_trial_guest=is_trial_guest)

@app.route("/api/lessons/<int:lesson_id>/toggle-complete", methods=["POST"])
@login_required
def toggle_lesson_complete(lesson_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT course_id FROM lessons WHERE id = ?", (lesson_id,))
    lesson = cursor.fetchone()
    if not lesson:
        conn.close()
        return jsonify({"success": False, "error": "Bài học không tồn tại"}), 404

    course_id = lesson["course_id"]

    cursor.execute("SELECT completed FROM lesson_progress WHERE student_id = ? AND lesson_id = ?", (user["id"], lesson_id))
    row = cursor.fetchone()

    new_state = 1
    if row and row["completed"] == 1:
        new_state = 0

    if row:
        cursor.execute("UPDATE lesson_progress SET completed = ?, completed_at = CURRENT_TIMESTAMP WHERE student_id = ? AND lesson_id = ?", (new_state, user["id"], lesson_id))
    else:
        cursor.execute("INSERT INTO lesson_progress (student_id, lesson_id, completed, completed_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)", (user["id"], lesson_id, new_state))

    # Cập nhật tiến độ khóa học
    cursor.execute("SELECT COUNT(*) FROM lessons WHERE course_id = ?", (course_id,))
    total_lessons = cursor.fetchone()[0] or 1

    cursor.execute("""
    SELECT COUNT(*) FROM lesson_progress lp
    JOIN lessons l ON lp.lesson_id = l.id
    WHERE lp.student_id = ? AND l.course_id = ? AND lp.completed = 1
    """, (user["id"], course_id))
    done_lessons = cursor.fetchone()[0]

    pct = round((done_lessons / total_lessons) * 100, 1)
    cursor.execute("""
    UPDATE course_enrollments SET progress_percentage = ?, last_accessed_at = CURRENT_TIMESTAMP
    WHERE student_id = ? AND course_id = ?
    """, (pct, user["id"], course_id))

    conn.commit()
    conn.close()

    return jsonify({"success": True, "completed": bool(new_state), "course_progress": pct})

# ==========================================
# ENTRANCE TEST
# ==========================================

@app.route("/entrance-test", methods=["GET", "POST"])
@login_required
def entrance_test():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        # Thu thập các câu trả lời dạng question_<id>
        answers = {}
        for key, val in request.form.items():
            if key.startswith("q_"):
                qid = key.split("_")[1]
                answers[qid] = int(val)

        res = evaluate_entrance_test(user["id"], answers)
        conn.close()
        if not res:
            flash("Đã có lỗi xảy ra khi chấm bài kiểm tra đầu vào.", "danger")
            return redirect(url_for("learner_dashboard"))

        flash("Bạn đã hoàn thành bài kiểm tra đầu vào! Xem kết quả và phân tích chi tiết bên dưới.", "success")
        return redirect(url_for("entrance_test_result", result_id=res["id"]))

    cursor.execute("SELECT * FROM entrance_questions ORDER BY id ASC")
    questions = []
    for r in cursor.fetchall():
        q = dict(r)
        q["options"] = json.loads(q["options_json"])
        questions.append(q)

    # Lấy kết quả kiểm tra trước đó nếu có
    cursor.execute("SELECT * FROM entrance_test_results WHERE student_id = ? ORDER BY created_at DESC LIMIT 1", (user["id"],))
    previous_result = cursor.fetchone()

    conn.close()
    return render_template("learner/entrance_test.html", questions=questions, previous_result=previous_result)

@app.route("/entrance-test/result/<int:result_id>")
@login_required
def entrance_test_result(result_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM entrance_test_results WHERE id = ? AND student_id = ?", (result_id, user["id"]))
    row = cursor.fetchone()
    conn.close()

    if not row:
        abort(404)

    topic_breakdown = json.loads(row["topic_breakdown_json"])
    weak_topics = json.loads(row["weak_topics_json"])
    details = []
    try:
        if "details_json" in row.keys() and row["details_json"]:
            details = json.loads(row["details_json"])
    except Exception:
        pass

    # Lấy khuyến nghị lộ trình dựa trên điểm yếu
    weakness_report = get_student_weakness_report(user["id"])

    return render_template("learner/entrance_result.html",
                           result=dict(row),
                           topic_breakdown=topic_breakdown,
                           weak_topics=weak_topics,
                           details=details,
                           weakness_report=weakness_report)

# ==========================================
# EXERCISES & ONLINE CODE PRACTICE
# ==========================================

@app.route("/exercises")
def exercise_list():
    keyword = request.args.get("q", "").strip()
    topic = request.args.get("topic", "").strip()
    difficulty = request.args.get("difficulty", "").strip()
    status_filter = request.args.get("status", "").strip()

    conn = get_db()
    cursor = conn.cursor()

    user = get_current_user()

    query = """
    SELECT e.*, c.title as course_title,
           (SELECT COUNT(*) FROM test_cases WHERE exercise_id = e.id) as test_case_count
    FROM exercises e
    LEFT JOIN courses c ON e.course_id = c.id
    WHERE e.status = 'approved'
    """
    params = []
    if keyword:
        query += " AND (e.title LIKE ? OR e.description LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%"])
    if topic:
        query += " AND e.topic = ?"
        params.append(topic)
    if difficulty:
        query += " AND e.difficulty = ?"
        params.append(difficulty)

    query += " ORDER BY e.id ASC"
    cursor.execute(query, params)
    exercises = [dict(r) for r in cursor.fetchall()]

    # Thêm thông tin trạng thái bài làm của học viên
    if user:
        cursor.execute("""
        SELECT exercise_id, status FROM submissions
        WHERE student_id = ?
        ORDER BY id DESC
        """, (user["id"],))
        submission_map = {}
        for sub in cursor.fetchall():
            eid = sub["exercise_id"]
            if eid not in submission_map or sub["status"] == "Accepted":
                submission_map[eid] = sub["status"]

        filtered_exercises = []
        for ex in exercises:
            ex_status = submission_map.get(ex["id"], "Chưa làm")
            ex["user_status"] = ex_status

            if status_filter == "solved" and ex_status != "Accepted":
                continue
            if status_filter == "attempted" and (ex_status == "Chưa làm" or ex_status == "Accepted"):
                continue
            if status_filter == "unsolved" and ex_status != "Chưa làm":
                continue
            filtered_exercises.append(ex)
        exercises = filtered_exercises
    else:
        for ex in exercises:
            ex["user_status"] = "Chưa làm"

    cursor.execute("SELECT DISTINCT topic FROM exercises ORDER BY topic ASC")
    topics = [r["topic"] for r in cursor.fetchall()]

    conn.close()
    return render_template("learner/exercises.html",
                           exercises=exercises,
                           topics=topics,
                           keyword=keyword,
                           current_topic=topic,
                           difficulty=difficulty,
                           status_filter=status_filter)

@app.route("/exercises/<int:exercise_id>")
def exercise_detail(exercise_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT e.*, c.title as course_title, l.title as lesson_title
    FROM exercises e
    LEFT JOIN courses c ON e.course_id = c.id
    LEFT JOIN lessons l ON e.lesson_id = l.id
    WHERE e.id = ? AND e.status = 'approved'
    """, (exercise_id,))
    exercise = cursor.fetchone()
    if not exercise:
        conn.close()
        abort(404)

    user = get_current_user()
    last_code = ""
    submissions = []
    can_view_solution = False

    if user:
        cursor.execute("""
        SELECT * FROM submissions
        WHERE student_id = ? AND exercise_id = ?
        ORDER BY submitted_at DESC
        """, (user["id"], exercise_id))
        submissions = [dict(r) for r in cursor.fetchall()]
        if submissions:
            last_code = submissions[0]["source_code"]
        # Theo tài liệu: Lời giải mẫu chỉ mở khi học viên đã đạt Accepted bài này
        has_accepted = any(s.get("status") == "Accepted" for s in submissions)
        if has_accepted or user["role"] in ["admin", "expert"]:
            can_view_solution = True

    if not last_code:
        last_code = """#include <iostream>
using namespace std;

int main() {
    // Viết giải pháp của bạn ở đây
    
    return 0;
}
"""

    # Parse gợi ý
    hints = []
    try:
        if exercise.get("hints_json"):
            hints = json.loads(exercise["hints_json"])
    except Exception:
        hints = []

    # Lấy rubric thang điểm
    cursor.execute("SELECT * FROM exercise_rubrics WHERE exercise_id = ? ORDER BY id ASC", (exercise_id,))
    rubrics = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("learner/editor.html",
                           exercise=dict(exercise),
                           code=last_code,
                           submissions=submissions,
                           can_view_solution=can_view_solution,
                           hints=hints,
                           rubrics=rubrics)

@app.route("/api/run-code", methods=["POST"])
@login_required
def api_run_code():
    data = request.get_json() or {}
    source_code = data.get("source_code", "")
    input_data = data.get("input_data", "")
    language = data.get("language", "C++")

    result = run_custom_code(source_code, input_data=input_data, language=language)
    return jsonify(result)

@app.route("/api/submit-code", methods=["POST"])
@login_required
def api_submit_code():
    user = get_current_user()
    data = request.get_json() or {}
    exercise_id = data.get("exercise_id")
    source_code = data.get("source_code", "")
    language = data.get("language", "C++")

    # Anti-cheat typing telemetry data
    paste_count = int(data.get("paste_count", 0))
    keystrokes = int(data.get("keystrokes", 0))
    tab_blurs = int(data.get("tab_blurs", 0))
    time_spent = float(data.get("time_spent", 0.0))
    typing_telemetry = {
        "paste_count": paste_count,
        "keystrokes": keystrokes,
        "tab_blurs": tab_blurs,
        "time_spent": time_spent,
        "code_length": len(source_code)
    }

    if not exercise_id:
        return jsonify({"success": False, "error": "Thiếu mã bài tập"}), 400

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM exercises WHERE id = ?", (exercise_id,))
    exercise = cursor.fetchone()
    if not exercise:
        conn.close()
        return jsonify({"success": False, "error": "Bài tập không tồn tại"}), 404

    cursor.execute("SELECT * FROM test_cases WHERE exercise_id = ? ORDER BY order_index ASC", (exercise_id,))
    test_cases = [dict(r) for r in cursor.fetchall()]

    if not test_cases:
        test_cases = [{
            "id": 0,
            "input_data": exercise["sample_input"],
            "expected_output": exercise["sample_output"],
            "points": exercise["points"],
            "is_hidden": 0
        }]

    # Thực hiện chấm bài bằng Judge Service
    judge_res = judge_submission(
        source_code=source_code,
        test_cases=test_cases,
        language=language,
        time_limit=exercise["time_limit"],
        max_points=exercise["points"]
    )

    # Heuristic phát hiện bất thường gõ code
    anomaly_flag = 0
    anomaly_score = 0
    anomaly_status = "normal"
    code_len = len(source_code.strip())
    if code_len > 80 and paste_count > 0 and keystrokes < code_len * 0.25:
        anomaly_flag = 1
        anomaly_score = min(100, int(70 + (paste_count * 6) + (tab_blurs * 4)))
        anomaly_status = "pending_review"

    # Lưu submission vào CSDL
    cursor.execute("""
    INSERT INTO submissions (student_id, exercise_id, source_code, language, status, score, passed_tests, total_tests, execution_time, compile_error, test_details, typing_data_json, anomaly_flag, anomaly_score, anomaly_status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        user["id"], exercise_id, source_code, language,
        judge_res["status"], judge_res["score"], judge_res["passed_tests"],
        judge_res["total_tests"], judge_res["execution_time"],
        judge_res["compile_error"], json.dumps(judge_res["test_details"], ensure_ascii=False),
        json.dumps(typing_telemetry, ensure_ascii=False),
        anomaly_flag, anomaly_score, anomaly_status
    ))
    submission_id = cursor.lastrowid

    # Ghi nhận sự kiện telemetry vào submission_events (Bảng #28)
    try:
        cursor.execute("""
        INSERT INTO submission_events (submission_id, event_type, event_data_json)
        VALUES (?, 'submit_telemetry', ?)
        """, (submission_id, json.dumps(typing_telemetry, ensure_ascii=False)))
    except Exception:
        pass

    conn.commit()
    conn.close()

    # Cập nhật phân tích điểm yếu
    is_accepted = (judge_res["status"] == "Accepted")
    update_weakness_on_submission(user["id"], exercise_id, is_accepted)

    client_test_details = judge_res["test_details"]
    if user["role"] == "learner":
        masked_details = []
        for tc in client_test_details:
            tc_copy = dict(tc)
            if tc_copy.get("is_hidden"):
                tc_copy["input"] = "[Test case ẩn]"
                tc_copy["expected"] = "[Test case ẩn]"
                if tc_copy.get("actual"):
                    tc_copy["actual"] = "[Kết quả thực tế ẩn]"
            masked_details.append(tc_copy)
        client_test_details = masked_details

    return jsonify({
        "success": True,
        "submission_id": submission_id,
        "status": judge_res["status"],
        "score": judge_res["score"],
        "passed_tests": judge_res["passed_tests"],
        "total_tests": judge_res["total_tests"],
        "execution_time": judge_res["execution_time"],
        "compile_error": judge_res["compile_error"],
        "test_details": client_test_details,
        "anomaly_flag": anomaly_flag,
        "anomaly_score": anomaly_score,
        "anomaly_status": anomaly_status
    })

@app.route("/submissions/<int:submission_id>")
@login_required
def submission_detail(submission_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT s.*, e.title as exercise_title, e.topic, e.difficulty, e.points as max_points, u.full_name as student_name
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    JOIN users u ON s.student_id = u.id
    WHERE s.id = ?
    """, (submission_id,))
    submission = cursor.fetchone()
    conn.close()

    if not submission:
        abort(404)

    # Bảo vệ phân quyền: chỉ chính học viên hoặc Expert/Admin mới được xem
    if user["role"] == "learner" and submission["student_id"] != user["id"]:
        abort(403)

    is_admin_or_expert = (user["role"] in ["admin", "expert"])

    test_details = []
    try:
        if submission["test_details"]:
            raw_details = json.loads(submission["test_details"])
            if not is_admin_or_expert:
                for tc in raw_details:
                    tc_copy = dict(tc)
                    if tc_copy.get("is_hidden"):
                        tc_copy["input"] = "[Test case ẩn]"
                        tc_copy["expected"] = "[Test case ẩn]"
                        if tc_copy.get("actual"):
                            tc_copy["actual"] = "[Kết quả thực tế ẩn]"
                    test_details.append(tc_copy)
            else:
                test_details = raw_details
    except:
        pass

    return render_template("learner/submission_detail.html",
                           submission=dict(submission),
                           test_details=test_details,
                           is_admin_or_expert=is_admin_or_expert)

# ==========================================
# WEAKNESS ANALYSIS & PROGRESS
# ==========================================

@app.route("/weakness-analysis")
@login_required
def weakness_analysis():
    user = get_current_user()
    student_id = user["id"]
    target_student = None

    # Expert và Admin có quyền xem phân tích điểm yếu của bất kỳ học viên nào
    req_student_id = request.args.get("student_id", type=int)
    if req_student_id and user["role"] in ["expert", "admin"]:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT id, username, full_name, email, role FROM users WHERE id = ?", (req_student_id,))
        row = cursor.fetchone()
        conn.close()
        if row:
            student_id = row["id"]
            target_student = dict(row)

    report = get_student_weakness_report(student_id)
    return render_template("learner/weakness.html", report=report, target_student=target_student)

@app.route("/progress")
@login_required
def my_progress():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    # Thống kê tổng quan
    cursor.execute("""
    SELECT COUNT(DISTINCT exercise_id) FROM submissions WHERE student_id = ? AND status = 'Accepted'
    """, (user["id"],))
    solved_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM submissions WHERE student_id = ?", (user["id"],))
    total_submissions = cursor.fetchone()[0]

    cursor.execute("SELECT AVG(score) FROM submissions WHERE student_id = ?", (user["id"],))
    avg_score = cursor.fetchone()[0] or 0.0

    # Danh sách khóa học đang tham gia
    cursor.execute("""
    SELECT c.*, ce.progress_percentage, ce.enrolled_at, ce.last_accessed_at,
           (SELECT COUNT(*) FROM lessons WHERE course_id = c.id) as total_lessons,
           (SELECT COUNT(*) FROM lesson_progress lp JOIN lessons l ON lp.lesson_id = l.id WHERE lp.student_id = ? AND l.course_id = c.id AND lp.completed = 1) as done_lessons
    FROM course_enrollments ce
    JOIN courses c ON ce.course_id = c.id
    WHERE ce.student_id = ?
    ORDER BY ce.last_accessed_at DESC
    """, (user["id"], user["id"]))
    courses = [dict(r) for r in cursor.fetchall()]

    # Toàn bộ lịch sử nộp bài
    cursor.execute("""
    SELECT s.*, e.title as exercise_title, e.topic, e.difficulty
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    WHERE s.student_id = ?
    ORDER BY s.submitted_at DESC LIMIT 20
    """, (user["id"],))
    history = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("learner/progress.html",
                           solved_count=solved_count,
                           total_submissions=total_submissions,
                           avg_score=round(avg_score, 1),
                           courses=courses,
                           history=history)

# ==========================================
# FORUM ROUTES
# ==========================================

@app.route("/forum")
def forum_index():
    tab = request.args.get("tab", "latest")
    keyword = request.args.get("q", "").strip()

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM forum_categories ORDER BY order_index ASC")
    categories = [dict(r) for r in cursor.fetchall()]

    query = """
    SELECT t.*, u.full_name as author_name, u.avatar as author_avatar, c.name as category_name, c.slug as category_slug,
           (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) as reply_count,
           (SELECT COUNT(*) FROM forum_likes WHERE thread_id = t.id) as like_count
    FROM forum_threads t
    JOIN users u ON t.user_id = u.id
    JOIN forum_categories c ON t.category_id = c.id
    WHERE t.status != 'hidden'
    """
    params = []
    if keyword:
        query += " AND (t.title LIKE ? OR t.content LIKE ? OR t.tags LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%", f"%{keyword}%"])

    if tab == "unanswered":
        query += " AND (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) = 0"
        query += " ORDER BY t.created_at DESC"
    elif tab == "popular":
        query += " ORDER BY like_count DESC, reply_count DESC"
    else:
        query += " ORDER BY t.created_at DESC"

    cursor.execute(query, params)
    threads = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("forum/index.html", categories=categories, threads=threads, tab=tab, keyword=keyword)

@app.route("/forum/category/<slug>")
def forum_category(slug):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM forum_categories WHERE slug = ?", (slug,))
    category = cursor.fetchone()
    if not category:
        conn.close()
        abort(404)

    cursor.execute("SELECT * FROM forum_categories ORDER BY order_index ASC")
    categories = [dict(r) for r in cursor.fetchall()]

    cursor.execute("""
    SELECT t.*, u.full_name as author_name, u.avatar as author_avatar, c.name as category_name, c.slug as category_slug,
           (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) as reply_count,
           (SELECT COUNT(*) FROM forum_likes WHERE thread_id = t.id) as like_count
    FROM forum_threads t
    JOIN users u ON t.user_id = u.id
    JOIN forum_categories c ON t.category_id = c.id
    WHERE t.category_id = ? AND t.status != 'hidden'
    ORDER BY t.created_at DESC
    """, (category["id"],))
    threads = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("forum/category.html", category=dict(category), categories=categories, threads=threads)

@app.route("/forum/create", methods=["GET", "POST"])
@login_required
def forum_create_thread():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        category_id = request.form.get("category_id")
        content = request.form.get("content", "").strip()
        tags = request.form.get("tags", "").strip()

        if not title or not category_id or not content:
            flash("Vui lòng điền đầy đủ tiêu đề, chuyên mục và nội dung bài viết.", "danger")
        else:
            cursor.execute("""
            INSERT INTO forum_threads (user_id, category_id, title, content, tags)
            VALUES (?, ?, ?, ?, ?)
            """, (user["id"], category_id, title, content, tags))
            thread_id = cursor.lastrowid
            conn.commit()
            conn.close()
            flash("Đăng câu hỏi thành công!", "success")
            return redirect(url_for("forum_thread_detail", thread_id=thread_id))

    cursor.execute("SELECT * FROM forum_categories ORDER BY order_index ASC")
    categories = [dict(r) for r in cursor.fetchall()]
    conn.close()
    return render_template("forum/create_thread.html", categories=categories)

@app.route("/forum/thread/<int:thread_id>", methods=["GET"])
def forum_thread_detail(thread_id):
    conn = get_db()
    cursor = conn.cursor()

    # Tăng lượt xem
    cursor.execute("UPDATE forum_threads SET views_count = views_count + 1 WHERE id = ?", (thread_id,))
    conn.commit()

    cursor.execute("""
    SELECT t.*, u.full_name as author_name, u.avatar as author_avatar, u.role as author_role,
           c.name as category_name, c.slug as category_slug,
           (SELECT COUNT(*) FROM forum_likes WHERE thread_id = t.id) as like_count
    FROM forum_threads t
    JOIN users u ON t.user_id = u.id
    JOIN forum_categories c ON t.category_id = c.id
    WHERE t.id = ?
    """, (thread_id,))
    thread = cursor.fetchone()
    if not thread:
        conn.close()
        abort(404)

    # Danh sách câu trả lời
    cursor.execute("""
    SELECT r.*, u.full_name as author_name, u.avatar as author_avatar, u.role as author_role
    FROM forum_replies r
    JOIN users u ON r.user_id = u.id
    WHERE r.thread_id = ?
    ORDER BY r.is_accepted DESC, r.created_at ASC
    """, (thread_id,))
    replies = [dict(r) for r in cursor.fetchall()]

    user = get_current_user()
    is_liked = False
    is_saved = False
    if user:
        cursor.execute("SELECT 1 FROM forum_likes WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
        is_liked = bool(cursor.fetchone())

        cursor.execute("SELECT 1 FROM saved_posts WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
        is_saved = bool(cursor.fetchone())

    conn.close()
    return render_template("forum/thread.html",
                           thread=dict(thread),
                           replies=replies,
                           is_liked=is_liked,
                           is_saved=is_saved)

@app.route("/forum/thread/<int:thread_id>/reply", methods=["POST"])
@login_required
def forum_reply_thread(thread_id):
    user = get_current_user()
    content = request.form.get("content", "").strip()

    if not content:
        flash("Nội dung câu trả lời không được để trống.", "danger")
        return redirect(url_for("forum_thread_detail", thread_id=thread_id))

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT user_id, title FROM forum_threads WHERE id = ?", (thread_id,))
    thread = cursor.fetchone()
    if not thread:
        conn.close()
        abort(404)

    cursor.execute("""
    INSERT INTO forum_replies (thread_id, user_id, content)
    VALUES (?, ?, ?)
    """, (thread_id, user["id"], content))

    # Gửi thông báo cho tác giả bài viết (nếu không phải chính người đăng)
    if thread["user_id"] != user["id"]:
        cursor.execute("""
        INSERT INTO notifications (user_id, title, content, link)
        VALUES (?, 'Câu trả lời mới', ?, ?)
        """, (
            thread["user_id"],
            f"{user['full_name']} vừa trả lời câu hỏi: '{thread['title']}'",
            url_for("forum_thread_detail", thread_id=thread_id)
        ))

    conn.commit()
    conn.close()
    flash("Gửi câu trả lời thành công!", "success")
    return redirect(url_for("forum_thread_detail", thread_id=thread_id))

@app.route("/forum/thread/<int:thread_id>/like", methods=["POST"])
@login_required
def forum_toggle_like(thread_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT 1 FROM forum_likes WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
    liked = cursor.fetchone()

    if liked:
        cursor.execute("DELETE FROM forum_likes WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
        is_liked = False
    else:
        cursor.execute("INSERT INTO forum_likes (user_id, thread_id) VALUES (?, ?)", (user["id"], thread_id))
        is_liked = True

    cursor.execute("SELECT COUNT(*) FROM forum_likes WHERE thread_id = ?", (thread_id,))
    like_count = cursor.fetchone()[0]

    conn.commit()
    conn.close()
    return jsonify({"success": True, "is_liked": is_liked, "like_count": like_count})

@app.route("/forum/thread/<int:thread_id>/save", methods=["POST"])
@login_required
def forum_toggle_save(thread_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT 1 FROM saved_posts WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
    saved = cursor.fetchone()

    if saved:
        cursor.execute("DELETE FROM saved_posts WHERE user_id = ? AND thread_id = ?", (user["id"], thread_id))
        is_saved = False
    else:
        cursor.execute("INSERT INTO saved_posts (user_id, thread_id) VALUES (?, ?)", (user["id"], thread_id))
        is_saved = True

    conn.commit()
    conn.close()
    return jsonify({"success": True, "is_saved": is_saved})

@app.route("/forum/reply/<int:reply_id>/accept", methods=["POST"])
@login_required
def forum_accept_reply(reply_id):
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT r.*, t.user_id as thread_author_id
    FROM forum_replies r
    JOIN forum_threads t ON r.thread_id = t.id
    WHERE r.id = ?
    """, (reply_id,))
    reply = cursor.fetchone()

    if not reply or reply["thread_author_id"] != user["id"]:
        conn.close()
        return jsonify({"success": False, "error": "Chỉ tác giả câu hỏi mới có quyền chấp nhận câu trả lời."}), 403

    # Reset các câu trả lời khác
    cursor.execute("UPDATE forum_replies SET is_accepted = 0 WHERE thread_id = ?", (reply["thread_id"],))
    new_status = 1 if reply["is_accepted"] == 0 else 0
    cursor.execute("UPDATE forum_replies SET is_accepted = ? WHERE id = ?", (new_status, reply_id))

    conn.commit()
    conn.close()
    return jsonify({"success": True, "is_accepted": bool(new_status)})

@app.route("/my-posts")
@login_required
def my_posts():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT t.*, c.name as category_name,
           (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) as reply_count,
           (SELECT COUNT(*) FROM forum_likes WHERE thread_id = t.id) as like_count
    FROM forum_threads t
    JOIN forum_categories c ON t.category_id = c.id
    WHERE t.user_id = ?
    ORDER BY t.created_at DESC
    """, (user["id"],))
    my_threads = [dict(r) for r in cursor.fetchall()]

    cursor.execute("""
    SELECT r.*, t.title as thread_title
    FROM forum_replies r
    JOIN forum_threads t ON r.thread_id = t.id
    WHERE r.user_id = ?
    ORDER BY r.created_at DESC
    """, (user["id"],))
    my_replies = [dict(r) for r in cursor.fetchall()]

    cursor.execute("""
    SELECT t.*, c.name as category_name, u.full_name as author_name,
           (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) as reply_count,
           (SELECT COUNT(*) FROM forum_likes WHERE thread_id = t.id) as like_count
    FROM saved_posts sp
    JOIN forum_threads t ON sp.thread_id = t.id
    JOIN forum_categories c ON t.category_id = c.id
    JOIN users u ON t.user_id = u.id
    WHERE sp.user_id = ?
    ORDER BY sp.created_at DESC
    """, (user["id"],))
    saved_threads = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("forum/my_posts.html", my_threads=my_threads, my_replies=my_replies, saved_threads=saved_threads)

@app.route("/notifications")
@login_required
def notifications_list():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC", (user["id"],))
    notifications = [dict(r) for r in cursor.fetchall()]

    # Tự động đánh dấu đã đọc
    cursor.execute("UPDATE notifications SET is_read = 1 WHERE user_id = ?", (user["id"],))
    conn.commit()
    conn.close()

    return render_template("forum/notifications.html", notifications=notifications)

# ==========================================
# EXPERT / TEACHER ROUTES
# ==========================================

@app.route("/expert/dashboard")
@role_required("expert", "admin")
def expert_dashboard():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM exercises")
    total_exercises = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM exercises WHERE status = 'pending'")
    pending_exercises = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM submissions")
    total_submissions = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM lessons WHERE status = 'pending'")
    pending_lessons = cursor.fetchone()[0]

    # Phân bố bài tập theo độ khó
    cursor.execute("SELECT difficulty, COUNT(*) as cnt FROM exercises GROUP BY difficulty")
    difficulty_stats = {r["difficulty"]: r["cnt"] for r in cursor.fetchall()}

    # Các chủ đề có tỷ lệ nộp bài sai cao
    cursor.execute("""
    SELECT e.topic,
           COUNT(*) as total_subs,
           SUM(CASE WHEN s.status != 'Accepted' THEN 1 ELSE 0 END) as wrong_subs
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    GROUP BY e.topic
    HAVING COUNT(*) >= 3
    ORDER BY (CAST(SUM(CASE WHEN s.status != 'Accepted' THEN 1 ELSE 0 END) AS REAL) / COUNT(*)) DESC LIMIT 5
    """)
    high_error_topics = [dict(r) for r in cursor.fetchall()]

    # Bài nộp cần xem xét gần đây
    cursor.execute("""
    SELECT s.*, e.title as exercise_title, u.full_name as student_name
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    JOIN users u ON s.student_id = u.id
    WHERE s.status != 'Accepted'
    ORDER BY s.submitted_at DESC LIMIT 5
    """)
    flagged_submissions = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("expert/dashboard.html",
                           total_exercises=total_exercises,
                           pending_exercises=pending_exercises,
                           total_submissions=total_submissions,
                           pending_lessons=pending_lessons,
                           difficulty_stats=difficulty_stats,
                           high_error_topics=high_error_topics,
                           flagged_submissions=flagged_submissions)

@app.route("/expert/exercises")
@role_required("expert", "admin")
def expert_exercises():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT e.*, c.title as course_title,
           (SELECT COUNT(*) FROM test_cases WHERE exercise_id = e.id) as test_case_count
    FROM exercises e
    LEFT JOIN courses c ON e.course_id = c.id
    ORDER BY e.id DESC
    """)
    exercises = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("expert/exercises.html", exercises=exercises)

@app.route("/expert/exercises/create", methods=["GET", "POST"])
@role_required("expert", "admin")
def expert_exercise_create():
    user = get_current_user()
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        course_id = request.form.get("course_id") or None
        lesson_id = request.form.get("lesson_id") or None
        topic = request.form.get("topic", "Biến và kiểu dữ liệu")
        difficulty = request.form.get("difficulty", "Dễ")
        description = request.form.get("description", "").strip()
        input_desc = request.form.get("input_description", "").strip()
        output_desc = request.form.get("output_description", "").strip()
        sample_in = request.form.get("sample_input", "").strip()
        sample_out = request.form.get("sample_output", "").strip()
        explanation = request.form.get("explanation", "").strip()
        constraints = request.form.get("constraints", "").strip()
        ref_sol = request.form.get("reference_solution", "").strip()
        points = int(request.form.get("points", 10))
        status = request.form.get("status", "approved")

        cursor.execute("""
        INSERT INTO exercises (title, course_id, lesson_id, topic, difficulty, description, input_description, output_description, sample_input, sample_output, explanation, constraints, reference_solution, points, expert_id, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (title, course_id, lesson_id, topic, difficulty, description, input_desc, output_desc, sample_in, sample_out, explanation, constraints, ref_sol, points, user["id"], status))
        new_ex_id = cursor.lastrowid

        # Tạo tự động 1 test case từ sample nếu có
        if sample_in and sample_out:
            cursor.execute("""
            INSERT INTO test_cases (exercise_id, input_data, expected_output, points, is_hidden, order_index)
            VALUES (?, ?, ?, ?, 0, 1)
            """, (new_ex_id, sample_in, sample_out, points))

        conn.commit()
        conn.close()
        flash("Tạo bài tập mới thành công! Bạn có thể thêm bộ test case ngay bên dưới.", "success")
        return redirect(url_for("expert_testcases", exercise_id=new_ex_id))

    cursor.execute("SELECT id, title FROM courses ORDER BY id ASC")
    courses = [dict(r) for r in cursor.fetchall()]

    cursor.execute("SELECT id, title FROM lessons ORDER BY id ASC")
    lessons = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("expert/exercise_form.html", exercise=None, courses=courses, lessons=lessons, topics=CORE_TOPICS)

@app.route("/expert/exercises/<int:exercise_id>/edit", methods=["GET", "POST"])
@role_required("expert", "admin")
def expert_exercise_edit(exercise_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM exercises WHERE id = ?", (exercise_id,))
    exercise = cursor.fetchone()
    if not exercise:
        conn.close()
        abort(404)

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        course_id = request.form.get("course_id") or None
        lesson_id = request.form.get("lesson_id") or None
        topic = request.form.get("topic")
        difficulty = request.form.get("difficulty")
        description = request.form.get("description", "").strip()
        input_desc = request.form.get("input_description", "").strip()
        output_desc = request.form.get("output_description", "").strip()
        sample_in = request.form.get("sample_input", "").strip()
        sample_out = request.form.get("sample_output", "").strip()
        explanation = request.form.get("explanation", "").strip()
        constraints = request.form.get("constraints", "").strip()
        ref_sol = request.form.get("reference_solution", "").strip()
        points = int(request.form.get("points", 10))
        status = request.form.get("status", "approved")

        cursor.execute("""
        UPDATE exercises SET
            title = ?, course_id = ?, lesson_id = ?, topic = ?, difficulty = ?,
            description = ?, input_description = ?, output_description = ?,
            sample_input = ?, sample_output = ?, explanation = ?, constraints = ?,
            reference_solution = ?, points = ?, status = ?
        WHERE id = ?
        """, (title, course_id, lesson_id, topic, difficulty, description, input_desc, output_desc, sample_in, sample_out, explanation, constraints, ref_sol, points, status, exercise_id))

        conn.commit()
        conn.close()
        flash("Cập nhật bài tập thành công!", "success")
        return redirect(url_for("expert_exercises"))

    cursor.execute("SELECT id, title FROM courses ORDER BY id ASC")
    courses = [dict(r) for r in cursor.fetchall()]

    cursor.execute("SELECT id, title FROM lessons ORDER BY id ASC")
    lessons = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("expert/exercise_form.html", exercise=dict(exercise), courses=courses, lessons=lessons, topics=CORE_TOPICS)

@app.route("/expert/exercises/<int:exercise_id>/testcases", methods=["GET", "POST"])
@role_required("expert", "admin")
def expert_testcases(exercise_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM exercises WHERE id = ?", (exercise_id,))
    exercise = cursor.fetchone()
    if not exercise:
        conn.close()
        abort(404)

    if request.method == "POST":
        input_data = request.form.get("input_data", "").strip()
        expected_output = request.form.get("expected_output", "").strip()
        points = int(request.form.get("points", 2))
        is_hidden = 1 if request.form.get("is_hidden") else 0

        cursor.execute("""
        INSERT INTO test_cases (exercise_id, input_data, expected_output, points, is_hidden)
        VALUES (?, ?, ?, ?, ?)
        """, (exercise_id, input_data, expected_output, points, is_hidden))
        conn.commit()
        flash("Thêm test case mới thành công!", "success")
        return redirect(url_for("expert_testcases", exercise_id=exercise_id))

    cursor.execute("SELECT * FROM test_cases WHERE exercise_id = ? ORDER BY order_index ASC", (exercise_id,))
    test_cases = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("expert/testcases.html", exercise=dict(exercise), test_cases=test_cases)

@app.route("/expert/testcases/<int:tc_id>/delete", methods=["POST"])
@role_required("expert", "admin")
def expert_testcase_delete(tc_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT exercise_id FROM test_cases WHERE id = ?", (tc_id,))
    tc = cursor.fetchone()
    if tc:
        ex_id = tc["exercise_id"]
        cursor.execute("DELETE FROM test_cases WHERE id = ?", (tc_id,))
        conn.commit()
        flash("Đã xóa test case thành công.", "info")
        conn.close()
        return redirect(url_for("expert_testcases", exercise_id=ex_id))
    conn.close()
    abort(404)

@app.route("/expert/exercises/<int:exercise_id>/verify-tests", methods=["POST"])
@role_required("expert", "admin")
def expert_verify_testcases(exercise_id):
    """
    Chạy thử lời giải mẫu (reference solution) với toàn bộ bộ test case để kiểm tra tính chính xác
    """
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM exercises WHERE id = ?", (exercise_id,))
    exercise = cursor.fetchone()
    if not exercise or not exercise["reference_solution"]:
        conn.close()
        return jsonify({"success": False, "error": "Bài tập chưa có mã nguồn tham chiếu (Reference Solution)."}), 400

    cursor.execute("SELECT * FROM test_cases WHERE exercise_id = ? ORDER BY order_index ASC", (exercise_id,))
    test_cases = [dict(r) for r in cursor.fetchall()]
    conn.close()

    res = judge_submission(
        source_code=exercise["reference_solution"],
        test_cases=test_cases,
        time_limit=exercise["time_limit"],
        max_points=exercise["points"]
    )
    return jsonify(res)

@app.route("/expert/submissions")
@role_required("expert", "admin")
def expert_submissions():
    student_id = request.args.get("student_id", type=int)
    conn = get_db()
    cursor = conn.cursor()

    query = """
    SELECT s.*, e.title as exercise_title, u.full_name as student_name, u.email as student_email
    FROM submissions s
    JOIN exercises e ON s.exercise_id = e.id
    JOIN users u ON s.student_id = u.id
    WHERE 1=1
    """
    params = []
    if student_id:
        query += " AND s.student_id = ?"
        params.append(student_id)

    query += " ORDER BY s.submitted_at DESC LIMIT 50"
    cursor.execute(query, params)
    submissions = [dict(r) for r in cursor.fetchall()]

    student_info = None
    if student_id:
        cursor.execute("SELECT id, full_name, username, email FROM users WHERE id = ?", (student_id,))
        row = cursor.fetchone()
        if row:
            student_info = dict(row)

    conn.close()
    return render_template("expert/submissions.html", submissions=submissions, student_info=student_info)

@app.route("/expert/lesson-reviews")
@role_required("expert", "admin")
def expert_lesson_reviews():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT l.*, c.title as course_title
    FROM lessons l
    JOIN courses c ON l.course_id = c.id
    ORDER BY l.id DESC
    """)
    lessons = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("expert/lesson_reviews.html", lessons=lessons)

@app.route("/expert/lessons/<int:lesson_id>/update-status", methods=["POST"])
@role_required("expert", "admin")
def expert_update_lesson_status(lesson_id):
    status = request.form.get("status")
    reason = request.form.get("reject_reason", "").strip()

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE lessons SET status = ?, reject_reason = ? WHERE id = ?", (status, reason, lesson_id))
    conn.commit()
    conn.close()

    flash(f"Đã cập nhật trạng thái bài học thành: {status}", "success")
    return redirect(url_for("expert_lesson_reviews"))

# ==========================================
# STUDENT MANAGEMENT & TRACKING (EXPERT & ADMIN)
# ==========================================

@app.route("/students")
@app.route("/expert/students")
@app.route("/admin/students")
@role_required("expert", "admin")
def student_list_view():
    keyword = request.args.get("q", "").strip()
    status_filter = request.args.get("status", "").strip()
    test_filter = request.args.get("test_status", "").strip()

    conn = get_db()
    cursor = conn.cursor()

    query = """
    SELECT u.id, u.username, u.full_name, u.email, u.status, u.created_at,
           (SELECT COUNT(DISTINCT s.exercise_id) FROM submissions s WHERE s.student_id = u.id AND s.status = 'Accepted') as solved_count,
           (SELECT COUNT(*) FROM submissions s WHERE s.student_id = u.id) as total_submissions,
           (SELECT AVG(s.score) FROM submissions s WHERE s.student_id = u.id) as avg_score,
           (SELECT total_score FROM entrance_test_results WHERE student_id = u.id ORDER BY id DESC LIMIT 1) as entrance_score,
           (SELECT max_score FROM entrance_test_results WHERE student_id = u.id ORDER BY id DESC LIMIT 1) as entrance_max,
           (SELECT percentage FROM entrance_test_results WHERE student_id = u.id ORDER BY id DESC LIMIT 1) as entrance_pct,
           (SELECT created_at FROM entrance_test_results WHERE student_id = u.id ORDER BY id DESC LIMIT 1) as entrance_date,
           (SELECT COUNT(*) FROM course_enrollments WHERE student_id = u.id) as enrolled_count
    FROM users u
    WHERE u.role = 'learner'
    """
    params = []
    if keyword:
        query += " AND (u.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%", f"%{keyword}%"])
    if status_filter:
        query += " AND u.status = ?"
        params.append(status_filter)
    if test_filter == "done":
        query += " AND (SELECT COUNT(*) FROM entrance_test_results WHERE student_id = u.id) > 0"
    elif test_filter == "not_yet":
        query += " AND (SELECT COUNT(*) FROM entrance_test_results WHERE student_id = u.id) = 0"

    query += " ORDER BY u.id DESC"
    cursor.execute(query, params)
    students = [dict(r) for r in cursor.fetchall()]

    for s in students:
        if s["entrance_pct"] is not None:
            pct = s["entrance_pct"]
            if pct >= 80:
                s["entrance_class"] = "Giỏi"
            elif pct >= 65:
                s["entrance_class"] = "Khá"
            elif pct >= 50:
                s["entrance_class"] = "Trung bình"
            else:
                s["entrance_class"] = "Cần củng cố"
        else:
            s["entrance_class"] = None

        cursor.execute("""
        SELECT c.id, c.title, ce.progress_percentage
        FROM course_enrollments ce
        JOIN courses c ON ce.course_id = c.id
        WHERE ce.student_id = ?
        """, (s["id"],))
        s["courses"] = [dict(r) for r in cursor.fetchall()]
        s["avg_score"] = round(s["avg_score"], 1) if s["avg_score"] else 0.0

    # Summary counts
    total_students = len(students)
    tested_count = sum(1 for s in students if s["entrance_score"] is not None)
    active_solvers = sum(1 for s in students if s["solved_count"] > 0)

    conn.close()
    return render_template("expert/students.html",
                           students=students,
                           keyword=keyword,
                           status_filter=status_filter,
                           test_filter=test_filter,
                           total_students=total_students,
                           tested_count=tested_count,
                           active_solvers=active_solvers)

# ==========================================
# ADMIN ROUTES
# ==========================================

@app.route("/admin/dashboard")
@role_required("admin")
def admin_dashboard():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM users")
    total_users = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'learner'")
    total_learners = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'expert'")
    total_experts = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM courses")
    total_courses = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM exercises")
    total_exercises = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM submissions")
    total_submissions = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM submissions WHERE status = 'Accepted'")
    accepted_submissions = cursor.fetchone()[0]

    accuracy_rate = round((accepted_submissions / total_submissions * 100), 1) if total_submissions > 0 else 0

    # Lịch sử nộp bài gần đây
    cursor.execute("""
    SELECT s.*, u.full_name as student_name, e.title as exercise_title
    FROM submissions s
    JOIN users u ON s.student_id = u.id
    JOIN exercises e ON s.exercise_id = e.id
    ORDER BY s.submitted_at DESC LIMIT 6
    """)
    recent_submissions = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return render_template("admin/dashboard.html",
                           total_users=total_users,
                           total_learners=total_learners,
                           total_experts=total_experts,
                           total_courses=total_courses,
                           total_exercises=total_exercises,
                           total_submissions=total_submissions,
                           accuracy_rate=accuracy_rate,
                           recent_submissions=recent_submissions)

@app.route("/admin/users")
@role_required("admin")
def admin_users():
    keyword = request.args.get("q", "").strip()
    role_filter = request.args.get("role", "").strip()
    status_filter = request.args.get("status", "").strip()

    conn = get_db()
    cursor = conn.cursor()

    # Thống kê số lượng theo từng vai trò
    cursor.execute("SELECT role, COUNT(*) as cnt FROM users GROUP BY role")
    role_counts = {r["role"]: r["cnt"] for r in cursor.fetchall()}
    role_counts["all"] = sum(role_counts.values())

    query = "SELECT * FROM users WHERE 1=1"
    params = []
    if keyword:
        query += " AND (full_name LIKE ? OR email LIKE ? OR username LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%", f"%{keyword}%"])
    if role_filter:
        query += " AND role = ?"
        params.append(role_filter)
    if status_filter:
        query += " AND status = ?"
        params.append(status_filter)

    query += " ORDER BY id DESC"
    cursor.execute(query, params)
    users = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("admin/users.html", users=users, keyword=keyword, role_filter=role_filter, status_filter=status_filter, role_counts=role_counts)

@app.route("/admin/users/create-expert", methods=["POST"])
@role_required("admin")
def admin_create_expert():
    full_name = request.form.get("full_name", "").strip()
    username = request.form.get("username", "").strip()
    email = request.form.get("email", "").strip()
    password = request.form.get("password", "")

    if not full_name or not username or not email or not password:
        flash("Vui lòng điền đầy đủ thông tin chuyên gia.", "danger")
        return redirect(url_for("admin_users"))

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT id FROM users WHERE username = ? OR email = ?", (username, email))
    if cursor.fetchone():
        conn.close()
        flash("Tên đăng nhập hoặc Email này đã tồn tại trên hệ thống.", "danger")
        return redirect(url_for("admin_users"))

    pwd_hash = generate_password_hash(password)
    cursor.execute("""
    INSERT INTO users (username, password_hash, email, full_name, role, status)
    VALUES (?, ?, ?, ?, 'expert', 'active')
    """, (username, pwd_hash, email, full_name))
    new_user_id = cursor.lastrowid
    conn.commit()
    conn.close()

    log_audit(session.get("user_id"), "CREATE_EXPERT", "user", new_user_id, f"Created expert {username}")
    flash(f"Tạo tài khoản Chuyên gia '{username}' thành công!", "success")
    return redirect(url_for("admin_users"))

@app.route("/admin/users/<int:user_id>/toggle-status", methods=["POST"])
@role_required("admin")
def admin_toggle_user_status(user_id):
    if user_id == session.get("user_id"):
        flash("Bạn không thể tự khóa tài khoản của chính mình!", "danger")
        return redirect(url_for("admin_users"))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT status, username FROM users WHERE id = ?", (user_id,))
    u = cursor.fetchone()
    if not u:
        conn.close()
        abort(404)

    new_status = "locked" if u["status"] == "active" else "active"
    cursor.execute("UPDATE users SET status = ? WHERE id = ?", (new_status, user_id))
    conn.commit()
    conn.close()

    log_audit(session.get("user_id"), "TOGGLE_USER_STATUS", "user", user_id, f"Changed status of {u['username']} to {new_status}")
    flash(f"Đã cập nhật trạng thái người dùng {u['username']} thành '{new_status}'.", "info")
    return redirect(url_for("admin_users"))

@app.route("/admin/users/<int:user_id>/update-role", methods=["POST"])
@role_required("admin")
def admin_update_user_role(user_id):
    new_role = request.form.get("role")
    if new_role not in ["learner", "expert", "admin"]:
        flash("Vai trò không hợp lệ.", "danger")
        return redirect(url_for("admin_users"))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE users SET role = ? WHERE id = ?", (new_role, user_id))
    conn.commit()
    conn.close()

    log_audit(session.get("user_id"), "UPDATE_USER_ROLE", "user", user_id, f"Changed role to {new_role}")
    flash("Cập nhật vai trò người dùng thành công!", "success")
    return redirect(url_for("admin_users"))

@app.route("/admin/courses")
@role_required("admin")
def admin_courses():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT c.*, u.full_name as expert_name,
           (SELECT COUNT(*) FROM lessons WHERE course_id = c.id) as lesson_count,
           (SELECT COUNT(*) FROM exercises WHERE course_id = c.id) as exercise_count
    FROM courses c
    LEFT JOIN users u ON c.expert_id = u.id
    ORDER BY c.id ASC
    """)
    courses = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("admin/courses.html", courses=courses)

@app.route("/admin/courses/create", methods=["GET", "POST"])
@role_required("admin")
def admin_create_course():
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        description = request.form.get("description", "").strip()
        language = request.form.get("language", "C++")
        level = request.form.get("level", "Cơ bản")
        expert_id = request.form.get("expert_id") or None
        image_url = request.form.get("image_url", "").strip()
        status = request.form.get("status", "published")

        cursor.execute("""
        INSERT INTO courses (title, description, language, level, expert_id, image_url, status)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (title, description, language, level, expert_id, image_url, status))
        new_course_id = cursor.lastrowid
        conn.commit()
        conn.close()

        log_audit(session.get("user_id"), "CREATE_COURSE", "course", new_course_id, f"Created course {title}")
        flash("Thêm khóa học mới thành công!", "success")
        return redirect(url_for("admin_courses"))

    cursor.execute("SELECT id, full_name FROM users WHERE role IN ('expert', 'admin')")
    experts = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("admin/course_form.html", course=None, experts=experts)

@app.route("/admin/reports")
@role_required("admin")
def admin_reports():
    start_date = request.args.get("start_date", "")
    end_date = request.args.get("end_date", "")

    conn = get_db()
    cursor = conn.cursor()

    query = "SELECT s.*, e.topic FROM submissions s JOIN exercises e ON s.exercise_id = e.id WHERE 1=1"
    params = []
    if start_date:
        query += " AND s.submitted_at >= ?"
        params.append(start_date + " 00:00:00")
    if end_date:
        query += " AND s.submitted_at <= ?"
        params.append(end_date + " 23:59:59")

    cursor.execute(query, params)
    subs = [dict(r) for r in cursor.fetchall()]

    total_subs = len(subs)
    accepted_subs = sum(1 for s in subs if s["status"] == "Accepted")
    accuracy_rate = round((accepted_subs / total_subs * 100), 1) if total_subs > 0 else 0

    # Phân bố theo chủ đề
    topic_map = {}
    for s in subs:
        t = s["topic"]
        if t not in topic_map:
            topic_map[t] = {"total": 0, "accepted": 0}
        topic_map[t]["total"] += 1
        if s["status"] == "Accepted":
            topic_map[t]["accepted"] += 1

    topic_report = []
    for t, val in topic_map.items():
        rate = round((val["accepted"] / val["total"] * 100), 1) if val["total"] > 0 else 0
        topic_report.append({
            "topic": t,
            "total": val["total"],
            "accepted": val["accepted"],
            "accuracy": rate
        })

    # Lấy lịch sử đăng ký người dùng
    cursor.execute("SELECT role, COUNT(*) as cnt FROM users GROUP BY role")
    user_role_counts = {r["role"]: r["cnt"] for r in cursor.fetchall()}

    conn.close()
    return render_template("admin/reports.html",
                           total_subs=total_subs,
                           accepted_subs=accepted_subs,
                           accuracy_rate=accuracy_rate,
                           topic_report=topic_report,
                           user_role_counts=user_role_counts,
                           start_date=start_date,
                           end_date=end_date)

@app.route("/admin/settings", methods=["GET", "POST"])
@role_required("admin")
def admin_settings():
    conn = get_db()
    cursor = conn.cursor()

    if request.method == "POST":
        for key in ["site_name", "site_description", "default_time_limit", "default_memory_limit", "supported_languages"]:
            if key in request.form:
                val = request.form[key].strip()
                cursor.execute("SELECT 1 FROM system_settings WHERE [key] = ?", (key,))
                if cursor.fetchone():
                    cursor.execute("UPDATE system_settings SET value = ? WHERE [key] = ?", (val, key))
                else:
                    cursor.execute("INSERT INTO system_settings ([key], value) VALUES (?, ?)", (key, val))
        conn.commit()
        flash("Lưu cấu hình hệ thống thành công!", "success")

    cursor.execute("SELECT * FROM system_settings")
    settings = {r["key"]: r["value"] for r in cursor.fetchall()}
    conn.close()

    return render_template("admin/settings.html", settings=settings)

@app.route("/admin/forum")
@role_required("admin")
def admin_forum():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT t.*, u.full_name as author_name, c.name as category_name,
           (SELECT COUNT(*) FROM forum_replies WHERE thread_id = t.id) as reply_count
    FROM forum_threads t
    JOIN users u ON t.user_id = u.id
    JOIN forum_categories c ON t.category_id = c.id
    ORDER BY t.created_at DESC
    """)
    threads = [dict(r) for r in cursor.fetchall()]
    conn.close()

    return render_template("admin/forum_moderation.html", threads=threads)

@app.route("/admin/forum/threads/<int:thread_id>/toggle-status", methods=["POST"])
@role_required("admin")
def admin_toggle_thread_status(thread_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT status FROM forum_threads WHERE id = ?", (thread_id,))
    t = cursor.fetchone()
    if not t:
        conn.close()
        abort(404)

    new_status = "hidden" if t["status"] == "active" else "active"
    cursor.execute("UPDATE forum_threads SET status = ? WHERE id = ?", (new_status, thread_id))
    conn.commit()
    conn.close()

    flash(f"Đã chuyển trạng thái bài viết thành: {new_status}", "info")
    return redirect(url_for("admin_forum"))

# ==========================================
# NEW SPEC ROUTES: LEARNER, EXPERT, MODERATOR, ADMIN
# ==========================================

# --- Phân hệ Học viên: Đánh giá khóa học, Mục tiêu & Phúc khảo & Tra cứu chứng chỉ ---
@app.route("/courses/<int:course_id>/review", methods=["POST"])
@login_required
def course_review(course_id):
    user = get_current_user()
    rating = int(request.form.get("rating", 5))
    review_text = request.form.get("review_text", "").strip()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM course_reviews WHERE course_id = ? AND student_id = ?", (course_id, user["id"]))
    cursor.execute("""
    INSERT INTO course_reviews (course_id, student_id, rating, comment, status)
    VALUES (?, ?, ?, ?, 'visible')
    """, (course_id, user["id"], max(1, min(5, rating)), review_text))
    conn.commit()
    conn.close()
    flash("Cảm ơn bạn đã gửi đánh giá khóa học!", "success")
    return redirect(url_for("course_detail", course_id=course_id))

@app.route("/courses/<int:course_id>/goal", methods=["POST"])
@login_required
def course_goal(course_id):
    user = get_current_user()
    days_per_week = int(request.form.get("days_per_week", 3))
    target_date = request.form.get("target_completion_date", "")
    reminder_time = request.form.get("reminder_time", "20:00")
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM learning_goals WHERE student_id = ? AND course_id = ?", (user["id"], course_id))
    cursor.execute("""
    INSERT INTO learning_goals (student_id, course_id, sessions_per_week, target_completion_date, reminder_time, email_reminder_enabled)
    VALUES (?, ?, ?, ?, ?, 1)
    """, (user["id"], course_id, days_per_week, target_date or None, reminder_time))
    conn.commit()
    conn.close()
    flash("Mục tiêu học tập và nhắc nhở đã được thiết lập thành công!", "success")
    return redirect(url_for("course_detail", course_id=course_id))

@app.route("/submissions/<int:submission_id>/regrade", methods=["POST"])
@login_required
def request_regrade(submission_id):
    user = get_current_user()
    reason = request.form.get("reason", "").strip()
    if not reason:
        flash("Vui lòng ghi rõ lý do đề nghị phúc khảo bài nộp.", "danger")
        return redirect(url_for("submission_detail", submission_id=submission_id))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT exercise_id FROM submissions WHERE id = ? AND student_id = ?", (submission_id, user["id"]))
    sub = cursor.fetchone()
    if not sub:
        conn.close()
        abort(404)

    cursor.execute("""
    INSERT INTO regrade_requests (submission_id, student_id, exercise_id, reason, status)
    VALUES (?, ?, ?, ?, 'pending')
    """, (submission_id, user["id"], sub["exercise_id"], reason))
    conn.commit()
    conn.close()
    flash("Yêu cầu phúc khảo đã được gửi thành công tới Ban Chuyên môn!", "success")
    return redirect(url_for("submission_detail", submission_id=submission_id))

@app.route("/certificate/verify")
def verify_certificate():
    return render_template("learner/certificate_verify.html", cert=None, cert_code=None)

@app.route("/certificate/verify/<code>")
def verify_certificate_code(code):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT cert.*, u.full_name as student_name, c.title as course_title
    FROM certificates cert
    JOIN users u ON cert.student_id = u.id
    JOIN courses c ON cert.course_id = c.id
    WHERE cert.certificate_code = ?
    """, (code,))
    cert = cursor.fetchone()
    conn.close()
    return render_template("learner/certificate_verify.html", cert=dict(cert) if cert else None, cert_code=code)

@app.route("/certificate/verify-query")
def verify_certificate_query():
    code = request.args.get("code", "").strip()
    if not code:
        return redirect(url_for("verify_certificate"))
    return redirect(url_for("verify_certificate_code", code=code))

# --- Phân hệ Chuyên gia: Đánh giá bất thường, Phúc khảo, Kiểm thử đáp án mẫu, Nạp Zip test cases ---
@app.route("/expert/abnormal-submissions")
@role_required("expert", "admin")
def expert_abnormal_submissions():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT s.*, u.full_name as student_name, u.username, e.title as exercise_title
    FROM submissions s
    JOIN users u ON s.student_id = u.id
    JOIN exercises e ON s.exercise_id = e.id
    WHERE s.anomaly_flag = 1 OR s.anomaly_status = 'pending_review'
    ORDER BY s.id DESC
    """)
    submissions = []
    for r in cursor.fetchall():
        s_dict = dict(r)
        try:
            tdata = json.loads(s_dict.get("typing_data_json") or "{}")
            s_dict["paste_count"] = tdata.get("paste_count", 0)
            s_dict["keystroke_count"] = tdata.get("keystrokes", 0)
            s_dict["tab_blurs"] = tdata.get("tab_blurs", 0)
        except Exception:
            s_dict["paste_count"] = 1
            s_dict["keystroke_count"] = 0
            s_dict["tab_blurs"] = 0
        submissions.append(s_dict)
    conn.close()
    return render_template("expert/abnormal_review.html", submissions=submissions)

@app.route("/expert/submission/<int:submission_id>/review-anomaly", methods=["POST"])
@role_required("expert", "admin")
def expert_review_anomaly(submission_id):
    user = get_current_user()
    decision = request.form.get("decision", "verified_human")
    notes = request.form.get("notes", "").strip()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    UPDATE submissions
    SET anomaly_status = ?, anomaly_review_notes = ?, anomaly_reviewer_id = ?
    WHERE id = ?
    """, (decision, notes, user["id"], submission_id))
    conn.commit()
    conn.close()
    flash(f"Đã cập nhật đánh giá bài nộp: {decision}", "success")
    return redirect(url_for("expert_abnormal_submissions"))

@app.route("/expert/regrades")
@role_required("expert", "admin")
def expert_regrades():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT r.*, u.full_name as student_name, e.title as exercise_title,
           s.score as current_score, s.status as current_status
    FROM regrade_requests r
    JOIN users u ON r.student_id = u.id
    JOIN exercises e ON r.exercise_id = e.id
    JOIN submissions s ON r.submission_id = s.id
    ORDER BY r.id DESC
    """)
    regrades = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return render_template("expert/regrade_list.html", regrades=regrades)

@app.route("/expert/regrade/<int:regrade_id>/resolve", methods=["POST"])
@role_required("expert", "admin")
def expert_resolve_regrade(regrade_id):
    user = get_current_user()
    decision = request.form.get("decision", "rejected")
    notes = request.form.get("notes", "").strip()
    new_score = request.form.get("new_score")

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT submission_id FROM regrade_requests WHERE id = ?", (regrade_id,))
    req_row = cursor.fetchone()
    if not req_row:
        conn.close()
        abort(404)

    if decision == "approved" and new_score is not None:
        new_score_val = float(new_score)
        status_update = "Accepted" if new_score_val >= 10.0 else "Partial"
        cursor.execute("UPDATE submissions SET score = ?, status = ? WHERE id = ?", (new_score_val, status_update, req_row["submission_id"]))

    cursor.execute("""
    UPDATE regrade_requests
    SET status = ?, reviewer_id = ?, reviewer_notes = ?, reviewed_at = CURRENT_TIMESTAMP
    WHERE id = ?
    """, (decision, user["id"], notes, regrade_id))
    conn.commit()
    conn.close()
    flash("Đã hoàn tất xử lý yêu cầu phúc khảo!", "success")
    return redirect(url_for("expert_regrades"))

@app.route("/expert/exercise/<int:exercise_id>/test-solution", methods=["POST"])
@role_required("expert", "admin")
def expert_test_solution(exercise_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT reference_solution, time_limit, points FROM exercises WHERE id = ?", (exercise_id,))
    ex = cursor.fetchone()
    if not ex or not ex["reference_solution"]:
        conn.close()
        flash("Bài tập chưa có mã nguồn lời giải mẫu.", "warning")
        return redirect(url_for("expert_exercise_edit", exercise_id=exercise_id))

    cursor.execute("SELECT * FROM test_cases WHERE exercise_id = ? ORDER BY order_index ASC", (exercise_id,))
    test_cases = [dict(r) for r in cursor.fetchall()]
    if not test_cases:
        conn.close()
        flash("Chưa có bộ test case để kiểm tra lời giải mẫu.", "warning")
        return redirect(url_for("expert_testcases", exercise_id=exercise_id))

    res = judge_submission(
        source_code=ex["reference_solution"],
        test_cases=test_cases,
        language="C++",
        time_limit=ex["time_limit"],
        max_points=ex["points"]
    )
    if res["status"] == "Accepted":
        cursor.execute("UPDATE exercises SET reference_solution_tested = 1 WHERE id = ?", (exercise_id,))
        conn.commit()
        flash(f"Lời giải mẫu đã vượt qua 100% test cases ({res['passed_tests']}/{res['total_tests']})! Đã xác nhận đạt chuẩn.", "success")
    else:
        flash(f"Lời giải mẫu chưa đạt 100% ({res['status']} - {res['passed_tests']}/{res['total_tests']} tests). Vui lòng kiểm tra lại code mẫu.", "danger")
    conn.close()
    return redirect(url_for("expert_exercise_edit", exercise_id=exercise_id))

@app.route("/expert/exercise/<int:exercise_id>/upload-testcases-zip", methods=["POST"])
@role_required("expert", "admin")
def expert_upload_testcases_zip(exercise_id):
    if 'zip_file' not in request.files:
        flash("Vui lòng chọn file zip chứa bộ test case.", "danger")
        return redirect(url_for("expert_testcases", exercise_id=exercise_id))
    f = request.files['zip_file']
    if not f.filename.endswith('.zip'):
        flash("File tải lên phải có định dạng .zip.", "danger")
        return redirect(url_for("expert_testcases", exercise_id=exercise_id))

    conn = get_db()
    cursor = conn.cursor()
    count = 0
    try:
        with zipfile.ZipFile(f) as z:
            names = z.namelist()
            in_files = sorted([n for n in names if n.endswith('.in')])
            for in_name in in_files:
                base = in_name[:-3]
                out_name = base + '.out'
                if out_name in names:
                    in_content = z.read(in_name).decode('utf-8', errors='ignore')
                    out_content = z.read(out_name).decode('utf-8', errors='ignore')
                    cursor.execute("""
                    INSERT INTO test_cases (exercise_id, input_data, expected_output, points, is_hidden, order_index)
                    VALUES (?, ?, ?, 2.0, 1, ?)
                    """, (exercise_id, in_content, out_content, count + 1))
                    count += 1
        conn.commit()
        flash(f"Đã nạp thành công {count} cặp test case từ file zip!", "success")
    except Exception as e:
        flash(f"Lỗi khi đọc file zip: {str(e)}", "danger")
    conn.close()
    return redirect(url_for("expert_testcases", exercise_id=exercise_id))

# --- Phân hệ Kiểm duyệt Diễn đàn (Moderator) ---
@app.route("/moderator/queue")
@role_required("moderator", "admin")
def moderator_queue():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT t.*, u.full_name as author_name, c.name as category_name
    FROM forum_threads t
    JOIN users u ON t.user_id = u.id
    LEFT JOIN forum_categories c ON t.category_id = c.id
    WHERE t.moderation_status = 'pending'
    ORDER BY t.id DESC
    """)
    pending_threads = [dict(r) for r in cursor.fetchall()]

    cursor.execute("""
    SELECT r.*, u.full_name as author_name, t.title as thread_title
    FROM forum_replies r
    JOIN users u ON r.user_id = u.id
    JOIN forum_threads t ON r.thread_id = t.id
    WHERE r.moderation_status = 'pending'
    ORDER BY r.id DESC
    """)
    pending_replies = [dict(r) for r in cursor.fetchall()]

    cursor.execute("SELECT COUNT(*) FROM forum_reports WHERE status = 'pending'")
    report_count = cursor.fetchone()[0]

    conn.close()
    return render_template("moderator/queue.html",
                           pending_threads=pending_threads,
                           pending_replies=pending_replies,
                           report_count=report_count)

@app.route("/moderator/thread/<int:thread_id>/action", methods=["POST"])
@role_required("moderator", "admin")
def moderator_thread_action(thread_id):
    user = get_current_user()
    action = request.form.get("action", "approve")
    reject_reason = request.form.get("reject_reason", "").strip()

    new_status = "approved" if action == "approve" else "rejected"
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    UPDATE forum_threads
    SET moderation_status = ?, moderated_by = ?, reject_reason = ?
    WHERE id = ?
    """, (new_status, user["id"], reject_reason if action != "approve" else None, thread_id))
    conn.commit()
    conn.close()
    log_audit(user["id"], f"forum_thread_{action}", "forum_threads", thread_id, reject_reason)
    flash(f"Đã { 'phê duyệt' if action == 'approve' else 'từ chối' } bài thảo luận #{thread_id}.", "success")
    return redirect(url_for("moderator_queue"))

@app.route("/moderator/reply/<int:reply_id>/action", methods=["POST"])
@role_required("moderator", "admin")
def moderator_reply_action(reply_id):
    user = get_current_user()
    action = request.form.get("action", "approve")
    reject_reason = request.form.get("reject_reason", "").strip()

    new_status = "approved" if action == "approve" else "rejected"
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    UPDATE forum_replies
    SET moderation_status = ?, moderated_by = ?, reject_reason = ?
    WHERE id = ?
    """, (new_status, user["id"], reject_reason if action != "approve" else None, reply_id))
    conn.commit()
    conn.close()
    log_audit(user["id"], f"forum_reply_{action}", "forum_replies", reply_id, reject_reason)
    flash(f"Đã { 'phê duyệt' if action == 'approve' else 'từ chối' } phản hồi #{reply_id}.", "success")
    return redirect(url_for("moderator_queue"))

@app.route("/moderator/reports")
@role_required("moderator", "admin")
def moderator_reports():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT rep.*, u.full_name as reporter_name
    FROM forum_reports rep
    JOIN users u ON rep.user_id = u.id
    ORDER BY rep.id DESC
    """)
    reports = [dict(r) for r in cursor.fetchall()]
    conn.close()
    return render_template("moderator/reports.html", reports=reports)

@app.route("/moderator/report/<int:report_id>/resolve", methods=["POST"])
@role_required("moderator", "admin")
def moderator_resolve_report(report_id):
    user = get_current_user()
    action = request.form.get("action", "resolve")
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM forum_reports WHERE id = ?", (report_id,))
    rep = cursor.fetchone()
    if not rep:
        conn.close()
        abort(404)

    if action == "resolve":
        if rep.get("target_type") == "thread":
            cursor.execute("UPDATE forum_threads SET status = 'hidden', moderation_status = 'hidden' WHERE id = ?", (rep["target_id"],))
        elif rep.get("target_type") == "reply":
            cursor.execute("UPDATE forum_replies SET moderation_status = 'hidden' WHERE id = ?", (rep["target_id"],))
        new_status = "resolved"
    else:
        new_status = "dismissed"

    cursor.execute("UPDATE forum_reports SET status = ? WHERE id = ?", (new_status, report_id))
    conn.commit()
    conn.close()
    flash("Đã xử lý xong báo cáo vi phạm!", "success")
    return redirect(url_for("moderator_reports"))

# --- Phân hệ Quản trị viên (Admin): Danh mục chủ đề, Sức khỏe hệ thống, Sao lưu & Khôi phục ---
@app.route("/admin/topics", methods=["GET", "POST"])
@role_required("admin")
def admin_topics():
    conn = get_db()
    cursor = conn.cursor()
    if request.method == "POST":
        name = request.form.get("name", "").strip()
        slug = request.form.get("slug", "").strip()
        description = request.form.get("description", "").strip()
        if name and slug:
            cursor.execute("""
            INSERT INTO programming_topics (name, slug, description, status, order_index)
            VALUES (?, ?, ?, 'active', (SELECT COALESCE(MAX(order_index), 0) + 1 FROM programming_topics))
            """, (name, slug, description))
            conn.commit()
            flash("Đã thêm chủ đề lập trình mới thành công!", "success")

    cursor.execute("SELECT * FROM programming_topics ORDER BY order_index ASC")
    topics = [dict(r) for r in cursor.fetchall()]
    conn.close()
    return render_template("admin/topics.html", topics=topics)

@app.route("/admin/topics/toggle/<int:topic_id>", methods=["POST"])
@role_required("admin")
def admin_toggle_topic(topic_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT status FROM programming_topics WHERE id = ?", (topic_id,))
    top = cursor.fetchone()
    if top:
        new_st = "hidden" if top["status"] == "active" else "active"
        cursor.execute("UPDATE programming_topics SET status = ? WHERE id = ?", (new_st, topic_id))
        conn.commit()
        flash(f"Đã chuyển trạng thái chủ đề thành: {new_st}", "info")
    conn.close()
    return redirect(url_for("admin_topics"))

@app.route("/admin/topics/merge", methods=["POST"])
@role_required("admin")
def admin_merge_topics():
    source_id = request.form.get("source_id")
    target_id = request.form.get("target_id")
    if not source_id or not target_id or source_id == target_id:
        flash("Vui lòng chọn 2 chủ đề khác nhau để gộp.", "danger")
        return redirect(url_for("admin_topics"))

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT slug FROM programming_topics WHERE id = ?", (target_id,))
    target_topic = cursor.fetchone()
    cursor.execute("SELECT slug FROM programming_topics WHERE id = ?", (source_id,))
    source_topic = cursor.fetchone()

    if target_topic and source_topic:
        cursor.execute("UPDATE exercises SET topic = ? WHERE topic = ?", (target_topic["slug"], source_topic["slug"]))
        cursor.execute("UPDATE programming_topics SET status = 'merged' WHERE id = ?", (source_id,))
        conn.commit()
        flash(f"Đã gộp thành công chủ đề '{source_topic['slug']}' vào '{target_topic['slug']}'!", "success")
    conn.close()
    return redirect(url_for("admin_topics"))

@app.route("/admin/system-health")
@role_required("admin")
def admin_system_health():
    import time
    db_type = "sqlserver"
    latency_ms = 1.0
    t0 = time.time()
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM users")
    cursor.fetchone()
    latency_ms = round((time.time() - t0) * 1000, 2)

    cursor.execute("SELECT * FROM system_alerts ORDER BY id DESC")
    alerts = [dict(r) for r in cursor.fetchall()]
    conn.close()

    total, used, free = shutil.disk_usage("C:\\")
    disk_free_gb = round(free / (1024**3), 1)

    return render_template("admin/system_health.html",
                           db_type=db_type,
                           latency_ms=latency_ms,
                           disk_free_gb=disk_free_gb,
                           alerts=alerts)

@app.route("/admin/backups")
@role_required("admin")
def admin_backups():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM system_backups ORDER BY id DESC")
    backups = [dict(r) for r in cursor.fetchall()]
    conn.close()
    return render_template("admin/backups.html", backups=backups)

@app.route("/admin/backups/create", methods=["POST"])
@role_required("admin")
def admin_create_backup():
    backup_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backups")
    os.makedirs(backup_dir, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"codebeginner_backup_{ts}.sql"
    filepath = os.path.join(backup_dir, filename)

    src_sql = os.path.join(os.path.dirname(os.path.abspath(__file__)), "codebeginner_sqlserver.sql")
    if os.path.exists(src_sql):
        shutil.copyfile(src_sql, filepath)
    else:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(f"-- CodeBeginner Backup Snapshot created at {datetime.now().isoformat()}\n")

    size_bytes = os.path.getsize(filepath)
    conn = get_db()
    cursor = conn.cursor()
    user = get_current_user()
    cursor.execute("""
    INSERT INTO system_backups (filename, file_size_bytes, backup_type, status, notes, created_by)
    VALUES (?, ?, 'full', 'success', '', ?)
    """, (filename, size_bytes, user["id"] if user else None))
    conn.commit()
    conn.close()

    flash(f"Tạo bản sao lưu thành công: {filename} ({size_bytes // 1024} KB)!", "success")
    return redirect(url_for("admin_backups"))

@app.route("/admin/backups/<int:backup_id>/download")
@role_required("admin")
def admin_download_backup(backup_id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT filename FROM system_backups WHERE id = ?", (backup_id,))
    b = cursor.fetchone()
    conn.close()
    backup_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backups")
    filepath = os.path.join(backup_dir, b["filename"]) if b else None
    if not filepath or not os.path.exists(filepath):
        flash("Tập tin sao lưu không tồn tại trên máy chủ.", "danger")
        return redirect(url_for("admin_backups"))
    return send_file(filepath, as_attachment=True, download_name=b["filename"])


# ==========================================
# ERROR HANDLERS
# ==========================================

@app.errorhandler(403)
def forbidden_error(error):
    return render_template("errors/403.html"), 403

@app.errorhandler(404)
def not_found_error(error):
    return render_template("errors/404.html"), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template("errors/500.html"), 500

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)
