v 0.9.7
	* Regular expressions used for message string parsing
	* Windows is now not sizeable
	* Ability to paste messages directly from xpl_logger
	* Minor changes in internal data manipulation (xpl visual components use)
v 0.9.9
	* Added ability to create messages from plugins.xml vendor files
	* File format of saved messages changed 
	* Little glyph for known message classes
	* Solved a problem when sending or receiving message with space in the "key" parameter of the body : 
		XPLHAL Monitor sees : command essai = request
		My monitor sees	  : command=
			    			ddd=request

v 0.9.9.1
	* Added xPL app repository support

v 1.0
	* Centralized logging enabled
	* App repository enabled (window allows launching of referenced apps).
v 1.1
	* Command line added : xpl_sender -s filename to send a message without gui
v 1.5 
	* Modifications to enable linux portability
v 1.5.1
        * Changed logging system that was incompatible with linux and also created
          read only files that disabled multi applications to be launched from the
          same directory
        * Load / Save of xPL messages are now formatted with the same format as
          determinator files.
        * Added access to log file
v 1.5.2
	* General code review to support library evolutions
	==> reste à finaliser la fonction Command Composer avec la librairie xpl_xml


	
