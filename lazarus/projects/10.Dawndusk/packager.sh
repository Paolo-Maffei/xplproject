mkdir xpl_dawndusk_lin
cp ../../../lazout/xpl_dawndusk ./xpl_dawndusk_lin/
strip ./xpl_dawndusk_lin/xpl_dawndusk
 # upx  ./xpl_dawndusk_lin/xpl_dawndusk   
cp readme*.* ./xpl_dawndusk_lin/
cp ../license*.* ./xpl_dawndusk_lin/
tar -cf xpl_dawndusk_lin.tar ./xpl_dawndusk_lin
gzip xpl_dawndusk_lin.tar

