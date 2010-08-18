'* xPL Library for .NET
'*
'* Version 5.2
'*
'* Copyright (c) 2009-2010 Thijs Schreijer
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
Imports Microsoft.Win32
Imports System.Net
Imports System.Net.Sockets
Imports System.Text
Imports xPL.xPL_Base

''' <summary>
''' The listener actually connects to the network and keeps track of all <c>xPLDevice</c> objects and
''' feeds the <c>xPLNetwork</c> object with xPL network information.
''' The listener object only has shared members, no instances can be created.
''' </summary>
''' <remarks></remarks>
Public Class xPLListener

    ' Networking stuff
    Private Shared sockIncoming As Socket = Nothing    ' Socket to handle incoming messages
    Private Shared epIncoming As IPEndPoint = Nothing  ' Endpoint for incoming messages
    Private Shared XPL_Buff(XPL_MAX_MSG_SIZE) As Byte  ' Buffer to store incoming messages
    Private Shared XPL_Portnum As Integer              ' Port used for listening
    Private Shared mLocalIPs As ArrayList              ' Local IPAddress(es)
    Private Shared mListenOnIP As IPAddress = Nothing  ' address we'll be listening on
    Private Shared mListenOnIPstr As String            ' Address listening on, in string format
    Private Shared mListenToIPs() As String            ' string array with IP adresses to listen to
    Private Shared mBroadcastAddress As IPAddress      ' IP address to broadcast messages to
    Private Shared mDevices As New ArrayList            ' holds all my devices

    Private Shared mActive As Boolean = False
    Private Shared LCTimer As Timers.Timer = Nothing   ' Timer incase network connection fails

    ''' <summary>
    ''' Event that is raised if data has been received that cannot be parsed into a valid xPL message object
    ''' </summary>
    ''' <param name="RawxPL">Contains the raw xPL data received from the network</param>
    ''' <remarks></remarks>
    Public Shared Event InvalidMessageReceived(ByVal RawxPL As String)

#Region "Construction, initialisation and destruction of XplListener"

    ' Everything is declared Shared, so there are no real constructors/destructors
    Private Sub New()   ' prevent anyone from creating an instance because its private
    End Sub

    Friend Shared Sub Initialize()
        If mActive Then Exit Sub
        ' Set active
        mActive = True
        ' go setup network
        RenewConnection()
        ' start watching the xPL network
        xPLNetwork.StartPassiveScan()
        LogError("xPLListener.Initialize", "Initialization completed")
    End Sub

    ''' <summary>
    ''' Shutsdown all <c>xPLDevices</c> by calling their <c>Dispose</c> method and cleans up the timer objects.
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub Shutdown()
        If Not mActive Then Exit Sub

        LogError("xPLListener.Shutdown", "Shutdown started")

        ' cleanup devices
        Dim xdev As xPLDevice
        For i As Integer = mDevices.Count - 1 To 0 Step -1
            Try
                xdev = CType(mDevices(i), xPLDevice)
                mDevices.RemoveAt(i)
                xdev.Dispose()
                xdev = Nothing
            Catch ex As Exception
                LogError("xPLListener.Shutdown", "Error shuttingdown device " & i & ": " & ex.Message)
            End Try
        Next

        ' Set mActive to False AFTER destroying the devices, otherwise the devices won't be able to sent a proper END message
        mActive = False

        ' Stop watching xPL network
        xPLNetwork.StopScan()

        ' cleanup timers
        Try
            If Not LCTimer Is Nothing Then
                LCTimer.Stop()
                RemoveHandler LCTimer.Elapsed, AddressOf TimerElapsed
                LCTimer = Nothing
            End If
        Catch ex As Exception
            LogError("xPLListener.Shutdown", "Error shutting down LCTimer: " & ex.Message)
        End Try

        ' cleanup network
        Try
            ' close sockets
            sockIncoming.Shutdown(SocketShutdown.Both)
            sockIncoming.Close()
        Catch ex As Exception
            LogError("xPLListener.Shutdown", "Error shuttingdown sockets: " & ex.Message)
        End Try
    End Sub

#End Region

#Region "Properties"

    ''' <returns>The IP address the listener is listening on for incoming messages from the hub.</returns>
    ''' <remarks>If the listener is inactive, an empty string ("") is returned</remarks>
    Public Shared ReadOnly Property IPaddress() As String
        Get
            If Not IsActive Then Return ""
            'put the IP address that we are actually listening on in the heartbeat
            Dim sip As String = mListenOnIPstr
            'if what is configured is not a real local ip, then make a best guess: take the first
            If Not mLocalIPs.Contains(sip) Then sip = mLocalIPs(0).ToString()
            Return sip
        End Get
    End Property

    ''' <returns>The port number the listener is listening on for incoming messages from the hub.</returns>
    ''' <remarks>If the listener is inactive, -1 is returned</remarks>
    Public Shared ReadOnly Property PortNumber() As Integer
        Get
            If Not IsActive Then Return -1
            Return XPL_Portnum
        End Get
    End Property

    ''' <summary>
    ''' Índicates whether the listener is active (eg. initialized)
    ''' </summary>
    ''' <returns><c>True</c> if the listener is active</returns>
    ''' <remarks>The listener is considered active if at least 1 device is in its device collection. Even if the
    ''' device is not enabled, the listener is still considered active.</remarks>
    Public Shared ReadOnly Property IsActive() As Boolean
        Get
            Return mActive
        End Get
    End Property

#End Region

#Region "Collection management"

    ''' <returns>The number of <c>Enabled</c> xplDevices</returns>
    ''' <remarks>If the listener isn't active, 0 is returned, no exception will be thrown</remarks>
    Public Shared ReadOnly Property Count() As Integer
        Get
            If Not IsActive Then
                Return 0
            Else
                Return xPLListener.mDevices.Count
            End If
        End Get
    End Property

    ''' <summary>
    ''' Use this method to retrieve individual <c>xPLDevice</c> objects from the listeners device list by their index.
    ''' </summary>
    ''' <param name="idx">Index of the xPLDevice to be returned from the list</param>
    ''' <returns>The <c>xPLDevice</c> object at position <c>idx</c> in the device list</returns>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less then 0 or greater than or equal to <c>xPLDeviceCount</c>.</exception>
    Public Shared ReadOnly Property Device(ByVal idx As Integer) As xPLDevice
        Get
            If Not IsActive Then Return Nothing
            If idx < 0 Or idx >= xPLListener.mDevices.Count Then
                Throw New ArgumentOutOfRangeException
            End If
            Return CType(xPLListener.mDevices(idx), xPLDevice)
        End Get
    End Property

    ''' <summary>
    ''' Use this method to retrieve individual <c>xPLDevice</c> objects from the listeners device list by their <c>CustomID</c>.
    ''' </summary>
    ''' <param name="CustomID"><c>CustomID</c> value of the xPLDevice to be returned from the list</param>
    ''' <returns>The first <c>xPLDevice</c> object in the device list with this <c>CustomID</c></returns>
    ''' <remarks>If the listener is inactive or the <c>CustomID</c> isn't found <c>Nothing</c> is returned, no exception will be thrown.</remarks>
    Public Shared ReadOnly Property Device(ByVal CustomID As String) As xPLDevice
        Get
            If Not IsActive Then Return Nothing
            For Each xdev As xPLDevice In xPLListener.mDevices
                If xdev.CustomID = CustomID Then Return xdev
            Next
            Return Nothing
        End Get
    End Property

    ''' <summary>
    ''' Use this method to retrieve individual <c>xPLDevice</c> objects from the listeners device list by their xPL address.
    ''' </summary>
    ''' <param name="Address"><c>xPLAddress</c> object with address of the xPLDevice to be returned from the list</param>
    ''' <returns>The first <c>xPLDevice</c> object in the device list with this xPL address</returns>
    ''' <remarks>If the listener is inactive, <c>Address Is Nothing</c> or the <c>Address</c> isn't found <c>Nothing</c> is returned, no exception will be thrown.</remarks>
    Public Shared ReadOnly Property Device(ByVal Address As xPLAddress) As xPLDevice
        Get
            Dim Addr As String
            If Not IsActive Then Return Nothing
            If Address Is Nothing Then Return Nothing
            Addr = Address.ToString
            For Each xdev As xPLDevice In xPLListener.mDevices
                If xdev.Address = Addr Then Return xdev
            Next
            Return Nothing
        End Get
    End Property

    ''' <summary>
    ''' Returns the index of a <c>xPLDevice</c> object by its <c>CustomID</c>
    ''' </summary>
    ''' <param name="CustomID">ID being sought</param>
    ''' <returns>Index of the first <c>xPLDevice</c> object from the list with a matching <c>CustomID</c> value</returns>
    ''' <remarks></remarks>
    Public Shared Function IndexOf(ByVal CustomID As String) As Integer
        Dim n As Integer = 0
        Dim xdev As xPLDevice
        For n = 0 To mDevices.Count - 1
            xdev = CType(mDevices(n), xPLDevice)
            If xdev.CustomID = CustomID Then
                Return n
            End If
        Next
        Return -1
    End Function

    ''' <summary>
    ''' Returns the index of a <c>xPLDevice</c> object by its xPL address
    ''' </summary>
    ''' <param name="Address"><c>xPLAddress</c> object containing the address being sought</param>
    ''' <returns>Index of the <c>xPLDevice</c> object from the list with a matching <c>Address</c> value</returns>
    ''' <remarks></remarks>
    Public Shared Function IndexOf(ByVal Address As xPLAddress) As Integer
        Dim n As Integer = 0
        Dim xdev As xPLDevice
        Dim addr As String
        If Address Is Nothing Then Return -1
        addr = Address.ToString
        For n = 0 To mDevices.Count - 1
            xdev = CType(mDevices(n), xPLDevice)
            If xdev.Address = addr Then
                Return n
            End If
        Next
        Return -1
    End Function

    ''' <summary>
    ''' Adds the device to the list
    ''' </summary>
    ''' <param name="xdev">Device to be added</param>
    ''' <remarks></remarks>
    Friend Shared Sub Add(ByVal xdev As xPLDevice)
        If xdev Is Nothing Then Exit Sub
        If xdev.Debug Then
            LogError("xPLListener.Add", "Adding " & xdev.Address)
        End If
        If Not mActive Then
            Initialize()
        End If
        If mDevices.IndexOf(xdev) = -1 Then
            ' not in the list yet, so add it
            mDevices.Add(xdev)
            If xdev.Debug Then
                LogError("xPLListener.Add", "Success adding " & xdev.Address)
            End If
        Else
            If xdev.Debug Then
                LogError("xPLListener.Add", "Not added; " & xdev.Address & ",  already in the list")
            End If
        End If
    End Sub

    ''' <summary>
    ''' Removes the device from the list
    ''' </summary>
    ''' <param name="xdev">Device to be removed</param>
    ''' <remarks></remarks>
    Friend Shared Sub Remove(ByVal xdev As xPLDevice)
        If Not mActive Then Exit Sub
        mDevices.Remove(xdev)
        If xdev.Debug Then
            LogError("xPLListener.Remove", "Removed " & xdev.Address)
        End If
        If mDevices.Count = 0 Then
            ' No more devices, dispose myself
            If xdev.Debug Then
                LogError("xPLListener.Remove", "No devices left, shutting listener down")
            End If
            xPLListener.Shutdown()
        End If
    End Sub

