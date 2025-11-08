@echo off
title Laravel API Server
color 0A

cd /d "%~dp0"

echo ========================================
echo   Sales Management API - Laravel
echo ========================================
echo.
echo Starting server on http://localhost:8000
echo API URL: http://localhost:8000/api
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

php artisan serve --host=0.0.0.0 --port=8000

pause
