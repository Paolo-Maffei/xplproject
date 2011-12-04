'* xPL Library for .NET
'*
'* Version 5.5
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

''' <summary>
''' This object represents a single Configuration key and will be used by the xPLExtDevice object to maintain the 
''' configuration information on devices seen on the xPL network. 
''' Each configuration key can have multiple values (no duplicates are allowed).
''' </summary>
''' <remarks>Property <c>Name</c> can only be set upon creation, it is read-only.</remarks>
Public Class xPLExtConfigItem

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLExtConfigItem" /> class.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem</param>
    ''' <param name="itemtype">The item type</param>
    ''' <param name="maxValues">The maximum number of values allowed for this xPLExtConfigItem</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name does not adhere to xPL standards.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only. If <c>maxValues</c> 
    ''' is set to less than 1, it will be set at 1, no exception will be thrown</remarks>
    Public Sub New(ByVal itemName As String, ByVal itemType As xPLConfigTypes, ByVal maxValues As Integer)
        itemName = itemName.ToLower
        mName = itemName
        mConfigType = itemType
        ' use property handlers for extra checks
        Me.MaxValues = maxValues
    End Sub

    Private mName As String
    ''' <returns>The name of the xPLExtConfigItem</returns>
    ''' <remarks>Read-only. This value can only be set upon creation of the object instance.</remarks>
    Public ReadOnly Property Name() As String
        Get
            Return mName
        End Get
    End Property

    Private mItem As New ArrayList
    ''' <param name="idx">Index of the item in the list to get/set.</param>
    ''' <value>Value to set at position <c>idx</c> in the list</value>
    ''' <returns>The current value set at position <c>idx</c> in the list.</returns>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than 0 or higher than or equal to <c>Count</c>.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    Default Public Property Item(ByVal idx As Integer) As String
        Get
            Return CStr(mItem(idx))
        End Get
        Set(ByVal value As String)
            If idx = 0 And mItem.Count = 0 Then
                mItem.Add(value)
            Else
                mItem(idx) = value
            End If
        End Set
    End Property

    Private mMaxValues As Integer
    ''' <value>Sets the maximum number of values that can be stored in the xPLExtConfigItem</value>
    ''' <returns>The maximum number of values allowed</returns>
    ''' <remarks>If the value is set to less than 1, it will be set at 1. If <c>value</c> is less than the current value of <c>Count</c>, 
    ''' then all excess items will be deleted from the list.</remarks>
    Public Property MaxValues() As Integer
        Get
            Return mMaxValues
        End Get
        Set(ByVal Value As Integer)
            ' handle special case "group" 
            If Value < 1 Then Value = 1
            mMaxValues = Value
            ' right-size array, ditch whatever is over the limit
            If mItem.Count > Value Then mItem.RemoveRange(Value, mItem.Count - Value)
        End Set
    End Property

    Private mConfigType As xPLConfigTypes
    ''' <returns>The xPL configuration item type; config, reconf or option.</returns>
    Public Property ConfigType() As xPLConfigTypes
        Get
            Return mConfigType
        End Get
        Set(ByVal value As xPLConfigTypes)
            mConfigType = value
        End Set
    End Property

    ''' <returns>The number of values stored in the value list</returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Count() As Integer
        Get
            Return mItem.Count
        End Get
    End Property

    ''' <param name="itemValue">The itemValue to be removed from the list</param>
    ''' <remarks>If the value isn't found, then no exception will be thrown.</remarks>
    Public Sub Remove(ByVal itemValue As String)
        Dim i As Integer = mItem.IndexOf(itemValue)
        If i <> -1 Then
            mItem.RemoveAt(i)
        End If
    End Sub

    ''' <summary>
    ''' Adds a value to the list of values stored in the <c>xPLExtConfigItem</c> object
    ''' </summary>
    ''' <param name="itemValue">Value to be added to the list</param>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>Count</c> equals <c>MaxValues</c>, no items can be added.</exception>
    ''' <remarks></remarks>
    Public Sub Add(ByVal itemValue As String)
        mItem.Add("")
        Me.Item(mItem.Count - 1) = itemValue
    End Sub

    ''' <param name="v">The value being sought in the list</param>
    ''' <returns>The index at which the value <c>v</c> is located in the list, or -1 if it doesn't exist in the list</returns>
    Public Function IndexOf(ByVal v As String) As Integer
        Return mItem.IndexOf(v)
    End Function

    ''' <summary>
    ''' Clears the list with values
    ''' </summary>
    ''' <remarks>The <c>Name</c>, <c>ConfigType</c> and <c>MaxValues</c> properties of the config item remain unchanged.</remarks>
    Public Sub Clear()
        mItem.Clear()
    End Sub

    ''' <returns>A string representing the xPLExtConfigItem in the format used for raw XPL. Each value will be in the list in the format "name=value". Hence 'name' is 
    ''' the same for each value in the list. The individual values (lines) will be separated by the <c>XPL_LF</c> constant.</returns>
    ''' <remarks>If there are no items in the list, "name=" will be returned</remarks>
    Public Overrides Function ToString() As String
        Dim n As Integer
        Dim result As String = ""
        If mItem.Count = 0 Then
            result = Me.Name & "="
        Else
            For n = 0 To mItem.Count - 1
                result = Me.Name & "=" & Me.Item(n) & XPL_LF
            Next
            result = Left(result, Len(result) - Len(XPL_LF))
        End If
        Return result
    End Function
