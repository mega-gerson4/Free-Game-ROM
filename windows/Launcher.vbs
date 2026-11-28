Option Explicit
Dim wsh, fso, root, cmd
Set wsh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
root = fso.GetParentFolderName(WScript.ScriptFullName)
cmd = "powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & root & "\TrunGameFreeMega.ps1" & Chr(34)
wsh.Run cmd, 0, False
