..\strip xpl_ping.exe
..\upx xpl_ping.exe
md xpl_ping_win
copy  xpl_ping.exe .\xpl_ping_win
copy  xpl_clinique-ping.xml .\xpl_ping_win
copy readme*.* .\xpl_ping_win
copy ..\sender\ping.*.xpl .\xpl_ping_win
copy ..\sender\xpl_sender_win\xpl_sender.exe .\xpl_ping_win
