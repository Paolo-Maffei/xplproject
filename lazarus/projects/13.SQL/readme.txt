xpl_sql v 4.0.0.0

This xpl client connects to a Mysql database.
It allows :
	- History log of all seen xPL messages
	- Look up and requests on the database using the db.basic schema (http://xplproject.org.uk/wiki/index.php?title=Schema_-_DB.BASIC) 
	
	
Configuration items: 
     hostname : localhost or ip of the server hosting the Mysql database
     username : username to connect on Mysql (eg root)
     password : password associated to the username
     database : name of the schema or database to be used ('xpl' by default)
     logging  : 'y' if you want to log all messages in the database.
	 
When the app is configured, it tries to connect to the database (note that libmysql.dll must be in system path).
Once done, it tries to open the database schema (eg xpl). If it doesn't exist, it is created automatically.
When logging is required, two tables will be created : log_body and log_header.

You can also query the database by using db.basic messages. 