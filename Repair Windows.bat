@echo off
setlocal
cd /d "%~dp0"
title Trun Game Free Mega 2.2 - Windows Repair
color 0C
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0windows\InstallerCore.ps1" -Mode Repair
set "result=%errorlevel%"
if not "%result%"=="0" (
  echo [BUILD FATAL ERROR] Repair failed.
) else (
  echo [BUILD SUCCESS] Launcher restored inside the project folder.
)
pause
exit /b %result%
