..\strip c:\lazout\xpl_balloon.exe
..\upx c:\lazout\xpl_balloon.exe
md xpl_balloon_win
copy  c:\lazout\xpl_balloon.exe .\xpl_balloon_win
copy readme*.* .\xpl_balloon_win
copy ..\lic*.txt .\xpl_balloon_win
copy ..\cre*.txt .\xpl_balloon_win


