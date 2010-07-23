xPL Library for .NET, version 5.2

Contents
=========

1 - License & copyrights
2 - xPL
3 - Object model description
4 - Distribution
5 - Changelog



1 - License
============

Copyright (c) 2009-2010 Thijs Schreijer
http://www.thijsschreijer.nl

Copyright (c) 2008-2009 Tom Van den Panhuyzen
http://blog.boxedbits.com/xpl

Copyright (C) 2003-2005 John Bent
http://www.xpl.myby.co.uk

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
Linking this library statically or dynamically with other modules is
making a combined work based on this library. Thus, the terms and
conditions of the GNU General Public License cover the whole
combination.
As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent
modules, and to copy and distribute the resulting executable under
terms of your choice, provided that you also meet, for each linked
independent module, the terms and conditions of the license of that
module. An independent module is a module which is not derived from
or based on this library. If you modify this library, you may extend
this exception to your version of the library, but you are not
obligated to do so. If you do not wish to do so, delete this
exception statement from your version.




2 - xPL
========

xPL is an open protocol intended to permit the control and monitoring of 
home automation devices. The primary design goal of xPL is to provide a 
rich set of features and functionality, whilst maintaining an elegant, 
uncomplicated message structure. The protocol includes complete discovery 
and auto-configuration capabilities which support a fully “plug-n-play” 
architecture – essential to ensure a good end-user experience.

xPL benefits from a strongly-specified message structure, required to 
ensure that xPL-enabled devices from different vendors are able to 
communicate without the risk of incompatibilities.

Visit the xPL project at http://xplproject.org.uk

The xPLLib is a library for .NET to enable xPL device development


3 - Object model description
=============================

The xPLLib contains the base library for creating applications that
support xPL. The object model has 4 main objects, and a number of 
supporting objects. In visual studio use the Object Browser to 
examine the different objects and their properties, most have fairly
detailed descriptions.

Main objects
-------------
xPLDevice
    This object represents the core of a device. Basically create a 
    device and set its property Enabled to True and you have created a 
    new working xPL device on your xPL network. The object provides 
    numerous properties, methods and events to manage device behaviour.
    You can create as many devices as you need.
    
xPLMessage
    Communicating on the xPL network happens through xPL messages.
    This object provides all properties and methods to work with
    messages. Sending and receiving of messages is done through the
    xPLDevice object.
    
xPLNetwork
    This is an all shared object (no instances can be created) and
    it collects information regarding the xPL network and the devices
    seen on that network. Status of other devices can be followed and
    methods for discovery of the entire network are provided.
    
xPLListener
    This object contains the core network functionality of sending and
    receiving messages, most of it is behind the scenes within the xPLLib.
    The listener is (like the xPLNetwork object) an all shared object and 
    hence no instances can be created.
    Every xPLDevice registers itself upon creation with the listener, so
    the listener can maintain a list of devices. Messages received from 
    the network are passed on to the created xPLDevice objects and to the 
    xPLNetwork object.

xPLPluginStore (new in 5.1)
    Downloading and parsing vendor xml plugin files is supported through
    this object. A local shared store can be used to store the information
    updated locally. 2 collections (vendors and devices) are available 
    after loading/updating the PluginStore. Two dialogs are included to
    show update progress to the enduser.
    

Supporting objects
-------------------
xPL_Base
    Provides a number of supporting functions and contains all xPL 
    related constants
    
xPLAddress
    Represents a single xPL device address
	
xPLConfigItem
    Represents a single configurable item of an xPL device
	
xPLConfigItems
    Maintains a list of xPLConfigItem objects for a device. Also includes
    the 4 generic configurable items; newconf, interval, group and filter

xPLExtConfigItem
    Represents a single configuration item, as it applies to a remote 
    device on the xPL network (external device, xPLExtDevice object)
    
xPLExtDevice
    Represents a single device on the xPL network (external device) and
    all that is known of this device based upon messages seen on the
    network.
	
xPLFilter
    Represents a single xPL message filter
    
xPLFilters
    Maintains a list of message filters for a device
    
xPLGroup
    Represents a single xPL group a device belongs to
    
xPLGroups
    Maintains a list of groups for a device
    
xPLKeyValuePair
    Represents a single key-valuepair as used in the xPL message body
    
xPLKeyValuePairs
    Maintains a list of key-valuepairs for an xPL message

xPLPluginVendor (new in 5.1)
	Represents the vendor information downloaded from the vendor plugin 
	and	vendor related information from the central list maintained by
	the xpl-project.
	
xPLPluginDevice (new in 5.1)
	Represents the device information downloaded from the vendor plugin. 
	
xPLPluginUpdateDlgLog (form) (new in 5.1)
    Progress form that can be used to display download/update information
    from the plugin-update process. It displays status, % complete and
    a complete message log of the process.
    
