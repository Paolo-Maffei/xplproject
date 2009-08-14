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

Public Class frmNewBodyBits
  Inherits xplhalMgrBase


#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()
    populatecomparisoncombo(cmbOperator)
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
    Friend WithEvents cmbName As System.Windows.Forms.ComboBox
    Friend WithEvents cmbOperator As System.Windows.Forms.ComboBox
    Friend WithEvents txtValue As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
    Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmNewBodyBits))
    Me.cmbName = New System.Windows.Forms.ComboBox
    Me.cmbOperator = New System.Windows.Forms.ComboBox
    Me.txtValue = New System.Windows.Forms.TextBox
    Me.Label1 = New System.Windows.Forms.Label
    Me.Label2 = New System.Windows.Forms.Label
    Me.Label3 = New System.Windows.Forms.Label
    Me.cmdOK = New System.Windows.Forms.Button
    Me.cmdCancel = New System.Windows.Forms.Button
    Me.SuspendLayout()
    '
    'cmbName
    '
    Me.cmbName.Location = New System.Drawing.Point(16, 32)
    Me.cmbName.Name = "cmbName"
    Me.cmbName.Size = New System.Drawing.Size(256, 21)
    Me.cmbName.TabIndex = 0
    '
    'cmbOperator
    '
    Me.cmbOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
    Me.cmbOperator.Location = New System.Drawing.Point(16, 80)
    Me.cmbOperator.Name = "cmbOperator"
    Me.cmbOperator.Size = New System.Drawing.Size(256, 21)
    Me.cmbOperator.TabIndex = 1
    '
    'txtValue
    '
    Me.txtValue.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.txtValue.Location = New System.Drawing.Point(16, 128)
    Me.txtValue.Name = "txtValue"
    Me.txtValue.Size = New System.Drawing.Size(256, 20)
    Me.txtValue.TabIndex = 2
    Me.txtValue.Text = ""
    '
    'Label1
    '
    Me.Label1.FlatStyle = FlatStyle.System
    Me.Label1.Location = New System.Drawing.Point(16, 16)
    Me.Label1.Name = "Label1"
    Me.Label1.Size = New System.Drawing.Size(256, 16)
    Me.Label1.TabIndex = 3
    Me.Label1.Text = "Name"
    '
    'Label2
    '
    Me.Label2.FlatStyle = FlatStyle.System
    Me.Label2.Location = New System.Drawing.Point(16, 112)
    Me.Label2.Name = "Label2"
    Me.Label2.Size = New System.Drawing.Size(256, 16)
    Me.Label2.TabIndex = 4
    Me.Label2.Text = "Value"
    '
    'Label3
    '
    Me.Label3.FlatStyle = FlatStyle.System
    Me.Label3.Location = New System.Drawing.Point(16, 64)
    Me.Label3.Name = "Label3"
    Me.Label3.Size = New System.Drawing.Size(256, 16)
    Me.Label3.TabIndex = 5
    Me.Label3.Text = "Operator"
    '
    'cmdOK
    '
    Me.cmdOK.FlatStyle = FlatStyle.System
    Me.cmdOK.Location = New System.Drawing.Point(104, 160)
    Me.cmdOK.Name = "cmdOK"
    Me.cmdOK.TabIndex = 3
    Me.cmdOK.Text = "OK"
    '
    'cmdCancel
    '
    Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
    Me.cmdCancel.FlatStyle = FlatStyle.System
    Me.cmdCancel.Location = New System.Drawing.Point(192, 160)
    Me.cmdCancel.Name = "cmdCancel"
    Me.cmdCancel.TabIndex = 4
    Me.cmdCancel.Text = "Cancel"
    '
    'frmNewBodyBits
    '
    Me.AcceptButton = Me.cmdOK
    Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
    Me.CancelButton = Me.cmdCancel
    Me.ClientSize = New System.Drawing.Size(288, 189)
    Me.Controls.Add(Me.cmdCancel)
    Me.Controls.Add(Me.cmdOK)
    Me.Controls.Add(Me.Label3)
    Me.Controls.Add(Me.Label2)
    Me.Controls.Add(Me.Label1)
    Me.Controls.Add(Me.txtValue)
    Me.Controls.Add(Me.cmbOperator)
    Me.Controls.Add(Me.cmbName)
    Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
    Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
    Me.Name = "frmNewBodyBits"
    Me.Text = "Message Parameters"
    Me.ResumeLayout(False)

  End Sub

#End Region

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
		Me.DialogResult = Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub




End Class
