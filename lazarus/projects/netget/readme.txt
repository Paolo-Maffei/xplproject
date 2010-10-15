xpl_netget

0.8 



Sample of download message :
xpl-cmnd
{
hop=1
source=clinique-sender.lapfr0005
target=*
}
netget.basic
{
protocol=http
uri=http://xoap.weather.com/weather/local/frxx0076?cc=*&dayf=5&link=xoap&prod=xoap&par=1104318584&key=218f82466abe84c3
destdir=c:\
destfn=test.xml
}
