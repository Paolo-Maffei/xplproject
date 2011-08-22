..\strip c:\lazout\app_plugin_editor.exe
..\upx c:\lazout\app_plugin_editor.exe
md app_plugin_editor
copy  c:\lazout\app_plugin_editor.exe .\app_plugin_editor
copy readme*.* .app_plugin_editor
copy ..\..\lic*.txt app_plugin_editor
copy ..\..\cre*.txt app_plugin_editor


