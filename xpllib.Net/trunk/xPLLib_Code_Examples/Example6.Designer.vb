<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Example6
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
        Me.tbDemoText = New System.Windows.Forms.TextBox
        Me.chkValidXPLValue = New System.Windows.Forms.CheckBox
        Me.chkValidxPLVendor = New System.Windows.Forms.CheckBox
        Me.chkValidxPLOther = New System.Windows.Forms.CheckBox
        Me.lblValue = New System.Windows.Forms.Label
        Me.lblOther = New System.Windows.Forms.Label
        Me.lblVendor = New System.Windows.Forms.Label
        Me.LabelIsItValidXPL = New System.Windows.Forms.Label
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.lblState = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'tbDemoText
        '
        Me.tbDemoText.Location = New System.Drawing.Point(37, 12)
        Me.tbDemoText.Name = "tbDemoText"
        Me.tbDemoText.Size = New System.Drawing.Size(476, 20)
        Me.tbDemoText.TabIndex = 0
        Me.tbDemoText.Text = "enter some text to see whether its valid xPL"
        '
        'chkValidXPLValue
        '
        Me.chkValidXPLValue.AutoSize = True
        Me.chkValidXPLValue.Enabled = False
        Me.chkValidXPLValue.Location = New System.Drawing.Point(37, 55)
        Me.chkValidXPLValue.Name = "chkValidXPLValue"
        Me.chkValidXPLValue.Size = New System.Drawing.Size(99, 17)
        Me.chkValidXPLValue.TabIndex = 1
        Me.chkValidXPLValue.Text = "Valid xPL value"
        Me.chkValidXPLValue.UseVisualStyleBackColor = True
        '
        'chkValidxPLVendor
        '
        Me.chkValidxPLVendor.AutoSize = True
        Me.chkValidxPLVendor.Enabled = False
        Me.chkValidxPLVendor.Location = New System.Drawing.Point(37, 78)
        Me.chkValidxPLVendor.Name = "chkValidxPLVendor"
        Me.chkValidxPLVendor.Size = New System.Drawing.Size(178, 17)
        Me.chkValidxPLVendor.TabIndex = 2
        Me.chkValidxPLVendor.Text = "Valid xPL VendorID or DeviceID"
        Me.chkValidxPLVendor.UseVisualStyleBackColor = True
        '
        'chkValidxPLOther
        '
        Me.chkValidxPLOther.AutoSize = True
        Me.chkValidxPLOther.Enabled = False
        Me.chkValidxPLOther.Location = New System.Drawing.Point(37, 101)
        Me.chkValidxPLOther.Name = "chkValidxPLOther"
        Me.chkValidxPLOther.Size = New System.Drawing.Size(137, 17)
        Me.chkValidxPLOther.TabIndex = 3
        Me.chkValidxPLOther.Text = "Valid other xPL element"
        Me.chkValidxPLOther.UseVisualStyleBackColor = True
        '
        'lblValue
        '
        Me.lblValue.AutoSize = True
        Me.lblValue.Location = New System.Drawing.Point(246, 56)
        Me.lblValue.Name = "lblValue"
        Me.lblValue.Size = New System.Drawing.Size(33, 13)
        Me.lblValue.TabIndex = 4
        Me.lblValue.Text = "value"
        '
        'lblOther
        '
        Me.lblOther.AutoSize = True
        Me.lblOther.Location = New System.Drawing.Point(246, 102)
        Me.lblOther.Name = "lblOther"
        Me.lblOther.Size = New System.Drawing.Size(33, 13)
        Me.lblOther.TabIndex = 5
        Me.lblOther.Text = "value"
        '
        'lblVendor
        '
        Me.lblVendor.AutoSize = True
        Me.lblVendor.Location = New System.Drawing.Point(246, 79)
        Me.lblVendor.Name = "lblVendor"
        Me.lblVendor.Size = New System.Drawing.Size(33, 13)
        Me.lblVendor.TabIndex = 6
        Me.lblVendor.Text = "value"
        '
        'LabelIsItValidXPL
        '
        Me.LabelIsItValidXPL.AutoSize = True
        Me.LabelIsItValidXPL.ForeColor = System.Drawing.SystemColors.ActiveCaption
        Me.LabelIsItValidXPL.Location = New System.Drawing.Point(34, 35)
        Me.LabelIsItValidXPL.Name = "LabelIsItValidXPL"
        Me.LabelIsItValidXPL.Size = New System.Drawing.Size(75, 13)
        Me.LabelIsItValidXPL.TabIndex = 7
        Me.LabelIsItValidXPL.Text = "Is it valid xPL?"
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.ForeColor = System.Drawing.SystemColors.ActiveCaption
        Me.Label1.Location = New System.Drawing.Point(246, 35)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(116, 13)
        Me.Label1.TabIndex = 8
        Me.Label1.Text = "What if we clean it up?"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.ForeColor = System.Drawing.SystemColors.ActiveCaption
        Me.Label2.Location = New System.Drawing.Point(34, 136)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(377, 13)
        Me.Label2.TabIndex = 9
        Me.Label2.Text = "States are merely comma-separated strings containing Base64 encoded strings"
        '
        'lblState
        '
        Me.lblState.AutoSize = True
        Me.lblState.Location = New System.Drawing.Point(34, 149)
        Me.lblState.Name = "lblState"
        Me.lblState.Size = New System.Drawing.Size(33, 13)
        Me.lblState.TabIndex = 10
        Me.lblState.Text = "value"
        '
        'Example6
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(554, 198)
        Me.Controls.Add(Me.lblState)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.LabelIsItValidXPL)
        Me.Controls.Add(Me.lblVendor)
        Me.Controls.Add(Me.lblOther)
        Me.Controls.Add(Me.lblValue)
        Me.Controls.Add(Me.chkValidxPLOther)
        Me.Controls.Add(Me.chkValidxPLVendor)
        Me.Controls.Add(Me.chkValidXPLValue)
        Me.Controls.Add(Me.tbDemoText)
        Me.Name = "Example6"
        Me.Text = "Example6 - some auxillary functions"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents tbDemoText As System.Windows.Forms.TextBox
    Friend WithEvents chkValidXPLValue As System.Windows.Forms.CheckBox
    Friend WithEvents chkValidxPLVendor As System.Windows.Forms.CheckBox
    Friend WithEvents chkValidxPLOther As System.Windows.Forms.CheckBox
    Friend WithEvents lblValue As System.Windows.Forms.Label
    Friend WithEvents lblOther As System.Windows.Forms.Label
    Friend WithEvents lblVendor As System.Windows.Forms.Label
    Friend WithEvents LabelIsItValidXPL As System.Windows.Forms.Label
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents lblState As System.Windows.Forms.Label
End Class
