xpl_dirmon

0.8 20/09/2010 
    As a prerequisite, this app needs xpl timer to be launched.
	First published version
	Monitors files or directories.
	Setting monitoring points : 
		Send a xpl-cmnd message of control.basic schema.
			Body Elements :
				device = <name of the directory finished by \> or <full path to file>
				current= start | stop
	When a file is created, deleted or modified (date/time) a message will be issued :
	xpl-trig
		{
		hop=0
		source=clinique-dirmon.lapfr005
		target=*
		}
	dirmon.basic
		{
		current=deleted
		device=c:\test\
		file=Nouvelle image bitmap.bmp
		}
		
0.85
	Added mechanism to test presence of xPL Timer, xpl timer can be launched before of after this app.
	Added small web interface that allow to directly set / remove monitoring points
