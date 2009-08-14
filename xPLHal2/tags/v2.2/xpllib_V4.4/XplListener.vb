'* xPL Library for .NET
'* xplListener Class
'*
'* Version 4.4
'*
'* Copyright (c) 2008 Tom Van den Panhuyzen
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
Imports System.Collections
Imports System.Threading


<Flags()> Public Enum XplMessageTypes As Byte
    None = 0
    Any = 255
    Command = 1
    Status = 2
    Trigger = 4
End Enum

Public Enum xplConfigTypes As Integer
    xConfig = 0
    xReconf = 1
    xOption = 2
End Enum

Public Structure XplSchema
    Dim msgClass As String
    Dim msgType As String
End Structure

Public Structure XplSource
    Dim Vendor As String
    Dim Device As String
    Dim Instance As String
End Structure

Public Class XplListener
    Implements IDisposable

#Region "Shared: ListenOnIp is used by other classes too (xplmsg)."
    Private Shared sListenOn As String
    Friend Shared Function sListenOnIP() As String
        Dim s As String
        Dim RegKey As RegistryKey = Nothing

        If sListenOn Is Nothing OrElse sListenOn.Length = 0 Then
            Try
                RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
                s = CStr(RegKey.GetValue("ListenOnAddress", "ANY_LOCAL"))
            Catch ex As Exception
                s = "ANY_LOCAL"
            Finally
                If Not RegKey Is Nothing Then
                    RegKey.Close()
                End If
            End Try

            sListenOn = s
        End If

        Return sListenOn
    End Function
#End Region

    'used to avoid configuration files of different versions getting mixed up:
    Public Const XPL_LIB_VERSION As String = "4.4"

    Private Const XPL_BASE_PORT As Integer = 3865
    Private Const XPL_BASE_DYNAMIC_PORT As Integer = 50000
    Private Const MAX_XPL_MSG_SIZE As Integer = 1500

  ' maximum numbers of filters and groups that a configuration tool may configure
    Private Const MAX_FILTERS As Integer = 16
    Private Const MAX_GROUPS As Integer = 16

  ' default, min, max HBEAT rate
    Private Const DEFAULT_HBEAT As Integer = 5
    Private Const MIN_HBEAT As Integer = 5
    Private Const MAX_HBEAT As Integer = 9
    Private Const NOHUB_HBEAT As Integer = 3  'seconds between HBEATs until hub is detected
    Private Const NOHUB_LOWERFREQ As Integer = 30  'lower frequency probing for hub
    Private Const NOHUB_TIMEOUT As Integer = 120  'after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ
    Private mHubFound As Boolean
    Private mNoHubTimerCount As Integer
    Private mNoHubPastInitialProbe As Boolean

    Private Const TIMER_FREQ As Integer = 60000  'normal timer frequency, used to raise timer event and to control hbeat

  ' if not configured otherwise, then listen to incoming data from IP addresses defined in DEFAULT_LISTENTOIP
  ' valid: ANY or ANY_LOCAL or a list of IPs
    Private Const DEFAULT_LISTENTOIP As String = "ANY"

    ' Socket to handle incoming messages
    Private sockIncoming As Socket

    ' Endpoint for incoming messages
    Private epIncoming As IPEndPoint

    ' Buffer to store incoming messages
    Private XPL_Buff(MAX_XPL_MSG_SIZE) As Byte

  ' Variable to hold version string
  Private VersionNumber As String

  ' Local IPAddress(es)
    Private LocalIP As ArrayList

    ' Timer to allow sending of heartbeat messages
    Private XPLTimer As Timers.Timer

    ' Number of minutes since last heartbeat
    Private HBeat_Count As Integer

    ' Port used for listening
    Private XPL_Portnum As Integer

    Private bListening As Boolean
    Private bConfigOnly As Boolean
    'Private WriteDebugInfo As Boolean
    Private mVendorId As String
    Private mDeviceId As String
    Private mFilters As XplFilters
    Private disposing As Boolean = False
    Private Shared mEventLog As EventLog
    Private mListenTo() As String

    Public ConfigItems As XplConfigItems

    '/* a developer can get his say in the data in the HBEAT */
    Public Delegate Function HBeatItemsCallback() As String
    Public XplHBeatItems As HBeatItemsCallback

    '/* a developer can get a call once and a while (every min to be exact), no idea how this could be useful
    Public Delegate Sub OnTimerCallback()
    Public XplOnTimer As OnTimerCallback

    '/* Events */
    Public Event XplMessageReceived(ByVal sender As Object, ByVal e As XplEventArgs)
    Public Event XplConfigDone(ByVal e As XplLoadStateEventArgs)   'raised the first time the xpl app is configured
    Public Event XplReConfigDone(ByVal e As XplLoadStateEventArgs) 'raised when the app was configured but receives new config items
    Public Event XplJoinedxPLNetwork() 'raised when the app has detected a hub
    Public Event XplConfigItemDone(ByVal itemName As String, ByVal itemValue As String, ByVal e As XplLoadStateEventArgs)


    '/* Event Data */
    Public Class XplEventArgs
        Inherits EventArgs

        Public XplMsg As XplMsg

        Public Sub New(ByVal x As XplMsg)
            XplMsg = x
        End Sub
    End Class

    Public Class XplLoadStateEventArgs
        Inherits EventArgs

        Public ConfigurationLoadedFromXML As Boolean

        Public Sub New(ByVal x As Boolean)
            ConfigurationLoadedFromXML = x
        End Sub
    End Class

    Public ReadOnly Property Port() As Integer
        Get
            Return (XPL_Portnum)
        End Get
    End Property

    Public ReadOnly Property AwaitingConfiguration() As Boolean
        Get
            Return (bConfigOnly)
        End Get
    End Property

    Public ReadOnly Property VendorId() As String
        Get
            Return mVendorId
        End Get
    End Property

    Public ReadOnly Property DeviceId() As String
        Get
            Return mDeviceId
        End Get
    End Property

    Public WriteOnly Property ErrorEventLog() As EventLog
        Set(ByVal Value As EventLog)
            mEventLog = Value
        End Set
    End Property

    Public ReadOnly Property JoinedxPLNetwork() As Boolean
        Get
            Return mHubFound
        End Get
    End Property

