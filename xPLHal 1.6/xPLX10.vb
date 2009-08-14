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
Module xPLX10

    ' x10 attributes
    Public Const X10_STATE As Integer = 0
    Public Const X10_LEVEL As Integer = 1
    Public Const X10_SELECTED As Integer = 2
    Public Const X10_DEVICE_TYPE As Integer = 3
    Public Const X10_IS_LIGHT As Integer = 4
    Public Const X10_RESUME_DIM As Integer = 5
    Public Const X10_DIM_TYPE As Integer = 6
    Public Const X10_TRACKS_DIM_LEVEL As Integer = 7
    Public Const X10_LABEL As Integer = 8
    Public Const X10_TIMEOUT As Integer = 9
    Public Const X10_CHANGE As Integer = 10
    Public Const X10_LOCATION As Integer = 11
    Public Const X10_ON_IMAGE As Integer = 12
    Public Const X10_OFF_IMAGE As Integer = 13

    ' x10 commands / states
    Public Const X10_UNKNOWN As Integer = -2 ' state unknown
    Public Const X10_SELECT As Integer = -1
    Public Const X10_ALL_UNITS_OFF As Integer = 0
    Public Const X10_ALL_LIGHTS_ON As Integer = 1
    Public Const X10_ON As Integer = 2 ' also state on
    Public Const X10_OFF As Integer = 3 ' also state off
    Public Const X10_DIM As Integer = 4
    Public Const X10_BRIGHT As Integer = 5
    Public Const X10_ALL_LIGHTS_OFF As Integer = 6
    Public Const X10_EXTENDED_CODE As Integer = 7
    Public Const X10_HAIL_REQUEST As Integer = 8
    Public Const X10_HAIL_ACK As Integer = 9
    Public Const X10_PRESET_DIM_1 As Integer = 10
    Public Const X10_PRESET_DIM_2 As Integer = 11
    Public Const X10_X_DATA_XFER As Integer = 12
    Public Const X10_STATUS_ON As Integer = 13
    Public Const X10_STATUS_OFF As Integer = 14
    Public Const X10_STATUS_REQUEST As Integer = 15

    ' x10 device types
    Public Const X10_NONE As Integer = -1 ' no device
    Public Const X10_LAMP As Integer = 0
    Public Const X10_APPLIANCE As Integer = 1
    Public Const X10_DIMMER As Integer = 2
    Public Const X10_SENSOR As Integer = 3
    Public Const X10_ACTUATOR As Integer = 4
    Public Const X10_MOTION As Integer = 5
    Public Const X10_SPECIAL As Integer = 6

    ' x10 dim types
    Public Const X10_X10 As Integer = 16
    Public Const X10_PCS As Integer = 32
    Public Const X10_LEVITON As Integer = 63

    ' x10 cache structure
    <Serializable()> Public Structure X10CacheStruc
        Public Device As String
        Public House As String
        Public State As Short
        Public Level As Short
        Public Selected As Boolean
        Public DeviceType As Short
        Public IsLight As Boolean
        Public ResumeDim As Boolean
        Public DimType As Short
        Public TracksDimLevel As Boolean
        Public Label As String
        Public Change As Date
        Public Timeout As Short
        Public Expires As Date
        Public Active As Boolean
        Public Location As Short
        Public OnImage As String
        Public OffImage As String
    End Structure

    Public X10Cache(26, 16) As X10CacheStruc

    ' routine to load xml device states
    Public Sub LoadX10Cache()

        Dim x, y As Integer
        For x = 1 To 26
            For y = 1 To 16
                X10Cache(x, y).DeviceType = X10_NONE
            Next
        Next
        If Dir(xPLHalData & "\xplhal_x10cache.xml") <> "" Then
            ' got xml devices so load
            Try
                Dim xml As New Xml.XmlTextReader(xPLHalData & "\xplhal_x10cache.xml")
                While xml.Read()
                    Select Case xml.NodeType
                        Case XmlNodeType.Element
                            Select Case xml.Name
                                Case "x10"
                                    x = Asc(Left(xml.GetAttribute("house"), 1)) - 64
                                    y = Mid(xml.GetAttribute("device"), 2)
                                    X10Cache(x, y).House = xml.GetAttribute("house")
                                    X10Cache(x, y).Device = xml.GetAttribute("device")
                                    X10Cache(x, y).Label = xml.GetAttribute("label")
                                    X10Cache(x, y).Level = xml.GetAttribute("level")
                                    X10Cache(x, y).Active = xml.GetAttribute("active")
                                    X10Cache(x, y).State = xml.GetAttribute("state")
                                    X10Cache(x, y).Location = xml.GetAttribute("location")
                                    X10Cache(x, y).Change = xml.GetAttribute("change")
                                    X10Cache(x, y).Expires = xml.GetAttribute("expires")
                                    X10Cache(x, y).Timeout = xml.GetAttribute("timeout")
                                    X10Cache(x, y).DeviceType = xml.GetAttribute("devicetype")
                                    X10Cache(x, y).IsLight = xml.GetAttribute("islight")
                                    X10Cache(x, y).DimType = xml.GetAttribute("dimtype")
                                    X10Cache(x, y).TracksDimLevel = xml.GetAttribute("tracksdimlevel")
                                    X10Cache(x, y).ResumeDim = xml.GetAttribute("resumedim")
                                    X10Cache(x, y).Selected = xml.GetAttribute("selected")
                                    X10Cache(x, y).OffImage = xml.GetAttribute("offimage")
                                    X10Cache(x, y).OnImage = xml.GetAttribute("onimage")
                            End Select
                    End Select
                End While
                xml.Close()
            Catch ex As Exception
                Call WriteErrorLog("Error Reading X10 Cache XML (" & Err.Description & ")")
                Exit Sub
            End Try
        Else
            ' no xml devices, so load bin if it exists and save as xml
            If Dir(xPLHalData & "\xplhal_x10cache.bin") <> "" Then
                Call LoadX10CacheBin()
                Call SaveX10Cache()
            End If
        End If

    End Sub

    ' routine to load old binary x10 state
    Public Sub LoadX10CacheBin()

        Dim wrkx10Cache As New Hashtable
        Dim BinFormatter As New Binary.BinaryFormatter
        Dim FS As FileStream
        Dim x, y As Integer
        Dim z As String
        Call X10Class.Init()
        Try
            FS = New FileStream(xPLHalData + "\xplhal_x10cache.bin", FileMode.Open)
            wrkx10Cache = CType(BinFormatter.Deserialize(FS), Hashtable)
            FS.Close()
        Catch ex As Exception
            Exit Sub
        End Try
        For x = 1 To 26
            For y = 1 To 16
                X10Cache(x, y).Device = X10_NONE
            Next
        Next
        For Each z In wrkx10Cache.Keys
            x = Asc(Left(z, 1)) - 64
            y = Mid(z, 2)
            X10Cache(x, y) = wrkx10Cache(z)
        Next
        Rename(xPLHalData & "\xplhal_x10cache.bin", xPLHalData & "\xplhal_x10cache.bin.old")
        wrkx10Cache.Clear()
        wrkx10Cache = Nothing
    End Sub

    ' routine to save x10 state
    Public Sub SaveX10Cache()
        Dim xml As New Xml.XmlTextWriter(xPLHalData + "\xplhal_x10cache.xml", System.Text.Encoding.ASCII)
    Dim x, y As Integer
        xml.Formatting = Formatting.Indented
        xml.WriteStartDocument()
        xml.WriteStartElement("x10cache")
        For x = 1 To 26
            For y = 1 To 16
                If X10Cache(x, y).DeviceType <> X10_NONE Then
                    '      Debug.WriteLine(X10Cache(x, y).DeviceType)
                    Try
                        xml.WriteStartElement("x10")
                        xml.WriteAttributeString("house", X10Cache(x, y).House.ToUpper)
                        xml.WriteAttributeString("device", X10Cache(x, y).Device.ToUpper)
                        xml.WriteAttributeString("label", X10Cache(x, y).Label)
                        xml.WriteAttributeString("level", X10Cache(x, y).Level)
                        xml.WriteAttributeString("active", X10Cache(x, y).Active)
                        xml.WriteAttributeString("state", X10Cache(x, y).State)
                        xml.WriteAttributeString("location", X10Cache(x, y).Location)
                        xml.WriteAttributeString("change", X10Cache(x, y).Change)
                        xml.WriteAttributeString("expires", X10Cache(x, y).Expires)
                        xml.WriteAttributeString("timeout", X10Cache(x, y).Timeout)
                        xml.WriteAttributeString("devicetype", X10Cache(x, y).DeviceType)
                        xml.WriteAttributeString("islight", X10Cache(x, y).IsLight)
                        xml.WriteAttributeString("dimtype", X10Cache(x, y).DimType)
                        xml.WriteAttributeString("tracksdimlevel", X10Cache(x, y).TracksDimLevel)
                        xml.WriteAttributeString("resumedim", X10Cache(x, y).ResumeDim)
                        xml.WriteAttributeString("selected", X10Cache(x, y).Selected)
                        xml.WriteAttributeString("offimage", X10Cache(x, y).OffImage)
                        xml.WriteAttributeString("onimage", X10Cache(x, y).OnImage)
                        xml.WriteEndElement()
                    Catch ex As Exception
                        Call WriteErrorLog("Error Writing X10 Device " & X10Cache(x, y).House.ToUpper & X10Cache(x, y).Device.ToUpper & " to XML (" & Err.Description & ")")
                    End Try
                End If
            Next
        Next
        xml.WriteEndElement()
        xml.WriteEndDocument()
        xml.Flush()
        xml.Close()

    End Sub

    ' routine to set x10 state by device
    Public Sub x10DeviceSet(ByVal strDevice As Object, ByVal intState As Object)
        Dim x As Integer
        Dim y As Integer
        If intState = X10_STATUS_ON Or intState = X10_STATUS_OFF Then
            Try
                x = Asc(Left(UCase(strDevice), 1)) - 64
                y = Val(Mid(UCase(strDevice), 2))
                If X10Cache(x, y).DeviceType <> X10_NONE Then
                    If intState = X10_STATUS_ON Then X10Cache(x, y).State = X10_ON
                    If intState = X10_STATUS_OFF Then X10Cache(x, y).State = X10_OFF
                    X10Cache(x, y).Change = Now
                    X10Cache(x, y).Expires = DateAdd(DateInterval.Minute, X10Cache(x, y).Timeout, X10Cache(x, y).Change)
                    If X10Cache(x, y).DeviceType = X10_MOTION And intState = X10_STATUS_ON Then X10Cache(x, y).Active = True
                End If
            Catch ex As Exception
            End Try
            Exit Sub
        End If
        If intState <> X10_ON And intState <> X10_OFF And intState <> X10_SELECT Then Exit Sub
        Try
            x = Asc(Left(UCase(strDevice), 1)) - 64
            y = Val(Mid(UCase(strDevice), 2))
            If intState = X10_SELECT Then
                Call x10Selections(x, y, True, False)
                Exit Sub
            End If
            If X10Cache(x, y).DeviceType <> X10_NONE = True Then
                X10Cache(x, y).State = intState
                X10Cache(x, y).Change = Now
                X10Cache(x, y).Expires = DateAdd(DateInterval.Minute, X10Cache(x, y).Timeout, X10Cache(x, y).Change)
                If X10Cache(x, y).DeviceType = X10_MOTION And intState = X10_ON Then X10Cache(x, y).Active = True
            End If
            Call x10Selections(x, y, False, False)
        Catch ex As Exception
        End Try
    End Sub

    ' routine to set x10 state by house
    Public Sub x10HouseSet(ByVal strHouse As Object, ByVal intState As Integer)
        Dim d, x As Integer
        Try
            x = Asc(Left(UCase(strHouse), 1)) - 64
            If x < 1 Or x > 26 Then Exit Sub
            Select Case intState
                Case X10_ON, X10_OFF
                    For d = 1 To 16
                        If X10Cache(x, d).DeviceType <> X10_NONE And X10Cache(x, d).Selected = True Then
                            X10Cache(x, d).State = intState
                            X10Cache(x, d).Change = Now
                        End If
                    Next
                    Call x10Selections(x, 0, False, False)
                Case X10_DIM, X10_BRIGHT
                    ' add dim/bright level support!!!
                    For d = 1 To 16
                        If (X10Cache(x, d).DeviceType = X10_LAMP Or X10Cache(x, d).DeviceType = X10_DIMMER) And X10Cache(x, d).Selected = True Then
                            X10Cache(x, d).State = X10_ON
                            X10Cache(x, d).Change = Now
                        End If
                    Next
                    Call x10Selections(x, 0, False, False)
                Case X10_ALL_UNITS_OFF
                    For d = 1 To 16
                        If (X10Cache(x, d).DeviceType = X10_LAMP Or X10Cache(x, d).DeviceType = X10_DIMMER Or X10Cache(x, d).DeviceType = X10_APPLIANCE) And X10Cache(x, d).Selected = True Then
                            X10Cache(x, d).State = X10_OFF
                            X10Cache(x, d).Change = Now
                        End If
                    Next
                    Call x10Selections(x, 0, False, True)
                Case X10_ALL_LIGHTS_OFF
                    For d = 1 To 16
                        If X10Cache(x, d).DeviceType <> X10_NONE And X10Cache(x, d).IsLight = True And X10Cache(x, d).Selected = True Then
                            X10Cache(x, d).State = X10_OFF
                            X10Cache(x, d).Change = Now
                        End If
                    Next
                    Call x10Selections(x, 0, False, True)
                Case X10_ALL_LIGHTS_ON
                    For d = 1 To 16
                        If X10Cache(x, d).DeviceType <> X10_NONE And X10Cache(x, d).IsLight = True And X10Cache(x, d).Selected = True Then
                            X10Cache(x, d).State = X10_ON
                            X10Cache(x, d).Change = Now
                        End If
                    Next
                    Call x10Selections(x, 0, False, True)
            End Select
        Catch ex As Exception
        End Try
    End Sub

    ' routine to maintain selection states (device = 0 = house command)
    Private Sub x10Selections(ByVal House As Integer, ByVal Device As Integer, ByVal IsSelect As Boolean, ByVal IsAllCmd As Boolean)
        Dim x As Integer
        Static HouseCmd(26) As Boolean
        If Device = 0 Then
            HouseCmd(House) = True
            If IsAllCmd = True Then
                For x = 1 To 16
                    X10Cache(House, x).Selected = False
                Next
                HouseCmd(House) = False
            End If
            Exit Sub
        End If
        If IsSelect = True Then
            If HouseCmd(House) = True Then
                For x = 1 To 16
                    X10Cache(House, x).Selected = False
                Next
                HouseCmd(House) = False
            End If
            X10Cache(House, Device).Selected = True
        Else
            HouseCmd(House) = True
            For x = 1 To 16
                X10Cache(House, x).Selected = False
            Next
            X10Cache(House, Device).Selected = True
        End If
    End Sub

    ' routine to clear select state
    Public Sub x10SelectClear(ByVal strDevice As String)
        Dim x As Integer
        Dim h As Integer
        h = Asc(strDevice.ToUpper.Substring(0, 1)) - 64
        For x = 1 To 16
            X10Cache(h, x).Selected = False
        Next
    End Sub

    ' routine to set select state
    Public Sub x10SelectSet(ByVal strDevice As Object, ByVal IsSelected As Object)
        Dim h, d As Integer
        h = Asc(strDevice.ToUpper.Substring(0, 1)) - 64
        d = Val(Mid(strDevice, 2))
        If X10Cache(h, d).DeviceType <> X10_NONE Then
            Select Case X10Cache(h, d).DeviceType
                Case X10_LAMP, X10_APPLIANCE, X10_DIMMER, X10_SPECIAL
                    X10Cache(h, d).Selected = IsSelected
            End Select
        End If
    End Sub

End Module
