..\strip c:\lazout\opc\xpl_opc.exe
..\upx c:\lazout\opc\xpl_opc.exe
md xpl_opc_win
copy  c:\lazout\opc\xpl_opc.exe .\xpl_opc_win
copy readme*.* .\xpl_opc_win
copy ..\lic*.* .\xpl_opc_win
