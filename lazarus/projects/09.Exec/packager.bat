..\strip c:\lazout\xpl_exec.exe
..\upx c:\lazout\xpl_exec.exe
md xpl_exec_win
copy  c:\lazout\xpl_exec.exe .\xpl_exec_win
copy readme*.* .\xpl_exec_win
copy ..\lic*.* .\xpl_exec_win
