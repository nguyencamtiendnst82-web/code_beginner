import json
from database import get_db

CORE_TOPICS = [
    "Biến và kiểu dữ liệu",
    "Nhập/xuất",
    "Toán tử",
    "If/Else",
    "Vòng lặp",
    "Mảng",
    "Chuỗi",
    "Hàm"
]

def evaluate_entrance_test(student_id, answers):
    """
    answers: dict dạng {str(question_id): int(selected_option_index)}
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT id, topic, question_text, code_snippet, options_json, correct_answer, explanation FROM entrance_questions ORDER BY id ASC")
    questions = cursor.fetchall()

    if not questions:
        conn.close()
        return None

    total_questions = len(questions)
    correct_count = 0

    topic_stats = {t: {"total": 0, "correct": 0} for t in CORE_TOPICS}
    details = []

    for q in questions:
        qid = q['id']
        topic = q['topic']
        correct_ans = q['correct_answer']
        options = json.loads(q['options_json']) if isinstance(q['options_json'], str) else q['options_json']

        if topic not in topic_stats:
            topic_stats[topic] = {"total": 0, "correct": 0}

        topic_stats[topic]["total"] += 1

        user_ans = answers.get(str(qid))
        user_ans_int = int(user_ans) if user_ans is not None else None
        is_correct = (user_ans_int == correct_ans) if user_ans_int is not None else False

        if is_correct:
            correct_count += 1
            topic_stats[topic]["correct"] += 1

        details.append({
            "question_id": qid,
            "topic": topic,
            "question_text": q['question_text'],
            "code_snippet": q['code_snippet'] or "",
            "options": options,
            "user_answer": user_ans_int,
            "user_answer_text": options[user_ans_int] if user_ans_int is not None and 0 <= user_ans_int < len(options) else "Chưa chọn",
            "correct_answer": correct_ans,
            "correct_answer_text": options[correct_ans] if 0 <= correct_ans < len(options) else "",
            "is_correct": is_correct,
            "explanation": q['explanation'] or ""
        })

    percentage = round((correct_count / total_questions) * 100, 1)

    # Tính tỷ lệ theo từng chủ đề
    topic_breakdown = {}
    weak_topics = []
    strong_topics = []

    for topic, stats in topic_stats.items():
        if stats["total"] > 0:
            pct = round((stats["correct"] / stats["total"]) * 100, 1)
            topic_breakdown[topic] = pct
            if pct < 60:
                weak_topics.append(topic)
            elif pct >= 80:
                strong_topics.append(topic)
        else:
            topic_breakdown[topic] = 0

    # Tạo tóm tắt và kết luận
    summary_parts = []
    if strong_topics:
        summary_parts.append(f"Bạn đã nắm vững các chủ đề: {', '.join(strong_topics)}.")
    if weak_topics:
        summary_parts.append(f"Các kiến thức còn yếu cần củng cố gồm: {', '.join(weak_topics)}.")
    else:
        summary_parts.append("Bạn có nền tảng cơ bản rất tốt ở tất cả các chủ đề!")

    summary = " ".join(summary_parts)

    # Lưu kết quả kiểm tra
    cursor.execute("""
    INSERT INTO entrance_test_results (student_id, total_score, max_score, percentage, topic_breakdown_json, weak_topics_json, summary, details_json)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (student_id, correct_count, total_questions, percentage, json.dumps(topic_breakdown, ensure_ascii=False), json.dumps(weak_topics, ensure_ascii=False), summary, json.dumps(details, ensure_ascii=False)))
    
    test_result_id = cursor.lastrowid

    # Cập nhật topic_weaknesses cho học viên
    for topic, pct in topic_breakdown.items():
        stats = topic_stats.get(topic, {"total": 0, "correct": 0})
        cursor.execute("SELECT total_attempts, correct_attempts FROM topic_weaknesses WHERE student_id = ? AND topic = ?", (student_id, topic))
        curr = cursor.fetchone()
        if curr:
            cursor.execute("""
            UPDATE topic_weaknesses
            SET mastery_percentage = ?, total_attempts = total_attempts + ?, correct_attempts = correct_attempts + ?, updated_at = CURRENT_TIMESTAMP
            WHERE student_id = ? AND topic = ?
            """, (pct, stats["total"], stats["correct"], student_id, topic))
        else:
            cursor.execute("""
            INSERT INTO topic_weaknesses (student_id, topic, mastery_percentage, total_attempts, correct_attempts, updated_at)
            VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            """, (student_id, topic, pct, stats["total"], stats["correct"]))

    conn.commit()
    conn.close()

    return {
        'id': test_result_id,
        'total_score': correct_count,
        'max_score': total_questions,
        'percentage': percentage,
        'topic_breakdown': topic_breakdown,
        'weak_topics': weak_topics,
        'strong_topics': strong_topics,
        'summary': summary
    }

