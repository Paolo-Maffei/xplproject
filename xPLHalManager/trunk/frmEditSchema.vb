'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003 John Bent & Ian Jeffery
'* http://www.xpl.myby.co.uk
'*
'* This program is free software; you can redistribute it and/or
'* modify it under the terms of the GNU General Public License
'* as published by the Free Software Foundation; either version 2
'* of the License, or (at your option) any later version.
'* 
'* This program is distributed in the hope that it will be useful,
'* but WITHOUT ANY WARRANTY; without even the implied warranty of
'* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'* GNU General Public License for more details.
'*
'* You should have received a copy of the GNU General Public License
'* along with this program; if not, write to the Free Software
'* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
'**************************************
Option Strict On

Public Class frmEditSchema
    Inherits System.Windows.Forms.Form




#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents txtSubs As System.Windows.Forms.TextBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents txtSchemaType As System.Windows.Forms.TextBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents txtSchemaClass As System.Windows.Forms.TextBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents txtInstance As System.Windows.Forms.TextBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents txtDevice As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents cmbMessageType As System.Windows.Forms.ComboBox
    Friend WithEvents txtVendor As System.Windows.Forms.TextBox
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdExit As System.Windows.Forms.Button
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents optContinueYes As System.Windows.Forms.RadioButton
    Friend WithEvents optContinueNo As System.Windows.Forms.RadioButton
    Friend WithEvents gbxContinue As System.Windows.Forms.GroupBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditSchema))
		Me.Label10 = New System.Windows.Forms.Label
		Me.txtSubs = New System.Windows.Forms.TextBox
		Me.Label9 = New System.Windows.Forms.Label
		Me.txtSchemaType = New System.Windows.Forms.TextBox
		Me.Label8 = New System.Windows.Forms.Label
		Me.txtSchemaClass = New System.Windows.Forms.TextBox
		Me.Label7 = New System.Windows.Forms.Label
		Me.txtInstance = New System.Windows.Forms.TextBox
		Me.Label6 = New System.Windows.Forms.Label
		Me.txtDevice = New System.Windows.Forms.TextBox
		Me.Label5 = New System.Windows.Forms.Label
		Me.Label4 = New System.Windows.Forms.Label
		Me.cmbMessageType = New System.Windows.Forms.ComboBox
		Me.txtVendor = New System.Windows.Forms.TextBox
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdExit = New System.Windows.Forms.Button
		Me.GroupBox1 = New System.Windows.Forms.GroupBox
		Me.GroupBox2 = New System.Windows.Forms.GroupBox
		Me.gbxContinue = New System.Windows.Forms.GroupBox
		Me.optContinueNo = New System.Windows.Forms.RadioButton
		Me.optContinueYes = New System.Windows.Forms.RadioButton
		Me.GroupBox1.SuspendLayout()
		Me.GroupBox2.SuspendLayout()
		Me.gbxContinue.SuspendLayout()
		Me.SuspendLayout()
		'
		'Label10
		'
		Me.Label10.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label10.Location = New System.Drawing.Point(24, 296)
		Me.Label10.Name = "Label10"
		Me.Label10.Size = New System.Drawing.Size(112, 20)
		Me.Label10.TabIndex = 13
		Me.Label10.Text = "Subs"
		Me.Label10.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtSubs
		'
		Me.txtSubs.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSubs.Location = New System.Drawing.Point(144, 296)
		Me.txtSubs.Name = "txtSubs"
		Me.txtSubs.Size = New System.Drawing.Size(232, 20)
		Me.txtSubs.TabIndex = 6
		Me.txtSubs.Text = ""
		'
		'Label9
		'
		Me.Label9.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label9.Location = New System.Drawing.Point(16, 56)
		Me.Label9.Name = "Label9"
		Me.Label9.Size = New System.Drawing.Size(112, 20)
		Me.Label9.TabIndex = 11
		Me.Label9.Text = "Type"
		Me.Label9.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtSchemaType
		'
		Me.txtSchemaType.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSchemaType.Location = New System.Drawing.Point(136, 56)
		Me.txtSchemaType.Name = "txtSchemaType"
		Me.txtSchemaType.Size = New System.Drawing.Size(232, 20)
		Me.txtSchemaType.TabIndex = 5
		Me.txtSchemaType.Text = ""
		'
		'Label8
		'
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Location = New System.Drawing.Point(16, 24)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(112, 20)
		Me.Label8.TabIndex = 9
		Me.Label8.Text = "Class"
		Me.Label8.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtSchemaClass
		'
		Me.txtSchemaClass.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSchemaClass.Location = New System.Drawing.Point(136, 24)
		Me.txtSchemaClass.Name = "txtSchemaClass"
		Me.txtSchemaClass.Size = New System.Drawing.Size(232, 20)
		Me.txtSchemaClass.TabIndex = 4
		Me.txtSchemaClass.Text = ""
		'
		'Label7
		'
		Me.Label7.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label7.Location = New System.Drawing.Point(16, 88)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(112, 20)
		Me.Label7.TabIndex = 7
		Me.Label7.Text = "Instance"
		Me.Label7.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtInstance
		'
		Me.txtInstance.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtInstance.Location = New System.Drawing.Point(136, 88)
		Me.txtInstance.Name = "txtInstance"
		Me.txtInstance.Size = New System.Drawing.Size(232, 20)
		Me.txtInstance.TabIndex = 3
		Me.txtInstance.Text = ""
		'
		'Label6
		'
		Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label6.Location = New System.Drawing.Point(16, 56)
		Me.Label6.Name = "Label6"
		Me.Label6.Size = New System.Drawing.Size(112, 20)
		Me.Label6.TabIndex = 5
		Me.Label6.Text = "Device"
		Me.Label6.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtDevice
		'
		Me.txtDevice.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtDevice.Location = New System.Drawing.Point(136, 56)
		Me.txtDevice.Name = "txtDevice"
		Me.txtDevice.Size = New System.Drawing.Size(232, 20)
		Me.txtDevice.TabIndex = 2
		Me.txtDevice.Text = ""
		'
		'Label5
		'
		Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label5.Location = New System.Drawing.Point(16, 24)
		Me.Label5.Name = "Label5"
		Me.Label5.Size = New System.Drawing.Size(112, 20)
		Me.Label5.TabIndex = 3
		Me.Label5.Text = "Vendor"
		Me.Label5.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label4
		'
		Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label4.Location = New System.Drawing.Point(24, 24)
		Me.Label4.Name = "Label4"
		Me.Label4.Size = New System.Drawing.Size(112, 20)
		Me.Label4.TabIndex = 2
		Me.Label4.Text = "Message Type"
		Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'cmbMessageType
		'
		Me.cmbMessageType.Location = New System.Drawing.Point(144, 24)
		Me.cmbMessageType.Name = "cmbMessageType"
		Me.cmbMessageType.Size = New System.Drawing.Size(232, 21)
		Me.cmbMessageType.TabIndex = 0
		'
		'txtVendor
		'
		Me.txtVendor.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtVendor.Location = New System.Drawing.Point(136, 24)
		Me.txtVendor.Name = "txtVendor"
		Me.txtVendor.Size = New System.Drawing.Size(232, 20)
		Me.txtVendor.TabIndex = 1
		Me.txtVendor.Text = ""
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(208, 408)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 9
		Me.cmdOK.Text = "OK"
		'
		'cmdExit
		'
		Me.cmdExit.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdExit.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdExit.Location = New System.Drawing.Point(296, 408)
		Me.cmdExit.Name = "cmdExit"
		Me.cmdExit.TabIndex = 10
		Me.cmdExit.Text = "Cancel"
		'
		'GroupBox1
		'
		Me.GroupBox1.Controls.Add(Me.Label7)
		Me.GroupBox1.Controls.Add(Me.txtInstance)
		Me.GroupBox1.Controls.Add(Me.Label6)
		Me.GroupBox1.Controls.Add(Me.txtDevice)
		Me.GroupBox1.Controls.Add(Me.Label5)
		Me.GroupBox1.Controls.Add(Me.txtVendor)
		Me.GroupBox1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.GroupBox1.Location = New System.Drawing.Point(8, 56)
		Me.GroupBox1.Name = "GroupBox1"
		Me.GroupBox1.Size = New System.Drawing.Size(376, 120)
		Me.GroupBox1.TabIndex = 16
		Me.GroupBox1.TabStop = False
		Me.GroupBox1.Text = "Source"
		'
		'GroupBox2
		'
		Me.GroupBox2.Controls.Add(Me.Label8)
		Me.GroupBox2.Controls.Add(Me.txtSchemaClass)
		Me.GroupBox2.Controls.Add(Me.Label9)
		Me.GroupBox2.Controls.Add(Me.txtSchemaType)
		Me.GroupBox2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.GroupBox2.Location = New System.Drawing.Point(8, 192)
		Me.GroupBox2.Name = "GroupBox2"
		Me.GroupBox2.Size = New System.Drawing.Size(376, 88)
		Me.GroupBox2.TabIndex = 17
		Me.GroupBox2.TabStop = False
		Me.GroupBox2.Text = "Schema"
		'
		'gbxContinue
		'
		Me.gbxContinue.Controls.Add(Me.optContinueNo)
		Me.gbxContinue.Controls.Add(Me.optContinueYes)
		Me.gbxContinue.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.gbxContinue.Location = New System.Drawing.Point(8, 336)
		Me.gbxContinue.Name = "gbxContinue"
		Me.gbxContinue.Size = New System.Drawing.Size(376, 64)
		Me.gbxContinue.TabIndex = 18
		Me.gbxContinue.TabStop = False
		Me.gbxContinue.Text = "Continue processing rules after execution of this rule is complete?"
		'
		'optContinueNo
		'
		Me.optContinueNo.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.optContinueNo.Location = New System.Drawing.Point(136, 40)
		Me.optContinueNo.Name = "optContinueNo"
		Me.optContinueNo.Size = New System.Drawing.Size(72, 16)
		Me.optContinueNo.TabIndex = 8
		Me.optContinueNo.Text = "No"
		'
		'optContinueYes
		'
		Me.optContinueYes.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.optContinueYes.Location = New System.Drawing.Point(136, 24)
		Me.optContinueYes.Name = "optContinueYes"
		Me.optContinueYes.Size = New System.Drawing.Size(72, 16)
		Me.optContinueYes.TabIndex = 7
		Me.optContinueYes.Text = "Yes"
		'
		'frmEditSchema
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdExit
		Me.ClientSize = New System.Drawing.Size(394, 447)
		Me.Controls.Add(Me.gbxContinue)
		Me.Controls.Add(Me.GroupBox2)
		Me.Controls.Add(Me.GroupBox1)
		Me.Controls.Add(Me.cmdExit)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.Label4)
		Me.Controls.Add(Me.cmbMessageType)
		Me.Controls.Add(Me.Label10)
		Me.Controls.Add(Me.txtSubs)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmEditSchema"
		Me.Text = "Edit Rule"
		Me.GroupBox1.ResumeLayout(False)
		Me.GroupBox2.ResumeLayout(False)
		Me.gbxContinue.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        Me.DialogResult = Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub

    Private Sub txtVendor_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtVendor.TextChanged

    End Sub

    Private Sub txtSchemaType_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSchemaType.TextChanged

    End Sub
End Class
