'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2004 John Bent & Ian Jeffery
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

Public Class frmConnect
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
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents txtServer As System.Windows.Forms.TextBox

    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmConnect))
		Me.Label1 = New System.Windows.Forms.Label
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.txtServer = New System.Windows.Forms.TextBox
		Me.SuspendLayout()
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 16)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(160, 32)
		Me.Label1.TabIndex = 0
		Me.Label1.Text = "Connect to this server:"
		'
		'cmdOK
		'
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(8, 88)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 1
		Me.cmdOK.Text = "OK"
		'
		'cmdCancel
		'
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(96, 88)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 2
		Me.cmdCancel.Text = "Cancel"
		'
		'txtServer
		'
		Me.txtServer.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtServer.Location = New System.Drawing.Point(8, 56)
		Me.txtServer.Name = "txtServer"
		Me.txtServer.Size = New System.Drawing.Size(160, 20)
		Me.txtServer.TabIndex = 0
		Me.txtServer.Text = ""
		'
		'frmConnect
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(186, 125)
		Me.Controls.Add(Me.txtServer)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.Label1)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmConnect"
		Me.Text = "Connect to xPLHal Server"
		Me.ResumeLayout(False)

	End Sub

#End Region


    Private Sub frmConnect_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'Me.CancelButton = cmdCancel
        'Me.AcceptButton = cmdOK
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        Me.DialogResult = Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub

End Class
