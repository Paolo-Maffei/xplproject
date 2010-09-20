..\strip c:\lazout\ftp\xpl_ftp.exe
..\upx c:\lazout\ftp\xpl_ftp.exe
md xpl_ftp_win
copy  c:\lazout\ftp\xpl_ftp.exe .\xpl_ftp_win
copy readme*.* .\xpl_ftp_win
copy ..\lic*.* .\xpl_ftp_win