#Region "Construction, initialisation and destruction of XplListener"

    Public Sub New(ByVal VendorId As String, ByVal DeviceId As String)
        BasicInit(VendorId, DeviceId, Nothing)
    End Sub

    Public Sub New(ByVal VendorId As String, ByVal DeviceId As String, ByVal ThisEventLog As EventLog)
        BasicInit(VendorId, DeviceId, ThisEventLog)
    End Sub

    Private Sub BasicInit(ByVal VendorId As String, ByVal DeviceId As String, ByVal ThisEventLog As EventLog)
        VersionNumber = GetVersionNumber()
        If VendorId.Length() = 0 Or DeviceId.Length() = 0 Then
            Throw New Exception("You must pass the XPL Vendor and Device identifiers for this instance to the constructor when creating a new instance of the xplListener object")
        End If
        mVendorId = VendorId
        mDeviceId = DeviceId
        bListening = False
        bConfigOnly = False
        mHubFound = False
        mNoHubTimerCount = 0
        mNoHubPastInitialProbe = False
        mEventLog = ThisEventLog

        'find the local IP Addresses
        LocalIP = LocalIPAddresses(mEventLog)

        ConfigItems = New XplConfigItems
        mFilters = New XplFilters(ConfigItems)
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        disposing = True

        Try

            If bListening Then
                If mHubFound Then
                    'send a last HBEAT
                    SendHeartbeatMessage(True)
                End If
                sockIncoming.Shutdown(SocketShutdown.Both)
                sockIncoming.Close()
            End If

        Catch
        End Try

    End Sub

    Protected Overrides Sub Finalize()
        Try
            If Not disposing Then  'hm, somebody did not call Dispose
                Me.Dispose()       'probably our socket is disposed but try anyway to send a hbeat and cleanup nicely
            End If
        Catch ex As Exception

        Finally
            MyBase.Finalize()
        End Try
    End Sub

#End Region

