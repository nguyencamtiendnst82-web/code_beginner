@echo off
title CodeBeginner Server - He Thong Hoc & Luyen Tap Lap Trinh C++
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================================
echo    CodeBeginner - Nền Tảng Học & Luyện Tập Lập Trình
echo ==========================================================
echo.
echo [*] Đang kiểm tra cơ sở dữ liệu và dữ liệu mẫu...
python seed_data.py
echo.
echo ==========================================================
echo    TÀI KHOẢN MẪU DÙNG THỬ:
echo    1. Học viên (Learner) : learner / Learner@123
echo    2. Chuyên gia (Expert): expert  / Expert@123
echo    3. Quản trị (Admin)   : admin   / Admin@123
echo ==========================================================
echo.
echo [*] Đang khởi động máy chủ Flask tại: http://127.0.0.1:5000
echo [*] Nhấn Ctrl+C để dừng máy chủ bất cứ lúc nào.
echo.
python app.py
pause
