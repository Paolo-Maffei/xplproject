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

Public Class frmSendRawXPL
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
    Friend WithEvents cmbMessageType As System.Windows.Forms.ComboBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents txtSchema As System.Windows.Forms.TextBox
    Friend WithEvents txtType As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents txtCommand1B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand1A As System.Windows.Forms.TextBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents txtCommand2B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand2A As System.Windows.Forms.TextBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents txtCommand3B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand3A As System.Windows.Forms.TextBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents txtCommand4B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand4A As System.Windows.Forms.TextBox
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents txtCommand5B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand5A As System.Windows.Forms.TextBox
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents txtCommand6B As System.Windows.Forms.TextBox
    Friend WithEvents txtCommand6A As System.Windows.Forms.TextBox
    Friend WithEvents cmdSend As System.Windows.Forms.Button
    Friend WithEvents cmdClear As System.Windows.Forms.Button
    Friend WithEvents cmdExit As System.Windows.Forms.Button
    Friend WithEvents cmbTarget As System.Windows.Forms.ComboBox
    Friend WithEvents txtSource As System.Windows.Forms.TextBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmSendRawXPL))
		Me.cmbMessageType = New System.Windows.Forms.ComboBox
		Me.cmbTarget = New System.Windows.Forms.ComboBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.Label2 = New System.Windows.Forms.Label
		Me.Label3 = New System.Windows.Forms.Label
		Me.Label4 = New System.Windows.Forms.Label
		Me.txtSchema = New System.Windows.Forms.TextBox
		Me.txtType = New System.Windows.Forms.TextBox
		Me.Label5 = New System.Windows.Forms.Label
		Me.Label6 = New System.Windows.Forms.Label
		Me.txtCommand1B = New System.Windows.Forms.TextBox
		Me.txtCommand1A = New System.Windows.Forms.TextBox
		Me.Label7 = New System.Windows.Forms.Label
		Me.txtCommand2B = New System.Windows.Forms.TextBox
		Me.txtCommand2A = New System.Windows.Forms.TextBox
		Me.Label8 = New System.Windows.Forms.Label
		Me.txtCommand3B = New System.Windows.Forms.TextBox
		Me.txtCommand3A = New System.Windows.Forms.TextBox
		Me.Label9 = New System.Windows.Forms.Label
		Me.txtCommand4B = New System.Windows.Forms.TextBox
		Me.txtCommand4A = New System.Windows.Forms.TextBox
		Me.Label10 = New System.Windows.Forms.Label
		Me.txtCommand5B = New System.Windows.Forms.TextBox
		Me.txtCommand5A = New System.Windows.Forms.TextBox
		Me.Label11 = New System.Windows.Forms.Label
		Me.txtCommand6B = New System.Windows.Forms.TextBox
		Me.txtCommand6A = New System.Windows.Forms.TextBox
		Me.cmdSend = New System.Windows.Forms.Button
		Me.cmdClear = New System.Windows.Forms.Button
		Me.cmdExit = New System.Windows.Forms.Button
		Me.txtSource = New System.Windows.Forms.TextBox
		Me.SuspendLayout()
		'
		'cmbMessageType
		'
		Me.cmbMessageType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbMessageType.Location = New System.Drawing.Point(112, 40)
		Me.cmbMessageType.Name = "cmbMessageType"
		Me.cmbMessageType.Size = New System.Drawing.Size(232, 21)
		Me.cmbMessageType.TabIndex = 0
		'
		'cmbTarget
		'
		Me.cmbTarget.Location = New System.Drawing.Point(112, 88)
		Me.cmbTarget.Name = "cmbTarget"
		Me.cmbTarget.Size = New System.Drawing.Size(232, 21)
		Me.cmbTarget.Sorted = True
		Me.cmbTarget.TabIndex = 2
		Me.cmbTarget.Text = "ComboBox3"
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 40)
		Me.Label1.Name = "Label1"
		Me.Label1.TabIndex = 3
		Me.Label1.Text = "Message Type :"
		Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label2
		'
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Location = New System.Drawing.Point(8, 64)
		Me.Label2.Name = "Label2"
		Me.Label2.TabIndex = 4
		Me.Label2.Text = "Source :"
		Me.Label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label3
		'
		Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label3.Location = New System.Drawing.Point(8, 88)
		Me.Label3.Name = "Label3"
		Me.Label3.TabIndex = 5
		Me.Label3.Text = "Target :"
		Me.Label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label4
		'
		Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label4.Location = New System.Drawing.Point(8, 112)
		Me.Label4.Name = "Label4"
		Me.Label4.TabIndex = 6
		Me.Label4.Text = "Schema :"
		Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtSchema
		'
		Me.txtSchema.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSchema.Location = New System.Drawing.Point(112, 112)
		Me.txtSchema.Name = "txtSchema"
		Me.txtSchema.Size = New System.Drawing.Size(104, 20)
		Me.txtSchema.TabIndex = 7
		Me.txtSchema.Text = "TextBox1"
		'
		'txtType
		'
		Me.txtType.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtType.Location = New System.Drawing.Point(240, 112)
		Me.txtType.Name = "txtType"
		Me.txtType.Size = New System.Drawing.Size(104, 20)
		Me.txtType.TabIndex = 8
		Me.txtType.Text = "TextBox2"
		'
		'Label5
		'
		Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label5.Font = New System.Drawing.Font("Microsoft Sans Serif", 14.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label5.Location = New System.Drawing.Point(216, 112)
		Me.Label5.Name = "Label5"
		Me.Label5.Size = New System.Drawing.Size(24, 23)
		Me.Label5.TabIndex = 9
		Me.Label5.Text = "."
		Me.Label5.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'Label6
		'
		Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label6.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label6.Location = New System.Drawing.Point(168, 160)
		Me.Label6.Name = "Label6"
		Me.Label6.Size = New System.Drawing.Size(16, 17)
		Me.Label6.TabIndex = 12
		Me.Label6.Text = "="
		Me.Label6.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand1B
		'
		Me.txtCommand1B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand1B.Location = New System.Drawing.Point(192, 160)
		Me.txtCommand1B.Name = "txtCommand1B"
		Me.txtCommand1B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand1B.TabIndex = 11
		Me.txtCommand1B.Text = ""
		'
		'txtCommand1A
		'
		Me.txtCommand1A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand1A.Location = New System.Drawing.Point(8, 160)
		Me.txtCommand1A.Name = "txtCommand1A"
		Me.txtCommand1A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand1A.TabIndex = 10
		Me.txtCommand1A.Text = ""
		'
		'Label7
		'
		Me.Label7.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label7.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label7.Location = New System.Drawing.Point(168, 184)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(16, 17)
		Me.Label7.TabIndex = 15
		Me.Label7.Text = "="
		Me.Label7.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand2B
		'
		Me.txtCommand2B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand2B.Location = New System.Drawing.Point(192, 184)
		Me.txtCommand2B.Name = "txtCommand2B"
		Me.txtCommand2B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand2B.TabIndex = 14
		Me.txtCommand2B.Text = ""
		'
		'txtCommand2A
		'
		Me.txtCommand2A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand2A.Location = New System.Drawing.Point(8, 184)
		Me.txtCommand2A.Name = "txtCommand2A"
		Me.txtCommand2A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand2A.TabIndex = 13
		Me.txtCommand2A.Text = ""
		'
		'Label8
		'
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label8.Location = New System.Drawing.Point(168, 208)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(16, 17)
		Me.Label8.TabIndex = 18
		Me.Label8.Text = "="
		Me.Label8.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand3B
		'
		Me.txtCommand3B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand3B.Location = New System.Drawing.Point(192, 208)
		Me.txtCommand3B.Name = "txtCommand3B"
		Me.txtCommand3B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand3B.TabIndex = 17
		Me.txtCommand3B.Text = ""
		'
		'txtCommand3A
		'
		Me.txtCommand3A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand3A.Location = New System.Drawing.Point(8, 208)
		Me.txtCommand3A.Name = "txtCommand3A"
		Me.txtCommand3A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand3A.TabIndex = 16
		Me.txtCommand3A.Text = ""
		'
		'Label9
		'
		Me.Label9.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label9.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label9.Location = New System.Drawing.Point(168, 232)
		Me.Label9.Name = "Label9"
		Me.Label9.Size = New System.Drawing.Size(16, 17)
		Me.Label9.TabIndex = 21
		Me.Label9.Text = "="
		Me.Label9.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand4B
		'
		Me.txtCommand4B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand4B.Location = New System.Drawing.Point(192, 232)
		Me.txtCommand4B.Name = "txtCommand4B"
		Me.txtCommand4B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand4B.TabIndex = 20
		Me.txtCommand4B.Text = ""
		'
		'txtCommand4A
		'
		Me.txtCommand4A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand4A.Location = New System.Drawing.Point(8, 232)
		Me.txtCommand4A.Name = "txtCommand4A"
		Me.txtCommand4A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand4A.TabIndex = 19
		Me.txtCommand4A.Text = ""
		'
		'Label10
		'
		Me.Label10.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label10.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label10.Location = New System.Drawing.Point(168, 256)
		Me.Label10.Name = "Label10"
		Me.Label10.Size = New System.Drawing.Size(16, 17)
		Me.Label10.TabIndex = 24
		Me.Label10.Text = "="
		Me.Label10.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand5B
		'
		Me.txtCommand5B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand5B.Location = New System.Drawing.Point(192, 256)
		Me.txtCommand5B.Name = "txtCommand5B"
		Me.txtCommand5B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand5B.TabIndex = 23
		Me.txtCommand5B.Text = ""
		'
		'txtCommand5A
		'
		Me.txtCommand5A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand5A.Location = New System.Drawing.Point(8, 256)
		Me.txtCommand5A.Name = "txtCommand5A"
		Me.txtCommand5A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand5A.TabIndex = 22
		Me.txtCommand5A.Text = ""
		'
		'Label11
		'
		Me.Label11.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label11.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label11.Location = New System.Drawing.Point(168, 280)
		Me.Label11.Name = "Label11"
		Me.Label11.Size = New System.Drawing.Size(16, 17)
		Me.Label11.TabIndex = 27
		Me.Label11.Text = "="
		Me.Label11.TextAlign = System.Drawing.ContentAlignment.TopCenter
		'
		'txtCommand6B
		'
		Me.txtCommand6B.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand6B.Location = New System.Drawing.Point(192, 280)
		Me.txtCommand6B.Name = "txtCommand6B"
		Me.txtCommand6B.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand6B.TabIndex = 26
		Me.txtCommand6B.Text = ""
		'
		'txtCommand6A
		'
		Me.txtCommand6A.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtCommand6A.Location = New System.Drawing.Point(8, 280)
		Me.txtCommand6A.Name = "txtCommand6A"
		Me.txtCommand6A.Size = New System.Drawing.Size(152, 20)
		Me.txtCommand6A.TabIndex = 25
		Me.txtCommand6A.Text = ""
		'
		'cmdSend
		'
		Me.cmdSend.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSend.Location = New System.Drawing.Point(96, 312)
		Me.cmdSend.Name = "cmdSend"
		Me.cmdSend.TabIndex = 28
		Me.cmdSend.Text = "&Send"
		'
		'cmdClear
		'
		Me.cmdClear.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdClear.Location = New System.Drawing.Point(184, 312)
		Me.cmdClear.Name = "cmdClear"
		Me.cmdClear.TabIndex = 29
		Me.cmdClear.Text = "&Clear"
		'
		'cmdExit
		'
		Me.cmdExit.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdExit.Location = New System.Drawing.Point(272, 312)
		Me.cmdExit.Name = "cmdExit"
		Me.cmdExit.TabIndex = 30
		Me.cmdExit.Text = "Close"
		'
		'txtSource
		'
		Me.txtSource.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSource.Location = New System.Drawing.Point(112, 64)
		Me.txtSource.Name = "txtSource"
		Me.txtSource.Size = New System.Drawing.Size(232, 20)
		Me.txtSource.TabIndex = 31
		Me.txtSource.Text = "TextBox1"
		'
		'frmSendRawXPL
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdExit
		Me.ClientSize = New System.Drawing.Size(360, 341)
		Me.Controls.Add(Me.txtSource)
		Me.Controls.Add(Me.cmdExit)
		Me.Controls.Add(Me.cmdClear)
		Me.Controls.Add(Me.cmdSend)
		Me.Controls.Add(Me.Label11)
		Me.Controls.Add(Me.txtCommand6B)
		Me.Controls.Add(Me.txtCommand6A)
		Me.Controls.Add(Me.Label10)
		Me.Controls.Add(Me.txtCommand5B)
		Me.Controls.Add(Me.txtCommand5A)
		Me.Controls.Add(Me.Label9)
		Me.Controls.Add(Me.txtCommand4B)
		Me.Controls.Add(Me.txtCommand4A)
		Me.Controls.Add(Me.Label8)
		Me.Controls.Add(Me.txtCommand3B)
		Me.Controls.Add(Me.txtCommand3A)
		Me.Controls.Add(Me.Label7)
		Me.Controls.Add(Me.txtCommand2B)
		Me.Controls.Add(Me.txtCommand2A)
		Me.Controls.Add(Me.Label6)
		Me.Controls.Add(Me.txtCommand1B)
		Me.Controls.Add(Me.txtCommand1A)
		Me.Controls.Add(Me.Label5)
		Me.Controls.Add(Me.txtType)
		Me.Controls.Add(Me.txtSchema)
		Me.Controls.Add(Me.Label4)
		Me.Controls.Add(Me.Label3)
		Me.Controls.Add(Me.Label2)
		Me.Controls.Add(Me.Label1)
		Me.Controls.Add(Me.cmbTarget)
		Me.Controls.Add(Me.cmbMessageType)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmSendRawXPL"
		Me.Text = "Send xPL Message"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub frmSendRawXPL_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        With cmbMessageType.Items
            .Add("Command (xpl-cmnd)")
            .Add("Trigger (xpl-trig)")
            .Add("Status (xpl-stat)")
        End With
    populateTargets(cmbTarget)
    cmbTarget.Items.Add("*")
        txtSource.Text = globals.XplHalSource


        cmbTarget.Text = "*"
        txtSchema.Text = ""
        txtType.Text = ""
    End Sub

    Private Sub cmbMessageType_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmbMessageType.SelectedIndexChanged

    End Sub

    Private Sub cmdSend_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdSend.Click
        If cmbMessageType.Text.Length < 3 Then
            MsgBox("Please select the type of message you wish to send.", vbInformation)
            cmbMessageType.Focus()
            Exit Sub
        End If
        Dim str As String
        connectToXplHal()
        xplHalSend("SENDXPLMSG" & vbCrLf)
        str = GetLine
        If str.StartsWith("313") Then
            Select Case cmbMessageType.Text.Substring(0, 3)
                Case "Com"
                    str = "xpl-cmnd"
                Case "Tri"
                    str = "xpl-trig"
                Case "Sta"
                    str = "xpl-stat"
            End Select
      str &= vbCrLf & "{" & vbCrLf & "hop=1" & vbCrLf & "source=" & txtSource.Text.ToLower.Trim & vbCrLf & "target=" & cmbTarget.Text.ToLower.Trim & vbCrLf & "}" & vbCrLf
      str &= txtSchema.Text.ToLower & "." & txtType.Text.ToLower & vbCrLf & "{" & vbCrLf

      str &= txtCommand1A.Text.ToLower & "=" & txtCommand1B.Text & vbCrLf
            If Not txtCommand2A.Text = "" Then
        str &= txtCommand2A.Text.ToLower & "=" & txtCommand2B.Text & vbCrLf
            End If
            If Not txtCommand3A.Text = "" Then
        str &= txtCommand3A.Text.ToLower & "=" & txtCommand3B.Text & vbCrLf
            End If
            If Not txtCommand4A.Text = "" Then
        str &= txtCommand4A.Text.ToLower & "=" & txtCommand4B.Text & vbCrLf
            End If
            If Not txtCommand5A.Text = "" Then
        str &= txtCommand5A.Text.ToLower & "=" & txtCommand5B.Text & vbCrLf
            End If
            If Not txtCommand6A.Text = "" Then
        str &= txtCommand6A.Text.ToLower & "=" & txtCommand6B.Text & vbCrLf
            End If
            str &= "}" & vbCrLf
            str &= "." & vbCrLf            
            xplHalSend(str)
            str = GetLine
            If Not str.StartsWith("213") Then
                globals.Unexpected(str)
            End If
        Else
            globals.Unexpected(str)
        End If
        Disconnect()
    End Sub

    Private Sub cmdExit_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdExit.Click
        Me.Close()
    End Sub


  Private Sub txtSchema_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtSchema.TextChanged

  End Sub

  Private Sub txtSchema_KeyPress(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles txtSchema.KeyPress
    If e.KeyChar = "." Then
      e.Handled = True
      txtType.Focus()
    End If
  End Sub
End Class
