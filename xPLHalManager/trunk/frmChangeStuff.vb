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

Public Class frmChangeStuff
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
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdExit As System.Windows.Forms.Button
    Friend WithEvents cmbStuffToChange As System.Windows.Forms.ComboBox
    Friend WithEvents lblStuff As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmChangeStuff))
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdExit = New System.Windows.Forms.Button
		Me.cmbStuffToChange = New System.Windows.Forms.ComboBox
		Me.lblStuff = New System.Windows.Forms.Label
		Me.SuspendLayout()
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(56, 90)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 1
		Me.cmdOK.Text = "OK"
		'
		'cmdExit
		'
		Me.cmdExit.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdExit.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdExit.Location = New System.Drawing.Point(144, 90)
		Me.cmdExit.Name = "cmdExit"
		Me.cmdExit.TabIndex = 2
		Me.cmdExit.Text = "Cancel"
		'
		'cmbStuffToChange
		'
		Me.cmbStuffToChange.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbStuffToChange.Location = New System.Drawing.Point(8, 56)
		Me.cmbStuffToChange.Name = "cmbStuffToChange"
		Me.cmbStuffToChange.Size = New System.Drawing.Size(216, 21)
		Me.cmbStuffToChange.TabIndex = 0
		'
		'lblStuff
		'
		Me.lblStuff.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblStuff.Location = New System.Drawing.Point(8, 16)
		Me.lblStuff.Name = "lblStuff"
		Me.lblStuff.Size = New System.Drawing.Size(216, 32)
		Me.lblStuff.TabIndex = 3
		Me.lblStuff.TextAlign = System.Drawing.ContentAlignment.BottomLeft
		'
		'frmChangeStuff
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdExit
		Me.ClientSize = New System.Drawing.Size(232, 127)
		Me.Controls.Add(Me.lblStuff)
		Me.Controls.Add(Me.cmbStuffToChange)
		Me.Controls.Add(Me.cmdExit)
		Me.Controls.Add(Me.cmdOK)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmChangeStuff"
		Me.Text = "Change Stuff"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private pSetting As String

    Public Property SettingName() As String
        Get
            Return pSetting
        End Get
        Set(ByVal Value As String)
            pSetting = Value
            Select Case pSetting.ToLower
                Case "mode"
                    Me.Text = "Change Mode"
                    lblStuff.Text = "Select a mode from the list"
                    For Counter As Integer = 0 To globals.Modes.Length - 1
                        cmbStuffToChange.Items.Add(globals.Modes(counter).Name)
                    Next
                Case "period"
                    Me.Text = "Change Period"
                    lblStuff.Text = "Select a period from the list"
                    For Counter As Integer = 0 To globals.Periods.Length - 1
                        cmbStuffToChange.Items.Add(globals.Periods(counter).Name)
                    Next
        Case ""
          Me.Text = "Select Value"
          lblStuff.Text = "Select an item from the list"
      End Select
      cmdOK.Enabled = False
        End Set
  End Property

  Public Property SettingValue() As String
    Get
      Return ""
    End Get
    Set(ByVal Value As String)
      For Counter As Integer = 0 To cmbStuffToChange.Items.Count - 1
        If cmbStuffToChange.Items(Counter).ToString = Value Then
          cmbStuffToChange.SelectedIndex = Counter
          Exit For
        End If
      Next
    End Set
  End Property


  Private Sub cmbStuffToChange_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbStuffToChange.SelectedIndexChanged
    cmdOK.Enabled = True
  End Sub

  Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        Me.DialogResult = Windows.Forms.DialogResult.OK
    Me.Close()
  End Sub
End Class