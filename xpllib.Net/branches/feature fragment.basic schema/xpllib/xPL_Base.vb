'* xPL Library for .NET
'*
'* Version 5.4
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
Imports System.Threading
Imports System.Text
Imports System.IO

Public Class xPL_Base

    ''' <summary>
    ''' Alle exposed methods, properties and constants are Shared. No object instances can be created 
    ''' because the Constructor New is Private.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub New()
    End Sub

#Region "Exceptions"
    ''' <summary>
    ''' Exception that will be thrown if an element in an xPL message is set to a value that doesn't adhere to
    ''' the xPL protocol specification.
    ''' </summary>
    ''' <remarks>General checks are minimum and maximum length and allowed characters</remarks>
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

    ''' <summary>
    ''' Exception that will be thrown if a rawxPL string cannot be parsed to an xPLMessage object
    ''' </summary>
    ''' <remarks>The exception contains the <c>RawxPL</c> property that contains the message that couldn't be parsed.</remarks>
    Public Class InvalidXPLMessageException
        Inherits System.Exception

        ''' <summary>
        ''' Contains the rawxPL string that could not be parsed.
        ''' </summary>
        ''' <remarks></remarks>
        Public RawxPL As String

        Public Sub New(ByVal Raw_xPL As String)
            MyBase.New()
            RawxPL = Raw_xPL
        End Sub

        Public Sub New(ByVal Raw_xPL As String, ByVal message As String)
            MyBase.New(message)
            RawxPL = Raw_xPL
        End Sub

        Public Sub New(ByVal Raw_xPL As String, ByVal message As String, ByVal inner As Exception)
            MyBase.New(message, inner)
            RawxPL = Raw_xPL
        End Sub
    End Class

    ''' <summary>
    ''' <para>Exception thrown when (for the <c>xPLMessage</c> object) required fields are missing or any of the following checks failed;</para>
    ''' <para>   - Message type may not be wildcard '*'</para>
    ''' <para>   - Source address has type 'Target'</para>
    ''' <para>   - Target address has type 'Source'</para>
    ''' <para>   - Schema may not be wildcarded</para>
    ''' <para>   - No key/value pairs have been set</para>
    ''' <para>   - Status messages must always be broadcasted (target='*')</para>
    ''' <para>   - Trigger messages must always be broadcasted (target='*')</para>
    ''' </summary>
    ''' <remarks></remarks>
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

    ''' <summary>
    ''' Exception will be thrown if illegal characters or length will be set for schema properties
    ''' </summary>
    ''' <remarks></remarks>
    Public Class IllegalSchema
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

    ''' <summary>
    ''' Exception that will be thrown by the xPLAddress class if an attempt is made to either;
    ''' <para>  a) set a value that contains illegal characters</para>
    ''' <para>  b) set a value that is either to long or to short</para>
    ''' <para>  c) set a wildcard value ("*") in a source address</para>
    ''' </summary>
    ''' <remarks></remarks>
    Public Class IllegalIDsInAddress
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

    ''' <summary>
    ''' Exception thrown if a reserved ("newconf", "interval", "filter" or "group") name is assigned, or the name does not adhere to xPL requirements.
    ''' </summary>
    ''' <remarks></remarks>
    Public Class IllegalConfigItemName
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

    ''' <summary>
    ''' Exception thrown if a value is being assigned that does not adhere to xPL requirements.
    ''' </summary>
    ''' <remarks></remarks>
    Public Class IllegalConfigItemValue
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

    ''' <summary>
    ''' Exception thrown if a value is being set that causes a duplicate.
    ''' </summary>
    ''' <remarks></remarks>
    Public Class DuplicateConfigItemValue
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

    ''' <summary>
    ''' Exception that will be thrown if an attempt is made to add a duplicate to the configitems list
    ''' </summary>
    ''' <remarks></remarks>
    Public Class DuplicateConfigItemName
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