End Class


''' <summary>
''' This class represents an external xPL device on the xPL network. The <c>xPLNetwork</c> object will automatically
''' create a list of external devices as it receives messages from the network.
''' </summary>
''' <remarks></remarks>
Public Class xPLExtDevice

#Region "Constructors"
    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLExtDevice" /> class.
    ''' </summary>
    Public Sub New(ByVal addr As String)
        'nothing to do here, but store the address
        mAddress.FullAddress = addr
    End Sub
#End Region

#Region "Properties"

    Private mKeys As New ArrayList
    Private mConfigItemList As New ArrayList

    ''' <summary>
    ''' The date/time the device was last seen on the network (a message from it was received)
    ''' </summary>
    ''' <remarks></remarks>
    Public LastSeen As DateTime = Now
    ''' <summary>
    ''' The date/time the device will timeout if no new heartbeat has been received
    ''' </summary>
    ''' <remarks></remarks>
    Public TimeOut As DateTime = Now.AddSeconds(XPL_DEFAULT_HBEAT_TIMEOUT)
    ''' <summary>
    ''' <c>True</c> if a config.list status message has been received from this device
    ''' </summary>
    ''' <remarks></remarks>
    Public ConfigList As Boolean = False
    ''' <summary>
    ''' <c>True</c> if a config.current status message has been received from this device
    ''' </summary>
    ''' <remarks>If a config.response command message for a device is seen, then this property is 
    ''' returned to <c>False</c> until a new config.current status message is received.</remarks>
    Public ConfigCurrent As Boolean = False
    ''' <summary>
    ''' <c>True</c> if a heartbeat END message has been received
    ''' </summary>
    ''' <remarks>see also <seealso cref="TimedOut"/></remarks>
    Public Ended As Boolean = False
    ''' <summary>
    ''' <c>True</c> if no new heartbeat was received from the device within INTERVAL * 2 + 1 minutes
    ''' </summary>
    ''' <remarks>see also <seealso cref="Ended"/></remarks>
    Public TimedOut As Boolean = False
    ''' <summary>
    ''' A list with all heartbeat items received from the device
    ''' </summary>
    ''' <remarks>Every time a message with schema type hbeat.basic, hbeat.app, config.basic or 
    ''' config.app is received the values in the list are overwritten with the new ones received.</remarks>
    Public ReadOnly HeartBeatItems As New xPLKeyValuePairs

    Private mAddress As New xPLAddress(xPLAddressType.Source)
    ''' <summary>
    ''' Returns the address of the device.
    ''' </summary>
    ''' <returns>xPL Address of the device.</returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Address() As xPLAddress
        Get
            Return mAddress
        End Get
    End Property

    ''' <param name="key">The <c>Name</c> of the xPLExtConfigItem object being sought</param>
    ''' <returns>the xPLExtConfigItem from the list that has a <c>Name</c> value that corresponds to the provide <c>key</c> value</returns>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: the <c>key</c> cannot be found.</exception>
    ''' <remarks>Read-only, use <c>Add</c> or <c>Remove</c> to modify the list. Value of <c>key</c> will be 
    ''' converted to lowercase.</remarks>
    Default Public ReadOnly Property Item(ByVal key As String) As xPLExtConfigItem
        Get
            Return Me.Item(mKeys.IndexOf(key.ToLower()))
        End Get
    End Property

    ''' <param name="idx">The index of the xPLExtConfigItem object in the list</param>
    ''' <returns>A reference to the xPLExtConfigItem object in the list at position <c>idx</c>.</returns>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: the <c>idx</c> value is less than 0 or greater than <c>Count</c>.</exception>
    ''' <remarks>Read-only, use <c>Add</c> or <c>Remove</c> to modify the list.</remarks>
    Default Public ReadOnly Property Item(ByVal idx As Integer) As xPLExtConfigItem
        Get
            Try
                Return CType(mConfigItemList(idx), xPLExtConfigItem)
            Catch ex As Exception
                Throw ex
            End Try
        End Get
    End Property

    ''' <returns>The number of xPLExtConfigItem objects in the list</returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Count() As Integer
        Get
            Return mKeys.Count
        End Get
    End Property

#End Region

