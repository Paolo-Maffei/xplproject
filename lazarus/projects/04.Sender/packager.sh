mkdir xpl_sender_lin
cp ../../../lazout/xpl_sender ./xpl_sender_lin/
strip ./xpl_sender_lin/xpl_sender
# upx  ./xpl_sender_lin/xpl_sender    No UPX, the exe file doesn't run after
cp readme*.* ./xpl_sender_lin/
cp license*.* ./xpl_sender_lin/
tar -cf xpl_sender_lin.tar ./xpl_sender_lin
gzip xpl_sender_lin.tar

