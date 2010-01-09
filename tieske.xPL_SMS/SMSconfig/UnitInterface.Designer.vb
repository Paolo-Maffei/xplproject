<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class UnitInterface
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
        Me.tbSMSurl = New System.Windows.Forms.TextBox
        Me.btnPhMessage = New System.Windows.Forms.Button
        Me.btnPhRecipient = New System.Windows.Forms.Button
        Me.GroupBox1 = New System.Windows.Forms.GroupBox
        Me.GroupBox2 = New System.Windows.Forms.GroupBox
        Me.rbFailure = New System.Windows.Forms.RadioButton
        Me.rbSuccess = New System.Windows.Forms.RadioButton
        Me.tbSMSresponse = New System.Windows.Forms.TextBox
        Me.GroupBox3 = New System.Windows.Forms.GroupBox
        Me.tbCreditURL = New System.Windows.Forms.TextBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.tbDelimEnd = New System.Windows.Forms.TextBox
        Me.GroupBox4 = New System.Windows.Forms.GroupBox
        Me.tbDelimStart = New System.Windows.Forms.TextBox
        Me.btnOK = New System.Windows.Forms.Button
        Me.btnCancel = New System.Windows.Forms.Button
        Me.gbGenericxPL = New System.Windows.Forms.GroupBox
        Me.tcGeneric = New System.Windows.Forms.TabControl
        Me.tpGroups = New System.Windows.Forms.TabPage
        Me.btnRemoveGroup = New System.Windows.Forms.Button
        Me.btnAddGroup = New System.Windows.Forms.Button
        Me.tbGroup = New System.Windows.Forms.TextBox
        Me.lblGroups = New System.Windows.Forms.Label
        Me.lbGroups = New System.Windows.Forms.ListBox
        Me.tpFilters = New System.Windows.Forms.TabPage
        Me.btnRemoveFilter = New System.Windows.Forms.Button
        Me.btnAddFilter = New System.Windows.Forms.Button
        Me.tbFilter = New System.Windows.Forms.TextBox
        Me.lbFilters = New System.Windows.Forms.ListBox
        Me.Label3 = New System.Windows.Forms.Label
        Me.tbInterval = New System.Windows.Forms.NumericUpDown
        Me.GroupBox6 = New System.Windows.Forms.GroupBox
        Me.tbNewConf = New System.Windows.Forms.TextBox
        Me.lblAddress = New System.Windows.Forms.Label
        Me.GroupBox1.SuspendLayout()
        Me.GroupBox2.SuspendLayout()
        Me.GroupBox3.SuspendLayout()
        Me.GroupBox4.SuspendLayout()
        Me.gbGenericxPL.SuspendLayout()
        Me.tcGeneric.SuspendLayout()
        Me.tpGroups.SuspendLayout()
        Me.tpFilters.SuspendLayout()
        CType(Me.tbInterval, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.GroupBox6.SuspendLayout()
        Me.SuspendLayout()
        '
        'tbSMSurl
        '
        Me.tbSMSurl.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbSMSurl.Location = New System.Drawing.Point(6, 19)
        Me.tbSMSurl.Name = "tbSMSurl"
        Me.tbSMSurl.Size = New System.Drawing.Size(451, 20)
        Me.tbSMSurl.TabIndex = 0
        '
        'btnPhMessage
        '
        Me.btnPhMessage.Location = New System.Drawing.Point(6, 45)
        Me.btnPhMessage.Name = "btnPhMessage"
        Me.btnPhMessage.Size = New System.Drawing.Size(157, 23)
        Me.btnPhMessage.TabIndex = 1
        Me.btnPhMessage.Text = "Insert message placeholder"
        Me.btnPhMessage.UseVisualStyleBackColor = True
        '
        'btnPhRecipient
        '
        Me.btnPhRecipient.Location = New System.Drawing.Point(169, 45)
        Me.btnPhRecipient.Name = "btnPhRecipient"
        Me.btnPhRecipient.Size = New System.Drawing.Size(157, 23)
        Me.btnPhRecipient.TabIndex = 2
        Me.btnPhRecipient.Text = "Insert recipient placeholder"
        Me.btnPhRecipient.UseVisualStyleBackColor = True
        '
        'GroupBox1
        '
        Me.GroupBox1.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox1.Controls.Add(Me.tbSMSurl)
        Me.GroupBox1.Controls.Add(Me.btnPhRecipient)
        Me.GroupBox1.Controls.Add(Me.btnPhMessage)
        Me.GroupBox1.Location = New System.Drawing.Point(12, 144)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(470, 76)
        Me.GroupBox1.TabIndex = 1
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "SMS command URL"
        '
        'GroupBox2
        '
        Me.GroupBox2.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox2.Controls.Add(Me.rbFailure)
        Me.GroupBox2.Controls.Add(Me.rbSuccess)
        Me.GroupBox2.Controls.Add(Me.tbSMSresponse)
        Me.GroupBox2.Location = New System.Drawing.Point(12, 226)
        Me.GroupBox2.Name = "GroupBox2"
        Me.GroupBox2.Size = New System.Drawing.Size(470, 48)
        Me.GroupBox2.TabIndex = 2
        Me.GroupBox2.TabStop = False
        Me.GroupBox2.Text = "Text to look for in the response of the SMS command URL"
        '
        'rbFailure
        '
        Me.rbFailure.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.rbFailure.AutoSize = True
        Me.rbFailure.Location = New System.Drawing.Point(358, 20)
        Me.rbFailure.Name = "rbFailure"
        Me.rbFailure.Size = New System.Drawing.Size(99, 17)
        Me.rbFailure.TabIndex = 2
        Me.rbFailure.TabStop = True
        Me.rbFailure.Text = "Found is Failure"
        Me.rbFailure.UseVisualStyleBackColor = True
        '
        'rbSuccess
        '
        Me.rbSuccess.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.rbSuccess.AutoSize = True
        Me.rbSuccess.Location = New System.Drawing.Point(234, 19)
        Me.rbSuccess.Name = "rbSuccess"
        Me.rbSuccess.Size = New System.Drawing.Size(109, 17)
        Me.rbSuccess.TabIndex = 1
        Me.rbSuccess.TabStop = True
        Me.rbSuccess.Text = "Found is Success"
        Me.rbSuccess.UseVisualStyleBackColor = True
        '
        'tbSMSresponse
        '
        Me.tbSMSresponse.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbSMSresponse.Location = New System.Drawing.Point(6, 19)
        Me.tbSMSresponse.Name = "tbSMSresponse"
        Me.tbSMSresponse.Size = New System.Drawing.Size(222, 20)
        Me.tbSMSresponse.TabIndex = 0
        '
        'GroupBox3
        '
        Me.GroupBox3.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox3.Controls.Add(Me.tbCreditURL)
        Me.GroupBox3.Location = New System.Drawing.Point(12, 280)
        Me.GroupBox3.Name = "GroupBox3"
        Me.GroupBox3.Size = New System.Drawing.Size(470, 48)
        Me.GroupBox3.TabIndex = 3
        Me.GroupBox3.TabStop = False
        Me.GroupBox3.Text = "Credit request URL"
        '
        'tbCreditURL
        '
        Me.tbCreditURL.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbCreditURL.Location = New System.Drawing.Point(6, 19)
        Me.tbCreditURL.Name = "tbCreditURL"
        Me.tbCreditURL.Size = New System.Drawing.Size(451, 20)
        Me.tbCreditURL.TabIndex = 0
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(6, 22)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(70, 13)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "Start delimiter"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(243, 22)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(67, 13)
        Me.Label2.TabIndex = 2
        Me.Label2.Text = "End delimiter"
        '
        'tbDelimEnd
        '
        Me.tbDelimEnd.Location = New System.Drawing.Point(325, 19)
        Me.tbDelimEnd.Name = "tbDelimEnd"
        Me.tbDelimEnd.Size = New System.Drawing.Size(132, 20)
        Me.tbDelimEnd.TabIndex = 3
        '
        'GroupBox4
        '
        Me.GroupBox4.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox4.Controls.Add(Me.tbDelimStart)
        Me.GroupBox4.Controls.Add(Me.Label2)
        Me.GroupBox4.Controls.Add(Me.tbDelimEnd)
        Me.GroupBox4.Controls.Add(Me.Label1)
        Me.GroupBox4.Location = New System.Drawing.Point(12, 334)
        Me.GroupBox4.Name = "GroupBox4"
        Me.GroupBox4.Size = New System.Drawing.Size(470, 48)
        Me.GroupBox4.TabIndex = 4
        Me.GroupBox4.TabStop = False
        Me.GroupBox4.Text = "Text to look for in credit response"
        '
        'tbDelimStart
        '
        Me.tbDelimStart.Location = New System.Drawing.Point(96, 19)
        Me.tbDelimStart.Name = "tbDelimStart"
        Me.tbDelimStart.Size = New System.Drawing.Size(132, 20)
        Me.tbDelimStart.TabIndex = 1
        '
        'btnOK
        '
        Me.btnOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnOK.DialogResult = System.Windows.Forms.DialogResult.OK
        Me.btnOK.Location = New System.Drawing.Point(407, 388)
        Me.btnOK.Name = "btnOK"
        Me.btnOK.Size = New System.Drawing.Size(75, 23)
        Me.btnOK.TabIndex = 6
        Me.btnOK.Text = "OK"
        Me.btnOK.UseVisualStyleBackColor = True
        '
        'btnCancel
        '
        Me.btnCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.btnCancel.Location = New System.Drawing.Point(326, 388)
        Me.btnCancel.Name = "btnCancel"
        Me.btnCancel.Size = New System.Drawing.Size(75, 23)
        Me.btnCancel.TabIndex = 5
        Me.btnCancel.Text = "Cancel"
        Me.btnCancel.UseVisualStyleBackColor = True
        '
        'gbGenericxPL
        '
        Me.gbGenericxPL.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.gbGenericxPL.Controls.Add(Me.tcGeneric)
        Me.gbGenericxPL.Controls.Add(Me.Label3)
        Me.gbGenericxPL.Controls.Add(Me.tbInterval)
        Me.gbGenericxPL.Controls.Add(Me.GroupBox6)
        Me.gbGenericxPL.Location = New System.Drawing.Point(12, 12)
        Me.gbGenericxPL.Name = "gbGenericxPL"
        Me.gbGenericxPL.Size = New System.Drawing.Size(470, 126)
        Me.gbGenericxPL.TabIndex = 0
        Me.gbGenericxPL.TabStop = False
        Me.gbGenericxPL.Text = "Generic xPL device settings"
        '
        'tcGeneric
        '
        Me.tcGeneric.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tcGeneric.Controls.Add(Me.tpGroups)
        Me.tcGeneric.Controls.Add(Me.tpFilters)
        Me.tcGeneric.Location = New System.Drawing.Point(192, 10)
        Me.tcGeneric.MinimumSize = New System.Drawing.Size(234, 110)
        Me.tcGeneric.Name = "tcGeneric"
        Me.tcGeneric.SelectedIndex = 0
        Me.tcGeneric.Size = New System.Drawing.Size(272, 110)
        Me.tcGeneric.TabIndex = 3
        '
        'tpGroups
        '
        Me.tpGroups.Controls.Add(Me.btnRemoveGroup)
        Me.tpGroups.Controls.Add(Me.btnAddGroup)
        Me.tpGroups.Controls.Add(Me.tbGroup)
        Me.tpGroups.Controls.Add(Me.lblGroups)
        Me.tpGroups.Controls.Add(Me.lbGroups)
        Me.tpGroups.Location = New System.Drawing.Point(4, 22)
        Me.tpGroups.Name = "tpGroups"
        Me.tpGroups.Padding = New System.Windows.Forms.Padding(3)
        Me.tpGroups.Size = New System.Drawing.Size(264, 84)
        Me.tpGroups.TabIndex = 0
        Me.tpGroups.Text = "Groups"
        Me.tpGroups.UseVisualStyleBackColor = True
        '
        'btnRemoveGroup
        '
        Me.btnRemoveGroup.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnRemoveGroup.Location = New System.Drawing.Point(205, 61)
        Me.btnRemoveGroup.Name = "btnRemoveGroup"
        Me.btnRemoveGroup.Size = New System.Drawing.Size(59, 23)
        Me.btnRemoveGroup.TabIndex = 4
        Me.btnRemoveGroup.Text = "Remove"
        Me.btnRemoveGroup.UseVisualStyleBackColor = True
        '
        'btnAddGroup
        '
        Me.btnAddGroup.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnAddGroup.Location = New System.Drawing.Point(157, 61)
        Me.btnAddGroup.Name = "btnAddGroup"
        Me.btnAddGroup.Size = New System.Drawing.Size(43, 23)
        Me.btnAddGroup.TabIndex = 3
        Me.btnAddGroup.Text = "Add"
        Me.btnAddGroup.UseVisualStyleBackColor = True
        '
        'tbGroup
        '
        Me.tbGroup.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbGroup.Location = New System.Drawing.Point(62, 63)
        Me.tbGroup.MaxLength = 16
        Me.tbGroup.Name = "tbGroup"
        Me.tbGroup.Size = New System.Drawing.Size(89, 20)
        Me.tbGroup.TabIndex = 2
        '
        'lblGroups
        '
        Me.lblGroups.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.lblGroups.AutoSize = True
        Me.lblGroups.Location = New System.Drawing.Point(3, 66)
        Me.lblGroups.Name = "lblGroups"
        Me.lblGroups.Size = New System.Drawing.Size(53, 13)
        Me.lblGroups.TabIndex = 1
        Me.lblGroups.Text = "xpl-group."
        '
        'lbGroups
        '
        Me.lbGroups.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lbGroups.FormattingEnabled = True
        Me.lbGroups.IntegralHeight = False
        Me.lbGroups.Location = New System.Drawing.Point(0, 0)
        Me.lbGroups.Name = "lbGroups"
        Me.lbGroups.Size = New System.Drawing.Size(264, 58)
        Me.lbGroups.TabIndex = 0
        '
        'tpFilters
        '
        Me.tpFilters.Controls.Add(Me.btnRemoveFilter)
        Me.tpFilters.Controls.Add(Me.btnAddFilter)
        Me.tpFilters.Controls.Add(Me.tbFilter)
        Me.tpFilters.Controls.Add(Me.lbFilters)
        Me.tpFilters.Location = New System.Drawing.Point(4, 22)
        Me.tpFilters.Name = "tpFilters"
        Me.tpFilters.Padding = New System.Windows.Forms.Padding(3)
        Me.tpFilters.Size = New System.Drawing.Size(264, 84)
        Me.tpFilters.TabIndex = 1
        Me.tpFilters.Text = "Filters"
        Me.tpFilters.UseVisualStyleBackColor = True
        '
        'btnRemoveFilter
        '
        Me.btnRemoveFilter.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnRemoveFilter.Location = New System.Drawing.Point(205, 61)
        Me.btnRemoveFilter.Name = "btnRemoveFilter"
        Me.btnRemoveFilter.Size = New System.Drawing.Size(59, 23)
        Me.btnRemoveFilter.TabIndex = 3
        Me.btnRemoveFilter.Text = "Remove"
        Me.btnRemoveFilter.UseVisualStyleBackColor = True
        '
        'btnAddFilter
        '
        Me.btnAddFilter.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnAddFilter.Location = New System.Drawing.Point(157, 61)
        Me.btnAddFilter.Name = "btnAddFilter"
        Me.btnAddFilter.Size = New System.Drawing.Size(43, 23)
        Me.btnAddFilter.TabIndex = 2
        Me.btnAddFilter.Text = "Add"
        Me.btnAddFilter.UseVisualStyleBackColor = True
        '
        'tbFilter
        '
        Me.tbFilter.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbFilter.Location = New System.Drawing.Point(0, 63)
        Me.tbFilter.Name = "tbFilter"
        Me.tbFilter.Size = New System.Drawing.Size(151, 20)
        Me.tbFilter.TabIndex = 1
        '
        'lbFilters
        '
        Me.lbFilters.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lbFilters.FormattingEnabled = True
        Me.lbFilters.IntegralHeight = False
        Me.lbFilters.Location = New System.Drawing.Point(0, 0)
        Me.lbFilters.Name = "lbFilters"
        Me.lbFilters.Size = New System.Drawing.Size(264, 58)
        Me.lbFilters.TabIndex = 0
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(12, 68)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(91, 13)
        Me.Label3.TabIndex = 1
        Me.Label3.Text = "Heartbeat interval"
        '
        'tbInterval
        '
        Me.tbInterval.Location = New System.Drawing.Point(132, 66)
        Me.tbInterval.Maximum = New Decimal(New Integer() {9, 0, 0, 0})
        Me.tbInterval.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
        Me.tbInterval.Name = "tbInterval"
        Me.tbInterval.Size = New System.Drawing.Size(45, 20)
        Me.tbInterval.TabIndex = 2
        Me.tbInterval.Value = New Decimal(New Integer() {5, 0, 0, 0})
        '
        'GroupBox6
        '
        Me.GroupBox6.Controls.Add(Me.tbNewConf)
        Me.GroupBox6.Controls.Add(Me.lblAddress)
        Me.GroupBox6.Location = New System.Drawing.Point(6, 19)
        Me.GroupBox6.Name = "GroupBox6"
        Me.GroupBox6.Size = New System.Drawing.Size(180, 41)
        Me.GroupBox6.TabIndex = 0
        Me.GroupBox6.TabStop = False
        Me.GroupBox6.Text = "xPL Address"
        '
        'tbNewConf
        '
        Me.tbNewConf.Location = New System.Drawing.Point(71, 13)
        Me.tbNewConf.MaxLength = 16
        Me.tbNewConf.Name = "tbNewConf"
        Me.tbNewConf.Size = New System.Drawing.Size(100, 20)
        Me.tbNewConf.TabIndex = 1
        '
        'lblAddress
        '
        Me.lblAddress.AutoSize = True
        Me.lblAddress.Location = New System.Drawing.Point(6, 16)
        Me.lblAddress.Name = "lblAddress"
        Me.lblAddress.Size = New System.Drawing.Size(59, 13)
        Me.lblAddress.TabIndex = 0
        Me.lblAddress.Text = "tieske-sms."
        '
        'UnitInterface
        '
        Me.AcceptButton = Me.btnOK
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.CancelButton = Me.btnCancel
        Me.ClientSize = New System.Drawing.Size(496, 417)
        Me.Controls.Add(Me.gbGenericxPL)
        Me.Controls.Add(Me.btnCancel)
        Me.Controls.Add(Me.btnOK)
        Me.Controls.Add(Me.GroupBox4)
        Me.Controls.Add(Me.GroupBox3)
        Me.Controls.Add(Me.GroupBox2)
        Me.Controls.Add(Me.GroupBox1)
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.MinimumSize = New System.Drawing.Size(512, 455)
        Me.Name = "UnitInterface"
        Me.Text = "UnitInterface"
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox1.PerformLayout()
        Me.GroupBox2.ResumeLayout(False)
        Me.GroupBox2.PerformLayout()
        Me.GroupBox3.ResumeLayout(False)
        Me.GroupBox3.PerformLayout()
        Me.GroupBox4.ResumeLayout(False)
        Me.GroupBox4.PerformLayout()
        Me.gbGenericxPL.ResumeLayout(False)
        Me.gbGenericxPL.PerformLayout()
        Me.tcGeneric.ResumeLayout(False)
        Me.tpGroups.ResumeLayout(False)
        Me.tpGroups.PerformLayout()
        Me.tpFilters.ResumeLayout(False)
        Me.tpFilters.PerformLayout()
        CType(Me.tbInterval, System.ComponentModel.ISupportInitialize).EndInit()
        Me.GroupBox6.ResumeLayout(False)
        Me.GroupBox6.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents tbSMSurl As System.Windows.Forms.TextBox
    Friend WithEvents btnPhMessage As System.Windows.Forms.Button
    Friend WithEvents btnPhRecipient As System.Windows.Forms.Button
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents rbFailure As System.Windows.Forms.RadioButton
    Friend WithEvents rbSuccess As System.Windows.Forms.RadioButton
    Friend WithEvents tbSMSresponse As System.Windows.Forms.TextBox
    Friend WithEvents GroupBox3 As System.Windows.Forms.GroupBox
    Friend WithEvents tbCreditURL As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents tbDelimEnd As System.Windows.Forms.TextBox
    Friend WithEvents GroupBox4 As System.Windows.Forms.GroupBox
    Friend WithEvents tbDelimStart As System.Windows.Forms.TextBox
    Friend WithEvents btnOK As System.Windows.Forms.Button
    Friend WithEvents btnCancel As System.Windows.Forms.Button
    Friend WithEvents gbGenericxPL As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox6 As System.Windows.Forms.GroupBox
    Friend WithEvents lblAddress As System.Windows.Forms.Label
    Friend WithEvents tcGeneric As System.Windows.Forms.TabControl
    Friend WithEvents tpGroups As System.Windows.Forms.TabPage
    Friend WithEvents tpFilters As System.Windows.Forms.TabPage
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents tbInterval As System.Windows.Forms.NumericUpDown
    Friend WithEvents tbNewConf As System.Windows.Forms.TextBox
    Friend WithEvents tbGroup As System.Windows.Forms.TextBox
    Friend WithEvents lblGroups As System.Windows.Forms.Label
    Friend WithEvents lbGroups As System.Windows.Forms.ListBox
    Friend WithEvents btnAddGroup As System.Windows.Forms.Button
    Friend WithEvents btnRemoveGroup As System.Windows.Forms.Button
    Friend WithEvents btnRemoveFilter As System.Windows.Forms.Button
    Friend WithEvents btnAddFilter As System.Windows.Forms.Button
    Friend WithEvents tbFilter As System.Windows.Forms.TextBox
    Friend WithEvents lbFilters As System.Windows.Forms.ListBox
End Class