#Region "Enumerations"

    ''' <summary>
    ''' Enumerator for the different types of messages; command, trigger or status messages
    ''' </summary>
    ''' <remarks>The <c>Any</c> value is only valid for filters</remarks>
    Public Enum xPLMessageTypeEnum
        ''' <summary>
        ''' xPL trigger message
        ''' </summary>
        Trigger
        ''' <summary>
        ''' xPL status message
        ''' </summary>
        Status
        ''' <summary>
        ''' xPL command message
        ''' </summary>
        Command
        ''' <summary>
        ''' 'Any' is not an xPL message type, but respresents the string wildcard '*' to match 'any type of message' with an xPL filter.
        ''' </summary>
        Any
    End Enum

    ''' <summary>
    ''' Determines how the instance part of the address 'vendor.device.instance' will be set.
    ''' </summary>
    Enum InstanceCreation
        ''' <summary>
        ''' Generates an instance id for the device based upon the hostname of the PC the application is running on.
        ''' </summary>
        ''' <remarks>If multiple xPL devices do this, there might be an xPL address conflict. Be carefull with duplicates!</remarks>
        HostNameBased
        ''' <summary>
        ''' Generates a random instance id for the device, 16 characters long consisting of characters a-z and 0-9.
        ''' </summary>
        ''' <remarks>The randomized name has a very, nearly non-existing, small probability of generating duplicates</remarks>
        Randomized
        ''' <summary>
        ''' No name will be generated, it must be set using the InstanceID property.
        ''' </summary>
        ''' <remarks></remarks>
        SetByParent
    End Enum

    ''' <summary>
    ''' Enumeration used by the <see cref="xPLDevice.MessagePassing"/> property. This
    ''' setting determines for which messages an <see cref="xPLDevice.xPLMessageReceived"/> event will be raised.
    ''' </summary>
    ''' <remarks></remarks>
    <Flags()> Enum MessagePassingEnum As Integer
        ''' <summary>
        ''' The default setting is to send only content that needs handling (and hasn't been handled by the xpllib 
        ''' already). No messages of class 'hbeat' and 'config' will be passed nor any messages that do not pass 
        ''' the filter settings. No messages at all will be passed while awaiting configuration.
        ''' </summary>
        ''' <remarks></remarks>
        ToBeHandledOnly = 0
        ''' <summary>
        ''' If set instructs the xPL device to pass messages while it is awaiting configuration
        ''' </summary>
        ''' <remarks>Responses to heartbeat requests and config messges will be handled by the xpllib independent of this setting</remarks>
        PassWhileAwaitingConfig = 1
        ''' <summary>
        ''' If set instructs the device to pass my own heartbeats and heartbeat requests (schema class 'hbeat'). 
        ''' </summary>
        ''' <remarks>Heartbeats will always be dealt with by the xpllib, independent of this setting. 'My' is defined as targetted at: 1) me specific, 2) a group I belong to 3) NOT a broadcast.</remarks>
        PassMyHeartbeatStuff = 2
        ''' <summary>
        ''' If set instructs the device to pass any heartbeat messages from or requests for other devices (schema class 'hbeat').
        ''' </summary>
        ''' <remarks>This overrides <c>DoNotApplyFilters</c>. 'Others' is defined as everything except if targetted at 1) me specific, 2) a group I belong to.</remarks>
        PassOthersHeartbeats = 4
        ''' <summary>
        ''' If set instructs the device to pass the echo's of the device's own sent messages.
        ''' </summary>
        ''' <remarks>This overrides the <c>PassWhileAwaitingConfig</c></remarks>
        PassMyOwnEcho = 8
        ''' <summary>
        ''' If set instructs the device to pass any configuration type messages for me (schema class 'config').
        ''' </summary>
        ''' <remarks>The messages will be dealt with anyway by the xpllib. 
        ''' This setting overrides the <c>PassWhileAwaitingConfig</c>. 'My' is defined as targetted at: 1) me specific, 2) a group I belong to 3) NOT a broadcast.</remarks>
        PassMyConfigStuff = 16
        ''' <summary>
        ''' If set instructs the device to pass any configuration messages for other devices (schema class 'config').
        ''' </summary>
        ''' <remarks>This overrides <c>DoNotApplyFilters</c>. 'Others' is defined as everything except if targetted at 1) me specific, 2) a group I belong to.</remarks>
        PassOthersConfig = 32
        ''' <summary>
        ''' If set instructs the device to pass messages even if they do not match the filter settings.
        ''' </summary>
        ''' <remarks>NOTE: Filters only apply to broadcast messages, so non-broadcast messages will not be handled differently based upon
        ''' this setting.</remarks>
        DoNotApplyFilters = 64
        ''' <summary>
        ''' If set, passes all messages.
        ''' </summary>
        ''' <remarks></remarks>
        All = 255
    End Enum

    ''' <summary>
    ''' Represents the status of an <c>xPLDevice</c> object.
    ''' </summary>
    ''' <remarks>See also <see cref="xPLDevice.Status"/></remarks>
    Public Enum xPLDeviceStatus
        ''' <summary>
        ''' The Enabled property has been set to <c>False</c> and the device is not receiving nor sending any messages. Its been disconnected 
        ''' from the xPL network.
        ''' </summary>
        ''' <remarks></remarks>
        Offline
        ''' <summary>
        ''' The Enabled property has been set to <c>True</c> and the device is now sending heartbeats. Once an echo is received back from the 
        ''' xPL hub the status will go to <c>Online</c>.
        ''' </summary>
        ''' <remarks>When going to <c>Online</c> and <c>xPLStatusChange</c> event will be raised.</remarks>
        Connecting
        ''' <summary>
        ''' The Enabled property is set to <c>True</c> and heartbeats are being echoed back by the hub. The device is connected to the xPL network.
        ''' </summary>
        ''' <remarks>If an echo of sent heartbeats is not received within <c>XPL_MYECHO_TIMEOUT</c> seconds, status will go back to <c>Connecting</c> 
        ''' and a <c>xPLStatusChange</c> event will be raised.</remarks>
        Online
    End Enum

    ''' <summary>
    ''' Enumerator for indicating the type of xPLAddress; source or target.
    ''' </summary>
    ''' <remarks>The difference is that for a source address, the wildcards ("*") are not allowed.</remarks>
    Public Enum xPLAddressType
        Source
        Target
    End Enum

    ''' <summary>
    ''' Enumerator for the xPL config item type
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum xPLConfigTypes As Integer
        ''' <summary>
        ''' 'Config' requires the configuration value to be set upon initial configuration. This value cannot be modified once the xPL device has been configured. It is once only.
        ''' </summary>
        ''' <remarks>It MUST be set and CANNOT be changed afterwards. That it MUST be set, doesn't mean that it couldn't have an empty value.</remarks>
        xConfig = 0
        ''' <summary>
        ''' 'Reconf' requires the configuration value to be set upon initial configuration, it may be altered later.
        ''' </summary>
        ''' <remarks>It MUST be set and CAN be changed afterwards. That it MUST be set, doesn't mean that it couldn't have an empty value.</remarks>
        xReconf = 1
        ''' <summary>
        ''' 'Option' does not require the configuration value to be set upon initial configuration, it may be set or altered later.
        ''' </summary>
        ''' <remarks></remarks>
        xOption = 2
    End Enum

    ''' <summary>
    ''' Enumerator listing the three possible xPL string types. Each one has its own XPL_ALLOWED_xxxxx constant with
    ''' the allowed characters for that type.
    ''' </summary>
    ''' <remarks>Use the <c>IsValidxPL</c> function to verify strings.</remarks>
    Public Enum XPL_STRING_TYPES
        VendorAndDevice
        OtherElements
        Values
    End Enum

