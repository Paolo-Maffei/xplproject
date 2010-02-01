
Adding the xPL check package to the installation of your xPL application
========================================================================

 1) add an 'Installer Class' to your project
       - right click the project; Add - New Item...
       - in VS2008 go to category 'Common items - General'
       - select "Installer class"

 2) Open Installer code
       - Rightclick newly added installer and select 'View Code'

 3) add/update the code of this class
       - Add the code between the lines below to your "installer class"
         (the code is Visual Basic, but shouldn't be hard to convert it to C#)
=================================================================================================
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
=================================================================================================

 
  4) In your projects deployment project go to the File System Editor
        - Right click "File System on Target Machine"
        - select Add Special Folder - Program Files folder
        - Right click the added branch in the tree and select Add - File...
        - browse to the "xPLCheckPackage.exe" and add it.
        
  5) In your projects deployement project go to the Custom Actions Editor
        - Right click the 'Install' branch and click Add custom action
        - In the dialog select the 'Application folder' and from that folder select the primary output
        - Repeat these 2 steps for the 'Commit' branch
        
Now rebuild the solution and the deployment project, when you now install the application it will end
with the xPL network check prompt.
