
xPLBalloon
Shows contents of xPL messages as popups in the taskbar notification area.

Author: Tom Van den Panhuyzen   tomvdp at gmail(dot)com
http://blog.boxedbits.com/xpl

Credits to  John O'Byrne  & "Crusty  Applesniffer" for  their work  on the popup
windows.

V1.0 20/04/2008: original release
V1.1 03/05/2008: support for osd.basic, added finetuning via appfilter
V1.2 01/08/2008: recompiled with xpllib V4.4

Freeware
________________________________________________________________________________

This  is  an  application  that  when  run  installs  an  icon  in  the  taskbar
notification area.

Any messages that  pass through its  filters are displayed  as a popup  near the
taskbar notification  area.  Multiple  popups will  be stacked.   A popup can be
closed  by  clicking  its close  button.   A  popup will  remain  visible  for a
specified  time  or  as long  as  the  mouse  is   hoovering   over   it.    The
application  itself  can  be  closed  by right-clicking on the taskbar icon  and
picking 'exit' from the menu. It is configured via xPLHAL.

The configuration items are:
- showsecs: how many seconds to show the popup
- fadeinmsecs: the fade in time in milliseconds
- fadeoutmsecs: the fade out time in milliseconds
- usefading: 1 = fade, 0 = slide the popup
- appfilter: allows finetuning per xpl source (see below)

Use the filter option to make it listen to whatever messages you are  interested
in. By default it listens to anything corresponding to the log.basic schema.

Use "appfilter" to further finetune per  xpl source.  If you are only interested
in some particular messages from an  xpl application then add it to appfilter in
the following way:
	vendor.device:key=value1,key=value2
	
The notification will   only be shown  for that particular  device when the  xpl
message contains a matching key=value pair.

E.g.: to see notifications for mal.xplexec  but to see only errors and  warnings
but not informational messages, then enter an appfilter as this:
	mal.xplexec:type=err,type=wrn

If the xpl message that is at the basis for the notification has a:
- "title" key, then its value will be used as title in the notification;
- "text" key, then its value will be used as the notification body;
- "delay" key,  then its value  will be used  to show the  notification for that
  amount of seconds;
- "type" key, and its value is  "wrn", "err", or "inf" then the background  will
  adapt accordingly.

Any other 'keyfield = value' pairs are added at the bottom of the  notification,
except  when the  message is  osd.basic, then  it ignores  'command', 'row'  and
'column'.
________________________________________________________________________________

Prerequisites:
 .Net 2.0
 xPL Hub
 