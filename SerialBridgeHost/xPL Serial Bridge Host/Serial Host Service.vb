Public Class Service1

    Private xPL As xpllib.XplListener

    Protected Overrides Sub OnStart(ByVal args() As String)
        xPL = New xpllib.XplListener("WMUTE-SRVHOST", 1, EventLog)
        If xPL.AwaitingConfiguration Then
            xPL.ConfigItems.Add("portscan", "TRUE", xpllib.xplConfigTypes.xOption)
            'xPL.ConfigItems.Add("portscan", "TRUE", xpllib.xplConfigTypes.xOption)
        End If
    End Sub

    Protected Overrides Sub OnStop()
        ' Add code here to perform any tear-down necessary to stop your service.
        xPL.Dispose()
    End Sub

End Class
