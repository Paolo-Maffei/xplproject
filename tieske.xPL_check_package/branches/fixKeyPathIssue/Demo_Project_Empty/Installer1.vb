Imports System.ComponentModel
Imports System.Configuration.Install

Public Class Installer1

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()

        'Add initialization code after the call to InitializeComponent

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