#Region "Configuration Items"


    '/****************************************************************************/
    '/* XplConfigItem                                                            */
    '/*                                                                          */
    '/* This class holds data for a single configuration element.                */
    '/* A configuration element has a one or more distinct Values associated     */
    '/* with a Name and has an associated Configuration Type.                    */
    '/*                                                                          */
    '/* 2 special cases:                                                         */
    '/* - Filters are stored in the item named "filter".                         */
    '/* - Groups are stored in the item named "group".                           */
    '/*                                                                          */
    '/* MaxValues is the maximum number of values the configuration tool (HAL    */
    '/* probably) should allow the user to enter.  It is not used to check the   */
    '/* actual numbers of values stored.                                         */
    '/*                                                                          */
    '/****************************************************************************/

    Public Class XplConfigItem
        Private mName As String
        Private mValue() As String
        Private mMaxValues As Integer
        Private mConfigType As xplConfigTypes
        'Private mIsMultivalue As Boolean

        Public Sub New(ByVal itemName As String, ByVal itemValue As String, ByVal itemtype As xplConfigTypes, ByVal maxValues As Integer)
            ReDim mValue(0)
            mName = itemName
            mValue(0) = itemValue
            mConfigType = itemtype
            mMaxValues = maxValues
        End Sub

        Public ReadOnly Property Name() As String
            Get
                Return mName
            End Get
        End Property

        Public Property Value() As String
            Get
                Return mValue(0)
            End Get
            Set(ByVal Value As String)
                mValue(0) = Value
            End Set
        End Property

        Public Property Value(ByVal idx As Integer) As String
            Get
                Return mValue(idx)
            End Get
            Set(ByVal Value As String)
                mValue(idx) = Value
            End Set
        End Property

        'necessary to stay compatible with old implementation that returns groups as a string()
        Public ReadOnly Property Values() As String()
            Get
                Return mValue
            End Get
        End Property

        Public Property MaxValues() As Integer
            Get
                Return mMaxValues
            End Get
            Set(ByVal Value As Integer)
                mMaxValues = Value
            End Set
        End Property

        'the number of values stored under this item
        Public ReadOnly Property ValueCount() As Integer
            Get
                If mValue.Length() = 1 And mValue(0).Length = 0 Then
                    Return 0
                Else
                    Return mValue.Length()
                End If
            End Get
        End Property

        Public ReadOnly Property ConfigType() As xplConfigTypes
            Get
                Return mConfigType
            End Get
        End Property

        Public Sub AddValue(ByVal itemValue As String)
            'if there is no value yet, put it in position 0
            If mValue(0).Length = 0 Then
                mValue(0) = itemValue
            Else
                'do not allow the same value twice
                Dim idx As Integer = -1
                For i As Integer = 0 To mValue.Length - 1
                    If mValue(i) = itemValue Then
                        idx = i
                        Exit For
                    End If
                Next
                If idx < 0 Then  'not found, then add
                    ReDim Preserve mValue(mValue.Length)
                    mValue(mValue.Length - 1) = itemValue
                End If
            End If
        End Sub

        Public Sub ResetValues()
            ReDim mValue(0)
            mValue(0) = String.Empty
        End Sub
    End Class


    '/****************************************************************************/
    '/* XplConfigItems                                                           */
    '/*                                                                          */
    '/* This class is a collection of XplConfigItems defined above.              */
    '/* It stores keys and items in 2 seperate ArrayLists.                      */
    '/* 2 ways of finding an element in the XplConfigItems collection:           */
    '/* - using the key                                                          */
    '/* - using an integer index: this returns the elements in the original      */
    '/*   order                                                                  */
    '/*                                                                          */
    '/****************************************************************************/

    Public Class XplConfigItems

        Private mKeys As ArrayList
        Private mConfigItemList As ArrayList

        Public Sub New()
            mKeys = New ArrayList(20)
            mConfigItemList = New ArrayList(20)

            'add entries that are defined by the xPL protocol: these must exists in this particular order
            Me.Define("newconf", xplConfigTypes.xReconf, 1)
            Me.Define("interval", CStr(DEFAULT_HBEAT), xplConfigTypes.xReconf, 1)
            Me.Define("filter", MAX_FILTERS)
            Me.Define("group", MAX_GROUPS)
        End Sub

        'the "ConfigItem" below would in a standard implementation be called "Item"
        Default Public ReadOnly Property Item(ByVal key As String) As XplConfigItem
            Get
                Return CType(mConfigItemList(mKeys.IndexOf(key.ToLower())), XplConfigItem)
            End Get
        End Property

        Default Public ReadOnly Property Item(ByVal idx As Integer) As XplConfigItem
            Get
                Return CType(mConfigItemList(idx), XplConfigItem)
            End Get
        End Property

        Public ReadOnly Property Count() As Integer
            Get
                Return mKeys.Count
            End Get
        End Property

        Public Sub Define(ByVal itemName As String, ByVal itemDefaultValue As String, ByVal itemtype As xplConfigTypes, ByVal MaxValues As Integer)
            Dim ci As XplConfigItem
            If Not mKeys.Contains(itemName.ToLower()) Then
                ci = New XplConfigItem(itemName, itemDefaultValue, itemtype, MaxValues)
                mKeys.Add(itemName.ToLower())
                mConfigItemList.Add(ci)
            Else
                LogError(itemName + " already defined.")
            End If
        End Sub

        Public Sub Define(ByVal itemName As String, ByVal itemtype As xplConfigTypes, ByVal MaxValues As Integer)
            Me.Define(itemName, "", itemtype, MaxValues)
        End Sub

        Public Sub Define(ByVal itemName As String, ByVal MaxValues As Integer)
            Me.Define(itemName, "", xplConfigTypes.xOption, MaxValues)
        End Sub

        Public Sub Define(ByVal itemName As String)
            Me.Define(itemName, "", xplConfigTypes.xOption, 1)
        End Sub

        Public Sub Define(ByVal itemName As String, ByVal itemDefaultValue As String)
            Me.Define(itemName, itemDefaultValue, xplConfigTypes.xOption, 1)
        End Sub

        Public Sub ResetAllConfigItemValues()
            For Each ci As XplConfigItem In mConfigItemList
                ci.ResetValues()
            Next
        End Sub
    End Class


    '/****************************************************************************/
    '/* XplFilters                                                               */
    '/*                                                                          */
    '/* This class reads and stores XplFilter objects in the XplConfigItems      */
    '/* collection.  From the outside it looks like a normal collection though.  */
    '/* Note that the constructor needs a reference to the XplConfigItems.       */
    '/*                                                                          */
    '/****************************************************************************/

    Public Class XplFilters
        ' Filters are stored in ConfigItems
        Private mConfigItems As XplConfigItems

        ' If match target is false, all messages will be
        ' passed through to the application, even if they are not 
        ' targetted at it's source address.
        Private mMatchTarget As Boolean

        ' If AlwaysPassMessages is true, xPL messages will
        ' always be passed to the application, even when the listener
        ' is waiting to be configured.
        Private mAlwaysPassMessages As Boolean

        Public Sub New(ByVal ConfigItems As XplConfigItems)
            mConfigItems = ConfigItems
            mMatchTarget = True
            mAlwaysPassMessages = False
        End Sub

        Public ReadOnly Property Count() As Integer
            'the number of filters = the number of values stored under the key "filter"
            Get
                Return mConfigItems("filter").ValueCount
            End Get
        End Property

        Public Property AlwaysPassMessages() As Boolean
            Get
                Return mAlwaysPassMessages
            End Get
            Set(ByVal Value As Boolean)
                mAlwaysPassMessages = Value
            End Set
        End Property

        Public Property MatchTarget() As Boolean
            Get
                Return mMatchTarget
            End Get
            Set(ByVal Value As Boolean)
                mMatchTarget = Value
            End Set
        End Property

        Public Sub Add(ByVal f As XplFilter)
            mConfigItems("filter").AddValue(f.ToString())
        End Sub

        Public Function Item(ByVal index As Integer) As XplFilter
            Return Str2Filter(mConfigItems("filter").Value(index))
        End Function
    End Class


    '/****************************************************************************/
    '/* XplFilter                                                                */
    '/*                                                                          */
    '/* This class stores data for an XplFilter object.                          */
    '/* The ToString() function returns the format used in the communication     */
    '/* of the configuration settings.                                           */
    '/*                                                                          */
    '/****************************************************************************/

    Public Class XplFilter
        Public MessageType As XplMessageTypes
        Public Source As XplSource
        Public Schema As XplSchema

        Public Sub New()
            MessageType = 0
            Source.Vendor = ""
            Source.Device = ""
            Source.Instance = ""
            Schema.msgClass = ""
            Schema.msgType = ""
        End Sub

        Public Sub New(ByVal t As XplMessageTypes, ByVal Source_Vendor As String, ByVal Source_Device As String, ByVal Source_Instance As String, ByVal Schema_Class As String, ByVal Schema_Type As String)
            MessageType = t
            Source.Vendor = Source_Vendor.ToLower()
            Source.Device = Source_Device.ToLower()
            Source.Instance = Source_Instance.ToLower()
            Schema.msgClass = Schema_Class.ToLower()
            Schema.msgType = Schema_Type.ToLower()
        End Sub

        Public Overrides Function ToString() As String
            Return StrMsgType2Cmnd(MessageType) & "." & Source.Vendor & "." & Source.Device & "." & Source.Instance & "." & Schema.msgClass & "." & Schema.msgType
        End Function

    End Class

    'Filters are available as XplFilters...
    Public ReadOnly Property Filters() As XplFilters
        Get
            Return mFilters
        End Get
    End Property

    '... while groups are made available as string()
    'got to stay compatible with old interface.
    Public ReadOnly Property Groups() As String()
        Get
            If ConfigItems("group").ValueCount = 0 Then 'no groups
                'if there are no groups in the ConfigItems, return an empty array
                Dim r() As String = {}
                Return r
            Else
                Return ConfigItems("group").Values
            End If
        End Get
    End Property

    'Storing "newconf" in the ConfigItems makes restoring/saving state and communicating config msgs easier
    Public Property InstanceName() As String
        Get
            Return ConfigItems("newconf").Value.ToLower()
        End Get
        Set(ByVal Value As String)
            ConfigItems("newconf").Value = Value
        End Set
    End Property


    'Number of minutes between heartbeat messages
    'Storing "interval" in the ConfigItems makes restoring/saving state and communicating config msgs easier
    Public Property HBeat_Interval() As Integer
        Get
            Try
                Return Int32.Parse(ConfigItems("interval").Value)
            Catch ex As Exception
                'no heartbeat in the collection, better have one
                HBeat_Interval = DEFAULT_HBEAT
                Return DEFAULT_HBEAT
            End Try
        End Get
        Set(ByVal Value As Integer)
            ConfigItems("interval").Value = Value.ToString()
        End Set
    End Property

    Private ReadOnly Property ListenOnIP_IP() As IPAddress
        Get
            Dim ip As IPAddress
            Dim s As String


            s = ListenOnIP

            If s = "ANY_LOCAL" Then
                ip = IPAddress.Any
            Else
                Try
                    ip = IPAddress.Parse(s)
                Catch ex As Exception
                    Throw New Exception("Could not decode to valid IPAddress: " & s, ex)
                End Try
            End If

            Return ip
        End Get
    End Property

    Private ReadOnly Property ListenOnIP() As String
        Get
            'implemented in the shared function sListenOnIP
            Return sListenOnIP()
        End Get
    End Property

    Private ReadOnly Property ListenToIPs() As String()
        Get
            Dim s As String
            Dim RegKey As RegistryKey = Nothing

            If mListenTo Is Nothing OrElse mListenTo.Length = 0 Then
                Try
                    RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
                    s = CStr(RegKey.GetValue("ListenToAddresses", DEFAULT_LISTENTOIP))
                Catch ex As Exception
                    s = DEFAULT_LISTENTOIP
                Finally
                    If Not RegKey Is Nothing Then
                        RegKey.Close()
                    End If
                End Try

                mListenTo = s.Split(","c)

                For i As Integer = 0 To mListenTo.Length - 1
                    mListenTo(i) = mListenTo(i).Trim()
                Next
            End If

            Return mListenTo
        End Get
    End Property

