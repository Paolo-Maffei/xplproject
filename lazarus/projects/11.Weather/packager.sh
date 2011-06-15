mkdir xpl_weather_lin
cp ../../../lazout/xpl_weather ./xpl_weather_lin/
strip ./xpl_weather_lin/xpl_weather
 # upx  ./xpl_weather_lin/xpl_weather   
cp readme*.* ./xpl_weather_lin/
cp license*.* ./xpl_weather_lin/
tar -cf xpl_weather_lin.tar ./xpl_weather_lin
gzip xpl_weather_lin.tar

