Option Strict On
Imports xPL

Public Class Form1
    Private xplug As New xPLPluginStore
    Private Sub Form1_FormClosing(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing
        If xplug.UpdateRunning Then
            e.Cancel = True
            MsgBox("Please wait for update to finish before closing the application")
        End If
    End Sub

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim frm As New xPLPluginUpdateDlgLog
        Dim frmsml As New xPLPluginUpdateDlgSmall
        xplug.Debug = True
        frm.Plugin = xplug
        frmsml.Plugin = xplug
        Try
            If MsgBox("Show log?", MsgBoxStyle.YesNo) = MsgBoxResult.No Then
                xplug.UpdatePluginStore(True)
                frmsml.ShowDialog()
            Else
                xplug.UpdatePluginStore(True)
                frm.Show()
            End If
        Catch ex As Exception

        End Try
        While Not xplug.IsLoaded
            Threading.Thread.Sleep(100)
        End While
        MsgBox(xplug.LocationsXmlElement.InnerXml)
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        Encoded.Text = xPL_Base.StateEncode(ToDecode.Text)
        Decoded.Text = xPL_Base.StateDecode(Encoded.Text)
        Dim s As String

        If Decoded.Text = ToDecode.Text Then
            MsgBox("They are equal", MsgBoxStyle.Information)
        Else
            MsgBox("They are not equal!!", MsgBoxStyle.Critical)
        End If
    End Sub
End Class