mkdir xpl_logger_lin
cp ../../../lazout/xpl_logger ./xpl_logger_lin/
strip ./xpl_logger_lin/xpl_logger
 # upx  ./xpl_logger_lin/xpl_logger   
cp readme*.* ./xpl_logger_lin/
cp license*.* ./xpl_logger_lin/
tar -cf xpl_logger_lin.tar ./xpl_logger_lin
gzip xpl_logger_lin.tar