def update_weakness_on_submission(student_id, exercise_id, is_accepted):
    """
    Cập nhật độ thành thạo chủ đề dựa trên kết quả nộp bài thực tế
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT topic FROM exercises WHERE id = ?", (exercise_id,))
    row = cursor.fetchone()
    if not row:
        conn.close()
        return

    topic = row['topic']

    # Lấy dữ liệu hiện tại
    cursor.execute("""
    SELECT total_attempts, correct_attempts FROM topic_weaknesses
    WHERE student_id = ? AND topic = ?
    """, (student_id, topic))
    curr = cursor.fetchone()

    total_attempts = (curr['total_attempts'] + 1) if curr else 1
    correct_attempts = (curr['correct_attempts'] + (1 if is_accepted else 0)) if curr else (1 if is_accepted else 0)
    mastery_pct = round((correct_attempts / total_attempts) * 100, 1)

    if curr:
        cursor.execute("""
        UPDATE topic_weaknesses
        SET mastery_percentage = ?, total_attempts = ?, correct_attempts = ?, updated_at = CURRENT_TIMESTAMP
        WHERE student_id = ? AND topic = ?
        """, (mastery_pct, total_attempts, correct_attempts, student_id, topic))
    else:
        cursor.execute("""
        INSERT INTO topic_weaknesses (student_id, topic, mastery_percentage, total_attempts, correct_attempts, updated_at)
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, (student_id, topic, mastery_pct, total_attempts, correct_attempts))

    conn.commit()
    conn.close()

def get_student_weakness_report(student_id):
    """
    Lấy báo cáo phân tích điểm yếu đầy đủ của học viên
    """
    conn = get_db()
    cursor = conn.cursor()

    # 1. Lấy kết quả kiểm tra đầu vào gần nhất
    cursor.execute("""
    SELECT * FROM entrance_test_results
    WHERE student_id = ?
    ORDER BY created_at DESC LIMIT 1
    """, (student_id,))
    latest_entrance = cursor.fetchone()

    entrance_data = None
    if latest_entrance:
        entrance_data = {
            'total_score': latest_entrance['total_score'],
            'max_score': latest_entrance['max_score'],
            'percentage': latest_entrance['percentage'],
            'topic_breakdown': json.loads(latest_entrance['topic_breakdown_json']),
            'weak_topics': json.loads(latest_entrance['weak_topics_json']),
            'summary': latest_entrance['summary'],
            'created_at': latest_entrance['created_at']
        }

    # 2. Lấy tình trạng điểm yếu hiện tại
    cursor.execute("""
    SELECT topic, mastery_percentage, total_attempts, correct_attempts
    FROM topic_weaknesses
    WHERE student_id = ?
    ORDER BY mastery_percentage ASC
    """, (student_id,))
    weaknesses = [dict(row) for row in cursor.fetchall()]

    # 3. Phân loại chủ đề yếu (mastery < 60) và cần cải thiện
    weak_topic_names = [w['topic'] for w in weaknesses if w['mastery_percentage'] < 60]

    # Nếu chưa có đủ dữ liệu, dùng từ bài test đầu vào
    if not weak_topic_names and entrance_data and entrance_data.get('weak_topics'):
        weak_topic_names = entrance_data['weak_topics']

    # 4. Đề xuất bài học bổ sung
    recommended_lessons = []
    if weak_topic_names:
        placeholders = ', '.join(['?'] * len(weak_topic_names))
        # Tìm bài học có tiêu đề hoặc nội dung liên quan đến chủ đề yếu
        cursor.execute(f"""
        SELECT l.id, l.title, l.course_id, c.title AS course_title
        FROM lessons l
        JOIN courses c ON l.course_id = c.id
        WHERE ({' OR '.join(['l.title LIKE ?' for _ in weak_topic_names])})
        LIMIT 5
        """, [f"%{t}%" for t in weak_topic_names])
        recommended_lessons = [dict(row) for row in cursor.fetchall()]

    # 5. Đề xuất bài tập (ưu tiên mức Dễ trước, rồi đến Trung bình)
    recommended_exercises = []
    if weak_topic_names:
        placeholders = ', '.join(['?'] * len(weak_topic_names))
        cursor.execute(f"""
        SELECT e.id, e.title, e.topic, e.difficulty, e.points
        FROM exercises e
        WHERE e.topic IN ({placeholders}) AND e.status = 'approved'
        ORDER BY CASE e.difficulty WHEN 'Dễ' THEN 1 WHEN 'Trung bình' THEN 2 ELSE 3 END ASC
        LIMIT 6
        """, weak_topic_names)
        recommended_exercises = [dict(row) for row in cursor.fetchall()]

    conn.close()

    return {
        'entrance_data': entrance_data,
        'weaknesses': weaknesses,
        'weak_topic_names': weak_topic_names,
        'recommended_lessons': recommended_lessons,
        'recommended_exercises': recommended_exercises
    }
