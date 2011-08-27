Readme file for UPnP-2-xPL gateway
==================================
Copyright 2010-2011 Thijs Schreijer


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
is the ID of that element, the others are sub elements (directly or indirectly 
somewhere in its hierarchy)

== Uniqueness ==
The gateway will use the UDN (UPnP's Unique Device Name; usually a UUID) as a
permanent identifier. The xPL settings, will be tied to this UDN.
So the same UDN will always get the same xPL settings, this will be persistent
over sessions.
The component IDs will NOT remain the same over sessions, they will be 
regenerated for each new session. So you should not rely on them.

== Announcing a new UPnP device ==
When a new device is added, it is dissected into its components. For each 
component a separate announce message will be send. Its a trigger message
defined as follows;
upnp.announce
{
announce = <device|subdevice|service|variable|method|argument>
id = <comma separated ID list>
[parent = <parentid>]
[element specific data]
}
Remark; only a 'device' anounce message will NOT have a 'parent' key

== Devices leaving ==
No message will be sent, but the corresponding xPL device will go offline and 
send its regular hbeat.end (or config.end) message. This should be considered 
the signal that the UPnP device is no longer available.

== Announce requests ==
To request a device to announce again, send a command message;

upnp.basic
{
command = announce
}
This will trigger a new announce cycle, which will announce all elements of the
device again. At start up an application may broadcast this command to discover
all UPnP devices available.

== Value updates (StateVariable events) ==
Whenever an evented state variable changes its value, the event will result
in a trigger message;

upnp.basic
{
<id> = <value>
[id = [value]]
}
The keys of this message will correspond to the ID's of the statevariable who's
value changed. The value, is the new value of the variable.
Generally, its only a single value per message. Devices that use the 
'LastUpdate' mechanism as described in the AV Rendering Control description 
(version 1.0, par 2.3) will get more than one value. 
NOTE: the 'LastUpdate' type updates are for devices supporting multiple 
instances, the gateway will only handle the first.

== call methods ==
To call a method on a device, use the following command message;

upnp.basic
{
command=methodcall
method=<id of method>
[<id arg 1>=<value argument 1>]
[<id arg n>=<value argument n>]
}