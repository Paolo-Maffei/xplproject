Imports System.Xml
Imports System.Xml.XPath
Imports System.IO
Imports xpllib

Public Class xplCurrentCost

    Const Classic As Integer = 1
    Const CC128 As Integer = 2

    Dim comport As Int32
    Dim baud As Int32
    Dim changedOnly As Boolean

    Dim sensorEnabled As New Dictionary(Of Integer, Boolean)
    Dim sensorName As New Dictionary(Of Integer, String)
    Dim sensorValue As New Dictionary(Of Integer, String)
    Dim sensorValueNew As New Dictionary(Of Integer, String)

    Dim tmprEnabled As Boolean
    Dim tmprName As String
    Dim tmprValue As String
    Dim tmprValueNew As String

    Dim first As Boolean = False

    Dim xL As xpllib.XplListener

    Dim WithEvents serialPort As New IO.Ports.SerialPort

    Protected Overrides Sub OnStart(ByVal args() As String)

        xL = New xpllib.XplListener("slateblu", "currcost", EventLog)
        xL.ConfigItems.Define("comport")
        xL.ConfigItems.Define("baud", "9600")
        xL.ConfigItems.Define("changed-only", "0")

        For i = 1 To 3
            xL.ConfigItems.Define("ch" & i.ToString & "-enabled", "1")
            xL.ConfigItems.Define("ch" & i.ToString & "-name", "Ch" & i.ToString)
        Next
        
        xL.ConfigItems.Define("temp-enabled", "1")
        xL.ConfigItems.Define("temp-name", "Temp")

        xL.Filters.Add(New XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "sensor", "request"))

        AddHandler xL.XplConfigDone, AddressOf xL_XplConfigDone
        AddHandler xL.XplReConfigDone, AddressOf xL_XplReConfigDone
        AddHandler xL.XplMessageReceived, AddressOf xL_XplMessageReceived

        xL.Listen()

    End Sub

    Private Sub xL_XplConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        readConfig()
        initSerial()
    End Sub

    Private Sub xL_XplReConfigDone(ByVal e As XplListener.XplLoadStateEventArgs)
        readConfig()
        initSerial()
    End Sub

    Private Sub xL_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs)

        ' Respond to requests for "current" from one of our devices
        If e.XplMsg.GetKeyValue("request").ToLower() = "current" Then

            Dim deviceRequested As String = e.XplMsg.GetKeyValue("device").ToLower()

            For i = 1 To 3
                If deviceRequested = sensorName(i) And sensorEnabled(i) Then
                    sendMessage(XplMsg.xPLMsgType.stat, sensorName(i), sensorValue(i), "power", "W")
                End If
            Next
            If deviceRequested = tmprName And tmprEnabled Then
                sendMessage(XplMsg.xPLMsgType.stat, tmprName, tmprValue, "temp", "c")
            End If

        End If

    End Sub

    Private Sub readConfig()

        comport = Int32.Parse(xL.ConfigItems("comport").Value)
        baud = Int32.Parse(xL.ConfigItems("baud").Value)

        If xL.ConfigItems("changed-only").Value = "0" Then
            changedOnly = False
        Else
            changedOnly = True
        End If

        For i = 1 To 3
            sensorName(i) = xL.ConfigItems("ch" & i.ToString & "-name").Value
            If xL.ConfigItems("ch" & i.ToString & "-enabled").Value = "0" Then
                sensorEnabled(i) = False
            Else
                sensorEnabled(i) = True
            End If
        Next

        If xL.ConfigItems("temp-enabled").Value = "0" Then
            tmprEnabled = False
        Else
            tmprEnabled = True
        End If
        tmprName = xL.ConfigItems("temp-name").Value

        EventLog.WriteEntry("Configuration read", EventLogEntryType.Information)

    End Sub

    Private Sub initSerial()

        If serialPort.IsOpen Then
            serialPort.Close()
        End If

        Try
            With serialPort
                .PortName = "COM" & comport
                .BaudRate = baud
                .Parity = IO.Ports.Parity.None
                .DataBits = 8
                .StopBits = IO.Ports.StopBits.One
            End With
            serialPort.Open()
            EventLog.WriteEntry("Opened serial port COM" & comport & " (" & baud & " baud)", EventLogEntryType.Information)
            first = True
        Catch ex As Exception
            EventLog.WriteEntry("Error opening serial port COM" & comport & Environment.NewLine & ex.Message, EventLogEntryType.Error)
        End Try

    End Sub

    Private Sub DataReceived(ByVal sender As Object, ByVal e As System.IO.Ports.SerialDataReceivedEventArgs) Handles serialPort.DataReceived

        ' Ignore the first packet we see, as we'll more than likely miss the first part of it
        If first Then
            first = False
        Else
            ' If we read immediately, we will not get the full packet, 
            ' so wait a bit for all the data to arrive
            System.Threading.Thread.Sleep(1500)

            Dim xml As String = serialPort.ReadExisting
            Dim unitType As Integer

            If InStr(xml, "<date>") > 0 Then
                unitType = Classic
            Else
                unitType = CC128
            End If

            If unitType = Classic Or (unitType = CC128 And InStr(xml, "<hist>") = 0 And InStr(xml, "<sensor>0</sensor>") > 0) Then

                Dim doc As XPathDocument
                Dim xmlNI As XPathNodeIterator
                Dim xmlNav As XPathNavigator
                Dim myStringReader = New StringReader(xml)

                Try
                    doc = New XPathDocument(myStringReader)
                    xmlNav = doc.CreateNavigator()
                    ' Channels 1 to 3 (may not all be present)
                    For i = 1 To 3
                        xmlNI = xmlNav.Select("/msg/ch" + i.ToString + "/watts")
                        If xmlNI.Count = 1 Then
                            xmlNI.MoveNext()
                            sensorValue(i) = xmlNI.Current.Value
                            If sensorEnabled(i) And (Not changedOnly Or sensorValue(i) <> sensorValueNew(i)) Then
                                sendMessage(XplMsg.xPLMsgType.trig, sensorName(i), sensorValueNew(i), "power", "W")
                            End If
                        End If
                    Next
                    ' Temperature
                    xmlNI = xmlNav.Select("/msg/tmpr")
                    If xmlNI.Count = 1 Then
                        xmlNI.MoveNext()
                        tmprValueNew = xmlNI.Current.Value
                    End If
                    If tmprEnabled And (Not changedOnly Or tmprValue <> tmprValueNew) Then
                        sendMessage(XplMsg.xPLMsgType.trig, tmprName, tmprValueNew, "temp", "c")
                    End If
                Catch ex As Exception
                    EventLog.WriteEntry("Error reading XML" & Environment.NewLine & ex.Message, EventLogEntryType.Error)
                End Try
            End If
        End If

        sensorValue = sensorValueNew
        tmprValue = tmprValueNew

    End Sub

    Private Sub sendMessage(ByVal msgType As XplMsg.xPLMsgType, ByVal device As String, _
                            ByVal value As String, ByVal type As String, ByVal units As String)
        Try
            Dim xM As xpllib.XplMsg = xL.GetPreparedXplMessage(msgType, True)
            xM.Class = "sensor"
            xM.Type = "basic"
            xM.AddKeyValuePair("device", device)
            xM.AddKeyValuePair("current", value)
            xM.AddKeyValuePair("type", type)
            xM.AddKeyValuePair("units", units)
            xM.Send()
        Catch ex As Exception
            EventLog.WriteEntry("Error sending xPL message" & Environment.NewLine & ex.Message, EventLogEntryType.Error)
        End Try

    End Sub

    Protected Overrides Sub OnStop()
        xL.Dispose()
    End Sub

End Class
