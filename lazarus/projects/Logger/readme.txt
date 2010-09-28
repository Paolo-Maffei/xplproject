Changes History : 
	0.9.8 : * Status bar shows 'hub not found' until a hub is found
		* Save a message as file (format compatible with sender)
		* Assemble and copy to clipboard filter strings from messages
		* Changed app icon

	1.0	* Filter system modified : treeview on the left replaces filter on source
		* Logger doesn't need to be configured anymore to log messages

	1.1	* Message editing is now in a separate window - this corrects a little bug in v1.0
		* Appname and appversion sent twice in the heartbeat message corrected


	1.2	* Access to app repository
		* Completed message editing window
		* window placement and option kept between sessions
		* Improved message editing window
		* Columns can be reordered using the app preference window
		* Message detail can be shown/hide
		* You can use either shema based icon or message type based icons for ease of debugging by suggestion of Tieske

	2.0	* Formerly available in 'xpl network', network configuration and vendor plugin update are available in xpl logger
		* Devices can now be directly configured from xPL Logger, it replaces the old xPL Config (right click on the device name, 'configure')
		* Session journal is now directly accessible from the application
		* The application respects the new registry organization (HKLM\Software\clinique\logger) to be compatible with xpl updater by Tieske
		* Available commands for specific device from the vendor plugin can be directly sent with xPL logger (right click, 'commands')
		* Plugin information regarding a specific device can be viewed

	2.0.1
		* Corrects an error raised when configuration items are absent from the vendor plugin file
	
	2.0.2 
		* Correct bug FS#29 : saved app setting wasn't applied after application reload
		* Corrected bug on message panel visibility toggle
		* Corrected a bug in the filter on message type 
	2.0.3
		* The 'Send a New Message To...' menu now populates the message body with sample value (was previously empty)
		* The 'Discover Network' menu is now accessible on right-clicking on the 'xPL Network' top node of the tree, 
			suppressed the nearly empty 'Device Configuration' menu.
		* Added the option to start logging (or not) at application startup
		* Icons added in contextual menus
		* Introducing proxy handling capability for HTTP at xPLSettings level
	2.1.2
		* General code review to support library evolutions
		* Removed General Settings Menu to avoid code redundancy between linux and windows versions (reintroduced in xPL Network Config)
		* Corrected an issue generating nearly empty messages when using 'Send Message To...'
		==> reste à finaliser la fonction Command Composer avec la librairie xpl_xml
		    (sauvegarde et chargement de configurations)
			Ajouter le fonctionnement du menu 'commands' sous linux


