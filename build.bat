@echo off
echo ========================================
echo بناء التطبيق للإنتاج
echo ========================================
echo.
echo جاري بناء التطبيق...
echo.
flutter build windows --release
echo.
echo تم البناء بنجاح!
echo الملف موجود في: build\windows\runner\Release
echo.
pause