#Region "Collection management"
    ''' <returns>The index of the xPLExtConfigItem with a <c>Name</c> that equals <c>itemName</c>.</returns>
    ''' <remarks><c>itemName</c> will be converted to lowercase. Returns -1 if not found.</remarks>
    Public Function IndexOf(ByVal itemName As String) As Integer
        Return mKeys.IndexOf(itemName.ToLower)
    End Function

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLExtConfigItem" /> class and adds it to the list.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem</param>
    ''' <param name="itemtype">The item type</param>
    ''' <param name="maxValues">The maximum number of values allowed for this xPLExtConfigItem</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name does not adhere to xPL standards.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards.</exception>
    ''' <exception cref="DuplicateConfigItemName">Condition: If <c>itemName</c> is already present in the list.</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only. If <c>maxValues</c> 
    ''' is set to less than 1, it will be set at 1, no exception will be thrown</remarks>
    Public Sub Add(ByVal itemName As String, ByVal itemType As xPLConfigTypes, ByVal MaxValues As Integer)
        Dim ci As xPLExtConfigItem
        ci = New xPLExtConfigItem(itemName, itemType, MaxValues)
        Me.Add(ci)
    End Sub

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLExtConfigItem" /> class and adds it to the list. The type 
    ''' will be set to "option" and the maximum number of values allowed to 1.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem.</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name does not adhere to xPL standards.</exception>
    ''' <exception cref="DuplicateConfigItemName">Condition: If <c>itemName</c> is already present in the list.</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only.</remarks>
    Public Sub Add(ByVal itemName As String)
        Me.Add(itemName, xPLConfigTypes.xOption, 1)
    End Sub

    ''' <summary>
    ''' Adds a xPLExtConfigItem object to the list of the xPLExtDevice
    ''' </summary>
    ''' <param name="ci">xPLExtConfigItem object to be added to the list</param>
    ''' <exception cref="DuplicateConfigItemName">Condition: If the <c>Name</c> of the <c>ConfigItem</c> object 
    ''' provided is already present in the list.</exception>
    ''' <remarks></remarks>
    Public Sub Add(ByVal ci As xPLExtConfigItem)
        If ci Is Nothing Then Return
        If Me.IndexOf(ci.Name) = -1 Then
            mConfigItemList.Add(ci)
            mKeys.Add(ci.Name)
        Else
            ' duplicate!
            Throw New DuplicateConfigItemName(ci.Name & " is allready present in the configuration items list")
        End If
    End Sub

    ''' <param name="key">The <c>Name</c> of the xPLExtConfigItem object to remove from the list.</param>
    ''' <remarks><c>key</c> will be converted to lowercase. If the item is not found, no exception is thrown.</remarks>
    Public Sub Remove(ByVal key As String)
        Dim i As Integer = Me.IndexOf(key.ToLower)
        If i <> -1 Then Me.Remove(i)
    End Sub

    ''' <param name="idx">The index of the item to remove from the list.</param>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than 0 or greater than or equal to <c>Count</c>.</exception>
    ''' <remarks></remarks>
    Public Sub Remove(ByVal idx As Integer)
        mConfigItemList.RemoveAt(idx)
        mKeys.RemoveAt(idx)
    End Sub
#End Region

#Region "Other..."

    ''' <summary>
    ''' Returns a raw xPL string containing all the configuration items. 
    ''' </summary>
    ''' <returns>String representation of configuration values.</returns>
    ''' <remarks>Each line has a format 'name=value', lines are separated by XPL_LF.</remarks>
    Public Overrides Function ToString() As String
        Dim result As String = ""
        For Each x As xPLExtConfigItem In mConfigItemList
            result = result & XPL_LF & x.ToString
        Next
        ' drop the first XPL_LF
        If result <> "" Then result = Mid(result, Len(XPL_LF) + 1)
        Return result
    End Function

#End Region

End Class

