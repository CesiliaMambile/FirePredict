@echo off
echo Starting FirePredict Backend Server...
echo API docs will be available at: http://localhost:8080/docs
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
pause
