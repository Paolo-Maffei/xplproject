xpl_netget

0.8 This tools allows to download or parse a distant page.



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


Sample of parsing message :
xpl-cmnd
{
hop=0
source=clinique-logger.lapfr0005
target=*
}
netget.basic
{
protocol=get
uri=http://www.infobel.com/fr/france/Inverse.aspx?q=France
qphone=0475026474
regexpr=QName=(.*?)&amp;QNum
}
