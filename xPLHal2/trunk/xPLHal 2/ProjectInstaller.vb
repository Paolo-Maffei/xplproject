Imports System.ComponentModel
Imports System.Configuration.Install

Public Class ProjectInstaller

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()

        'Add initialization code after the call to InitializeComponent

    End Sub

    Public Sub startservice() Handles ServiceProcessInstaller1.Committed
        Dim sc As New ServiceProcess.ServiceController("xPLHal 2 Server")
        sc.Start()
    End Sub

End Class
