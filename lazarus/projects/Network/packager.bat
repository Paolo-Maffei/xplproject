..\strip c:\lazout\xpl_network.exe
..\upx   c:\lazout\xpl_network.exe

md xpl_network_win

copy c:\lazout\xpl_network.exe .\xpl_network_win
copy readme*.* .\xpl_network_win
copy ..\lic*.* .\xpl_network_win

