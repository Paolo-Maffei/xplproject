'* xPL Library for .NET
'*
'* Version 5.3
'*
'* Copyright (c) 2009-2011 Thijs Schreijer
'* http://www.thijsschreijer.nl
'*
'* Copyright (c) 2008-2009 Tom Van den Panhuyzen
'* http://blog.boxedbits.com/xpl
'*
'* Copyright (C) 2003-2005 John Bent
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
Imports xPL.xPL_Base
Imports System.Text.RegularExpressions

''' <summary>
''' The xPLMessage object represents  a single xPL message
''' </summary>
''' <remarks></remarks>
Public Class xPLMessage

#Region "Constructors"

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLMessage" /> class. All properties set to their default values.
    ''' </summary>
    Public Sub New()
        ' nothing to do, defaults have been set
    End Sub

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLMessage" /> class from a raw xPL message string.
    ''' </summary>
    ''' <exception cref="InvalidXPLMessageException">Condition: If the message does not adhere to the xML specifications.</exception>
    ''' <param name="RawxPLMsg">The raw xPL MSG.</param>
    ''' <remarks>All elements that only allow for lowercase characters are transparently converted to lowercase and will 
    ''' not raise any exceptions.</remarks>
    Public Sub New(ByVal RawxPLMsg As String)
        If Not ExtractContents(RawxPLMsg) Then
            Throw New InvalidXPLMessageException(RawxPLMsg)
        End If
    End Sub

#End Region

