@echo off
setlocal
cd /d "%~dp0"
title Trun Game Free Mega 2.2 - Windows Build
color 0C
echo ==========================================
echo        TRUN GAME FREE MEGA 2.2
echo           WINDOWS INSTALLER
echo ==========================================
echo.
echo The launcher will be created inside THIS project folder.
echo Support files will be hidden after installation.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0windows\InstallerCore.ps1" -Mode Install
set "result=%errorlevel%"
if not "%result%"=="0" (
  echo.
  echo [BUILD FATAL ERROR] Installation could not be completed.
) else (
  echo.
  echo [BUILD SUCCESS] Find "Trun Game Free Mega" in this same folder.
)
echo.
pause
exit /b %result%
