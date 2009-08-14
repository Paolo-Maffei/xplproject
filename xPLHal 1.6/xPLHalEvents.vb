'**************************************
'* xPLHal 
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
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
Option Strict On

Public Class xPLHalEvents

    <Serializable()> Public Structure xPLEventStruc
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
    End Structure

    Public xPLEventsHash As New Hashtable
    Public xPLEvents() As xPLEventStruc
    Public xPLEventsCount As Integer

    ' add event
    Public Function Add(ByVal e As xPLEventStruc) As Boolean
        Dim x, y As Integer
        Dim IsNew As Boolean = False
        If e.RunSub.Length = 0 Then Return False
        If e.Tag.Length = 0 Then Return False
        If e.Recurring = True Then
            If e.DoW = Nothing Then Return False
            If e.DoW.Length <> 7 Then Return False
        End If
        If xPLEventsHash.ContainsKey(e.Tag.ToUpper.Trim) Then
      x = CInt(xPLEventsHash(e.Tag.ToUpper.Trim))
        Else
            x = -1
            For y = 0 To xPLEventsCount
                If xPLEvents(y).Active = False Then
                    x = y
                    Exit For
                End If
            Next
            If x = -1 Then
                xPLEventsCount = xPLEventsCount + 1
                ReDim Preserve xPLEvents(xPLEventsCount)
                x = xPLEventsCount
            End If
            xPLEventsHash.Add(e.Tag.ToUpper.Trim, x)
            IsNew = True
        End If
        If e.Recurring = True Then
            e.Init = False
            e.EventDateTime = GetNextEvent(e)
            e.Init = True
            e.EventRunTime = SetNextEvent(e)
        End If
        If IsNew = True Then xPLEvents(x) = New xPLEventStruc
        xPLEvents(x) = e
        xPLEvents(x).Active = True
        Return True
    End Function

    ' set next event date.time
    Public Function SetNextEvent(ByVal e As xPLEventStruc) As Date
        Dim t As Date
        t = e.EventDateTime
        If e.RandomTime = 0 Then Return t
        Return DateAdd(DateInterval.Minute, (Int(Rnd() * (e.RandomTime + 1))), t)
    End Function

    ' get next event date/time
    Public Function GetNextEvent(ByVal e As xPLEventStruc) As Date
        Dim t, n As Date
        ' get todays date and date/time
        t = Now.Date
        n = DateAdd(DateInterval.Second, 10, Now)
        ' check if end time passed
        If t <> DateAdd(DateInterval.Minute, e.Interval, n).Date Then
            t = DateAdd(DateInterval.Day, 1, t)
        Else
            If n.TimeOfDay.Ticks > e.EndTime.Ticks Then
                ' add a day
                t = DateAdd(DateInterval.Day, 1, t)
            End If
        End If
        ' get first valid day
        While e.DoW.Substring(t.DayOfWeek, 1) = "N"
            t = DateAdd(DateInterval.Day, 1, t)
        End While
        ' set start time
        t = t.Date.Add(e.StartTime.TimeOfDay)
        ' find next event
        If e.Interval > 0 Then
            While t.Date <= n.Date And (t.TimeOfDay.TotalHours * 60) + t.TimeOfDay.TotalMinutes <= (n.TimeOfDay.TotalHours * 60) + n.TimeOfDay.TotalMinutes
                t = DateAdd(DateInterval.Minute, e.Interval, t)
            End While
        End If
        ' return new start time
        Return t
    End Function

    ' delete event
    Public Sub Delete(ByVal evtTag As String)
        Dim x As Integer
        If Not Exists(evtTag) Then Exit Sub
        Try
      x = CInt(xPLEventsHash(evtTag.ToUpper.Trim))
            xPLEvents(x).Active = False
            xPLEventsHash.Remove(evtTag.ToUpper.Trim)
        Catch ex As Exception
        End Try
    End Sub

    ' event exists
  Public Function Exists(ByVal evtTag As String) As Boolean
    Return xPLEventsHash.ContainsKey(evtTag.ToUpper.Trim)
  End Function

  ' run events
  Public Sub RunEvents()
    Dim x As Integer

    For x = 0 To xPLEventsCount
      If xPLEvents(x).Active = True Then
        If xPLEvents(x).EventRunTime.CompareTo(Now) <= 0 Then
          xPLEvents(x).Active = xPLEvents(x).Recurring
          'WriteErrorLog("Running event...")
          Try
            If xPLEvents(x).RunSub = "{determinator}" Then
              'WriteErrorLog("Running rule " & xPLEvents(x).Param)
                            xplDeterminator.ExecuteRule(xPLEvents(x).Param, 0, False)
            ElseIf xPLEvents(x).RunSub = "{suspended-determinator}" Then
              Dim ruleName As String, ruleOffset As Integer
              ruleName = xPLEvents(x).Param
              If xhcp.EnableLogging Then
                WriteErrorLog("About to resume execution of " & ruleName)
              End If
              ruleOffset = CInt(ruleName.Substring(0, ruleName.IndexOf(":")))
              ruleName = ruleName.Substring(ruleName.IndexOf(":") + 1, ruleName.Length - ruleName.IndexOf(":") - 1)
                            xplDeterminator.ExecuteRule(ruleName, ruleOffset)
            Else
              If xPLEvents(x).Param.ToString.Length > 0 Then
                Call RunScript(GetScriptSub(xPLEvents(x).RunSub), True, xPLEvents(x).Param.ToString)
              Else
                'WriteErrorLog("Running script " & xPLEvents(x).RunSub)
                RunScript(GetScriptSub(xPLEvents(x).RunSub), False, "")
              End If
            End If
          Catch ex As Exception
            WriteErrorLog("Error Executing Event for script " & GetScriptSub(xPLEvents(x).RunSub) & " (" & Err.Description & ")")
          End Try
          Call UpdateEvents(x)
        End If
      End If
    Next

  End Sub

  ' save events
  Public Sub Save()
    Dim xml As New Xml.XmlTextWriter(xPLHalData + "\xplhal_events.xml", System.Text.Encoding.ASCII)
        Dim x As Integer

    xml.Formatting = Formatting.Indented
    xml.WriteStartDocument()
    xml.WriteStartElement("events")
    For x = 0 To xPLEventsCount
      If xPLEvents(x).Active = True Then
        Try
          xml.WriteStartElement("event")
          xml.WriteAttributeString("tag", xPLEvents(x).Tag.ToUpper)
          xml.WriteAttributeString("starttime", xPLEvents(x).StartTime.ToString())
          xml.WriteAttributeString("endtime", xPLEvents(x).EndTime.ToString())
          xml.WriteAttributeString("dow", xPLEvents(x).DoW)
          xml.WriteAttributeString("randomtime", xPLEvents(x).RandomTime.ToString())
          xml.WriteAttributeString("recurring", xPLEvents(x).Recurring.ToString())
          xml.WriteAttributeString("interval", xPLEvents(x).Interval.ToString())
          xml.WriteAttributeString("runsub", xPLEvents(x).RunSub)
          xml.WriteAttributeString("param", xPLEvents(x).Param)
          xml.WriteAttributeString("eventdatetime", xPLEvents(x).EventDateTime.ToString())
          xml.WriteAttributeString("eventruntime", xPLEvents(x).EventRunTime.ToString())
          xml.WriteAttributeString("init", xPLEvents(x).Init.ToString())
          xml.WriteEndElement()
        Catch ex As Exception
          Call WriteErrorLog("Error Writing Event " & xPLEvents(x).Tag.ToUpper & " to XML (" & Err.Description & ")")
        End Try
      End If
    Next
    xml.WriteEndElement()
    xml.WriteEndDocument()
    xml.Flush()
    xml.Close()

  End Sub

  ' load xml events
  Public Sub Load()
    Dim wrkEvent As xPLEventStruc
    xPLEventsCount = -1
    ReDim xPLEvents(0)
    xPLEventsHash.Clear()

    If Dir(xPLHalData & "\xplhal_events.xml") <> "" Then
      ' got xml events so load
      Try
        Dim xml As New Xml.XmlTextReader(xPLHalData & "\xplhal_events.xml")
        While xml.Read()
          Select Case xml.NodeType
            Case XmlNodeType.Element
              Select Case xml.Name
                Case "event"
                  wrkEvent.Active = True
                  wrkEvent.Tag = xml.GetAttribute("tag").ToUpper
                  wrkEvent.StartTime = CDate(xml.GetAttribute("starttime"))
                  wrkEvent.EndTime = CDate(xml.GetAttribute("endtime"))
                  wrkEvent.DoW = xml.GetAttribute("dow")
                  wrkEvent.RandomTime = CShort(xml.GetAttribute("randomtime"))
                  wrkEvent.Recurring = CBool(xml.GetAttribute("recurring"))
                  wrkEvent.Interval = CShort(xml.GetAttribute("interval"))
                  wrkEvent.RunSub = xml.GetAttribute("runsub")
                  wrkEvent.Param = xml.GetAttribute("param")
                  wrkEvent.EventDateTime = CDate(xml.GetAttribute("eventdatetime"))
                  wrkEvent.EventRunTime = CDate(xml.GetAttribute("eventruntime"))
                  wrkEvent.Init = CBool(xml.GetAttribute("init"))
                  wrkEvent.Tag = xml.GetAttribute("tag")
                  xPLEventsCount = xPLEventsCount + 1
                  ReDim Preserve xPLEvents(xPLEventsCount)
                  xPLEvents(xPLEventsCount) = wrkEvent
                  xPLEventsHash.Add(xPLEvents(xPLEventsCount).Tag.ToUpper.Trim, xPLEventsCount)
              End Select
          End Select
        End While
        xml.Close()
      Catch ex As Exception
        Call WriteErrorLog("Error Reading Events XML (" & Err.Description & ")")
        xPLEventsCount = -1
        Exit Sub
      End Try
      Call UpdateEvents(-1)
    Else
      ' no xml events, so load bin if it exists and save as xml
      'If Dir(xPLHalData & "\xplhal_events.bin") <> "" Then
      'Call LoadBin()
      'Call Save()
      'End If
    End If
  End Sub

  ' load old binary events
  Public Sub LoadBin()
    'Dim wrkEvents As New Hashtable
    'Dim BinFormatter As New Binary.BinaryFormatter
    'Dim FS As FileStream
    'Dim x As Object
    'Try
    '  FS = New FileStream(xPLHalData + "\xplhal_events.bin", FileMode.Open)
    '  wrkEvents = CType(BinFormatter.Deserialize(FS), Hashtable)
    '  FS.Close()
    'Catch ex As Exception
    '  xPLEventsCount = -1
    '  Exit Sub
    'End Try
    'xPLEventsCount = -1
    'ReDim Preserve xPLEvents(0)
    'xPLEventsHash.Clear()
    'For Each x In wrkEvents.Keys
    '  xPLEventsCount = xPLEventsCount + 1
    '  ReDim Preserve xPLEvents(xPLEventsCount)
    '  xPLEvents(xPLEventsCount) = wrkEvents(x)
    '  xPLEventsHash.Add(xPLEvents(xPLEventsCount).Tag.ToUpper.Trim, xPLEventsCount)
    'Next
    'wrkEvents.Clear()
    'wrkEvents = Nothing
    'Rename(xPLHalData & "\xplhal_events.bin", xPLHalData & "\xplhal_events.bin.old")
    'Call UpdateEvents(-1)
  End Sub

  ' update events
  Private Sub UpdateEvents(ByVal intEvent As Integer)
    Dim y(1) As Integer
    Dim x As Integer
        y(0) = intEvent
    y(1) = intEvent
    If intEvent = -1 Then
      y(0) = 0
      y(1) = xPLEventsCount
    End If
    For x = y(0) To y(1)
      If xPLEvents(x).Active = False Then
        Try
          xPLEventsHash.Remove(xPLEvents(x).Tag.ToUpper.Trim)
        Catch ex As Exception
        End Try
      Else
        If xPLEvents(x).Recurring = True Then
          xPLEvents(x).EventDateTime = GetNextEvent(xPLEvents(x))
          xPLEvents(x).EventRunTime = SetNextEvent(xPLEvents(x))
        End If
      End If
    Next
  End Sub

End Class