#End Region

#Region "Constants"

    ''' <summary>
    ''' used to avoid configuration files of different versions getting mixed up.
    ''' </summary>
    ''' <remarks>Value is used in the <c>GetState</c> and the <c>NewFromState</c> methods of the <c>xPLListener</c>
    ''' object as well as the <c>GetState</c> and <c>New</c> methods of the <c>xPLDevice</c> object to determine
    ''' what version of xpllib created the SavedState settings string.</remarks>
    Public Const XPL_LIB_VERSION As String = "5.4" 'when updating check all "State" related methods for updates!!
    ' Specifically;
    '        - Case statement in xPLListener.RestoreFromState(ByVal SavedState As String, ByVal RestoreEnabled As Boolean)
    '        - Case statement in xPLDevice.New(ByVal SavedState As String, ByVal RestoreEnabled As Boolean)
    ' Every version ever created MUST be in the cases, unless no longer supported




    '
    ' network constants
    '

    ''' <summary>
    ''' The base port that is used in the xPL communications protocol is 3865. All xPL devices communicate on this port.
    ''' </summary>
    ''' <remarks>Exception to this is the case where multiple devices are hosted on a single system, in that case only
    ''' sending is done to this port, incoming data is received from a local hub. See 
    ''' also <seealso cref="XPL_BASE_DYNAMIC_PORT"/>.</remarks>
    Public Const XPL_BASE_PORT As Integer = 3865
    ''' <summary>
    ''' The dynamic port range to be used if an xPL device is hosted on a system where the xPL hub is connecting to 
    ''' the XPL_BASE_PORT. Because of this, individual devices will connect to the hub on a dynamic port range from 
    ''' 50000 to 50256. The hub will forward incoming messages from the outside world to the dynamic port where
    ''' the device will be able to receive them.
    ''' </summary>
    ''' <remarks>See also <seealso cref="XPL_BASE_PORT"/>.</remarks>
    Public Const XPL_BASE_DYNAMIC_PORT As Integer = 50000
    ''' <summary>
    ''' If not configured otherwise (through registry xPL network settings), then listen to incoming data from 
    ''' IP addresses defined in <c>XPL_DEFAULT_LISTENTO</c> (the IP address where the message originates from)
    ''' </summary>
    ''' <remarks>valid: "ANY" or "ANY_LOCAL" or a comma separated list of IPs</remarks>
    Public Const XPL_DEFAULT_LISTENTO As String = "ANY"
    ''' <summary>
    ''' If not configured otherwise (through registry xPL network settings), then broadcast xPL messages
    ''' to the address defined in <c>XPL_DEFAULT_BROADCAST</c>
    ''' </summary>
    Public Const XPL_DEFAULT_BROADCAST As String = "255.255.255.255"
    ''' <summary>
    ''' If not configured otherwise (through registry xPL network settings), then listen for incoming data on
    ''' the network adapter with the address defined in <c>XPL_DEFAULT_BROADCAST</c> (the IP address the 
    ''' message was sent to)
    ''' </summary>
    ''' <remarks>valid: "ANY_LOCAL" or a comma separated list of IPs</remarks>
    Public Const XPL_DEFAULT_LISTENON As String = "ANY_LOCAL"
    ''' <summary>
    ''' The maximum supported overall size (in bytes, or ASCII characters) of a raw-xPL message.
    ''' </summary>
    ''' <remarks>Though the xPL specs said 1500, actual max size is 1472 to prevent fragmenting.</remarks>
    Public Const XPL_MAX_MSG_SIZE As Integer = 1472
    ''' <summary>
    ''' Buffer size for the receiving socket
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_SOCKET_BUFFER_SIZE As Integer = (32 * 1024)
    ''' <summary>
    ''' Default heartbeat timeout for an xPL device seen on the network
    ''' </summary>
    ''' <remarks>Specified in seconds</remarks>
    Public Const XPL_DEFAULT_HBEAT_TIMEOUT As Integer = XPL_DEFAULT_HBEAT * 2 + 60  ' in seconds; hbeat*2 + 1 minute

    '
    ' maximum numbers of filters and groups that a configuration tool may configure
    '

    ''' <summary>
    ''' Maximum number of filters for a configurable xPL device
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_MAX_FILTERS As Integer = 16
    ''' <summary>
    ''' Maximum number of groups for a configurable xPL device
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_MAX_GROUPS As Integer = 16

    '
    ' default, min, max HBEAT rate, all specified in seconds
    '

    ''' <summary>
    ''' Default heartbeat interval for an xPL device
    ''' </summary>
    ''' <remarks>Specified in seconds</remarks>
    Public Const XPL_DEFAULT_HBEAT As Integer = 5 * 60  ' in seconds
    ''' <summary>
    ''' Minimum heartbeat interval for an xPL device
    ''' </summary>
    ''' <remarks>Specified in seconds</remarks>
    Public Const XPL_MIN_HBEAT As Integer = 5 * 60 ' in seconds
    ''' <summary>
    ''' Maximum heartbeat interval for an xPL device
    ''' </summary>
    ''' <remarks>Specified in seconds</remarks>
    Public Const XPL_MAX_HBEAT As Integer = 9 * 60 ' in seconds
    ''' <summary>
    ''' Heartbeat interval to be used when no hub has been detected yet
    ''' </summary>
    ''' <remarks>Specified in seconds. This interval will be used for <c>XPL_NOHUB_TIMEOUT</c> seconds, if still no
    ''' hub has been detected the interval will be set at <c>XPL_NOHUB_LOWERFREQ</c>.</remarks>
    Public Const XPL_NOHUB_HBEAT As Integer = 3 ' in seconds 
    ''' <summary>
    ''' Timeout period for hub detection.
    ''' </summary>
    ''' <remarks>Specified in seconds. The heartbeat interval will be <c>XPL_NOHUB_HBEAT</c> seconds, until the 
    ''' timeout period expires, if still no hub has been detected the interval will be set at 
    ''' <c>XPL_NOHUB_LOWERFREQ</c>.</remarks>
    Public Const XPL_NOHUB_TIMEOUT As Integer = 2 * 60 'in seconds
    ''' <summary>
    ''' Heartbeat interval to be used if after expiration of the <c>XPL_NOHUB_TIMEOUT</c> period still no hub has been 
    ''' detected
    ''' </summary>
    ''' <remarks>Specified in seconds. The heartbeat interval will be <c>XPL_NOHUB_HBEAT</c> seconds, until the 
    ''' timeout period expires, if still no hub has been detected the interval will be set at 
    ''' <c>XPL_NOHUB_LOWERFREQ</c>.</remarks>
    Public Const XPL_NOHUB_LOWERFREQ As Integer = 30 ' in seconds
    ''' <summary>
    ''' Frequency of the timer for <c>xPLDevice</c> objects. In which heartbeats and other items are being handled.
    ''' </summary>
    ''' <remarks>Specified in seconds. This value must be equal or smaller than the lowest heartbeat interval.</remarks>
    Public Const XPL_TIMER_FREQ As Integer = XPL_NOHUB_HBEAT ' in seconds
    ''' <summary>
    ''' Timeout period for hearing the echos of sent messages. If no echo is received within this period it is assumed
    ''' that the network connection was lost and the <c>xPLDevice</c> object will inform the listener of the lost
    ''' connection.
    ''' </summary>
    ''' <remarks>Specified in seconds.</remarks>
    Public Const XPL_MYECHO_TIMEOUT As Integer = 5 ' within these seconds I expect my own echo, if not I lost my connection
    ''' <summary>
    ''' If a network issue has been arising then the xPLListener will reset the network configuration every 
    ''' <c>XPL_NETWORK_RESET_TIMEOUT</c> seconds until the network connection has been restored (this also applies if the 
    ''' network is functioning, but only on the local loopback address)
    ''' </summary>
    ''' <remarks>Specified in seconds.</remarks>
    Public Const XPL_NETWORK_RESET_TIMEOUT As Integer = 20 ' if there is a network issue, renew settings every xx seconds and retry


    '
    ' Valid characters in xPL message elements
    '

    ''' <summary>
    ''' Constant containing the characters that are allowed in the 'VendorID' and 'DeviceID'. These are lowercase characters a-z and numbers 0-9. This is the same as for the other structural elements except in this case the hyphen/dash character (ASCII 45) is not allowed.
    ''' </summary>
    ''' <remarks>This is the most restrictive set. See also <seealso cref="XPL_ALLOWED_ELEMENTS"/> and <seealso cref="XPL_UNALLOWED_VALUE"/>.</remarks>
    Public Const XPL_ALLOWED_VENDOR_DEVICE As String = "abcdefghijklmnopqrstuvwxyz0123456789"
    ''' <summary>
    ''' Constant containing the characters that are allowed in the structural elements (keynames, schemas, etc) of an xPL message. Allowed are lowercase a-z, numbers 0-9 and the hyphen/dash character (ASCII 45).
    ''' </summary>
    ''' <remarks>See also <seealso cref="XPL_ALLOWED_VENDOR_DEVICE"/> and <seealso cref="XPL_UNALLOWED_VALUE"/>.</remarks>
    Public Const XPL_ALLOWED_ELEMENTS As String = "abcdefghijklmnopqrstuvwxyz0123456789-"
    ''' <summary>
    ''' Constant containing the characters that are allowed in data/values in an xPL message. Allowed are ASCII 32 to 126.
    ''' Developers are urged to consider platform portability when constructing messages, and should pay special attention that characters with structural meaning such as "{", "}", "-" and "." are not misinterpreted.
    ''' </summary>
    ''' <remarks>See also <seealso cref="XPL_ALLOWED_VENDOR_DEVICE"/> and <seealso cref="XPL_ALLOWED_ELEMENTS"/>.</remarks>
    <Obsolete("UTF8 is now allowed, so use the opposite; XPL_UNALLOWED_VALUE")> _
    Public Const XPL_ALLOWED_VALUE As String = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    Private Shared _arrUnallowed As Byte() = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31}
    Private Shared _strUnallowed As String = String.Empty
    ''' <summary>
    ''' Constant containing the characters that are NOT allowed in data/values in an xPL message. Allowed are UTF8 characters.
    ''' Which means byte values 32 to 255, unallowed values are control characters, bytes 0 to 31.
    ''' Developers are urged to consider platform portability when constructing messages, and should pay special attention that characters with structural meaning such as "{", "}", "-" and "." are not misinterpreted.
    ''' </summary>
    ''' <remarks>See also <seealso cref="XPL_ALLOWED_VENDOR_DEVICE"/> and <seealso cref="XPL_ALLOWED_ELEMENTS"/>.</remarks>
    Public Shared ReadOnly Property XPL_UNALLOWED_VALUE() As String
        Get
            If _strUnallowed = String.Empty Then _strUnallowed = Text.Encoding.GetEncoding(1252).GetString(_arrUnallowed)
            Return _strUnallowed
        End Get
    End Property

    ''' <summary>
    ''' xPL message identifier for command messages
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_TYPELBL_CMND As String = "xpl-cmnd"
    ''' <summary>
    ''' xPL message identifier for status messages
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_TYPELBL_STAT As String = "xpl-stat"
    ''' <summary>
    ''' xPL message identifier for trigger messages
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_TYPELBL_TRIG As String = "xpl-trig"
    ''' <summary>
    ''' xPL message identifier wildcard for use in filters
    ''' </summary>
    ''' <remarks>This setting is not allowed for xPLMessages</remarks>
    Public Const XPL_TYPELBL_ANY As String = "*"

    ''' <summary>
    ''' Line separator character for xPL messages. Defined in the xPL protocol as a single ASCII 10 character.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_LF As String = Chr(10)
    ''' <summary>
    ''' Separator character used in State strings to separate individual values
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_STATESEP As Char = ","c


    '
    ' Vendor plugin constants
    '

    ''' <summary>
    ''' Vendorplugin list download location 1
    ''' </summary>
    ''' <remarks>The extension is set in the <seealso cref="XPL_PLUGIN_EXTENSION"/> constant</remarks>
    Public Const XPL_PLUGIN_URL1 As String = "http://www.xplproject.org.uk/plugins"          ' Main xPL site, by Ian
    ''' <summary>
    ''' Vendorplugin list download location 2
    ''' </summary>
    ''' <remarks>The extension is set in the <seealso cref="XPL_PLUGIN_EXTENSION"/> constant</remarks>
    Public Const XPL_PLUGIN_URL2 As String = "http://www.xPL4Java.org/plugins"               ' Gerry's copy
    ''' <summary>
    ''' Vendorplugin list download location 3
    ''' </summary>
    ''' <remarks>The extension is set in the <seealso cref="XPL_PLUGIN_EXTENSION"/> constant</remarks>
    Public Const XPL_PLUGIN_URL3 As String = "http://www.xplmonkey.com/downloads/plugins"    ' Mal's copy
    ''' <summary>
    ''' Vendorplugin list extension to be used for the plugin and list downloads, also used for the
    ''' local pluginstore file, see <seealso cref="XPL_PLUGINSTORE_PATH"/>.
    ''' </summary>
    ''' <remarks>The dot ('.') preceeding the extension is included.</remarks>
    Public Const XPL_PLUGIN_EXTENSION As String = ".xml"
    ''' <summary>
    ''' The relative path to the pluginstore. The base path is the system directory 'Common Application Data'.
    ''' </summary>
    ''' <remarks>The path includes the filename, but not the extension. The extension is 
    ''' set in the <seealso cref="XPL_PLUGIN_EXTENSION"/> constant.</remarks>
    Public Const XPL_PLUGINSTORE_PATH As String = "\xPL\xPLLib\PluginStore"
    ''' <summary>
    ''' Version of the PluginStore created by the xPLPlugin object
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_PLUGINSTORE_VERSION As String = "1.0"


    '
    ' Fragmentation constants
    '

    ''' <summary>
    ''' The maximum counter size for the fragmented message ID's. ID's in fragmented messages are generated as a 
    ''' rotating counter, this value is the maximum after which the value resets to 0.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_FRAGMENT_COUNTER_MAX As Integer = 99
    ''' <summary>
    ''' The maximum number of fragments for a single message supported.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_FRAGMENT_MAX As Integer = 99
    ''' <summary>
    ''' How long should a fragmented message be retained for retransmission if requested by other 
    ''' devices. Value in milliseconds.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_FRAGMENT_SEND_RETAIN As Integer = 20000
    ''' <summary>
    ''' Timeout value, after receiving the last fragment-message, after which a request for the 
    ''' remaining fragments will be send (if the overall message remains incomplete). Value in milliseconds.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_FRAGMENT_REQUEST_AFTER As Integer = 3000
    ''' <summary>
    ''' If a resend of fragments was requested, this value is the timeout after which the resend request is 
    ''' considered failed (if no new fragments arrived) and the message will be disposed of.
    ''' </summary>
    ''' <remarks></remarks>
    Public Const XPL_FRAGMENT_REQUEST_TIMEOUT As Integer = 5000

#End Region

#Region "Graphics"
    ''' <returns>The xPL logo icon</returns>
    ''' <remarks>
    ''' <example>This sample shows how to set the <c>Icon</c> property of a form to the xPL icon.
    ''' <code>
    ''' Form1.Icon = xPL.xPL_Base.XPL_Icon
    ''' </code>
    ''' </example>
    ''' </remarks>
    Public Shared ReadOnly Property XPL_Icon() As Drawing.Icon
        Get
            Return My.Resources.xplicon
        End Get
    End Property

#End Region

#Region "Error logging"

    '
    ' Error logging
    '

    ''' <summary>
    ''' Holds the eventlog where errors should be logged to.
    ''' </summary>
    ''' <remarks>Errors can be logged using the <c>LogError</c> method. If set to <c>Nothing</c>, then no errors will
    ''' be logged. <seealso cref="xPLErrorLogFile"/></remarks>
    Public Shared xPLErrorEventLog As EventLog = Nothing
    ''' <summary>
    ''' Holds the logfile where errors should be logged to.
    ''' </summary>
    ''' <remarks>Errors can be logged using the <c>LogError</c> method. If set to an empty string, then no errors will
    ''' be logged. <seealso cref="xPLErrorEventLog"/></remarks>
    Public Shared xPLErrorLogFile As String = ""

    ''' <summary>
    ''' Logs a string into the errorlog and logfile, and optionally, if the DEBUG compiler directive is present, to the 
    ''' immediate window in Visual Studio
    ''' </summary>
    ''' <param name="Source">The source of the error (eg. device address, method or function).</param>
    ''' <param name="Message">String containing the error message to be logged.</param>
    ''' <remarks>use <see cref="xPLErrorEventLog"/> to set the log where to write the message and/or set the
    ''' <see cref="xPLErrorLogFile"/> to write the message to an error logfile.</remarks>
    Public Shared Sub LogError(ByVal Source As String, ByVal Message As String, Optional ByVal MsgType As System.Diagnostics.EventLogEntryType = EventLogEntryType.Information)
        If Not xPLErrorEventLog Is Nothing Then
            xPLErrorEventLog.WriteEntry(Source & ": " & Message, MsgType)
        End If
        If Not xPLErrorLogFile Is Nothing Then
            If Not xPLErrorLogFile = "" Then
                Dim fs As StreamWriter = Nothing
                Try
                    fs = File.AppendText(xPLErrorLogFile)
                    fs.WriteLine(DateTime.Now().ToString("dd-MMM-yy HH:mm:ss") & " " & Source & ": " & Message)
                Finally
                    If Not fs Is Nothing Then fs.Close()
                End Try
            End If
        End If
#If DEBUG Then
        Debug.Print(Source & ": " & Message)
#End If
    End Sub

#End Region

#Region "State encoding/decoding"

    ''' <summary>
    ''' Allows for encoding of strings into SavedState string
    ''' </summary>
    ''' <param name="value">input string to be encoded</param>
    ''' <returns>encoded string</returns>
    ''' <remarks>In an encoded string all characters have been replaced by the Base64 encoded 
    ''' equivalent. This ensures that the result will have only the Base64 characters, so character 
    ''' <see cref="XPL_STATESEP"/> can be used as a separator for concatenating values. When decoding a
    ''' SavedState string the <c>Split</c> function can be used to return the individual values 
    ''' eg. <c>ResultArray = StateValue.Split(XPL_STATESEP)</c> and individual values can be decoded 
    ''' using the <see cref="StateDecode"/> method, eg. <c>value1 = StateDecode(ResultArray(0))</c>
    ''' </remarks>
    Public Shared Function StateEncode(ByVal value As String) As String
        Dim s As String = ""
        If value Is Nothing Then value = ""

        s = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(value))

        Return s
    End Function

    ''' <summary>
    ''' Allows for decoding of strings from SavedState string
    ''' </summary>
    ''' <param name="StateValue">SavedState string to be decoded</param>
    ''' <returns>decoded string</returns>
    ''' <remarks>See <see cref="StateEncode"/> for more details.</remarks>
    Public Shared Function StateDecode(ByVal StateValue As String) As String
        Dim s As String = ""
        If StateValue Is Nothing Then StateValue = ""

        s = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(StateValue))

        Return s
    End Function

    ''' <summary>
    ''' Returns the application version that created the SavedState string. This can be used when a newer application version has different xPL Device
    ''' settings. After recreating the device, the upgrade modifications can be made to enable a smooth transition.
    ''' </summary>
    ''' <param name="SavedState">SavedState string that was created to store the settings</param>
    ''' <returns>Application version string as supplied to the <see cref="StateEncode"/> method.</returns>
    ''' <remarks></remarks>
    Public Shared Function StateAppVersion(ByVal SavedState As String) As String
        Dim lst() As String
        Dim xVersion As String
        Dim aVersion As String = ""

        If SavedState <> "" Then
            Try

                ' split string in settings for individual devices
                lst = SavedState.Split(XPL_STATESEP)
                ' get version of xpllib that created it
                xVersion = StateDecode(lst(0))
                ' get version of the application that created it
                aVersion = StateDecode(lst(1))
            Catch ex As Exception
            End Try
        End If
        Return aVersion
    End Function

    ''' <summary>
    ''' Returns the xPLLib version that created the SavedState string.
    ''' </summary>
    ''' <param name="SavedState">SavedState string that was created to store the settings</param>
    ''' <returns>xPLLib version at the time of creating the SavedState by the <see cref="StateEncode"/> method.</returns>
    ''' <remarks></remarks>
    Public Shared Function StatexPLLibVersion(ByVal SavedState As String) As String
        Dim lst() As String
        Dim xVersion As String = ""

        If SavedState <> "" Then
            Try

                ' split string in settings for individual devices
                lst = SavedState.Split(XPL_STATESEP)
                ' get version of xpllib that created it
                xVersion = StateDecode(lst(0))
            Catch ex As Exception
            End Try
        End If
        Return xVersion
    End Function

