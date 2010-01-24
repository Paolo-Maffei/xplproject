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
        Me.btnClose = New System.Windows.Forms.Button
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.btnCheckPort = New System.Windows.Forms.Button
        Me.btnOpenPort = New System.Windows.Forms.Button
        Me.Label3 = New System.Windows.Forms.Label
        Me.Label5 = New System.Windows.Forms.Label
        Me.ProgressBar1 = New System.Windows.Forms.ProgressBar
        Me.lblPortOpen = New System.Windows.Forms.Label
        Me.btnClosePort = New System.Windows.Forms.Button
        Me.btnCheckHub = New System.Windows.Forms.Button
        Me.btnInstallHub = New System.Windows.Forms.Button
        Me.Label7 = New System.Windows.Forms.Label
        Me.Label8 = New System.Windows.Forms.Label
        Me.Label9 = New System.Windows.Forms.Label
        Me.lblHubFound = New System.Windows.Forms.Label
        Me.Label11 = New System.Windows.Forms.Label
        Me.btnInstallDiag = New System.Windows.Forms.Button
        Me.Label12 = New System.Windows.Forms.Label
        Me.Label13 = New System.Windows.Forms.Label
        Me.Label14 = New System.Windows.Forms.Label
        Me.lblPortClosed = New System.Windows.Forms.Label
        Me.lblHubNotFound = New System.Windows.Forms.Label
        Me.lblHubConnecting = New System.Windows.Forms.Label
        Me.xPLLogo = New System.Windows.Forms.PictureBox
        Me.Button1 = New System.Windows.Forms.Button
        CType(Me.xPLLogo, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'btnClose
        '
        Me.btnClose.Location = New System.Drawing.Point(372, 287)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 2
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(110, 9)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(116, 20)
        Me.Label1.TabIndex = 4
        Me.Label1.Text = "Firewall ports"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(111, 34)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(224, 13)
        Me.Label2.TabIndex = 5
        Me.Label2.Text = "The xPL port (UDP on 3865) must be open to "
        '
        'btnCheckPort
        '
        Me.btnCheckPort.Location = New System.Drawing.Point(372, 12)
        Me.btnCheckPort.Name = "btnCheckPort"
        Me.btnCheckPort.Size = New System.Drawing.Size(75, 23)
        Me.btnCheckPort.TabIndex = 6
        Me.btnCheckPort.Text = "Check port"
        Me.btnCheckPort.UseVisualStyleBackColor = True
        '
        'btnOpenPort
        '
        Me.btnOpenPort.Location = New System.Drawing.Point(372, 41)
        Me.btnOpenPort.Name = "btnOpenPort"
        Me.btnOpenPort.Size = New System.Drawing.Size(75, 23)
        Me.btnOpenPort.TabIndex = 7
        Me.btnOpenPort.Text = "Open port"
        Me.btnOpenPort.UseVisualStyleBackColor = True
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(111, 48)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(220, 13)
        Me.Label3.TabIndex = 8
        Me.Label3.Text = "connect to other xPL devices on the network"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label5.Location = New System.Drawing.Point(110, 106)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(103, 20)
        Me.Label5.TabIndex = 10
        Me.Label5.Text = "Hub service"
        '
        'ProgressBar1
        '
        Me.ProgressBar1.Location = New System.Drawing.Point(114, 168)
        Me.ProgressBar1.Maximum = 120
        Me.ProgressBar1.Name = "ProgressBar1"
        Me.ProgressBar1.Size = New System.Drawing.Size(252, 23)
        Me.ProgressBar1.Step = 1
        Me.ProgressBar1.TabIndex = 11
        '
        'lblPortOpen
        '
        Me.lblPortOpen.AutoSize = True
        Me.lblPortOpen.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblPortOpen.ForeColor = System.Drawing.Color.LimeGreen
        Me.lblPortOpen.Location = New System.Drawing.Point(329, 17)
        Me.lblPortOpen.Name = "lblPortOpen"
        Me.lblPortOpen.Size = New System.Drawing.Size(37, 13)
        Me.lblPortOpen.TabIndex = 12
        Me.lblPortOpen.Text = "Open"
        Me.lblPortOpen.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'btnClosePort
        '
        Me.btnClosePort.Location = New System.Drawing.Point(372, 70)
        Me.btnClosePort.Name = "btnClosePort"
        Me.btnClosePort.Size = New System.Drawing.Size(75, 23)
        Me.btnClosePort.TabIndex = 13
        Me.btnClosePort.Text = "Close port"
        Me.btnClosePort.UseVisualStyleBackColor = True
        '
        'btnCheckHub
        '
        Me.btnCheckHub.Location = New System.Drawing.Point(372, 139)
        Me.btnCheckHub.Name = "btnCheckHub"
        Me.btnCheckHub.Size = New System.Drawing.Size(75, 23)
        Me.btnCheckHub.TabIndex = 14
        Me.btnCheckHub.Text = "Check Hub"
        Me.btnCheckHub.UseVisualStyleBackColor = True
        '
        'btnInstallHub
        '
        Me.btnInstallHub.Location = New System.Drawing.Point(372, 168)
        Me.btnInstallHub.Name = "btnInstallHub"
        Me.btnInstallHub.Size = New System.Drawing.Size(75, 23)
        Me.btnInstallHub.TabIndex = 15
        Me.btnInstallHub.Text = "Install Hub"
        Me.btnInstallHub.UseVisualStyleBackColor = True
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.Location = New System.Drawing.Point(111, 126)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(236, 13)
        Me.Label7.TabIndex = 16
        Me.Label7.Text = "Every PC must run a xPL hub. The Hub receives"
        '
        'Label8
        '
        Me.Label8.AutoSize = True
        Me.Label8.Location = New System.Drawing.Point(111, 139)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(234, 13)
        Me.Label8.TabIndex = 17
        Me.Label8.Text = "messages from the network and delivers them to"
        '
        'Label9
        '
        Me.Label9.AutoSize = True
        Me.Label9.Location = New System.Drawing.Point(111, 152)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(109, 13)
        Me.Label9.TabIndex = 18
        Me.Label9.Text = "local xPL applications"
        '
        'lblHubFound
        '
        Me.lblHubFound.AutoSize = True
        Me.lblHubFound.BackColor = System.Drawing.Color.Transparent
        Me.lblHubFound.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblHubFound.ForeColor = System.Drawing.Color.LimeGreen
        Me.lblHubFound.Location = New System.Drawing.Point(300, 113)
        Me.lblHubFound.Name = "lblHubFound"
        Me.lblHubFound.Size = New System.Drawing.Size(66, 13)
        Me.lblHubFound.TabIndex = 19
        Me.lblHubFound.Text = "Hub found"
        Me.lblHubFound.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'Label11
        '
        Me.Label11.AutoSize = True
        Me.Label11.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label11.Location = New System.Drawing.Point(110, 208)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(143, 20)
        Me.Label11.TabIndex = 20
        Me.Label11.Text = "Trouble shooting"
        '
        'btnInstallDiag
        '
        Me.btnInstallDiag.Location = New System.Drawing.Point(372, 227)
        Me.btnInstallDiag.Name = "btnInstallDiag"
        Me.btnInstallDiag.Size = New System.Drawing.Size(75, 23)
        Me.btnInstallDiag.TabIndex = 21
        Me.btnInstallDiag.Text = "Install Diags"
        Me.btnInstallDiag.UseVisualStyleBackColor = True
        '
        'Label12
        '
        Me.Label12.AutoSize = True
        Me.Label12.Location = New System.Drawing.Point(111, 254)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(210, 13)
        Me.Label12.TabIndex = 24
        Me.Label12.Text = "to install xPL diagnostics for further analysis"
        '
        'Label13
        '
        Me.Label13.AutoSize = True
        Me.Label13.Location = New System.Drawing.Point(111, 241)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(252, 13)
        Me.Label13.TabIndex = 23
        Me.Label13.Text = "but the hub still cannot be found, then you may wish"
        '
        'Label14
        '
        Me.Label14.AutoSize = True
        Me.Label14.Location = New System.Drawing.Point(111, 228)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(235, 13)
        Me.Label14.TabIndex = 22
        Me.Label14.Text = "If the firewall port is open and the hub is installed"
        '
        'lblPortClosed
        '
        Me.lblPortClosed.AutoSize = True
        Me.lblPortClosed.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblPortClosed.ForeColor = System.Drawing.Color.Red
        Me.lblPortClosed.Location = New System.Drawing.Point(321, 17)
        Me.lblPortClosed.Name = "lblPortClosed"
        Me.lblPortClosed.Size = New System.Drawing.Size(45, 13)
        Me.lblPortClosed.TabIndex = 25
        Me.lblPortClosed.Text = "Closed"
        Me.lblPortClosed.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'lblHubNotFound
        '
        Me.lblHubNotFound.AutoSize = True
        Me.lblHubNotFound.BackColor = System.Drawing.Color.Transparent
        Me.lblHubNotFound.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblHubNotFound.ForeColor = System.Drawing.Color.Red
        Me.lblHubNotFound.Location = New System.Drawing.Point(278, 113)
        Me.lblHubNotFound.Name = "lblHubNotFound"
        Me.lblHubNotFound.Size = New System.Drawing.Size(88, 13)
        Me.lblHubNotFound.TabIndex = 26
        Me.lblHubNotFound.Text = "Hub not found"
        Me.lblHubNotFound.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'lblHubConnecting
        '
        Me.lblHubConnecting.AutoSize = True
        Me.lblHubConnecting.BackColor = System.Drawing.Color.Transparent
        Me.lblHubConnecting.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblHubConnecting.ForeColor = System.Drawing.Color.Orange
        Me.lblHubConnecting.Location = New System.Drawing.Point(283, 113)
        Me.lblHubConnecting.Name = "lblHubConnecting"
        Me.lblHubConnecting.Size = New System.Drawing.Size(83, 13)
        Me.lblHubConnecting.TabIndex = 27
        Me.lblHubConnecting.Text = "Connecting..."
        Me.lblHubConnecting.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'xPLLogo
        '
        Me.xPLLogo.BackgroundImage = Global.xPL_Hub_Verifier.My.Resources.Resources.Xpllogoian___Copy
        Me.xPLLogo.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.xPLLogo.InitialImage = Nothing
        Me.xPLLogo.Location = New System.Drawing.Point(4, 5)
        Me.xPLLogo.Name = "xPLLogo"
        Me.xPLLogo.Size = New System.Drawing.Size(100, 90)
        Me.xPLLogo.TabIndex = 1
        Me.xPLLogo.TabStop = False
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(12, 287)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 28
        Me.Button1.Text = "About..."
        Me.Button1.UseVisualStyleBackColor = True
        '
        'MainForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None
        Me.ClientSize = New System.Drawing.Size(459, 322)
        Me.ControlBox = False
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.lblHubConnecting)
        Me.Controls.Add(Me.lblHubNotFound)
        Me.Controls.Add(Me.lblPortClosed)
        Me.Controls.Add(Me.Label12)
        Me.Controls.Add(Me.Label13)
        Me.Controls.Add(Me.Label14)
        Me.Controls.Add(Me.btnInstallDiag)
        Me.Controls.Add(Me.Label11)
        Me.Controls.Add(Me.lblHubFound)
        Me.Controls.Add(Me.Label9)
        Me.Controls.Add(Me.Label8)
        Me.Controls.Add(Me.Label7)
        Me.Controls.Add(Me.btnInstallHub)
        Me.Controls.Add(Me.btnCheckHub)
        Me.Controls.Add(Me.btnClosePort)
        Me.Controls.Add(Me.lblPortOpen)
        Me.Controls.Add(Me.ProgressBar1)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.btnOpenPort)
        Me.Controls.Add(Me.btnCheckPort)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.xPLLogo)
        Me.Name = "MainForm"
        Me.Text = "xPL connectivity check"
        CType(Me.xPLLogo, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents xPLLogo As System.Windows.Forms.PictureBox
    Friend WithEvents btnClose As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents btnCheckPort As System.Windows.Forms.Button
    Friend WithEvents btnOpenPort As System.Windows.Forms.Button
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents ProgressBar1 As System.Windows.Forms.ProgressBar
    Friend WithEvents lblPortOpen As System.Windows.Forms.Label
    Friend WithEvents btnClosePort As System.Windows.Forms.Button
    Friend WithEvents btnCheckHub As System.Windows.Forms.Button
    Friend WithEvents btnInstallHub As System.Windows.Forms.Button
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents lblHubFound As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents btnInstallDiag As System.Windows.Forms.Button
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents lblPortClosed As System.Windows.Forms.Label
    Friend WithEvents lblHubNotFound As System.Windows.Forms.Label
    Friend WithEvents lblHubConnecting As System.Windows.Forms.Label
    Friend WithEvents Button1 As System.Windows.Forms.Button

End Class
