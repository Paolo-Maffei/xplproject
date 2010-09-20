..\strip c:\lazarus\projects\output\xpl_config.exe
..\upx   c:\lazarus\projects\output\xpl_config.exe
md xpl_config_win
copy  c:\lazarus\projects\output\xpl_config.exe .\xpl_config_win
copy readme*.* .\xpl_config_win
copy ..\lic*.* .\xpl_config_win
