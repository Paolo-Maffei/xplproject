Option Strict Off
Option Explicit On

Imports System.IO.Ports

Public Class VFDDevice
    Private comms As New SerialPort
    Private commsActive As Boolean = False
    Private zonelbl As String = "zone1"
    Private exczone As String = ""

    Public Class VFD

        'Cursor Movement
        Public Const BackSpace = Chr(8)
        Public Const HorizontalTab = Chr(9)
        Public Const LineFeed = Chr(10)
        Public Const FormFeed = Chr(12)
        Public Const CarriageReturn = Chr(13)
        Public Const ClearPage = Chr(14)

        'Device Control
        Public Const ResetDevice = Chr(27) & Chr(73)

        'Display Modes
        Public Const OverWriteAtEndOfLine = Chr(17)
        Public Const ScrollUpAtEndOfLine = Chr(18)

        'Cursor Control Commands
        Public Const CursorUnderline = Chr(20)
        Public Const CursorBlinkDot = Chr(21)
        Public Const CursorNone = Chr(22)
        Public Const CursorBlinkUnderline = Chr(23)

        'Cursor Control Commands
        Public Const DimDisplay = Chr(27) & Chr(20) & Chr(76) & Chr(127)
        '        Public Const BrightDisplay = Chr(27) & Chr(20) & Chr(76) & Chr(254)

    End Class


    Public Class PortSettings
        Private mdmPortName As String = "COM1"
        Private mdmBaudRate As String = "19200"
        Private mdmParity As String = "Even"
        Private mdmDataBits As String = "8"
        Private mdmStopBits As String = "1"
        Private mdmHandshake As String = "None"

        Property PortName() As String
            Get
                PortName = mdmPortName
            End Get
            Set(ByVal value As String)
                mdmPortName = value
            End Set
        End Property

        Property BaudRate() As String
            Get
                BaudRate = mdmBaudRate
            End Get
            Set(ByVal value As String)
                mdmBaudRate = value
            End Set
        End Property

        Property Parity() As String
            Get
                Parity = mdmParity
            End Get
            Set(ByVal value As String)
                mdmParity = value
            End Set
        End Property

        Property DataBits() As String
            Get
                DataBits = mdmDataBits
            End Get
            Set(ByVal value As String)
                mdmDataBits = value
            End Set
        End Property
        Property StopBits() As String
            Get
                StopBits = mdmStopBits
            End Get
            Set(ByVal value As String)
                mdmStopBits = value
            End Set
        End Property

        Property Handshake() As String
            Get
                Handshake = mdmHandshake
            End Get
            Set(ByVal value As String)
                mdmHandshake = value
            End Set
        End Property


    End Class

    Property VFDPortConfig() As PortSettings
        Get
            VFDPortConfig = New PortSettings
            With VFDPortConfig
                .BaudRate = comms.BaudRate
                .Parity = comms.Parity.ToString
                .PortName = comms.PortName
                .DataBits = comms.DataBits
                .StopBits = comms.StopBits.ToString
                .Handshake = comms.Handshake.ToString
            End With
        End Get
        Set(ByVal value As PortSettings)
            With comms
                .BaudRate = value.BaudRate
                .Parity = CType([Enum].Parse(GetType(Parity), value.Parity), Parity)
                .PortName = value.PortName
                .DataBits = value.DataBits
                .StopBits = CType([Enum].Parse(GetType(StopBits), value.StopBits), StopBits)
                .Handshake = CType([Enum].Parse(GetType(Handshake), value.Handshake), Handshake)
            End With
        End Set
    End Property

    Property ZoneLabel() As String
        Get
            ZoneLabel = zonelbl
        End Get
        Set(ByVal value As String)
            zonelbl = value
        End Set
    End Property

    Property ExclusiveUser() As String
        Get
            ExclusiveUser = exczone
        End Get
        Set(ByVal value As String)
            exczone = value
        End Set
    End Property

    Public Function InitVFDDevice() As Boolean
        Try
            comms.NewLine = vbNewLine
            comms.DtrEnable = True
            comms.RtsEnable = True
            comms.WriteTimeout = 500
            comms.Open()
        Catch ex As Exception
            InitVFDDevice = False
            Exit Function
        End Try

        'Send universal VFD Hailing command... :)
        comms.Write(VFD.ResetDevice)
        comms.Write(VFD.ScrollUpAtEndOfLine)
        comms.Write(VFD.CursorNone)
        comms.Write("xPL VFD Display Service" & VFD.LineFeed & VFD.CarriageReturn)
        comms.Write("v" & My.Application.Info.Version.ToString)
        InitVFDDevice = True
    End Function

    Public Sub ClearDevice()
        comms.Write(VFD.ClearPage)
    End Sub

    Public Sub WriteMessage(ByVal strMessage As String)
        comms.Write(strMessage)
    End Sub
End Class
