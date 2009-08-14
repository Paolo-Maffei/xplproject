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

Public Class frmEditXML
    Inherits xplhalMgrBase

    Private IsDirty As Boolean

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
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents txtXML As System.Windows.Forms.TextBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditXML))
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.txtXML = New System.Windows.Forms.TextBox
		Me.Panel1.SuspendLayout()
		Me.Panel2.SuspendLayout()
		Me.SuspendLayout()
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.cmdCancel)
		Me.Panel1.Controls.Add(Me.cmdOK)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel1.Location = New System.Drawing.Point(0, 473)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(744, 40)
		Me.Panel1.TabIndex = 1
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(656, 8)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 2
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(568, 8)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 1
		Me.cmdOK.Text = "OK"
		'
		'Panel2
		'
		Me.Panel2.Controls.Add(Me.txtXML)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Fill
		Me.Panel2.Location = New System.Drawing.Point(0, 0)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(744, 473)
		Me.Panel2.TabIndex = 2
		'
		'txtXML
		'
		Me.txtXML.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtXML.Dock = System.Windows.Forms.DockStyle.Fill
		Me.txtXML.Location = New System.Drawing.Point(0, 0)
		Me.txtXML.Multiline = True
		Me.txtXML.Name = "txtXML"
		Me.txtXML.ScrollBars = System.Windows.Forms.ScrollBars.Both
		Me.txtXML.Size = New System.Drawing.Size(744, 473)
		Me.txtXML.TabIndex = 0
		Me.txtXML.Text = ""
		Me.txtXML.WordWrap = False
		'
		'frmEditXML
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(744, 513)
		Me.Controls.Add(Me.Panel2)
		Me.Controls.Add(Me.Panel1)
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmEditXML"
		Me.Text = "Edit XML Configuration Document"
		Me.Panel1.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub frmEditXML_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    GetFormSettings(Me, 752, 540)
    txtXML.Text = getconfigXML()
        IsDirty = False        
    End Sub

    Private Sub cmdOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        savexml(txtXML.Text)
        Me.Close()
    End Sub

    
    Private Sub cmdCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

  Private Sub frmEditXML_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
    SetFormSettings(Me)
  End Sub
End Class
