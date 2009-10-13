
XPL Logger V1.2
Author: Tom Van den Panhuyzen   tomvdp at gmail(dot)com
http://blog.boxedbits.com/xpl
_______________________________________________________________________________

Features
--------

* Logs xpl messages in xml format
* Includes raw xpl message in the xml
* Xsl files included to transform the xml into a readable format:
-- log.xsl: picks out the LOG.BASIC messages and transforms these to html
-- logAll.xsl: transforms all messages in the xml to html output
-- logTable.xsl: very basic html output
-- logXLS.xsl: output in Excel format (Excel2002 and later)


Configuration
-------------
Configuration is done via XPL Hal or another tool capable of sending config items to the XPL Logger.
The following items can be entered:

* loglen: Specifies the maximum number of xpl messages to store in the log file.  Keep this down to a reasonable value.  150 messages roughly equals 100Kb.

* lpath: Specifies the path where the log file will be saved and where optionally the xsl file and transformation output reside.

* xml: Specifies the name (no path) of the log file. 

* xsl: Specifies the name (no path) of the xsl file that transforms the xml log file. Leave blank for no transformation.

* out: Specifies the name (no path) of the output file created by the xsl transform. Leave blank for no transformation.

* appfilter: allows finetuning per xpl source (see below)

Possible scenarios
------------------
A) To log the last 150 xpl-cmnd and xpl-trig messages in a directory "c:\logs\xplmessages\" and later view them with a browser, do this:
1) Create the directory "c:\logs\xplmessages\"
2) Copy the .xsl files to it
3) configure XPL Logger:
    loglen = 150
    lpath = c:\logs\xplmessages\
    xml = log.xml
    xsl = logAll.xsl
    out = log.htm
    filter = xpl-cmnd.*.*.*.*.*
    filter = xpl-trig.*.*.*.*.*

If an xpl messages is generated that conforms to the filters set for XPL Logger, it will be logged and you should see a log.xml and log.htm appear in c:\logs\xplmessages\.
You can view the log.htm in a browser.
Most recent messsage is on top.

B) If you prefer to transform the output to Excel format change the config items to:
    xsl = logXLS.xsl
    out = log.xls
    
You can then view log.xls in Excel.

C) To see only the xpl messages that were intended to be logged because they belong to the schema LOG.BASIC, then use the following settings:
    xsl = log.xsl
    out = log.htm

Note that the xpllogger is still logging all messages according to the filters, but the xsl transforms only those that belong to LOG.BASIC to html.
If you want to log to the xml file the message of schema LOG.BASIC only, then change the filter settings to:
    filter = xpl-trig.*.*.*.log.basic

Use "appfilter" to further finetune per  xpl source.  If you are only interested
in some particular messages from an  xpl application then add it to appfilter in
the following way:
	vendor.device:key=value1,key=value2
	
The notification will  only be logged  for that particular  device when the  xpl
message contains a matching key=value pair.

E.g.: to see log messages for mal.xplexec  but to see only errors and  warnings
but not informational messages, then enter an appfilter as this:
	mal.xplexec:type=err,type=wrn


Other
-----
* The xsl files can be adapted to suit your needs.
* Changing configuration parameters takes effect immediately; no need to restart the xpllogger service.
* xpl messages are buffered and flushed to disk either when the buffer is full or when an explicit LOG.BASIC message arrives.  It is only a small buffer (10 messages), but now you know why that messages that you have just sent does not appear in the log!


Changelog
---------
V1.2  (1 aug 2008)
* Recompiled with xpllib V4.4
* Added support for "appfilter"
* changed the devicename to "logger" (previously: "xpllogger" which was too long according to the standards)

V1.1
LOG.BASIC support:
- Added an xls that displays these messages only
- If a LOG.BASIC messages arrives, the buffer is immediately flushed to disk and not kept in memory.  Other messages are not immediately written to disk but buffered.

V1.0
Initial release
