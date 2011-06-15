mkdir xpl_nntp_lin
cp ../../../lazout/xpl_nntp ./xpl_nntp_lin/
strip ./xpl_nntp_lin/xpl_nntp
 # upx  ./xpl_nntp_lin/xpl_nntp   
cp readme*.* ./xpl_nntp_lin/
cp ../license*.* ./xpl_nntp_lin/
tar -cf xpl_nntp_lin.tar ./xpl_nntp_lin
gzip xpl_nntp_lin.tar

