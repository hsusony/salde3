@echo off
echo ========================================
echo   Laravel Backend - Quick Setup
echo ========================================
echo.

cd /d "%~dp0"

echo Step 1: Installing Composer packages...
echo.
call composer install --no-interaction --prefer-dist --optimize-autoloader 2>nul
if errorlevel 1 (
    echo [ERROR] Composer not found or failed
    echo Please install Composer from: https://getcomposer.org/download
    pause
    exit /b 1
)

echo.
echo Step 2: Generating application key...
php artisan key:generate --force

echo.
echo Step 3: Clearing cache...
php artisan config:clear
php artisan cache:clear

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo To start the server, run:
echo   php artisan serve
echo.
pause
