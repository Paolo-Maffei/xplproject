Imports System.ComponentModel
Imports System.Configuration.Install
Imports System.ServiceProcess

Public Class ProjectInstaller

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()

        'Add initialization code after the call to InitializeComponent

    End Sub
    Private Sub xPL_SMS_service_AfterInstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles xPL_SMS_service.AfterInstall
        Try
            Dim s As New ServiceController(xPL_SMS_service.ServiceName)
            s.Start()
        Catch ex As Exception
        End Try
    End Sub

    Private Sub xPL_SMS_service_BeforeUninstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles xPL_SMS_service.BeforeUninstall
        Try
            Dim s As New ServiceController(xPL_SMS_service.ServiceName)
            If Not s.Status = ServiceControllerStatus.Stopped Then
                s.Stop()
                s.WaitForStatus(ServiceControllerStatus.Stopped)
            End If
        Catch ex As Exception
        End Try
    End Sub


    <Security.Permissions.SecurityPermission(Security.Permissions.SecurityAction.Demand)> _
Public Overrides Sub Commit(ByVal savedState As System.Collections.IDictionary)

        MyBase.Commit(savedState)

        Dim filename As String = "xPLCheckPackage.exe"
        Dim fromfile As String = FileIO.SpecialDirectories.ProgramFiles & System.IO.Path.DirectorySeparatorChar & filename
        Dim proc As New Process

        If System.IO.File.Exists(fromfile) Then
            If MsgBox("Installation is nearly complete, would you like to verify the xPL infrastructure?", _
                      MsgBoxStyle.OkCancel Or MsgBoxStyle.DefaultButton1 Or MsgBoxStyle.Question, _
                      "Check xPL infrastructure?") = MsgBoxResult.Ok Then
                Try
                    proc.StartInfo.FileName = fromfile
                    proc.StartInfo.Arguments = Process.GetCurrentProcess.Id.ToString
                    proc.Start()
                    Try
                        proc.WaitForExit()
                    Catch
                    End Try
                Catch ex As Exception
                    MsgBox("Something went wrong, the verification utility couldn't be started. You may try to start " & _
                           "it manually, the file 'xPLCheckPackage.exe' should be located in your 'Program Files' directory." & _
                           vbCrLf & vbCrLf & "Error: " & ex.Message, _
                           MsgBoxStyle.Exclamation Or MsgBoxStyle.OkOnly, "Error")
                End Try
            End If
            Try
                ' Process is done, delete file
                Kill(fromfile)
            Catch
            End Try
        End If

    End Sub

End Class
