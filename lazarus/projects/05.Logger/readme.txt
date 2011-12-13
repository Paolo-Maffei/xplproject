xPL Logger

Changes History : 
	4.3.2.2
		Corrected a display bug in the left tree view (selected icons disappeared)
		Corrected some bugs related to simplified display : 
			* 'Send message to...' is not working
			* List filtered on device not working
		
	4.3.2.1
		The 'Clear' button now also reset the left panel treeview
		Introduced a simplified treeview for network elements discovered ( V-D-I instead of V\D\I )
		Main window layout saved between sessions
		Reintroduced filtering capabilities. New schema filters can be added directly from schema tree (right clic on the schema)
		
	4.3.1.5
		Corrected resource consumption bug (#FS76)
		Corrected bug in loop sending function when Sleep=0
		Log viewer button display glitch corrected
		Log viewer can directly be accessed from status bar of the window (clic on it)
		Launch > Installed xPL Apps : non 'clinique' apps had an empty name
	4.3.0.2
		Corrected bug #FS71
		Code cleansing for multipart messages handling		
	4.3.0.1
		Added new functionalities to logger to allow usage of fragment messages (cf http://www.xplproject.org.uk/forums/viewtopic.php?f=2&t=1099)	
		Select the first fragment element of a message, extend the selection to the last element. Right click and use 'Assemble fragments'.
	4.2.0.0
		* Fixed bugs 
			#FS69 : removed auto split of long values
			#FS70 : crash when opening two message windows in specific case
		* Removed limit of 128 char in body value elements
		* Checked UTF8 compatibility for values
		* Added 'Macro' mode. This mode enables you to send a list of pre-defined messages.
		Right clic on the messages you want to add to the macro list
		Select 'Add to Macro List'
		Clic on 'Macro (x elmts)' to display the message list that will be played
		You can specify a timing (in seconds) and enable loop sending.
	4.1.0.10
		* Column ordering is now done via drag and drop of columns in the main screen, no more by the app settings dialog
		* Columns order and sizes saved between sessions
		* Right clic on a message allows to directly resend the message
	4.1.0
		* Corrected problems due to the absence of vendor files
		* Message body added to listview, now enabling them to be exported in csv export
		* Simplification of contextual menus in hierarchical treeview and list of messages
		* Added 'Discover Network' (hbeat request) on right clic on 'Network' menu entry
		* Added conversation mode
		* Logger now dives in message body to identify specific 'device = xxxx' lines
	4.0.0
		* Revamped application based on the complete rewrite of xPL Lazarus library
		* No need to have admin rights at startup
		* Filter system changed to dynamic filter on sender/message types
	2.2.4
		* Recompiled to use new config file format. Please delete previous file to avoid error at launch.
		* Send message box can now handle xPL messages defined in vendor file	
	2.2.3
		* Corrected an error when using 'Send a Message' that left last message content in the window
		* Menu 'Command' (right click on a module do display possible commands available from the vendor file) back to work		
	2.2.2 (internal / test realease)
		* Message are no longueur internally stored as stringlist but using TXMLOuput structure from u_xml this
		  enables : 
			- better code coverage for testing
			- Exporting xPL Logger file export is now complete and done in xml format
	2.2.1
		* Resolved a bug when saving / loading xpl messages (also when saving load configuration elements).
	2.2
		* General code review to support library evolutions
		* Removed General Settings Menu to avoid code redundancy between linux and windows versions (reintroduced in xPL Network Config)
		* Corrected an issue generating nearly empty messages when using 'Send Message To...'
		* Configure menu now appear as soon as configuration elements are received
		* Added ability to display messages either by target or by source in the tree view
	2.0.3
		* The 'Send a New Message To...' menu now populates the message body with sample value (was previously empty)
		* The 'Discover Network' menu is now accessible on right-clicking on the 'xPL Network' top node of the tree, 
			suppressed the nearly empty 'Device Configuration' menu.
		* Added the option to start logging (or not) at application startup
		* Icons added in contextual menus
		* Introducing proxy handling capability for HTTP at xPLSettings level
	2.0.2 
		* Correct bug FS#29 : saved app setting wasn't applied after application reload
		* Corrected bug on message panel visibility toggle
		* Corrected a bug in the filter on message type 
	2.0.1
		* Corrects an error raised when configuration items are absent from the vendor plugin file
		0.9.8 : * Status bar shows 'hub not found' until a hub is found
		* Save a message as file (format compatible with sender)
		* Assemble and copy to clipboard filter strings from messages
		* Changed app icon
	2.0	
		* Formerly available in 'xpl network', network configuration and vendor plugin update are available in xpl logger
		* Devices can now be directly configured from xPL Logger, it replaces the old xPL Config (right click on the device name, 'configure')
		* Session journal is now directly accessible from the application
		* The application respects the new registry organization (HKLM\Software\clinique\logger) to be compatible with xpl updater by Tieske
		* Available commands for specific device from the vendor plugin can be directly sent with xPL logger (right click, 'commands')
		* Plugin information regarding a specific device can be viewed
	1.2	
		* Access to app repository
		* Completed message editing window
		* window placement and option kept between sessions
		* Improved message editing window
		* Columns can be reordered using the app preference window
		* Message detail can be shown/hide
		* You can use either shema based icon or message type based icons for ease of debugging by suggestion of Tieske
	1.1	
		* Message editing is now in a separate window - this corrects a little bug in v1.0
		* Appname and appversion sent twice in the heartbeat message corrected
	1.0	
		* Filter system modified : treeview on the left replaces filter on source
		* Logger doesn't need to be configured anymore to log messages



	
