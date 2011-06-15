..\strip c:\lazout\app_basic_settings.exe
..\upx c:\lazout\app_basic_settings.exe
md app_basic_settings_win
copy  c:\lazout\app_basic_settings.exe .\app_basic_settings_win
copy readme*.* .\app_basic_settings_win
copy ..\lic*.* .\app_basic_settings_win