#End Region

#Region "IP Communication, socket, msg sending"

    Private Sub InitSocket()
        Dim Portnum As Integer

        XPL_Portnum = XPL_BASE_DYNAMIC_PORT
        sockIncoming = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)

        Portnum = XPL_Portnum
        ' Bind to the port for listening
        While Portnum < XPL_BASE_DYNAMIC_PORT + 512 And Not Portnum = 0
            Try
                sockIncoming.Bind(New IPEndPoint(ListenOnIP_IP, Portnum))
                XPL_Portnum = Portnum
                Portnum = 0
            Catch ex As Exception
                Portnum = Portnum + 1
                sockIncoming = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
            End Try
        End While

        If Portnum = XPL_BASE_DYNAMIC_PORT + 512 Then
            Throw New Exception("Unable to bind to a free UDP port for listening.")
        End If

        XPLTimer = New Timers.Timer
        XPLTimer.Interval = NOHUB_HBEAT * 1000

        XPLTimer.AutoReset = False
        AddHandler XPLTimer.Elapsed, AddressOf XPLTimerElapsed
        XPLTimer.Enabled = True

        ' Add a listener for incoming data
        epIncoming = New IPEndPoint(IPAddress.Any, 0)
        sockIncoming.BeginReceiveFrom(XPL_Buff, 0, MAX_XPL_MSG_SIZE, SocketFlags.None, CType(epIncoming, EndPoint), AddressOf Me.ReceiveData, Nothing)
        bListening = True

        ' Force transmission of a heartbeat
        XPLTimerElapsed(Nothing, Nothing)
    End Sub

    Private Sub ReceiveData(ByVal ar As IAsyncResult)
        'during shutdown, stop listening
        If disposing Then Exit Sub

        Dim ep As EndPoint = CType(epIncoming, EndPoint)
        Dim bytes_read As Integer = sockIncoming.EndReceiveFrom(ar, ep)
        epIncoming = CType(ep, IPEndPoint)

        'check origin
        Dim accept As Boolean = False
        Dim i As Integer = 0
        While ((Not accept) And (i < ListenToIPs.Length))
            If ListenToIPs(i).ToUpper() = "ANY" Then
                accept = True
            Else
                'don't accept candy from a stranger
                If ListenToIPs(i).ToUpper() = "ANY_LOCAL" Then
                    accept = LocalIP.Contains(epIncoming.Address.ToString())
                ElseIf ListenToIPs(i) = epIncoming.Address.ToString() Then
                    accept = True
                End If
            End If
            i += 1
        End While

        If accept Then
            Dim myXPL As XplMsg
            Dim rawXpl As String = ""

            Try
                rawXpl = Encoding.ASCII.GetString(XPL_Buff, 0, bytes_read)
                myXPL = New XplMsg(rawXpl)

                Dim myTarget As String = myXPL.TargetTag

                Dim bIsForMyTarget As Boolean = (myXPL.TargetTag.ToLower() = (mVendorId & "-" & mDeviceId & "." & InstanceName).ToLower())
                Dim bIsForAnyTarget As Boolean = myXPL.TargetIsAll
                Dim bFiltered As Boolean = (Filters.Count = 0)  'if there are no filters, then by default the message is accepted
                Dim SchemaClass As String = myXPL.Class.ToLower()
                Dim SchemaType As String = myXPL.Type.ToLower()

                'are we waiting for our own hbeat ?
                If Not mHubFound Then
                    If (SchemaClass = "hbeat" Or SchemaClass = "config") AndAlso SchemaType = "app" AndAlso myXPL.SourceTag = mVendorId & "-" & mDeviceId & "." & InstanceName Then
                        'communication established
                        mHubFound = True
                        XPLTimer.Interval = TIMER_FREQ  'return to normal hbeat frequency
                        RaiseEvent XplJoinedxPLNetwork()
                    End If
                End If

                'handle config messages - these are always targeted to the device
                If bIsForMyTarget AndAlso SchemaClass = "config" Then
                    HandleConfigMessage(myXPL)
                End If

                ' Handle hbeat.request messages
                If (bIsForMyTarget Or bIsForAnyTarget) And (SchemaClass = "hbeat" And SchemaType = "request") Then
                    WaitForRandomPeriod()
                    SendHeartbeatMessage(False)
                End If

                'see if we need to raise an event:
                '- if we are in AwaitingConfig, then do not raise events unless AlwaysPassMessages is true (still check against filters though)
                '- if there are filters, see if there is at least 1 match

                'nothing to do if in AwaitingConfig and Not AlwaysPassMessages
                If Not bConfigOnly Or Filters.AlwaysPassMessages Then

                    'any messages for us are checked against the filter collection
                    If bIsForAnyTarget Or bIsForMyTarget Or Not Filters.MatchTarget OrElse CheckGroups(myTarget) Then
                        Dim flt As XplFilter
                        For f As Integer = 0 To Filters.Count - 1
                            flt = Filters.Item(f)
                            If MsgTypeMatchesFilter(myXPL.MsgType, flt.MessageType) Then
                                ' Match the source
                                If MsgSourceMatchesFilter(myXPL.SourceVendor.ToLower(), myXPL.SourceDevice.ToLower(), myXPL.SourceInstance.ToLower(), flt.Source) Then
                                    ' Match the schema
                                    If MsgSchemaMatchesFilter(SchemaClass, SchemaType, flt.Schema) Then
                                        bFiltered = True
                                        Exit For
                                    End If
                                End If
                            End If
                        Next
                    End If

                    'raise an event if the message was filtered
                    If bFiltered Then
                        RaiseEvent XplMessageReceived(Me, New XplEventArgs(myXPL))
                    End If
                End If
            Catch ex As Exception
                LogError(ex.ToString() & vbCrLf & rawXpl)
            End Try
        End If

        sockIncoming.BeginReceiveFrom(XPL_Buff, 0, MAX_XPL_MSG_SIZE, SocketFlags.None, ep, AddressOf Me.ReceiveData, Nothing)
    End Sub

    Private Function CheckGroups(ByVal t As String) As Boolean
        Try
            t = t.ToLower()
            If Not t.StartsWith("xpl-group") Then
                Return (False)
            End If
            Dim g As String = t.Substring(10, t.Length - 10)
            Dim Counter As Integer
            For Counter = 0 To Groups.Length - 1
                If Groups(Counter) = g Then
                    Return (True)
                End If
            Next
        Catch ex As Exception
        End Try
        Return (False)
    End Function

    Public Sub Listen()
        If Not bListening Then
            LoadState()
            InitSocket()
        End If
    End Sub

    Public Function GetPreparedXplMessage(ByVal MessageType As XplMsg.xPLMsgType, Optional ByVal TargetIsAll As Boolean = False) As XplMsg
        Dim m As XplMsg = New XplMsg()
        m.MsgType = MessageType
        m.SourceVendor = mVendorId
        m.SourceDevice = mDeviceId
        m.SourceInstance = InstanceName

        If TargetIsAll Then m.TargetIsAll = True

        Return m
    End Function

    Public Function GetPreparedXplMessage(ByVal MessageType As XplMsg.xPLMsgType, ByVal TargetVendor As String, ByVal TargetDevice As String, ByVal TargetInstance As String) As XplMsg
        Dim m As XplMsg = GetPreparedXplMessage(MessageType)
        m.TargetVendor = TargetVendor
        m.TargetDevice = TargetDevice
        m.TargetInstance = TargetInstance
        Return m
    End Function

    Public Sub SendMessage(ByVal MsgType As String, ByVal strTarget As String, ByVal strSchema As String, ByVal strMessage As String)
        Dim s As String
        s = MsgType & Chr(10) & "{" & Chr(10)
        s = s & "hop=1" & Chr(10)
        s = s & "source=" & mVendorId & "-" & mDeviceId & "." & InstanceName & Chr(10)
        s = s & "target=" & strTarget & Chr(10)
        s = s & "}" & Chr(10) & strSchema & Chr(10) & "{" & Chr(10)
        s = s & strMessage & "}" & Chr(10)

        Dim myXplMsg As New XplMsg(s)
        myXplMsg.Send()
    End Sub


