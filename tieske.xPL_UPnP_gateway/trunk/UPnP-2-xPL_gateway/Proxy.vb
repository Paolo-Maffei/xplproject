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
    Private _OldxPLAddress As String
    Private WithEvents _xPLDevice As xPLDevice = Nothing
    Public ReadOnly Property xPLDevice() As xPLDevice
        Get
            Return _xPLDevice
        End Get
    End Property
    Private WithEvents _Service As UPnPService = Nothing
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
    Private WithEvents _Variable As UPnPStateVariable = Nothing
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
    ''' <summary>
    ''' Creates a proxy from an object, either; device, service, statevariable, method or argument objects
    ''' </summary>
    ''' <param name="obj"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function Create(ByVal obj As Object, ByVal logger As LogMessageDelegate) As Proxy
        Dim p As New Proxy
        p._LogMessage = logger
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
            p.LogMessage("ERROR: While creating a Proxy object an unknown type was encountered; " & obj.GetType.ToString)
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
                p.LogMessage("ERROR: Unknown ProxyType, please update source code")
        End Select
        ' I wasn't in the list, so I'm new and ready to be added
        ' Add xPLDevice, but only for devices, for others create the reference
        If p.Type = ProxyType.Device Then
            If p.Device.Root Then
                ' we're a new root device, so we have to create an xPL device
                ' first check if we created one before;
                If xPLListener.IndexOf(p.Device.UniqueDeviceName) = -1 Then
                    ' none found, so create one
                    p._xPLDevice = New xPLDevice
                    With p.xPLDevice
                        .VendorID = "tieske"
                        .DeviceID = "upnp"
                        .InstanceID = "proxy" & p.ID.ToString
                        .Configurable = True
                        .ConfigItems.Add("name", p.Device.FriendlyName, xPLConfigTypes.xOption, 1)
                        .MessagePassing = .MessagePassing Or MessagePassingEnum.PassWhileAwaitingConfig
                        .Enabled = True
                        p.LogMessage("New xPLDevice created; " & .Address & " (status: " & CStr(IIf(.Configured, "configured", "unconfigured")) & ")")
                    End With
                Else
                    ' Found an existing device, so restart that device
                    p._xPLDevice = xPLListener.Device(p.Device.UniqueDeviceName)
                    p.xPLDevice.Enabled = True
                    p.LogMessage("Existing xPLDevice restarted; " & p.xPLDevice.Address & " (status: " & CStr(IIf(p.xPLDevice.Configured, "configured", "unconfigured")) & ")")
                End If
                p._OldxPLAddress = p.xPLDevice.Address
            Else
                ' We're a sub device, so go lookup my parents xPL device
                p._xPLDevice = GetProxy(p.Device.ParentDevice).xPLDevice
            End If
        Else
            ' we're not a device, so we have to go look up our device and add a reference to its xPLDevice to myself
            p._xPLDevice = GetProxy(p.Device).xPLDevice
        End If
        ' Subscribe to UPnP service to receive its events
        If p.Type = ProxyType.Service Then
            p.Service.Subscribe(900, Nothing)
            p.LogMessage("Now subscribing to the events of service; " & p.Service.ServiceID)
        End If
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
                If p.Type = ProxyType.Device And p.xPLDevice.Address = xPLAddr Then
                    result = p
                    Exit For
                End If
            Next
        End SyncLock
        Return result
    End Function

    Public Delegate Sub LogMessageDelegate(ByVal message As String)
    Private _LogMessage As LogMessageDelegate = Nothing
    Public Sub LogMessage(ByVal message As String)
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
        dev._LogMessage = logger
        dev.LogMessage("UPnP device added: " & Device.FriendlyName & " (ID = " & Device.UniqueDeviceName & ")")
        dev.Announce()
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
        Dim logger As LogMessageDelegate = AddressOf p.LogMessage
        Dim devname As String = Device.FriendlyName & " (ID = " & Device.UniqueDeviceName & ")"
        logger("Removing UPnP Device: " & devname)
        Dim l As ArrayList = p.GetIDList
        SyncLock _SharedLock
            ' count backwards, to remove in reverse order of adding
            For n As Integer = l.Count - 1 To 0 Step -1
                p = GetProxy(l(n))
                If p.Type = ProxyType.Device Then
                    ' stop xPL device
                    p.xPLDevice.Dispose()
                End If
                _Proxylist.Remove(p)
            Next
        End SyncLock
        logger("UPnP device removed: " & devname)
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

    ''' <summary>
    ''' Returns an ArrayList with all Proxy ID's of this proxy and all that are underneith this proxy (recursively). If an
    ''' input list is provided, the ID's will be added to that list.
    ''' </summary>
    ''' <param name="List"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetIDList(Optional ByVal List As ArrayList = Nothing) As ArrayList
        If List Is Nothing Then List = New ArrayList
        Select Case Type

            Case ProxyType.Device
                List.Add(Me.ID)
                ' also add all services and embedded devices
                For Each s As UPnPService In Me.Device.Services
                    GetProxy(s).GetIDList(List)
                Next
                For Each d As UPnPDevice In Me.Device.EmbeddedDevices
                    GetProxy(d).GetIDList(List)
                Next

            Case ProxyType.Service
                List.Add(Me.ID)
                ' also add all statevariables and methods
                For Each s As UPnPStateVariable In Me.Service.GetStateVariables
                    GetProxy(s).GetIDList(List)
                Next
                For Each m As UPnPAction In Me.Service.GetActions
                    GetProxy(m).GetIDList(List)
                Next

            Case ProxyType.Method
                List.Add(Me.ID)
                ' also add all arguments
                For Each a As UPnPArgument In Me.Method.ArgumentList
                    GetProxy(a).GetIDList(List)
                Next

            Case ProxyType.Variable
                List.Add(Me.ID)

            Case ProxyType.Argument
                List.Add(Me.ID)

            Case Else
                Throw New Exception("Unknown ProxyType, please update source code")

        End Select
        Return List
    End Function

    ''' <summary>
    ''' Will handle received xPL messages. 
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Sub _xPLDevice_xPLMessageReceived(ByVal xpldev As xPL.xPLDevice, ByVal e As xPL.xPLDevice.xPLEventArgs) Handles _xPLDevice.xPLMessageReceived
        ' Only handle messages if we're root device
        If Me.Type <> ProxyType.Device Then Exit Sub
        If Not Me.Device.Root Then Exit Sub
        ' Deal with the message
        Try
            If e.IsForMe Then
                With e.XplMsg
                    If .Schema = "upnp.basic" And .MsgType = xPLMessageTypeEnum.Command Then
                        If .KeyValueList.IndexOf("command") = -1 Then Exit Sub
                        Select Case .KeyValueList.Item("command")
                            Case "announce"
                                ' must announce device
                                Me.LogMessage("Received announce request for; " & Me.Device.FriendlyName & "(" & Me.xPLDevice.Address & ")")
                                Me.Announce()
                            Case "methodcall"
                                ' TODO: implement the method call
                            Case Else
                                LogMessage("WARNING: an xPL command message with schema 'upnp.basic' was received with an unknown command '" & .KeyValueList.Item("command") & "'." & vbCrLf & e.XplMsg.RawxPL)
                        End Select
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
    ''' Send the Announce messages for the device. Throws exception if Proxy is not of Device type!!
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub Announce()
        ' only root devices can announce
        If Me.Type <> ProxyType.Device Then Exit Sub
        If Not Me.Device.Root Then Exit Sub
        ' we are a root device, now let all elements announce themselves
        Dim l As ArrayList = Me.GetIDList
        Dim p As Proxy
        Me.LogMessage("Now announcing; " & Me.Device.FriendlyName & "(" & Me.xPLDevice.Address & ")")
        For n = 0 To l.Count - 1
            p = GetProxy(l(n))
            xPLDevice.Send(p.GetAnnounceMessage)
        Next
    End Sub
    ''' <summary>
    ''' Returns the results of <see cref="GetIDList">GetIDList</see> as a comma delimited string. Auxilary function for creating xpl messages.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function IDstring() As String
        Dim s As String = ""
        For Each i As Integer In Me.GetIDList
            s = s & "," & i
        Next
        Return Mid(s, 2)    ' drop first comma
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
                    .Add("xpl", Me.xPLDevice.Address)
                    If Not Device.Root Then
                        .Add("parent", GetProxy(Device.ParentDevice).ID.ToString)
                    End If

                Case ProxyType.Service
                    .Add("announce", "service")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Device).ID.ToString)
                    .Add("service", Service.ServiceID)

                Case ProxyType.Method
                    .Add("announce", "method")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Service).ID.ToString)
                    .Add("name", Method.Name)
                    .Add("xpl", Me.xPLDevice.Address)

                Case ProxyType.Variable
                    .Add("announce", "variable")
                    .Add("id", Me.IDstring)
                    .Add("parent", GetProxy(Service).ID.ToString)
                    .Add("name", Variable.Name)
                    .Add("event", Variable.SendEvent.ToString)
                    .Add("type", Variable.ValueType)

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
    Private Sub UPnPServiceEventHandler(ByVal sender As OpenSource.UPnP.UPnPService, ByVal SEQ As Long) Handles _Service.OnUPnPEvent
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
    Private Sub UPnPValueChange(ByVal sender As OpenSource.UPnP.UPnPStateVariable, ByVal NewValue As Object) Handles _Variable.OnModified
        ' Only deal with updates if I'm a variable
        If Me.Type <> ProxyType.Variable Then Exit Sub

        ' go deal with the event
        Dim xmsg As New xPLMessage

        ' Setup basics of xPL message
        xmsg.MsgType = xPLMessageTypeEnum.Trigger
        xmsg.Schema = "upnp.basic"
        xmsg.Target = "*"

        If sender.Name <> "LastChange" Then
            ' its a regular UPnP event value
            xmsg.KeyValueList.Add(Proxy.GetProxy(sender).ID.ToString, NewValue.ToString)
        Else
            ' its an AV device with XML payload with the changes
            Dim x As XmlReader
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
                            varID = Proxy.GetProxy(CType(Me.Service.GetStateVariable(x.Name), UPnPStateVariable)).ID
                            While x.MoveToNextAttribute
                                If x.Name = "val" Then
                                    xmsg.KeyValueList.Add(varID.ToString, x.Value)
                                End If
                            End While
                        End If
                        x.Read()
                    End While
                End If
            End While
        End If
        ' send message
        Me.xPLDevice.Send(xmsg)
    End Sub

    ''' <summary>
    ''' Handles update of config info for xPLDevice. Must announce UPnP device again if the xPL address has 
    ''' changed (a hbeat.end or config.end message has already been send automatically, so remote devices
    ''' now assume that the UPnP device was gone).
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub xPLConfigUpdate()
        If xPLDevice.Address <> _OldxPLAddress Then
            ' My xPL address changed, so must announce again
            LogMessage("Address of " & _OldxPLAddress & " was changed to " & xPLDevice.Address & ", now announcing again on the new address.")
            Me.Announce()
            _OldxPLAddress = xPLDevice.Address
        End If
    End Sub
    ''' <summary>
    ''' When xPLDevice is reconfigured, executes the xPLConfigUpdate.
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <remarks></remarks>
    Private Sub _xPLDevice_xPLConfigDone(ByVal xpldev As xPL.xPLDevice) Handles _xPLDevice.xPLConfigDone
        LogMessage("Device " & xPLDevice.Address & " received initial configuration.")
        xPLConfigUpdate()
    End Sub
    ''' <summary>
    ''' When xPLDevice is reconfigured, executes the xPLConfigUpdate again.
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <remarks></remarks>
    Private Sub _xPLDevice_xPLReConfigDone(ByVal xpldev As xPL.xPLDevice) Handles _xPLDevice.xPLReConfigDone
        LogMessage("Device " & xPLDevice.Address & " received a configuration update.")
        xPLConfigUpdate()
    End Sub

End Class