#End Region

#Region "Other..."

    Friend Shared Function HexDump(ByRef s As String) As String
        Dim h As New StringBuilder
        Dim ca As Char() = s.ToCharArray()
        Dim spacecount As Integer = 0
        Dim linecount As Integer = 0
        For i As Integer = 0 To ca.Length() - 1
            h.Append(Convert.ToInt32(ca(i)).ToString("X2"))
            spacecount += 1
            If spacecount = 5 Then
                h.Append(" ")
                spacecount = 0
                linecount += 1
                If linecount = 4 Then
                    h.Append(vbCrLf)
                    linecount = 0
                End If
            End If
        Next
        Return h.ToString()

    End Function


    ''' <summary>
    ''' Gets the assembly version numbers consisting of Major, Minor, Build and Revision numbers, separated by '.' (dot) characters
    ''' </summary>
    ''' <param name="levels">Number of levels to include; 1 to 4; 1) only includes Major, 4) includes Major, Minor, Build and Revision</param>
    ''' <returns>Assembly version numbers consisting of Major, Minor, Build and Revision numbers, separated by '.' (dot) characters</returns>
    ''' <remarks>Returns the values from the main assembly, not the xPLLib version numbers.</remarks>
    Public Shared Function GetVersionNumber(Optional ByVal levels As Byte = 4) As String
        Dim Result As String
        If levels < 1 Or levels > 4 Then Throw New ArgumentOutOfRangeException("levels", "levels parameter must have a value between 1 and 4. Current value: " & CStr(levels))
        Try
            Dim v As Version = System.Reflection.Assembly.GetEntryAssembly().GetName().Version
            Result = CStr(v.Major)
            If levels > 1 Then Result = Result & "." & v.Minor
            If levels > 2 Then Result = Result & "." & v.Build
            If levels > 3 Then Result = Result & "." & v.Revision
        Catch ex As Exception
            Result = "0.0.0.0"
        End Try
        Return Result
    End Function

    Friend Shared Sub WaitForRandomPeriod(Optional ByVal MinWait As Integer = 1000, Optional ByVal MaxWait As Integer = 3000)
        ' Compute a random number between 1000 and 3000
        Dim R As New Random
        Dim Period As Integer = R.Next(MinWait, MaxWait)

        ' Wait for the specified period
        Thread.Sleep(Period)
    End Sub

    Friend Shared Function GenerateRandomString(ByVal PossibleChars As String, ByVal Length As Integer) As String
        Dim n As Integer
        Dim result As String
        result = ""
        Randomize()
        For n = 1 To Length
            result = result & Mid(PossibleChars, CInt(Int(PossibleChars.Length * Rnd() + 1)), 1)
        Next
        Return result
    End Function

    ''' <summary>
    ''' Verifies a string to be a valid xPL value. Verification against minimum and maximum length, and characters allowed.
    ''' </summary>
    ''' <param name="CheckMe">The string to be verified as a valid xPL string</param>
    ''' <param name="min">required minimum length</param>
    ''' <param name="max">allowed maximum length (set to 0 to allow any length)</param>
    ''' <param name="sType">The type of xPL element to verify against</param>
    ''' <returns><c>True</c> if the string is valid, <c>False</c> otherwise</returns>
    ''' <remarks>This function will NOT automatically convert to lowercase</remarks>
    Public Shared Function IsValidxPL(ByVal CheckMe As String, ByVal min As Integer, ByVal max As Integer, ByVal sType As XPL_STRING_TYPES) As Boolean
        Dim result As Boolean = False
        Select Case sType
            Case XPL_STRING_TYPES.VendorAndDevice
                result = IsValidIdentifier(CheckMe, min, max, XPL_ALLOWED_VENDOR_DEVICE, "")
            Case XPL_STRING_TYPES.OtherElements
                result = IsValidIdentifier(CheckMe, min, max, XPL_ALLOWED_ELEMENTS, "")
            Case XPL_STRING_TYPES.Values
                result = IsValidIdentifier(CheckMe, min, max, "", XPL_UNALLOWED_VALUE)
        End Select
        Return result
    End Function

    ''' <summary>
    ''' Removes any invalid characters from an xPL string
    ''' </summary>
    ''' <param name="s">String to clean up</param>
    ''' <param name="stype">Type of xPL elements to be generated (determines what characters are allowed)</param>
    ''' <returns>String with all unallowed characters removed</returns>
    ''' <remarks>Any input is first converted to lowercase. Note that the length of the result is not adjusted
    ''' to within allowed limits</remarks>
    Public Shared Function RemoveInvalidxPLchars(ByVal s As String, ByVal stype As XPL_STRING_TYPES) As String
        Dim n As Integer
        Dim valid As String = ""
        Dim result As String = ""
        Dim c As Char
        Select Case stype
            Case XPL_STRING_TYPES.VendorAndDevice
                valid = XPL_ALLOWED_VENDOR_DEVICE
                s = s.ToLower
                For n = 1 To s.Length
                    c = s.Chars(n - 1)
                    If valid.IndexOf(c) <> -1 Then  ' found it, so copy to result
                        result += c
                    End If
                Next
            Case XPL_STRING_TYPES.OtherElements
                valid = XPL_ALLOWED_ELEMENTS
                s = s.ToLower
                For n = 1 To s.Length
                    c = s.Chars(n - 1)
                    If valid.IndexOf(c) <> -1 Then  ' found it, so copy to result
                        result += c
                    End If
                Next
            Case XPL_STRING_TYPES.Values
                valid = XPL_UNALLOWED_VALUE     ' <-- OPPOSITE!! UNallowed characters
                For n = 1 To s.Length
                    c = s.Chars(n - 1)
                    If valid.IndexOf(c) = -1 Then  ' NOT found, so copy to result
                        result += c
                    End If
                Next
        End Select
        Return result
    End Function

    Friend Shared Function IsValidIdentifier(ByVal CheckMe As String, ByVal min As Integer, ByVal max As Integer, _
                                            Optional ByVal AllowedChars As String = "", Optional ByVal UnallowedChars As String = "") As Boolean
        Dim myChar As Char
        Dim result As Boolean = True
        ' check length
        If CheckMe.Length < min Or (CheckMe.Length > max And max <> 0) Then
            result = False
        End If
        ' check characters 
        For Each myChar In CheckMe
            If AllowedChars <> "" AndAlso AllowedChars.IndexOf(myChar) = -1 Then result = False ' not found in allowed set
            If UnallowedChars <> "" AndAlso UnallowedChars.IndexOf(myChar) <> -1 Then result = False ' found in unallowed set
        Next
        Return result
    End Function

#End Region

End Class