''' <summary>
''' The <c>xPLNetwork</c> class is a shared class that provides access to the xPL devices as seen on the
''' xPL network. The <c>xPLListener</c> initiates and terminates information collecting automatically. 
''' No instances of the xPLNetwork object can be created.
''' Passive scanning is automatic; all messages received by the <c>xPLListener</c> object will be passed 
''' on and any new information on the xPL network will be stored.
''' For active scanning of individual devices use the methods <see cref="xPLNetwork.RequestHeartbeat"/>, 
''' <see cref="xPLNetwork.RequestConfigList"/>,  <see cref="xPLNetwork.RequestConfigCurrent"/> or start
''' an asynchroneous scan of the entire network by calling <see cref="xPLNetwork.ScanASync"/>.
''' </summary>
''' <remarks>There must be at least 1 enabled device for the listener to remain connected and receive
''' messages. If the last device is disabled, connection with the xPL network is lost and the 
''' <see cref="xPLNetwork"/> object will not receive any updates from the listener. The network information 
''' will then become unreliable!! Consider doing a reset or activescan after reconnecting to the network.
''' </remarks>
Public Class xPLNetwork
    Private Shared mNetwork As New ArrayList           ' holds all devices as seen on the network
    Private Shared mNetworkTimer As Timers.Timer       ' Timer used to check for devices timing out on the network
    Private Shared mScanTimer As Timers.Timer          ' Timer used to actively scan for devices
    Private Shared mScanDevice As String               ' Address of device to be used for scanning the network
    Private Shared mScanStage As Integer               ' stage the ASync scan is in
    Private Shared mStageWait As Integer               ' Wait inbetween scanning stages
    Private Shared mScanCallback As ScanASyncCompleteCallback = Nothing
    Private Shared mActive As Boolean = False
    Private Shared mNetworkKeepEnded As Boolean = False

#Region "Events"

    ''' <summary>
    ''' Event raised when a device is seen for the first time on the network.
    ''' </summary>
    ''' <remarks>When using 1 eventhandler for both the Lost and Found events, check the 
    ''' <see cref="xPLExtDevice.Ended"/> and <see cref="xPLExtDevice.TimedOut"/> properties
    ''' to determine whether the device was found (both <c>False</c>) or lost (at least 1 <c>True</c>).</remarks>
    Public Shared Event xPLDeviceFound(ByVal e As xPLNetworkEventArgs)
    ''' <summary>
    ''' Event raised when a device is lost (either heartbeat timed out, or an END message was received).
    ''' </summary>
    ''' <remarks>Check the <see cref="xPLExtDevice.Ended"/> and <see cref="xPLExtDevice.TimedOut"/> of the device to 
    ''' find out the reason. When using 1 eventhandler for both the Lost and Found events, these two properties
    ''' can be used to determine whether the device was found (both <c>False</c>) or lost (at least 1 <c>True</c>).</remarks>
    Public Shared Event xPLDeviceLost(ByVal e As xPLNetworkEventArgs)
    ''' <summary>
    ''' Event raised when the network has been reset by calling the <see cref="xPLNetwork.Reset"/> method.
    ''' </summary>
    Public Shared Event xPLNetworkReset()

    ''' <summary>
    ''' Eventarguments containing the <see cref="xPLExtDevice"/> found or lost. Used by  
    ''' <see cref="xPLDeviceFound"/> and <see cref="xPLDeviceLost"/> events.
    ''' </summary>
    Public Class xPLNetworkEventArgs
        Inherits EventArgs
        ''' <summary>
        ''' Contains the <see cref="xPLExtDevice"/> object that as found/lost on the network
        ''' </summary>
        ''' <remarks>Check the <see cref="xPLExtDevice.Ended"/> and <see cref="xPLExtDevice.TimedOut"/> properties
        ''' to determine whether the device was found (both <c>False</c>) or lost (at least 1 <c>True</c>)</remarks>
        Public ExtDevice As xPLExtDevice = Nothing
        Public Sub New(ByVal xPLExtDev As xPLExtDevice)
            ExtDevice = xPLExtDev
        End Sub
    End Class

#End Region

#Region "Properties"

    ''' <summary>
    ''' Delegate function used for a CallBack when the <c>ScanASync</c> completes
    ''' </summary>
    ''' <remarks>see <see cref="xPLNetwork.ScanASync"/>.</remarks>
    Public Delegate Sub ScanASyncCompleteCallback()

    ''' <summary>
    ''' Should devices having send an END message (or having been timed-out) be kept in the list?
    ''' </summary>
    ''' <remarks>If set to <c>False</c> all ended and timedout devices will be removed from the list. If set 
    ''' to <c>True</c> the status of devices can still be checked by the properties 
    ''' <see cref="xPLExtDevice.TimedOut"/> and <see cref="xPLExtDevice.Ended"/>.
    ''' NOTE: this property is included in the <see cref="xPLListener.GetState"/>.</remarks>
    Public Shared Property NetworkKeepEnded() As Boolean
        Get
            Return mNetworkKeepEnded
        End Get
        Set(ByVal value As Boolean)
            Dim n As Integer
            Dim xdev As xPLExtDevice
            mNetworkKeepEnded = value
            If Not mNetworkKeepEnded Then
                ' Remove any ended or timedout devices from the list
                For n = Count - 1 To 0 Step -1  ' count backwards, as we might be removing items
                    xdev = CType(mNetwork(n), xPLExtDevice)
                    If xdev.TimedOut Or xdev.Ended Then
                        mNetwork.RemoveAt(n)
                    End If
                Next
            End If
        End Set
    End Property

    ''' <summary>
    ''' Returns the index of a device (based on its xPL address) in the network list.
    ''' </summary>
    ''' <param name="DeviceAddress">Full xPL address formatted as 'vendor-device.instance'</param>
    ''' <returns>Index value, or -1 if not found.</returns>
    ''' <remarks></remarks>
    Public Shared Function IndexOf(ByVal DeviceAddress As String) As Integer
        Dim result As Integer = -1
        Dim dev As xPLExtDevice
        Dim n As Integer
        If Not mActive Then Return -1

        DeviceAddress = DeviceAddress.ToLower
        For n = 0 To mNetwork.Count - 1
            dev = CType(mNetwork(n), xPLExtDevice)
            If dev.Address.ToString = DeviceAddress Then
                result = n
                Exit For
            End If
        Next
        Return result
    End Function

    ''' <summary>
    ''' Gets an <c>xPLExtDevice</c> object from the list by its index
    ''' </summary>
    ''' <param name="idx">Index of the <c>xPLExtDevice</c> object requested from the list</param>
    ''' <returns><c>xPLExtDevice</c> object at position <c>idx</c></returns>
    ''' <remarks></remarks>
    ''' <exception cref="IndexOutOfRangeException">Condition: <c>idx</c> is less than 0 or greater than or equal to <c>Count</c>.</exception>
    Public Shared ReadOnly Property Devices(ByVal idx As Integer) As xPLExtDevice
        Get
            Return CType(mNetwork(idx), xPLExtDevice)
        End Get
    End Property

    ''' <summary>
    ''' Gets an <c>xPLExtDevice</c> object from the list by its device address
    ''' </summary>
    ''' <param name="addr">xPL Address of the <c>xPLExtDevice</c> object requested from the list</param>
    ''' <returns>First <c>xPLExtDevice</c> object with address <c>addr</c>, or <c>Nothing</c> if <c>addr</c> 
    ''' was not found in the list</returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property Devices(ByVal addr As String) As xPLExtDevice
        Get
            Dim n As Integer
            n = IndexOf(addr)
            If n = -1 Then
                Return Nothing
            Else
                Return CType(mNetwork(IndexOf(addr)), xPLExtDevice)
            End If
        End Get
    End Property

    ''' <returns>The number of devices in the list</returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property Count() As Integer
        Get
            Return mNetwork.Count
        End Get
    End Property

