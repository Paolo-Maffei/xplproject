copy "c:\Program Files\Lua\5.1\lua\xpl*.lua" src\
xcopy "c:\Program Files\Lua\5.1\lua\xpl\*.*" src\xpl\ /Y/E
"c:\Program Files\Lua\5.1\lua\luadoc_start.lua" -d doc src > luadoc_output.txt
type luadoc_output.txt
start doc\index.html
pause