#End Region

#Region "Store and restore states"

    ''' <summary>
    ''' Recreates all xPLDevices from a SavedState string. Any existing devices will first be removed (disposed).
    ''' </summary>
    ''' <param name="SavedState">SavedState string containing all parameters to recreate the entire list of 
    ''' xPLDevices and the <see cref="xPLNetwork.NetworkKeepEnded"/> setting. It can be created by calling the <c>GetState</c> method.</param>
    ''' <param name="RestoreEnabled">If <c>True</c>, the <c>Enabled</c> property for the devices will be set as recorded 
    ''' in the SavedState string, if set to <c>False</c> the devices will not be Enabled, independent of the 
    ''' setting stored in the SavedState string.</param>
    ''' <remarks>The SavedState string can be obtained from the <c>GetState</c> method. If the <c>SavedState</c> string is an 
    ''' empty string ("") then all currently existing devices will be disposed of and no new ones will be created. Before 
    ''' recreating the devices, the <see cref="StateAppVersion"/> method can be used the check the application version that created
    ''' the SavedState string.</remarks>
    ''' <exception cref="Exception">Condition: An individual device returned an exception upon recreating it from its
    ''' SavedState string.</exception>
    ''' <exception cref="ArgumentException">Condition: SavedState string was created by a newer/unknown version of xpllib 
    ''' and can not be handled</exception>
    Public Shared Sub RestoreFromState(ByVal SavedState As String, ByVal RestoreEnabled As Boolean)
        Dim lst() As String
        Dim xdev As xPLDevice
        Dim xversion As String
        Dim aversion As String
        Dim i As Integer = 0
        If IsActive Then
            LogError("xPLListener.RestoreFromState", "Listener is still active, start shutdown to dispose existing devices")
            ' dispose listener, will also shutdown all devices
            xPLListener.Shutdown()
        End If

        If SavedState = "" Then Exit Sub ' no state to restore

        ' split string in settings for individual devices
        lst = SavedState.Split(XPL_STATESEP)
        i = 0
        ' get version of xpllib that created it
        xversion = StateDecode(lst(i))
        i += 1
        ' get version of the application that created it
        aversion = StateDecode(lst(i))
        i += 1

        LogError("xPLListener.RestoreFromState", "State created by; AppVersion = " & aversion & ", xPLLib version = " & xversion)

        Select Case xversion
            Case "5.0", "5.1", "5.2"
                ' get settings for xPLNetwork object
                xPLNetwork.NetworkKeepEnded = Boolean.Parse(StateDecode(lst(i)))
                i += 1
                ' for each device recreate it
                While i <= lst.Length - 1
                    Try
                        xdev = New xPLDevice(StateDecode(lst(i)), RestoreEnabled)
                    Catch ex As Exception
                        Dim e As String = "Device " & i & " could not be recreated from State value!"
                        LogError("xPLListener.RestoreFromState", e & " Error: " & ex.Message)
                        Throw New Exception(e, ex)
                    End Try
                    i += 1
                End While
            Case Else
                ' SavedState created by an unknown version of xpllib
                LogError("xPLListener.RestoreFromState", "State created by unknown version of xPLLib: " & xversion & ".")
                Throw New ArgumentException("SavedState value was created by an unknown version of xpllib: " & xversion, "SavedState")
        End Select
    End Sub

    ''' <summary>
    ''' Returns a SavedState string enabling the persistence of configuration information of a list of devices.
    ''' </summary>
    ''' <returns>A SavedState string, containing all configuration info from the devices in the list and the 
    ''' <see cref="xPLNetwork.NetworkKeepEnded"/> property value.</returns>
    ''' <param name="AppVersion">Version information of the host application.</param>
    ''' <remarks>The SavedState string can be used with the <c>xPLListener.NewFromState</c>
    ''' method to recreate the device list in the exact same state, including the settings of the <see cref="xPLNetwork"/>
    ''' object.</remarks>
    Public Shared Function GetState(ByVal AppVersion As String) As String
        Dim s As String = ""
        If IsActive Then
            LogError("xPLListener.GetState", "Creating state for; AppVersion = " & AppVersion & ", xPLLib version = " & XPL_LIB_VERSION)
            ' start with xpllib version
            s = StateEncode(XPL_LIB_VERSION)
            ' get version of the application that created it
            s += XPL_STATESEP & StateEncode(AppVersion)

            ' add xPLNetwork settings
            s += XPL_STATESEP & StateEncode(xPLNetwork.NetworkKeepEnded.ToString)
            ' now add all devices
            For Each xdev As xPLDevice In xPLListener.mDevices
                s += XPL_STATESEP & StateEncode(xdev.GetState(AppVersion))
            Next
            LogError("xPLListener.GetState", "Success")
        Else
            LogError("xPLListener.GetState", "Listener is not active, empty string returned")
        End If
        Return s
    End Function

#End Region

#Region "Device Management"

    ''' <summary>
    ''' inform my devices that the network address; IP address or Port number have changed.
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared Sub NewAddress()
        If Not mActive Then Exit Sub
        LogError("xPLListener.NewAddress", "Start informing devices of new address;" & vbCrLf & _
                 "    IP address : " & IPaddress & vbCrLf & _
                 "    Port number: " & PortNumber.ToString)
        For Each xdev As xPLDevice In mDevices
            Try
                xdev.IPaddressChange()
            Catch ex As Exception
                LogError("xPLListener.NewAddress", "Error informing " & xdev.Address & _
                         "; " & ex.Message, EventLogEntryType.Error)
            End Try
        Next
    End Sub

    ''' <summary>
    ''' Calling this method informs the Listener that the device has lost connection and the listener needs to renew the network settings.
    ''' </summary>
    ''' <remarks>From a device perspective this method should be called when status goes from <c>Online</c> back to <c>Connecting</c>, or 
    ''' when the <c>XPL_NOHUB_TIMEOUT</c> expires. As these are the two occurences at which no network seems to be available.</remarks>
    Friend Shared Sub ReportLostConnection()
        If Not LCTimer Is Nothing Then
            ' timer is already running, so nothing to do...
        Else
            LogError("xPLListener.ReportLostConnection", "Starting network renewal timer")
            TimerElapsed(Nothing, Nothing)
        End If
    End Sub

    Private Shared Sub TimerElapsed(ByVal sender As Object, ByVal e As Timers.ElapsedEventArgs)
        Dim conn As Boolean = False
        Dim enab As Boolean = False
        Try
            ' stop timer
            If Not LCTimer Is Nothing Then LCTimer.Stop()
            ' Check if there is at least 1 device still online
            For Each xdev As xPLDevice In mDevices
                If xdev.Enabled Then enab = True ' There's at least 1 enabled device
                If xdev.Enabled And xdev.Status = xPLDeviceStatus.Online Then
                    conn = True
                    Exit For
                End If
            Next
            If Not enab Then
                conn = True     ' if there is not at least 1 enabled device, then assume we're connected and stop trying.
            End If
            ' check if we're connecte to the loopback adapter
            If conn Then
                If mLocalIPs.Count = 1 Then
                    If CStr(mLocalIPs(0)) = System.Net.IPAddress.Loopback.ToString() Then
                        ' we're connected to the loopback, so actually we're not connected....
                        conn = False
                        LogError("xPLListener.TimerElapsed", "Currently connected to loopback adapter")
                    End If
                End If
            End If

            If Not conn Then
                ' No device is online, so reset network settings
                If LCTimer Is Nothing Then
                    ' create timer if it doesn't exist
                    LCTimer = New Timers.Timer
                    LCTimer.Interval = XPL_NETWORK_RESET_TIMEOUT * 1000 '  (milliseconds)
                    AddHandler LCTimer.Elapsed, AddressOf TimerElapsed
                    LCTimer.AutoReset = False
                End If
                ' update settings and start timer
                RenewConnection()
            Else
                ' there is at least one device online, so if timer exists, dismiss it
                If Not LCTimer Is Nothing Then
                    RemoveHandler LCTimer.Elapsed, AddressOf TimerElapsed
                    LCTimer = Nothing
                End If
            End If
        Catch ex As Exception
            LogError("xPLListener.TimerElapsed", "Error: " & ex.ToString)
        Finally
            ' restart timer
            If Not LCTimer Is Nothing Then LCTimer.Start()
        End Try
    End Sub

