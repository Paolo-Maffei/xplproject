..\strip c:\lazout\xpl_sender.exe
..\upx c:\lazout\xpl_sender.exe
md xpl_sender_win
copy  c:\lazout\xpl_sender.exe .\xpl_sender_win
copy *.xpl .\xpl_sender_win
copy *.xml .\xpl_sender_win
copy readme*.* .\xpl_sender_win

REM md xpl_sender_src
REM copy frm_*.pas .\xpl_sender_src
REM copy frm_*.lfm .\xpl_sender_src
REM copy *.lrs .\xpl_sender_src
REM copy *.lpi .\xpl_sender_src
REM copy *.lpr .\xpl_sender_src
REM copy *.xml .\xpl_sender_src
REM copy *.rc  .\xpl_sender_src
REM copy readme*.* .\xpl_sender_src