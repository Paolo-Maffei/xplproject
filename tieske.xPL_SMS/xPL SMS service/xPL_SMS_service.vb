Public Class xPL_SMS_service
    Dim app As New AppCore
    Protected Overrides Sub OnStart(ByVal args() As String)
        ' Add code here to start your service. This method should set things
        ' in motion so your service can do its work.
        app.OnStartUp(Me.EventLog)
    End Sub

    Protected Overrides Sub OnStop()
        ' Add code here to perform any tear-down necessary to stop your service.
        app.OnShutdown()
    End Sub

End Class
