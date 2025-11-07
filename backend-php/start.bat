@echo off
title PHP Sales API Server
color 0A

cd /d "%~dp0"

echo ========================================
echo   Sales Management API - PHP
echo ========================================
echo.
echo Starting PHP built-in server...
echo Server: http://localhost:8000
echo API: http://localhost:8000/api
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

REM Check if PHP is installed
php --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: PHP is not installed or not in PATH
    echo.
    echo Please install PHP from:
    echo https://windows.php.net/download
    echo.
    echo Or install XAMPP from:
    echo https://www.apachefriends.org
    echo.
    pause
    exit /b 1
)

REM Start PHP server
php -S localhost:8000 index.php

pause
