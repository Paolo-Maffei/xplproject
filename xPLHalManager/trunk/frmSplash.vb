'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2007 John Bent & Ian Jeffery
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

Public Class frmSplash
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
    Friend WithEvents lblDescription As System.Windows.Forms.Label
    Friend WithEvents lblTitle As System.Windows.Forms.Label
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmSplash))
		Me.lblDescription = New System.Windows.Forms.Label
		Me.lblTitle = New System.Windows.Forms.Label
		Me.PictureBox1 = New System.Windows.Forms.PictureBox
		Me.SuspendLayout()
		'
		'lblDescription
		'
		Me.lblDescription.BackColor = System.Drawing.SystemColors.Window
		Me.lblDescription.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lblDescription.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblDescription.Font = New System.Drawing.Font("Times New Roman", 12.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.lblDescription.ForeColor = System.Drawing.SystemColors.WindowText
		Me.lblDescription.Location = New System.Drawing.Point(88, 24)
		Me.lblDescription.Name = "lblDescription"
		Me.lblDescription.Size = New System.Drawing.Size(306, 159)
		Me.lblDescription.TabIndex = 5
		Me.lblDescription.Text = "Label1"
		Me.lblDescription.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		'
		'lblTitle
		'
		Me.lblTitle.BackColor = System.Drawing.SystemColors.Window
		Me.lblTitle.Dock = System.Windows.Forms.DockStyle.Top
		Me.lblTitle.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblTitle.Font = New System.Drawing.Font("Microsoft Sans Serif", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.lblTitle.ForeColor = System.Drawing.SystemColors.WindowText
		Me.lblTitle.Location = New System.Drawing.Point(88, 0)
		Me.lblTitle.Name = "lblTitle"
		Me.lblTitle.Size = New System.Drawing.Size(306, 24)
		Me.lblTitle.TabIndex = 4
		Me.lblTitle.Text = "xPLHal"
		Me.lblTitle.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'PictureBox1
		'
		Me.PictureBox1.BackColor = System.Drawing.SystemColors.Window
		Me.PictureBox1.Dock = System.Windows.Forms.DockStyle.Left
		Me.PictureBox1.Image = CType(resources.GetObject("PictureBox1.Image"), System.Drawing.Image)
		Me.PictureBox1.Location = New System.Drawing.Point(0, 0)
		Me.PictureBox1.Name = "PictureBox1"
		Me.PictureBox1.Size = New System.Drawing.Size(88, 183)
		Me.PictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage
		Me.PictureBox1.TabIndex = 3
		Me.PictureBox1.TabStop = False
		'
		'frmSplash
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.ClientSize = New System.Drawing.Size(394, 183)
		Me.Controls.Add(Me.lblDescription)
		Me.Controls.Add(Me.lblTitle)
		Me.Controls.Add(Me.PictureBox1)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.MaximizeBox = False
		Me.MinimizeBox = False
		Me.Name = "frmSplash"
		Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
		Me.Text = "xPLHal"
		Me.ResumeLayout(False)

	End Sub

#End Region

  Private Sub frmSplash_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    lblDescription.Text = "Version " & System.Reflection.Assembly.GetExecutingAssembly.GetName().Version.Major.ToString & "." & System.Reflection.Assembly.GetExecutingAssembly.GetName.Version.Minor
    lblDescription.Text &= vbCrLf & vbCrLf & "by" & vbCrLf & "John Bent" & vbCrLf & "and" & vbCrLf & "Ian Jeffery"
  End Sub

End Class
