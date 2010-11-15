'* xPL Comfort Service
'*
'* Copyright (C) 2004-2005 John Bent
'* http://www.xpl.myby.co.uk/
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
Option Strict On

Public Class comfort
  Inherits CommBase

  Private Const DEBUG_LOG As String = "c:\xplcomfort-debug.log"
  Private Const DEFAULT_COMFORT_PORT As Integer = 1001
  Private Const MAX_BUFF_SIZE As Integer = 255

  Public EventLog As EventLog

  Private WithEvents Timer1 As System.Timers.Timer
  Private TimerCount As Integer

  Private bEnableLogging As Boolean
  Private CommsOK As Boolean
  Private LastHousekeepingDay As Date
  Private LastResponseFromComfort As Date
  Private WithEvents myXplListener As xpllib.XplListener
  Private ComfortBuff(MAX_BUFF_SIZE) As Byte
  Private CurrentComfortBuffSize As Integer
  Private Sock As Socket

  Public Sub Initialise()
    CommsOK = False
    bEnableLogging = False
    TimerCount = 1
        myXplListener = New xpllib.XplListener("johnb-comfort", "1", EventLog)

    ' Add supported remote config items
        myXplListener.ConfigItems.Define("ucmhost", "", xpllib.xplConfigTypes.xReconf, 1)
        myXplListener.ConfigItems.Define("ucmport", "1001", xpllib.xplConfigTypes.xReconf, 1)
        myXplListener.ConfigItems.Define("usercode", "1234", xpllib.xplConfigTypes.xReconf, 1)
        myXplListener.ConfigItems.Define("clocksync", "Y", xpllib.xplConfigTypes.xOption, 1)
        myXplListener.ConfigItems.Define("x10", "N", xpllib.xplConfigTypes.xOption, 1)
    myXplListener.Listen()
    If Not myXplListener.AwaitingConfiguration Then
      ' Go ahead and set things up
      myXplListener_XplConfigDone()
    End If
    Timer1 = New System.Timers.Timer
    Timer1.Interval = 60000
    Timer1.Enabled = True
  End Sub

  Public Sub Shutdown()
    myXplListener.Dispose()
    SendToComfort("LI")
    If bEnableLogging Then
      WriteDebugLog("Shutting down")
    End If
    myXplListener = Nothing
    DisconnectFromUCM()
  End Sub

  Private Sub WriteDebugLog(ByVal str As String)
    Exit Sub
    Try
      Dim fs As TextWriter = File.AppendText(DEBUG_LOG)
      fs.WriteLine(Now.ToString("dd/MMM/yyyy HH:mm:ss") & " " & str)
      fs.Close()
    Catch ex As Exception
    End Try
  End Sub

  Private Sub SendToComfort(ByVal str As String)
    ' Sends a string to the comfort UCM
    Try
      If bEnableLogging Then
        WriteDebugLog("Sending to comfort: " & str)
      End If
      If Not Sock Is Nothing Then
        If Sock.Connected Then
          Sock.Send(Encoding.UTF8.GetBytes(Chr(3) & str & vbCr))
        End If
      ElseIf CommsOK Then
        Send(Encoding.UTF8.GetBytes(Chr(3) & str & vbCr))
      End If
    Catch ex As Exception
      EventLog.WriteEntry("Error sending the string " & str & " to Comfort: " & ex.Message, EventLogEntryType.Error)
    End Try
  End Sub

  Private Sub ReceiveFromComfort(ByVal str As String)
    Dim d1, d2 As String

    ' Receives a string from the comfort UCM
    LastResponseFromComfort = DateTime.Now
    If bEnableLogging Then
      WriteDebugLog("Received: " & str)
    End If
    ' Determine the 2nd and 3rd characters    
    Select Case str.Substring(1, 2)
      Case "A?" ' Analogue input value
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        d2 = CInt("&H" & str.Substring(5, 2)).ToString
        myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=" & d1 & vbLf & "type=analogueinput" & vbLf & "current=" & d2 & vbLf)
      Case "AL" ' Alarm type report
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        d2 = str.Substring(5, 2)
        Select Case d2
          Case "00"
            d2 = "idle"
          Case "01"
            d2 = "trouble"
          Case "02"
            d2 = "alert"
          Case "03"
            d2 = "alarm"
        End Select
        myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=alarm" & vbLf & "current=" & d2 & vbLf)
      Case "AM", "AR" ' System alarm and restore reports
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        If str.Length > 6 Then
          d2 = "&H" & str.Substring(5, 2)
        Else
          d2 = ""
        End If
        Select Case CInt(d1)
          Case 0
            d1 = "intruder"
          Case 1
            d1 = "zonetrouble"
          Case 2
            d1 = "lowbattery"
          Case 3
            d1 = "powerfail"
          Case 4
            d1 = "phonetrouble"
          Case 5
            d1 = "duress"
          Case 6
            d1 = "armfail"
          Case 8
            d1 = "disarmed"
            d2 = CStr(CInt(d2) - 128)
          Case 9
            d1 = "armed"
          Case 10
            d1 = "tamper"
          Case 12
            d1 = "entrywarning"
          Case 13
            d1 = "alarmabort"
          Case 14
            d1 = "sirentamper"
          Case 15
            d1 = "bypass"
          Case 17
            d1 = "dialtest"
          Case 19
            d1 = "entryalert"
          Case 20
            d1 = "fire"
          Case 21
            d1 = "panic"
          Case 23
            d1 = "newmessage"
          Case 24
            d1 = "doorbell"
          Case 25
            d1 = "commsfail"
          Case 26
            d1 = "signintamper"
        End Select
        If str.Substring(1, 2) = "AR" Then
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=sysalarmrestore" & vbLf & "current=" & d2 & vbLf)
        Else
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=sysalarm" & vbLf & "current=" & d2 & vbLf)
        End If
      Case "CT", "C?" ' Counter change/status reports
        d1 = str.Substring(3, 2)
        d2 = str.Substring(5, 2)
        ' Convert to decimal
        d1 = CStr(CInt("&H" & d1))
        d2 = CStr(CInt("&H" & d2))
        If str.Substring(1, 2) = "C?" Then
          myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=" & d1 & vbLf & "type=variable" & vbLf & "current=" & d2 & vbLf)
        Else
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=variable" & vbLf & "current=" & d2 & vbLf)
        End If
      Case "DB" ' Door bell pressed
        d1 = str.Substring(3, 2)
        myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=doorbell" & vbLf & "type=generic" & vbLf & "current=" & d1 & vbLf)
      Case "IP", "I?" ' Input activation/status report
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        d2 = str.Substring(5, 2)
        Select Case d2
          Case "00"
            d2 = "off"
          Case "01"
            d2 = "on"
          Case "02"
            d2 = "short"
          Case "03"
            d2 = "open"
        End Select
        If str.Substring(1, 2) = "IP" Then
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=input" & vbLf & "current=" & d2 & vbLf)
        Else
          myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=" & d1 & vbLf & "type=input" & vbLf & "current=" & d2 & vbLf)
        End If
      Case "IX" ' Infra-red command received
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        myXplListener.SendMessage("xpl-trig", "*", "remote.basic", "device=comfort" & vbLf & "keys=" & d1 & vbLf)
      Case "MD", "M?" ' Security mode change/status reports
        d1 = str.Substring(3, 2)
        Select Case d1
          Case "00"
            d1 = "off"
          Case "01"
            d1 = "away"
          Case "02"
            d1 = "night"
          Case "03"
            d1 = "day"
          Case "04"
            d1 = "holiday"
        End Select
        If str.Substring(1, 2) = "M?" Then
          myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=Security Mode" & vbLf & "type=security" & vbLf & "current=" & d1 & vbLf)
        Else
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=Security Mode" & vbLf & "type=security" & vbLf & "current=" & d1 & vbLf)
        End If
      Case "OP", "O?" ' Output activation/status reports
        d1 = CInt("&H" & str.Substring(3, 2)).ToString
        d2 = str.Substring(5, 2)
        Select Case d2
          Case "00"
            d2 = "off"
          Case "01"
            d2 = "on"
        End Select
        If str.Substring(1, 2) = "O?" Then
          myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=" & d1 & vbLf & "type=output" & vbLf & "current=" & d2 & vbLf)
        Else
          myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=" & d1 & vbLf & "type=output" & vbLf & "current=" & d2 & vbLf)
        End If
      Case "XT" ' X10 transmit report
        Dim h As String = str.Substring(3, 1)
        Dim u As String = str.Substring(4, 2)
        Dim f As String = str.Substring(6, 2)
        ' Convert unit code to decimal
        u = CStr(CInt("&H" & u))
        Select Case f.ToUpper()
          Case "01"
            f = "all_units_off"
          Case "05"
            f = "on"
          Case "07"
            f = "off"
          Case "09"
            f = "dim"
          Case "0B"
            f = "bright"
          Case Else ' Unrecognised function code
            Exit Sub
        End Select
        myXplListener.SendMessage("xpl-trig", "*", "x10.confirm", "command=" & f & vbLf & "device=" & h & u & vbLf)
    End Select
  End Sub

  Private Sub myXplListener_XplConfigDone() Handles myXplListener.XplConfigDone
    If Not Sock Is Nothing Then
      Sock.Shutdown(SocketShutdown.Both)
      Sock.Close()
    End If
    If Not myXplListener.ConfigItems("ucmhost").Value(0).ToUpper = "RS232" Then
      ethernetConnect()
    ElseIf IsNumeric(myXplListener.ConfigItems("ucmport").Value(0)) Then
      serialConnect()
    End If
  End Sub

  Private Sub ethernetConnect()
    Dim portnum As Integer
    Dim portval As String = myXplListener.ConfigItems("ucmport").Value(0)
    Dim hostname As String = myXplListener.ConfigItems("ucmhost").Value(0)
    Try
      If IsNumeric(portval) Then
        portnum = CInt(portval)
        If portnum < 0 Or portnum > 65535 Then
          portnum = DEFAULT_COMFORT_PORT
        End If
      Else
        portnum = DEFAULT_COMFORT_PORT
      End If
      Sock = New Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
      Sock.Connect(New IPEndPoint(Dns.Resolve(hostname).AddressList(0), portnum))
      CurrentComfortBuffSize = 0
      Sock.BeginReceive(ComfortBuff, CurrentComfortBuffSize, MAX_BUFF_SIZE, SocketFlags.None, AddressOf Me.ReceiveData, Nothing)
      WriteDebugLog("Connected to UCM/Ethernet at " & hostname & ":" & portval)
      LogInToUCM()
    Catch ex As Exception
      If bEnableLogging Then
        WriteDebugLog("EthernetConnect failed when attempting to connect to " & hostname & ":" & portval & ". The error was as follows: " & ex.ToString)
      End If
      EventLog.WriteEntry("EthernetConnect failed when attempting to connect to " & hostname & ":" & portval & ". The error was as follows: " & ex.Message, EventLogEntryType.Error)
    End Try
  End Sub

  Private Sub ReceiveData(ByVal ar As IAsyncResult)
    Dim bytes_read As Integer = Sock.EndReceive(ar)
    CurrentComfortBuffSize += bytes_read
    'WriteDebugLog("Read bytes: " & Encoding.UTF8.GetString(ComfortBuff))
    ' If the last read character is a Cr, then we've got a command ready for processing
    If ComfortBuff(CurrentComfortBuffSize - 1) = 13 Then
      Try
        ReceiveFromComfort(Encoding.UTF8.GetString(ComfortBuff).Substring(0, CurrentComfortBuffSize - 1))
      Catch ex As Exception
        WriteDebugLog("Error processing received command: " & ex.ToString)
      End Try
      CurrentComfortBuffSize = 0
    End If
    Sock.BeginReceive(ComfortBuff, CurrentComfortBuffSize, MAX_BUFF_SIZE - CurrentComfortBuffSize, SocketFlags.None, AddressOf Me.ReceiveData, Nothing)
  End Sub

  Private Sub LogInToUCM()
    SendToComfort("LI" & myXplListener.ConfigItems("usercode").Value(0))
  End Sub

  Private Sub myXplListener_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles myXplListener.XplMessageReceived
    Dim x As xpllib.XplMsg = e.XplMsg
    Dim x10support As String = myXplListener.ConfigItems("x10").Value(0).ToUpper
    ' Look for command messages
    Select Case x.XPL_Msg(0).Section.ToLower
      Case "xpl-cmnd"
        Select Case x.Schema.msgClass
          Case "control"
            ProcessControlMessage(x)
          Case "x10"
            If x10support = "Y" Then
              ProcessX10Message(x)
            End If
        End Select
    End Select
  End Sub

  Private Sub ProcessX10Message(ByRef x As xpllib.XplMsg)
    Try
      Dim d As String = x.GetParam(1, "device").Trim.ToUpper
      If d.Length < 2 Then Exit Sub
      Dim h As String = d.Substring(0, 1)
      Dim u As String = d.Substring(1, d.Length - 1)
      Dim c As String = x.GetParam(1, "command").Trim.ToLower
      ' Convert unit code to hex
      u = Hex(u)
      If u.Length < 2 Then
        u = "0" & u
      End If
      Select Case c
        Case "all_lights_off"
          c = "13"
        Case "all_lights_on"
          c = "03"
        Case "all_units_off"
          c = "01"
        Case "bright"
          c = "0B"
        Case "dim"
          c = "09"
        Case "on"
          c = "05"
        Case "off"
          c = "07"
        Case Else ' Unrecognised command
          Exit Sub
      End Select
      SendToComfort("X!" & h & u & c & "00")
    Catch ex As Exception
    End Try
  End Sub

  Private Sub ProcessControlMessage(ByRef x As xpllib.XplMsg)
    Dim d As String = x.GetParam(1, "device")
    Dim t As String = x.GetParam(1, "type")
    Dim c As String = x.GetParam(1, "current")

    Select Case t.ToLower.Trim
      Case "analogueinput"
        If c = "request" Then
          d = Hex(CInt(d))
          If d.Length < 2 Then d = "0" & d
          SendToComfort("A?" & d)
        End If
      Case "digit"
        If d.Trim.ToLower = "keypad" Then
          Dim digits() As String = c.Split(CChar(","))
          For Counter As Integer = 0 To digits.Length - 1
            If digits(counter).length < 2 Then
              digits(counter) = "0" & digits(counter)
            End If
            SendToComfort("KD" & digits(counter))
          Next
        End If
      Case "variable"
        If CInt(c) < 0 Or CInt(c) > 255 Then
          Exit Sub
        End If
        c = Hex(CInt(c))
        If d.Length < 2 Then
          d = "0" & d
        End If
        If c.Length < 2 Then
          c = "0" & c
        End If
        SendToComfort("C!" & d & c)
      Case "generic"
        Select Case d.ToLower
          Case "action"
            Dim bits() As String = c.Split(CChar(","))
            If bits.Length < 1 Or bits.Length > 24 Then
              Exit Sub
            End If
            Dim fullstring As String = "DA"
            For Counter As Integer = 0 To bits.Length - 1
              bits(Counter) = Hex(bits(Counter))
              If bits(Counter).Length < 2 Then bits(Counter) = "0" & bits(Counter)
              fullstring &= bits(Counter)
            Next
            SendToComfort(fullstring)
          Case "response"
            c = Hex(c)
            If c.Length < 2 Then c = "0" & c
            SendToComfort("R!" & c)
          Case "speaker"
            Select Case c
              Case "off"
                c = "00"
              Case "on"
                c = "01"
              Case "slow"
                c = "02"
              Case "fast"
                c = "03"
              Case "error"
                c = "04"
              Case Else
                Exit Sub
            End Select
            SendToComfort("BP" & c)
        End Select
      Case "input"
        If c = "request" Then
          d = Hex(CInt(d))
          If d.Length < 2 Then d = "0" & d
          SendToComfort("I?" & d)
        End If
      Case "output"
        d = Hex(CInt(d))
        If d.Length < 2 Then d = "0" & d
        If c = "request" Then
          SendToComfort("O?" & d)
        Else
          ' Set state of output
          Select Case c
            Case "off", "low"
              c = "00"
            Case "on", "high"
              c = "01"
            Case "toggle"
              c = "02"
            Case "pulse"
              c = "03"
            Case "flash"
              c = "04"
            Case Else
              Exit Sub
          End Select
          SendToComfort("O!" & d & c)
        End If
      Case "security"
        If d = "security mode" Then
          If c = "request" Then
            SendToComfort("M?")
          Else
            Dim ss As String
            Dim usercode As String = x.GetParam(1, "usercode")
            If usercode = "" Then
              usercode = myXplListener.ConfigItems("usercode").Value(0)
            End If
            Select Case c
              Case "off"
                c = "00"
              Case "away"
                c = "01"
              Case "night"
                c = "02"
              Case "day"
                c = "03"
              Case "holiday"
                c = "04"
              Case Else
                Exit Sub
            End Select
            SendToComfort("M!" & c & usercode)
          End If
        End If
    End Select

  End Sub

  Private Sub HouseKeeping()
    If Not Now.Today = LastHousekeepingDay Then
      WriteDebugLog("Doing housekeeping...")
      DisconnectFromUCM()
      Threading.Thread.Sleep(1000)
      ConnectToUCM()
      ClockSync()
      LastHousekeepingDay = Now.Today
    End If
  End Sub

  Private Sub Timer1_Elapsed(ByVal sender As Object, ByVal e As System.Timers.ElapsedEventArgs) Handles Timer1.Elapsed
    Timer1.Enabled = False
    Try
      TimerCount += 1
      ConnectToUCM()
      If TimerCount > 5 Then
        HouseKeeping()
        TimerCount = 1
      End If
    Catch ex As Exception
      EventLog.WriteEntry("Error processing timer: " & ex.ToString, EventLogEntryType.Error)
    End Try
    Timer1.Enabled = True
  End Sub

  Protected Overrides Function CommSettings() As CommBaseSettings
    Dim cs As New CommBaseSettings
    cs.SetStandard("COM" & myXplListener.ConfigItems("ucmport").Value(0) & ":", 9600, CommBase.Handshake.none)
    Return cs
  End Function

  Protected Overrides Sub Finalize()
    MyBase.Close()
    MyBase.Finalize()
  End Sub

  Protected Overrides Sub OnRxChar(ByVal c As Byte)
    ComfortBuff(CurrentComfortBuffSize) = c
    CurrentComfortBuffSize += 1
    If c = 13 Then
      ' End of command
      Try
        ReceiveFromComfort(Encoding.UTF8.GetString(ComfortBuff).Substring(0, CurrentComfortBuffSize - 1))
      Catch ex As Exception
        WriteDebugLog("Error processing received command: " & ex.ToString)
      End Try
      CurrentComfortBuffSize = 0
    End If
  End Sub

  Private Sub serialConnect()
    Try
      If CommsOK Then Exit Sub
      If MyBase.Open Then
        CommsOK = True
        WriteDebugLog("Communications port opened successfully.")
        LogInToUCM()
      Else
        CommsOK = False
        EventLog.WriteEntry("Could not connect to the UCM via RS232 on port " & myXplListener.ConfigItems("uchport").Value(0), EventLogEntryType.Error)
        WriteDebugLog("Could not connect to the UCM via RS232 on port " & myXplListener.ConfigItems("uchport").Value(0))
      End If
    Catch ex As Exception
      EventLog.WriteEntry("RS232 connect failed with the following error: " & ex.Message, EventLogEntryType.Error)
    End Try
  End Sub

  Private Sub ConnectToUCM()
    ' Connects to UCM, or re-connects if connection has failed
    ' Ensure we're connected to the UCM
    If myXplListener.ConfigItems("ucmhost").Value(0).ToUpper = "RS232" Then
      serialConnect()
    Else
      If Not Sock Is Nothing Then
        If Not Sock.Connected Then
          WriteDebugLog("Socket not connected.")
          ethernetConnect()
        End If
      End If
    End If
  End Sub

  Private Sub ClockSync()
    ' Syncs Comfort's clock with that of the PC, if enabled
    If myXplListener.ConfigItems("clocksync").Value(0).ToUpper = "Y" Then
      SendToComfort("DT" & Now.ToString("yyyyMMddHHmmss"))
    End If
  End Sub

  Private Sub DisconnectFromUCM()
    Try
      If Not Sock Is Nothing Then
        If Sock.Connected Then
          Sock.Shutdown(SocketShutdown.Both)
          Sock.Close()
        End If
      End If
    Catch ex As Exception
    End Try
    Try
      CommsOK = False
      MyBase.Close()
    Catch ex As Exception
    End Try
  End Sub

End Class
