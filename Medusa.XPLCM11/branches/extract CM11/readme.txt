
'* xPL CM11
'*
'* Written by Tom Van den Panhuyzen
'* Version 1.00 - 5/feb/2005
'* Version 1.01 - 20/mar/2005  (modified timeout settings)
'* Version 1.02 - 02/oct/2005  (recompiled with xpllib V4.1)
'* Version 1.03 - 16/dec/2005  (PREDIM1/2 now use the level attribute)
'* Version 1.04 - 11/feb/2007  (no more timeout when sending commands to the CM11 while a message arrives at powerline)
'* Version 1.05 - 01/aug/2008  (recompiled with xpllib V4.4)
'* Version 2.00 - 01/sep/2010  (reorganized the code so the CM11 part is in a separate dll that can be re-used outside of this application)
'*                             (updated to use xPLLib 5.2)
'*                             (updated to fix the loop issue; it no longer acts on trigger messages)
'*
'* For more information on the serial communications library (CommBase), see:
'* "Serial Comm: Use P/Invoke to Develop a .NET Base Class Library
'* for Serial Device Communications" John Hind, MSDN Magazine, Oct 2002
'*

'* Copyright 2007, 2008 Tom Van den Panhuyzen
'* tomvdp at gmail(dot)com
'* http://blog.boxedbits.com/xpl

* What *

MEDUSA-XPLCM11 implements the x10.basic xpl-schema, i.e.:
- it listens to xpl-command messages that pass this filter: xpl-cmnd.*.*.*.x10.*
- it expects messages like:
	command=ON
	device=B3
- it will pass on these messages to the CM11 component
- it will send xpl messages per received X10 signal



* How *

For an overview of the message schema see the project documentation available at http://wiki.xplproject.org.uk/index.php/Main_Page.

There are a few deviations:

- The "house" attribute is not supported for commands sent to the component.  The following is NOT supported:

	command=ON
	house=A

Note that you may receive a trigger like that.  If that signal was read from the power line, you will receive it in that form.

- The "device" attribute can contain multiple devices.  Devices belonging to the same housecode are grouped and sent as a whole to the device.  The following message:

	command=ON
	device=A1,A4,A5,B7,A8,C10

will send

	A1,A4,A5 ON
	B7 ON
	A8 ON
	C10 ON

to the CM11 component.  It will send a confirmation message per address.  In the above example 6 xpl confirm messages will be sent onto the xpl network.


* Why *

- Reliable.
- Asynchronous: messages are queued for delivery to the component.  No messages will be lost if they arrive in bursts.
- Multi-threaded: a message can arrive (via xPL) at the same time as the component is communicating a received signal (from the powerline).  The threads will not interfere.
- Fast: there is no polling scenario where threads are put to sleep and poll a state change.  Threads communicate via synchronisation objects.
- Stress-tested: MEDUSA-XPLCM11 survives a scenario in which it is sent numerous X10 commands and at the same time X10 signals are sent on the powerline.  The X10 signals from the powerline are sent out while the X10 commands are treated.

