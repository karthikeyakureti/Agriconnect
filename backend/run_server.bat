@echo off
cd /d "%~dp0"
echo ========================================================
echo Starting AgriConnect FastAPI Backend Server...
echo API Docs: http://127.0.0.1:8000/docs
echo Database Dashboard: http://127.0.0.1:8000/admin
echo ========================================================
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
