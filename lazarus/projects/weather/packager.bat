..\strip xpl_weather.exe
..\upx xpl_weather.exe
md xpl_weather_win
copy  xpl_weather.exe .\xpl_weather_win
copy readme*.* .\xpl_weather_win
copy html .\xpl_weather_win