#End Region

#Region "Timer, Heartbeat"

    Public Sub XPLTimerElapsed(ByVal sender As Object, ByVal e As Timers.ElapsedEventArgs)
        If disposing Then
            Exit Sub
        End If

        'If WriteDebugInfo Then
        '    'LogInfo("The timer has elapsed.")
        'End If

        If Not mHubFound Then 'we are sending out hbeats at a higher frequency
            If Not mNoHubPastInitialProbe Then 'not yet at a lower frequency
                mNoHubTimerCount += NOHUB_HBEAT
                If mNoHubTimerCount >= NOHUB_TIMEOUT Then 'lower the hbeat frequency as apparently there is no hub
                    XPLTimer.Interval = NOHUB_LOWERFREQ * 1000
                    mNoHubPastInitialProbe = True
                End If
            End If

            SendHeartbeatMessage(False)

        Else 'normal pace
            If Not XplOnTimer Is Nothing And Not sender Is Nothing Then
                Try
                    XplOnTimer.Invoke()
                Catch ex As Exception
                End Try
            End If

            HBeat_Count = HBeat_Count + 1
            If HBeat_Count >= HBeat_Interval Or bConfigOnly Then
                ' Send our XPL heartbeat
                SendHeartbeatMessage(False)
                HBeat_Count = 0
            End If

            ' Calculate our next interval
            XPLTimer.Interval = (60 - DateTime.Now.Second + 1) * 1000
        End If
        'If WriteDebugInfo Then
        '    'LogInfo("Timer interval is " & XPLTimer.Interval)
        'End If
        XPLTimer.Start()
    End Sub

    Public Property HBeatInterval() As Integer
        Get
            Return (HBeat_Interval)
        End Get
        Set(ByVal Value As Integer)
            If Value < 5 Then
                HBeat_Interval = 5
            ElseIf Value > 30 Then
                HBeat_Interval = 30
            Else
                HBeat_Interval = Value
            End If
        End Set
    End Property

    Private Sub SendHeartbeatMessage(ByVal closingDown As Boolean)
        Try
            Dim x As New XplMsg()
            x.MsgType = XplMsg.xPLMsgType.stat
            x.SourceVendor = mVendorId
            x.SourceDevice = mDeviceId
            x.SourceInstance = InstanceName
            x.TargetIsAll = True

            If bConfigOnly Then
                x.Class = "config"
            Else
                x.Class = "hbeat"
            End If

            If closingDown Then
                x.Type = "end"
            Else
                x.Type = "app"
            End If

            x.AddKeyValuePair("interval", HBeat_Interval.ToString())
            x.AddKeyValuePair("port", XPL_Portnum.ToString())

            'put the IP address that we are actually listening on in the heartbeat
            Dim sip As String = ListenOnIP()
            'if what is configured is not a real local ip, then make a best guess: take the first
            If Not LocalIP.Contains(sip) Then sip = LocalIP(0).ToString()

            x.AddKeyValuePair("remote-ip", sip)
            x.AddKeyValuePair("version", VersionNumber)

            If Not XplHBeatItems Is Nothing And Not bConfigOnly Then
                Dim s As String = XplHBeatItems.Invoke()
                Dim ars() As String = s.Split(CChar(vbLf))
                Dim kv() As String
                For i As Integer = 1 To ars.Length
                    kv = (ars(i - 1).Split("="c))
                    If kv.Length = 2 Then
                        x.AddKeyValuePair(kv(0), kv(1))
                    End If
                Next
            End If

            x.Send()
        Catch ex As Exception
            LogError("Error sending heartbeat: " & ex.ToString())
        End Try
    End Sub

