Option Strict On

''' <summary>
''' Form to be used to show progress while updating the PluginStore. This form shows a status text, 
''' a progressbar and closes automatically when the update is complete.
''' </summary>
''' <remarks>To use it, first set the <c>Plugin</c> property of the form, then start the update by
''' calling the <seealso cref="xPLPluginStore.UpdatePluginStore" /> method, finally call either the
''' <c>Show</c> or <c>ShowModal</c> methods of the form.</remarks>
Public Class xPLPluginUpdateDlgSmall
    ''' <summary>
    ''' Plugin is to be set by the calling code to the pluginstore being updated
    ''' </summary>
    ''' <remarks></remarks>
    Public WithEvents Plugin As xPLPluginStore

    Private Sub xPLPluginUpdateDialog_FormClosing(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing
        Try
            RemoveHandler Plugin.UpdateComplete, AddressOf UpdProgrDone
            RemoveHandler Plugin.UpdateProgress, AddressOf UpdProgr
        Catch ex As Exception
        End Try
    End Sub
    Private Sub PluginUpdateDialog_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Try
            Me.pbProgress.Value = 0
            Me.Icon = xPL_Base.XPL_Icon
            AddHandler Plugin.UpdateProgress, AddressOf UpdProgr
            AddHandler Plugin.UpdateComplete, AddressOf UpdProgrDone
        Catch ex As Exception
        End Try
    End Sub
    Private Delegate Sub dUpdProgrEx(ByVal e As xPLPluginStore.UpdateInfo)
    Private Sub UpdProgrEx(ByVal e As xPLPluginStore.UpdateInfo)
        ' set caption
        Me.lblStatus.Text = e.StatusMsg
        ' set progress bar
        Me.pbProgress.Value = e.PercentComplete
        If e.PercentComplete = 100 Then Me.Close() ' we're done, so close
    End Sub
    Private Sub UpdProgr(ByVal e As xPLPluginStore.UpdateInfo)
        If Me.pbProgress.InvokeRequired Then
            Dim d As dUpdProgrEx = AddressOf UpdProgrEx
            Me.Invoke(d, e)
        Else
            UpdProgrEx(e)
        End If
    End Sub
    Private Sub UpdProgrDone(ByVal e As xPLPluginStore.UpdateInfo)
        e.PercentComplete = 100       ' make the form being closed
        UpdProgr(e)
    End Sub
End Class

