' Claude Code Launcher - Hidden Window Starter
' This VBScript launches the PowerShell GUI without showing a console window

Set objShell = CreateObject("WScript.Shell")
strPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

objShell.Run "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strPath & "\launcher\ClaudeCodeLauncher.ps1""", 0, False
