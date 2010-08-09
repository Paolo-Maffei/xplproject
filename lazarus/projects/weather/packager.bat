..\strip c:\lazout\weather\xpl_weather.exe
..\upx c:\lazout\weather\xpl_weather.exe
md xpl_weather_win
copy  c:\lazout\weather\xpl_weather.exe .\xpl_weather_win
copy readme*.* .\xpl_weather_win
copy loc_*.txt .\xpl_weather_win
rem copy html .\xpl_weather_win