#End Region

#Region "Constructors and Destructors"

    Private Sub New()
        ' private New to prevent instance creation
    End Sub
    ' All is shared, so no real constructor, will be called by listener when created
    Friend Shared Sub StartPassiveScan()
        mActive = True
        If mNetwork Is Nothing Then mNetwork = New ArrayList
        ' Network scanning timer
        mNetworkTimer = New Timers.Timer
        AddHandler mNetworkTimer.Elapsed, AddressOf NetworkTimerElapsed
        mNetworkTimer.Interval = 1000 * 60  ' once every minute check for timeouts of network devices
        mNetworkTimer.AutoReset = False
        mNetworkTimer.Start()
    End Sub
    ' All is shared, so no real destructor, will be called by listener when destroyed
    Friend Shared Sub StopScan()
        mActive = False
        ' destroy timers
        Try
            If Not mNetworkTimer Is Nothing Then
                mNetworkTimer.Stop()
                RemoveHandler mNetworkTimer.Elapsed, AddressOf NetworkTimerElapsed
                mNetworkTimer = Nothing
            End If
        Catch
        End Try
        Try
            If Not mScanTimer Is Nothing Then
                mScanTimer.Stop()
                RemoveHandler mScanTimer.Elapsed, AddressOf ScanTimerElapsed
                mScanTimer = Nothing
            End If
        Catch
        End Try
        ' clear list
        mNetwork.Clear()
    End Sub

#End Region