#End Region

#Region "Message contents interpretation, filtering, reply"

    Private Function MsgTypeMatchesFilter(ByVal m As XplMsg.xPLMsgType, ByVal f As XplMessageTypes) As Boolean
        If f = XplMessageTypes.Any Then
            Return (True)
        End If
        MsgTypeMatchesFilter = False
        Select Case m
            Case XplMsg.xPLMsgType.cmnd
                If (f And XplMessageTypes.Command) > 0 Then
                    MsgTypeMatchesFilter = True
                End If
            Case XplMsg.xPLMsgType.stat
                If (f And XplMessageTypes.Status) > 0 Then
                    MsgTypeMatchesFilter = True
                End If
            Case XplMsg.xPLMsgType.trig
                If (f And XplMessageTypes.Trigger) > 0 Then
                    MsgTypeMatchesFilter = True
                End If
        End Select
        'DEBUGSTUFF
        'LogInfo("Msgtypematchesfilter=" & MsgTypeMatchesFilter.ToString())
    End Function

    Private Function MsgSourceMatchesFilter(ByVal mySourceVendor As String, ByVal mySourceDevice As String, ByVal mySourceInstance As String, ByVal fSource As XplSource) As Boolean
        'LogInfo("vendor=" & myVendor & ",device=" & myDevice & ",instance=" & myInstance)
        ' Compare the vendor portion
        If fSource.Vendor <> "*" And fSource.Vendor <> mySourceVendor Then
            Return (False)
        End If

        ' Compare the device portion
        If fSource.Device <> "*" And fSource.Device <> mySourceDevice Then
            Return (False)
        End If

        ' Compare the instance portion
        If fSource.Instance <> "*" And fSource.Instance <> mySourceInstance Then
            Return (False)
        End If
        'DEBUGSTUFF
        'LogInfo("SourceMatchesfilter = true")
        Return (True)
    End Function

    Private Function MsgSchemaMatchesFilter(ByVal c As String, ByVal t As String, ByVal fSchema As XplSchema) As Boolean
        If fSchema.msgClass <> "*" And fSchema.msgClass <> c Then
            Return (False)
        End If
        If fSchema.msgType <> "*" And fSchema.msgType <> t Then
            Return (False)
        End If
        'LogInfo("SchemaMatchesFilter=true")
        Return (True)
    End Function

    Private Sub HandleConfigMessage(ByVal x As XplMsg)

        If x.MsgType <> XplMsg.xPLMsgType.cmnd Then
            Exit Sub
        End If

        Dim xr As XplMsg
        ' What sort of config message is it?
        Select Case (x.Class & "." & x.Type).ToLower()
            Case "config.current"
                If x.GetKeyValue("command").ToLower() = "request" Then   'reply with our current configuration

                    xr = New XplMsg()
                    xr.MsgType = XplMsg.xPLMsgType.stat
                    xr.SourceVendor = mVendorId
                    xr.SourceDevice = mDeviceId
                    xr.SourceInstance = InstanceName
                    xr.TargetIsAll = True
                    xr.Class = "config"
                    xr.Type = "current"

                    Dim ci As XplConfigItem
                    For j As Integer = 0 To ConfigItems.Count - 1
                        ci = CType(ConfigItems(j), XplConfigItem)
                        For i As Integer = 0 To ci.ValueCount - 1
                            xr.AddKeyValuePair(ci.Name, ci.Value(i))
                        Next
                    Next

                    xr.Send()

                End If
            Case "config.list"   'list all config options

                xr = New XplMsg()
                xr.MsgType = XplMsg.xPLMsgType.stat
                xr.SourceVendor = mVendorId
                xr.SourceDevice = mDeviceId
                xr.SourceInstance = InstanceName
                xr.TargetIsAll = True
                xr.Class = "config"
                xr.Type = "list"

                Dim ci As XplConfigItem
                Dim k As String = ""
                Dim v As String
                For j As Integer = 0 To ConfigItems.Count - 1
                    ci = CType(ConfigItems(j), XplConfigItem)
                    Select Case ci.ConfigType
                        Case xplConfigTypes.xConfig
                            k = "config"
                        Case xplConfigTypes.xReconf
                            k = "reconf"
                        Case xplConfigTypes.xOption
                            k = "option"
                    End Select
                    v = ci.Name
                    If ci.MaxValues > 1 Then 'add [MaxValues] to the name so that receiver knows this item can have multiple values
                        v &= "[" & ci.MaxValues.ToString() & "]"
                    End If
                    xr.AddKeyValuePair(k, v)
                Next

                xr.Send()

            Case "config.response"  'our new configuration
                If x.TargetTag.ToLower() = mVendorId & "-" & mDeviceId & "." & InstanceName.ToLower() Then
                    Dim colHadThisElement As New ArrayList
                    Dim ci As XplConfigItem

                    Dim key As String
                    Dim sval As String

                    For Each kv As XplMsg.KeyValuePair In x.KeyValues
                        Try
                            key = kv.Key.ToLower()
                            sval = kv.Value

                            ci = ConfigItems(key)

                            If Not colHadThisElement.Contains(key) Then
                                ci.ResetValues()
                                colHadThisElement.Add(key)
                            End If

                            If key = "interval" Then
                                Dim hbeat As Integer
                                Try
                                    hbeat = Int32.Parse(sval)
                                Catch ex As Exception
                                    hbeat = DEFAULT_HBEAT
                                End Try
                                If hbeat < MIN_HBEAT Then
                                    hbeat = MIN_HBEAT
                                ElseIf hbeat > MAX_HBEAT Then
                                    hbeat = MAX_HBEAT
                                End If
                                ci.AddValue(hbeat.ToString())
                                RaiseEvent XplConfigItemDone(key, hbeat.ToString(), New XplLoadStateEventArgs(False))
                            Else
                                ci.AddValue(sval)
                                RaiseEvent XplConfigItemDone(key, sval, New XplLoadStateEventArgs(False))
                            End If
                        Catch ex As Exception
                            LogError(ex.Message)
                        End Try
                    Next

                    Try
                        If bConfigOnly Then
                            bConfigOnly = False
                            RaiseEvent XplConfigDone(New XplLoadStateEventArgs(False))
                        Else
                            RaiseEvent XplReConfigDone(New XplLoadStateEventArgs(False))
                        End If
                    Catch
                    End Try

                    SaveState()
                    SendHeartbeatMessage(False)
                End If
        End Select
    End Sub

    Private Shared Function StrCmnd2MsgType(ByVal StrCmnd As String) As XplMessageTypes
        Dim MessageType As XplMessageTypes
        Select Case StrCmnd.ToLower()
            Case "xpl-cmnd"
                MessageType = XplMessageTypes.Command
            Case "xpl-stat"
                MessageType = XplMessageTypes.Status
            Case "xpl-trig"
                MessageType = XplMessageTypes.Trigger
            Case "*"
                MessageType = XplMessageTypes.Any
            Case Else
                MessageType = XplMessageTypes.None
        End Select
        Return MessageType
    End Function

    Private Shared Function StrMsgType2Cmnd(ByVal MessageType As XplMessageTypes) As String
        Dim StrCmnd As String
        Select Case MessageType
            Case XplMessageTypes.Command
                StrCmnd = "xpl-cmnd"
            Case XplMessageTypes.Status
                StrCmnd = "xpl-stat"
            Case XplMessageTypes.Trigger
                StrCmnd = "xpl-trig"
            Case XplMessageTypes.Any
                StrCmnd = "*"
            Case Else
                StrCmnd = ""
        End Select
        Return StrCmnd
    End Function

    Private Shared Function Str2Filter(ByVal StrFilter As String) As XplFilter
        Dim filterparts() As String = StrFilter.Split("."c)
        If filterparts.Length <> 6 Then 'malformed filter
            Throw New Exception("Malformed filter: " & StrFilter)
        End If
        Dim msgType As XplMessageTypes = StrCmnd2MsgType(filterparts(0))
        If msgType = XplMessageTypes.None Then 'malformed 1st part of filter
            Throw New Exception("Malformed message type in filter: " & StrFilter)
        End If

        Return New XplFilter(msgType, filterparts(1), filterparts(2), filterparts(3), filterparts(4), filterparts(5))

    End Function

