xPL App Title: xPLDawnDusk

Default Source.Instance:
TONYT-DAWNDUSK.<hostname>HHMMSS

Default Filter(s):
xpl-cmnd.*.*.*.dawndusk.*

Default Group(s):
none

Schema(s):
DAWNDUSK.BASIC


Purpose:
To provide dusk/dawn notification to xPL systems


Installation:
Requires xPL OCX
Accepts Standard xPL Settings
Additional Remote Config Items:
LONGITUDE= longitude, default = -1
LATITUDE= latitude, default = 50
DAWNADJUST= (in +/- minutes), default = 0
DUSKADJUST= (in +/- minutes), default = 0

Notes:
This application does not currently allow for daylight saving,
it is necessary to use the DAWNADJ/DUSKADJ to correct for this.

Use a website such as www.streetmap.co.uk to get your latitude and longitude

Acknowledgements:
The Dusk/Dawn calculation is from a routine written by Thomas Laureanno 
