Option Strict On

Module MainCode
    ''' <summary>
    ''' This code is a container only, unpack resources included in temp folder and start them, exit immediately
    ''' </summary>
    ''' <remarks>Application must be started with parent ProcessID on the commandline</remarks>
    Public Sub Main()
        ' start up
        Dim pid As Integer
        If My.Application.CommandLineArgs.Count = 0 Then
            pid = 0
        Else
            ' commandline argument, should be proces ID of installer
            Try
                ' get process ID from argument list
                pid = CInt(My.Application.CommandLineArgs(0))

            Catch ex As Exception
                pid = 0
            End Try
        End If

        ' We have started and have the parent (installer application) proces ID
        ' Unpack resources to temp dir
        Dim dir As String = Resources.tempPath
        Resources.SaveResourceToFile(My.Resources.Interop_NetFwTypeLib, dir & "Interop.NetFwTypeLib.dll")
        Resources.SaveResourceToFile(My.Resources.xpllib, dir & "xpllib.dll")
        Resources.SaveResourceToFile(My.Resources.xPL_Hub_Verifier, dir & "xPL Hub Verifier.exe")
        Process.Start(dir & "xPL Hub Verifier.exe", pid.ToString)
        ' unpacked files, process started, we're done, exit
    End Sub
End Module