Option Strict On

' requires a reference to FirewallAPI.dll (in c:\windows\system32)
Imports NetFwTypeLib

Module Firewall
    Const xPLPort As Integer = 3865

    ''' <summary>
    ''' Opens the xPL port in the firewall; port 3865, UDP
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub OpenxPLPort()
        Dim fwMgr As INetFwMgr = CType(getInstance("INetFwMgr"), INetFwMgr)
        Dim fwPolicy As INetFwPolicy = fwMgr.LocalPolicy
        Dim fwProfile As INetFwProfile = fwPolicy.CurrentProfile
        Dim openports As INetFwOpenPorts = fwProfile.GloballyOpenPorts
        Dim openport As INetFwOpenPort = CType(getInstance("INetOpenPort"), INetFwOpenPort)
        With openport
            .Port = xPLPort
            .Protocol = NET_FW_IP_PROTOCOL_.NET_FW_IP_PROTOCOL_UDP
            .Name = "xPL protocol UDP @ " & xPLPort
        End With
        openports.Add(openport)
        fwMgr = Nothing
        fwPolicy = Nothing
        fwProfile = Nothing
        openports = Nothing
        openport = Nothing
    End Sub
    ''' <summary>
    ''' Closes the xPL port in the firewall; port 3865, UDP
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub ClosexPLport()
        Dim fwMgr As INetFwMgr = CType(getInstance("INetFwMgr"), INetFwMgr)
        Dim fwPolicy As INetFwPolicy = fwMgr.LocalPolicy
        Dim fwProfile As INetFwProfile = fwPolicy.CurrentProfile
        Dim ports As INetFwOpenPorts = fwProfile.GloballyOpenPorts
        ports.Remove(xPLPort, NET_FW_IP_PROTOCOL_.NET_FW_IP_PROTOCOL_UDP)
        fwMgr = Nothing
        fwPolicy = Nothing
        fwProfile = Nothing
        ports = Nothing
    End Sub
    Public Function IsFWaccessible() As Boolean
        Dim result As Boolean = False
        Dim fwMgr As INetFwMgr
        Dim fwPolicy As INetFwPolicy
        Dim fwProfile As INetFwProfile
        Dim ports As INetFwOpenPorts
        Try
            ' try access the COM object for the windows firewall
            fwMgr = CType(getInstance("INetFwMgr"), INetFwMgr)
            fwPolicy = fwMgr.LocalPolicy
            fwProfile = fwPolicy.CurrentProfile
            ports = fwProfile.GloballyOpenPorts
            ' No exceptions, so firewall seem to be available
            result = True
        Catch ex As Exception
            ' Exception, so seems the firewall is not running (or another one is installed??)
            result = False
        End Try

        fwMgr = Nothing
        fwPolicy = Nothing
        fwProfile = Nothing
        ports = Nothing
        Return result
    End Function
    Public Function IsxPLportOpen() As Boolean
        Dim result As Boolean = False
        If IsFWaccessible() Then
            Dim fwMgr As INetFwMgr = CType(getInstance("INetFwMgr"), INetFwMgr)
            Dim fwPolicy As INetFwPolicy = fwMgr.LocalPolicy
            Dim fwProfile As INetFwProfile = fwPolicy.CurrentProfile
            Dim ports As INetFwOpenPorts = fwProfile.GloballyOpenPorts
            Try
                Dim port As INetFwOpenPort = ports.Item(xPLPort, NET_FW_IP_PROTOCOL_.NET_FW_IP_PROTOCOL_UDP)
                result = port.Enabled
                port = Nothing
            Catch ex As Exception
                result = False
            End Try

            fwMgr = Nothing
            fwPolicy = Nothing
            fwProfile = Nothing
            ports = Nothing
        End If
        Return result
    End Function

    Private Function getInstance(ByVal typeName As String) As Object
        If (typeName = "INetFwMgr") Then
            Dim type As Type = type.GetTypeFromCLSID(New Guid("{304CE942-6E39-40D8-943A-B913C40C9CD4}"))
            Return Activator.CreateInstance(type)
        ElseIf (typeName = "INetAuthApp") Then
            Dim type As Type = type.GetTypeFromCLSID(New Guid("{EC9846B3-2762-4A6B-A214-6ACB603462D2}"))
            Return Activator.CreateInstance(type)
        ElseIf (typeName = "INetOpenPort") Then
            Dim type As Type = type.GetTypeFromCLSID(New Guid("{0CA545C6-37AD-4A6C-BF92-9F7610067EF5}"))
            Return Activator.CreateInstance(type)
        Else
            Return Nothing
        End If
    End Function

End Module
