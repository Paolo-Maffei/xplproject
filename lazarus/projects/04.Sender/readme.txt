v 4.1.0.2
Modified to allow multiple instance of xPL Sender at the same time.

v 4.1.0.1
Added new functionalities to sender to allow usage of fragment messages (cf http://www.xplproject.org.uk/forums/viewtopic.php?f=2&t=1099)	

v 4.0.0
Revamped application based on the complete rewrite of xPL Lazarus library
No need to have admin rights at startup
Helper added for {SYS::VARIABLES} functions
Loop mode added (sends messages continuously until 'Loop Send' unchecked)
New GUI

v 1.6.2
Corrected code when pasting message containing {SYS::VARIABLES}

v 1.6.1
General code review to support library evolutions
Now supports copy to clipboard function
Message saving format unified
Supports use of {SYS::VARIABLES} : 
	{SYS::TIMESTAMP},{SYS::DATE_YMD},{SYS::DATE_UK},{SYS::DATE_US},
	{SYS::DATE},{SYS::DAY},{SYS::MONTH},{SYS::YEAR},{SYS::TIME},
	{SYS::HOUR},{SYS::MINUTE},{SYS::SECOND}

v 1.5.1
Changed logging system that was incompatible with linux and also created read only files that disabled multi applications to be launched from the same directory
Load / Save of xPL messages are now formatted with the same format as determinator files.
Added access to log file

v 1.5 
Modifications to enable linux portability

v 1.1
Command line added : xpl_sender -s filename to send a message without gui

v 0.9.7
Regular expressions used for message string parsing
Windows is now not sizeable
Ability to paste messages directly from xpl_logger
Minor changes in internal data manipulation (xpl visual components use)

v 0.9.9
Added ability to create messages from plugins.xml vendor files
File format of saved messages changed 
Little glyph for known message classes
Solved a problem when sending or receiving message with space in the "key" parameter of the body : 
XPLHAL Monitor sees : command essai = request 
My monitor sees	  : command= ddd=request

v 1.0
Centralized logging enabled
App repository enabled (window allows launching of referenced apps).
