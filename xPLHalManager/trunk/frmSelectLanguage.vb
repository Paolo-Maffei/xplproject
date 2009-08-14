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

Public Class frmSelectLanguage
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
    Friend WithEvents cmbLanguage As System.Windows.Forms.ComboBox
    Friend WithEvents lblLanguage As System.Windows.Forms.Label
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdExit As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmSelectLanguage))
		Me.cmbLanguage = New System.Windows.Forms.ComboBox
		Me.lblLanguage = New System.Windows.Forms.Label
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdExit = New System.Windows.Forms.Button
		Me.SuspendLayout()
		'
		'cmbLanguage
		'
		Me.cmbLanguage.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbLanguage.Location = New System.Drawing.Point(24, 32)
		Me.cmbLanguage.Name = "cmbLanguage"
		Me.cmbLanguage.Size = New System.Drawing.Size(248, 21)
		Me.cmbLanguage.TabIndex = 0
		'
		'lblLanguage
		'
		Me.lblLanguage.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblLanguage.Location = New System.Drawing.Point(24, 16)
		Me.lblLanguage.Name = "lblLanguage"
		Me.lblLanguage.Size = New System.Drawing.Size(240, 16)
		Me.lblLanguage.TabIndex = 1
		Me.lblLanguage.Text = "Select your language."
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(96, 72)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 2
		Me.cmdOK.Text = "OK"
		'
		'cmdExit
		'
		Me.cmdExit.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdExit.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdExit.Location = New System.Drawing.Point(192, 72)
		Me.cmdExit.Name = "cmdExit"
		Me.cmdExit.TabIndex = 3
		Me.cmdExit.Text = "Cancel"
		'
		'frmSelectLanguage
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdExit
		Me.ClientSize = New System.Drawing.Size(296, 109)
		Me.Controls.Add(Me.cmdExit)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.lblLanguage)
		Me.Controls.Add(Me.cmbLanguage)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmSelectLanguage"
		Me.Text = "Select Language"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub frmSelectLanguage_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        cmbLanguage.Items.Add("English")
        cmbLanguage.Items.Add("French")
        Me.Text = My.Resources.RES_LANGUAGE_CAPTION
        cmdOK.Text = My.Resources.RES_OK
        cmdExit.Text = My.Resources.RES_CANCEL
        lblLanguage.Text = My.Resources.RES_LANGUAGE

        ' Select current language        
        Select Case Threading.Thread.CurrentThread.CurrentUICulture.ToString.Substring(0, 2)
            Case "en"
                cmbLanguage.SelectedIndex = 0
            Case "fr"
                cmbLanguage.SelectedIndex = 1
        End Select
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        Select Case CStr(cmbLanguage.SelectedItem)
            Case "English"
                Threading.Thread.CurrentThread.CurrentUICulture = New CultureInfo("en")
            Case "French"
                Threading.Thread.CurrentThread.CurrentUICulture = New CultureInfo("fr")
        End Select
        globals.SaveSettings()
        MsgBox("You will need to restart xPLHal Manager for your new language to take effect.", vbInformation)
        Me.Close()
    End Sub

End Class
