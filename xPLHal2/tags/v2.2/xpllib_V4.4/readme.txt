xPL Library for .NET Release Information
========================================

Written by John Bent (C) 2003-2006
john.b1 at blueyonder(dot)co(dot)uk

and

Tom Van den Panhuyzen (C) 2007-2008
tomvdp at gmail(dot)com
http://blog.boxedbits.com

Version 4.4, 18th of May 2008


Usage
-----

Open a project in Visual Studio .NET.
Select "Add Reference" from the Project menu (or by right-clicking in the Solution Explorer).
Click the Browse button and select the xpllib.dll file which was downloaded as part of this package.
Click OK.

You can now start using the classes exposed by the xplLib assembly.

CANVAS FOR USING XPL-LIB
========================
VB.Net Code
-----------

'....
'somewhere in the Sub Main of an application or the OnStart method of a service
'....
'
            'Create an XplListener object.
            'The constructor takes at least 2 arguments: the vendor id and the device id.
            'A third is optional but highly recommended for exception logging: a reference to the Windows Eventlog
            xL = New xpllib.XplListener("avendor", "smartdev", EventLog)
            
            'Define which configuration items will be communicated between the xPL application and xPLHAL (or another centralised application).
            'Their value will be configurable via xPLHAL and, after succesfull configuration, stored locally in an XML file.
            'In this example: "foo" by default contains "0" (i.e. when the user opens the configuration screen the very first time, foo will contain "0").
            ' "bar" is a multi-valued item that can hold up to 16 values.  It is empty by default.
            xL.ConfigItems.Define("foo", "0")
            xL.ConfigItems.Define("bar", 16)
            
            'By default, what messages will this application want to receive ?
            'The user may overrule these filter settings via xPLHAL.
            xL.Filters.Add(New XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "sensor", "request"))

            'Get ready to start receiving events about the configuration
            AddHandler xL.XplConfigDone, AddressOf xL_XplConfigDone
            AddHandler xL.XplReConfigDone, AddressOf xL_XplReConfigDone

            'We will add extra info to heartbeats
            xL.XplHBeatItems = AddressOf xL_OnHBeatItems
            
            'We will listen to incoming xpl traffic directed to this application (because it passes the filter setup above or overruled by the user)
            AddHandler xL.XplMessageReceived, AddressOf xL_XplMessageReceived

            'Connect to the xPL newtork and start listening
            xL.Listen()

'............

'....
' outside Sub Main or OnStart
' Receiving and working with the Configuration Items
'....


    'This event is raised whenever an initial configuration is received: this configuration can be read from a locally saved XML file,
    'or can come via the xPL network when the user has configured the application (the app was in a state of "awaiting configuration" in xPLHal).
    'If it matters where the configuration comes from then examine the event arguments.  E.g. if you need to validate user input and this is a computational expensive procedure (the contents of the XML was already validated).
    Private Sub xL_XplConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        ReadConfigItems()
    End Sub

    'This event is raised whenever the application is already configured, but the user went through the configuration settings again (in xPLHAL).
    'Depending on the application you may need to take different actions here (close resources etcetera).
    Private Sub xL_XplReConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        ReadConfigItems()
    End Sub

    'Be careful when receiving configuration items: treat them as user input
    Private Sub ReadConfigItems()
        Try
            mFoo = Int32.Parse(xL.ConfigItems.Item("foo").Value)
        Catch ex As Exception
            EventLog.WriteEntry("Error parsing ConfigItem Foo" & Environment.NewLine & ex.Message, EventLogEntryType.Error)
            mFoo = 0
        End Try

        'multi-valued configitems do not necessarily contain as much values as allowed        
        Dim i as Integer = 0
        While i<=xL.ConfigItems.Item("bar").ValueCount-1
            mbar = xL.ConfigItems.Item("bar").Value(i)
            '... use/store the values
            i += 1
        Wend
    End Sub


'....
' outside Sub Main or OnStart
' Receiving an xPL Message and replying with an xPLMessage
'....

    Private Sub xL_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs)
    
        'If we received a query, but not for "mysensor" then we cannot answer this request.
        'GetKeyValue is the way to read a value from an xPL message.
        If e.XplMsg.GetKeyValue("query").ToLower() <> "mysensor" Then Exit Sub

        'Otherwise reply with a xpl-stat message containing the values of "mysensor".
        'Get a prepared xPL Message of the type "xpl-stat".  We will be sending it to everybody, not some specific target.
        Dim x As XplMsg = xL.GetPreparedXplMessage(XplMsg.xPLMsgType.stat, True)
        x.Class = "sensor"
        x.Type = "basic"
        x.AddKeyValuePair("device", "mysensor")
        x.AddKeyValuePair("current", mysensor.readvalue())  'suppose mysensor.readvalue() returns some actual temperature
        x.AddKeyValuePair("type", "temp")
        x.AddKeyValuePair("units", "celsius")
        x.Send()
    End Sub
    
 
'....
' outside Sub Main or OnStart
' Adding information in the Heartbeat message
'....
   
    'This is "old-style": the callback function should return a string where all key-value pairs are seperated with chr(10)-s.
    'Note that the final xPL Heartbeat message will still be validated before it is sent.  So be careful not to use capitals in the keys.
    Public Function xL_OnHBeatItems() As String
        Dim s As String
        s = "schema=sensor.basic" & Chr(10)
        s = s & "type=temp" & Chr(10)
        s = s & "current=" & mysensor.readvalue() & Chr(10)
        Return s
    End Function


 
'....
' Clean up code,
' typically somewhere in the FormClosing event or in the OnStop event of a Windows service
'....

        'calling Dispose on the xPLListener object will send a final "hbeat.end" onto the xPL network
        xL.Dispose();






License
=======

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version, taking 
into account the exception described below.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is contained in the file gpl.txt, which is included as part of this download package.

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
obligated to do so. 


