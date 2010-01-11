..\strip xpl_sender.exe
..\upx xpl_sender.exe
md xpl_sender_win
copy  xpl_sender.exe .\xpl_sender_win
copy *.xpl .\xpl_sender_win
copy *.xml .\xpl_sender_win
copy readme*.* .\xpl_sender_win

md xpl_sender_src
copy frm_*.pas .\xpl_sender_src
copy frm_*.lfm .\xpl_sender_src
copy *.lrs .\xpl_sender_src
copy *.lpi .\xpl_sender_src
copy *.lpr .\xpl_sender_src
copy *.xml .\xpl_sender_src
copy *.rc  .\xpl_sender_src
copy readme*.* .\xpl_sender_src