xPLPluginUpdateDlgSmall (form) (new in 5.1)
    Progress form that can be used to display download/update information
    from the plugin-update process. It displays status and % complete of 
    the update process. No log is shown and it is automatically dismissed
    when the update completes

xPLSchema
    Represents a single schema name
    
    
    

4 - Distribution
=================

A distribution of the xpllib should include the following files;
 - xpllib.dll        The library core, providing the xPL functionality
 - ReadMe.txt        The documentation, including copyrights and 
                     changelog (this file)
 - gpl.txt           The license GNU General Public License
 - xpllib.xml        Contains the documentation of the object model, to
                     be browsed with the Visual Studio Object Browser.
                     This file does not provide any functional value 
                     other than for developers wishing to write their
                     own xPL applications.

    
    
5 - Changelog 
==============

Changes in version 5.2 from 5.1
NEW in 5.2
  - New event; xPLListener.InvalidMessageReceived. This event is raised if a received 
    message cannot be parsed into a xPLMessage object. The raw xPL string is passed along
  - The sourcecode now also contains an example application that demonstrates how to use
    the xpllib to create xPL applications
    
FIXED in 5.2
  - "States" used with the xPLListener object could not be restored (exception was thrown)
  - the xPLListener.Shutdown method prevented devices from sending a proper end-message
  - the xPLConfigItem.ToString method didn't list all values in the configitem, only the
    last one in the list
  - Functions xPL_Base.StatexPLLibVersion and xPL_Base.StateAppVersion, did not correctly
    decode the version information
  - Additionally some minor/cosmetic fixes

Changes in version 5.1 from 5.0
NEW in 5.1
  - Added the xPLPlugin object with its supporting object to download and parse
    vendor plugins xml files into a local PluginStore.
  - xPLDevice object has two new methods; Enable and Disable, that make setting the
    Enabled property more intuitive.
    
FIXED in 5.1
  - "States" returned by the GetState method of the xPLDevice and xPLListener
    objects were ASCII encoded, which could cause data loss if strings contained
    non-ASCII characters. States are now encoded using UTF8.


Changes in version 5.0 from 4.4
NEW in 5.0
  - The object model has been completely rewritten. Version 5.0 is not
    backward compatible with the previous 4.4 version.
  - Extensive documention is provided in the xml tags, accessible through 
    the visual studio object browser.
  - New object xPLNetwork provides scanning of the xPL network and connected
    devices, including events for new devices, or devices leaving/timeingout.
    Passive scanning (only based upon messages received) is automatic, active
    scanning (by sending requests) is supported through several methods
  - Configitems can be set to be 'hidden'. These will not show up in config.list
    and config.current status messages, but can be configured using 
    config.response command messages (each device has by default a hidden
    configitem 'debug', linked to the xPLDevice.Debug property).
  
FIXED in 5.0
  - There isn't an easy way to force an app to a specific config at startup. 
    The xpllib uses a config file, and once set, there's no way to stop it 
    from using that config.
      ** The xPLLib no longer writes its own config file. Replaced that with
         a 'state' that can be retrieved from a device (or the listener, 
         encompassing all devices at once), and can be set to restore a 
         previous state. It's up to the host application to store the state
         in a persistent manner.
  - There's no exposed 'version' number (I fixed this in the version I use for 
    xplhal2 - making the internal version number a public rather than private 
    property)
      ** Each xPLdevice object has a public property "VersionNumber" which is 
         initially set to the xpllib version, but can be overwritten with an 
         application specific setting. This versionnumber is included in 
         heartbeat messages.
  - a Win32 API call is used to enumerate the IP addresses available to bind 
    to - which is the only thing stopping the library being re-used on Linux 
    through Mono
      ** replaced it by .NET code, must be tested though...
  - It doesn't handle the network dropping - so if a wireless network is patchy, 
    and it drops, it doesn't come back without restarting the app
      ** network droppings are signalled and recovered
  - it's very easy (too easy) to cause message loops accidentally - if you 
    send a config message with a blank filters= line, the lib responds to all 
    messages. In the case of an X10 device, this means that the app will see an
    X10 command, and send an X10 response, but the broken filter causes this to 
    be seen as another command, which causes another response... and so on, 
    until you disable the service...
      ** The property MessagePassing, is by default set NOT to pass a devices
         own echo messages back to the device. This basically disables the
         loop
  - You can't force the lib to start listening on startup. In the case of 
    infrastructure services (like xplhal), you can get into a lockout where 
    you don't get a config message because you are not configured... catch 22! 
    if this isn't clear, I can show you a code sample that shows what I mean
      ** Also covered by the property MessagePassing, it also has the ability
         to set passing of messages even if the device itself is not 
         configured yet (by default it doesn't pass any messages until
         configured though)
