..\strip c:\lazout\app_vendor_files.exe
..\upx c:\lazout\app_vendor_files.exe
md app_vendor_files
copy  c:\lazout\app_vendor_files.exe .\app_vendor_files
copy readme*.* .\app_vendor_files
copy ..\..\lic*.txt .app_vendor_files
copy ..\..\cre*.txt .app_vendor_files


