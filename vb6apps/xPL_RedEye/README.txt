xPL App Title: xPLRedEye

Default Source.Instance:
TONYT-REDEYE.<hostname>HHMMSS

Default Filter(s):
XPL-CMND.*.*.*.REMOTE.BASIC

Default Group(s):
none

Schema(s):
REMOTE.BASIC


Purpose:
To provide a method of xPL IR control of Pace Cable STB and Sky via a RedEye device


Installation:
Requires xPL OCX
Requires RedEye Serial Device
Accepts Standard xPL Settings
Additional Remote Config Items:
COMPORT=
DEVICE=PACE_IRDA (default) or PACE_RC5 or SKY
Only COMPORT should need configuring



Notes:
zone= should always be the configured instance
The device= component of remote.basic is ignored, the device is always that configured

Acknowledgements:

