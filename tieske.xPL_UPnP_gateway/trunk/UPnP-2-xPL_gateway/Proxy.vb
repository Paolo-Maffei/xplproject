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

    Private Shared WithEvents xxxPLDevice As xPLDevice = Nothing
    Public Shared Property xPLDevice() As xPLDevice
        Get
            Return xxxPLDevice
        End Get
        Set(ByVal value As xPLDevice)
            If value Is Nothing Then Throw New NullReferenceException
            xxxPLDevice = value
            _OldxPLAddress = xxxPLDevice.Address
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
        Dim l As ArrayList = p.GetIDList
        SyncLock _SharedLock
            ' count backwards, to remove in reverse order of adding
            For n As Integer = l.Count - 1 To 0 Step -1
                p = GetProxy(l(n))
                _Proxylist.Remove(p)
            Next
            ' last value of p is device itself. Now go sent an 'announce=left' message for this device
            Dim m As New xPLMessage
            m.MsgType = xPLMessageTypeEnum.Trigger
            m.Source = xPLDevice.Address
            m.Target = "*"
            m.Hop = 1
            m.Schema = "upnp.announce"
            With m.KeyValueList
                .Add("announce", "left")
                .Add("id", idlist)
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
    Private Shared Sub _xPLDevice_xPLMessageReceived(ByVal xpldev As xPL.xPLDevice, ByVal e As xPL.xPLDevice.xPLEventArgs) Handles xxxPLDevice.xPLMessageReceived
        ' Deal with the message
        Try
            If e.IsForMe Then
                With e.XplMsg
                    If .Schema = "upnp.basic" And .MsgType = xPLMessageTypeEnum.Command Then
                        If .KeyValueList.IndexOf("command") = -1 Then Exit Sub
                        Select Case .KeyValueList.Item("command")
                            Case "announce"
                                ' must announce device
                                ' TODO: optional announce only a single device
                                LogMessage("Received announce request")
                                Announce()
                            Case "methodcall"
                                Proxy.CallMethod(e.XplMsg)
                            Case "requestvalue"
                                LogMessage("Received a value request")
                                Dim i As Integer = e.XplMsg.KeyValueList.IndexOf("id")
                                If i <> -1 Then
                                    Dim p As Proxy = GetProxy(CInt(Val(e.XplMsg.KeyValueList("id"))))
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
    ''' Send the Announce messages for the device (only for root devices, exits silently on any other. 
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub AnnounceDevice()
        ' only root devices can announce
        If Me.Type <> ProxyType.Device Then Exit Sub
        If Not Me.Device.Root Then Exit Sub
        ' we are a root device, now let all elements announce themselves
        Dim l As ArrayList = Me.GetIDList
        Dim p As Proxy
        LogMessage("   Now announcing; " & Me.Device.FriendlyName & "(" & xPLDevice.Address & ")")
        For n = 0 To l.Count - 1
            p = GetProxy(l(n))
            xPLDevice.Send(p.GetAnnounceMessage)
        Next
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
                    .Add("xpl", xPLDevice.Address)
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
                    .Add("xpl", xPLDevice.Address)

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
    Private Shared Sub _xPLDevice_xPLConfigDone(ByVal xpldev As xPL.xPLDevice) Handles xxxPLDevice.xPLConfigDone
        LogMessage("Device " & xPLDevice.Address & " received initial configuration.")
        xPLConfigUpdate()
    End Sub
    ''' <summary>
    ''' When xPLDevice is reconfigured, executes the xPLConfigUpdate again.
    ''' </summary>
    ''' <param name="xpldev"></param>
    ''' <remarks></remarks>
    Private Shared Sub _xPLDevice_xPLReConfigDone(ByVal xpldev As xPL.xPLDevice) Handles xxxPLDevice.xPLReConfigDone
        LogMessage("Device " & xPLDevice.Address & " received a configuration update.")
        xPLConfigUpdate()
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
                ' TODO: report actual variable value

            Case ProxyType.Service
                If p.Service.GetStateVariables.Count > 0 Then
                    LogMessage("   Reporting values for service; " & p.Service.ServiceID)
                    For Each s As UPnPStateVariable In p.Service.GetStateVariables
                        ' call this sub recursively for each variable
                        Proxy.RequestValues(Proxy.GetProxy(s))
                    Next
                End If
            Case ProxyType.Device
                If p.Device.Services.Count > 0 Then
                    LogMessage("   Reporting values for device; " & p.Device.FriendlyName)
                    For Each s As UPnPService In p.Device.Services
                        ' call this sub recursively for each variable
                        Proxy.RequestValues(Proxy.GetProxy(s))
                    Next
                End If
        End Select
    End Sub

    Private Shared Sub CallMethod(ByVal msg As xPLMessage)
        ' TODO: implement the method call

    End Sub

End Class
