'**************************************
'* xPL xPLHal 
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
Public Class X10

    ' routine to delete an x10 device
    Public Sub DeleteDevice(ByVal strDevice As Object)
        Dim x, y As Integer
        strDevice = Trim(UCase(strDevice))
        x = Asc(Left(strDevice, 1)) - 64
        y = Mid(strDevice, 2)
        X10Cache(x, y).DeviceType = X10_NONE
    End Sub

    ' routine to send an x10 xPL message
    Sub Send(ByVal strDevice As Object, ByVal strCommand As String, ByVal strLevel As Object)
        Dim strMsg As String
        strMsg = "command=" & strCommand & Chr(10)
        Select Case UCase(strCommand)
            Case "ALL_UNITS_OFF", "ALL_LIGHTS_ON", "ALL_LIGHTS_OFF"
                strMsg = "house=" & UCase(Left(Trim(strDevice), 1)) & Chr(10)
            Case "ON", "OFF", "STATUS", "SELECT", "STATUS", "HAIL_REQ", "PREDIM1", "PREDIM2"
                strMsg = strMsg & "device=" & UCase(Left(Trim(strDevice), 3)) & Chr(10)
            Case "DIM", "BRIGHT"
                strDevice = UCase(Trim(strDevice))
                If Len(strDevice) > 1 Then
                    strMsg = strMsg & "device=" & Left(strDevice, 3) & Chr(10)
                    strMsg = strMsg & "level=" & strLevel & Chr(10)
                Else
                    strMsg = strMsg & "house=" & Left(strDevice, 1) & Chr(10)
                    strMsg = strMsg & "level=" & strLevel & Chr(10)
                End If
            Case Else
                Exit Sub ' not supported
        End Select
        Call xPLSendMsg("XPL-CMND", "", "X10.BASIC", strMsg)
    End Sub

    ' routine to send extended
    Sub SendExt(ByVal strDevice As Object, ByVal Data1 As Object, ByVal Data2 As Object)
        Dim strMsg As String
        strMsg = "command=EXTENDED" & Chr(10)
        strMsg = strMsg & "device=" & UCase(Left(Trim(strDevice), 3)) & Chr(10)
        strMsg = strMsg & "data1=" & Data1 & Chr(10)
        strMsg = strMsg & "data2=" & Data2 & Chr(10)
        Call xPLSendMsg("XPL-CMND", "", "X10.BASIC", strMsg)
    End Sub

    ' routine to load a device
    Public Sub LoadDevice(ByVal strDevice As Object, ByVal DeviceType As Object, ByVal IsLight As Object, ByVal ResumeDim As Object, ByVal DimType As Object, ByVal TracksDimLevel As Object, ByVal strLabel As Object, ByVal Timeout As Object, ByVal State As Integer, ByVal Location As Object, ByVal OnImage As Object, ByVal OffImage As Object, ByVal Overwrite As Object)
        Dim x, y As Integer
        strDevice = Trim(UCase(strDevice))
        x = Asc(Left(strDevice, 1)) - 64
        y = Mid(strDevice, 2)
        If X10Cache(x, y).DeviceType <> X10_NONE And Overwrite = False Then Exit Sub
        X10Cache(x, y).Device = strDevice
        X10Cache(x, y).House = Left(strDevice, 1)
        Select Case State
            Case X10_ON, X10_OFF
                X10Cache(x, y).State = State
            Case Else
                X10Cache(x, y).State = X10_UNKNOWN
        End Select
        X10Cache(x, y).Level = 0
        If State = X10_ON Then X10Cache(x, y).Level = 100 ' temporary
        X10Cache(x, y).Selected = False
        X10Cache(x, y).DeviceType = DeviceType
        X10Cache(x, y).IsLight = IsLight
        X10Cache(x, y).ResumeDim = ResumeDim
        X10Cache(x, y).DimType = DimType
        X10Cache(x, y).TracksDimLevel = TracksDimLevel
        X10Cache(x, y).Label = strLabel
        If Timeout < 0 Then Timeout = 0
        If DeviceType <> X10_MOTION Then Timeout = 0
        X10Cache(x, y).Timeout = Timeout
        X10Cache(x, y).Expires = DateAdd(DateInterval.Minute, Timeout, Now)
        X10Cache(x, y).Change = Now
        If DeviceType = X10_MOTION Then
            Select Case State
                Case X10_ON
                    X10Cache(x, y).Active = True
                Case X10_OFF
                    X10Cache(x, y).Active = False
            End Select
        End If
        X10Cache(x, y).Location = Location
        X10Cache(x, y).OnImage = OnImage
        X10Cache(x, y).OffImage = OffImage
    End Sub

    ' routine to get/set x10 attribute
    Public Property Attrib(ByVal strDevice As Object, ByVal intAttrib As Integer) As Object
        Get
            Dim x, y As Integer
            Dim x10Level As Object
            Try
                strDevice = Trim(UCase(strDevice))
                x = Asc(Left(strDevice, 1)) - 64
                y = Mid(strDevice, 2)
                Select Case intAttrib
                    Case X10_STATE
                        Return X10Cache(x, y).State
                    Case X10_LEVEL
                        x10Level = 0
                        x10Level = Int(X10Cache(x, y).Level / (100 / X10Cache(x, y).DimType))
                        If x10Level < 0 Then x10Level = 0
                        If x10Level > X10Cache(x, y).DimType Then x10Level = X10Cache(x, y).DimType
                        Return x10Level
                    Case X10_SELECTED
                        Return X10Cache(x, y).Selected
                    Case X10_DEVICE_TYPE
                        Return X10Cache(x, y).DeviceType
                    Case X10_IS_LIGHT
                        Return X10Cache(x, y).IsLight
                    Case X10_RESUME_DIM
                        Return X10Cache(x, y).ResumeDim
                    Case X10_DIM_TYPE
                        Return X10Cache(x, y).DimType
                    Case X10_TRACKS_DIM_LEVEL
                        Return X10Cache(x, y).TracksDimLevel
                    Case X10_LABEL
                        Return X10Cache(x, y).Label
                    Case X10_TIMEOUT
                        Return X10Cache(x, y).Timeout
                    Case X10_CHANGE
                        Return X10Cache(x, y).Change
                    Case X10_LOCATION
                        Return X10Cache(x, y).Location
                    Case X10_ON_IMAGE
                        Return X10Cache(x, y).OnImage
                    Case X10_OFF_IMAGE
                        Return X10Cache(x, y).OffImage
                End Select
                Return Nothing
            Catch ex As Exception
                Return Nothing
            End Try
        End Get
        Set(ByVal Value As Object)
            Dim x, y As Integer
            'Dim x10Level As Object
            Try
                strDevice = Trim(UCase(strDevice))
                x = Asc(Left(strDevice, 1)) - 64
                y = Mid(strDevice, 2)
                If X10Cache(x, y).DeviceType = X10_NONE Then Exit Property
                Select Case intAttrib
                    Case X10_STATE
                        X10Cache(x, y).State = Value
                        If Value = X10_ON Then
                            X10Cache(x, y).Expires = DateAdd(DateInterval.Minute, X10Cache(x, y).Timeout, Now)
                        End If
                        X10Cache(x, y).Change = Now
                    Case X10_LEVEL
                        X10Cache(x, y).Level = Int(X10Cache(x, y).Level + (Value * (100 / X10Cache(x, y).DimType)))
                        If X10Cache(x, y).Level < 0 Then X10Cache(x, y).Level = 0
                        If X10Cache(x, y).Level > 100 Then X10Cache(x, y).Level = 100
                    Case X10_SELECTED
                        X10Cache(x, y).Selected = Value
                    Case X10_DEVICE_TYPE
                        X10Cache(x, y).DeviceType = Value
                    Case X10_IS_LIGHT
                        X10Cache(x, y).IsLight = Value
                    Case X10_RESUME_DIM
                        X10Cache(x, y).ResumeDim = Value
                    Case X10_DIM_TYPE
                        X10Cache(x, y).DimType = Value
                    Case X10_TRACKS_DIM_LEVEL
                        X10Cache(x, y).TracksDimLevel = Value
                    Case X10_LABEL
                        X10Cache(x, y).Label = Value
                    Case X10_TIMEOUT
                        X10Cache(x, y).Timeout = Value
                        If X10Cache(x, y).Timeout < 0 Then X10Cache(x, y).Timeout = 0
                    Case X10_CHANGE
                        X10Cache(x, y).Change = Value
                    Case X10_LOCATION
                        X10Cache(x, y).Location = Value
                    Case X10_ON_IMAGE
                        X10Cache(x, y).OnImage = Value
                    Case X10_OFF_IMAGE
                        X10Cache(x, y).OffImage = Value
                End Select
            Catch ex As Exception
            End Try
        End Set
    End Property

    ' routine to reset x10 cache
    Public Sub Init()
        Dim x, y As Integer
        For x = 1 To 26
            For y = 1 To 16
                X10Cache(x, y).DeviceType = X10_NONE
            Next
        Next
    End Sub

    ' routine to save the cache
    Public Sub Save()
        Call SaveX10Cache()
    End Sub

End Class
