xpl_weather

Credits goes to Scott Crevier for his set of temperature icons (http://www.x10.crevier.org/homeseer/), and allowing me to reuse them in this project.

All configuration must be done (through xplhal or dcm) before it operates.
You must get an account with weather.com and then fill PartnerID, LicenseKey and select a ZipCode.
Works for USA - test with success for France.
The weather.com website is scanned every 30 minutes.

v 0.6 First published version
v 0.9 Corrected incorrect body values containing '_' character
	Added to the application directory
	Updated About box for portability with linux
	Modification in window behavior : 
		- Added minimize button
		- Coherence between app/window icons
	Sample sensor request included in the zip to use with xpl_sender

v 1.0   Adapted to last xpl lazarus library evolutions	
	Access to standard app library added
	The application now issues a sensor.basic for each supplied value, instead of a global message containing all.
	sensor.basic messages are only issued on device value change.

v 1.0.1
	Correction when xpl_weather searches for bad formatted image filename (9.png, wind_N/A.png)
v 2.0
	xPL weather now goes web
	Forecast values available
	Schema added to vendor plugin file
	Added configuration informations needed for web server :
		default root path
		default port (8333 by default)
	   - can be changed via xpl configuration options
	This program now runs in parallel with the web arborescence that must be downloaded altogether.


