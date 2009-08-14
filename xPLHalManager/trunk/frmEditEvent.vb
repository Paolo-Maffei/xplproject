'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2006 John Bent & Ian Jeffery
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

Public Class frmEditEvent
  Inherits xplhalMgrBase

  Private IsDirty As Boolean
  Private evName As String
  Private evSub As String
  Private evDet As String

  Public IsRecurring As Boolean

  Public Property EventName() As String
    Get
      Return evName
    End Get
    Set(ByVal Value As String)
      evName = Value
      If evName = "" Then
        Me.Text = "Create New Event"
      Else
        Me.Text = "Edit Event " & evName
        GetEventInfo()
      End If
      IsDirty = False
      'If Not IsRecurring Then
      '  grpDays.Visible = False
      '  Me.dtpStartTime.CustomFormat = "ddd d MMM yyyy HH:mm"
      'Else
      '  Me.dtpStartTime.CustomFormat = "HH:mm"
      'End If
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
  Friend WithEvents txtEventName As System.Windows.Forms.TextBox
  Friend WithEvents Label1 As System.Windows.Forms.Label
  Friend WithEvents cmdOK As System.Windows.Forms.Button
  Friend WithEvents cmdCancel As System.Windows.Forms.Button
  Friend WithEvents txtParams As System.Windows.Forms.TextBox
  Friend WithEvents cmbSubs As System.Windows.Forms.ComboBox
  Friend WithEvents Label2 As System.Windows.Forms.Label
  Friend WithEvents dtpStartTime As System.Windows.Forms.DateTimePicker
  Friend WithEvents dtpEndTime As System.Windows.Forms.DateTimePicker
  Friend WithEvents Label7 As System.Windows.Forms.Label
  Friend WithEvents chkSunday As System.Windows.Forms.CheckBox
  Friend WithEvents chkSaturday As System.Windows.Forms.CheckBox
  Friend WithEvents chkFriday As System.Windows.Forms.CheckBox
  Friend WithEvents chkThursday As System.Windows.Forms.CheckBox
  Friend WithEvents chkWednesday As System.Windows.Forms.CheckBox
  Friend WithEvents chkTuesday As System.Windows.Forms.CheckBox
  Friend WithEvents chkMonday As System.Windows.Forms.CheckBox
  Friend WithEvents nudInterval As System.Windows.Forms.NumericUpDown
  Friend WithEvents grpDays As System.Windows.Forms.GroupBox
  Friend WithEvents Label9 As System.Windows.Forms.Label
  Friend WithEvents Label8 As System.Windows.Forms.Label
  Friend WithEvents radDeterminator As System.Windows.Forms.RadioButton
  Friend WithEvents radSubroutine As System.Windows.Forms.RadioButton
  Friend WithEvents grpSubroutine As System.Windows.Forms.GroupBox
  Friend WithEvents grpDeterminator As System.Windows.Forms.GroupBox
  Friend WithEvents cmbDeterminators As System.Windows.Forms.ComboBox
  Friend WithEvents lblStartTime As System.Windows.Forms.Label
  Friend WithEvents lblInterval As System.Windows.Forms.Label
  Friend WithEvents lblRandomisation As System.Windows.Forms.Label
  Friend WithEvents lblEndTime As System.Windows.Forms.Label
  Friend WithEvents nudRandomise As System.Windows.Forms.NumericUpDown
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditEvent))
		Me.txtEventName = New System.Windows.Forms.TextBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.txtParams = New System.Windows.Forms.TextBox
		Me.cmbSubs = New System.Windows.Forms.ComboBox
		Me.Label2 = New System.Windows.Forms.Label
		Me.dtpStartTime = New System.Windows.Forms.DateTimePicker
		Me.lblStartTime = New System.Windows.Forms.Label
		Me.lblInterval = New System.Windows.Forms.Label
		Me.dtpEndTime = New System.Windows.Forms.DateTimePicker
		Me.nudInterval = New System.Windows.Forms.NumericUpDown
		Me.nudRandomise = New System.Windows.Forms.NumericUpDown
		Me.lblRandomisation = New System.Windows.Forms.Label
		Me.lblEndTime = New System.Windows.Forms.Label
		Me.Label7 = New System.Windows.Forms.Label
		Me.grpDays = New System.Windows.Forms.GroupBox
		Me.chkMonday = New System.Windows.Forms.CheckBox
		Me.chkTuesday = New System.Windows.Forms.CheckBox
		Me.chkWednesday = New System.Windows.Forms.CheckBox
		Me.chkThursday = New System.Windows.Forms.CheckBox
		Me.chkFriday = New System.Windows.Forms.CheckBox
		Me.chkSaturday = New System.Windows.Forms.CheckBox
		Me.chkSunday = New System.Windows.Forms.CheckBox
		Me.grpSubroutine = New System.Windows.Forms.GroupBox
		Me.grpDeterminator = New System.Windows.Forms.GroupBox
		Me.cmbDeterminators = New System.Windows.Forms.ComboBox
		Me.Label9 = New System.Windows.Forms.Label
		Me.radDeterminator = New System.Windows.Forms.RadioButton
		Me.radSubroutine = New System.Windows.Forms.RadioButton
		Me.Label8 = New System.Windows.Forms.Label
		CType(Me.nudInterval, System.ComponentModel.ISupportInitialize).BeginInit()
		CType(Me.nudRandomise, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.grpDays.SuspendLayout()
		Me.grpSubroutine.SuspendLayout()
		Me.grpDeterminator.SuspendLayout()
		Me.SuspendLayout()
		'
		'txtEventName
		'
		Me.txtEventName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtEventName.Location = New System.Drawing.Point(128, 16)
		Me.txtEventName.Name = "txtEventName"
		Me.txtEventName.Size = New System.Drawing.Size(200, 20)
		Me.txtEventName.TabIndex = 0
		Me.txtEventName.Text = "txtEventName"
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(16, 16)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(100, 16)
		Me.Label1.TabIndex = 1
		Me.Label1.Text = "Event Name:"
		'
		'cmdOK
		'
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(368, 360)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 14
		Me.cmdOK.Text = "OK"
		'
		'cmdCancel
		'
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(472, 360)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 15
		Me.cmdCancel.Text = "Cancel"
		'
		'txtParams
		'
		Me.txtParams.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtParams.Location = New System.Drawing.Point(184, 40)
		Me.txtParams.Name = "txtParams"
		Me.txtParams.Size = New System.Drawing.Size(328, 20)
		Me.txtParams.TabIndex = 2
		Me.txtParams.Text = ""
		'
		'cmbSubs
		'
		Me.cmbSubs.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbSubs.Location = New System.Drawing.Point(8, 40)
		Me.cmbSubs.Name = "cmbSubs"
		Me.cmbSubs.Size = New System.Drawing.Size(168, 21)
		Me.cmbSubs.TabIndex = 1
		'
		'Label2
		'
		Me.Label2.Location = New System.Drawing.Point(8, 24)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(100, 16)
		Me.Label2.TabIndex = 6
		Me.Label2.Text = "Sub Routine:"
		'
		'dtpStartTime
		'
		Me.dtpStartTime.Format = System.Windows.Forms.DateTimePickerFormat.Custom
		Me.dtpStartTime.Location = New System.Drawing.Point(16, 216)
		Me.dtpStartTime.Name = "dtpStartTime"
		Me.dtpStartTime.ShowUpDown = True
		Me.dtpStartTime.Size = New System.Drawing.Size(168, 20)
		Me.dtpStartTime.TabIndex = 3
		'
		'lblStartTime
		'
		Me.lblStartTime.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblStartTime.Location = New System.Drawing.Point(16, 200)
		Me.lblStartTime.Name = "lblStartTime"
		Me.lblStartTime.Size = New System.Drawing.Size(100, 16)
		Me.lblStartTime.TabIndex = 9
		Me.lblStartTime.Text = "Start Time:"
		'
		'lblInterval
		'
		Me.lblInterval.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblInterval.Location = New System.Drawing.Point(16, 248)
		Me.lblInterval.Name = "lblInterval"
		Me.lblInterval.Size = New System.Drawing.Size(100, 16)
		Me.lblInterval.TabIndex = 10
		Me.lblInterval.Text = "Interval:"
		'
		'dtpEndTime
		'
		Me.dtpEndTime.Location = New System.Drawing.Point(200, 216)
		Me.dtpEndTime.Name = "dtpEndTime"
		Me.dtpEndTime.ShowUpDown = True
		Me.dtpEndTime.Size = New System.Drawing.Size(168, 20)
		Me.dtpEndTime.TabIndex = 4
		'
		'nudInterval
		'
		Me.nudInterval.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.nudInterval.Location = New System.Drawing.Point(16, 264)
		Me.nudInterval.Maximum = New Decimal(New Integer() {1440, 0, 0, 0})
		Me.nudInterval.Name = "nudInterval"
		Me.nudInterval.Size = New System.Drawing.Size(88, 20)
		Me.nudInterval.TabIndex = 5
		'
		'nudRandomise
		'
		Me.nudRandomise.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.nudRandomise.Location = New System.Drawing.Point(200, 264)
		Me.nudRandomise.Maximum = New Decimal(New Integer() {60, 0, 0, 0})
		Me.nudRandomise.Name = "nudRandomise"
		Me.nudRandomise.Size = New System.Drawing.Size(88, 20)
		Me.nudRandomise.TabIndex = 6
		'
		'lblRandomisation
		'
		Me.lblRandomisation.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblRandomisation.Location = New System.Drawing.Point(200, 248)
		Me.lblRandomisation.Name = "lblRandomisation"
		Me.lblRandomisation.Size = New System.Drawing.Size(100, 16)
		Me.lblRandomisation.TabIndex = 16
		Me.lblRandomisation.Text = "Randomisation:"
		'
		'lblEndTime
		'
		Me.lblEndTime.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblEndTime.Location = New System.Drawing.Point(200, 200)
		Me.lblEndTime.Name = "lblEndTime"
		Me.lblEndTime.Size = New System.Drawing.Size(100, 16)
		Me.lblEndTime.TabIndex = 15
		Me.lblEndTime.Text = "End Time:"
		'
		'Label7
		'
		Me.Label7.Location = New System.Drawing.Point(184, 24)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(200, 16)
		Me.Label7.TabIndex = 14
		Me.Label7.Text = "Sub Routine Parameters:"
		'
		'grpDays
		'
		Me.grpDays.Controls.Add(Me.chkMonday)
		Me.grpDays.Controls.Add(Me.chkTuesday)
		Me.grpDays.Controls.Add(Me.chkWednesday)
		Me.grpDays.Controls.Add(Me.chkThursday)
		Me.grpDays.Controls.Add(Me.chkFriday)
		Me.grpDays.Controls.Add(Me.chkSaturday)
		Me.grpDays.Controls.Add(Me.chkSunday)
		Me.grpDays.Location = New System.Drawing.Point(376, 208)
		Me.grpDays.Name = "grpDays"
		Me.grpDays.Size = New System.Drawing.Size(168, 144)
		Me.grpDays.TabIndex = 17
		Me.grpDays.TabStop = False
		Me.grpDays.Text = "Execute on these days only"
		'
		'chkMonday
		'
		Me.chkMonday.Checked = True
		Me.chkMonday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkMonday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkMonday.Location = New System.Drawing.Point(16, 40)
		Me.chkMonday.Name = "chkMonday"
		Me.chkMonday.Size = New System.Drawing.Size(128, 16)
		Me.chkMonday.TabIndex = 8
		Me.chkMonday.Text = "Monday"
		'
		'chkTuesday
		'
		Me.chkTuesday.Checked = True
		Me.chkTuesday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkTuesday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkTuesday.Location = New System.Drawing.Point(16, 56)
		Me.chkTuesday.Name = "chkTuesday"
		Me.chkTuesday.Size = New System.Drawing.Size(128, 16)
		Me.chkTuesday.TabIndex = 9
		Me.chkTuesday.Text = "Tuesday"
		'
		'chkWednesday
		'
		Me.chkWednesday.Checked = True
		Me.chkWednesday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkWednesday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkWednesday.Location = New System.Drawing.Point(16, 72)
		Me.chkWednesday.Name = "chkWednesday"
		Me.chkWednesday.Size = New System.Drawing.Size(128, 16)
		Me.chkWednesday.TabIndex = 10
		Me.chkWednesday.Text = "Wednesday"
		'
		'chkThursday
		'
		Me.chkThursday.Checked = True
		Me.chkThursday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkThursday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkThursday.Location = New System.Drawing.Point(16, 88)
		Me.chkThursday.Name = "chkThursday"
		Me.chkThursday.Size = New System.Drawing.Size(128, 16)
		Me.chkThursday.TabIndex = 11
		Me.chkThursday.Text = "Thursday"
		'
		'chkFriday
		'
		Me.chkFriday.Checked = True
		Me.chkFriday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkFriday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkFriday.Location = New System.Drawing.Point(16, 104)
		Me.chkFriday.Name = "chkFriday"
		Me.chkFriday.Size = New System.Drawing.Size(128, 16)
		Me.chkFriday.TabIndex = 12
		Me.chkFriday.Text = "Friday"
		'
		'chkSaturday
		'
		Me.chkSaturday.Checked = True
		Me.chkSaturday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkSaturday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkSaturday.Location = New System.Drawing.Point(16, 120)
		Me.chkSaturday.Name = "chkSaturday"
		Me.chkSaturday.Size = New System.Drawing.Size(128, 16)
		Me.chkSaturday.TabIndex = 13
		Me.chkSaturday.Text = "Saturday"
		'
		'chkSunday
		'
		Me.chkSunday.Checked = True
		Me.chkSunday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkSunday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkSunday.Location = New System.Drawing.Point(16, 24)
		Me.chkSunday.Name = "chkSunday"
		Me.chkSunday.Size = New System.Drawing.Size(128, 16)
		Me.chkSunday.TabIndex = 7
		Me.chkSunday.Text = "Sunday"
		'
		'grpSubroutine
		'
		Me.grpSubroutine.Controls.Add(Me.Label7)
		Me.grpSubroutine.Controls.Add(Me.txtParams)
		Me.grpSubroutine.Controls.Add(Me.cmbSubs)
		Me.grpSubroutine.Controls.Add(Me.Label2)
		Me.grpSubroutine.Location = New System.Drawing.Point(16, 112)
		Me.grpSubroutine.Name = "grpSubroutine"
		Me.grpSubroutine.Size = New System.Drawing.Size(528, 72)
		Me.grpSubroutine.TabIndex = 18
		Me.grpSubroutine.TabStop = False
		Me.grpSubroutine.Text = "Run Subroutine"
		'
		'grpDeterminator
		'
		Me.grpDeterminator.Controls.Add(Me.cmbDeterminators)
		Me.grpDeterminator.Controls.Add(Me.Label9)
		Me.grpDeterminator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpDeterminator.Location = New System.Drawing.Point(16, 112)
		Me.grpDeterminator.Name = "grpDeterminator"
		Me.grpDeterminator.Size = New System.Drawing.Size(528, 72)
		Me.grpDeterminator.TabIndex = 19
		Me.grpDeterminator.TabStop = False
		Me.grpDeterminator.Text = "Run Determinator"
		'
		'cmbDeterminators
		'
		Me.cmbDeterminators.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbDeterminators.Location = New System.Drawing.Point(8, 40)
		Me.cmbDeterminators.Name = "cmbDeterminators"
    Me.cmbDeterminators.Size = New System.Drawing.Size(350, 21)
    Me.cmbDeterminators.Sorted = True
		Me.cmbDeterminators.TabIndex = 1
		'
		'Label9
		'
		Me.Label9.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label9.Location = New System.Drawing.Point(8, 24)
		Me.Label9.Name = "Label9"
		Me.Label9.Size = New System.Drawing.Size(100, 16)
		Me.Label9.TabIndex = 6
		Me.Label9.Text = "Determinator:"
		'
		'radDeterminator
		'
		Me.radDeterminator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radDeterminator.Location = New System.Drawing.Point(16, 64)
		Me.radDeterminator.Name = "radDeterminator"
		Me.radDeterminator.Size = New System.Drawing.Size(104, 16)
		Me.radDeterminator.TabIndex = 20
		Me.radDeterminator.Text = "Determinator"
		'
		'radSubroutine
		'
		Me.radSubroutine.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radSubroutine.Location = New System.Drawing.Point(16, 80)
		Me.radSubroutine.Name = "radSubroutine"
		Me.radSubroutine.Size = New System.Drawing.Size(104, 16)
		Me.radSubroutine.TabIndex = 21
		Me.radSubroutine.Text = "Subroutine."
		'
		'Label8
		'
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Location = New System.Drawing.Point(16, 48)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(320, 16)
		Me.Label8.TabIndex = 22
		Me.Label8.Text = "This event will run a:"
		'
		'frmEditEvent
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(554, 391)
		Me.Controls.Add(Me.Label8)
		Me.Controls.Add(Me.radSubroutine)
		Me.Controls.Add(Me.radDeterminator)
		Me.Controls.Add(Me.grpDeterminator)
		Me.Controls.Add(Me.grpSubroutine)
		Me.Controls.Add(Me.grpDays)
		Me.Controls.Add(Me.lblRandomisation)
		Me.Controls.Add(Me.lblEndTime)
		Me.Controls.Add(Me.nudRandomise)
		Me.Controls.Add(Me.nudInterval)
		Me.Controls.Add(Me.dtpEndTime)
		Me.Controls.Add(Me.lblInterval)
		Me.Controls.Add(Me.lblStartTime)
		Me.Controls.Add(Me.dtpStartTime)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.Label1)
		Me.Controls.Add(Me.txtEventName)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmEditEvent"
		Me.Text = "EditEvent"
		CType(Me.nudInterval, System.ComponentModel.ISupportInitialize).EndInit()
		CType(Me.nudRandomise, System.ComponentModel.ISupportInitialize).EndInit()
		Me.grpDays.ResumeLayout(False)
		Me.grpSubroutine.ResumeLayout(False)
		Me.grpDeterminator.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region

  Private Sub GetEventInfo()
    Dim str As String
    Dim lhs, rhs As String
    evSub = ""
    connectToXplHal()
    xplhalsend("GETEVENT " & evName & vbCrLf)
    str = getLine
    If str.StartsWith("222") Then
      str = getLine
      While str <> ("." & vbCrLf) And str <> ""
        If str.IndexOf("=") > 0 Then
          lhs = str.Substring(0, str.IndexOf("="))
          rhs = str.Substring(str.IndexOf("=") + 1, str.Length - str.IndexOf("=") - 1).Replace(vbCrLf, "")
          Select Case lhs.ToLower
            Case "dow"
              If rhs.Length = 7 Then
                If rhs.Substring(0, 1) = "Y" Or rhs.Substring(0, 1) = "1" Then
                  chkSunday.Checked = True
                Else
                  chkSunday.Checked = False
                End If
                If rhs.Substring(1, 1) = "Y" Or rhs.Substring(1, 1) = "1" Then
                  chkMonday.Checked = True
                Else
                  chkMonday.Checked = False
                End If
                If rhs.Substring(2, 1) = "Y" Or rhs.Substring(2, 1) = "1" Then
                  chkTuesday.Checked = True
                Else
                  chkTuesday.Checked = False
                End If
                If rhs.Substring(3, 1) = "Y" Or rhs.Substring(3, 1) = "1" Then
                  chkWednesday.Checked = True
                Else
                  chkWednesday.Checked = False
                End If
                If rhs.Substring(4, 1) = "Y" Or rhs.Substring(4, 1) = "1" Then
                  chkThursday.Checked = True
                Else
                  chkThursday.Checked = False
                End If
                If rhs.Substring(5, 1) = "Y" Or rhs.Substring(5, 1) = "1" Then
                  chkFriday.Checked = True
                Else
                  chkFriday.Checked = False
                End If
                If rhs.Substring(6, 1) = "Y" Or rhs.Substring(6, 1) = "1" Then
                  chkSaturday.Checked = True
                Else
                  chkSaturday.Checked = False
                End If
              Else
                MsgBox("Invalid DOW length.")
              End If
            Case "date"
              dtpStartTime.Format = DateTimePickerFormat.Custom
              dtpStartTime.CustomFormat = "ddd d MMM yyyy HH:mm"
              Me.dtpStartTime.Value = CDate(rhs)
              Me.dtpEndTime.Visible = False
              Me.nudInterval.Visible = False
              lblStartTime.Text = "Date/time"
              nudRandomise.Visible = False
              lblEndTime.Visible = False
              lblInterval.Visible = False
              lblRandomisation.Visible = False
              grpDays.Visible = False
            Case "endtime"
              Me.dtpEndTime.Value = DateTime.Today.AddHours(CInt(rhs.Substring(0, 2))).AddMinutes(CInt(rhs.Substring(3, 2)))
            Case "starttime"
              dtpStartTime.CustomFormat = "HH:mm"
              Me.dtpStartTime.Value = DateTime.Today.AddHours(CInt(rhs.Substring(0, 2))).AddMinutes(CInt(rhs.Substring(3, 2)))
            Case "subname"
              evSub = rhs
            Case "params"
              txtParams.Text = rhs
              cmbDeterminators.Text = rhs
              evDet = rhs
            Case "tag"
              txtEventName.Text = rhs
            Case "interval"
              nudInterval.Text = rhs
            Case "rand"
              nudRandomise.Text = rhs
          End Select
          If evSub.ToLower <> "{determinator}" Then
            evDet = ""
          End If
        End If
        str = getLine
      End While
    Else
      globals.Unexpected(str)
    End If

        Disconnect()
        If evSub = "{determinator}" Then
      radDeterminator.Checked = True
      cmbDeterminators.Text = txtParams.Text      
    Else
      radSubroutine.Checked = True
    End If
  End Sub

  Private Sub cmdCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
    If IsDirty Then
            If MsgBox(My.Resources.RES_EVENT_SAVE_CHANGES, vbQuestion Or vbYesNo) = vbYes Then
                SaveEvent()
            End If
        End If
        Me.Close()
    End Sub

    Private Function SaveEvent() As Boolean
        Dim str As String

        ' Validate user input
        If txtEventName.Text = "" Then
            MsgBox(My.Resources.RES_EVENT_ENTER_NAME, vbExclamation)
            Return False
        End If
        If Not radDeterminator.Checked And cmbSubs.Text = "" Then
            MsgBox(My.Resources.RES_MUST_SELECT_SUB, vbExclamation)
            Return False
        End If

        ConnectToXplHal()
        If radDeterminator.Checked Then

        End If
        xplHalSend("ADDEVENT" & vbCrLf)
        str = GetLine()
        If str.StartsWith("319") Then
            xplHalSend("tag=" & txtEventName.Text & vbCrLf)
            If IsRecurring Then
                xplHalSend("starttime=" & dtpStartTime.Value.ToString("HH:mm:ss") & vbCrLf)
                xplHalSend("endtime=" & dtpEndTime.Value.ToString("HH:mm:ss") & vbCrLf)
                xplHalSend("interval=" & nudInterval.Text & vbCrLf)
                xplHalSend("rand=" & nudRandomise.Text & vbCrLf)

                ' Determine on which days to execute        
                If chkSunday.Checked Then
                    str = "1"
                Else
                    str = "0"
                End If
                If chkMonday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                If chkTuesday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                If chkWednesday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                If chkThursday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                If chkFriday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                If chkSaturday.Checked Then
                    str &= "1"
                Else
                    str &= "0"
                End If
                xplHalSend("dow=" & str & vbCrLf)
            Else
                xplHalSend("date=" & dtpStartTime.Value.ToString("dd/MMM/yyyy HH:mm") & vbCrLf)
            End If
            If radDeterminator.Checked Then
                xplHalSend("subname={determinator}" & vbCrLf)
                xplHalSend("params=" & cmbDeterminators.Text & vbCrLf)
            Else
                xplHalSend("subname=" & cmbSubs.Text & vbCrLf)
                xplHalSend("params=" & txtParams.Text & vbCrLf)
            End If

            xplHalSend("." & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("219") Then
                globals.Unexpected(str)
            End If
        Else
            globals.Unexpected(str)
        End If
        Disconnect()
        Return True
    End Function



  Private Sub frmEditEvent_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    Me.dtpStartTime.Format = DateTimePickerFormat.Custom
    Me.dtpEndTime.MaxDate = DateTime.Today.AddHours(24)
    Me.dtpEndTime.MinDate = DateTime.Today
    Me.dtpEndTime.Format = DateTimePickerFormat.Custom
    Me.dtpEndTime.CustomFormat = "HH:mm"
    PopulateSubs(cmbSubs)
    populateDeterminators(cmbDeterminators)
    cmbSubs.Text = evSub
    cmbDeterminators.Text = evDet
  End Sub

  Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
    If SaveEvent() Then
      Me.Close()
    End If
  End Sub

  Private Sub radDeterminator_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radDeterminator.CheckedChanged, radSubroutine.CheckedChanged
    If radDeterminator.Checked Then
      grpDeterminator.Visible = True
      grpSubroutine.Visible = False
      cmbDeterminators.Text = ""
    Else
      grpDeterminator.Visible = False
      grpSubroutine.Visible = True
      txtParams.Text = ""
    End If
  End Sub


End Class
