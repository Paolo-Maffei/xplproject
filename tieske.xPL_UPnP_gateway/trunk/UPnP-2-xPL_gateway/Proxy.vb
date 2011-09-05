Option Explicit On

Imports xPL
Imports xPL.xPL_Base
Imports OpenSource.UPnP
Imports System.Xml

Public Class Proxy
    ''' <summary>
    ''' The proxy type indication
    ''' </summary>
    ''' <remarks></remarks>
    Enum ProxyType
        Device
        Service
        Method
        Variable
        Argument
    End Enum

    ''' <summary>
    ''' Shared clounter that provides the unique ID, can be gotten from <see cref="GetNewID">GetNewID</see>.
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared _Counter As Integer = 0
    ''' <summary>
    ''' Lock object to protect <see cref="_Counter">_Counter</see> and <see cref="_Proxylist">_ProxyList</see>.
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared _SharedLock As Object = New Object
    ''' <summary>
    ''' Gets a new unique proxy ID
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetNewID() As Integer
        SyncLock _SharedLock
            _Counter += 1
            Return _Counter
        End SyncLock
    End Function
    ''' <summary>
    ''' List containing all proxies, use the GetProxy functions to returnd them
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared _Proxylist As New System.Collections.ObjectModel.Collection(Of Proxy)
    ''' <summary>
    ''' Adds a proxy to the ProxyList, doesn't check whether it already exists.  Use the <see cref="AddDevice">AddDevice</see> method to add
    ''' proxies, that's also where the double entry check is done
    ''' </summary>
    ''' <param name="p"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function AddProxy(ByVal p As Proxy) As Integer
        p._ID = GetNewID()
        SyncLock _SharedLock
            _Proxylist.Add(p)
        End SyncLock
        Return p.ID
    End Function
    Private _ID As Integer = 0
    ''' <summary>
    ''' Unique ID of the proxy
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property ID() As Integer
        Get
            Return _ID
        End Get
    End Property
    Private _Type As ProxyType = ProxyType.Device
    ''' <summary>
    ''' Type of the proxy, what type of object does it represent
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Type() As ProxyType
        Get
            Return _Type
        End Get
    End Property
    Private _Device As UPnPDevice = Nothing
    Public ReadOnly Property Device() As UPnPDevice
        Get
            Return _Device
        End Get
    End Property
    Private Shared _OldxPLAddress As String

    Private Shared WithEvents _xPLDevice As xPLDevice = Nothing
    Public Shared Property xPLDevice() As xPLDevice
        Get
            Return _xPLDevice
        End Get
        Set(ByVal value As xPLDevice)
            If value Is Nothing Then Throw New NullReferenceException
            _xPLDevice = value
            _OldxPLAddress = _xPLDevice.Address
        End Set
    End Property


    Private _Service As UPnPService = Nothing
    Public ReadOnly Property Service() As UPnPService
        Get
            Return _Service
        End Get
    End Property
    Private _Method As UPnPAction = Nothing
    Public ReadOnly Property Method() As UPnPAction
        Get
            Return _Method
        End Get
    End Property
    Private _Variable As UPnPStateVariable = Nothing
    Public ReadOnly Property Variable() As UPnPStateVariable
        Get
            Return _Variable
        End Get
    End Property
    Private _Argument As UPnPArgument = Nothing
    Public ReadOnly Property Argument() As UPnPArgument
        Get
            Return _Argument
        End Get
    End Property

    ''' <summary>
    ''' Auxilary function for <see cref="Create">Create</see>.
    ''' </summary>
    ''' <param name="TypeSet"></param>
    ''' <param name="T"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function SetType(ByVal TypeSet As Boolean, ByVal T As ProxyType) As Boolean
        If Not TypeSet Then _Type = T
        Return True
    End Function

    ''' <summary>
    ''' Private, so proxies can only be created through the <see cref="AddDevice">AddDevice</see> method
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub New()
        ' nothing here, just private to prevent creation externally
    End Sub
    Private Shared CreateLock As New Object
    ''' <summary>
    ''' Creates a proxy from an object, either; device, service, statevariable, method or argument objects
    ''' </summary>
    ''' <param name="obj"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function Create(ByVal obj As Object, ByVal logger As LogMessageDelegate) As Proxy
        Dim p As New Proxy
        SyncLock CreateLock
            _LogMessage = logger
            Dim TypeSet As Boolean = False
            If TypeOf obj Is UPnPArgument Then
                ' its an argument to a method
                p._Argument = CType(obj, UPnPArgument)
                TypeSet = p.SetType(TypeSet, ProxyType.Argument)
                obj = p._Argument.ParentAction
            End If
            If TypeOf obj Is UPnPAction Then
                ' its a method
                p._Method = CType(obj, UPnPAction)
                TypeSet = p.SetType(TypeSet, ProxyType.Method)
                obj = p._Method.ParentService
            End If
            If TypeOf obj Is UPnPStateVariable Then
                ' its a statevariable
                p._Variable = CType(obj, UPnPStateVariable)
                TypeSet = p.SetType(TypeSet, ProxyType.Variable)
                obj = p._Variable.OwningService
            End If
            If TypeOf obj Is UPnPService Then
                ' its a service
                p._Service = CType(obj, UPnPService)
                TypeSet = p.SetType(TypeSet, ProxyType.Service)
                obj = p._Service.ParentDevice
            End If
            If TypeOf obj Is UPnPDevice Then
                p._Device = CType(obj, UPnPDevice)
                TypeSet = p.SetType(TypeSet, ProxyType.Device)
                obj = Nothing
            Else
                LogMessage("ERROR: While creating a Proxy object an unknown type was encountered; " & obj.GetType.ToString)
            End If
            ' so by now all relevant properties have been set

            ' check if I'm already in the list, if so, return existing instance
            Select Case p.Type
                Case ProxyType.Device
                    If GetProxy(p.Device) IsNot Nothing Then Return GetProxy(p.Device)
                Case ProxyType.Service
                    If GetProxy(p.Service) IsNot Nothing Then Return GetProxy(p.Service)
                Case ProxyType.Method
                    If GetProxy(p.Method) IsNot Nothing Then Return GetProxy(p.Method)
                Case ProxyType.Variable
                    If GetProxy(p.Variable) IsNot Nothing Then Return GetProxy(p.Variable)
                Case ProxyType.Argument
                    If GetProxy(p.Argument) IsNot Nothing Then Return GetProxy(p.Argument)
                Case Else
                    LogMessage("ERROR: Unknown ProxyType, please update source code")
            End Select
            ' I wasn't in the list, so I'm new and ready to be added

            ' Subscribe to UPnP service to receive its events
            If p.Type = ProxyType.Service Then
                AddHandler p.Service.OnUPnPEvent, AddressOf p.UPnPServiceEventHandler
                p.Service.Subscribe(900, Nothing)
                LogMessage("   Now subscribing to the events of service; " & p.Service.ServiceID)
            End If
            ' add handler for variable updates
            If p.Type = ProxyType.Variable Then
                AddHandler p.Variable.OnModified, AddressOf p.UPnPValueChange
            End If
        End SyncLock

        Proxy.AddProxy(p)
        Return p
    End Function
    ''' <summary>
    ''' Returns a proxy from the list by its ID, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal ID As Integer) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.ID = ID Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for an Argument, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal Arg As UPnPArgument) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Argument And p.Argument Is Arg Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for a Method/Action, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal method As UPnPAction) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Method And p.Method Is method Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for a Variable, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal var As UPnPStateVariable) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Variable And p.Variable Is var Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for a Service, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal service As UPnPService) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Service And p.Service Is service Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for a Device, or <c>Nothing</c> if it doesn't exist
    ''' </summary>
    Public Shared Function GetProxy(ByVal dev As UPnPDevice) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Device And p.Device Is dev Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function
    ''' <summary>
    ''' Returns the proxy from the list for a xPLAddress, or <c>Nothing</c> if it doesn't exist. 
    ''' The proxy returned will be the proxy for the UPnPDevice object.
    ''' </summary>
    Public Shared Function GetProxy(ByVal xPLAddr As String) As Proxy
        Dim result As Proxy = Nothing
        SyncLock _SharedLock
            For Each p As Proxy In _Proxylist
                If p.Type = ProxyType.Device And xPLDevice.Address = xPLAddr Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function

    Public Delegate Sub LogMessageDelegate(ByVal message As String)
    Private Shared _LogMessage As LogMessageDelegate = Nothing
    Public Shared Sub LogMessage(ByVal message As String)
        If _LogMessage IsNot Nothing Then
            _LogMessage(message)
        End If
    End Sub
    ''' <summary>
    ''' Adds a root UPnP device to the list, creating all underlying objects and proxies. And sends the announce messages.
    ''' </summary>
    ''' <param name="Device"></param>
    ''' <remarks></remarks>
    Public Shared Sub AddDevice(ByVal Device As UPnPDevice, Optional ByVal logger As LogMessageDelegate = Nothing)
        If Device Is Nothing Then Throw New ArgumentException("No device provided; Nothing", "Device")
        If Not Device.Root Then Throw New Exception("Only root devices can be added")
        logger("Adding UPnP device: " & Device.FriendlyName & " (ID = " & Device.UniqueDeviceName & ")")
        AddAnyDevice(Device, logger)
        Dim dev As Proxy = GetProxy(Device)
        _LogMessage = logger
        dev.AnnounceDevice()
        LogMessage("   UPnP device added: " & Device.FriendlyName & " (ID = " & Device.UniqueDeviceName & ")")
    End Sub

    ''' <summary>
    ''' Removes this proxy, and its children from the proxy list
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub RemoveProxy()
        ' count backwards, to remove children in reverse order of adding
        If IDList.Count > 1 Then
            ' we have children, remove them first
            Dim p As Proxy
            For n As Integer = Me.IDList.Count - 1 To 1 Step -1 ' not to 0, becasue we'll be removing the ID itself below
                p = GetProxy(Me.IDList(n))
                p.RemoveProxy()
            Next
        End If
        ' now remove self
        _Proxylist.Remove(Me)
    End Sub

    ''' <summary>
    ''' Removes a root UPnP device from the list, removing all underlying objects and proxies.
    ''' </summary>
    ''' <param name="Device"></param>
    ''' <remarks></remarks>
    Public Shared Sub RemoveDevice(ByVal Device As UPnPDevice)
        If Device Is Nothing Then Throw New ArgumentException("No device provided; Nothing", "Device")
        If Not Device.Root Then Throw New Exception("Only root devices can be removed")
        Dim p As Proxy = GetProxy(Device)
        Dim idlist As String = p.IDstring
        Dim devname As String = Device.FriendlyName & " (ID = " & Device.UniqueDeviceName & ")"
        LogMessage("Removing UPnP Device: " & devname)
        Dim l As ArrayList = p.IDList
        SyncLock _SharedLock
            p.RemoveProxy()
            ' Now go sent an 'announce=left' message for this device
            Dim m As New xPLMessage
            m.MsgType = xPLMessageTypeEnum.Trigger
            m.Source = xPLDevice.Address
            m.Target = "*"
            m.Hop = 1
            m.Schema = "upnp.announce"
            With m.KeyValueList
                .Add("announce", "left")
                .Add("id", p.ID.ToString)
            End With
            ' finally send it
            xPLDevice.Send(m)
        End SyncLock
        LogMessage("UPnP device removed: " & devname)
    End Sub
    ''' <summary>
    ''' Adds a device (also embedded devices) to the list, creating all underlying objects and proxies
    ''' </summary>
    ''' <param name="Device"></param>
    ''' <remarks></remarks>
    Private Shared Sub AddAnyDevice(ByVal Device As UPnPDevice, ByVal logger As LogMessageDelegate)
        If Device Is Nothing Then Throw New ArgumentException("No device provide; Nothing", "Device")
        If GetProxy(Device) IsNot Nothing Then Throw New Exception("Device already in proxylist")
        ' add device
        Proxy.Create(Device, logger)
        ' add services
        For Each Service As UPnPService In Device.Services
            Proxy.Create(Service, logger)
            ' add statevariables
            For Each var As UPnPStateVariable In Service.GetStateVariables
                Proxy.Create(var, logger)
            Next
            ' add methods
            For Each Method As UPnPAction In Service.GetActions
                Proxy.Create(Method, logger)
                ' add parameters
                For Each param As UPnPArgument In Method.ArgumentList
                    Proxy.Create(param, logger)
                Next
            Next
        Next
        ' add embedded devices
        For Each dev As UPnPDevice In Device.EmbeddedDevices
            AddAnyDevice(dev, logger)
        Next
    End Sub

    Private _IDList As ArrayList = Nothing
    ''' <summary>
    ''' Returns an ArrayList with all Proxy ID's of this proxy (but NOT all that are underneith this proxy). If an
    ''' input list is provided, the ID's will be added to that list.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property IDList() As ArrayList
        Get
            ' lazy creation, create upon request and maintain after that
            If _IDList Is Nothing Then
                _IDList = New ArrayList
                Select Case Type

                    Case ProxyType.Device
                        _IDList.Add(Me.ID)
                        ' also add all services and embedded devices
                        For Each s As UPnPService In Me.Device.Services
                            _IDList.Add(GetProxy(s).ID)
                            'GetProxy(s).GetIDList(List)
                        Next
                        For Each d As UPnPDevice In Me.Device.EmbeddedDevices
                            _IDList.Add(GetProxy(d).ID)
                            'GetProxy(d).GetIDList(List)
                        Next

                    Case ProxyType.Service
                        _IDList.Add(Me.ID)
                        ' also add all statevariables and methods
                        For Each s As UPnPStateVariable In Me.Service.GetStateVariables
                            _IDList.Add(GetProxy(s).ID)
                            'GetProxy(s).GetIDList(List)
                        Next
                        For Each m As UPnPAction In Me.Service.GetActions
                            _IDList.Add(GetProxy(m).ID)
                            'GetProxy(m).GetIDList(List)
                        Next

                    Case ProxyType.Method
                        _IDList.Add(Me.ID)
                        ' also add all arguments
                        For Each a As UPnPArgument In Me.Method.ArgumentList
                            _IDList.Add(GetProxy(a).ID)
                            'GetProxy(a).GetIDList(List)
                        Next

                    Case ProxyType.Variable
                        _IDList.Add(Me.ID)

                    Case ProxyType.Argument
                        _IDList.Add(Me.ID)

                    Case Else
                        Throw New Exception("Unknown ProxyType, please update source code")

                End Select
            End If
            Return _IDList
        End Get
    End Property

    'Public Function GetIDList(Optional ByVal List As ArrayList = Nothing) As ArrayList
    '    ' TODO: make this lazy! to improve performance
    '    If List Is Nothing Then List = New ArrayList
    '    Select Case Type

    '        Case ProxyType.Device
    '            List.Add(Me.ID)
    '            ' also add all services and embedded devices
    '            For Each s As UPnPService In Me.Device.Services
    '                List.Add(GetProxy(s).ID)
    '                'GetProxy(s).GetIDList(List)
    '            Next
    '            For Each d As UPnPDevice In Me.Device.EmbeddedDevices
    '                List.Add(GetProxy(d).ID)
    '                'GetProxy(d).GetIDList(List)
    '            Next

    '        Case ProxyType.Service
    '            List.Add(Me.ID)
    '            ' also add all statevariables and methods
    '            For Each s As UPnPStateVariable In Me.Service.GetStateVariables
    '                List.Add(GetProxy(s).ID)
    '                'GetProxy(s).GetIDList(List)
    '            Next
    '            For Each m As UPnPAction In Me.Service.GetActions
    '                List.Add(GetProxy(m).ID)
    '                'GetProxy(m).GetIDList(List)
    '            Next

    '        Case ProxyType.Method
    '            List.Add(Me.ID)
    '            ' also add all arguments
    '            For Each a As UPnPArgument In Me.Method.ArgumentList
    '                List.Add(GetProxy(a).ID)
    '                'GetProxy(a).GetIDList(List)
    '            Next

    '        Case ProxyType.Variable
    '            List.Add(Me.ID)

    '        Case ProxyType.Argument
    '            List.Add(Me.ID)

    '        Case Else
    '            Throw New Exception("Unknown ProxyType, please update source code")

    '    End Select
    '    Return List
    'End Function

    ''' <summary>
    ''' Will handle received xPL messages. 
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Shared Sub _xPLDevice_xPLMessageReceived(ByVal xpldev As xPL.xPLDevice, ByVal e As xPL.xPLDevice.xPLEventArgs) Handles _xPLDevice.xPLMessageReceived
        ' Deal with the message
        Try
            If e.IsForMe Then
                With e.XplMsg
                    If .Schema = "upnp.basic" And .MsgType = xPLMessageTypeEnum.Command Then
                        If .KeyValueList.IndexOf("command") = -1 Then Exit Sub
                        Select Case .KeyValueList.Item("command")
                            Case "announce"
                                ' must announce device
                                Dim i As Integer = .KeyValueList.IndexOf("id")
                                If i <> -1 Then
                                    ' IDs have been listed, serve them
                                    LogMessage("Received announce request for specific IDs")
                                    For n = 0 To .KeyValueList.Count
                                        If .KeyValueList(n).Key = "id" Then
                                            LogMessage("   Now announcing ID " & .KeyValueList(n).Value)
                                            Dim mp As Proxy = GetProxy(CInt(Val(.KeyValueList(n).Value)))
                                            mp.AnnounceElement()
                                        End If
                                    Next
                                Else
                                    ' No IDs requested, serve ALL
                                    LogMessage("Received announce request for ALL devices")
                                    Announce()
                                End If

                            Case "requestvalue"
                                LogMessage("Received a value request")
                                Dim i As Integer = .KeyValueList.IndexOf("id")
                                If i <> -1 Then
                                    Dim p As Proxy = GetProxy(CInt(Val(.KeyValueList("id"))))
                                    If p.Type = ProxyType.Device Or p.Type = ProxyType.Service Or p.Type = ProxyType.Variable Then
                                        Proxy.RequestValues(p)
                                    Else
                                        LogMessage("WARNING: requested id is not one of the following; device, service, variable. Ignoring message.")
                                    End If
                                Else
                                    LogMessage("WARNING: missing key 'id' in message body.")
                                End If

                            Case Else
                                LogMessage("WARNING: an xPL command message with schema 'upnp.basic' was received with an unknown command '" & .KeyValueList.Item("command") & "'." & vbCrLf & e.XplMsg.RawxPL)
                        End Select

                    ElseIf .Schema = "upnp.method" And .MsgType = xPLMessageTypeEnum.Command Then
                        If .KeyValueList.IndexOf("command") <> -1 Then
                            If .KeyValueList("command") = "methodcall" Then
                                Proxy.CallMethod(e.XplMsg)
                            End If
                        End If

                    Else
                        LogMessage("WARNING: Cannot handle received xPL message;" & vbCrLf & e.XplMsg.RawxPL)
                    End If
                End With
            End If
        Catch ex As Exception
            LogMessage("ERROR: handling xPL message;" & vbCrLf & e.XplMsg.RawxPL & vbCrLf & _
                       "resulted in the following exception:" & vbCrLf & ex.ToString)
        End Try

    End Sub

    ''' <summary>
    ''' Send the Announce messages for the element. 
    ''' </summary>
    ''' <remarks>Don't call directly, use AnnounceDevice</remarks>
    Private Sub AnnounceElement()
        Dim p As Proxy
        ' send my own message
        xPLDevice.Send(Me.GetAnnounceMessage)
        ' if there are any subs, call them now
        For n = 1 To Me.IDList.Count - 1
            p = Proxy.GetProxy(Me.IDList(n))
            p.AnnounceElement()
        Next
    End Sub
    ''' <summary>
    ''' Send the Announce messages for the device (only for root devices, exits silently on any other. 
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub AnnounceDevice()
        ' only root devices can announce
        If Me.Type <> ProxyType.Device Then Exit Sub
        If Not Me.Device.Root Then Exit Sub
        ' we are a root device, now let all elements announce themselves
        LogMessage("   Now announcing; " & Me.Device.FriendlyName & "(" & xPLDevice.Address & ")")
        Me.AnnounceElement()
    End Sub
    ''' <summary>
    ''' Announces all UPnP root devices known
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared Sub Announce()
        For Each p As Proxy In Proxy._Proxylist
            If p.Type = ProxyType.Device And p.Device.Root Then
                p.AnnounceDevice()
            End If
        Next
    End Sub

    Private _IDstring As String = ""
    ''' <summary>
    ''' Returns the results of <see cref="IDList">IDList</see> as a comma delimited string. Auxilary function for creating xpl messages.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function IDstring() As String
        ' initialize lazy!
        If _IDstring = "" Then
            Dim s As String = ""
            For Each i As Integer In Me.IDList
                s = s & "," & i
            Next
            _IDstring = Mid(s, 2)    ' drop first comma
        End If
        Return _IDstring
    End Function
    ''' <summary>
    ''' Returns the xPLAnnounce message message for the proxy type
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetAnnounceMessage() As xPLMessage
        Dim m As New xPLMessage
        m.MsgType = xPLMessageTypeEnum.Trigger
        m.Source = xPLDevice.Address
        m.Target = "*"
        m.Hop = 1
        m.Schema = "upnp.announce"
        With m.KeyValueList
            Select Case Me.Type
                Case ProxyType.Device
                    If Device.Root Then
                        .Add("announce", "device")
                    Else
                        .Add("announce", "subdevice")
                    End If
                    .Add("id", Me.IDstring)
                    .Add("deviceid", Device.UniqueDeviceName)
                    .Add("type", Device.DeviceURN)
                    .Add("name", Device.FriendlyName)
                    .Add("xpl", xPLDevice.Address)
                    If Not Device.Root Then
                        .Add("parent", GetProxy(Device.ParentDevice).ID.ToString)
                    End If

                Case ProxyType.Service
                    .Add("announce", "service")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Device).ID.ToString)
                    .Add("service", Service.ServiceID)
                    .Add("xpl", xPLDevice.Address)

                Case ProxyType.Method
                    .Add("announce", "method")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Service).ID.ToString)
                    .Add("name", Method.Name)
                    .Add("xpl", xPLDevice.Address)

                Case ProxyType.Variable
                    .Add("announce", "variable")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Service).ID.ToString)
                    .Add("name", Variable.Name)
                    .Add("event", Variable.SendEvent.ToString)
                    .Add("type", Variable.ValueType)
                    .Add("xpl", xPLDevice.Address)
                    If Variable.Minimum IsNot Nothing Then
                        .Add("minimum", Variable.Minimum.ToString)
                    End If
                    If Variable.Maximum IsNot Nothing Then
                        .Add("maximum", Variable.Maximum.ToString)
                    End If
                    If Variable.Step IsNot Nothing Then
                        .Add("step", Variable.Step.ToString)
                    End If
                    If Variable.AllowedStringValues IsNot Nothing AndAlso Variable.AllowedStringValues.Count > 0 Then
                        Dim allowed As String = String.Join(",", Variable.AllowedStringValues)
                        .Add("allowed", allowed)
                    End If

                Case ProxyType.Argument
                    .Add("announce", "argument")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Method).ID.ToString)
                    .Add("name", Argument.Name)
                    .Add("variable", GetProxy(Argument.RelatedStateVar).ID.ToString)
                    .Add("direction", Argument.Direction)
                    .Add("retval", Argument.IsReturnValue.ToString)

                Case Else
                    Throw New Exception("Unknown ProxyType, update source code!!")
            End Select
        End With
        Return m
    End Function

    ''' <summary>
    ''' Eventhandler for Service related events.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="SEQ"></param>
    ''' <remarks></remarks>
    Private Sub UPnPServiceEventHandler(ByVal sender As OpenSource.UPnP.UPnPService, ByVal SEQ As Long) 'Handles _Service.OnUPnPEvent
        ' only services deal with service events
        If Me.Type <> ProxyType.Service Then Exit Sub
        ' go deal with the event

    End Sub

    ''' <summary>
    ''' handle UPnP events for updated statevariables and forward as xPL message
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="NewValue"></param>
    ''' <remarks></remarks>
    Private Sub UPnPValueChange(ByVal sender As OpenSource.UPnP.UPnPStateVariable, ByVal NewValue As Object) 'Handles _Variable.OnModified
        ' Only deal with updates if I'm a variable
        If Me.Type <> ProxyType.Variable Then Exit Sub

        ' go deal with the event
        Dim xmsg As New xPLMessage
        Dim log As String = "Received value update for service '" & Service.ServiceID & "' from device '" & Device.FriendlyName & "' (xPL: " & xPLDevice.Address & ")"
        ' Setup basics of xPL message
        xmsg.MsgType = xPLMessageTypeEnum.Trigger
        xmsg.Schema = "upnp.basic"
        xmsg.Target = "*"
        Try
            If sender.Name <> "LastChange" Then
                ' its a regular UPnP event value
                xmsg.KeyValueList.Add(Proxy.GetProxy(sender).ID.ToString, NewValue.ToString)
                log = log & vbCrLf & "   " & Variable.Name & " = " & NewValue.ToString
            Else
                log = log & "New value is of type 'LastChange' with the following xml;" & vbCrLf & NewValue.ToString
                log = log & LastChangeUpdate(NewValue, xmsg)
            End If
            ' send message
            LogMessage(log)
            xPLDevice.Send(xmsg)
            LogMessage("   xPL update message send completed.")
        Catch ex As Exception
            LogMessage(log)
            LogMessage("ERROR: Handling UPnP update resulted in the following exception;" & vbCrLf & ex.ToString & vbCrLf & ex.StackTrace)
        End Try
    End Sub

    ''' <summary>
    ''' Deals with an update variable of type 'LastChange' as used by AV devices
    ''' </summary>
    ''' <param name="NewValue">Value of the LastChange property to be analyzed</param>
    ''' <param name="xmsg">xPLMessage where elements found will be added</param>
    ''' <returns>a string containing the log message</returns>
    ''' <remarks></remarks>
    Private Function LastChangeUpdate(ByVal NewValue As Object, ByVal xmsg As xPLMessage) As String
        ' its an AV device with XML payload with the changes
        Dim x As XmlReader
        Dim log As String = ""
        Dim sett As New XmlReaderSettings
        With sett
            .IgnoreComments = True
            .IgnoreWhitespace = True
        End With
        x = XmlTextReader.Create(New System.IO.StringReader(NewValue.ToString), sett)

        While x.Read
            If x.NodeType = XmlNodeType.Element And x.Name = "InstanceID" Then
                x.Read()
                While x.NodeType <> XmlNodeType.EndElement
                    If x.NodeType = XmlNodeType.Element Then
                        Dim varID As Integer
                        ' lookup statevariable by its name
                        Dim s As UPnPStateVariable = Nothing
                        Debug.Print("Looking for: " & x.Name)
                        For Each ert As UPnPStateVariable In Me.Service.GetStateVariables
                            If x.Name = ert.Name Then
                                Debug.Print("  -->" & ert.Name)
                                s = ert
                            Else
                                Debug.Print("   " & ert.Name)
                            End If
                        Next
                        If s IsNot Nothing Then
                            varID = Proxy.GetProxy(s).ID
                            s = Nothing
                        End If
                        While x.MoveToNextAttribute
                            If x.Name = "val" Then
                                xmsg.KeyValueList.Add(varID.ToString, x.Value)
                                log = log & vbCrLf & "   " & varID.ToString & " = " & x.Value
                            End If
                        End While
                    End If
                    x.Read()
                End While
            End If
        End While
        Return log
    End Function
    ''' <summary>
    ''' Handles update of config info for xPLDevice. Must announce UPnP device again if the xPL address has 
    ''' changed (a hbeat.end or config.end message has already been send automatically, so remote devices
    ''' now assume that the UPnP device was gone).
    ''' </summary>
    ''' <remarks></remarks>
    Private Shared Sub xPLConfigUpdate()
        If xPLDevice.Address <> _OldxPLAddress Then
            ' My xPL address changed, so must announce again
            LogMessage("Address of " & _OldxPLAddress & " was changed to " & xPLDevice.Address & ", now announcing all UPnP devices again on the new address.")
            Announce()
            _OldxPLAddress = xPLDevice.Address
        End If
    End Sub
    ''' <summary>
    ''' When xPLDevice is reconfigured, executes the xPLConfigUpdate.
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <remarks></remarks>
    Private Shared Sub _xPLDevice_xPLConfigDone(ByVal xpldev As xPL.xPLDevice) Handles _xPLDevice.xPLConfigDone
        LogMessage("Device " & xPLDevice.Address & " received initial configuration.")
        xPLConfigUpdate()
    End Sub
    ''' <summary>
    ''' When xPLDevice is reconfigured, executes the xPLConfigUpdate again.
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <remarks></remarks>
    Private Shared Sub _xPLDevice_xPLReConfigDone(ByVal xpldev As xPL.xPLDevice) Handles _xPLDevice.xPLReConfigDone
        LogMessage("Device " & xPLDevice.Address & " received a configuration update.")
        xPLConfigUpdate()
    End Sub

    ''' <summary>
    ''' Executes a method call
    ''' </summary>
    ''' <param name="msg"></param>
    ''' <remarks></remarks>
    Private Shared Sub CallMethod(ByVal msg As xPLMessage)
        LogMessage("Received MethodCall command from " & msg.Source)
        Dim method As UPnPAction = Nothing
        Dim uid As String = ""
        Dim result As New xPLMessage
        ' get the method to execute
        If msg.KeyValueList.IndexOf("method") = -1 Then
            Proxy.CallMethodError(msg, "ERROR: Missing the 'method' identifier")
            Exit Sub
        Else
            ' lookup the UPnP method/action
            method = GetProxy(CInt(Val(msg.KeyValueList("method")))).Method
        End If
        ' get the unique message id
        If msg.KeyValueList.IndexOf("callid") <> -1 Then
            uid = msg.KeyValueList("callid")
        End If
        LogMessage("   Method: " & method.Name & ", unique id: " & uid)
        ' build result message
        result.MsgType = xPLMessageTypeEnum.Trigger
        result.Source = xPLDevice.Address
        result.Target = "*"
        result.Schema = "upnp.method"
        If uid <> "" Then
            result.KeyValueList.Add("callid", uid)
        End If
        Try
            ' define an argument list
            Dim args(method.Arguments.Count - 1) As UPnPArgument
            Dim i As Integer = 0
            For n As Integer = 0 To msg.KeyValueList.Count - 1
                Dim kvp As xPLKeyValuePair = msg.KeyValueList(n)
                If kvp.Key <> "command" And kvp.Key <> "method" And kvp.Key <> "callid" Then
                    ' create a copy of the argument and set its value as provided
                    Dim arg As UPnPArgument = GetProxy(CInt(Val(kvp.Key))).Argument.Clone
                    arg.DataValue = ConvertToUPnPType(arg.RelatedStateVar.ValueType, kvp.Value)
                    ' add to arguments list
                    args(i) = arg
                    i = i + 1
                End If
            Next
            method.ValidateArgs(args)
            Dim retValue As Object = method.ParentService.InvokeSync(method.Name, args)
            If retValue Is Nothing Then retValue = ""
            LogMessage("   Returned: " & retValue.ToString)
            result.KeyValueList.Add("success", "true")
            result.KeyValueList.Add("retval", retValue.ToString)
            For Each arg As UPnPArgument In args
                If arg.Direction = "out" Then
                    result.KeyValueList.Add(GetProxy(method.GetArg(arg.Name)).ID, arg.DataValue.ToString)
                    LogMessage("   " & arg.Name & " = " & arg.DataValue.ToString)
                End If
            Next
        Catch ex As Exception
            result.KeyValueList.Add("success", "false")
            result.KeyValueList.Add("error", ex.Message)
            LogMessage("   ERROR: " & ex.ToString)
        End Try
        xPLDevice.Send(result)
    End Sub

    ''' <summary>
    ''' Converts a string value to the proper UPnP value type
    ''' </summary>
    ''' <param name="UPnPType"></param>
    ''' <param name="strValue"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function ConvertToUPnPType(ByVal UPnPType As String, ByVal strValue As String) As Object
        Dim value As Object = Nothing
        Select Case UPnPType
            Case "string"
                value = strValue
            Case "boolean"
                value = Boolean.Parse(strValue)
            Case "uri"
                ' unknown ??
            Case "ui1"
                value = CByte(Val(strValue))
            Case "ui2"
                value = CType(Val(strValue), UInt16)
            Case "ui4"
                value = CType(Val(strValue), UInt32)
            Case "int"
                value = CType(Val(strValue), Int32)
            Case "i4"
                value = CType(Val(strValue), Int32)
            Case "i2"
                value = CType(Val(strValue), Int16)
            Case "i1"
                value = CType(Val(strValue), SByte)
            Case "r4"
                value = CType(Val(strValue), Single)
            Case "r8"
                value = CType(Val(strValue), Double)
            Case "number"
                value = CType(Val(strValue), Double)
            Case "float"
                value = CType(Val(strValue), Single)
            Case "char"
                value = CChar(strValue)
            Case "bin.base64"
                value = System.Text.Encoding.ASCII.GetBytes(strValue)
            Case "dateTime"
                value = Date.Parse(strValue)
            Case Else
                value = strValue
        End Select
        Return value
    End Function

    ''' <summary>
    ''' Returns an error if a method call fails
    ''' </summary>
    ''' <param name="msg"></param>
    ''' <remarks></remarks>
    Private Shared Sub CallMethodError(ByVal msg As xPLMessage, ByVal Text As String)
        LogMessage("   " & Text)
        Dim m As New xPLMessage
        m.MsgType = xPLMessageTypeEnum.Trigger
        m.Target = "*"
        m.Schema = "upnp.method"
        m.KeyValueList.Add("result", "error")
        If msg.KeyValueList.IndexOf("callid") <> -1 Then
            m.KeyValueList.Add("callid", msg.KeyValueList("callid"))
        End If
        m.KeyValueList.Add("error", Text)
        xPLDevice.Send(m)
    End Sub

    ''' <summary>
    ''' Will request (and post on the xPL network) the values of related variables. The parameter should be a proxy of type
    ''' device, service or variable. For service and device types all underlying variables will be reported.
    ''' </summary>
    ''' <param name="p"></param>
    ''' <remarks></remarks>
    Private Shared Sub RequestValues(ByVal p As Proxy)
        If p Is Nothing Then Exit Sub
        Select Case p.Type
            Case ProxyType.Variable
                LogMessage("   Requesting value for variable " & p.Variable.Name)
                If p.Variable.SendEvent Then
                    ' evented variable, so we can just get the current value
                    Dim msg As New xPLMessage
                    msg.MsgType = xPLMessageTypeEnum.Trigger
                    msg.Target = "*"
                    msg.Schema = "upnp.basic"
                    If Not p.Variable.Name = "LastChange" Then
                        ' regular evented variable
                        If p.Variable.Value IsNot Nothing Then
                            msg.KeyValueList.Add(p.ID.ToString, xPL_Base.RemoveInvalidxPLchars(p.Variable.Value.ToString, XPL_STRING_TYPES.Values))
                        Else
                            msg.KeyValueList.Add(p.ID.ToString, "")
                        End If
                        LogMessage("      Returning value for " & p.Variable.Name & " of service " & p.Service.ServiceID)
                        LogMessage("         value = " & msg.KeyValueList(p.ID.ToString))
                    Else
                        'LastChange' type variable
                        Dim lm As String = p.LastChangeUpdate(p.Variable.Value.ToString, msg)
                        LogMessage("      Returning value for LastChange of service " & p.Service.ServiceID & lm)
                    End If
                    xPLDevice.Send(msg)
                Else
                    ' non-evented, we have to go and request the value using an action/method
                    ' go and find method to request the value
                    Dim mname As String = "GET" & p.Variable.Name.ToUpper
                    Dim m As UPnPAction = Nothing
                    For Each action As UPnPAction In p.Service.GetActions
                        If action.Name.ToUpper = mname Then
                            ' found the method, check some requirements
                            If action.Arguments.Count = 1 Then
                                If action.ArgumentList(0).Direction = "out" Then
                                    ' must be it, action with GET name, 1 argument direction OUT
                                    m = action
                                    Exit For
                                End If
                            End If
                        End If
                    Next
                    If m IsNot Nothing Then
                        ' a method was found, go invoke it
                        Dim a(0) As UPnPArgument
                        a(0) = m.ArgumentList(0).Clone()
                        p.Service.InvokeAsync(m.Name, a, p, AddressOf Proxy.VariableCallBack, AddressOf Proxy.VariableErrorCallBack)
                        LogMessage("      Requested value for " & p.Variable.Name & " of service " & p.Service.ServiceID)
                    Else
                        ' no method found, can't request value
                        LogMessage("      " & p.Variable.Name & "; doesn't have a GET method to request its value")
                    End If
                End If

            Case ProxyType.Service
                    LogMessage("   Reporting values for service; " & p.Service.ServiceID & " it has " & p.Service.GetStateVariables.Count & " variables")
                    If p.Service.GetStateVariables.Count > 0 Then
                        For Each s As UPnPStateVariable In p.Service.GetStateVariables
                            ' call this sub recursively for each variable
                            Proxy.RequestValues(Proxy.GetProxy(s))
                        Next
                    End If
            Case ProxyType.Device
                    LogMessage("   Reporting values for device; " & p.Device.FriendlyName & " it has " & p.Device.Services.Count.ToString & " services")
                    If p.Device.Services.Count > 0 Then
                        For Each s As UPnPService In p.Device.Services
                            ' call this sub recursively for each variable
                            Proxy.RequestValues(Proxy.GetProxy(s))
                        Next
                    End If
                    LogMessage("   Reporting values for device; " & p.Device.FriendlyName & " it has " & p.Device.EmbeddedDevices.Count.ToString & " subdevices")
                    If p.Device.Services.Count > 0 Then
                        For Each d As UPnPDevice In p.Device.EmbeddedDevices
                            ' call this sub recursively for each variable
                            Proxy.RequestValues(Proxy.GetProxy(d))
                        Next
                    End If
            Case Else
                    LogMessage("Can't request values for proxy type: " & p.Type.ToString)
        End Select
    End Sub

    ''' <summary>
    ''' Callback for ASync variable value request used by <see cref="RequestValues">RequestValues</see>
    ''' </summary>
    Private Shared Sub VariableCallBack(ByVal sender As OpenSource.UPnP.UPnPService, ByVal MethodName As String, ByVal Args() As OpenSource.UPnP.UPnPArgument, ByVal ReturnValue As Object, ByVal Tag As Object)
        Try
            Dim msg As New xPLMessage
            Dim p As Proxy = CType(Tag, Proxy)
            msg.MsgType = xPLMessageTypeEnum.Trigger
            msg.Target = "*"
            msg.Schema = "upnp.basic"
            If Args(0).DataValue Is Nothing Then
                msg.KeyValueList.Add(p.ID.ToString, "")
            Else
                msg.KeyValueList.Add(p.ID.ToString, Args(0).DataValue.ToString)
            End If
            If ReturnValue Is Nothing Then ReturnValue = ""
            msg.KeyValueList.Add("retval", ReturnValue.ToString)
            LogMessage("   Returning value for " & p.Variable.Name & " of service " & p.Service.ServiceID)
            LogMessage("       value = " & msg.KeyValueList(p.ID.ToString))
            xPLDevice.Send(msg)
        Catch ex As Exception
            LogMessage("ERROR: VariableCallBack had exception: " & ex.ToString)
        End Try
    End Sub
    ''' <summary>
    ''' Callback for ASync variable value request used by <see cref="RequestValues">RequestValues</see>
    ''' </summary>
    Private Shared Sub VariableErrorCallBack(ByVal sender As OpenSource.UPnP.UPnPService, ByVal MethodName As String, ByVal Args() As OpenSource.UPnP.UPnPArgument, ByVal ReturnValue As Object, ByVal Tag As Object)
        Try
            LogMessage("ERROR: method " & MethodName & " to request the value of " & CType(Tag, Proxy).Variable.Name & " failed.")
        Catch ex As Exception
            LogMessage("ERROR: VariableErrorCallBack had exception: " & ex.ToString)
        End Try
    End Sub



End Class
