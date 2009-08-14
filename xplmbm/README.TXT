xPL Plug-in for Motherboard Monitor 5
=====================================

Introduction
------------

Motherboard Monitor 5 (MBM5) is a program for monitoring the health of your computer.
It reports the values of temperature sensors, voltages and fan speeds, and can be downloaded from:
http://mbm.livewiredev.com/

This plug-in allows the status information from MBM to be broadcast as xPL messages, allowing
xPL devices on the network to act on the information.

License
-------

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Installation
------------

Note: Please upgrade to MBM version 5.3.4.0 or later before installing this plug-in.

1. Close Motherboard Monitor if it is running.
2. Copy the file xplmbm.dll to the Plugin directory inside your MBM5 installation directory.
   By default this is C:\Program Files\Motherboard Monitor 5\Plugin.
3. Start Motherboard Monitor.
4. If this is the first time the plug-in has been installed, right-click on the MBM systray icon and select Plug-in -> xPL MBM Plug-in v1.0 -> Start Plug-in.
5. Use your xPL Configuration Manager to configure the plug-in.
   If you are using xPLHal, you can do this by opening the xPLHal Manager, expanding the xPL Devices node, and clicking on Awaiting Configuration.
   You should see the newly installed MBM plug-in in the list of devices. Double-click on it to open it's configuration dialog.
   Select "newconf" from the list of configurable items and enter a name for the plug-in, for example, the name of the computer that the MBM plug-in is
   running on.
   Click OK to save your configuration, and the plug-in will now start sending out messages.

The plug-in will send one xPL message for each sensor, at every heartbeat interval.
The messages use the sensor.basic schema, details of which are available from http://www.xplproject.org.uk/.


Copyright (C) 2003 John Bent
john.b1@blueyonder.co.uk
http://www.xpl.myby.co.uk/