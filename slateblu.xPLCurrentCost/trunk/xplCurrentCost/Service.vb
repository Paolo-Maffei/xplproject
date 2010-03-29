Imports System.Xml
Imports System.IO
Imports xpllib

Public Class xplCurrentCost

    Dim comport As Int32
    Dim baud As Int32
    Dim changedOnly As Boolean

    Dim ch1Enabled As Boolean
    Dim ch1Name As String
    Dim ch1Value As String
    Dim ch1ValueNew As String

    Dim ch2Enabled As Boolean
    Dim ch2Name As String
    Dim ch2Value As String
    Dim ch2ValueNew As String

    Dim ch3Enabled As Boolean
    Dim ch3Name As String
    Dim ch3Value As String
    Dim ch3ValueNew As String

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

        xL.ConfigItems.Define("ch1-enabled", "1")
        xL.ConfigItems.Define("ch1-name", "Ch1")

        xL.ConfigItems.Define("ch2-enabled", "0")
        xL.ConfigItems.Define("ch2-name", "Ch2")

        xL.ConfigItems.Define("ch3-enabled", "0")
        xL.ConfigItems.Define("ch3-name", "Ch3")

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

            Select Case e.XplMsg.GetKeyValue("device").ToLower()
                Case ch1Name
                    If deviceRequested = ch1Name And ch1Enabled Then
                        sendMessage(XplMsg.xPLMsgType.stat, ch1Name, ch1Value, "power", "W")
                    ElseIf deviceRequested = ch2Name And ch2Enabled Then
                        sendMessage(XplMsg.xPLMsgType.stat, ch2Name, ch2Value, "power", "W")
                    ElseIf deviceRequested = ch3Name And ch3Enabled Then
                        sendMessage(XplMsg.xPLMsgType.stat, ch3Name, ch3Value, "power", "W")
                    ElseIf deviceRequested = tmprName And tmprEnabled Then
                        sendMessage(XplMsg.xPLMsgType.stat, tmprName, tmprValue, "temp", "c")
                    End If
            End Select

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

        If xL.ConfigItems("ch1-enabled").Value = "0" Then
            ch1Enabled = False
        Else
            ch1Enabled = True
        End If

        If xL.ConfigItems("ch2-enabled").Value = "0" Then
            ch2Enabled = False
        Else
            ch2Enabled = True
        End If

        If xL.ConfigItems("ch3-enabled").Value = "0" Then
            ch3Enabled = False
        Else
            ch3Enabled = True
        End If

        If xL.ConfigItems("temp-enabled").Value = "0" Then
            tmprEnabled = False
        Else
            tmprEnabled = True
        End If

        ch1Name = xL.ConfigItems("ch1-name").Value
        ch2Name = xL.ConfigItems("ch2-name").Value
        ch3Name = xL.ConfigItems("ch3-name").Value
        tmprName = xL.ConfigItems("temp-name").Value

    End Sub

    Private Sub initSerial()

        If serialPort.IsOpen Then
            serialPort.Close()
        End If

        Try
            With serialPort
                .PortName = "COM" & comport ' Server=COM5, Tim=COM4
                .BaudRate = baud
                .Parity = IO.Ports.Parity.None
                .DataBits = 8
                .StopBits = IO.Ports.StopBits.One
            End With
            serialPort.Open()
            EventLog.WriteEntry("Opened serial port COM" & comport, EventLogEntryType.Information)
            first = True
        Catch ex As Exception
            EventLog.WriteEntry("Error opening serial port" & Environment.NewLine & ex.Message, EventLogEntryType.Error)
        End Try

    End Sub

    Private Sub readSerial()

        ' If we read immediately, we will not get the full packet, so wait a while 
        System.Threading.Thread.Sleep(1500)
        Dim xml As String = serialPort.ReadExisting

        Dim myStringReader = New StringReader(xml)
        Dim reader = New XmlTextReader(myStringReader)
        reader.WhitespaceHandling = WhitespaceHandling.None

        reader.Read()   'msg

        reader.Read()   'date
        reader.Read()   'dsb
        Dim strDsb = reader.ReadElementString("dsb")
        Dim strHr = reader.ReadElementString("hr")
        Dim strMin = reader.ReadElementString("min")
        Dim strSec = reader.ReadElementString("sec")

        reader.Read()   'src
        reader.Read()   'name
        Dim strName = reader.ReadElementString("name")
        Dim strId = reader.ReadElementString("id")
        Dim strType = reader.ReadElementString("type")
        Dim strSver = reader.ReadElementString("sver")

        reader.Read()   'ch1
        reader.Read()   'watts
        ch1ValueNew = reader.ReadElementString("watts")

        reader.Read()   'ch2
        reader.Read()   'watts
        ch2ValueNew = reader.ReadElementString("watts")

        reader.Read()   'ch3
        reader.Read()   'watts
        ch3ValueNew = reader.ReadElementString("watts")

        reader.Read()   'tmpr
        tmprValueNew = reader.ReadElementString("tmpr")

        reader.Close()

    End Sub

    Private Sub DataReceived(ByVal sender As Object, ByVal e As System.IO.Ports.SerialDataReceivedEventArgs) Handles serialPort.DataReceived

        ' Ignore the first packet, as we'll more than likely miss the first part of it
        If first Then
            first = False
        Else
            readSerial()
        End If

        If ch1Enabled And (Not changedOnly Or ch1Value <> ch1ValueNew) And ch1Value <> "" Then
            sendMessage(XplMsg.xPLMsgType.trig, ch1Name, ch1ValueNew, "power", "W")
        End If

        If ch2Enabled And (Not changedOnly Or ch2Value <> ch2ValueNew) And ch2Value <> "" Then
            sendMessage(XplMsg.xPLMsgType.trig, ch2Name, ch2ValueNew, "power", "W")
        End If

        If ch3Enabled And (Not changedOnly Or ch3Value <> ch3ValueNew) And ch3Value <> "" Then
            sendMessage(XplMsg.xPLMsgType.trig, ch3Name, ch3ValueNew, "power", "W")
        End If

        If tmprEnabled And (Not changedOnly Or tmprValue <> tmprValueNew) And tmprValue <> "" Then
            sendMessage(XplMsg.xPLMsgType.trig, tmprName, tmprValueNew, "temp", "c")
        End If

        ch1Value = ch1ValueNew
        ch2Value = ch2ValueNew
        ch2Value = ch3ValueNew
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
