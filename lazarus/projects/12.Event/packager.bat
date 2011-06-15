..\strip c:\lazout\xpl_event.exe
..\upx c:\lazout\xpl_event.exe
md xpl_event_win
copy  c:\lazout\xpl_event.exe .\xpl_event_win
copy readme*.* .\xpl_event_win
copy ..\lic*.* .\xpl_event_win
rem copy ..\sender\event.*.xpl .\xpl_event_win
rem copy ..\sender\xpl_sender_win\xpl_sender.exe .\xpl_event_win
