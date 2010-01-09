<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class MainInterface
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
        Me.btnConfigure = New System.Windows.Forms.Button
        Me.lbSMSDevices = New System.Windows.Forms.ListBox
        Me.btnClose = New System.Windows.Forms.Button
        Me.btnSearch = New System.Windows.Forms.Button
        Me.SuspendLayout()
        '
        'btnConfigure
        '
        Me.btnConfigure.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnConfigure.Location = New System.Drawing.Point(197, 12)
        Me.btnConfigure.Name = "btnConfigure"
        Me.btnConfigure.Size = New System.Drawing.Size(75, 23)
        Me.btnConfigure.TabIndex = 0
        Me.btnConfigure.Text = "Configure"
        Me.btnConfigure.UseVisualStyleBackColor = True
        '
        'lbSMSDevices
        '
        Me.lbSMSDevices.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lbSMSDevices.FormattingEnabled = True
        Me.lbSMSDevices.IntegralHeight = False
        Me.lbSMSDevices.Location = New System.Drawing.Point(12, 12)
        Me.lbSMSDevices.Name = "lbSMSDevices"
        Me.lbSMSDevices.Size = New System.Drawing.Size(179, 125)
        Me.lbSMSDevices.TabIndex = 1
        '
        'btnClose
        '
        Me.btnClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClose.Location = New System.Drawing.Point(197, 114)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 2
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'btnSearch
        '
        Me.btnSearch.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnSearch.Location = New System.Drawing.Point(197, 41)
        Me.btnSearch.Name = "btnSearch"
        Me.btnSearch.Size = New System.Drawing.Size(75, 23)
        Me.btnSearch.TabIndex = 3
        Me.btnSearch.Text = "Refresh"
        Me.btnSearch.UseVisualStyleBackColor = True
        '
        'MainInterface
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(284, 149)
        Me.Controls.Add(Me.btnSearch)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.lbSMSDevices)
        Me.Controls.Add(Me.btnConfigure)
        Me.MinimumSize = New System.Drawing.Size(271, 168)
        Me.Name = "MainInterface"
        Me.Text = "xPL SMS service configurator"
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents btnConfigure As System.Windows.Forms.Button
    Friend WithEvents lbSMSDevices As System.Windows.Forms.ListBox
    Friend WithEvents btnClose As System.Windows.Forms.Button
    Friend WithEvents btnSearch As System.Windows.Forms.Button
End Class
