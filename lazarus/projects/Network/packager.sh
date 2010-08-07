mkdir xpl_network_lin
cp ../../../lazout/\xpl_network ./xpl_network_lin/
strip ./xpl_network_lin/xpl_network
upx  ./xpl_network_lin/xpl_network
cp readme*.* ./xpl_network_lin/
cp license*.* ./xpl_network_lin/
tar -cf xpl_network_lin.tar ./xpl_network_lin
gzip xpl_network_lin.tar

