..\strip xpl_network.exe
..\upx xpl_network.exe
md xpl_network_win
copy  xpl_network.exe .\xpl_network_win
copy readme*.* .\xpl_network_win
copy license*.* .\xpl_network_win

md xpl_network_src
copy frm_*.pas .\xpl_network_src
copy frm_*.lfm .\xpl_network_src
copy *.lrs .\xpl_network_src
copy *.lpi .\xpl_network_src
copy *.lpr .\xpl_network_src
copy *.rc  .\xpl_network_src
copy readme*.*  .\xpl_network_src
copy license*.* .\xpl_network_src
