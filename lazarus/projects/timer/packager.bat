..\strip c:\lazout\timer\xpl_timer.exe
..\upx c:\lazout\timer\xpl_timer.exe
md xpl_timer_win
copy  c:\lazout\timer\xpl_timer.exe .\xpl_timer_win
copy readme*.* .\xpl_timer_win
rem copy ..\sender\timer.*.xpl .\xpl_timer_win
rem copy ..\sender\xpl_sender_win\xpl_sender.exe .\xpl_timer_win
