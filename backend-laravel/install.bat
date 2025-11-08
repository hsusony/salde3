@echo off
echo ==========================================
echo   تثبيت Laravel Backend
echo ==========================================
echo.

REM فحص PHP
echo [1/4] Checking PHP...
php --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ ERROR: PHP is not installed!
    echo.
    echo Please install PHP first:
    echo 1. Download from: https://windows.php.net/download/
    echo 2. Extract to C:\php
    echo 3. Add to PATH: setx PATH "%%PATH%%;C:\php" /M
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)
echo ✅ PHP is installed
echo.

REM فحص Composer
echo [2/4] Checking Composer...
composer --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ ERROR: Composer is not installed!
    echo.
    echo Please install Composer:
    echo Download from: https://getcomposer.org/download/
    echo.
    pause
    exit /b 1
)
echo ✅ Composer is installed
echo.

REM تثبيت المكتبات
echo [3/4] Installing Laravel dependencies...
echo This may take a few minutes...
composer install
if errorlevel 1 (
    echo.
    echo ❌ ERROR: Failed to install dependencies!
    pause
    exit /b 1
)
echo ✅ Dependencies installed successfully
echo.

REM توليد Application Key
echo [4/4] Generating application key...
php artisan key:generate
if errorlevel 1 (
    echo.
    echo ⚠️  Warning: Could not generate key
)
echo.

echo ==========================================
echo ✅ Installation Complete!
echo ==========================================
echo.
echo Next steps:
echo 1. Edit .env file and set your SQL Server password
echo 2. Run: start-server.bat
echo.
pause
