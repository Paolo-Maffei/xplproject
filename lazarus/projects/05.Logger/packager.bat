..\strip c:\lazout\xpl_logger.exe
..\upx c:\lazout\xpl_logger.exe
md xpl_logger_win
copy  c:\lazout\xpl_logger.exe .\xpl_logger_win
copy readme*.* .\xpl_logger_win
copy ..\lic*.* .\xpl_logger_win
copy ..\cre*.* .\xpl_logger_win
