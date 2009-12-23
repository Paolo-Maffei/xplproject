'* xPL Library for .NET
'* xPLMsg Class
'*
'* Version 4.4
'*
'* Copyright (c) 2008 Tom Van den Panhuyzen
'* http://blog.boxedbits.com/xpl
'*
'* Copyright (C) 2003-2005 John Bent
'* http://www.xpl.myby.co.uk
'*
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
'* Linking this library statically or dynamically with other modules is
'* making a combined work based on this library. Thus, the terms and
'* conditions of the GNU General Public License cover the whole
'* combination.
'* As a special exception, the copyright holders of this library give you
'* permission to link this library with independent modules to produce an
'* executable, regardless of the license terms of these independent
'* modules, and to copy and distribute the resulting executable under
'* terms of your choice, provided that you also meet, for each linked
'* independent module, the terms and conditions of the license of that
'* module. An independent module is a module which is not derived from
'* or based on this library. If you modify this library, you may extend
'* this exception to your version of the library, but you are not
'* obligated to do so. If you do not wish to do so, delete this
'* exception statement from your version.
Option Strict On

Imports System.Collections.Generic
Imports System.Net
Imports Microsoft.Win32
Imports System.Net.Sockets
Imports System.Text.RegularExpressions

'* The XplMsg class represents a single XPL message.
'* As such, it provides methods for constructing, analysing,
'* and sending an XPL message.
Public Class XplMsg

    Public Enum xPLMsgType
        trig
        stat
        cmnd
    End Enum

    Public Class KeyValuePair
        Private mKey As String
        Private mValue As String

        Public Sub New(ByVal k As String, ByVal v As String)
            mKey = k
            mValue = v
        End Sub

        Public Property Key() As String
            Get
                Return mKey
            End Get
            Set(ByVal value As String)
                If CheckString(value, 1, 8, True) Then
                    mKey = value
                Else
                    Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
                End If
            End Set
        End Property

        Public Property Value() As String
            Get
                Return mValue
            End Get
            Set(ByVal v As String)
                If CheckString(v, 0, 128, False) Then
                    mValue = v
                Else
                    Throw New IllegalFieldContentsException("Illegal field length (0 to 128)")
                End If
            End Set
        End Property
    End Class

    Private Const DefaultStrictInterpretation As Boolean = False
    Shared mStrictInterpretation As Boolean
    Private mXplMsgType As xPLMsgType
    Private mSourceVendor As String
    Private mSourceDevice As String
    Private mSourceInstance As String
    Private mTargetVendor As String
    Private mTargetDevice As String
    Private mTargetInstance As String
    Private mTargetIsAll As Boolean
    Private mClass As String
    Private mType As String
    Private mKeysValues As List(Of KeyValuePair)
    Private mRawXPL As String
    Private mValidRawXPL As Boolean

    Private Const XPL_BASE_PORT As Integer = 3865
    Private Shared pBroadcastAddress As IPAddress

    Public Sub New()
        mStrictInterpretation = DefaultStrictInterpretation
        mXplMsgType = xPLMsgType.cmnd
        mTargetIsAll = True
        mKeysValues = New List(Of KeyValuePair)
        mValidRawXPL = False

        mExtractedOldWay = False  'to be removed in future versions
        XPL_Raw = ""  'to be removed in future versions
    End Sub

    Public Sub New(ByVal rawXplMsg As String)
        mStrictInterpretation = DefaultStrictInterpretation
        If Not ExtractContents(rawXplMsg) Then
            Throw New InvalidXPLMessageException()
        End If

        mExtractedOldWay = False  'to be removed in future versions
        XPL_Raw = rawXplMsg  'to be removed in future versions
    End Sub

    Public Sub New(ByVal rawXplMsg As String, ByVal AllowUppercase As Boolean)
        mStrictInterpretation = Not AllowUppercase
        If Not ExtractContents(rawXplMsg) Then
            Throw New InvalidXPLMessageException()
        End If

        mExtractedOldWay = False  'to be removed in future versions
        XPL_Raw = rawXplMsg  'to be removed in future versions
    End Sub

    Public Property AllowUppercaseFromNetwork() As Boolean
        Get
            Return Not mStrictInterpretation
        End Get
        Set(ByVal value As Boolean)
            mStrictInterpretation = Not value
        End Set
    End Property

    Public Property MsgType() As xPLMsgType
        Get
            Return mXplMsgType
        End Get
        Set(ByVal value As xPLMsgType)
            mXplMsgType = value
        End Set
    End Property


    Public ReadOnly Property MsgTypeString() As String
        Get
            Select Case mXplMsgType
                Case xPLMsgType.cmnd : Return "xpl-cmnd"
                Case xPLMsgType.stat : Return "xpl-stat"
                Case xPLMsgType.trig : Return "xpl-trig"
            End Select
            Return ""
        End Get
    End Property

    Public Property SourceVendor() As String
        Get
            Return mSourceVendor
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mSourceVendor = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
        End Set
    End Property

    Public Property SourceDevice() As String
        Get
            Return mSourceDevice
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mSourceDevice = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
        End Set
    End Property

    Public Property SourceInstance() As String
        Get
            Return mSourceInstance
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 16, True) Then
                mSourceInstance = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 16) or illegal casing")
            End If
        End Set
    End Property

    Public ReadOnly Property SourceTag() As String
        Get
            Return mSourceVendor & "-" & mSourceDevice & "." & mSourceInstance
        End Get
    End Property

    Public Property TargetVendor() As String
        Get
            Return mTargetVendor
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mTargetVendor = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
            If value = "*" Then mTargetIsAll = True
        End Set
    End Property

    Public Property TargetDevice() As String
        Get
            Return mTargetDevice
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mTargetDevice = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
            If value = "*" Then mTargetIsAll = True
        End Set
    End Property

    Public Property TargetInstance() As String
        Get
            Return mTargetInstance
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 16, True) Then
                mTargetInstance = value
                If value = "*" Then mTargetIsAll = True
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 16) or illegal casing")
            End If
        End Set
    End Property

    Public ReadOnly Property TargetTag() As String
        Get
            If TargetIsAll Then
                Return "*"
            Else
                Return mTargetVendor & "-" & mTargetDevice & "." & mTargetInstance
            End If
        End Get
    End Property

    Public Property TargetIsAll() As Boolean
        Get
            Return mTargetIsAll
        End Get
        Set(ByVal value As Boolean)
            mTargetIsAll = value
            If value Then
                mTargetVendor = "*"
                mTargetDevice = "*"
                mTargetInstance = "*"
            End If
        End Set
    End Property

    Public Property [Class]() As String
        Get
            Return mClass
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mClass = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
        End Set
    End Property

    Public Property [Type]() As String
        Get
            Return mType
        End Get
        Set(ByVal value As String)
            If CheckString(value, 1, 8, True) Then
                mType = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
        End Set
    End Property

    Public Sub AddKeyValuePair(ByRef KeyValue As KeyValuePair)
        mKeysValues.Add(KeyValue)
    End Sub

    Public Sub AddKeyValuePair(ByVal Key As String, ByVal Value As String)
        mKeysValues.Add(New KeyValuePair(Key, Value))
    End Sub

    Public ReadOnly Property KeyValues() As List(Of KeyValuePair)
        Get
            Return mKeysValues
        End Get
    End Property

    Public Function GetKeyValue(ByVal Key As String) As String

        For Each kv As KeyValuePair In mKeysValues
            If kv.Key.ToLower() = Key Then
                Return kv.Value
            End If
        Next
        Return ""

    End Function

    Public Property RawXPL() As String
        Get
            If Not mValidRawXPL Then
                'check if all fields supplied

                If RequiredFieldsFilled() Then
                    mRawXPL = BuildXplMsg()
                    mValidRawXPL = True
                Else
                    Throw New MissingFieldsException("Unable to construct valid xPL from supplied fields.")
                End If
            End If
            Return mRawXPL
        End Get
        Set(ByVal value As String)
            If Not ExtractContents(value) Then
                Throw New InvalidXPLMessageException()
            End If
        End Set
    End Property

    Private Function BuildXplMsg() As String
        Dim s As String = ""

        Select Case mXplMsgType
            Case xPLMsgType.cmnd : s = "xpl-cmnd" & vbLf & "{" & vbLf & "hop=1" & vbLf
            Case xPLMsgType.stat : s = "xpl-stat" & vbLf & "{" & vbLf & "hop=1" & vbLf
            Case xPLMsgType.trig : s = "xpl-trig" & vbLf & "{" & vbLf & "hop=1" & vbLf
        End Select

        s += "source=" & SourceTag & vbLf
        s += "target=" & TargetTag & vbLf
        s += "}" & vbLf & mClass & "." & mType & vbLf & "{" & vbLf

        For Each kv As KeyValuePair In mKeysValues
            s += kv.Key & "=" & kv.Value & vbLf
        Next

        s += "}" & vbLf

        Return s
    End Function

    'test the string: is it too long, and if it has to be lowercase, is it lowercase ?
    Shared Function CheckString(ByVal theString As String, ByVal minlen As Integer, ByVal maxlen As Integer, ByVal lower As Boolean) As Boolean
        Dim ok As Boolean = True

        If theString.Length() > maxlen Or theString.Length() < minlen Then ok = False
        If ok AndAlso lower AndAlso theString.ToLower() <> theString Then ok = False

        Return ok
    End Function

    Private Function RequiredFieldsFilled() As Boolean
        If mSourceVendor.Length() > 0 And mSourceDevice.Length() > 0 And mSourceInstance.Length() > 0 _
          And (mTargetIsAll Or (mTargetVendor.Length() > 0 And mTargetDevice.Length() > 0 And mTargetInstance.Length() > 0)) _
          And mClass.Length() > 0 And mType.Length() > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Private Function ExtractContents(ByVal themsg As String) As Boolean
        Dim ok As Boolean = False
        Dim m As Match

        'If mStrictInterpretation Then  'no uppercase allowed

        '    r = New Regex("^xpl-(?<msgtype>trig|stat|cmnd)\n" & _
        '                           "\{\n" & _
        '                           "(?:hop=\d\n" & _
        '                           "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\.(?<si>[0-9a-z/-]{1,16})\n" & _
        '                           "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\.(?<ti>[0-9a-z/-]{1,16})|\*)\n){3}" & _
        '                           "\}\n" & _
        '                           "(?<class>[0-9a-z/-]{1,8})\.(?<type>[0-9a-z/-]{1,8})\n" & _
        '                           "\{\n" & _
        '                           "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\x20-\x7E]{0,128})\n)*" & _
        '                           "\}\n$" _
        '                           , RegexOptions.Compiled Or RegexOptions.Singleline)

        'Else  'mixed case allowed

        '    r = New Regex("^xpl-(?<msgtype>trig|stat|cmnd)\n" & _
        '                           "\{\n" & _
        '                           "(?:hop=\d\n" & _
        '                           "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\.(?<si>[0-9a-z/-]{1,16})\n" & _
        '                           "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\.(?<ti>[0-9a-z/-]{1,16})|\*)\n){3}" & _
        '                           "\}\n" & _
        '                           "(?<class>[0-9a-z/-]{1,8})\.(?<type>[0-9a-z/-]{1,8})\n" & _
        '                           "\{\n" & _
        '                           "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\x20-\x7E]{0,128})\n)*" & _
        '                           "\}\n$" _
        '                           , RegexOptions.Compiled Or RegexOptions.Singleline Or RegexOptions.IgnoreCase)

        'End If

        'Dim m As Match = r.Match(themsg)

        'using static method to avoid object creation...
        Dim pattern As String = "^xpl-(?<msgtype>trig|stat|cmnd)\n" & _
                                   "\{\n" & _
                                   "(?:hop=\d\n" & _
                                   "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\.(?<si>[0-9a-z/-]{1,16})\n" & _
                                   "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\.(?<ti>[0-9a-z/-]{1,16})|\*)\n){3}" & _
                                   "\}\n" & _
                                   "(?<class>[0-9a-z/-]{1,8})\.(?<type>[0-9a-z/-]{1,8})\n" & _
                                   "\{\n" & _
                                   "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\x20-\x7E]{0,128})\n)*" & _
                                   "\}\n$"

        If mStrictInterpretation Then  'no uppercase allowed
            m = Regex.Match(themsg, pattern, RegexOptions.Compiled Or RegexOptions.Singleline)
        Else  'mixed case allowed
            m = Regex.Match(themsg, pattern, RegexOptions.Compiled Or RegexOptions.Singleline Or RegexOptions.IgnoreCase)
        End If

        If m.Success Then
            Select Case m.Groups("msgtype").Captures(0).Value.ToLower()
                Case "trig" : mXplMsgType = xPLMsgType.trig
                Case "cmnd" : mXplMsgType = xPLMsgType.cmnd
                Case "stat" : mXplMsgType = xPLMsgType.stat
            End Select

            mSourceVendor = m.Groups("sv").Captures(0).Value
            mSourceDevice = m.Groups("sd").Captures(0).Value
            mSourceInstance = m.Groups("si").Captures(0).Value

            If m.Groups("target").Captures(0).Value = "*" Then
                mTargetIsAll = True
                mTargetVendor = "*"
                mTargetDevice = "*"
                mTargetInstance = "*"
            Else
                mTargetIsAll = False
                mTargetVendor = m.Groups("tv").Captures(0).Value
                mTargetDevice = m.Groups("td").Captures(0).Value
                mTargetInstance = m.Groups("ti").Captures(0).Value
            End If

            mClass = m.Groups("class").Captures(0).Value
            mType = m.Groups("type").Captures(0).Value

            Dim ival As Integer = 0
            mKeysValues = New List(Of KeyValuePair)

            For Each c As Capture In m.Groups("key").Captures
                mKeysValues.Add(New KeyValuePair(c.Value, m.Groups("val").Captures(ival).Value))
                ival += 1
            Next

            mRawXPL = themsg
            mValidRawXPL = True
            ok = True
        End If

        Return ok

    End Function

