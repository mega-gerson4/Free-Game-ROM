' Optional starter: launch the same .bat without briefly displaying the black console.
Set sh = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
base = fs.GetParentFolderName(WScript.ScriptFullName)
command = "cmd.exe /c " & Chr(34) & Chr(34) & base & "\Trun-Game-Free-Mega.bat" & Chr(34) & Chr(34)
sh.Run command, 0, False