#Region "Network Management"

    ''' <summary>
    ''' Resets all information currently known from the network
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub Reset()
        If mActive Then
            xPLNetwork.StopScan()
            xPLNetwork.StartPassiveScan()
            Try
                RaiseEvent xPLNetworkReset()
            Catch ex As Exception
                LogError("xPLNetwork.Reset, xPLNetworkReset event", "Exception returned from RaiseEvent: " & ex.ToString)
            End Try
        End If
    End Sub

    ''' <summary>
    ''' Check whether the devices in my network list are still valid, or they timed-out
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Shared Sub NetworkTimerElapsed(ByVal sender As Object, ByVal e As Timers.ElapsedEventArgs)
        Dim n As Integer
        Dim nwdev As xPLExtDevice
        Try
            mNetworkTimer.Stop()
            If Not mActive Then Exit Sub
            ' count backwards, as we might be deleting items
            For n = mNetwork.Count - 1 To 0 Step -1
                nwdev = CType(mNetwork(n), xPLExtDevice)
                If nwdev.TimeOut <= Now Then
                    ' Timeout expired
                    nwdev.TimedOut = True
                    If Not NetworkKeepEnded Then
                        ' remove from the list
                        mNetwork.RemoveAt(n)
                    End If
                    ' raise event for lost network device
                    Try
                        RaiseEvent xPLDeviceLost(New xPLNetworkEventArgs(nwdev))
                    Catch ex As Exception
                        LogError("xPLNetwork.NetworkTimerElapsed, xPLDeviceLost event", "Exception returned from RaiseEvent: " & ex.ToString)
                    End Try
                End If
            Next
        Finally
            mNetworkTimer.Start()
        End Try
    End Sub

    ''' <summary>
    ''' Everytime a message is received from the network, the listener calls this method to
    ''' update the <c>Network</c> property containing the list of all known devices
    ''' </summary>
    ''' <param name="xmsg">The message just received</param>
    ''' <remarks></remarks>
    Friend Shared Sub MessageReceived(ByVal xmsg As xPLMessage)
        Dim nwdev As xPLExtDevice
        Dim i As Double
        Dim n As Integer
        Dim kv As xPLKeyValuePair
        Dim NewDevice As Boolean = False

        If Not mActive Then Exit Sub

        ' if config current has been handled, and new config.response command is seen, then reset configcurrent
        If xmsg.Schema = "config.response" And xmsg.MsgType = xPLMessageTypeEnum.Command Then
            If mNetwork.IndexOf(xmsg.Target) <> -1 Then
                CType(mNetwork(mNetwork.IndexOf(xmsg.Target)), xPLExtDevice).ConfigCurrent = False
            End If
        End If

        ' do I know the sender?
        If IndexOf(xmsg.Source) = -1 Then
            ' No, haven't seen it before, add it
            nwdev = New xPLExtDevice(xmsg.Source)
            mNetwork.Add(nwdev)
            NewDevice = True
        Else
            'get existing networkdevice
            nwdev = CType(mNetwork(IndexOf(xmsg.Source)), xPLExtDevice)
        End If
        ' set last seen time
        nwdev.LastSeen = DateTime.Now

        If xmsg.MsgType = xPLMessageTypeEnum.Status Then
            Select Case xmsg.Schema.ToString
                Case "hbeat.end", "config.end"
                    ' remove device from the list
                    nwdev.Ended = True
                    If Not NetworkKeepEnded Then
                        ' remove the device
                        mNetwork.Remove(nwdev)
                    End If
                    ' raise event for lost network device
                    Try
                        RaiseEvent xPLDeviceLost(New xPLNetworkEventArgs(nwdev))
                    Catch ex As Exception
                        LogError("xPLNetwork.MessageReceived, xPLDeviceLost event", "Exception returned from RaiseEvent: " & ex.ToString)
                    End Try

                Case "hbeat.basic", "hbeat.app", "config.basic", "config.app"
                    ' update hbeat info
                    Try
                        i = CDbl(xmsg.KeyValueList.Item("interval"))
                    Catch
                        i = (XPL_DEFAULT_HBEAT_TIMEOUT / 60)
                    End Try
                    nwdev.TimedOut = False
                    nwdev.TimeOut = nwdev.LastSeen.AddMinutes(i * 2 + 1)        ' 2 * hbeat +1
                    n = nwdev.IndexOf("interval")
                    If n = -1 Then
                        nwdev.Add("interval")
                        n = nwdev.IndexOf("interval")
                    End If
                    nwdev.Item(n).Item(0) = i.ToString
                    ' Read all key value pairs into heartbeatlist
                    For n = 0 To xmsg.KeyValueList.Count - 1
                        kv = xmsg.KeyValueList(n)
                        If nwdev.HeartBeatItems.IndexOf(kv.Key) = -1 Then
                            ' If the key doesn't exist, add it
                            nwdev.HeartBeatItems.Add(New xPLKeyValuePair(kv.Key, kv.Value))
                        Else
                            ' If the key does exist, overwrite value
                            nwdev.HeartBeatItems(nwdev.HeartBeatItems.IndexOf(kv.Key)).Value = kv.Value
                        End If
                    Next

                Case "config.list"
                    ' store the configuration items available
                    Dim eci As xPLExtConfigItem
                    Dim s As String
                    Dim j As Integer
                    Dim t As xPLConfigTypes
                    Dim m As Integer
                    ' start by removing items from my list that are not in the message
                    ' go through list backwards as we might be deleting items
                    For n = nwdev.Count - 1 To 0 Step -1
                        eci = nwdev(n)
                        For j = 0 To xmsg.KeyValueList.Count - 1
                            s = xmsg.KeyValueList(j).Value
                            If InStr(s, "["c) <> 0 Then
                                s = Left(s, InStr(s, "[") - 1)
                            End If
                            If s = eci.Name Then
                                ' got a match, so exit the loop
                                eci = Nothing
                                Exit For
                            End If
                        Next
                        If Not eci Is Nothing Then
                            ' was not found, so delete it
                            nwdev.Remove(eci.Name)
                        End If
                    Next
                    ' now update settings according to message
                    For n = 0 To xmsg.KeyValueList.Count - 1
                        kv = xmsg.KeyValueList(n)
                        Select Case kv.Key
                            Case "config" : t = xPLConfigTypes.xConfig
                            Case "reconf" : t = xPLConfigTypes.xReconf
                            Case Else : t = xPLConfigTypes.xOption
                        End Select
                        s = kv.Value
                        If InStr(s, "["c) <> 0 Then
                            ' first get number between brackets []
                            s = Mid(kv.Value, InStr(kv.Value, "[") + 1)
                            s = Left(s, InStr(s, "]") - 1)
                            m = CInt(Val(s))
                            ' now get name before bracket [
                            s = Left(kv.Value, InStr(kv.Value, "[") - 1)
                        Else
                            m = 1
                        End If
                        If nwdev.IndexOf(s) = -1 Then
                            ' item not present, so add it
                            eci = New xPLExtConfigItem(s, t, m)
                            nwdev.Add(eci)
                        Else
                            ' get existing item
                            eci = nwdev(s)
                        End If
                        eci.ConfigType = t
                        eci.MaxValues = m
                    Next
                    ' set configlist as handled
                    nwdev.ConfigList = True

                Case "config.current"
                    ' store the values provided for the configuration
                    Dim restlist As New ArrayList
                    ' try and get the interval value if present
                    Try
                        i = CDbl(xmsg.KeyValueList.Item("interval"))
                        nwdev.TimedOut = False
                        nwdev.TimeOut = nwdev.LastSeen.AddMinutes(i * 2 + 1)
                    Catch
                    End Try
                    ' go through all values and reset current list
                    For n = 0 To xmsg.KeyValueList.Count - 1
                        kv = xmsg.KeyValueList(n)
                        If restlist.IndexOf(kv.Key) = -1 Then
                            ' not found in the list, so value has still to be reset
                            Try
                                If nwdev.IndexOf(kv.Key) <> -1 Then nwdev.Item(kv.Key).Clear()
                            Finally
                                ' add to list to prevent resetting again
                                restlist.Add(kv.Key)
                            End Try
                        End If
                        ' add value received to list
                        Try
                            If kv.Value <> "" Then
                                nwdev.Item(kv.Key).Add(kv.Value)
                            End If
                        Catch
                        End Try
                    Next
                    'set configcurrent as handled
                    nwdev.ConfigCurrent = True
            End Select
        End If

        ' Raise event for new device
        If NewDevice Then
            Try
                RaiseEvent xPLDeviceFound(New xPLNetworkEventArgs(nwdev))
            Catch ex As Exception
                LogError("xPLNetwork.MessageReceived, xPLDeviceFound event", "Exception returned from RaiseEvent: " & ex.ToString)
            End Try
        End If

    End Sub

