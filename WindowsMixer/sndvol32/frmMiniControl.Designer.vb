<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Public Class frmMiniControl
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.chkMute = New System.Windows.Forms.CheckBox
        Me.barVolume = New System.Windows.Forms.TrackBar
        CType(Me.barVolume, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'chkMute
        '
        Me.chkMute.AutoSize = True
        Me.chkMute.Location = New System.Drawing.Point(12, 142)
        Me.chkMute.Name = "chkMute"
        Me.chkMute.Size = New System.Drawing.Size(46, 17)
        Me.chkMute.TabIndex = 6
        Me.chkMute.Text = "Mute"
        '
        'barVolume
        '
        Me.barVolume.Location = New System.Drawing.Point(16, 12)
        Me.barVolume.Maximum = 100
        Me.barVolume.Name = "barVolume"
        Me.barVolume.Orientation = System.Windows.Forms.Orientation.Vertical
        Me.barVolume.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.barVolume.RightToLeftLayout = True
        Me.barVolume.Size = New System.Drawing.Size(42, 111)
        Me.barVolume.TabIndex = 5
        Me.barVolume.TickFrequency = 10
        Me.barVolume.TickStyle = System.Windows.Forms.TickStyle.Both
        Me.barVolume.Value = 1
        '
        'frmMiniControl
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(70, 171)
        Me.ControlBox = False
        Me.Controls.Add(Me.chkMute)
        Me.Controls.Add(Me.barVolume)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow
        Me.Name = "frmMiniControl"
        Me.Opacity = 0.8
        Me.Text = "Volume"
        Me.TopMost = True
        CType(Me.barVolume, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents chkMute As System.Windows.Forms.CheckBox
    Friend WithEvents barVolume As System.Windows.Forms.TrackBar
End Class
