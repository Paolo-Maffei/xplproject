<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Example5
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
        Me.lblDescription = New System.Windows.Forms.Label
        Me.btnStartStop = New System.Windows.Forms.Button
        Me.lbStatus = New System.Windows.Forms.ListBox
        Me.lblStatusChanges = New System.Windows.Forms.Label
        Me.GroupBoxMessageHandling = New System.Windows.Forms.GroupBox
        Me.chkAll = New System.Windows.Forms.CheckBox
        Me.chkDoNotApplyFilters = New System.Windows.Forms.CheckBox
        Me.chkPassOthersConfig = New System.Windows.Forms.CheckBox
        Me.chkPassMyConfigStuff = New System.Windows.Forms.CheckBox
        Me.chkPassMyOwnEcho = New System.Windows.Forms.CheckBox
        Me.chkPassOthersHeartbeats = New System.Windows.Forms.CheckBox
        Me.chkPassMyHeartbeatStuff = New System.Windows.Forms.CheckBox
        Me.chkPassWhileAwaitingConfig = New System.Windows.Forms.CheckBox
        Me.chkToBeHandledOnly = New System.Windows.Forms.CheckBox
        Me.lbLog = New System.Windows.Forms.ListBox
        Me.btnSendHeartBeatRequest = New System.Windows.Forms.Button
        Me.btnScanNetwork = New System.Windows.Forms.Button
        Me.ToolTip = New System.Windows.Forms.ToolTip(Me.components)
        Me.ButtonClear = New System.Windows.Forms.Button
        Me.GroupBoxMessageHandling.SuspendLayout()
        Me.SuspendLayout()
        '
        'lblDescription
        '
        Me.lblDescription.AutoSize = True
        Me.lblDescription.Location = New System.Drawing.Point(16, 19)
        Me.lblDescription.Name = "lblDescription"
        Me.lblDescription.Size = New System.Drawing.Size(359, 13)
        Me.lblDescription.TabIndex = 0
        Me.lblDescription.Text = "This test form contains a single xPL device, click start/stop to make it work"
        '
        'btnStartStop
        '
        Me.btnStartStop.Location = New System.Drawing.Point(415, 14)
        Me.btnStartStop.Name = "btnStartStop"
        Me.btnStartStop.Size = New System.Drawing.Size(75, 23)
        Me.btnStartStop.TabIndex = 1
        Me.btnStartStop.Text = "Start"
        Me.btnStartStop.UseVisualStyleBackColor = True
        '
        'lbStatus
        '
        Me.lbStatus.FormattingEnabled = True
        Me.lbStatus.Location = New System.Drawing.Point(12, 61)
        Me.lbStatus.Name = "lbStatus"
        Me.lbStatus.Size = New System.Drawing.Size(143, 69)
        Me.lbStatus.TabIndex = 2
        '
        'lblStatusChanges
        '
        Me.lblStatusChanges.AutoSize = True
        Me.lblStatusChanges.Location = New System.Drawing.Point(12, 45)
        Me.lblStatusChanges.Name = "lblStatusChanges"
        Me.lblStatusChanges.Size = New System.Drawing.Size(81, 13)
        Me.lblStatusChanges.TabIndex = 3
        Me.lblStatusChanges.Text = "Status changes"
        '
        'GroupBoxMessageHandling
        '
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkAll)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkDoNotApplyFilters)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassOthersConfig)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassMyConfigStuff)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassMyOwnEcho)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassOthersHeartbeats)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassMyHeartbeatStuff)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkPassWhileAwaitingConfig)
        Me.GroupBoxMessageHandling.Controls.Add(Me.chkToBeHandledOnly)
        Me.GroupBoxMessageHandling.Location = New System.Drawing.Point(161, 43)
        Me.GroupBoxMessageHandling.Name = "GroupBoxMessageHandling"
        Me.GroupBoxMessageHandling.Size = New System.Drawing.Size(329, 140)
        Me.GroupBoxMessageHandling.TabIndex = 4
        Me.GroupBoxMessageHandling.TabStop = False
        Me.GroupBoxMessageHandling.Text = "Message passing"
        '
        'chkAll
        '
        Me.chkAll.AutoSize = True
        Me.chkAll.Location = New System.Drawing.Point(6, 19)
        Me.chkAll.Name = "chkAll"
        Me.chkAll.Size = New System.Drawing.Size(37, 17)
        Me.chkAll.TabIndex = 8
        Me.chkAll.Text = "All"
        Me.chkAll.UseVisualStyleBackColor = True
        '
        'chkDoNotApplyFilters
        '
        Me.chkDoNotApplyFilters.AutoSize = True
        Me.chkDoNotApplyFilters.Location = New System.Drawing.Point(6, 111)
        Me.chkDoNotApplyFilters.Name = "chkDoNotApplyFilters"
        Me.chkDoNotApplyFilters.Size = New System.Drawing.Size(110, 17)
        Me.chkDoNotApplyFilters.TabIndex = 7
        Me.chkDoNotApplyFilters.Text = "DoNotApplyFilters"
        Me.chkDoNotApplyFilters.UseVisualStyleBackColor = True
        '
        'chkPassOthersConfig
        '
        Me.chkPassOthersConfig.AutoSize = True
        Me.chkPassOthersConfig.Location = New System.Drawing.Point(180, 111)
        Me.chkPassOthersConfig.Name = "chkPassOthersConfig"
        Me.chkPassOthersConfig.Size = New System.Drawing.Size(110, 17)
        Me.chkPassOthersConfig.TabIndex = 6
        Me.chkPassOthersConfig.Text = "PassOthersConfig"
        Me.chkPassOthersConfig.UseVisualStyleBackColor = True
        '
        'chkPassMyConfigStuff
        '
        Me.chkPassMyConfigStuff.AutoSize = True
        Me.chkPassMyConfigStuff.Location = New System.Drawing.Point(180, 42)
        Me.chkPassMyConfigStuff.Name = "chkPassMyConfigStuff"
        Me.chkPassMyConfigStuff.Size = New System.Drawing.Size(115, 17)
        Me.chkPassMyConfigStuff.TabIndex = 5
        Me.chkPassMyConfigStuff.Text = "PassMyConfigStuff"
        Me.chkPassMyConfigStuff.UseVisualStyleBackColor = True
        '
        'chkPassMyOwnEcho
        '
        Me.chkPassMyOwnEcho.AutoSize = True
        Me.chkPassMyOwnEcho.Location = New System.Drawing.Point(180, 65)
        Me.chkPassMyOwnEcho.Name = "chkPassMyOwnEcho"
        Me.chkPassMyOwnEcho.Size = New System.Drawing.Size(110, 17)
        Me.chkPassMyOwnEcho.TabIndex = 4
        Me.chkPassMyOwnEcho.Text = "PassMyOwnEcho"
        Me.chkPassMyOwnEcho.UseVisualStyleBackColor = True
        '
        'chkPassOthersHeartbeats
        '
        Me.chkPassOthersHeartbeats.AutoSize = True
        Me.chkPassOthersHeartbeats.Location = New System.Drawing.Point(180, 88)
        Me.chkPassOthersHeartbeats.Name = "chkPassOthersHeartbeats"
        Me.chkPassOthersHeartbeats.Size = New System.Drawing.Size(132, 17)
        Me.chkPassOthersHeartbeats.TabIndex = 3
        Me.chkPassOthersHeartbeats.Text = "PassOthersHeartbeats"
        Me.chkPassOthersHeartbeats.UseVisualStyleBackColor = True
        '
        'chkPassMyHeartbeatStuff
        '
        Me.chkPassMyHeartbeatStuff.AutoSize = True
        Me.chkPassMyHeartbeatStuff.Location = New System.Drawing.Point(180, 19)
        Me.chkPassMyHeartbeatStuff.Name = "chkPassMyHeartbeatStuff"
        Me.chkPassMyHeartbeatStuff.Size = New System.Drawing.Size(132, 17)
        Me.chkPassMyHeartbeatStuff.TabIndex = 2
        Me.chkPassMyHeartbeatStuff.Text = "PassMyHeartbeatStuff"
        Me.chkPassMyHeartbeatStuff.UseVisualStyleBackColor = True
        '
        'chkPassWhileAwaitingConfig
        '
        Me.chkPassWhileAwaitingConfig.AutoSize = True
        Me.chkPassWhileAwaitingConfig.Location = New System.Drawing.Point(6, 88)
        Me.chkPassWhileAwaitingConfig.Name = "chkPassWhileAwaitingConfig"
        Me.chkPassWhileAwaitingConfig.Size = New System.Drawing.Size(146, 17)
        Me.chkPassWhileAwaitingConfig.TabIndex = 1
        Me.chkPassWhileAwaitingConfig.Text = "PassWhileAwaitingConfig"
        Me.chkPassWhileAwaitingConfig.UseVisualStyleBackColor = True
        '
        'chkToBeHandledOnly
        '
        Me.chkToBeHandledOnly.AutoSize = True
        Me.chkToBeHandledOnly.Location = New System.Drawing.Point(6, 42)
        Me.chkToBeHandledOnly.Name = "chkToBeHandledOnly"
        Me.chkToBeHandledOnly.Size = New System.Drawing.Size(113, 17)
        Me.chkToBeHandledOnly.TabIndex = 0
        Me.chkToBeHandledOnly.Text = "ToBeHandledOnly"
        Me.chkToBeHandledOnly.UseVisualStyleBackColor = True
        '
        'lbLog
        '
        Me.lbLog.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lbLog.Font = New System.Drawing.Font("Courier New", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lbLog.FormattingEnabled = True
        Me.lbLog.ItemHeight = 14
        Me.lbLog.Location = New System.Drawing.Point(12, 190)
        Me.lbLog.Name = "lbLog"
        Me.lbLog.Size = New System.Drawing.Size(480, 172)
        Me.lbLog.TabIndex = 5
        '
        'btnSendHeartBeatRequest
        '
        Me.btnSendHeartBeatRequest.Location = New System.Drawing.Point(12, 136)
        Me.btnSendHeartBeatRequest.Name = "btnSendHeartBeatRequest"
        Me.btnSendHeartBeatRequest.Size = New System.Drawing.Size(143, 23)
        Me.btnSendHeartBeatRequest.TabIndex = 6
        Me.btnSendHeartBeatRequest.Text = "Send Heart Beat request"
        Me.ToolTip.SetToolTip(Me.btnSendHeartBeatRequest, "Request heartbeat messages from devices on the network")
        Me.btnSendHeartBeatRequest.UseVisualStyleBackColor = True
        '
        'btnScanNetwork
        '
        Me.btnScanNetwork.Location = New System.Drawing.Point(12, 161)
        Me.btnScanNetwork.Name = "btnScanNetwork"
        Me.btnScanNetwork.Size = New System.Drawing.Size(143, 23)
        Me.btnScanNetwork.TabIndex = 7
        Me.btnScanNetwork.Text = "Scan network"
        Me.ToolTip.SetToolTip(Me.btnScanNetwork, "Request heartbeats and then request configuration information from devices found " & _
                "(takes 10-15 seconds)")
        Me.btnScanNetwork.UseVisualStyleBackColor = True
        '
        'ButtonClear
        '
        Me.ButtonClear.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonClear.Location = New System.Drawing.Point(417, 368)
        Me.ButtonClear.Name = "ButtonClear"
        Me.ButtonClear.Size = New System.Drawing.Size(75, 23)
        Me.ButtonClear.TabIndex = 8
        Me.ButtonClear.Text = "Clear"
        Me.ButtonClear.UseVisualStyleBackColor = True
        '
        'Example5
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(504, 396)
        Me.Controls.Add(Me.ButtonClear)
        Me.Controls.Add(Me.btnScanNetwork)
        Me.Controls.Add(Me.btnSendHeartBeatRequest)
        Me.Controls.Add(Me.lbLog)
        Me.Controls.Add(Me.GroupBoxMessageHandling)
        Me.Controls.Add(Me.lblStatusChanges)
        Me.Controls.Add(Me.lbStatus)
        Me.Controls.Add(Me.btnStartStop)
        Me.Controls.Add(Me.lblDescription)
        Me.Name = "Example5"
        Me.Text = "Example5"
        Me.GroupBoxMessageHandling.ResumeLayout(False)
        Me.GroupBoxMessageHandling.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lblDescription As System.Windows.Forms.Label
    Friend WithEvents btnStartStop As System.Windows.Forms.Button
    Friend WithEvents lbStatus As System.Windows.Forms.ListBox
    Friend WithEvents lblStatusChanges As System.Windows.Forms.Label
    Friend WithEvents GroupBoxMessageHandling As System.Windows.Forms.GroupBox
    Friend WithEvents chkToBeHandledOnly As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassWhileAwaitingConfig As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassMyHeartbeatStuff As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassOthersHeartbeats As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassMyOwnEcho As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassMyConfigStuff As System.Windows.Forms.CheckBox
    Friend WithEvents chkPassOthersConfig As System.Windows.Forms.CheckBox
    Friend WithEvents chkDoNotApplyFilters As System.Windows.Forms.CheckBox
    Friend WithEvents chkAll As System.Windows.Forms.CheckBox
    Friend WithEvents lbLog As System.Windows.Forms.ListBox
    Friend WithEvents btnSendHeartBeatRequest As System.Windows.Forms.Button
    Friend WithEvents btnScanNetwork As System.Windows.Forms.Button
    Friend WithEvents ToolTip As System.Windows.Forms.ToolTip
    Friend WithEvents ButtonClear As System.Windows.Forms.Button
End Class
