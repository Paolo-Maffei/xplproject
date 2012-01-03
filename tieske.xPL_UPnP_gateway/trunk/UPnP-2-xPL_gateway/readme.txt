Readme file for UPnP-2-xPL gateway
==================================
Copyright 2010-2012 Thijs Schreijer

-------------------------------------------------------------------------------
Changelog;
xx-jan-2012 version 0.2.4
   - Updated logging, to show a warning when a 'LastChange' update comes in
     that contains references to non-existing statevariables.
   - Fixed logging, to show proper warnings when an announcement is requested
     for a non-existing ID (reported by Mike C)
   - Fixed logging, to no longer show warnings for unknown message schemas
     (reported by Mike C)
   - Added a button to show the debug window (of the underlying UPnP lib) and
     a commandline option '/debug' to show it from the start.
   - Fixed a bug (reported by Mike C) for a value too large for an xPL message
     when delivered in a 'LastChange' AV event value.
28-dec-2011 version 0.2.3
   - Fix; requesting an id to be re-announced caused an exception
04-dec-2011 version 0.2.2
   - more fixes, illegal xPL characters now properly removed, xml payloads
     can now be transferred properly
   - splitting long values over multiple key-value pairs
   - updated to xPLLib 5.5, so large messages will auto-fragment
06-sep-2011 version 0.2.1
   - several fixes, updated media devices code
04-sep-2011 version 0.2.0
   - changed announcements (even more messages required) and lots of fixes
26-aug-2011 version 0.1.0
   - complete rewrite of the experimental gateway, incorporating lots of 
     lessons learned
-------------------------------------------------------------------------------
Schema used for UPnP gateway

A UPnP device will be dissected into its components and each component will get 
its own unique ID. The components are;
 - Device
 - Subdevice
 - Service
 - Variable
 - Method
 - Argument
The ID tag for the elements are a comma-separated list, of which the first one 
is the ID of that element, the others are sub elements (child elements).

== Uniqueness ==
The component IDs will NOT remain the same over sessions, they will be 
regenerated for each new session. So you should not rely on them. You should
rely only on the UDN (unique device name, usually a UUID) of the UPnP device.

== Announcing a new UPnP device ==
When a new device is added, it is dissected into its components. For each 
component a separate announce message will be send. Its a trigger message
defined as follows;
upnp.announce
{
announce = <device|subdevice|service|variable|method|argument|left>
id = <comma separated ID list>
[parent = <parentid>]
[element specific data]
}
Remarks;
 - only a 'device' and 'left' anounce message will NOT have a 'parent' key
 - The <comma separated ID list> is a list starting with the elements own ID
   and followed by any children it has (only 1st level children, not recursive)
 - an 'announce=left' message is used to indicate a device leaving, it will
   only have the 'id=...' key value pair. Indicating who has left.
   There will always be only 1 root device leaving per message, and hence the
   id will only contain the id of the root device leaving (no child IDs).
 - the 'allowed' key will contain the allowvaluelist in a comma separated
   format
   
== Devices leaving ==
A special case of the announce message will be send. See 'Announcing a new UPnP
device'.

== Announce requests ==
To request a device to announce again, send a command message;

upnp.basic
{
command = announce
[id = <ID>]
[id = ...]
}
This will trigger a new announce cycle, which will announce all elements of the
requested ID again. If no ID is provided, then all devices known by the gateway 
will announce again. At start up an application may broadcast this command to 
discover all UPnP devices available. Multiple requests can be combined by 
having multiple ID keys, each with 1 ID requested.

== Value updates (StateVariable events) ==
Whenever an evented state variable changes its value, the event will result
in a trigger message;

upnp.basic
{
<id> = <value>
[<id> = <value>]
}
The keys of this message will correspond to the ID's of the statevariable who's
value changed. The value, is the new value of the variable.
Generally, its only a single value per message. Devices that use the 
'LastUpdate' mechanism as described in the AV Rendering Control description 
(version 1.0, par 2.3) will get more than one value.
In case a value is too large, it will be chopped in pieces. Example;
the ID = 34, then the following is returned as part of the message;
34=<<chopped_it>>
34-1=this is part 1
34-2=this is part 2
34-3=etc.
So if the ID returns "<<chopped_it>>", then the receiver should look for 
the ID with sub-numbers, the values can be concatenated to get back to the
original value.
NOTE: the 'LastUpdate' type updates are for devices supporting multiple 
instances, the gateway will only handle the first.

== Value requests ==
To request a statevariable value, send a command message;

upnp.basic
{
command = requestvalue
id = <ID>
[id = ...]
}
This will trigger a set of response messages with the variable values (see
Value updates). There must be at least 1 ID in the command message and it can be
the ID of either a; device, service or variable. In the first two cases all 
underlying variables will be reported.
Caveat: UPnP does not provide a standard way of getting variable values, but it
has a convention that methods to get a variable value are named as the variable
name, prefixed with 'Get'. So this command will return the last received value
for evented statevariables, and for non-evented statevariables if will look for
a UPnP method called 'Get<variablename>' (with 1 parameter, direction OUT) and 
return the result of executing that method.

== call methods ==
To call a method on a device, use the following command message;

upnp.method
{
command=methodcall
method=<id of method>
[callid=<uniqueid>]
[<id arg 1>=<value argument 1>]
[<id arg n>=<value argument n>]
}
the key 'callid' is optional and is returned with the response so the command
and its response can be connected back together (calls are async).

The response will be a trigger message;
upnp.method
{
[callid=<uniqueid>]
success=<true|false>
[error=error text]
[retval=<return value>]
<id>=<value>
[<id>=<value>]
}
The callid value will be only be present if provided with the command, and will 
have the same value that was provided with the command.
The key 'success' is a boolean indicating success.
In case of failure the 'error' key indicates the error message, no other keys
will be provided.
In case of success, no 'error' key will be available, but the returnvalue 
(retval) will be present along with all id's and values of arguments with 
direction 'out'.
The ID's and the values represent the arguments and the returned values. In
case a value is too large, it will be chopped in pieces, see the 'value 
updates' section above.
