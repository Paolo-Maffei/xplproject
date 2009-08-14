Public Class frmMiniControl



    Private Sub frmMiniControl_MouseClick(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles Me.MouseClick
        If e.Button = Windows.Forms.MouseButtons.Right Then
            Me.Close()
        End If
    End Sub
End Class