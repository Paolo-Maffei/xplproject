<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class xPLPluginUpdateDlgSmall
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.pbProgress = New System.Windows.Forms.ProgressBar
        Me.lblStatus = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'pbProgress
        '
        Me.pbProgress.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.pbProgress.Location = New System.Drawing.Point(12, 32)
        Me.pbProgress.Name = "pbProgress"
        Me.pbProgress.Size = New System.Drawing.Size(291, 23)
        Me.pbProgress.Step = 1
        Me.pbProgress.TabIndex = 0
        '
        'lblStatus
        '
        Me.lblStatus.AutoSize = True
        Me.lblStatus.Location = New System.Drawing.Point(12, 9)
        Me.lblStatus.Name = "lblStatus"
        Me.lblStatus.Size = New System.Drawing.Size(70, 13)
        Me.lblStatus.TabIndex = 1
        Me.lblStatus.Text = "Please wait..."
        '
        'xPLPluginUpdateDlgSmall
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(315, 67)
        Me.ControlBox = False
        Me.Controls.Add(Me.lblStatus)
        Me.Controls.Add(Me.pbProgress)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.Name = "xPLPluginUpdateDlgSmall"
        Me.Text = "Updating information, please wait..."
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents pbProgress As System.Windows.Forms.ProgressBar
    Friend WithEvents lblStatus As System.Windows.Forms.Label

End Class
