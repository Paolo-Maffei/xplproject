mkdir xpl_balloon_lin
cp /home/glhopital/lazout/xpl_balloon ./xpl_balloon_lin/
strip ./xpl_balloon_lin/xpl_balloon
 # upx  ./xpl_balloon_lin/xpl_balloon   
cp readme*.* ./xpl_balloon_lin/
cp ../license*.* ./xpl_balloon_lin/
tar -cf xpl_balloon_lin.tar ./xpl_balloon_lin
gzip xpl_balloon_lin.tar

