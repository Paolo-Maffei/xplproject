xPL App Title: xPLBarcode

Default Source.Instance:
TONYT-BARCODE.<hostname>HHMMSS

Default Filter(s):
none

Default Group(s):
none

xPL Schema(s):
BARCODE.BASIC


Purpose:
To provide barcode scanning to an xPL network


Installation:
Requires xPL OCX
Accepts Standard xPL Settings
Additional Remote Config Items:
COMMANDS=
BARCODES=
SERVER= (default is barcodes.xplhal.com)
USERNAME= (request from tony, required to add/edit database)
PASSWORD= (as above)
INTERACTIVE= (Y/N - should app prompt for description if unknown in database)
COMPORT=1
BAUD=19200
DATABITS=8
PARITY=N
STOPBITS=1
FLOWCONTROL=N
RTSENABLE=N
DTRENABLE=N

Notes:
COMMANDS/BARCODES have 16 items
It allows a command= in the schema to be matched to a scanned barcode
Thereby allowing the user to signal the type of scan (e.g. shopping, rubbish, dvd's)

Acknowledgements:
