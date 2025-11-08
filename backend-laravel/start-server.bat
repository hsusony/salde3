@echo off
echo ==========================================
echo   Sales Management System - Laravel API
echo ==========================================
echo.

cd /d "%~dp0"

echo [1/3] Checking PHP...
php --version
if errorlevel 1 (
    echo ERROR: PHP is not installed or not in PATH
    pause
    exit /b 1
)
echo.

echo [2/3] Starting Laravel Development Server...
echo Server will run on: http://localhost:8000
echo API Endpoint: http://localhost:8000/api
echo.
echo Press Ctrl+C to stop the server
echo.

php artisan serve --host=0.0.0.0 --port=8000

pause
