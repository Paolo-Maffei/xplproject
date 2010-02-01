Option Strict On

Module Resources
    ''' <summary>
    ''' Returns the path to the temp files folder, including the closing directory separatorcharacter
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function tempPath() As String
        Return Microsoft.VisualBasic.FileIO.SpecialDirectories.Temp() & System.IO.Path.DirectorySeparatorChar
    End Function

    ''' <summary>
    ''' Saves a resource to a file
    ''' </summary>
    ''' <param name="resource">The resource to be saved</param>
    ''' <param name="filename">The filename of the file to which to save the resource</param>
    ''' <returns>True id success, False otherwise</returns>
    ''' <remarks></remarks>
    Public Function SaveResourceToFile(ByVal resource As Object, ByVal filename As String) As Boolean
        Dim bArr() As Byte
        Dim result As Boolean = False
        bArr = TryCast(resource, Byte())
        If bArr Is Nothing Then
            result = False
        Else
            Try
                My.Computer.FileSystem.WriteAllBytes(filename, bArr, False)
                result = True
            Catch ex As Exception
                result = False
            End Try
        End If
        Return result
    End Function


End Module
