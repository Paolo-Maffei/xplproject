mkdir xpl_calevent_lin
cp ../../../lazout/xpl_calevent ./xpl_calevent_lin/
strip ./xpl_calevent_lin/xpl_calevent
 # upx  ./xpl_calevent_lin/xpl_calevent   
cp readme*.* ./xpl_calevent_lin/
cp ../license*.* ./xpl_calevent_lin/
tar -cf xpl_calevent_lin.tar ./xpl_calevent_lin
gzip xpl_calevent_lin.tar

