..\strip ..\..\..\lazout\app_basic_settings.exe
..\upx ..\..\..\lazout\app_basic_settings.exe
md app_basic_settings_win
copy  ..\..\..\lazout\app_basic_settings.exe .\app_basic_settings_win
copy readme*.* .\app_basic_settings_win
copy ..\lic*.* .\app_basic_settings_win
copy ..\cre*.* .\app_basic_settings_win
