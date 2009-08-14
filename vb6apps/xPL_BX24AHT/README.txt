xPL App Title: xPLBX24AHT

Default Source.Instance:
TONYT-BX24AHT.<hostname>HHMMSS

Default Filter(s):
none

Default Group(s):
none

xPL Schema(s):
X10.BASIC


Purpose:
To provide an xPL X10 interface via a BX24-AHT unit


Installation:
Requires xPL OCX
Accepts Standard xPL Settings
Additional Remote Config Items:
HOUSECODES= (list of housecodes to monitor, overrides previous settings)
e.g. HOUSECODES=AFB or HOUSECODES=A,B,G
COMPORT=1
BAUD=19200
DATABITS=8
PARITY=N
STOPBITS=1
FLOWCONTROL=N
RTSENABLE=N
DTRENABLE=N

Notes:
Currently supports X10 ON/OFF 
Other x10 commands will be supported in the future

BX24AHT.cfg holds the X10 ON/OFF RF Codes

SECURITY.cfg is for user inclusion of Security X10 Codes 

Each entry is constructed as an 8 digit code RFRFX10N where:
RFRF = 4 digit hex code as displayed in application window
X10 = 2 or 3 digit pseudo x10 code Q1 thru Z16 (trailing space for 2 digit)
N = 2 for open (ON = rf04), 3 for close (OFF = rf84)
e.g. 
D904S1 2
D984S1 3
D904S162
D984S163

As the security.cfg file is loaded at startup, the application needs to be restarted 
to load any amendments


Acknowledgements:
For futher Information on the BX24-AHT see
http://www.laser.com/dhouston/bx24-pcb.htm

