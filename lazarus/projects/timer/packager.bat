..\strip xpl_timer.exe
..\upx xpl_timer.exe
md xpl_timer_win
copy  xpl_timer.exe .\xpl_timer_win
copy readme*.* .\xpl_timer_win
copy ..\sender\timer.*.xpl .\xpl_timer_win
copy ..\sender\xpl_sender_win\xpl_sender.exe .\xpl_timer_win
