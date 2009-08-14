<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Public Class frmVolControl
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
        Me.components = New System.ComponentModel.Container
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(frmVolControl))
        Me.mnuMain = New System.Windows.Forms.MenuStrip
        Me.OptionsToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem
        Me.mProperties = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripSeparator2 = New System.Windows.Forms.ToolStripSeparator
        Me.mDND = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripSeparator1 = New System.Windows.Forms.ToolStripSeparator
        Me.mExit = New System.Windows.Forms.ToolStripMenuItem
        Me.HelpToolStripMenuItem = New System.Windows.Forms.ToolStripMenuItem
        Me.mHelp = New System.Windows.Forms.ToolStripMenuItem
        Me.mAbout = New System.Windows.Forms.ToolStripMenuItem
        Me.TrayIcon = New System.Windows.Forms.NotifyIcon(Me.components)
        Me.TrayContextMenu = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.OpenVolPanel = New System.Windows.Forms.ToolStripMenuItem
        Me.AudioProps = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripSeparator3 = New System.Windows.Forms.ToolStripSeparator
        Me.cmDND = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripSeparator4 = New System.Windows.Forms.ToolStripSeparator
        Me.cmdExit = New System.Windows.Forms.ToolStripMenuItem
        Me.StatusStrip1 = New System.Windows.Forms.StatusStrip
        Me.lblMixerName = New System.Windows.Forms.ToolStripStatusLabel
        Me.GroupBox1 = New System.Windows.Forms.GroupBox
        Me.Label6 = New System.Windows.Forms.Label
        Me.Label7 = New System.Windows.Forms.Label
        Me.CheckBox2 = New System.Windows.Forms.CheckBox
        Me.TrackBar5 = New System.Windows.Forms.TrackBar
        Me.TrackBar3 = New System.Windows.Forms.TrackBar
        Me.gbDevicePanel = New System.Windows.Forms.GroupBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.TrackBar1 = New System.Windows.Forms.TrackBar
        Me.Label2 = New System.Windows.Forms.Label
        Me.CheckBox1 = New System.Windows.Forms.CheckBox
        Me.TrackBar2 = New System.Windows.Forms.TrackBar
        Me.mnuMain.SuspendLayout()
        Me.TrayContextMenu.SuspendLayout()
        Me.StatusStrip1.SuspendLayout()
        Me.GroupBox1.SuspendLayout()
        CType(Me.TrackBar5, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.TrackBar3, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.gbDevicePanel.SuspendLayout()
        CType(Me.TrackBar1, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.TrackBar2, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'mnuMain
        '
        Me.mnuMain.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.OptionsToolStripMenuItem, Me.HelpToolStripMenuItem})
        Me.mnuMain.Location = New System.Drawing.Point(0, 0)
        Me.mnuMain.Name = "mnuMain"
        Me.mnuMain.RenderMode = System.Windows.Forms.ToolStripRenderMode.System
        Me.mnuMain.Size = New System.Drawing.Size(196, 24)
        Me.mnuMain.TabIndex = 0
        Me.mnuMain.Text = "MainMenu"
        '
        'OptionsToolStripMenuItem
        '
        Me.OptionsToolStripMenuItem.DropDownItems.AddRange(New System.Windows.Forms.ToolStripItem() {Me.mProperties, Me.ToolStripSeparator2, Me.mDND, Me.ToolStripSeparator1, Me.mExit})
        Me.OptionsToolStripMenuItem.Name = "OptionsToolStripMenuItem"
        Me.OptionsToolStripMenuItem.Text = "Options"
        '
        'mProperties
        '
        Me.mProperties.Name = "mProperties"
        Me.mProperties.Text = "Properties"
        '
        'ToolStripSeparator2
        '
        Me.ToolStripSeparator2.Name = "ToolStripSeparator2"
        '
        'mDND
        '
        Me.mDND.CheckOnClick = True
        Me.mDND.Name = "mDND"
        Me.mDND.Text = "Do Not Disturb"
        '
        'ToolStripSeparator1
        '
        Me.ToolStripSeparator1.Name = "ToolStripSeparator1"
        '
        'mExit
        '
        Me.mExit.Name = "mExit"
        Me.mExit.Text = "Exit"
        '
        'HelpToolStripMenuItem
        '
        Me.HelpToolStripMenuItem.DropDownItems.AddRange(New System.Windows.Forms.ToolStripItem() {Me.mHelp, Me.mAbout})
        Me.HelpToolStripMenuItem.Name = "HelpToolStripMenuItem"
        Me.HelpToolStripMenuItem.Text = "Help"
        '
        'mHelp
        '
        Me.mHelp.Name = "mHelp"
        Me.mHelp.Text = "Help Topics"
        '
        'mAbout
        '
        Me.mAbout.Name = "mAbout"
        Me.mAbout.Text = "About xPL Volume Control"
        '
        'TrayIcon
        '
        Me.TrayIcon.ContextMenuStrip = Me.TrayContextMenu
        Me.TrayIcon.Icon = CType(resources.GetObject("TrayIcon.Icon"), System.Drawing.Icon)
        Me.TrayIcon.Text = "Volume"
        Me.TrayIcon.Visible = True
        '
        'TrayContextMenu
        '
        Me.TrayContextMenu.Enabled = True
        Me.TrayContextMenu.GripMargin = New System.Windows.Forms.Padding(2)
        Me.TrayContextMenu.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.OpenVolPanel, Me.AudioProps, Me.ToolStripSeparator3, Me.cmDND, Me.ToolStripSeparator4, Me.cmdExit})
        Me.TrayContextMenu.Location = New System.Drawing.Point(25, 83)
        Me.TrayContextMenu.Name = "TrayContextMenu"
        Me.TrayContextMenu.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.TrayContextMenu.Size = New System.Drawing.Size(182, 104)
        '
        'OpenVolPanel
        '
        Me.OpenVolPanel.Font = New System.Drawing.Font("Tahoma", 8.25!, System.Drawing.FontStyle.Bold)
        Me.OpenVolPanel.Name = "OpenVolPanel"
        Me.OpenVolPanel.Text = "Open Volume Control"
        '
        'AudioProps
        '
        Me.AudioProps.Name = "AudioProps"
        Me.AudioProps.Text = "Adjust Audio Properties"
        '
        'ToolStripSeparator3
        '
        Me.ToolStripSeparator3.Name = "ToolStripSeparator3"
        '
        'cmDND
        '
        Me.cmDND.CheckOnClick = True
        Me.cmDND.Name = "cmDND"
        Me.cmDND.Text = "Do Not Disturb"
        '
        'ToolStripSeparator4
        '
        Me.ToolStripSeparator4.Name = "ToolStripSeparator4"
        '
        'cmdExit
        '
        Me.cmdExit.Name = "cmdExit"
        Me.cmdExit.Text = "Exit"
        '
        'StatusStrip1
        '
        Me.StatusStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.lblMixerName})
        Me.StatusStrip1.LayoutStyle = System.Windows.Forms.ToolStripLayoutStyle.Table
        Me.StatusStrip1.Location = New System.Drawing.Point(0, 261)
        Me.StatusStrip1.Name = "StatusStrip1"
        Me.StatusStrip1.Size = New System.Drawing.Size(196, 23)
        Me.StatusStrip1.SizingGrip = False
        Me.StatusStrip1.TabIndex = 6
        Me.StatusStrip1.Text = "StatusStrip1"
        '
        'lblMixerName
        '
        Me.lblMixerName.Name = "lblMixerName"
        Me.lblMixerName.Text = "No Mixer Device Found"
        '
        'GroupBox1
        '
        Me.GroupBox1.Controls.Add(Me.Label6)
        Me.GroupBox1.Controls.Add(Me.Label7)
        Me.GroupBox1.Controls.Add(Me.CheckBox2)
        Me.GroupBox1.Controls.Add(Me.TrackBar5)
        Me.GroupBox1.Controls.Add(Me.TrackBar3)
        Me.GroupBox1.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.GroupBox1.Location = New System.Drawing.Point(0, 26)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(106, 233)
        Me.GroupBox1.TabIndex = 10
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "Volume Control"
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(9, 84)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(41, 13)
        Me.Label6.TabIndex = 13
        Me.Label6.Text = "Volume:"
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.Location = New System.Drawing.Point(9, 23)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(45, 13)
        Me.Label7.TabIndex = 15
        Me.Label7.Text = "Balance:"
        '
        'CheckBox2
        '
        Me.CheckBox2.AutoSize = True
        Me.CheckBox2.Location = New System.Drawing.Point(10, 199)
        Me.CheckBox2.Name = "CheckBox2"
        Me.CheckBox2.Size = New System.Drawing.Size(60, 17)
        Me.CheckBox2.TabIndex = 14
        Me.CheckBox2.Text = "Mute All"
        '
        'TrackBar5
        '
        Me.TrackBar5.Location = New System.Drawing.Point(28, 99)
        Me.TrackBar5.Maximum = 100
        Me.TrackBar5.Name = "TrackBar5"
        Me.TrackBar5.Orientation = System.Windows.Forms.Orientation.Vertical
        Me.TrackBar5.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.TrackBar5.RightToLeftLayout = True
        Me.TrackBar5.Size = New System.Drawing.Size(42, 94)
        Me.TrackBar5.TabIndex = 12
        Me.TrackBar5.TickFrequency = 10
        Me.TrackBar5.TickStyle = System.Windows.Forms.TickStyle.Both
        Me.TrackBar5.Value = 1
        '
        'TrackBar3
        '
        Me.TrackBar3.Location = New System.Drawing.Point(12, 39)
        Me.TrackBar3.Name = "TrackBar3"
        Me.TrackBar3.Size = New System.Drawing.Size(73, 42)
        Me.TrackBar3.TabIndex = 17
        Me.TrackBar3.TickFrequency = 5
        Me.TrackBar3.Value = 5
        '
        'gbDevicePanel
        '
        Me.gbDevicePanel.Controls.Add(Me.Label1)
        Me.gbDevicePanel.Controls.Add(Me.TrackBar1)
        Me.gbDevicePanel.Controls.Add(Me.Label2)
        Me.gbDevicePanel.Controls.Add(Me.CheckBox1)
        Me.gbDevicePanel.Controls.Add(Me.TrackBar2)
        Me.gbDevicePanel.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.gbDevicePanel.Location = New System.Drawing.Point(103, 26)
        Me.gbDevicePanel.Name = "gbDevicePanel"
        Me.gbDevicePanel.Size = New System.Drawing.Size(93, 233)
        Me.gbDevicePanel.TabIndex = 11
        Me.gbDevicePanel.TabStop = False
        Me.gbDevicePanel.Text = "Device"
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(5, 83)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(41, 13)
        Me.Label1.TabIndex = 13
        Me.Label1.Text = "Volume:"
        '
        'TrackBar1
        '
        Me.TrackBar1.Location = New System.Drawing.Point(14, 39)
        Me.TrackBar1.Name = "TrackBar1"
        Me.TrackBar1.Size = New System.Drawing.Size(73, 42)
        Me.TrackBar1.TabIndex = 16
        Me.TrackBar1.TickFrequency = 5
        Me.TrackBar1.Value = 5
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(5, 23)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(45, 13)
        Me.Label2.TabIndex = 15
        Me.Label2.Text = "Balance:"
        '
        'CheckBox1
        '
        Me.CheckBox1.AutoSize = True
        Me.CheckBox1.Location = New System.Drawing.Point(14, 199)
        Me.CheckBox1.Name = "CheckBox1"
        Me.CheckBox1.Size = New System.Drawing.Size(46, 17)
        Me.CheckBox1.TabIndex = 14
        Me.CheckBox1.Text = "Mute"
        '
        'TrackBar2
        '
        Me.TrackBar2.Location = New System.Drawing.Point(30, 99)
        Me.TrackBar2.Maximum = 100
        Me.TrackBar2.Name = "TrackBar2"
        Me.TrackBar2.Orientation = System.Windows.Forms.Orientation.Vertical
        Me.TrackBar2.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.TrackBar2.RightToLeftLayout = True
        Me.TrackBar2.Size = New System.Drawing.Size(42, 94)
        Me.TrackBar2.TabIndex = 12
        Me.TrackBar2.TickFrequency = 10
        Me.TrackBar2.TickStyle = System.Windows.Forms.TickStyle.Both
        Me.TrackBar2.Value = 1
        '
        'frmVolControl
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(196, 284)
        Me.Controls.Add(Me.gbDevicePanel)
        Me.Controls.Add(Me.GroupBox1)
        Me.Controls.Add(Me.StatusStrip1)
        Me.Controls.Add(Me.mnuMain)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MainMenuStrip = Me.mnuMain
        Me.Name = "frmVolControl"
        Me.Text = "Volume Control"
        Me.mnuMain.ResumeLayout(False)
        Me.TrayContextMenu.ResumeLayout(False)
        Me.StatusStrip1.ResumeLayout(False)
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox1.PerformLayout()
        CType(Me.TrackBar5, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.TrackBar3, System.ComponentModel.ISupportInitialize).EndInit()
        Me.gbDevicePanel.ResumeLayout(False)
        Me.gbDevicePanel.PerformLayout()
        CType(Me.TrackBar1, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.TrackBar2, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents mnuMain As System.Windows.Forms.MenuStrip
    Friend WithEvents OptionsToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents HelpToolStripMenuItem As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents mProperties As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripSeparator1 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents mExit As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripSeparator2 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents mDND As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents mHelp As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents mAbout As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents TrayIcon As System.Windows.Forms.NotifyIcon
    Friend WithEvents StatusStrip1 As System.Windows.Forms.StatusStrip
    Friend WithEvents lblMixerName As System.Windows.Forms.ToolStripStatusLabel
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents CheckBox2 As System.Windows.Forms.CheckBox
    Friend WithEvents TrackBar5 As System.Windows.Forms.TrackBar
    Friend WithEvents TrackBar3 As System.Windows.Forms.TrackBar
    Friend WithEvents gbDevicePanel As System.Windows.Forms.GroupBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents TrackBar1 As System.Windows.Forms.TrackBar
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents CheckBox1 As System.Windows.Forms.CheckBox
    Friend WithEvents TrackBar2 As System.Windows.Forms.TrackBar
    Friend WithEvents TrayContextMenu As System.Windows.Forms.ContextMenuStrip
    Friend WithEvents OpenVolPanel As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents AudioProps As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripSeparator3 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents ToolStripSeparator4 As System.Windows.Forms.ToolStripSeparator
    Friend WithEvents cmDND As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents cmdExit As System.Windows.Forms.ToolStripMenuItem

End Class
