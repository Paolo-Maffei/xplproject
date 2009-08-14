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

Public Class frmErrorLog
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
    Friend WithEvents txtErrorLog As System.Windows.Forms.TextBox
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents cmdClose As System.Windows.Forms.Button
    Friend WithEvents cmdClear As System.Windows.Forms.Button
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
    Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmErrorLog))
    Me.txtErrorLog = New System.Windows.Forms.TextBox
    Me.Panel2 = New System.Windows.Forms.Panel
    Me.cmdClose = New System.Windows.Forms.Button
    Me.cmdClear = New System.Windows.Forms.Button
    Me.Panel1 = New System.Windows.Forms.Panel
    Me.Panel2.SuspendLayout()
    Me.Panel1.SuspendLayout()
    Me.SuspendLayout()
    '
    'txtErrorLog
    '
    Me.txtErrorLog.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.txtErrorLog.Dock = System.Windows.Forms.DockStyle.Fill
    Me.txtErrorLog.Location = New System.Drawing.Point(0, 0)
    Me.txtErrorLog.Multiline = True
    Me.txtErrorLog.Name = "txtErrorLog"
    Me.txtErrorLog.ReadOnly = True
    Me.txtErrorLog.ScrollBars = System.Windows.Forms.ScrollBars.Both
    Me.txtErrorLog.Size = New System.Drawing.Size(744, 473)
    Me.txtErrorLog.TabIndex = 0
    Me.txtErrorLog.Text = ""
    Me.txtErrorLog.WordWrap = False
    '
    'Panel2
    '
    Me.Panel2.Controls.Add(Me.cmdClose)
    Me.Panel2.Controls.Add(Me.cmdClear)
    Me.Panel2.Dock = System.Windows.Forms.DockStyle.Bottom
    Me.Panel2.Location = New System.Drawing.Point(0, 473)
    Me.Panel2.Name = "Panel2"
    Me.Panel2.Size = New System.Drawing.Size(744, 40)
    Me.Panel2.TabIndex = 4
    '
    'cmdClose
    '
    Me.cmdClose.AccessibleDescription = "Closes the window"
    Me.cmdClose.AccessibleName = "Close"
    Me.cmdClose.FlatStyle = FlatStyle.System
    Me.cmdClose.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdClose.DialogResult = System.Windows.Forms.DialogResult.Cancel
    Me.cmdClose.Location = New System.Drawing.Point(664, 8)
    Me.cmdClose.Name = "cmdClose"
    Me.cmdClose.TabIndex = 2
    Me.cmdClose.Text = "Close"
    '
    'cmdClear
    '
    Me.cmdClear.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdClear.FlatStyle = FlatStyle.System
    Me.cmdClear.Location = New System.Drawing.Point(584, 8)
    Me.cmdClear.Name = "cmdClear"
    Me.cmdClear.TabIndex = 1
    Me.cmdClear.Text = "Clear Log"
    '
    'Panel1
    '
    Me.Panel1.Controls.Add(Me.txtErrorLog)
    Me.Panel1.Dock = System.Windows.Forms.DockStyle.Fill
    Me.Panel1.Location = New System.Drawing.Point(0, 0)
    Me.Panel1.Name = "Panel1"
    Me.Panel1.Size = New System.Drawing.Size(744, 473)
    Me.Panel1.TabIndex = 5
    '
    'frmErrorLog
    '
    Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
    Me.ClientSize = New System.Drawing.Size(744, 513)
    Me.Controls.Add(Me.Panel1)
    Me.Controls.Add(Me.Panel2)
    Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
    Me.Name = "frmErrorLog"
    Me.Text = "xPLHal Error Log"
    Me.Panel2.ResumeLayout(False)
    Me.Panel1.ResumeLayout(False)
    Me.ResumeLayout(False)

  End Sub

#End Region


    Private Sub frmErrorLog_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    GetFormSettings(Me, 752, 540)
    Dim str As String
    Dim sb As New StringBuilder
        connectToXplHal()
        xplhalsend("GETERRLOG" & vbCrLf)
        str = getLine
        If str.StartsWith("207") Then
            str = getLine
            While str <> ("." & vbCrLf) And str <> ""
        sb.Append(str)
                str = getLine
            End While
        End If
    Disconnect()
    txtErrorLog.Text = sb.ToString
    End Sub

    Private Sub cmdClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdClose.Click
        Me.Close()
    End Sub

    Private Sub cmdClear_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdClear.Click
        If MsgBox(My.Resources.RES_CLEAR_ERROR_LOG, vbQuestion Or vbYesNo) = vbYes Then
            Dim str As String
            ConnectToXplHal()
            xplHalSend("CLEARERRLOG" & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("225") Then
                globals.Unexpected(str)
            End If
            Disconnect()
            Me.Close()
        End If
    End Sub

    Private Sub Panel1_Paint(ByVal sender As System.Object, ByVal e As System.Windows.Forms.PaintEventArgs)

    End Sub

  Private Sub frmErrorLog_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
    SetFormSettings(Me)
  End Sub
End Class
