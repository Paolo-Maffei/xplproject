<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DeviceDetails
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
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
        Me.tbVendor = New System.Windows.Forms.TextBox
        Me.lblVendor = New System.Windows.Forms.Label
        Me.lblDevice = New System.Windows.Forms.Label
        Me.tbDevice = New System.Windows.Forms.TextBox
        Me.lblVersionStable = New System.Windows.Forms.Label
        Me.lblVersionBeta = New System.Windows.Forms.Label
        Me.tbVersionStable = New System.Windows.Forms.TextBox
        Me.tbVersionBeta = New System.Windows.Forms.TextBox
        Me.tbDescription = New System.Windows.Forms.TextBox
        Me.lblDescription = New System.Windows.Forms.Label
        Me.btnClose = New System.Windows.Forms.Button
        Me.lblType = New System.Windows.Forms.Label
        Me.tbType = New System.Windows.Forms.TextBox
        Me.lblPlatform = New System.Windows.Forms.Label
        Me.tbPlatform = New System.Windows.Forms.TextBox
        Me.lblDeviceInfo = New System.Windows.Forms.Label
        Me.lblDownload = New System.Windows.Forms.Label
        Me.lblVendorInfo = New System.Windows.Forms.Label
        Me.llblDownload = New System.Windows.Forms.LinkLabel
        Me.llblVendorInfo = New System.Windows.Forms.LinkLabel
        Me.llblDeviceInfo = New System.Windows.Forms.LinkLabel
        Me.SuspendLayout()
        '
        'tbVendor
        '
        Me.tbVendor.Location = New System.Drawing.Point(86, 12)
        Me.tbVendor.Name = "tbVendor"
        Me.tbVendor.ReadOnly = True
        Me.tbVendor.Size = New System.Drawing.Size(100, 20)
        Me.tbVendor.TabIndex = 0
        '
        'lblVendor
        '
        Me.lblVendor.AutoSize = True
        Me.lblVendor.Location = New System.Drawing.Point(12, 15)
        Me.lblVendor.Name = "lblVendor"
        Me.lblVendor.Size = New System.Drawing.Size(41, 13)
        Me.lblVendor.TabIndex = 1
        Me.lblVendor.Text = "Vendor"
        '
        'lblDevice
        '
        Me.lblDevice.AutoSize = True
        Me.lblDevice.Location = New System.Drawing.Point(12, 41)
        Me.lblDevice.Name = "lblDevice"
        Me.lblDevice.Size = New System.Drawing.Size(41, 13)
        Me.lblDevice.TabIndex = 2
        Me.lblDevice.Text = "Device"
        '
        'tbDevice
        '
        Me.tbDevice.Location = New System.Drawing.Point(86, 38)
        Me.tbDevice.Name = "tbDevice"
        Me.tbDevice.ReadOnly = True
        Me.tbDevice.Size = New System.Drawing.Size(100, 20)
        Me.tbDevice.TabIndex = 3
        '
        'lblVersionStable
        '
        Me.lblVersionStable.AutoSize = True
        Me.lblVersionStable.Location = New System.Drawing.Point(201, 41)
        Me.lblVersionStable.Name = "lblVersionStable"
        Me.lblVersionStable.Size = New System.Drawing.Size(74, 13)
        Me.lblVersionStable.TabIndex = 4
        Me.lblVersionStable.Text = "Stable version"
        '
        'lblVersionBeta
        '
        Me.lblVersionBeta.AutoSize = True
        Me.lblVersionBeta.Location = New System.Drawing.Point(201, 67)
        Me.lblVersionBeta.Name = "lblVersionBeta"
        Me.lblVersionBeta.Size = New System.Drawing.Size(66, 13)
        Me.lblVersionBeta.TabIndex = 5
        Me.lblVersionBeta.Text = "Beta version"
        '
        'tbVersionStable
        '
        Me.tbVersionStable.Location = New System.Drawing.Point(281, 38)
        Me.tbVersionStable.Name = "tbVersionStable"
        Me.tbVersionStable.ReadOnly = True
        Me.tbVersionStable.Size = New System.Drawing.Size(100, 20)
        Me.tbVersionStable.TabIndex = 6
        '
        'tbVersionBeta
        '
        Me.tbVersionBeta.Location = New System.Drawing.Point(281, 64)
        Me.tbVersionBeta.Name = "tbVersionBeta"
        Me.tbVersionBeta.ReadOnly = True
        Me.tbVersionBeta.Size = New System.Drawing.Size(100, 20)
        Me.tbVersionBeta.TabIndex = 7
        '
        'tbDescription
        '
        Me.tbDescription.Location = New System.Drawing.Point(86, 90)
        Me.tbDescription.Multiline = True
        Me.tbDescription.Name = "tbDescription"
        Me.tbDescription.ReadOnly = True
        Me.tbDescription.Size = New System.Drawing.Size(295, 77)
        Me.tbDescription.TabIndex = 8
        '
        'lblDescription
        '
        Me.lblDescription.AutoSize = True
        Me.lblDescription.Location = New System.Drawing.Point(12, 93)
        Me.lblDescription.Name = "lblDescription"
        Me.lblDescription.Size = New System.Drawing.Size(60, 13)
        Me.lblDescription.TabIndex = 9
        Me.lblDescription.Text = "Description"
        '
        'btnClose
        '
        Me.btnClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClose.Location = New System.Drawing.Point(306, 257)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 10
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'lblType
        '
        Me.lblType.AutoSize = True
        Me.lblType.Location = New System.Drawing.Point(12, 67)
        Me.lblType.Name = "lblType"
        Me.lblType.Size = New System.Drawing.Size(31, 13)
        Me.lblType.TabIndex = 11
        Me.lblType.Text = "Type"
        '
        'tbType
        '
        Me.tbType.Location = New System.Drawing.Point(86, 64)
        Me.tbType.Name = "tbType"
        Me.tbType.ReadOnly = True
        Me.tbType.Size = New System.Drawing.Size(100, 20)
        Me.tbType.TabIndex = 12
        '
        'lblPlatform
        '
        Me.lblPlatform.AutoSize = True
        Me.lblPlatform.Location = New System.Drawing.Point(201, 15)
        Me.lblPlatform.Name = "lblPlatform"
        Me.lblPlatform.Size = New System.Drawing.Size(45, 13)
        Me.lblPlatform.TabIndex = 13
        Me.lblPlatform.Text = "Platform"
        '
        'tbPlatform
        '
        Me.tbPlatform.Location = New System.Drawing.Point(280, 12)
        Me.tbPlatform.Name = "tbPlatform"
        Me.tbPlatform.ReadOnly = True
        Me.tbPlatform.Size = New System.Drawing.Size(100, 20)
        Me.tbPlatform.TabIndex = 14
        '
        'lblDeviceInfo
        '
        Me.lblDeviceInfo.AutoSize = True
        Me.lblDeviceInfo.Location = New System.Drawing.Point(12, 202)
        Me.lblDeviceInfo.Name = "lblDeviceInfo"
        Me.lblDeviceInfo.Size = New System.Drawing.Size(61, 13)
        Me.lblDeviceInfo.TabIndex = 15
        Me.lblDeviceInfo.Text = "Device info"
        '
        'lblDownload
        '
        Me.lblDownload.AutoSize = True
        Me.lblDownload.Location = New System.Drawing.Point(12, 228)
        Me.lblDownload.Name = "lblDownload"
        Me.lblDownload.Size = New System.Drawing.Size(55, 13)
        Me.lblDownload.TabIndex = 16
        Me.lblDownload.Text = "Download"
        '
        'lblVendorInfo
        '
        Me.lblVendorInfo.AutoSize = True
        Me.lblVendorInfo.Location = New System.Drawing.Point(12, 176)
        Me.lblVendorInfo.Name = "lblVendorInfo"
        Me.lblVendorInfo.Size = New System.Drawing.Size(61, 13)
        Me.lblVendorInfo.TabIndex = 19
        Me.lblVendorInfo.Text = "Vendor info"
        '
        'llblDownload
        '
        Me.llblDownload.AutoSize = True
        Me.llblDownload.Location = New System.Drawing.Point(83, 228)
        Me.llblDownload.MaximumSize = New System.Drawing.Size(295, 0)
        Me.llblDownload.MinimumSize = New System.Drawing.Size(295, 0)
        Me.llblDownload.Name = "llblDownload"
        Me.llblDownload.Size = New System.Drawing.Size(295, 13)
        Me.llblDownload.TabIndex = 21
        Me.llblDownload.TabStop = True
        Me.llblDownload.Text = "Unavailable"
        '
        'llblVendorInfo
        '
        Me.llblVendorInfo.AutoSize = True
        Me.llblVendorInfo.Location = New System.Drawing.Point(83, 176)
        Me.llblVendorInfo.MaximumSize = New System.Drawing.Size(295, 0)
        Me.llblVendorInfo.MinimumSize = New System.Drawing.Size(295, 0)
        Me.llblVendorInfo.Name = "llblVendorInfo"
        Me.llblVendorInfo.Size = New System.Drawing.Size(295, 13)
        Me.llblVendorInfo.TabIndex = 22
        Me.llblVendorInfo.TabStop = True
        Me.llblVendorInfo.Text = "Unavailable"
        '
        'llblDeviceInfo
        '
        Me.llblDeviceInfo.AutoSize = True
        Me.llblDeviceInfo.Location = New System.Drawing.Point(83, 202)
        Me.llblDeviceInfo.MaximumSize = New System.Drawing.Size(295, 0)
        Me.llblDeviceInfo.MinimumSize = New System.Drawing.Size(295, 0)
        Me.llblDeviceInfo.Name = "llblDeviceInfo"
        Me.llblDeviceInfo.Size = New System.Drawing.Size(295, 13)
        Me.llblDeviceInfo.TabIndex = 23
        Me.llblDeviceInfo.TabStop = True
        Me.llblDeviceInfo.Text = "Unavailable"
        '
        'DeviceDetails
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(392, 292)
        Me.Controls.Add(Me.llblDeviceInfo)
        Me.Controls.Add(Me.llblVendorInfo)
        Me.Controls.Add(Me.llblDownload)
        Me.Controls.Add(Me.lblVendorInfo)
        Me.Controls.Add(Me.lblDownload)
        Me.Controls.Add(Me.lblDeviceInfo)
        Me.Controls.Add(Me.tbPlatform)
        Me.Controls.Add(Me.lblPlatform)
        Me.Controls.Add(Me.tbType)
        Me.Controls.Add(Me.lblType)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.lblDescription)
        Me.Controls.Add(Me.tbDescription)
        Me.Controls.Add(Me.tbVersionBeta)
        Me.Controls.Add(Me.tbVersionStable)
        Me.Controls.Add(Me.lblVersionBeta)
        Me.Controls.Add(Me.lblVersionStable)
        Me.Controls.Add(Me.tbDevice)
        Me.Controls.Add(Me.lblDevice)
        Me.Controls.Add(Me.lblVendor)
        Me.Controls.Add(Me.tbVendor)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.Name = "DeviceDetails"
        Me.Text = "Device details"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents tbVendor As System.Windows.Forms.TextBox
    Friend WithEvents lblVendor As System.Windows.Forms.Label
    Friend WithEvents lblDevice As System.Windows.Forms.Label
    Friend WithEvents tbDevice As System.Windows.Forms.TextBox
    Friend WithEvents lblVersionStable As System.Windows.Forms.Label
    Friend WithEvents lblVersionBeta As System.Windows.Forms.Label
    Friend WithEvents tbVersionStable As System.Windows.Forms.TextBox
    Friend WithEvents tbVersionBeta As System.Windows.Forms.TextBox
    Friend WithEvents tbDescription As System.Windows.Forms.TextBox
    Friend WithEvents lblDescription As System.Windows.Forms.Label
    Friend WithEvents btnClose As System.Windows.Forms.Button
    Friend WithEvents lblType As System.Windows.Forms.Label
    Friend WithEvents tbType As System.Windows.Forms.TextBox
    Friend WithEvents lblPlatform As System.Windows.Forms.Label
    Friend WithEvents tbPlatform As System.Windows.Forms.TextBox
    Friend WithEvents lblDeviceInfo As System.Windows.Forms.Label
    Friend WithEvents lblDownload As System.Windows.Forms.Label
    Friend WithEvents lblVendorInfo As System.Windows.Forms.Label
    Friend WithEvents llblDownload As System.Windows.Forms.LinkLabel
    Friend WithEvents llblVendorInfo As System.Windows.Forms.LinkLabel
    Friend WithEvents llblDeviceInfo As System.Windows.Forms.LinkLabel
End Class
