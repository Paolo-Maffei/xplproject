WireShark dissector for xPL homeautomation protocol
===================================================
Copyright 2011 by Thijs Schreijer
thijs@thijsschreijer.nl
http://www.thijsschreijer.nl

Feedback is very welcome.

License
=======
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


Links
=====
WireShark       http://www.wireshark.org/
xPL protocol    http://xplproject.org.uk/


Changelog
=========
26-apr-2011   v1.0     Initial version



OS support
==========
The dissector was created on Windows, but should work on all OS'es where
WireShark supports lua scripting.


Filelist
========
ReadMe.txt                           - This file
COPYING.txt                          - GNU Public License
xpl_dissector.lua                    - WireShark xPL addon
xpl_dissector_testdata.pcap          - WireShark testdata, output of the faulty 
                                       message generator
xPL Faulty Message Generator.exe     - Windows app to generate invalid xPL messages
xpllib.dll                           - Support dll for message generator
TestApp source (folder)              - VS2008 VB project with source of generator


Installation
============
Copy the xpl_dissector.lua file to the WireShark plugin directory, at the
time of writing that was; C:\Program Files\Wireshark\plugins\1.4.6\
That's all (for non Windows OS, please consult the WireShark documentation)


Using WireShark with xPL
========================
CAPTURING DATA;
Open the capture options dialog and enter "udp port 3865" in the "capture filter"
textbox, this will capture only UDP traffic in/out at port 3865 (the xPL port)
Make sure the correct network interface is selected and then click Start at the 
bottom of the dialog.

FILTERING (display filter)
Click the "Expression..." button right of the filter textbox
In the tree open the Field name at XPL, here you'll find the different xPL
message fields that can be used for filtering.

PLAYING AROUND
Open the xpl_dissector_testdata.pcap file with WireShark, it contains test data
with numerous xPL messages, mostly faulty messages as it was generated with the
(included) test generator.
Select a package in the top part of the window and then expand the tree below
where it says "xPL Protocol, Src: .....". In most cases this line will be red
which indicates its a faulty message, browse through the tree to see what kind
of feedback the dissector gives on faulty messages. For each of the messages
the first key-value pair contains the error in the message.


NOTES
=====
Because its coded in lua script, the dissector is not as fast as the built-in
dissectors. Especially as it does validate every message quite extensively.
xPL is not very bandwith intense, so this should not be an issue, but in 
sporadic cases it might be. Consider to capture the data first with the 
dissector disabled and save the data. Then later reopen the saved file with the
dissector enabled to perform your analysis.

