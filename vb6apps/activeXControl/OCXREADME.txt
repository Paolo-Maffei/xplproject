xPL App Title: xPL.ocx

Purpose:
To encapsulate the xPL Schema in an OCX for use in any compatible software

Functions
---------
Initialise(<Source> as string,<waitforconfig> as boolean,<interval> as long) as boolean
<source>=vendor-device.instance
<waitforconfig>=True/False
<interval>=5 to 30
Returns True/False
This function must be the first called, it initialises the xpl system
System is non-functional if it returns false

Start() as boolean
Returns True/False
This function starts the xpl processes, normally called after adding configs/filters etc
System is non-functional if it returns false

ConfigsAdd(<item> as string,<style> as string,<number allowed> as integer) as boolean
<item>=name of config item
<style>=CONFIG or RECONF or OPTION
<number allowed>=number of this item allowed (normally 1)
Returns True/False
This function allows additional configuration items to be added
Add has failed if it returns false

FiltersAdd(<filter> as string) as boolean
<filter>=<msgtype>.<vendor>.<device>.<instance>.<class>.<type>
Returns True/False
This function allows filters to be added
Until at least 1 filter is added no messages will be received
Add has failed if it returns false

GroupsAdd(<group> as string) as boolean
<group>=group e.g. XPL-GROUP.LOUNGE
Returns True/False
This function allows groups to be added
Groups are the same as <source> except must begin XPL-GROUP.
Add has failed if it returns false

SendXplMsg(<msgtype>,<target>,<schema>,<message>) as boolean
<msgtype>=xpl-cmnd or xpl-trig or xpl-stat (""="xpl-cmnd")
<target>=* or vendor-device.instance (""="*")
<schema>=class.type
<message>=message body (final chr$(10) is optional)
This function is used to send an xpl message
Send failed if returns false

SendxPLRaw(<message>) as boolean
<message>=complete xpl message
This function sends a raw xpl message (with no validation)
Send failed if returns false


Subs
----
ConfigClear(<config item>)
Clears out all <config items> from list

FiltersClear()
Clears out all filters
No messages will be received until a new filter is added

GroupsClear()
Clears out all groups

SendConfig()
Sends current config values
Call this after changing configs at the application end
Not required to be called at initial load
e.g. an application (like xpl_monitor) that allows filters to be modified should 
call the routine to inform the xPLHal manager it has changed it's configuration


Properties
----------
PassNOMATCH as boolean (default = false)
When set to true then messages 'targeted at other devices' are passed thru if they pass filters

PassCONFIG as boolean (default = false)
When set to true then messages of schema config.* are passed thru if they pass filters

PassHBEAT as boolean (default = false)
When set to true then messages of schema hbeat.* are passed thru if they pass filters

StatusSchema as string
Sets the status schema <class>.<type> for status information to be added to heartbeats
Required if status information to be added to heartbeats

StatusMsg as string
Sets the status message for status information to be added to heartbeats
Required if status information to be added to heartbeats

Configs(ByVal Item As String, Optional ByVal Occurance As Integer, ByVal NewValue As String)
Sets/returns the value of a config item
Occurance is 1 thru n, where n is maximum number of config items

AppVersion as string
Sets/returns the application version information to be reported within the heartbeat message's "version=" field. If this is not set by the developer, then the version of the xPL ActiveX Control on the system will be sent instead.


Read-only Properties
--------------------
IPAddress() as variant
Returns the bound IP address

HostName() as variant
Returns the PC Hostname


Events
------
xPL_Received(<message> as xPLMsg)
Messages that pass the filters etc are passed in this event

xPL_Config(<item> as string,<Value> as string,<occurance> as integer>
When a configuration message is received this event is fired for each developer added 
config item that is in the config.response message
Note: config items marked as type CONFIG will only trigger this event when device is in
config.basic state.

xPL_Configured(<source> as string)
This event is fired when configuration process is completed
If config process is not initiated, event never fires
<source>=new vendor-device.instance

xPL_xPLRX(<msg> as string)
This event is fired whenever an xPL message is received
<msg> is raw xpl message
Useful for displaying message

xPL_xPLTX(<msg> as string)
This event is fired whenever an xPL message is sent
<msg> is raw xpl message
USeful for displaying message

JoinedxPLNetwork(<heartbeatcount> as integer)
This event is fired when the OCX receives one of it's own heartbeats back from the active Hub. heartbeatcount contains the number of heartbeats sent before the hub responds (max value 30)

Data Types
----------
xPL.xPLMsg

Public Type xPLMsg
    xPLType As String     = xpl-cmnd/xpl-trig/xpl-stat
    Hop as Integer        = hop
    Source As String      = vendor-device.instance of sender
    Target As String      = * or vendor-device.instance of target
    Schema As String      = schema class.type
    NamePairs As Integer  = number of name pairs
    Names() As String     = name part of name pairs
    Values() As String    = value part of name pairs
    Raw As String  	  = copy of raw message
End Type

Note: Names/Values are both base 0 (zero)
