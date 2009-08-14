'**************************************
'* xPLHal Event Launcher
'*
'* Version 2.20
'*
'* Copyright (C) 2003-2007 John Bent, Ian Jeffery, Tony Tofts 
'* Copyright (C) 2008-2009 Ian Lowe 
'*
'* This program is free software; you can redistribute it and/or
'* modify it under the terms of the GNU General Public License
'* as published by the Free Software Foundation; either version 2
'* of the License, or (at your option) any later version.
'*
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
'**************************************

Imports xPLLogging
Imports xPLLogging.LogLevel
Imports System.Xml

Public Class xPLEvent

    Public Recurring As Boolean ' false = single, true = recurring
    Public EventDateTime As Date ' date/time next event due
    Public EventRunTime As Date ' actual date/time event occurs
    Public StartTime As Date  ' recurring start time
    Public EndTime As Date   ' recurring end time
    Public Interval As Short    ' interval in minutes between recurring
    Public RandomTime As Short     ' minutes for random
    Public DoW As String ' days of week NYYYYYN
    Public RunSub As String ' vbscript to run
    Public Param As String ' parameter to pass to vbscript
    Public Tag As String ' name of this event
    Public Active As Boolean ' is is still an valid event, or deleted
    Public Init As Boolean ' is initialised

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Public Function Valid() As Boolean

        If RunSub.Length = 0 Then Return False
        If Tag.Length = 0 Then Return False
        If Recurring = True Then
            If DoW = Nothing Then Return False
            If DoW.Length <> 7 Then Return False
        End If
        Return True
    End Function

    ' set next event date.time
    Public Function SetNextEvent() As Date
        Dim t As Date
        t = EventDateTime
        If RandomTime = 0 Then Return t
        Return DateAdd(DateInterval.Minute, (Int(Rnd() * (RandomTime + 1))), t)
    End Function

    ' get next event date/time
    Public Function GetNextEvent() As Date
        Dim t, n As Date
        ' get todays date and date/time
        t = Now.Date
        n = DateAdd(DateInterval.Second, 10, Now)
        ' check if end time passed
        If t <> DateAdd(DateInterval.Minute, Interval, n).Date Then
            t = DateAdd(DateInterval.Day, 1, t)
        Else
            If n.TimeOfDay.Ticks > EndTime.Ticks Then
                ' add a day
                t = DateAdd(DateInterval.Day, 1, t)
            End If
        End If
        ' get first valid day
        While DoW.Substring(t.DayOfWeek, 1) = "N"
            t = DateAdd(DateInterval.Day, 1, t)
        End While
        ' set start time
        t = t.Date.Add(StartTime.TimeOfDay)
        ' find next event
        If Interval > 0 Then
            While t.Date <= n.Date And (t.TimeOfDay.TotalHours * 60) + t.TimeOfDay.TotalMinutes <= (n.TimeOfDay.TotalHours * 60) + n.TimeOfDay.TotalMinutes
                t = DateAdd(DateInterval.Minute, Interval, t)
            End While
        End If
        ' return new start time
        Return t
    End Function

End Class

