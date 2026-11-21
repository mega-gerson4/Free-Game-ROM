@echo off
setlocal
rem Windows 11 launcher - keep all files together.
cd /d "%~dp0"
if not exist "%~dp0Trun-Game-Free-Mega.ps1" (
  echo ERROR: Trun-Game-Free-Mega.ps1 was not found in this folder.
  pause
  exit /b 1
)
start "" powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0Trun-Game-Free-Mega.ps1"
exit /b 0
