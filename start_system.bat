@echo off
chcp 65001 >nul
echo.
echo ═══════════════════════════════════════════════════════
echo   نظام إدارة المبيعات - SQL Server 2008
echo   Sales Management System
echo ═══════════════════════════════════════════════════════
echo.

echo [1/3] 📡 بدء تشغيل REST API Server...
cd backend
start "API Server" cmd /k "node server.js"
timeout /t 3 /nobreak >nul

echo [2/3] ⏳ انتظار تشغيل API...
timeout /t 2 /nobreak >nul

echo [3/3] 🚀 تشغيل تطبيق Flutter...
cd ..
flutter run -d windows

pause
