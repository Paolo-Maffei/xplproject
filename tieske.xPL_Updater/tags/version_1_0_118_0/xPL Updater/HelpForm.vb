Public Class HelpForm

    Private Sub HelpForm_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Activated
        Me.tbHelp.SelectionLength = 0
    End Sub

    Private Sub HelpForm_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Me.Icon = xPL_Base.XPL_Icon
        Me.tbHelp.Text = My.Resources.Help
    End Sub

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.Close()
    End Sub
End Class