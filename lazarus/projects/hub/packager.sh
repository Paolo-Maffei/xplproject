mkdir xpl_hub_lin
cp ../../../lazout/xpl_hub ./xpl_hub_lin/
strip ./xpl_hub_lin/xpl_hub
 # upx  ./xpl_hub_lin/xpl_hub   
cp readme*.* ./xpl_hub_lin/
cp ../license*.* ./xpl_hub_lin/
tar -cf xpl_hub_lin.tar ./xpl_hub_lin
gzip xpl_hub_lin.tar