#Region "Properties"

    Private mMsgType As xPLMessageTypeEnum = xPLMessageTypeEnum.Status
    ''' <summary>
    ''' Gets or sets the type of the message.
    ''' </summary>
    ''' <value>The type of the message as xPLMessageTypeEnum, except for the 'Any' (wildcard) value</value>
    ''' <exception cref="IllegalFieldContentsException">Conditions: when the wildcard value 'Any' is being set.</exception>
    ''' <remarks>Default value for new xPLMessageObjects is 'Trigger'</remarks>
    Public Property MsgType() As xPLMessageTypeEnum
        Get
            Return mMsgType
        End Get
        Set(ByVal value As xPLMessageTypeEnum)
            If value = xPLMessageTypeEnum.Any Then
                Throw New IllegalFieldContentsException("Message Type for a message object cannot be wildcarded ('Any', or string '*')")
            End If
            mMsgType = value
        End Set
    End Property

    Private mHop As Integer = 1
    ''' <summary>
    ''' Gets the hop count of the message.
    ''' </summary>
    ''' <value>The message hop count.</value>
    ''' <remarks>Default value is 1. Only for messages created from a raw xPL string (usually received messages from the xPL network) 
    ''' this can be something else. If a value of 1 or less is being set, then the result will be 1, no exceptions will be thrown.</remarks>
    Public Property Hop() As Integer
        Get
            Return mHop
        End Get
        Set(ByVal value As Integer)
            If value >= 1 Then mHop = value
        End Set
    End Property

    Private mSource As New xPLAddress(xPLAddressType.Source)
    ''' <summary>
    ''' Gets or sets the source address of the xPL message.
    ''' </summary>
    ''' <value>The source address in format 'vendor-device.instance'.</value>
    ''' <exception cref="IllegalIDsInAddress">Condition: if illegal characters or length is set for the address(parts)</exception>
    ''' <remarks>No wildcards are allowed in the source address. Any uppercase characters will automatically be converted to lowercase.</remarks>
    Public Property Source() As String
        Get
            Return mSource.ToString
        End Get
        Set(ByVal value As String)
            Dim x As New xPLAddress(xPLAddressType.Source, value)
            mSource.Vendor = x.Vendor
            mSource.Device = x.Device
            mSource.Instance = x.Instance
        End Set
    End Property

    Private mTarget As New xPLAddress(xPLAddressType.Target)
    ''' <summary>
    ''' Gets or sets the target address of the xPL message.
    ''' </summary>
    ''' <value>The target address in format 'vendor-device.instance'.</value>
    ''' <exception cref="IllegalIDsInAddress">Condition: if illegal characters or length is set for the address(parts)</exception>
    ''' <remarks>Wildcards are allowed. Any uppercase characters will automatically be converted to lowercase.</remarks>
    Public Property Target() As String
        Get
            Return mTarget.ToString
        End Get
        Set(ByVal value As String)
            Dim x As New xPLAddress(xPLAddressType.Target, value)
            mTarget.Vendor = x.Vendor
            mTarget.Device = x.Device
            mTarget.Instance = x.Instance
        End Set
    End Property

    Private mSchema As New xPLSchema
    ''' <summary>
    ''' Gets or sets the schema used by the xPL message.
    ''' </summary>
    ''' <value>The schema in format 'class.type'.</value>
    ''' <exception cref="IllegalSchema">Condition: if illegal characters or length is set for the schema(parts)</exception>
    ''' <remarks>No wildcards are allowed in the schema. Any uppercase characters will automatically be converted to lowercase.</remarks>
    Public Property Schema() As String
        Get
            Return mSchema.ToString
        End Get
        Set(ByVal value As String)
            Dim x As New xPLSchema(value)
            If x.SchemaClass = "*" Or x.SchemaType = "*" Then
                Throw New IllegalSchema("Wildcards are not allowed in a message schema. Schema: " & value)
            End If
            mSchema.SchemaClass = x.SchemaClass
            mSchema.SchemaType = x.SchemaType
        End Set
    End Property

    Private mKeyValueList As New xPLKeyValuePairs
    ''' <summary>
    ''' Gets the key value list for this message containing all the key value pairs in the message body.
    ''' </summary>
    ''' <value>The key value list.</value>
    ''' <remarks>Read only</remarks>
    Public ReadOnly Property KeyValueList() As xPLKeyValuePairs
        Get
            Return mKeyValueList
        End Get
    End Property

    ''' <summary>
    ''' Returns or sets the raw xPL string for the current message.
    ''' </summary>
    ''' <value>The raw xPL string to set for the xPL message object</value>
    ''' <returns>The raw xPL string generated from the current xPL message objects contents</returns>
    ''' <exception cref="MissingFieldsException"><para>Condition: When required fields are missing or any of the following checks failed;</para>
    ''' <para>   - Message type may not be wildcard '*'</para>
    ''' <para>   - Source address has type 'Target'</para>
    ''' <para>   - Target address has type 'Source'</para>
    ''' <para>   - Schema may not be wildcarded</para>
    ''' <para>   - No key/value pairs have been set</para>
    ''' <para>   - Status messages must always be broadcasted (target='*')</para>
    ''' <para>   - Trigger messages must always be broadcasted (target='*')</para>
    ''' <para>If the conversion fails; then the current object values might be partially overwritten by the values from the raw xPL string.</para>
    ''' </exception>
    ''' <remarks>When getting this property, the content is dynamically created. This means that a raw xPL value set 
    ''' is not necessarily equal to the raw xPL returned. Uppercase may have been converted to lowercase for example.</remarks>
    Public Property RawxPL() As String
        Get
            Dim s As String
            'check if all fields supplied
            s = RequiredFieldsFilled()
            If s <> "" Then
                Throw New MissingFieldsException("Unable to construct valid xPL message: " & s)
            End If
            Return BuildxPLMsg()
        End Get
        Set(ByVal value As String)
            mRawxPLReceived = value
            If Not ExtractContents(value) Then
                Throw New InvalidXPLMessageException(value)
            End If
        End Set
    End Property

    Dim mRawxPLReceived As String = ""
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <returns>Raw xPL as set for the message, or an empty string ( "" ) if nothing was set.</returns>
    ''' <remarks>Setting a raw xPL string to the <see cref="xPLMessage.RawxPL"/> property will set this value, 
    ''' or providing a rawxPL string when creating the object.</remarks>
    Public ReadOnly Property RawxPLReceived() As String
        Get
            Return mRawxPLReceived
        End Get
    End Property

#End Region

