@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
set "PYTHONIOENCODING=utf-8"
if defined INFERNUX_PYTHON (
    "%INFERNUX_PYTHON%" launch.py %*
) else if exist "%~dp0.runtime\python313\python.exe" (
    "%~dp0.runtime\python313\python.exe" launch.py %*
) else (
    python launch.py %*
)
set "GAME_EXIT_CODE=%ERRORLEVEL%"
if not "%GAME_EXIT_CODE%"=="0" pause
exit /b %GAME_EXIT_CODE%
