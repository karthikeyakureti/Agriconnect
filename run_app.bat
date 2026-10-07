@echo off
cd /d "%~dp0"
title AgriConnect App Launcher

echo ===================================================================
echo                     AgriConnect All-In-One Launcher
echo ===================================================================
echo.
echo Choose what you want to do:
echo.
echo   [1] Start Backend Server & Cloudflare Tunnel
echo   [2] Run Flutter App in Google Chrome (Web)
echo   [3] Run Flutter App on connected Phone / Device
echo   [4] Build New Release APK for Android Phone
echo   [5] Run Everything (Backend + Chrome App)
echo   [0] Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto start_backend
if "%choice%"=="2" goto run_chrome
if "%choice%"=="3" goto run_device
if "%choice%"=="4" goto build_apk
if "%choice%"=="5" goto run_all
if "%choice%"=="0" exit
goto invalid

:start_backend
echo.
echo Launching backend server and tunnel...
call "%~dp0backend\run_server_and_tunnel.bat"
goto end

:run_chrome
echo.
echo Launching Flutter app in Google Chrome...
flutter run -d chrome
goto end

:run_device
echo.
echo Launching Flutter app on connected Android phone...
flutter run
goto end

:build_apk
echo.
echo Building release APK for Android phone...
flutter build apk --release
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /y "build\app\outputs\flutter-apk\app-release.apk" "%~dp0AgriConnect.apk"
    echo.
    echo [SUCCESS] APK built and updated at: %~dp0AgriConnect.apk
    echo You can transfer AgriConnect.apk to your phone and install it!
)
pause
goto end

:run_all
echo.
echo [1/2] Starting Backend & Tunnel in background windows...
start "" "%~dp0backend\run_server_and_tunnel.bat"
timeout /t 5 /nobreak >nul
echo [2/2] Starting Flutter App in Chrome...
flutter run -d chrome
goto end

:invalid
echo.
echo Invalid option selected!
pause

:end