#End Region

#Region "IP Communication, socket, msg sending"

    Private Shared Sub RenewConnection()
        Dim i As Integer
        Dim s As String
        Dim RegKey As RegistryKey = Nothing

        '
        ' Cleanup existing stuff
        '
        Try
            If Not sockIncoming Is Nothing Then
                sockIncoming.Shutdown(SocketShutdown.Both)
                sockIncoming.Close()
                sockIncoming = Nothing
            End If
            If Not mListenOnIP Is Nothing Then mListenOnIP = Nothing
            If Not epIncoming Is Nothing Then epIncoming = Nothing
        Catch ex As Exception
        End Try

        '
        ' renew the local IP Addresses list
        '
        mLocalIPs = New ArrayList
        Try
            'Get the Host by Name
            Dim ipHost As IPHostEntry = Dns.GetHostEntry(Dns.GetHostName())
            ' add IP adresses to return list
            For Each IP As IPAddress In ipHost.AddressList
                If InStr(IP.ToString, ".") <> 0 Then
                    ' contains a dot '.' so must be an IPv4 address
                    mLocalIPs.Add(IP.ToString)
                End If
            Next
            ' if nothing else found, add loopback address
            If mLocalIPs.Count = 0 Then
                mLocalIPs.Add(System.Net.IPAddress.Loopback.ToString())
            End If
        Catch ex As Exception
            LogError("xPLListener.RenewConnection: ", "Error looking for local ip address(es): " & ex.Message)
        End Try

        '
        ' What IP address to broadcast to?
        '

        ' get settings from registry
        Try
            RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
            s = Trim(CStr(RegKey.GetValue("BroadcastAddress", XPL_DEFAULT_BROADCAST)))
        Catch ex As Exception
            ' couldn't read from registry, set default value
            s = XPL_DEFAULT_BROADCAST
        End Try
        If Not RegKey Is Nothing Then
            RegKey.Close()
        End If
        ' Parse setting to IP address object
        Try
            mBroadcastAddress = System.Net.IPAddress.Parse(s)
        Catch ex As Exception
            LogError("xPLListener.RenewConnection: ", "Could not parse broadcastaddress '" & s & "' to a valid IP address")
            mBroadcastAddress = System.Net.IPAddress.Broadcast
        End Try

        '
        ' What IP address to listen on?
        '

        ' first read settings from the registry
        Try
            RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
            mListenOnIPstr = CStr(RegKey.GetValue("ListenOnAddress", XPL_DEFAULT_LISTENON))
        Catch ex As Exception
            mListenOnIPstr = XPL_DEFAULT_LISTENON     ' default value
        Finally
            If Not RegKey Is Nothing Then
                RegKey.Close()
            End If
        End Try
        ' Now convert registry settings into a valid IP address (if necessary)
        If mListenOnIPstr = XPL_DEFAULT_LISTENON Then
            mListenOnIP = System.Net.IPAddress.Any
        Else
            Try
                mListenOnIP = System.Net.IPAddress.Parse(mListenOnIPstr)
            Catch ex As Exception
                LogError("xPLListener.RenewConnection: ", "Could not decode to valid IPAddress to listen on: " & mListenOnIPstr & ". " & ex.Message)
            End Try
        End If

        '
        ' What IP adresses to listen to
        '
        Try
            RegKey = Registry.LocalMachine.OpenSubKey("Software\xPL")
            s = CStr(RegKey.GetValue("ListenToAddresses", XPL_DEFAULT_LISTENTO))
        Catch ex As Exception
            s = XPL_DEFAULT_LISTENTO      ' set to default
        Finally
            If Not RegKey Is Nothing Then
                RegKey.Close()
            End If
        End Try
        mListenToIPs = s.Split(","c)
        For i = 0 To mListenToIPs.Length - 1
            mListenToIPs(i) = mListenToIPs(i).Trim()
        Next


        ' Start network communications
        sockIncoming = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)

        i = XPL_BASE_DYNAMIC_PORT
        ' Bind to the port for listening, try 512 ports before giving in...
        While i < XPL_BASE_DYNAMIC_PORT + 512 And Not i = 0
            Try
                sockIncoming.Bind(New IPEndPoint(mListenOnIP, i))
                XPL_Portnum = i
                i = 0                 ' to exit loop
            Catch ex As Exception
                i += 1
                sockIncoming = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
            End Try
        End While

        ' if i <> 0 then I ran through 512 ports, and not being able to bind to any of them....  report error
        If i <> 0 Then
            LogError("xPLListener.RenewConnection: ", "Unable to bind to a free UDP port for listening.")
            Throw New Exception("Unable to bind to a free UDP port for listening.")
        End If

        ' Add a listener for incoming data
        epIncoming = New IPEndPoint(System.Net.IPAddress.Any, 0)
        sockIncoming.BeginReceiveFrom(XPL_Buff, 0, XPL_MAX_MSG_SIZE, SocketFlags.None, CType(epIncoming, EndPoint), AddressOf ReceiveData, Nothing)

        ' update devices; inform them of new IP and Port info
        NewAddress()

    End Sub

    Private Shared Sub ReceiveData(ByVal ar As IAsyncResult)
        'during shutdown, stop listening
        If Not mActive Then Exit Sub

        Dim ep As EndPoint = CType(epIncoming, EndPoint)
        Dim bytes_read As Integer
        Try
            bytes_read = sockIncoming.EndReceiveFrom(ar, ep)
        Catch ex As Exception
            Exit Sub
        End Try
        epIncoming = CType(ep, IPEndPoint)
        Dim myXPL As xPLMessage
        Dim rawXPL As String = ""

        'check origin
        Dim accept As Boolean = False
        Dim i As Integer = 0
        While ((Not accept) And (i < mListenToIPs.Length))
            If mListenToIPs(i).ToUpper() = XPL_DEFAULT_LISTENTO Then
                accept = True
            Else
                'don't accept candy from a stranger
                If mListenToIPs(i).ToUpper() = XPL_DEFAULT_LISTENON Then
                    ' if the incoming data is from a local address (in LocalIP list) then accept it, as HUB must be local.
                    accept = mLocalIPs.Contains(epIncoming.Address.ToString())
                ElseIf mListenToIPs(i) = epIncoming.Address.ToString() Then
                    ' only accept if its an exact match
                    accept = True
                End If
            End If
            i += 1
        End While

        If accept Then

            Try
                ' parse raw xpl into a message object
                rawXPL = Encoding.ASCII.GetString(XPL_Buff, 0, bytes_read)
                myXPL = New xPLMessage(rawXPL)
            Catch ex As Exception
                LogError("xPLListener.ReceiveData", "Error: " & ex.ToString() & vbCrLf & rawXPL & vbCrLf & HexDump(rawXPL))

                Try
                    RaiseEvent InvalidMessageReceived(rawXPL)
                Catch
                End Try

                rawXPL = ""
                myXPL = Nothing
            End Try

            ' Valid message has been received
            If rawXPL <> "" Then
                ' update what we know from the network by what we learn from this message
                xPLNetwork.MessageReceived(myXPL)
                ' Distribute to enlisted devices
                For i = 0 To mDevices.Count - 1
                    ' create new message instance for each device to prevent interference
                    myXPL = New xPLMessage(rawXPL)
                    Try
                        CType(mDevices(i), xPLDevice).IncomingMessage(myXPL)
                    Catch
                    End Try
                Next
            End If
        End If

        Try
            sockIncoming.BeginReceiveFrom(XPL_Buff, 0, XPL_MAX_MSG_SIZE, SocketFlags.None, ep, AddressOf ReceiveData, Nothing)
        Catch ex As Exception
            If mDevices.Count <> 0 Then
                LogError("xPLListener.ReceiveData", ex.ToString)
            End If
        End Try
    End Sub

    ''' <summary>
    ''' Sends a raw xPL string.
    ''' </summary>
    ''' <param name="RawxPL">The raw xPL string that needs to be sent.</param>
    ''' <exception cref="Exception">Condition: The network returned an exception when sending, or the 
    ''' network was not yet initialized by the xPLListener (at least one xPLDevice object must have been created for this, but 
    ''' there is no need for that device to be enabled, just creating it will initialize the xPLListener)</exception>
    ''' <remarks>NOTE: no verification of any kind will be done on the string provided. It will simply be sent.</remarks>
    Public Shared Sub SendRawxPL(ByVal RawxPL As String)
        If Not mActive Then
            Throw New Exception("Cannot sent the message because the network has not been " & _
                "initialized by the xPLListener. Create at least 1 xPLDevice object to achieve this.")
        Else
            ' try and send the message
            Try
                SendData(RawxPL)
            Catch ex As Exception
                Throw New Exception("Failed to send the xPL message: " & ex.Message, ex)
            End Try
        End If
    End Sub

    Private Shared Sub SendData(ByVal RawXPL As String)
        Dim s As Socket
        Dim ep As IPEndPoint
        s = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
        ep = New IPEndPoint(mBroadcastAddress, XPL_BASE_PORT)

        s.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, 1)

        'See if we need to specify a source IP for the broadcast
        Dim sIP As String = mListenOnIPstr
        If sIP <> XPL_DEFAULT_LISTENON Then
            Dim a As IPAddress = System.Net.IPAddress.Parse(sIP)
            Dim lep As New IPEndPoint(a, 0)
            s.Bind(lep)
        End If

        s.SendTo(Encoding.ASCII.GetBytes(RawXPL), ep)
        s.Close()
    End Sub

#End Region

End Class
