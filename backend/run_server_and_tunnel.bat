@echo off
cd /d "%~dp0"
title AgriConnect Live Server Launcher (Mobile Data & Wi-Fi)
echo ===================================================================
echo           AgriConnect Live Server (Mobile Data & Wi-Fi)
echo ===================================================================
echo [1/2] Launching AgriConnect FastAPI Backend on port 8000...
echo       - Local API Docs: http://127.0.0.1:8000/docs
echo       - Local Wi-Fi:    http://192.168.137.203:8000
echo.
echo [2/2] Launching Cloudflare Live Tunnel (4G, 5G, & Worldwide Access)...
echo ===================================================================
echo.

set "CLOUDFLARED_EXE=cloudflared"
if exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" set "CLOUDFLARED_EXE=C:\Program Files (x86)\cloudflared\cloudflared.exe"
if exist "C:\Program Files\cloudflared\cloudflared.exe" set "CLOUDFLARED_EXE=C:\Program Files\cloudflared\cloudflared.exe"

start "AgriConnect Backend" cmd /k "cd /d "%~dp0" && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 3 /nobreak >nul

start "AgriConnect Cloudflare Tunnel" cmd /k ""%CLOUDFLARED_EXE%" tunnel --protocol http2 --url http://127.0.0.1:8000"

echo Both services launched in separate windows!
echo Look at the "AgriConnect Cloudflare Tunnel" window for your public URL (https://*.trycloudflare.com).
echo Keep both windows open while testing on Mobile Data or Wi-Fi.
echo.
pause