#Region "Other..."

    ''' <summary>
    ''' Send the message though the specified xPL device, using the <c>xPLDevice.Send</c> method. Any 
    ''' exceptions from that method will not be caught, so see <seealso>xPLDevice.Send</seealso> for 
    ''' other exception that might occur.
    ''' </summary>
    ''' <param name="xdev">An <c>xPLDevice</c> object through which the message should be sent. If this
    ''' parameter is not provided, the device will be lookedup in the <see cref="xPLListener"/> device list
    ''' by the <c>Source</c> address specified in the message.</param>
    ''' <remarks>The <c>Source</c> property of the message will be overwritten with the address of the
    ''' device through which to sent (if provided).</remarks>
    ''' <exception cref="NullReferenceException">Condition: <c>xdev</c> parameter <c>Is Nothing</c> and <c>Source</c>
    ''' address is not found in the local device list of <c>xPLListener</c>.</exception>
    Public Sub Send(Optional ByVal xdev As xPLDevice = Nothing)
        If (xdev Is Nothing) And (xPLListener.IndexOf(mSource) = -1) Then Throw New NullReferenceException
        If xdev Is Nothing Then
            xdev = xPLListener.Device(mSource)
        End If
        xdev.Send(Me)
    End Sub

    ''' <summary>
    ''' Checks if all required fields to build and raw xPL string are complete and properly filled.
    ''' </summary>
    ''' <returns>Empty string is all is OK, error message (the deficit) if not OK</returns>
    Private Function RequiredFieldsFilled() As String
        '
        '  When updating the checks in this function; DO NOT  forget to update the xml intellisense 
        '  comments of the RawxPL property !!!!
        '
        If mMsgType = xPLMessageTypeEnum.Any Then Return "Message type cannot be wildcard '*'"
        If mSource.Type <> xPLAddressType.Source Then Return "Source address has type 'Target'"
        If mTarget.Type <> xPLAddressType.Target Then Return "Target address has type 'Source'"
        If mSchema.IsWildCarded Then Return "Schema cannot be wildcarded"
        If mKeyValueList.Count = 0 Then Return "No key/value pairs have been set"
        If mMsgType = xPLMessageTypeEnum.Status And mTarget.ToString <> "*" Then Return "Status messages must always be broadcasted (target='*')"
        If mMsgType = xPLMessageTypeEnum.Trigger And mTarget.ToString <> "*" Then Return "Trigger messages must always be broadcasted (target='*')"
        Return ""
    End Function

    ''' <summary>
    ''' Builds the xPL message.
    ''' </summary>
    ''' <returns>string containing the raw xPL</returns>
    Private Function BuildxPLMsg() As String
        Dim s As String = ""
        s = MsgType2String(Me.mMsgType) & XPL_LF & _
            "{" & XPL_LF & _
            "hop=" & CStr(Me.mHop) & XPL_LF & _
            "source=" & Me.mSource.ToString & XPL_LF & _
            "target=" & Me.mTarget.ToString & XPL_LF & _
            "}" & XPL_LF & _
            Me.Schema.ToString & XPL_LF & _
            "{" & XPL_LF & _
            Me.mKeyValueList.ToString & XPL_LF & _
            "}" & XPL_LF

        Return s
    End Function

    ''' <summary>
    ''' Extracts the contents of a raw xPL message into the xPL message object.
    ''' </summary>
    ''' <param name="themsg">The raw xPL string containing the message.</param>
    ''' <returns>True if the conversion was succesfull, false if it failed</returns>
    Private Function ExtractContents(ByVal themsg As String) As Boolean
        Dim r As Regex
        Dim m As Match
        Dim ival As Integer
        Dim ok As Boolean = False

        Me.mRawxPLReceived = themsg
        r = New Regex("^xpl-(?<msgtype>trig|stat|cmnd)\n" & _
                               "\{\n" & _
                               "(?:hop=\d\n" & _
                               "|source=(?<sv>[0-9a-z]{1,8})-(?<sd>[0-9a-z]{1,8})\.(?<si>[0-9a-z/-]{1,16})\n" & _
                               "|target=(?<target>(?<tv>[0-9a-z]{1,8})-(?<td>[0-9a-z]{1,8})\.(?<ti>[0-9a-z/-]{1,16})|\*)\n){3}" & _
                               "\}\n" & _
                               "(?<class>[0-9a-z/-]{1,8})\.(?<type>[0-9a-z/-]{1,8})\n" & _
                               "\{\n" & _
                               "(?:(?<key>[0-9a-z/-]{1,16})=(?<val>[\x20-\xFF]{0,})\n)*" & _
                               "\}\n$" _
                               , RegexOptions.Compiled Or RegexOptions.Singleline Or RegexOptions.IgnoreCase)


        m = r.Match(themsg)
        If m.Success Then
            Select Case m.Groups("msgtype").Captures(0).Value.ToLower()

                Case "trig" : Me.mMsgType = xPLMessageTypeEnum.Trigger
                Case "cmnd" : Me.mMsgType = xPLMessageTypeEnum.Command
                Case "stat" : Me.mMsgType = xPLMessageTypeEnum.Status
            End Select

            mSource.Vendor = m.Groups("sv").Captures(0).Value
            mSource.Device = m.Groups("sd").Captures(0).Value
            mSource.Instance = m.Groups("si").Captures(0).Value

            If m.Groups("target").Captures(0).Value = "*" Then
                mTarget.Vendor = "*"
                mTarget.Device = "*"
                mTarget.Instance = "*"
            Else
                mTarget.Vendor = m.Groups("tv").Captures(0).Value
                mTarget.Device = m.Groups("td").Captures(0).Value
                mTarget.Instance = m.Groups("ti").Captures(0).Value
            End If

            mSchema.SchemaClass = m.Groups("class").Captures(0).Value
            mSchema.SchemaType = m.Groups("type").Captures(0).Value

            mKeyValueList.Clear()
            ival = 0
            For Each c As Capture In m.Groups("key").Captures
                mKeyValueList.Add(New xPLKeyValuePair(c.Value, m.Groups("val").Captures(ival).Value))
                ival += 1
            Next

            ok = True
        End If

        Return ok

    End Function

    ''' <summary>
    ''' Converts a string into an <see cref="xPLMessageTypeEnum"/> value
    ''' </summary>
    ''' <param name="MsgType">Can be any of the XPL_TYPELBL_xxxx constants</param>
    ''' <returns>An xPLMessageTypeEnum value</returns>
    ''' <exception cref="ArgumentException">condition: if a string value is passed that doesn't match any of the XPL_TYPELBL_xxxx constants.</exception>
    ''' <remarks>Any input will be converted to lower case.</remarks>
    Public Shared Function MsgType2Enum(ByVal MsgType As String) As xPLMessageTypeEnum
        Select Case MsgType.ToLower
            Case XPL_TYPELBL_CMND
                Return xPLMessageTypeEnum.Command
            Case XPL_TYPELBL_STAT
                Return xPLMessageTypeEnum.Status
            Case XPL_TYPELBL_TRIG
                Return xPLMessageTypeEnum.Trigger
            Case XPL_TYPELBL_ANY
                Return xPLMessageTypeEnum.Any
            Case Else
                Throw New ArgumentException("'" & MsgType & "' doesn't match any of the XPL_TYPELBL_xxxx constants.")
        End Select
    End Function
    ''' <summary>
    ''' Converts an <see cref="xPLMessageTypeEnum"/> value into a string
    ''' </summary>
    ''' <param name="MsgType">An xPLMessageTypeEnum value</param>
    ''' <returns>Can be any of the XPL_TYPELBL_xxxx constants</returns>
    Public Shared Function MsgType2String(ByVal MsgType As xPLMessageTypeEnum) As String
        Select Case MsgType
            Case xPLMessageTypeEnum.Command
                Return XPL_TYPELBL_CMND
            Case xPLMessageTypeEnum.Status
                Return XPL_TYPELBL_STAT
            Case xPLMessageTypeEnum.Trigger
                Return XPL_TYPELBL_TRIG
            Case xPLMessageTypeEnum.Any
                Return XPL_TYPELBL_ANY
            Case Else
                ' do nothing
                Return ""
        End Select
    End Function

#End Region

End Class
