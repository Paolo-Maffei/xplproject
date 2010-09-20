..\strip c:\lazout\frog\xpl_frog.exe
..\upx c:\lazout\frog\xpl_frog.exe
md xpl_frog_win
copy  c:\lazout\frog\xpl_frog.exe .\xpl_frog_win
copy readme*.* .\xpl_frog_win
copy ..\lic*.* .\xpl_frog_win
