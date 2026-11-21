Option Explicit
Dim sh, fs, base, cmd, scriptPath
Set sh = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
base = fs.GetParentFolderName(WScript.ScriptFullName)
scriptPath = base & "\Launcher Links.ps1"
cmd = "powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & scriptPath & Chr(34)
sh.Run cmd, 0, False
