@echo off
setlocal
chcp 65001 >nul
title Trun Game Free Mega - Installer Links
cd /d "%~dp0"
echo =====================================================
echo           TRUN GAME FREE MEGA - INSTALLER LINKS
echo =====================================================
echo.
echo This installer creates a personal shortcut for this PC.
echo No administrator permission is required.
echo.
if not exist "%~dp0Installer Links.ps1" (
    echo ERROR: Installer Links.ps1 was not found.
    pause
    exit /b 1
)
powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0Installer Links.ps1"
if errorlevel 1 (
    echo.
    echo Installation failed. Read the error above.
    pause
    exit /b 1
)
echo.
echo Installation complete. Your personalized shortcut is ready.
echo.
pause
exit /b 0
