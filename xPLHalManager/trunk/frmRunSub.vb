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

Public Class frmRunSub
    Inherits xplhalMgrBase

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
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdRun As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cmbRunSub As System.Windows.Forms.ComboBox
    Friend WithEvents txtParameters As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
    Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmRunSub))
    Me.cmdCancel = New System.Windows.Forms.Button
    Me.cmdRun = New System.Windows.Forms.Button
    Me.Label1 = New System.Windows.Forms.Label
    Me.cmbRunSub = New System.Windows.Forms.ComboBox
    Me.txtParameters = New System.Windows.Forms.TextBox
    Me.Label2 = New System.Windows.Forms.Label
    Me.SuspendLayout()
    '
    'cmdCancel
    '
    Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
    Me.cmdCancel.FlatStyle = FlatStyle.System
    Me.cmdCancel.Location = New System.Drawing.Point(248, 116)
    Me.cmdCancel.Name = "cmdCancel"
    Me.cmdCancel.TabIndex = 3
    Me.cmdCancel.Text = "Close"
    '
    'cmdRun
    '
    Me.cmdRun.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdRun.FlatStyle = FlatStyle.System
    Me.cmdRun.Location = New System.Drawing.Point(168, 116)
    Me.cmdRun.Name = "cmdRun"
    Me.cmdRun.TabIndex = 2
    Me.cmdRun.Text = "Run"
    '
    'Label1
    '
    Me.Label1.FlatStyle = FlatStyle.System
    Me.Label1.Location = New System.Drawing.Point(8, 16)
    Me.Label1.Name = "Label1"
    Me.Label1.Size = New System.Drawing.Size(320, 16)
    Me.Label1.TabIndex = 20
    Me.Label1.Text = "Select subroutine to run:"
    '
    'cmbRunSub
    '
    Me.cmbRunSub.DropDownWidth = 320
    Me.cmbRunSub.Location = New System.Drawing.Point(8, 32)
    Me.cmbRunSub.Name = "cmbRunSub"
    Me.cmbRunSub.Size = New System.Drawing.Size(320, 21)
    Me.cmbRunSub.Sorted = True
    Me.cmbRunSub.TabIndex = 0
    '
    'txtParameters
    '
    Me.txtParameters.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.txtParameters.Location = New System.Drawing.Point(8, 80)
    Me.txtParameters.Name = "txtParameters"
    Me.txtParameters.Size = New System.Drawing.Size(320, 20)
    Me.txtParameters.TabIndex = 1
    Me.txtParameters.Text = ""
    '
    'Label2
    '
    Me.Label2.FlatStyle = FlatStyle.System
    Me.Label2.Location = New System.Drawing.Point(8, 64)
    Me.Label2.Name = "Label2"
    Me.Label2.Size = New System.Drawing.Size(320, 16)
    Me.Label2.TabIndex = 23
    Me.Label2.Text = "Parameters (optional)"
    '
    'frmRunSub
    '
    Me.AcceptButton = Me.cmdRun
    Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
    Me.CancelButton = Me.cmdCancel
    Me.ClientSize = New System.Drawing.Size(336, 141)
    Me.Controls.Add(Me.Label2)
    Me.Controls.Add(Me.txtParameters)
    Me.Controls.Add(Me.cmbRunSub)
    Me.Controls.Add(Me.Label1)
    Me.Controls.Add(Me.cmdCancel)
    Me.Controls.Add(Me.cmdRun)
    Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
    Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
    Me.Name = "frmRunSub"
    Me.Text = "Run Subroutine"
    Me.ResumeLayout(False)

  End Sub

#End Region

  Private Sub frmRunSub_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    connecttoxplhal()
    populatesubs(cmbRunSub)
    'If LastRunSub <> "" Then
    cmbRunSub.Text = LastRunSub
    txtParameters.Text = LastRunSubParam
    'End If
  End Sub

  Private Sub cmdRun_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRun.Click
    Dim str As String
    LastRunSub = cmbRunSub.Text
    LastRunSubParam = txtParameters.Text
    If txtParameters.Text = "" Then
      xplHalSend("RUNSUB " & cmbRunSub.Text & vbCrLf)
    Else
      xplHalSend("RUNSUB " & cmbRunSub.Text & " " & txtParameters.Text & vbCrLf)
    End If
    str = getLine
    Me.Close()
  End Sub

End Class
