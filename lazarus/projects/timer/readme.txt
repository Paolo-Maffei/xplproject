xpl_timer

All configuration must be done (through xplhal or dcm, or xpl_configurator) before it operates.

---
Revision History

v 0.9 First published version
v 0.9.1
	Set a default filter on timer.* messages
	Changed the application icon
	When it joins the xPL network, it starts a timer by default (timer_app).
	Timer list is saved when application closed and reloaded when application launched.
		Important : the application reestimated durations when it reloads timers.
		If timers should have elapsed during the interval, they will be stopped as soon as created.
v 0.9.2
	Added recurrent timer type (cf schema description)
v 0.9.5
	Bug fixing : 
		Found the origin of an error message about an error in intToStr, due to empty 'interval' value in configuration messages
		Corrected configuration problem when used with xPLHal Manager, due to high/lower case in instance name
	Changed the schema, using the standard control.basic for timers and sensor.request (see exemple messages)
	Added the 'went off' notion for naturally elapsed timers
	Changed the loading sequence to allow start of default timer as soon as the app is configured.
v 0.9.7
	Corrected a display bug affecting refresh when creating new timers
	Application now demands confirmation before exiting
	Introduced to the local xpl apps repository
	A flag indicates wheter the app is configured or pending 
	Corrected an error in the sensor.request message interpretation (current=request was taken in place of request=current)
	Corrected the way timer are stored in the config file

v 0.9.9	
	Timers can now be edited in place
	Timers now stat timer.basic messages (instead of sensor.basic in previous versions)
	Added access to xpl apps repository
	Added access to log viewer
	Added Events support : 
		- Simple / programmed events
		- Recurring events
	==> Application need to be configured before operating anything.

v 1.0	Correction of opened bugs on xPL bugtraker : 
		FS#21 : ergonomy change of the main window
		FS#20 : problem in planification of recurring events when now > end of daily window
		FS#23 : Added ability to randomize start of weekly events
	Common to all lazarus xpl log format modified for better readability

v 1.1	Bug fixing :
		Recurring events can't be created without a name now
		Timers with the same name can't be created twice
	        Next fire timer recomputed every time the event is edited
		FS#29 An unwanted event was launched when creating a new recurring event. It has been suppressed.
		Application had a problem when reopening having an empty event list or timer list
	Evolutions :
 		Suppressed auto launched xpl message at xpl_timer startup
		FS#27  Fire now! function added - to enable testing/design
		Added display of minute equivalency for random and interval informations stored in seconds for ease of user.
		Events can now trigger either their standard timer.basic/fired message, either a choosen message
		Recurent and single events forms evolutions

v 1.1.1
	Maxvalue of randomize parameter is wrong when scheduling weekly timers

v 1.1.2
	Solved problem with timer self firing after launch of the program if their target date/time was reached while the program was off
	Templates of the schema are now available in the vendor plugin file.
	
v 1.5
	This version is now web enabled
	Added special timers of family 'dawndusk' to handle dawn, dusk and noon events. These events are not editable.
	To enable calculation of dusk, dawn, latitude and longitude has to be setup in the configuration of the app.
	Upon request (dawndusk.request message), the application sends the absolute light level in the day (1 to 6)
	Timer actions (create timer, start,stop...) directly available thru web version of xPL Timer (actions are issued from the plugin file then it has to be up to date).
	
v 1.5.1
    Corrected a bug that allowed xPL timer to see messages not directed to him (at library level).
	Removed Log4Delphi dependance
	Added direct access to log file
	
v 1.5.2
	Corrected : 
		- a bug affecting targetted timer ticks (message sent to wrong device)
		- a problem in the window representing timers when frenquency > 100
		- bug when closing timer window
		- problem when sliding in single and recurrent events to 23:59
		
v 1.6
	*** This version now relies only on timer.basic schema, previously used control.basic removed ***
	*** Check dependecies with you determinators/scripts when deploying it if you used previous versions ***
	Described timer message schema on the xpl website : http://xplproject.org.uk/wiki/index.php?title=Schema_-_TIMER#TIMER_Message_Specification
	Corrected display problem when resizing timer window
	Ability to do 'Fire Now' on Timer (it was already possible on events).
	Added seasons
	Recompiled to be compatible with xpl message format saved by latest versions of xpl sender, xpl logger
		* Message sent can also include {SYS::VARIABLE} parameters (please see xPL Sender readme file)
	Vendor file updated to reflect these changes

Todo :
	- Ajouter le calcul des changements d'heure
	- Ajouter le chargement d'évènements quotidiens (éphémérides)
	- Supprimer un timer initié par une application sur réception de hbeat.end de l'application ?


