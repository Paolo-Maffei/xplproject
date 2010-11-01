'* xPL Comfort UCM Gateway Service
'*
'* Copyright (C) 2003 Ian Lowe
'* http://www.xplproject.org.uk
'*
'* Based upon prior work Copyright (C) 2003 John Bent
'* http://www.xpl.myby.co.uk
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
'*
Option Strict On

Imports System.IO
Imports JH.CommBase

Public Class clsUCM
    Inherits CommBase

    Private StatusReqHC As Integer, StatusReqDC As Integer

    Public Event X10Event(ByVal sender As Object, ByVal devices As String, ByVal housecode As String, ByVal functionCode As Integer, ByVal extra As Integer, ByVal data2 As Integer)

    Private Shared Sub LogEvent(ByVal s As String)
        Exit Sub
        Try
            Dim fs As TextWriter = File.AppendText("c:\log.txt")
            fs.WriteLine(s)
            fs.Close()
        Catch ex As Exception
        End Try
    End Sub

    Private Const ADDR As Byte = 4
    Private Const FUNC As Byte = 6
    Private Const EXTENDED_FUNC As Byte = 7
    Const X10_ALL_UNITS_OFF As Integer = 0
    Const X10_ALL_LIGHTS_ON As Integer = 1
    Const X10_ON As Integer = 2
    Const X10_OFF As Integer = 3
    Const X10_DIM As Integer = 4
    Const X10_BRIGHT As Integer = 5
    Const X10_ALL_LIGHTS_OFF As Integer = 6
    Const X10_EXTENDED As Integer = 7
    Const X10_HAIL_REQ As Integer = 8
    Const X10_HAIL_ACK As Integer = 9
    Const X10_STATUS_ON As Integer = 13
    Const X10_STATUS_OFF As Integer = 14
    Const X10_STATUS_REQUEST As Integer = 15

    Const X10_A1 As Byte = 6
    Const X10_B2 As Byte = 14
    Const X10_C3 As Byte = 2
    Const X10_D4 As Byte = 10
    Const X10_E5 As Byte = 1
    Const X10_F6 As Byte = 9
    Const X10_G7 As Byte = 5
    Const X10_H8 As Byte = 13
    Const X10_I9 As Byte = 7
    Const X10_J10 As Byte = 15
    Const X10_K11 As Byte = 3
    Const X10_L12 As Byte = 11
    Const X10_M13 As Byte = 0
    Const X10_N14 As Byte = 8
    Const X10_O15 As Byte = 4
    Const X10_P16 As Byte = 12

    Private Const INIT_OK As Integer = 0
    Private Const INIT_NO_CM_FOUND As Integer = 1
    Private Const COM_PORT_ERROR As Integer = 2

    Private Enum RxModes
        Normal
        AwaitingChecksum
        AwaitingCTS
        AwaitingData
    End Enum

    Private RxMode As RxModes
    Private tempHouse, tempunit, tempfunc, templevel As Integer
    Private InputBuffer(255) As Byte
    Private Checksum As Byte
    Private RxCount, RxTotal As Integer
    Public comPort As String
    Public SendRetryCount As Integer
    Protected Overrides Function CommSettings() As CommBaseSettings
        Dim cs As New CommBaseSettings
        cs.SetStandard(comPort, 4800, CommBase.Handshake.none)
        Return cs
    End Function

    Public Function Init() As Integer
        If Not MyBase.Open() Then
            Return COM_PORT_ERROR
        Else
            RxMode = RxModes.Normal
            Return INIT_OK
        End If
    End Function

    Protected Overrides Sub Finalize()
        MyBase.Close()
        MyBase.Finalize()
    End Sub

    Public Sub Cleanup()
        MyBase.Close()
    End Sub

    Public Sub Exec(ByVal HouseCode As String, ByVal DeviceCode As String, ByVal FunctionCode As Integer, ByVal Brightness As Integer, ByVal data1 As Integer, ByVal data2 As Integer)
        Dim n, checksumX10 As Byte
        Dim TImeout As Integer = 0
        If Not DeviceCode = "" And Not FunctionCode = X10_EXTENDED Then
            ' Send the address
            LogEvent("Sending address...")
            SendAddress(strToX10(HouseCode), strToX10(DeviceCode))
        End If

        ' Send the function code
        n = (strToX10(HouseCode) * CByte(&H10)) Or CByte(FunctionCode)

        If FunctionCode = X10_STATUS_REQUEST Then
            StatusReqDC = strToX10(DeviceCode)
        End If
        If FunctionCode = X10_EXTENDED Then
            checksumX10 = (EXTENDED_FUNC + n + strToX10(DeviceCode) + CByte(data1) + CByte(data2)) And CByte(&HFF) ' checksum            
            Send(EXTENDED_FUNC)
            Send(n)
            Send(strToX10(DeviceCode))
            Send(CByte(data1))
            Send(CByte(data2))
        Else
            If FunctionCode = X10_DIM Or FunctionCode = X10_BRIGHT Then
                Brightness = CInt(CDbl(Brightness) * 0.22) * 8
                checksumX10 = (CByte(Brightness Or FUNC) + n) And CByte(&HFF) ' checksum
                Send(CByte(Brightness Or FUNC))
            Else
                checksumX10 = (FUNC + n) And CByte(&HFF) ' checksum
                Send(FUNC)
            End If
            Send(n)
        End If

        RxMode = RxModes.AwaitingChecksum
        LogEvent("Waiting for checksum (should be " & checksumX10.ToString & ")")
        While RxMode = RxModes.AwaitingChecksum And TImeout < 20
            Thread.CurrentThread.Sleep(50)
            TImeout += 1
        End While
        If TImeout = 20 Then
            Throw New Exception("Timeout waiting for checksum.")
            'ElseIf Checksum <> checksumX10 Then
            'Throw New Exception("Invalid X10 checksum.")
        Else
            ' Send an OK to transmit
            LogEvent("OK to transmit.")
            sendimmediate(0)
            RxMode = RxModes.AwaitingCTS
            LogEvent("Waiting for CTS.")
            While RxMode = RxModes.AwaitingCTS
                Thread.CurrentThread.Sleep(50)
            End While
        End If
        LogEvent("Send operation complete.")
    End Sub

    Private Sub SendAddress(ByVal houseCode As Byte, ByVal UnitCode As Byte)
        Dim n As Byte
        Dim checksumX10 As Byte

        n = (houseCode * CByte(&H10)) Or UnitCode
        checksumX10 = (ADDR + n) And CByte(&HFF) ' checksum
        Send(ADDR)
        Send(n)
        RxMode = RxModes.AwaitingChecksum
        While RxMode = RxModes.AwaitingChecksum
            Thread.CurrentThread.Sleep(50)
        End While
        If Checksum <> checksumX10 Then
            Throw New Exception("Invalid X10 checksum.")
        Else
            ' Send an OK to transmit
            Send(0)
            RxMode = RxModes.AwaitingCTS
            While RxMode = RxModes.AwaitingCTS
                Thread.CurrentThread.Sleep(50)
            End While
        End If
    End Sub

    Private Function strToX10(ByVal s As String) As Byte
        Select Case s.ToUpper
            Case "A", "1"
                Return (X10_A1)
            Case "b", "2"
                Return (X10_B2)
            Case "C", "3"
                Return (X10_C3)
            Case "D", "4"
                Return (X10_D4)
            Case "E", "5"
                Return (X10_E5)
            Case "F", "6"
                Return (X10_F6)
            Case "G", "7"
                Return (X10_G7)
            Case "H", "8"
                Return (X10_H8)
            Case "I", "9"
                Return (X10_I9)
            Case "J", "10"
                Return (X10_J10)
            Case "K", "11"
                Return (X10_K11)
            Case "L", "12"
                Return (X10_L12)
            Case "M", "13"
                Return (X10_M13)
            Case "N", "14"
                Return (X10_N14)
            Case "O", "15"
                Return (X10_O15)
            Case "P", "16"
                Return (X10_P16)
        End Select
    End Function

    Protected Overrides Sub OnRxChar(ByVal c As Byte)
        ' The behaviour of this method depends in which state the application is currently in.
        LogEvent("rawdata: " & c.ToString())
        Select Case RxMode
            Case RxModes.AwaitingChecksum
                Checksum = c
                RxMode = RxModes.Normal
            Case RxModes.AwaitingCTS
                RxMode = RxModes.Normal
            Case RxModes.AwaitingData
                If c = CByte(&H5A) And RxCount = 0 Then
                    Send(&HC3)
                Else
                    InputBuffer(RxCount) = c
                    LogEvent("rxCount=" & RxCount)
                    LogEvent("data=" & c.ToString())
                    If RxCount = 0 Then
                        RxTotal = CInt(c)
                    End If
                    RxCount += 1
                    If RxTotal <> 0 And RxCount > (RxTotal) Then
                        RxMode = RxModes.Normal
                        AnalyseBuffer()
                    End If
                End If
            Case Else
                Select Case c
                    Case CByte(&H5A)
                        ' Interface ready to send data                        
                        RxCount = 0
                        RxMode = RxModes.AwaitingData
                        LogEvent("Ready to receive data...")
                        Send(CByte(&HC3))
                    Case CByte(&HA5)
                        ' Set clock
                        sendimmediate(CByte(&H9B))
                End Select
        End Select
    End Sub

    Private Sub AnalyseBuffer()
        ' Analyses the complete contents of the incoming data buffer
        LogEvent("analysing the buffer")
        Dim pos As Integer = 2 ' Our starting position in the buffer
        Dim maxlen As Integer = CInt(InputBuffer(0)) ' The number of bytes in the buffer
        Dim mask As Byte, funcAddrMask As Byte = InputBuffer(1)

        While pos <= maxlen
            Select Case pos
                Case 2
                    mask = 1
                Case 3
                    mask = 2
                Case 4
                    mask = 4
                Case 5
                    mask = 8
                Case 6
                    mask = 16
                Case 7
                    mask = 32
                Case 8
                    mask = 64
                Case 9
                    mask = 128
            End Select
            If (funcAddrMask And mask) = 0 Then
                ' Decode address
                tempHouse = (CInt(InputBuffer(pos)) And 240) \ 16
                tempunit = (CInt(InputBuffer(pos)) And 15)
            Else
                ' Decode function
                tempfunc = (CInt(InputBuffer(pos)) And 15)
                Select Case tempfunc
                    Case X10_ALL_LIGHTS_ON, X10_ALL_LIGHTS_OFF, X10_ALL_UNITS_OFF, X10_STATUS_ON, X10_STATUS_OFF
                        tempHouse = (CInt(InputBuffer(pos)) And 240) \ 16
                        tempunit = StatusReqDC
                        PrepareEvent()
                    Case X10_DIM, X10_BRIGHT
                        tempHouse = (CInt(InputBuffer(pos)) And 240) \ 16
                        pos += 1
                        templevel = CInt(InputBuffer(pos))
                        PrepareEvent()
                    Case Else
                        If Not tempHouse = -1 Then
                            PrepareEvent()
                        End If
                End Select
            End If

            pos += 1
        End While
    End Sub

    Private Function X10toHC(ByVal hc As Integer) As String
        Select Case hc
            Case X10_A1
                Return "A"
            Case X10_B2
                Return "B"
            Case X10_C3
                Return "C"
            Case X10_D4
                Return "D"
            Case X10_E5
                Return "E"
            Case X10_F6
                Return "F"
            Case X10_G7
                Return "G"
            Case X10_H8
                Return "H"
            Case X10_I9
                Return "I"
            Case X10_J10
                Return "J"
            Case X10_K11
                Return "K"
            Case X10_L12
                Return "L"
            Case X10_M13
                Return "M"
            Case X10_N14
                Return "N"
            Case X10_O15
                Return "N"
            Case X10_P16
                Return "P"
            Case Else
                Return "?"
        End Select
    End Function

    Private Sub PrepareEvent()
        Select Case tempfunc
            Case X10_ON, X10_OFF, X10_STATUS_ON, X10_STATUS_OFF
                RaiseEvent X10Event(Me, X10toHC(tempHouse) & X10toDC(tempunit), X10toHC(tempHouse), tempfunc, 0, 0)
            Case X10_DIM, X10_BRIGHT
                RaiseEvent X10Event(Me, "", X10toHC(tempHouse), tempfunc, templevel, 0)
            Case X10_ALL_LIGHTS_ON, X10_ALL_UNITS_OFF, X10_ALL_LIGHTS_OFF
                RaiseEvent X10Event(Me, "", X10toHC(tempHouse), tempfunc, 0, 0)
        End Select
        tempHouse = -1
        tempunit = -1
        tempfunc = -1
    End Sub

    Private Function X10toDC(ByVal hc As Integer) As String
        Select Case hc
            Case X10_A1
                Return "1"
            Case X10_B2
                Return "2"
            Case X10_C3
                Return "3"
            Case X10_D4
                Return "4"
            Case X10_E5
                Return "5"
            Case X10_F6
                Return "6"
            Case X10_G7
                Return "7"
            Case X10_H8
                Return "8"
            Case X10_I9
                Return "9"
            Case X10_J10
                Return "10"
            Case X10_K11
                Return "11"
            Case X10_L12
                Return "12"
            Case X10_M13
                Return "13"
            Case X10_N14
                Return "14"
            Case X10_O15
                Return "15"
            Case X10_P16
                Return "16"
            Case Else
                Return "?"
        End Select
    End Function

End Class