#Region "Older interface left for compatibility reasons"
    Private mExtractedOldWay As Boolean

    <Obsolete()> _
    Public Structure XplSchema
        Dim msgClass As String
        Dim msgType As String
    End Structure

    <Obsolete()> _
    Public Structure XplSource
        Dim Vendor As String
        Dim Device As String
        Dim Instance As String
    End Structure

    <Obsolete()> _
    Public Structure structXPLMsg
        Public keyName As String
        Public Value As String
    End Structure

    <Obsolete()> _
    Public Structure structXplSection
        Public Section As String
        Public Details() As structXPLMsg
        Public DC As Integer
    End Structure

    Private XPL_Raw As String
    <Obsolete()> _
    Public XPL_Msg() As structXplSection
    Private XPL_Bodies As Integer
    Private bValid As Boolean

    'Public Sub New(ByVal XPLMsg As String)
    '    bValid = False
    '    XPL_Raw = XPLMsg
    '    If XPLMsg.Length > 0 Then
    '        ExtractMsg()
    '    End If
    'End Sub

    'Public Sub New()
    '    bValid = False
    'End Sub

    <Obsolete()> _
    Public ReadOnly Property IsMessageValid() As Boolean
        Get
            If Not mExtractedOldWay Then ExtractMsg()
            IsMessageValid = bValid
        End Get
    End Property

    <Obsolete()> _
    Public ReadOnly Property Bodies() As Integer
        Get
            If Not mExtractedOldWay Then ExtractMsg()
            Bodies = XPL_Bodies
        End Get
    End Property

    <Obsolete()> _
    Public ReadOnly Property Content() As String
        Get
            Return (XPL_Raw)
        End Get
    End Property

    'xpl-trig
    '{
    'hop=1
    'source=medusa-xplcm11.vmcm11
    'target=*
    '}
    'x10.basic
    '{
    'command=OFF
    'device=C7
    '}

    Private Sub ExtractMsg()
        Try
            Dim tempstr As String = XPL_Raw
            Dim x As Integer, y As Integer, z As Integer

            bValid = True
            XPL_Bodies = -1

