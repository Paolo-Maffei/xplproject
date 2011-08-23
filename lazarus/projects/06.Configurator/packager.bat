..\strip c:\lazout\app_configurator.exe
..\upx c:\lazout\app_configurator.exe
md app_configurator_win
copy  c:\lazout\app_configurator.exe .\app_configurator_win
copy readme*.* .\app_configurator_win
copy ..\lic*.* .\app_configurator_win
copy ..\cre*.* .\app_configurator_win
