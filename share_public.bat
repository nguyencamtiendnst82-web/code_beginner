@echo off
title CodeBeginner - Chia Se Link Cong Khai Toan Cau
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================================
echo       🌐 CODEBEGINNER - PUBLIC CLOUDFLARE LINK 🌐
echo ========================================================
echo.
echo [*] Dang tao link cong khai toan cau cho CodeBeginner...
echo [*] Link co the truy cap tu dien thoai, may tinh khac o bat ky dau!
echo.
cloudflared.exe tunnel --url http://127.0.0.1:5000
pause