extract_next_part:
            ' Get section
            y = InStr(1, tempstr, vbLf + "{" + vbLf, vbBinaryCompare)
            If y = 0 Then
                If XPL_Bodies = -1 Then
                    bValid = False
                End If
                Exit Sub
            End If

            XPL_Bodies = XPL_Bodies + 1

            ReDim Preserve XPL_Msg(XPL_Bodies)
            XPL_Msg(XPL_Bodies).DC = -1
            XPL_Msg(XPL_Bodies).Section = UCase(StripIt(Left$(tempstr, y - 1)).ToString())
            If XPL_Bodies = 0 Then
                Select Case XPL_Msg(XPL_Bodies).Section
                    Case "XPL-CMND"
                    Case "XPL-STAT"
                    Case "XPL-TRIG"
                    Case Else
                        bValid = False
                        Exit Sub
                End Select
            End If
            tempstr = Mid$(tempstr, y + 3)

extract_next_name:
            ' get name of name/value pair
            x = InStr(1, tempstr, "=", vbBinaryCompare)
            z = InStr(1, tempstr, "!", vbBinaryCompare)
            If z <> 0 And z < x Then x = z
            XPL_Msg(XPL_Bodies).DC = XPL_Msg(XPL_Bodies).DC + 1
            ReDim Preserve XPL_Msg(XPL_Bodies).Details(XPL_Msg(XPL_Bodies).DC)
            XPL_Msg(XPL_Bodies).Details(XPL_Msg(XPL_Bodies).DC).keyName = UCase(StripIt(Left$(tempstr, x - 1)).ToString())

            ' get value
            tempstr = Mid$(tempstr, x + 1)
            x = InStr(1, tempstr, vbLf, vbBinaryCompare)
            XPL_Msg(XPL_Bodies).Details(XPL_Msg(XPL_Bodies).DC).Value = Left$(tempstr, x - 1)
            If XPL_Bodies = 0 Then
                XPL_Msg(XPL_Bodies).Details(XPL_Msg(XPL_Bodies).DC).Value = StripIt(XPL_Msg(XPL_Bodies).Details(XPL_Msg(XPL_Bodies).DC).Value)
            End If

            ' process next section/name
            tempstr = Mid$(tempstr, x)
            If InStr(1, tempstr, vbLf + "}" + vbLf, vbBinaryCompare) = 1 Then
                ' next part
                tempstr = Mid$(tempstr, 4)
                GoTo extract_next_part
            End If
            tempstr = Mid$(tempstr, 2)
            GoTo extract_next_name
        Catch ex As Exception
            bValid = False
        Finally
            mExtractedOldWay = True
        End Try
    End Sub

    ' routine to strip leading/trailing spaces
    Private Function StripIt(ByVal strWhat As String) As String
        If strWhat.Length = 0 Then
            Return ("")
        End If
        ' strip leading/trailing spaces
        StripIt = strWhat
        While Left$(StripIt, 1) = " "
            StripIt = Mid$(StripIt, 2)
        End While
        While Right$(StripIt, 1) = " "
            StripIt = Left$(StripIt, Len(StripIt) - 1)
        End While

    End Function

    <Obsolete()> _
    Public Function GetParam(ByVal BodyPart As Integer, ByVal strName As String) As String
        Dim Counter As Integer

        If Not mExtractedOldWay Then ExtractMsg()
        If BodyPart < 0 Or BodyPart > XPL_Bodies Then
            Return ("!InvalidBodyPart")
            Exit Function
        End If
        GetParam = ""
        While Counter <= XPL_Msg(BodyPart).DC
            If XPL_Msg(BodyPart).Details(Counter).keyName.ToLower() = strName.ToLower() Then
                GetParam = XPL_Msg(BodyPart).Details(Counter).Value
                Counter = XPL_Msg(BodyPart).DC + 1
            Else
                Counter = Counter + 1
            End If
        End While
    End Function

    <Obsolete()> _
    Public ReadOnly Property Schema() As XplSchema
        Get
            If Not mExtractedOldWay Then ExtractMsg()
            Dim s As XplSchema
            ' Extract the schema
            s.msgClass = XPL_Msg(1).Section.ToLower()
            s.msgType = s.msgClass.Substring(s.msgClass.IndexOf(".") + 1, s.msgClass.Length - s.msgClass.IndexOf(".") - 1)
            s.msgClass = s.msgClass.Substring(0, s.msgClass.IndexOf("."))
            Return (s)
        End Get
    End Property

    <Obsolete()> _
    Public ReadOnly Property Source() As XplSource
        Get
            If Not mExtractedOldWay Then ExtractMsg()
            Dim s As XplSource
            Dim mySource As String
            mySource = GetParam(0, "source").ToLower()
            ' Extract the three components from the source
            s.Vendor = mySource.Substring(0, mySource.IndexOf("-"))
            s.Device = mySource.Substring(mySource.IndexOf("-") + 1, mySource.IndexOf(".") - mySource.IndexOf("-") - 1)
            s.Instance = mySource.Substring(mySource.IndexOf(".") + 1, mySource.Length - mySource.IndexOf(".") - 1)
            Return (s)
        End Get
    End Property

    <Obsolete()> _
    Public ReadOnly Property Target() As XplSource
        Get
            If Not mExtractedOldWay Then ExtractMsg()
            Dim s As XplSource
            Dim mySource As String
            mySource = GetParam(0, "target").ToLower()
            ' Extract the three components from the source
            If mySource = "*" Then
                s.Vendor = "*"
                s.Device = "*"
                s.Instance = "*"
            Else
                s.Vendor = mySource.Substring(0, mySource.IndexOf("-"))
                s.Device = mySource.Substring(mySource.IndexOf("-") + 1, mySource.IndexOf(".") - mySource.IndexOf("-") - 1)
                s.Instance = mySource.Substring(mySource.IndexOf(".") + 1, mySource.Length - mySource.IndexOf(".") - 1)
            End If
            Return (s)
        End Get
    End Property
