<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class MainForm
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
        Me.lbLog = New System.Windows.Forms.ListBox
        Me.chkStartMinimized = New System.Windows.Forms.CheckBox
        Me.SuspendLayout()
        '
        'lbLog
        '
        Me.lbLog.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lbLog.Font = New System.Drawing.Font("Courier New", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbLog.FormattingEnabled = True
        Me.lbLog.ItemHeight = 14
        Me.lbLog.Location = New System.Drawing.Point(12, 12)
        Me.lbLog.Name = "lbLog"
        Me.lbLog.Size = New System.Drawing.Size(743, 228)
        Me.lbLog.TabIndex = 2
        '
        'chkStartMinimized
        '
        Me.chkStartMinimized.AutoSize = True
        Me.chkStartMinimized.Checked = Global.UPnP2xPL.My.MySettings.Default.StartMinimized
        Me.chkStartMinimized.DataBindings.Add(New System.Windows.Forms.Binding("Checked", Global.UPnP2xPL.My.MySettings.Default, "StartMinimized", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.chkStartMinimized.Location = New System.Drawing.Point(12, 246)
        Me.chkStartMinimized.Name = "chkStartMinimized"
        Me.chkStartMinimized.Size = New System.Drawing.Size(96, 17)
        Me.chkStartMinimized.TabIndex = 3
        Me.chkStartMinimized.Text = "Start minimized"
        Me.chkStartMinimized.UseVisualStyleBackColor = True
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(767, 266)
        Me.Controls.Add(Me.chkStartMinimized)
        Me.Controls.Add(Me.lbLog)
        Me.Name = "Form1"
        Me.Text = "UPnP 2 xPL gateway"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lbLog As System.Windows.Forms.ListBox
    Friend WithEvents chkStartMinimized As System.Windows.Forms.CheckBox

End Class