Public Class EventLauncher

    Public Shared DataFileFolder As String = ""
    Public Shared EventCount As Integer

    Public Shared Event ExecuteRule(ByVal rulename As String, ByVal offset As Integer, ByVal RunIfDisabled As Boolean)
    Public Shared Event RunScript(ByVal strScript As String, ByVal HasParams As Boolean, ByVal strParams As Object)

    Private Shared xPLEvents As New Collection

    Public Shared ReadOnly Property GetEvent(ByVal EventName As String) As xPLEvent
        Get
            If EventName = "" Then Return Nothing
            Dim EventKey As String = EventName.Trim
            If xPLEvents.Contains(EventKey) Then
                Dim entry As xPLEvent = xPLEvents(EventKey)
                Return entry
            Else
                Return Nothing
            End If
        End Get
    End Property

    Public Shared Function CompareEvents(ByVal Event1 As xPLEvent, ByVal Event2 As xPLEvent) As Boolean
        Dim Event1XML As XElement = <event
                                        tag=<%= Event1.Tag %>
                                        starttime=<%= Event1.StartTime %>
                                        endtime=<%= Event1.EndTime %>
                                        dow=<%= Event1.DoW %>
                                        randomtime=<%= Event1.RandomTime %>
                                        recurring=<%= Event1.Recurring %>
                                        interval=<%= Event1.Interval %>
                                        runsub=<%= Event1.RunSub %>
                                        param=<%= Event1.Param %>
                                        eventdatetime=<%= Event1.EventDateTime %>
                                        eventruntime=<%= Event1.EventRunTime %>
                                        init=<%= Event1.Init %>/>

        Dim Event2XML As XElement = <event
                                        tag=<%= Event2.Tag %>
                                        starttime=<%= Event2.StartTime %>
                                        endtime=<%= Event2.EndTime %>
                                        dow=<%= Event2.DoW %>
                                        randomtime=<%= Event2.RandomTime %>
                                        recurring=<%= Event2.Recurring %>
                                        interval=<%= Event2.Interval %>
                                        runsub=<%= Event2.RunSub %>
                                        param=<%= Event2.Param %>
                                        eventdatetime=<%= Event2.EventDateTime %>
                                        eventruntime=<%= Event2.EventRunTime %>
                                        init=<%= Event2.Init %>/>

        Return Event1XML.ToString = Event2XML.ToString
    End Function


    Public Shared Function ListAllEvents(ByVal _filter As String) As Collection
        Dim FilteredSet As New Collection
        For Each entry As xPLEvent In xPLEvents
            If entry.Active Then
                Select Case _filter
                    Case "recurring"
                        If entry.Recurring Then
                            FilteredSet.Add(entry, entry.Tag)
                        End If
                    Case "single"
                        If entry.Recurring = False Then
                            FilteredSet.Add(entry, entry.Tag)
                        End If
                    Case Else
                        FilteredSet.Add(entry, entry.Tag)
                End Select
            End If
        Next
        Return FilteredSet
    End Function

    ' add event
    Public Shared Function Add(ByVal xEvent As xPLEvent) As Boolean
        If xEvent IsNot Nothing Then
            Dim EventKey As String = xEvent.Tag.ToLower.Trim
            Try
                If xPLEvents.Contains(EventKey) And EventKey <> "" Then
                    If CompareEvents(xEvent, xPLEvents(EventKey)) = False Then
                        xPLEvents.Remove(EventKey)
                        xPLEvents.Add(xEvent)
                        Logger.AddLogEntry(AppInfo, "event", "Modified Event Entry: " & EventKey.ToString.Trim)
                        Return True
                    Else
                        Logger.AddLogEntry(AppWarn, "event", "Failed to add an identical event: " & EventKey.ToString.Trim)
                        Return False
                    End If
                Else
                    If xEvent.Valid Then
                        xPLEvents.Add(xEvent, EventKey)
                        Logger.AddLogEntry(AppInfo, "event", "Added New Event: " & EventKey.ToString.Trim)
                        Return True
                    Else
                        Logger.AddLogEntry(AppError, "event", "Cannot Add Event (invalid event): " & EventKey.ToString.Trim)
                        Return False
                    End If
                End If
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "event", "Failed to Add Event: " & EventKey.ToString.Trim)
                Logger.AddLogEntry(AppError, "event", "Cause: " & ex.Message)
                Return False
            End Try
        End If
    End Function


    ' delete event
    Public Shared Sub Remove(ByVal EventKey As String)
        If xPLEvents.Contains(EventKey) Then
            Try
                xPLEvents.Remove(EventKey)
                Logger.AddLogEntry(AppInfo, "event", "Removed Event: " & EventKey.ToString.Trim)
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "event", "Failed to Remove Event: " & EventKey.ToString.Trim)
                Logger.AddLogEntry(AppError, "event", "Cause: " & ex.Message)
            End Try
        End If
    End Sub


    ' run events
    Public Shared Sub RunEvents()
        For Each EventEntry As xPLEvent In xPLEvents
            If EventEntry.Active = True Then
                If EventEntry.EventRunTime.CompareTo(Now) <= 0 Then
                    EventEntry.Active = EventEntry.Recurring
                    Logger.AddLogEntry(AppInfo, "event", "Running event: " & EventEntry.Tag)
                    Try
                        If EventEntry.RunSub = "{determinator}" Then
                            Logger.AddLogEntry(AppInfo, "event", "Running rule " & EventEntry.Param)
                            RaiseEvent ExecuteRule(EventEntry.Param, 0, False)

                        ElseIf EventEntry.RunSub = "{suspended-determinator}" Then
                            Dim ruleName As String, ruleOffset As Integer
                            ruleName = EventEntry.Param
                            Logger.AddLogEntry(AppInfo, "event", "About to resume execution of " & ruleName)

                            ruleOffset = CInt(ruleName.Substring(0, ruleName.IndexOf(":")))
                            ruleName = ruleName.Substring(ruleName.IndexOf(":") + 1, ruleName.Length - ruleName.IndexOf(":") - 1)
                            RaiseEvent ExecuteRule(ruleName, ruleOffset, False)
                        Else
                            If EventEntry.Param.ToString.Length > 0 Then
                                RaiseEvent RunScript(GetScriptSub(EventEntry.RunSub), True, EventEntry.Param.ToString)
                            Else
                                Logger.AddLogEntry(AppInfo, "event", "Running script " & EventEntry.RunSub)
                                RaiseEvent RunScript(GetScriptSub(EventEntry.RunSub), False, "")
                            End If
                        End If
                    Catch ex As Exception
                        Logger.AddLogEntry(AppError, "event", "Error Executing Event for script " & GetScriptSub(EventEntry.RunSub) & " (" & Err.Description & ")")
                    End Try
                End If
            End If
        Next
        UpdateEvents()

    End Sub

    ' save events to XML
    Public Shared Sub Save()
        Dim _eventfilestore As String = DataFileFolder + "\xplhal_events.xml"

        Dim xmlOutput As New XElement("events")
        For Each Entry As xPLEvent In xPLEvents
            xmlOutput.Add(<event
                              tag=<%= Entry.Tag %>
                              starttime=<%= Entry.StartTime %>
                              endtime=<%= Entry.EndTime %>
                              dow=<%= Entry.DoW %>
                              randomtime=<%= Entry.RandomTime %>
                              recurring=<%= Entry.Recurring %>
                              interval=<%= Entry.Interval %>
                              runsub=<%= Entry.RunSub %>
                              param=<%= Entry.Param %>
                              eventdatetime=<%= Entry.EventDateTime %>
                              eventruntime=<%= Entry.EventRunTime %>
                              init=<%= Entry.Init %>/>)
        Next
        Try
            xmlOutput.Save(_eventfilestore)
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "event", "Error Writing Events to XML.")
            Logger.AddLogEntry(AppError, "event", "Cause: " & ex.Message)
        End Try
    End Sub

    'Load Object Cache from XML
    Public Shared Sub Load()
        xPLEvents.Clear()

        Dim _eventfilestore As String = DataFileFolder + "\xplhal_events.xml"
        If Dir(_eventfilestore) <> "" Then
            Try
                Dim xmlInput = XDocument.Load(_eventfilestore)
                Dim AllEventsinXML = xmlInput.<events>.Elements
                For Each EventEntry In AllEventsinXML
                    Dim newEvent As New xPLEvent
                    With newEvent
                        .Tag = EventEntry.Attribute("tag").Value
                        .StartTime = EventEntry.Attribute("starttime").Value
                        .EndTime = EventEntry.Attribute("endtime").Value
                        .DoW = EventEntry.Attribute("dow").Value
                        .RandomTime = EventEntry.Attribute("randomtime").Value
                        .Recurring = EventEntry.Attribute("recurring").Value
                        .Interval = EventEntry.Attribute("interval").Value
                        .RunSub = EventEntry.Attribute("runsub").Value
                        .Param = EventEntry.Attribute("param").Value
                        .EventDateTime = EventEntry.Attribute("eventdatetime").Value
                        .EventRunTime = EventEntry.Attribute("eventruntime").Value
                        .Init = EventEntry.Attribute("init").Value
                        .Active = True
                    End With
                    xPLEvents.Add(newEvent, newEvent.Tag)
                Next
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "event", "Error Reading Events from XML (" & Err.Description & ")")
                Exit Sub
            End Try
        Else
            Logger.AddLogEntry(AppError, "event", "XML Events File not found. Creating new one at: " & _eventfilestore)
            Dim newEventStore As New XDocument
            newEventStore.Add(<events></events>)
            newEventStore.Save(_eventfilestore)
        End If
    End Sub


    ' build safe name for script routine
    Private Shared Function GetScriptSub(ByVal strSubName As String) As String
        Dim strSub As String
        strSub = ""
        Dim x As Integer
        strSubName = strSubName.Trim().ToUpper()
        For x = 1 To Len(strSubName)
            Select Case Mid(strSubName, x, 1)
                Case "0" To "9"
                    strSub = strSub + Mid(strSubName, x, 1)
                Case "A" To "Z"
                    strSub = strSub + Mid(strSubName, x, 1)
                Case Else
                    strSub = strSub + "_"
            End Select
        Next x
        Return strSub
    End Function

    ' update events
    Private Shared Sub UpdateEvents()

        For Each EventEntry As xPLEvent In xPLEvents
            If EventEntry IsNot Nothing Then
                If EventEntry.Active Then
                    If EventEntry.Recurring Then
                        With EventEntry
                            .EventDateTime = .GetNextEvent
                            .EventRunTime = .SetNextEvent
                        End With
                    End If
                Else
                    Remove(EventEntry.ToString)
                End If
            End If
        Next
    End Sub

    ' handle events
    Public Shared Function BuildSingleEvent(ByVal evtDateTime As Date, _
                                            ByVal evtRunSub As String, _
                                            ByVal evtParam As String, _
                                            ByVal evtTag As String) As xPLEvent
        Dim eventEntry As New xPLEvent
        Try
            If Not IsDate(evtDateTime) Then Return Nothing
            eventEntry.Recurring = False
            eventEntry.EventDateTime = evtDateTime
            eventEntry.EventRunTime = eventEntry.EventDateTime
            eventEntry.RunSub = evtRunSub
            eventEntry.Param = evtParam
            eventEntry.Tag = UCase(evtTag)
        Catch ex As Exception
            Return Nothing
        End Try
        If eventEntry.RunSub.Length = 0 Then Return Nothing
        If eventEntry.Tag.Length = 0 Then Return Nothing
        eventEntry.RandomTime = 0
        eventEntry.Active = True
        Return eventEntry
    End Function

    Public Shared Function BuildRecurringEvent(ByVal evtStart As Date, _
                                               ByVal evtEnd As Date, _
                                               ByVal evtInterval As Short, _
                                               ByVal evtRandom As Short, _
                                               ByVal evtDoW As String, _
                                               ByVal evtRunSub As String, _
                                               ByVal evtParam As String, _
                                               ByVal evtTag As String, _
                                               ByVal evtOverWrite As Boolean) As xPLEvent

        If evtOverWrite = False And xPLEvents.Contains(evtTag) Then Return Nothing
        Dim eventEntry As New xPLEvent
        eventEntry.Recurring = True
        Try
            eventEntry.EventDateTime = DateAdd(DateInterval.Day, 1, Now)
            eventEntry.EventRunTime = eventEntry.EventDateTime
            eventEntry.StartTime = evtStart
            eventEntry.EndTime = evtEnd
            eventEntry.Interval = Int(Val(evtInterval))
            If eventEntry.Interval < 0 Then eventEntry.Interval = 0
            If eventEntry.Interval = 0 Then eventEntry.EndTime = eventEntry.StartTime
            eventEntry.RandomTime = Int(Val(evtRandom))
            If eventEntry.RandomTime < 0 Then eventEntry.RandomTime = 0
            eventEntry.DoW = evtDoW
            eventEntry.RunSub = evtRunSub
            eventEntry.Param = evtParam
            eventEntry.Tag = UCase(evtTag)
        Catch ex As Exception
            Return Nothing
        End Try
        If eventEntry.DoW.Length > 7 Then eventEntry.DoW = eventEntry.DoW.Substring(0, 7)
        If eventEntry.DoW.Length < 7 Then eventEntry.DoW = eventEntry.DoW & "YYYYYYY".Substring(0, 7 - eventEntry.DoW.Length)
        If eventEntry.DoW = "NNNNNNN" Then Return Nothing
        If eventEntry.RunSub.Length = 0 Then Return Nothing
        If eventEntry.Tag.Length = 0 Then Return Nothing
        eventEntry.Active = True
        Return eventEntry
    End Function
End Class
