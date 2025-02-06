FUNCTION ShellExecuteFile(sFileName as String)
DECLARE INTEGER ShellExecute in shell32.dll Long,String,String,String,String,Long
=ShellExecute(0,"OPEN",sFileName,"","C:\", 1)
ENDFUNC