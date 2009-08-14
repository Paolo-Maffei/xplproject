Imports Microsoft.Win32

Module Settings
    Public Sub SaveRegSetting(ByVal sSetting As String, ByVal sValue As String)
        Dim HKLMRoot As RegistryKey = Registry.LocalMachine
        Dim HKLMXPL As RegistryKey = HKLMRoot.OpenSubKey("Software\\xPL\\VFD Display Driver", True)

        If HKLMXPL Is Nothing Then
            Try
                Dim HKLMSoft As RegistryKey = HKLMRoot.OpenSubKey("Software", True)
                HKLMSoft.CreateSubKey("xPL\\VFD Display Driver\\VFD1")
                HKLMXPL = HKLMRoot.OpenSubKey("Software\\xPL\\VFD Display Driver", True)
                HKLMSoft.Close()
            Catch ex As Exception
            End Try
        End If

        HKLMXPL.SetValue(sSetting, sValue)

        'flush through the changes
        HKLMXPL.Flush()
        HKLMXPL.Close()
        HKLMRoot = Nothing
    End Sub

    Public Function getRegSetting(ByVal sSetting As String) As String
        Dim HKLMRoot As RegistryKey = Registry.LocalMachine
        Dim xplRegKey As RegistryKey = HKLMRoot.OpenSubKey("Software\\xPL\\VFD Display Driver")
        If xplRegKey IsNot Nothing Then
            getRegSetting = CType(xplRegKey.GetValue(sSetting), String)
            xplRegKey.Close()
        Else
            getRegSetting = ""
        End If
        HKLMRoot = Nothing
    End Function

End Module