#End Region

#Region "Network scan"
    ''' <returns><c>True</c> if currently an asynchronous network scan is running</returns>
    ''' <remarks></remarks>
    Public Shared Function ScanASyncRunning() As Boolean
        Return Not (mScanTimer Is Nothing)
    End Function

    ''' <summary>
    ''' Performs an xPL network scan asynchroneously (will not block the current thread). The scan has 
    ''' 3 stages; 1) sending a heartbeat (and waiting for responses), 2) requesting config.list from all 
    ''' devices known but yet lacking a config.list (and waiting for responses), 3) requesting config.current 
    ''' from all known devices but lacking a config.current (and waiting for responses).
    ''' When the scan is complete the callback method is called.
    ''' </summary>
    ''' <param name="SourceDev">The <c>xPLDevice</c> object used to send the various requests.</param>
    ''' <param name="StageWait">How long to wait (in milliseconds) for responses at the end of each stage.
    ''' The duration of the entire scan is at least 3x this value.</param>
    ''' <param name="ScanCompleteCallBack">Callback method that will be called when the scan completes</param>
    ''' <remarks>If the information in the config.list and config.current messages is not required, then it is easier
    ''' to just send out a heartbeat request using the <see cref="RequestHeartbeat"/> method.
    ''' Scanning the network will scan for missing information, so known devices for which a 
    ''' config.list or config.current was received already, will not be scanned again. If an entirely new
    ''' scan must be performed, then call the <see cref="Reset"/> method first.
    ''' (if a config.response command message was received for a device and no new config.current status
    ''' message has been received since, it will be scanned again, see <seealso cref="xPLExtDevice.ConfigCurrent"/>)</remarks>
    Public Shared Sub ScanASync(ByVal SourceDev As xPLDevice, Optional ByVal ScanCompleteCallBack As ScanASyncCompleteCallback = Nothing, Optional ByVal StageWait As Integer = 5000)
        If Not mActive Then Exit Sub
        ' request heartbeat
        RequestHeartbeat(SourceDev, "*")
        ' setup timer
        If Not mScanTimer Is Nothing Then
            mScanTimer.Stop()
        Else
            mScanTimer = New Timers.Timer
            AddHandler mScanTimer.Elapsed, AddressOf ScanTimerElapsed
        End If
        mScanTimer.AutoReset = False
        mScanTimer.Interval = StageWait
        ' store settings for timer
        mScanDevice = SourceDev.Address
        mScanStage = 1
        mStageWait = StageWait
        mScanCallback = ScanCompleteCallBack
        mScanTimer.Start()
    End Sub
    Private Shared Sub ScanTimerElapsed(ByVal sender As Object, ByVal e As Timers.ElapsedEventArgs)
        Dim SourceDev As xPLDevice
        Dim Done As Boolean = False
        Dim ListDone As ArrayList
        If Not mActive Then Exit Sub

        mScanTimer.Stop()
        If xPLListener.IndexOf(New xPLAddress(xPLAddressType.Source, mScanDevice)) = -1 Then
            ' source device no longer exists, cancel scan
            RemoveHandler mScanTimer.Elapsed, AddressOf ScanTimerElapsed
            mScanTimer.Dispose()
            mScanTimer = Nothing
        Else
            Try
                SourceDev = xPLListener.Device(New xPLAddress(xPLAddressType.Source, mScanDevice))
                Select Case mScanStage
                    Case 1  ' Heartbeat request was send and now we're supposed to send out config.list requests
                        ' request config.list for all devices not yet received
                        ' tricky here; sending a request, might alter the collection while we work on it
                        ' that will in turn cause an exception.
                        ' So keep iterating the collection until no more exceptions occur and the iteration completes
                        Done = False
                        ListDone = New ArrayList
                        While Not Done
                            Try
                                For Each ExtDev As xPLExtDevice In mNetwork
                                    ' check it against the list already done
                                    If ListDone.IndexOf(ExtDev.Address.ToString) = -1 Then
                                        ' not done so far, so do it now
                                        ListDone.Add(ExtDev.Address.ToString)
                                        If Not ExtDev.ConfigList Then
                                            RequestConfigList(SourceDev, ExtDev.Address.ToString)
                                            ' wait in between sending 200 milliseconds
                                            Threading.Thread.Sleep(200)
                                        End If
                                    End If
                                    If Not mActive Then Exit Sub
                                Next
                                Done = True
                            Catch ex As Exception
                            End Try
                        End While
                        mScanStage = 2
                    Case 2
                        ' request config.current for all devices not yet received
                        ' tricky here; sending a request, might alter the collection while we work on it
                        ' that will in turn cause an exception.
                        ' So keep iterating the collection until no more exceptions occur and the iteration completes
                        Done = False
                        ListDone = New ArrayList
                        While Not Done
                            Try
                                For Each ExtDev As xPLExtDevice In mNetwork
                                    ' check it against the list already done
                                    If ListDone.IndexOf(ExtDev.Address.ToString) = -1 Then
                                        ' not done so far, so do it now
                                        ListDone.Add(ExtDev.Address.ToString)
                                        If Not ExtDev.ConfigCurrent Then
                                            RequestConfigCurrent(SourceDev, ExtDev.Address.ToString)
                                            ' wait in between sending 200 milliseconds
                                            Threading.Thread.Sleep(200)
                                        End If
                                    End If
                                    If Not mActive Then Exit Sub
                                Next
                                Done = True
                            Catch ex As Exception
                            End Try
                        End While
                        mScanStage = 3
                    Case Else
                        ' we're done, (or something is wrong)
                        RemoveHandler mScanTimer.Elapsed, AddressOf ScanTimerElapsed
                        mScanTimer.Dispose()
                        mScanTimer = Nothing
                        If mScanStage = 3 And Not mScanCallback Is Nothing Then
                            ' call the callback method, async is complete
                            Try
                                mScanCallback.Invoke()
                            Catch ex As Exception
                                LogError("NetworkScanASync", "Callback returned an exception: " & ex.ToString)
                            End Try
                        End If
                End Select
            Catch ex As Exception

            End Try
        End If
        If Not mScanTimer Is Nothing Then mScanTimer.Start()
    End Sub