#End Region

#Region "Restore and save state"

    Public Sub SaveState()
        If bConfigOnly Then
            Exit Sub
        End If
        'LogInfo("Saving state...")
        Try
            Dim filename As String = "xpl_" & mVendorId & "-" & mDeviceId & ".instance." & XPL_LIB_VERSION & ".xml"

            Dim xml As New XmlTextWriter(filename, Nothing)
            xml.Formatting = Formatting.Indented
            xml.WriteStartDocument(False)
            xml.WriteComment("This file was automatically generated by the xPL Library " & XPL_LIB_VERSION & " for .NET")

            xml.WriteStartElement("xplConfiguration")

            ' Config items
            xml.WriteStartElement("configItems")
            Dim ci As XplConfigItem
            For j As Integer = 0 To ConfigItems.Count - 1
                ci = CType(ConfigItems(j), XplConfigItem)
                xml.WriteStartElement("configItem")
                xml.WriteAttributeString("key", ci.Name)
                xml.WriteAttributeString("value", ci.Value(0))
                xml.WriteEndElement()
                For i As Integer = 1 To ci.ValueCount - 1
                    xml.WriteStartElement("configItem")
                    xml.WriteAttributeString("key", ci.Name)
                    xml.WriteAttributeString("value", ci.Value(i))
                    xml.WriteEndElement()
                Next
            Next
            xml.WriteEndElement()

            xml.WriteEndElement()
            xml.Flush()
            xml.Close()
        Catch ex As Exception
            LogError("Error saving state: " & ex.ToString())
        End Try
    End Sub

    Private Sub LoadState()
        Dim xml As XmlTextReader
        Dim filename As String = "xpl_" & mVendorId & "-" & mDeviceId & ".instance." & XPL_LIB_VERSION & ".xml"
        Dim bLoaded As Boolean = False

        Try
            If File.Exists(filename) Then

                'reset config data
                ConfigItems.ResetAllConfigItemValues()

                xml = New XmlTextReader(filename)

                While xml.Read
                    If xml.NodeType = XmlNodeType.Element AndAlso xml.Name = "configItem" Then
                        ConfigItems(xml.GetAttribute("key")).AddValue(xml.GetAttribute("value"))
                    End If
                End While
                xml.Close()
                bLoaded = True
                RaiseEvent XplConfigDone(New XplLoadStateEventArgs(True))
                'LogInfo("Configuration loaded OK.")
            Else
                'LogInfo("The config file " & filename & " does not exist. Going into remote config mode.")
            End If

        Catch ex As Exception
            LogError("Loading did not succeed: " & ex.Message)
        End Try

        If Not bLoaded Then
            ' Setup default instance
            Dim defaultName As String = Environment.MachineName.ToLower().Replace("-", "").Replace("_", "")
            If defaultName.Length > 14 Then
                defaultName = defaultName.Substring(0, 14)
            End If
            InstanceName = defaultName

            bConfigOnly = True
            'LogInfo("Awaiting configuration.")
        End If
    End Sub

#End Region


    Friend Shared Sub LogError(ByVal s As String)
        If Not mEventLog Is Nothing Then
            mEventLog.WriteEntry(s)
        End If
    End Sub

    'Private Sub LogInfo(ByVal s As String)
    '    If WriteDebugInfo Then
    '        Dim fs As StreamWriter = File.AppendText("c:\xpllib-debug-log.txt")
    '  fs.WriteLine(DateTime.Now().ToString("dd-MMM-yy HH:mm:ss") & " " & Source & ": " & s)
    '        fs.Close()
    '    End If
    'End Sub

  Private Function GetVersionNumber() As String
    Try
      Dim v As Version = System.Reflection.Assembly.GetEntryAssembly().GetName().Version
      Return v.Major & "." & v.Minor & "." & v.Build & "." & v.Revision
    Catch ex As Exception
      Return "0.0.0.0"
    End Try
  End Function

  Private Sub WaitForRandomPeriod()
    ' Compute a random number between 1000 and 3000
    Dim R As New Random
    Dim Period As Integer = R.Next(1000, 3000)

    ' Wait for the specified period
        Thread.Sleep(Period)
  End Sub

End Class
