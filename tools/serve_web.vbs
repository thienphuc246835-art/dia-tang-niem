' Serves the Flutter web build at http://127.0.0.1:8780 with no console window.
' A copy lives in the Windows Startup folder so the server starts at login.
' Paths go through the ASCII junction C:\src\dtn (VBScript cannot read the
' accented project path).
Set sh = CreateObject("WScript.Shell")
sh.Run """C:\Users\ThinkPad T480s\AppData\Local\Programs\Python\Python312\pythonw.exe"" -m http.server 8780 --bind 127.0.0.1 --directory ""C:\src\dtn\build\web""", 0, False
