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
        Me.tcMain = New System.Windows.Forms.TabControl
        Me.TabPage1 = New System.Windows.Forms.TabPage
        Me.dgInstalled = New System.Windows.Forms.DataGridView
        Me.insIcon = New System.Windows.Forms.DataGridViewImageColumn
        Me.insAddress = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.insDescription = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.insVersion = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.insLatest = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.insBeta = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.TabPage2 = New System.Windows.Forms.TabPage
        Me.dgAvailable = New System.Windows.Forms.DataGridView
        Me.avIcon = New System.Windows.Forms.DataGridViewImageColumn
        Me.avID = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.avDescription = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.avVersion = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.avPlatform = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.avType = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.avBeta = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.btnClose = New System.Windows.Forms.Button
        Me.btnCheckUpdates = New System.Windows.Forms.Button
        Me.lblxPLstatus = New System.Windows.Forms.Label
        Me.btnDetails = New System.Windows.Forms.Button
        Me.lblLastUpdate = New System.Windows.Forms.Label
        Me.tbSearch = New System.Windows.Forms.TextBox
        Me.lblSearch = New System.Windows.Forms.Label
        Me.btnClearSearch = New System.Windows.Forms.Button
        Me.btnAbout = New System.Windows.Forms.Button
        Me.btnClearFlags = New System.Windows.Forms.Button
        Me.btnHelp = New System.Windows.Forms.Button
        Me.tcMain.SuspendLayout()
        Me.TabPage1.SuspendLayout()
        CType(Me.dgInstalled, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.TabPage2.SuspendLayout()
        CType(Me.dgAvailable, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'tcMain
        '
        Me.tcMain.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tcMain.Controls.Add(Me.TabPage1)
        Me.tcMain.Controls.Add(Me.TabPage2)
        Me.tcMain.Location = New System.Drawing.Point(12, 12)
        Me.tcMain.Name = "tcMain"
        Me.tcMain.SelectedIndex = 0
        Me.tcMain.Size = New System.Drawing.Size(726, 241)
        Me.tcMain.TabIndex = 0
        '
        'TabPage1
        '
        Me.TabPage1.Controls.Add(Me.dgInstalled)
        Me.TabPage1.Location = New System.Drawing.Point(4, 22)
        Me.TabPage1.Name = "TabPage1"
        Me.TabPage1.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage1.Size = New System.Drawing.Size(718, 215)
        Me.TabPage1.TabIndex = 0
        Me.TabPage1.Text = "Installed applications"
        Me.TabPage1.UseVisualStyleBackColor = True
        '
        'dgInstalled
        '
        Me.dgInstalled.AllowUserToAddRows = False
        Me.dgInstalled.AllowUserToDeleteRows = False
        Me.dgInstalled.AllowUserToOrderColumns = True
        Me.dgInstalled.AllowUserToResizeRows = False
        Me.dgInstalled.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
                    Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.dgInstalled.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgInstalled.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.insIcon, Me.insAddress, Me.insDescription, Me.insVersion, Me.insLatest, Me.insBeta})
        Me.dgInstalled.Location = New System.Drawing.Point(0, 0)
        Me.dgInstalled.Name = "dgInstalled"
        Me.dgInstalled.ReadOnly = True
        Me.dgInstalled.RowHeadersVisible = False
        Me.dgInstalled.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgInstalled.Size = New System.Drawing.Size(718, 215)
        Me.dgInstalled.TabIndex = 0
        '
        'insIcon
        '
        Me.insIcon.HeaderText = ""
        Me.insIcon.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom
        Me.insIcon.Name = "insIcon"
        Me.insIcon.ReadOnly = True
        Me.insIcon.Resizable = System.Windows.Forms.DataGridViewTriState.[False]
        Me.insIcon.Width = 20
        '
        'insAddress
        '
        Me.insAddress.HeaderText = "Address"
        Me.insAddress.Name = "insAddress"
        Me.insAddress.ReadOnly = True
        Me.insAddress.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.insAddress.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.insAddress.Width = 150
        '
        'insDescription
        '
        Me.insDescription.HeaderText = "Description"
        Me.insDescription.Name = "insDescription"
        Me.insDescription.ReadOnly = True
        Me.insDescription.Width = 250
        '
        'insVersion
        '
        Me.insVersion.HeaderText = "Running"
        Me.insVersion.Name = "insVersion"
        Me.insVersion.ReadOnly = True
        Me.insVersion.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.insVersion.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.insVersion.Width = 70
        '
        'insLatest
        '
        Me.insLatest.HeaderText = "Latest"
        Me.insLatest.Name = "insLatest"
        Me.insLatest.ReadOnly = True
        Me.insLatest.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.insLatest.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable
        Me.insLatest.Width = 70
        '
        'insBeta
        '
        Me.insBeta.HeaderText = "Beta"
        Me.insBeta.Name = "insBeta"
        Me.insBeta.ReadOnly = True
        Me.insBeta.Width = 70
        '
        'TabPage2
        '
        Me.TabPage2.Controls.Add(Me.dgAvailable)
        Me.TabPage2.Location = New System.Drawing.Point(4, 22)
        Me.TabPage2.Name = "TabPage2"
        Me.TabPage2.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage2.Size = New System.Drawing.Size(718, 215)
        Me.TabPage2.TabIndex = 1
        Me.TabPage2.Text = "Available applications"
        Me.TabPage2.UseVisualStyleBackColor = True
        '
        'dgAvailable
        '
        Me.dgAvailable.AllowUserToAddRows = False
        Me.dgAvailable.AllowUserToDeleteRows = False
        Me.dgAvailable.AllowUserToOrderColumns = True
        Me.dgAvailable.AllowUserToResizeRows = False
        Me.dgAvailable.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.dgAvailable.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.avIcon, Me.avID, Me.avDescription, Me.avVersion, Me.avPlatform, Me.avType, Me.avBeta})
        Me.dgAvailable.Dock = System.Windows.Forms.DockStyle.Fill
        Me.dgAvailable.Location = New System.Drawing.Point(3, 3)
        Me.dgAvailable.MultiSelect = False
        Me.dgAvailable.Name = "dgAvailable"
        Me.dgAvailable.ReadOnly = True
        Me.dgAvailable.RowHeadersVisible = False
        Me.dgAvailable.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect
        Me.dgAvailable.Size = New System.Drawing.Size(712, 209)
        Me.dgAvailable.TabIndex = 0
        '
        'avIcon
        '
        Me.avIcon.HeaderText = ""
        Me.avIcon.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom
        Me.avIcon.Name = "avIcon"
        Me.avIcon.ReadOnly = True
        Me.avIcon.Resizable = System.Windows.Forms.DataGridViewTriState.[False]
        Me.avIcon.Width = 20
        '
        'avID
        '
        Me.avID.HeaderText = "Device"
        Me.avID.Name = "avID"
        Me.avID.ReadOnly = True
        '
        'avDescription
        '
        Me.avDescription.HeaderText = "Description"
        Me.avDescription.Name = "avDescription"
        Me.avDescription.ReadOnly = True
        Me.avDescription.Width = 250
        '
        'avVersion
        '
        Me.avVersion.HeaderText = "Version"
        Me.avVersion.Name = "avVersion"
        Me.avVersion.ReadOnly = True
        Me.avVersion.Width = 70
        '
        'avPlatform
        '
        Me.avPlatform.HeaderText = "Platform"
        Me.avPlatform.Name = "avPlatform"
        Me.avPlatform.ReadOnly = True
        Me.avPlatform.Width = 80
        '
        'avType
        '
        Me.avType.HeaderText = "Type"
        Me.avType.Name = "avType"
        Me.avType.ReadOnly = True
        Me.avType.Width = 70
        '
        'avBeta
        '
        Me.avBeta.HeaderText = "Beta"
        Me.avBeta.Name = "avBeta"
        Me.avBeta.ReadOnly = True
        '
        'btnClose
        '
        Me.btnClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClose.Location = New System.Drawing.Point(744, 258)
        Me.btnClose.Name = "btnClose"
        Me.btnClose.Size = New System.Drawing.Size(75, 23)
        Me.btnClose.TabIndex = 1
        Me.btnClose.Text = "Close"
        Me.btnClose.UseVisualStyleBackColor = True
        '
        'btnCheckUpdates
        '
        Me.btnCheckUpdates.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnCheckUpdates.Location = New System.Drawing.Point(744, 64)
        Me.btnCheckUpdates.Name = "btnCheckUpdates"
        Me.btnCheckUpdates.Size = New System.Drawing.Size(75, 23)
        Me.btnCheckUpdates.TabIndex = 2
        Me.btnCheckUpdates.Text = "Scan..."
        Me.btnCheckUpdates.UseVisualStyleBackColor = True
        '
        'lblxPLstatus
        '
        Me.lblxPLstatus.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.lblxPLstatus.AutoSize = True
        Me.lblxPLstatus.Location = New System.Drawing.Point(9, 263)
        Me.lblxPLstatus.Name = "lblxPLstatus"
        Me.lblxPLstatus.Size = New System.Drawing.Size(131, 13)
        Me.lblxPLstatus.TabIndex = 3
        Me.lblxPLstatus.Text = "xPL status: not connected"
        '
        'btnDetails
        '
        Me.btnDetails.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnDetails.Location = New System.Drawing.Point(744, 34)
        Me.btnDetails.Name = "btnDetails"
        Me.btnDetails.Size = New System.Drawing.Size(75, 23)
        Me.btnDetails.TabIndex = 4
        Me.btnDetails.Text = "Details..." & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10)
        Me.btnDetails.UseVisualStyleBackColor = True
        '
        'lblLastUpdate
        '
        Me.lblLastUpdate.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.lblLastUpdate.AutoSize = True
        Me.lblLastUpdate.Location = New System.Drawing.Point(176, 263)
        Me.lblLastUpdate.Name = "lblLastUpdate"
        Me.lblLastUpdate.Size = New System.Drawing.Size(66, 13)
        Me.lblLastUpdate.TabIndex = 5
        Me.lblLastUpdate.Text = "Last update:"
        '
        'tbSearch
        '
        Me.tbSearch.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tbSearch.Location = New System.Drawing.Point(586, 259)
        Me.tbSearch.Name = "tbSearch"
        Me.tbSearch.Size = New System.Drawing.Size(100, 20)
        Me.tbSearch.TabIndex = 6
        '
        'lblSearch
        '
        Me.lblSearch.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lblSearch.AutoSize = True
        Me.lblSearch.Location = New System.Drawing.Point(541, 262)
        Me.lblSearch.Name = "lblSearch"
        Me.lblSearch.Size = New System.Drawing.Size(41, 13)
        Me.lblSearch.TabIndex = 7
        Me.lblSearch.Text = "Search"
        '
        'btnClearSearch
        '
        Me.btnClearSearch.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClearSearch.Location = New System.Drawing.Point(688, 258)
        Me.btnClearSearch.Name = "btnClearSearch"
        Me.btnClearSearch.Size = New System.Drawing.Size(46, 23)
        Me.btnClearSearch.TabIndex = 8
        Me.btnClearSearch.Text = "Clear"
        Me.btnClearSearch.UseVisualStyleBackColor = True
        '
        'btnAbout
        '
        Me.btnAbout.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnAbout.Location = New System.Drawing.Point(744, 151)
        Me.btnAbout.Name = "btnAbout"
        Me.btnAbout.Size = New System.Drawing.Size(75, 23)
        Me.btnAbout.TabIndex = 9
        Me.btnAbout.Text = "About..."
        Me.btnAbout.UseVisualStyleBackColor = True
        '
        'btnClearFlags
        '
        Me.btnClearFlags.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnClearFlags.Enabled = False
        Me.btnClearFlags.Location = New System.Drawing.Point(744, 93)
        Me.btnClearFlags.Name = "btnClearFlags"
        Me.btnClearFlags.Size = New System.Drawing.Size(75, 23)
        Me.btnClearFlags.TabIndex = 10
        Me.btnClearFlags.Text = "Clear status"
        Me.btnClearFlags.UseVisualStyleBackColor = True
        '
        'btnHelp
        '
        Me.btnHelp.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.btnHelp.Location = New System.Drawing.Point(744, 122)
        Me.btnHelp.Name = "btnHelp"
        Me.btnHelp.Size = New System.Drawing.Size(75, 23)
        Me.btnHelp.TabIndex = 11
        Me.btnHelp.Text = "Help..."
        Me.btnHelp.UseVisualStyleBackColor = True
        '
        'MainForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(831, 285)
        Me.Controls.Add(Me.btnHelp)
        Me.Controls.Add(Me.btnClearFlags)
        Me.Controls.Add(Me.btnAbout)
        Me.Controls.Add(Me.btnClearSearch)
        Me.Controls.Add(Me.lblSearch)
        Me.Controls.Add(Me.tbSearch)
        Me.Controls.Add(Me.lblLastUpdate)
        Me.Controls.Add(Me.btnDetails)
        Me.Controls.Add(Me.lblxPLstatus)
        Me.Controls.Add(Me.btnCheckUpdates)
        Me.Controls.Add(Me.btnClose)
        Me.Controls.Add(Me.tcMain)
        Me.MinimumSize = New System.Drawing.Size(745, 323)
        Me.Name = "MainForm"
        Me.Text = "xPL Updater"
        Me.tcMain.ResumeLayout(False)
        Me.TabPage1.ResumeLayout(False)
        CType(Me.dgInstalled, System.ComponentModel.ISupportInitialize).EndInit()
        Me.TabPage2.ResumeLayout(False)
        CType(Me.dgAvailable, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents tcMain As System.Windows.Forms.TabControl
    Friend WithEvents TabPage1 As System.Windows.Forms.TabPage
    Friend WithEvents TabPage2 As System.Windows.Forms.TabPage
    Friend WithEvents btnClose As System.Windows.Forms.Button
    Friend WithEvents btnCheckUpdates As System.Windows.Forms.Button
    Friend WithEvents dgInstalled As System.Windows.Forms.DataGridView
    Friend WithEvents dgAvailable As System.Windows.Forms.DataGridView
    Friend WithEvents lblxPLstatus As System.Windows.Forms.Label
    Friend WithEvents btnDetails As System.Windows.Forms.Button
    Friend WithEvents lblLastUpdate As System.Windows.Forms.Label
    Friend WithEvents avIcon As System.Windows.Forms.DataGridViewImageColumn
    Friend WithEvents avID As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents avDescription As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents avVersion As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents avPlatform As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents avType As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents avBeta As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents tbSearch As System.Windows.Forms.TextBox
    Friend WithEvents lblSearch As System.Windows.Forms.Label
    Friend WithEvents btnClearSearch As System.Windows.Forms.Button
    Friend WithEvents btnAbout As System.Windows.Forms.Button
    Friend WithEvents btnClearFlags As System.Windows.Forms.Button
    Friend WithEvents insIcon As System.Windows.Forms.DataGridViewImageColumn
    Friend WithEvents insAddress As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents insDescription As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents insVersion As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents insLatest As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents insBeta As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents btnHelp As System.Windows.Forms.Button

End Class
