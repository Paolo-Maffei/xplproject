'************************************** 
'* xPLHal Windows Client
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

Public Class frmEditX10
    Inherits xplhalMgrBase

    Private DevAddr As String

    Public Property DeviceAddress() As String
        Get
            Return DevAddr
        End Get
        Set(ByVal Value As String)
            DevAddr = Value
            If Not DevAddr = "" Then
                GetDeviceInfo()
            Else
                Me.Text = "New X10 Device"
            End If
        End Set
    End Property

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
    Friend WithEvents txtLabel As System.Windows.Forms.TextBox
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents txtAddress As System.Windows.Forms.TextBox
    Friend WithEvents chkIsLight As System.Windows.Forms.CheckBox
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents ErrorProvider1 As System.Windows.Forms.ErrorProvider
    Friend WithEvents chkStatus As System.Windows.Forms.CheckBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditX10))
		Me.Label1 = New System.Windows.Forms.Label
		Me.txtLabel = New System.Windows.Forms.TextBox
		Me.cmdOK = New System.Windows.Forms.Button
		Me.Label2 = New System.Windows.Forms.Label
		Me.txtAddress = New System.Windows.Forms.TextBox
		Me.chkIsLight = New System.Windows.Forms.CheckBox
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.ErrorProvider1 = New System.Windows.Forms.ErrorProvider
		Me.chkStatus = New System.Windows.Forms.CheckBox
		Me.SuspendLayout()
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 8)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(80, 16)
		Me.Label1.TabIndex = 0
		Me.Label1.Text = "Device name:"
		'
		'txtLabel
		'
		Me.txtLabel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtLabel.Location = New System.Drawing.Point(96, 8)
		Me.txtLabel.Name = "txtLabel"
		Me.txtLabel.Size = New System.Drawing.Size(216, 20)
		Me.txtLabel.TabIndex = 0
		Me.txtLabel.Text = ""
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.Enabled = False
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(176, 128)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 4
		Me.cmdOK.Text = "OK"
		'
		'Label2
		'
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Location = New System.Drawing.Point(8, 40)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(80, 16)
		Me.Label2.TabIndex = 3
		Me.Label2.Text = "X10 Address:"
		'
		'txtAddress
		'
		Me.txtAddress.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtAddress.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper
		Me.txtAddress.Location = New System.Drawing.Point(96, 40)
		Me.txtAddress.MaxLength = 3
		Me.txtAddress.Name = "txtAddress"
		Me.txtAddress.Size = New System.Drawing.Size(48, 20)
		Me.txtAddress.TabIndex = 1
		Me.txtAddress.Text = ""
		'
		'chkIsLight
		'
		Me.chkIsLight.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkIsLight.Location = New System.Drawing.Point(96, 72)
		Me.chkIsLight.Name = "chkIsLight"
		Me.chkIsLight.Size = New System.Drawing.Size(144, 16)
		Me.chkIsLight.TabIndex = 2
		Me.chkIsLight.Text = "This device is a light"
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(264, 128)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 5
		Me.cmdCancel.Text = "Cancel"
		'
		'ErrorProvider1
		'
		Me.ErrorProvider1.ContainerControl = Me
		'
		'chkStatus
		'
		Me.chkStatus.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkStatus.Location = New System.Drawing.Point(96, 96)
		Me.chkStatus.Name = "chkStatus"
		Me.chkStatus.Size = New System.Drawing.Size(208, 16)
		Me.chkStatus.TabIndex = 3
		Me.chkStatus.Text = "This device can be polled for status"
		'
		'frmEditX10
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(344, 157)
		Me.Controls.Add(Me.chkStatus)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.chkIsLight)
		Me.Controls.Add(Me.txtAddress)
		Me.Controls.Add(Me.Label2)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.txtLabel)
		Me.Controls.Add(Me.Label1)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmEditX10"
		Me.Text = "Edit X10 Device"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub GetDeviceInfo()
        Dim str As String
        Dim lhs, rhs As String
        connectToXplHal()
        xplhalsend("GETX10DEVICE " & DevAddr & vbCrLf)
        str = getline
        If str.StartsWith("227") Then
            str = getLine
            While str <> ("." & vbCrLf) And str <> ""
                If str.IndexOf("=") > 0 Then
                    lhs = str.Substring(0, str.IndexOf("="))
                    rhs = str.Substring(str.IndexOf("=") + 1, str.Length - str.IndexOf("=") - 1).Replace(vbCrLf, "")
                    Select Case lhs.ToLower
                        Case "device"
                            txtAddress.Text = rhs
                        Case "islight"
                            If rhs.ToLower = "true" Or rhs = "1" Then
                                chkIsLight.Checked = True
                            Else
                                chkIsLight.Checked = False
                            End If
                        Case "label"
                            txtLabel.Text = rhs
                    End Select
                End If
                str = getLine
            End While
        End If
        disconnect()
    End Sub

    Private Sub cmdCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click

        'txtAddress_Validating(Nothing, Nothing)
        'txtLabel_Validating(Nothing, Nothing)
        If Not CheckErrors() Then
            SaveX10Info()
            Me.Close()
        End If
    End Sub

    Private Sub SaveX10Info()
        Try
            Dim str As String
            connectToXplHal()
            xplhalSend("ADDX10DEVICE" & vbCrLf)
            str = getLine
      If str.StartsWith("326") Then
        xplHalSend("device=" & txtAddress.Text & vbCrLf)
        xplHalSend("label=" & txtLabel.Text & vbCrLf)
        If chkIsLight.Checked Then
          xplHalSend("islight=true" & vbCrLf)
        Else
          xplHalSend("islight=false" & vbCrLf)
        End If
        xplHalSend("." & vbCrLf)
        str = getLine
        If Not str.StartsWith("226") Then
          globals.Unexpected(str)
        End If
      Else
        globals.Unexpected(str)
      End If
      Disconnect()
    Catch ex As Exception
            MsgBox("xPLHal Manager was unable to save the details of this X10 device." & vbCrLf & vbCrLf & "Please make sure that your xPLHal server is operational.", vbCritical, "xPLHal Manager")
        End Try
    End Sub

    Private Sub txtAddress_Validating(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles txtAddress.Validating
        Dim Address As String, Letter As String, I As Integer

        Address = txtAddress.Text
        If Address.Length > 1 Then
            If IsNumeric(Address.Substring(1, Address.Length - 1)) Then
                I = CInt(Address.Substring(1, Address.Length - 1))
            End If
            Letter = UCase(Address.Substring(0, 1))
            txtAddress.Text = Letter & I
            If Letter < "A" Or Letter > "P" Or I < 1 Or I > 16 Then
                ' Activate the error provider to notify the user of a
                ' problem.
                ErrorProvider1.SetError(txtAddress, "Not a valid X10 address.")
                'cmdOK.Enabled = False
            Else
                ' Clear the Error
                ErrorProvider1.SetError(txtAddress, "")
                'cmdOK.Enabled = True
            End If
        Else
            ErrorProvider1.SetError(txtAddress, "Not a valid X10 address.")
            'cmdOK.Enabled = False
        End If
        CheckErrors()
    End Sub

    Private Sub txtLabel_Validating(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles txtLabel.Validating

        Dim Str As String
        Str = txtLabel.Text
        If Str.Length < 1 Then
            ErrorProvider1.SetError(txtLabel, "Name must not be empty.")
            'cmdOK.Enabled = False
        Else
            ' Clear the Error
            ErrorProvider1.SetError(txtLabel, "")
            'Str = ErrorProvider1.GetError(txtAddress)
            'cmdOK.Enabled = True
        End If
        CheckErrors()
    End Sub
    Private Function CheckErrors() As Boolean
        ' returns true is an error exists and disables ok button
        If ErrorProvider1.GetError(txtAddress) & ErrorProvider1.GetError(txtLabel) = "" Then
            cmdOK.Enabled = True
            Return False
        Else
            cmdOK.Enabled = False
            Return True
        End If
    End Function

    'Private Sub frmEditX10_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

    'End Sub

    'Private Sub frmEditX10_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
    '    CheckErrors()
    '    If cmdOK.Enabled = False Then
    '        e.Cancel = True
    '    End If
    'End Sub

  Private Sub frmEditX10_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
    CheckErrors()
  End Sub
End Class