#End Region

#Region "Basic messages"

    ''' <summary>
    ''' Sends out a heartbeat request from the specified xPLDevice to the target address
    ''' </summary>
    ''' <param name="xPLDev"><c>xPLDevice</c> object used as source of the heartbeat request</param>
    ''' <param name="Target">string with target address the heartbeat is requested from. If not specified
    ''' a wildcard "*" is used, requesting the entire xPL network to send a heartbeat.</param>
    ''' <remarks></remarks>
    ''' <exception cref="NullReferenceException">Condition: xPLDev <c>Is Nothing</c></exception>
    ''' <exception cref="IllegalIDsInAddress">Condition: <c>target</c> is not a valid xPLAddress</exception>
    Public Shared Sub RequestHeartbeat(ByVal xPLDev As xPLDevice, Optional ByVal Target As String = "*")
        Dim hbr As New xPLMessage
        If xPLDev Is Nothing Then Throw New NullReferenceException("xPLDev value not set")
        With hbr
            .MsgType = xPLMessageTypeEnum.Command
            .Source = xPLDev.Address
            .Target = Target
            .Schema = "hbeat.request"
            .KeyValueList.Add(New xPLKeyValuePair("command", "request"))
            .Send(xPLDev)
        End With
    End Sub

    ''' <summary>
    ''' Sends out a config.list request from the specified xPLDevice to the target address
    ''' </summary>
    ''' <param name="xPLDev"><c>xPLDevice</c> object used as source of the config.list request</param>
    ''' <param name="Target">string with target address the config.list is requested from.</param>
    ''' <remarks></remarks>
    ''' <exception cref="NullReferenceException">Condition: xPLDev <c>Is Nothing</c></exception>
    ''' <exception cref="IllegalIDsInAddress">Condition: <c>target</c> is not a valid xPLAddress</exception>
    Public Shared Sub RequestConfigList(ByVal xPLDev As xPLDevice, ByVal Target As String)
        Dim hbr As New xPLMessage
        If xPLDev Is Nothing Then Throw New NullReferenceException("xPLDev value not set")
        With hbr
            .MsgType = xPLMessageTypeEnum.Command
            .Source = xPLDev.Address
            .Target = Target
            .Schema = "config.list"
            .KeyValueList.Add(New xPLKeyValuePair("command", "request"))
            .Send(xPLDev)
        End With
    End Sub

    ''' <summary>
    ''' Sends out a config.current request from the specified xPLDevice to the target address
    ''' </summary>
    ''' <param name="xPLDev"><c>xPLDevice</c> object used as source of the config.current request</param>
    ''' <param name="Target">string with target address the config.list is requested from.</param>
    ''' <remarks></remarks>
    ''' <exception cref="NullReferenceException">Condition: xPLDev <c>Is Nothing</c></exception>
    ''' <exception cref="IllegalIDsInAddress">Condition: <c>target</c> is not a valid xPLAddress</exception>
    Public Shared Sub RequestConfigCurrent(ByVal xPLDev As xPLDevice, ByVal Target As String)
        Dim hbr As New xPLMessage
        If xPLDev Is Nothing Then Throw New NullReferenceException("xPLDev value not set")
        With hbr
            .MsgType = xPLMessageTypeEnum.Command
            .Source = xPLDev.Address
            .Target = Target
            .Schema = "config.current"
            .KeyValueList.Add(New xPLKeyValuePair("command", "request"))
            .Send(xPLDev)
        End With
    End Sub

#End Region

End Class