#End Region

    Private Shared ReadOnly Property BroadcastAddress() As IPAddress
        Get
            If Not pBroadcastAddress Is Nothing Then
                Return pBroadcastAddress
            Else
                Dim RegKey As RegistryKey = Nothing
                Try
                    RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
                    pBroadcastAddress = IPAddress.Parse(CStr(RegKey.GetValue("BroadcastAddress", "255.255.255.255")))
                Catch ex As Exception
                    pBroadcastAddress = IPAddress.Broadcast
                End Try
                If Not RegKey Is Nothing Then
                    RegKey.Close()
                End If
                BroadcastAddress = pBroadcastAddress
            End If
        End Get
    End Property

    Public Sub Send(ByVal ep As IPEndPoint)
        Dim s As New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
        s.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, 1)

        'See if we need to specify a source IP for the broadcast
        Dim sIP As String = XplListener.sListenOnIP()
        If sIP <> "ANY_LOCAL" Then
            Dim a As IPAddress = IPAddress.Parse(sIP)
            Dim lep As New IPEndPoint(a, 0)
            s.Bind(lep)
        End If

        s.SendTo(Encoding.ASCII.GetBytes(RawXPL), ep)
        s.Close()

    End Sub

    Public Sub Send()
        Dim ep As New IPEndPoint(BroadcastAddress, XPL_BASE_PORT)
        Send(ep)
    End Sub

    Public Sub Send(ByVal s As String)
        RawXPL = s
        Dim ep As New IPEndPoint(BroadcastAddress, XPL_BASE_PORT)
        Send(ep)
    End Sub

#Region "Definition of Exceptions"
    Public Class IllegalFieldContentsException
        Inherits System.Exception

        Public Sub New()
            MyBase.New()
        End Sub

        Public Sub New(ByVal message As String)
            MyBase.New(message)
        End Sub

        Public Sub New(ByVal message As String, ByVal inner As Exception)
            MyBase.New(message, inner)
        End Sub
    End Class

    Public Class InvalidXPLMessageException
        Inherits System.Exception

        Public Sub New()
            MyBase.New()
        End Sub

        Public Sub New(ByVal message As String)
            MyBase.New(message)
        End Sub

        Public Sub New(ByVal message As String, ByVal inner As Exception)
            MyBase.New(message, inner)
        End Sub
    End Class

    Public Class MissingFieldsException
        Inherits System.Exception

        Public Sub New()
            MyBase.New()
        End Sub

        Public Sub New(ByVal message As String)
            MyBase.New(message)
        End Sub

        Public Sub New(ByVal message As String, ByVal inner As Exception)
            MyBase.New(message, inner)
        End Sub
    End Class

#End Region
End Class
