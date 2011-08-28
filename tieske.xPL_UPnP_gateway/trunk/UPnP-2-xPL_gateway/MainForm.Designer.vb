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
        Me.components = New System.ComponentModel.Container
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(MainForm))
        Me.lbLog = New System.Windows.Forms.ListBox
        Me.chkStartMinimized = New System.Windows.Forms.CheckBox
        Me.tbLogLines = New System.Windows.Forms.TextBox
        Me.lblLinesToKeep = New System.Windows.Forms.Label
        Me.btnCopyToClipboard = New System.Windows.Forms.Button
        Me.TaskBarIcon = New System.Windows.Forms.NotifyIcon(Me.components)
        Me.PopupMenu = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.ShowLogToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem
        Me.ExitToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem
        Me.btnClose = New System.Windows.Forms.Button
        Me.PopupMenu.SuspendLayout()
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
        Me.lbLog.Size = New System.Drawing.Size(712, 256)
        Me.lbLog.TabIndex = 2
        '
        'chkStartMinimized
        '
        Me.chkStartMinimized.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.chkStartMinimized.AutoSize = True
        Me.chkStartMinimized.Checked = Global.UPnP2xPL.My.MySettings.Default.StartMinimized
        Me.chkStartMinimized.DataBindings.Add(New System.Windows.Forms.Binding("Checked", Global.UPnP2xPL.My.MySettings.Default, "StartMinimized", True, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged))
        Me.chkStartMinimized.Location = New System.Drawing.Point(294, 282)
        Me.chkStartMinimized.Name = "chkStartMinimized"
        Me.chkStartMinimized.Size = New System.Drawing.Size(96, 17)
        Me.chkStartMinimized.TabIndex = 3
        Me.chkStartMinimized.Text = "Start minimized"
        Me.chkStartMinimized.UseVisualStyleBackColor = True
        '
        'tbLogLines
        '
        Me.tbLogLines.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.tbLogLines.Location = New System.Drawing.Point(213, 280)
        Me.tbLogLines.Name = "tbLogLines"
        Me.tbLogLines.Size = New System.Drawing.Size(61, 20)
        Me.tbLogLines.TabIndex = 4
        '
        'lblLinesToKeep
        '
        Me.lblLinesToKeep.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.lblLinesToKeep.AutoSize = True
        Me.lblLinesToKeep.Location = New System.Drawing.Point(136, 283)
        Me.lblLinesToKeep.Name = "lblLinesToKeep"
        Me.lblLinesToKeep.Size = New System.Drawing.Size(71, 13)
        Me.lblLinesToKeep.TabIndex = 5
        Me.lblLinesToKeep.Text = "Lines to keep"
        '
        'btnCopyToClipboard
        '
        Me.btnCopyToClipboard.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.btnCopyToClipboard.Location = New System.Drawing.Point(12, 278)
        Me.btnCopyToClipboard.Name = "btnCopyToClipboard"
        Me.btnCopyToClipboard.Size = New System.Drawing.Size(118, 23)
        Me.btnCopyToClipboard.TabIndex = 6
        Me.btnCopyToClipboard.Text = "Copy to clipboard"
        Me.btnCopyToClipboard.UseVisualStyleBackColor = True
        '
        'TaskBarIcon
        '
        Me.TaskBarIcon.BalloonTipText = "UPnP-2-xPL gateway"
        Me.TaskBarIcon.ContextMenuStrip = Me.PopupMenu
        Me.TaskBarIcon.Icon = CType(resources.GetObject("TaskBarIcon.Icon"), System.Drawing.Icon)
        Me.TaskBarIcon.Visible = True
        '
        'PopupMenu
        '
        Me.PopupMenu.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ShowLogToolStripMenuItem, Me.ExitToolStripMenuItem})
        Me.PopupMenu.Name = "PopupMenu"
        Me.PopupMenu.Size = New System.Drawing.Size(129, 48)
        '
        'ShowLogToolStripMenuItem
        '
        Me.ShowLogToolStripMenuItem.Name = "ShowLogToolStripMenuItem"
        Me.ShowLogToolStripMenuItem.Size = New System.Drawing.Size(128, 22)
        Me.ShowLogToolStripMenuItem.Text = "Show log"
        '
        'ExitToolStripMenuItem
        '
        Me.ExitToolStripMenuItem.Name = "ExitToolStripMenuItem"
        Me.ExitToolStripMenuItem.Size = New System.Drawing.Size(128, 22)
        Me.ExitToolStripMenuItem.Text = "Exit"
        '
        'btnClose
        '
        Me.btnClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClose.Location = New System.Drawing.Point(649, 278)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 7
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'MainForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(736, 302)
        Me.ControlBox = False
        Me.Controls.Add(Me.btnCopyToClipboard)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.lblLinesToKeep)
        Me.Controls.Add(Me.lbLog)
        Me.Controls.Add(Me.tbLogLines)
        Me.Controls.Add(Me.chkStartMinimized)
        Me.MinimumSize = New System.Drawing.Size(493, 163)
        Me.Name = "MainForm"
        Me.ShowInTaskbar = False
        Me.Text = "UPnP 2 xPL gateway"
        Me.PopupMenu.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lbLog As System.Windows.Forms.ListBox
    Friend WithEvents chkStartMinimized As System.Windows.Forms.CheckBox
    Friend WithEvents tbLogLines As System.Windows.Forms.TextBox
    Friend WithEvents lblLinesToKeep As System.Windows.Forms.Label
    Friend WithEvents btnCopyToClipboard As System.Windows.Forms.Button
    Friend WithEvents TaskBarIcon As System.Windows.Forms.NotifyIcon
    Friend WithEvents PopupMenu As System.Windows.Forms.ContextMenuStrip
    Friend WithEvents ShowLogToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ExitToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents btnClose As System.Windows.Forms.Button

End Class
