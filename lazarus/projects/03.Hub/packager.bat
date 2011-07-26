..\strip c:\lazout\xpl_hub.exe
..\upx c:\lazout\xpl_hub.exe
md xpl_hub_win
copy  c:\lazout\xpl_hub.exe .\xpl_hub_win
copy readme*.* .\xpl_hub_win
copy ..\..\lic*.txt .\xpl_hub_win
copy ..\..\cre*.txt .\xpl_hub_win


