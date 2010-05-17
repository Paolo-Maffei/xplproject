xpl_timer

All configuration must be done (through xplhal or dcm, or xpl_configurator) before it operates.
Sample xpl messages provided can be used with xpl_sender to test the timer program.

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
	


---
Instructions added to standard control.basic schema

Message type xpl-cmnd
	current = start
		device = name of the timer
		duration = 0 | empty or integer value
			If an integer value is provided the timer will count down to 0
			If a 0 or no value provided, the timer will endless count until a stop is received
		range	   = local | global (optional)
		frequence = 0 | empty or integer value
			If a value is indicated, the status of this timer will be triggered on this frequency base (a tick every x seconds)
		Starts a new timer based.
		Parameter duration indicates how many seconds it lasts.
		Range indicates wheter events related to that timer will be adressed to '*' or only the module starting it. Local by default.
	current = halt
	current = resume
	current = stop

sensor.request schema
  request= current
  device = name of the timer
	No status returned for stopped timers
  

Send messages.
A trigger is fired on every event for a timer : pause, resume, start stop, went off

When a timer is stopped or the duration equals 0 : 
	xpl-trig timer.basic
		name = timername
		status = stopped
		elapsed = number of seconds between start and stop
