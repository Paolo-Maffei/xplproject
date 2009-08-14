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

 Public Class frmEventWizard
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
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents lblTitle As System.Windows.Forms.Label
    Friend WithEvents lblDescription As System.Windows.Forms.Label
  Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdBack As System.Windows.Forms.Button
    Friend WithEvents cmdNext As System.Windows.Forms.Button
    Friend WithEvents grpEventType As System.Windows.Forms.GroupBox
  Friend WithEvents grpDays As System.Windows.Forms.GroupBox
    Friend WithEvents chkMonday As System.Windows.Forms.CheckBox
    Friend WithEvents chkTuesday As System.Windows.Forms.CheckBox
    Friend WithEvents chkWednesday As System.Windows.Forms.CheckBox
    Friend WithEvents chkThursday As System.Windows.Forms.CheckBox
    Friend WithEvents chkFriday As System.Windows.Forms.CheckBox
    Friend WithEvents chkSaturday As System.Windows.Forms.CheckBox
    Friend WithEvents chkSunday As System.Windows.Forms.CheckBox
  Friend WithEvents cmbSubs As System.Windows.Forms.ComboBox
    Friend WithEvents txtParams As System.Windows.Forms.TextBox
    Friend WithEvents txtFinish As System.Windows.Forms.TextBox
	Friend WithEvents cmdSelectAllDays As System.Windows.Forms.Button
    Friend WithEvents cmdSelectWeekend As System.Windows.Forms.Button
    Friend WithEvents cmdSelectWeekdays As System.Windows.Forms.Button
  Friend WithEvents Label1 As System.Windows.Forms.Label
  Friend WithEvents Label2 As System.Windows.Forms.Label
  Friend WithEvents Label3 As System.Windows.Forms.Label
  Friend WithEvents Label4 As System.Windows.Forms.Label
  Friend WithEvents Label5 As System.Windows.Forms.Label
  Friend WithEvents Label7 As System.Windows.Forms.Label
  Friend WithEvents Panel2 As System.Windows.Forms.Panel
  Friend WithEvents RadRecurring As System.Windows.Forms.RadioButton
  Friend WithEvents RadSingle As System.Windows.Forms.RadioButton
  Friend WithEvents Label10 As System.Windows.Forms.Label
  Friend WithEvents Label8 As System.Windows.Forms.Label
  Friend WithEvents txtName As System.Windows.Forms.TextBox
  Friend WithEvents Label9 As System.Windows.Forms.Label
  Friend WithEvents RadRepeating As System.Windows.Forms.RadioButton
  Friend WithEvents Label11 As System.Windows.Forms.Label
  Friend WithEvents Label12 As System.Windows.Forms.Label
  Friend WithEvents lblCombo As System.Windows.Forms.Label
  Friend WithEvents Label16 As System.Windows.Forms.Label
  Friend WithEvents Page1 As System.Windows.Forms.Panel
  Friend WithEvents Page4 As System.Windows.Forms.Panel
  Friend WithEvents Page3 As System.Windows.Forms.Panel
  Friend WithEvents Page2 As System.Windows.Forms.Panel
  Friend WithEvents Page8 As System.Windows.Forms.Panel
  Friend WithEvents Page6 As System.Windows.Forms.Panel
  Friend WithEvents Page5 As System.Windows.Forms.Panel
  Friend WithEvents Page7 As System.Windows.Forms.Panel
  Friend WithEvents nudInterval As System.Windows.Forms.NumericUpDown
  Friend WithEvents nudRandom As System.Windows.Forms.NumericUpDown
  Friend WithEvents dtpStartTime As System.Windows.Forms.DateTimePicker
  Friend WithEvents dtpEndTime As System.Windows.Forms.DateTimePicker
  Friend WithEvents grpSubroutine As System.Windows.Forms.GroupBox
	Friend WithEvents radDeterminator As System.Windows.Forms.RadioButton
  Friend WithEvents radSubroutine As System.Windows.Forms.RadioButton
  Friend WithEvents txtDescription As System.Windows.Forms.TextBox
  Friend WithEvents lblTimes As System.Windows.Forms.Label
  Friend WithEvents lblEndTime As System.Windows.Forms.Label
  Friend WithEvents lblInterval As System.Windows.Forms.Label
  Friend WithEvents lblStartTime As System.Windows.Forms.Label
  Friend WithEvents grpRun As System.Windows.Forms.GroupBox
  Friend WithEvents cmdAllDay As System.Windows.Forms.Button
  Friend WithEvents Label6 As System.Windows.Forms.Label
	Friend WithEvents grpDeterminator As System.Windows.Forms.GroupBox
	Friend WithEvents cmdNewDeterminator As System.Windows.Forms.Button
	Friend WithEvents cmbDeterminators As System.Windows.Forms.ComboBox
	Friend WithEvents Label13 As System.Windows.Forms.Label
	<System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEventWizard))
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdBack = New System.Windows.Forms.Button
		Me.cmdNext = New System.Windows.Forms.Button
		Me.grpEventType = New System.Windows.Forms.GroupBox
		Me.RadRepeating = New System.Windows.Forms.RadioButton
		Me.RadRecurring = New System.Windows.Forms.RadioButton
		Me.RadSingle = New System.Windows.Forms.RadioButton
		Me.lblStartTime = New System.Windows.Forms.Label
		Me.dtpStartTime = New System.Windows.Forms.DateTimePicker
		Me.nudInterval = New System.Windows.Forms.NumericUpDown
		Me.grpDays = New System.Windows.Forms.GroupBox
		Me.cmdSelectWeekend = New System.Windows.Forms.Button
		Me.cmdSelectWeekdays = New System.Windows.Forms.Button
		Me.cmdSelectAllDays = New System.Windows.Forms.Button
		Me.chkMonday = New System.Windows.Forms.CheckBox
		Me.chkTuesday = New System.Windows.Forms.CheckBox
		Me.chkWednesday = New System.Windows.Forms.CheckBox
		Me.chkThursday = New System.Windows.Forms.CheckBox
		Me.chkFriday = New System.Windows.Forms.CheckBox
		Me.chkSaturday = New System.Windows.Forms.CheckBox
		Me.chkSunday = New System.Windows.Forms.CheckBox
		Me.cmbSubs = New System.Windows.Forms.ComboBox
		Me.txtParams = New System.Windows.Forms.TextBox
		Me.txtFinish = New System.Windows.Forms.TextBox
		Me.Page1 = New System.Windows.Forms.Panel
		Me.Label6 = New System.Windows.Forms.Label
		Me.Label1 = New System.Windows.Forms.Label
		Me.Page4 = New System.Windows.Forms.Panel
		Me.grpDeterminator = New System.Windows.Forms.GroupBox
		Me.cmdNewDeterminator = New System.Windows.Forms.Button
		Me.cmbDeterminators = New System.Windows.Forms.ComboBox
		Me.Label13 = New System.Windows.Forms.Label
		Me.grpRun = New System.Windows.Forms.GroupBox
		Me.radDeterminator = New System.Windows.Forms.RadioButton
		Me.radSubroutine = New System.Windows.Forms.RadioButton
		Me.Label4 = New System.Windows.Forms.Label
		Me.grpSubroutine = New System.Windows.Forms.GroupBox
		Me.Label12 = New System.Windows.Forms.Label
		Me.lblCombo = New System.Windows.Forms.Label
		Me.Page3 = New System.Windows.Forms.Panel
		Me.Label11 = New System.Windows.Forms.Label
		Me.txtDescription = New System.Windows.Forms.TextBox
		Me.Label3 = New System.Windows.Forms.Label
		Me.Page2 = New System.Windows.Forms.Panel
		Me.Label9 = New System.Windows.Forms.Label
		Me.txtName = New System.Windows.Forms.TextBox
		Me.Label2 = New System.Windows.Forms.Label
		Me.Page8 = New System.Windows.Forms.Panel
		Me.Label5 = New System.Windows.Forms.Label
		Me.Page6 = New System.Windows.Forms.Panel
		Me.nudRandom = New System.Windows.Forms.NumericUpDown
		Me.Label16 = New System.Windows.Forms.Label
		Me.Label7 = New System.Windows.Forms.Label
		Me.Page5 = New System.Windows.Forms.Panel
		Me.cmdAllDay = New System.Windows.Forms.Button
		Me.lblEndTime = New System.Windows.Forms.Label
		Me.dtpEndTime = New System.Windows.Forms.DateTimePicker
		Me.lblInterval = New System.Windows.Forms.Label
		Me.lblTimes = New System.Windows.Forms.Label
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.Label10 = New System.Windows.Forms.Label
		Me.PictureBox1 = New System.Windows.Forms.PictureBox
		Me.Page7 = New System.Windows.Forms.Panel
		Me.Label8 = New System.Windows.Forms.Label
		Me.grpEventType.SuspendLayout()
		CType(Me.nudInterval, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.grpDays.SuspendLayout()
		Me.Page1.SuspendLayout()
		Me.Page4.SuspendLayout()
		Me.grpDeterminator.SuspendLayout()
		Me.grpRun.SuspendLayout()
		Me.grpSubroutine.SuspendLayout()
		Me.Page3.SuspendLayout()
		Me.Page2.SuspendLayout()
		Me.Page8.SuspendLayout()
		Me.Page6.SuspendLayout()
		CType(Me.nudRandom, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.Page5.SuspendLayout()
		Me.Panel2.SuspendLayout()
		Me.Panel1.SuspendLayout()
		Me.Page7.SuspendLayout()
		Me.SuspendLayout()
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(1110, 6)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 2
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdBack
		'
		Me.cmdBack.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdBack.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdBack.Location = New System.Drawing.Point(942, 6)
		Me.cmdBack.Name = "cmdBack"
		Me.cmdBack.TabIndex = 0
		Me.cmdBack.Text = "< &Back"
		'
		'cmdNext
		'
		Me.cmdNext.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdNext.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdNext.Location = New System.Drawing.Point(1022, 6)
		Me.cmdNext.Name = "cmdNext"
		Me.cmdNext.TabIndex = 1
		Me.cmdNext.Text = "&Next >"
		'
		'grpEventType
		'
		Me.grpEventType.Controls.Add(Me.RadRepeating)
		Me.grpEventType.Controls.Add(Me.RadRecurring)
		Me.grpEventType.Controls.Add(Me.RadSingle)
		Me.grpEventType.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpEventType.Location = New System.Drawing.Point(32, 48)
		Me.grpEventType.Name = "grpEventType"
		Me.grpEventType.Size = New System.Drawing.Size(160, 104)
		Me.grpEventType.TabIndex = 2
		Me.grpEventType.TabStop = False
		Me.grpEventType.Text = "Event Type"
		'
		'RadRepeating
		'
		Me.RadRepeating.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.RadRepeating.Location = New System.Drawing.Point(16, 72)
		Me.RadRepeating.Name = "RadRepeating"
		Me.RadRepeating.Size = New System.Drawing.Size(112, 24)
		Me.RadRepeating.TabIndex = 2
		Me.RadRepeating.Text = "Repeating Event"
		'
		'RadRecurring
		'
		Me.RadRecurring.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.RadRecurring.Location = New System.Drawing.Point(16, 48)
		Me.RadRecurring.Name = "RadRecurring"
		Me.RadRecurring.TabIndex = 1
		Me.RadRecurring.Text = "Recurring Event"
		'
		'RadSingle
		'
		Me.RadSingle.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.RadSingle.Location = New System.Drawing.Point(16, 24)
		Me.RadSingle.Name = "RadSingle"
		Me.RadSingle.TabIndex = 0
		Me.RadSingle.Text = "Single Event"
		'
		'lblStartTime
		'
		Me.lblStartTime.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblStartTime.Location = New System.Drawing.Point(32, 48)
		Me.lblStartTime.Name = "lblStartTime"
		Me.lblStartTime.Size = New System.Drawing.Size(168, 16)
		Me.lblStartTime.TabIndex = 11
		Me.lblStartTime.Text = "Start Time:"
		'
		'dtpStartTime
		'
		Me.dtpStartTime.CustomFormat = "hh:mm"
		Me.dtpStartTime.Format = System.Windows.Forms.DateTimePickerFormat.Custom
		Me.dtpStartTime.Location = New System.Drawing.Point(32, 64)
		Me.dtpStartTime.Name = "dtpStartTime"
		Me.dtpStartTime.ShowUpDown = True
		Me.dtpStartTime.Size = New System.Drawing.Size(168, 20)
		Me.dtpStartTime.TabIndex = 1
		'
		'nudInterval
		'
		Me.nudInterval.Location = New System.Drawing.Point(32, 168)
		Me.nudInterval.Maximum = New Decimal(New Integer() {1440, 0, 0, 0})
		Me.nudInterval.Name = "nudInterval"
		Me.nudInterval.Size = New System.Drawing.Size(88, 20)
		Me.nudInterval.TabIndex = 3
		Me.nudInterval.Value = New Decimal(New Integer() {1, 0, 0, 0})
		'
		'grpDays
		'
		Me.grpDays.Controls.Add(Me.cmdSelectWeekend)
		Me.grpDays.Controls.Add(Me.cmdSelectWeekdays)
		Me.grpDays.Controls.Add(Me.cmdSelectAllDays)
		Me.grpDays.Controls.Add(Me.chkMonday)
		Me.grpDays.Controls.Add(Me.chkTuesday)
		Me.grpDays.Controls.Add(Me.chkWednesday)
		Me.grpDays.Controls.Add(Me.chkThursday)
		Me.grpDays.Controls.Add(Me.chkFriday)
		Me.grpDays.Controls.Add(Me.chkSaturday)
		Me.grpDays.Controls.Add(Me.chkSunday)
		Me.grpDays.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpDays.Location = New System.Drawing.Point(24, 56)
		Me.grpDays.Name = "grpDays"
		Me.grpDays.Size = New System.Drawing.Size(240, 144)
		Me.grpDays.TabIndex = 18
		Me.grpDays.TabStop = False
		Me.grpDays.Text = "Execute on these days only"
		'
		'cmdSelectWeekend
		'
		Me.cmdSelectWeekend.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdSelectWeekend.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSelectWeekend.Location = New System.Drawing.Point(120, 112)
		Me.cmdSelectWeekend.Name = "cmdSelectWeekend"
		Me.cmdSelectWeekend.Size = New System.Drawing.Size(112, 23)
		Me.cmdSelectWeekend.TabIndex = 26
		Me.cmdSelectWeekend.Text = "Select weekend"
		'
		'cmdSelectWeekdays
		'
		Me.cmdSelectWeekdays.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdSelectWeekdays.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSelectWeekdays.Location = New System.Drawing.Point(120, 72)
		Me.cmdSelectWeekdays.Name = "cmdSelectWeekdays"
		Me.cmdSelectWeekdays.Size = New System.Drawing.Size(112, 23)
		Me.cmdSelectWeekdays.TabIndex = 25
		Me.cmdSelectWeekdays.Text = "Select Weekdays"
		'
		'cmdSelectAllDays
		'
		Me.cmdSelectAllDays.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdSelectAllDays.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSelectAllDays.Location = New System.Drawing.Point(120, 32)
		Me.cmdSelectAllDays.Name = "cmdSelectAllDays"
		Me.cmdSelectAllDays.Size = New System.Drawing.Size(112, 23)
		Me.cmdSelectAllDays.TabIndex = 24
		Me.cmdSelectAllDays.Text = "Select all"
		'
		'chkMonday
		'
		Me.chkMonday.Checked = True
		Me.chkMonday.CheckState = System.Windows.Forms.CheckState.Checked
		Me.chkMonday.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkMonday.Location = New System.Drawing.Point(16, 40)
		Me.chkMonday.Name = "chkMonday"
		Me.chkMonday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkTuesday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkWednesday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkThursday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkFriday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkSaturday.Size = New System.Drawing.Size(96, 16)
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
		Me.chkSunday.Size = New System.Drawing.Size(96, 16)
		Me.chkSunday.TabIndex = 7
		Me.chkSunday.Text = "Sunday"
		'
		'cmbSubs
		'
		Me.cmbSubs.Location = New System.Drawing.Point(8, 32)
		Me.cmbSubs.Name = "cmbSubs"
		Me.cmbSubs.Size = New System.Drawing.Size(304, 21)
		Me.cmbSubs.Sorted = True
		Me.cmbSubs.TabIndex = 0
		'
		'txtParams
		'
		Me.txtParams.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtParams.Location = New System.Drawing.Point(8, 72)
		Me.txtParams.Name = "txtParams"
		Me.txtParams.Size = New System.Drawing.Size(304, 20)
		Me.txtParams.TabIndex = 1
		Me.txtParams.Text = ""
		'
		'txtFinish
		'
		Me.txtFinish.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtFinish.Location = New System.Drawing.Point(112, 56)
		Me.txtFinish.Multiline = True
		Me.txtFinish.Name = "txtFinish"
		Me.txtFinish.ReadOnly = True
		Me.txtFinish.ScrollBars = System.Windows.Forms.ScrollBars.Both
		Me.txtFinish.Size = New System.Drawing.Size(160, 152)
		Me.txtFinish.TabIndex = 22
		Me.txtFinish.Text = ""
		Me.txtFinish.Visible = False
		Me.txtFinish.WordWrap = False
		'
		'Page1
		'
		Me.Page1.Controls.Add(Me.Label6)
		Me.Page1.Controls.Add(Me.Label1)
		Me.Page1.Location = New System.Drawing.Point(24, 80)
		Me.Page1.Name = "Page1"
		Me.Page1.Size = New System.Drawing.Size(360, 168)
		Me.Page1.TabIndex = 24
		'
		'Label6
		'
		Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label6.Location = New System.Drawing.Point(24, 64)
		Me.Label6.Name = "Label6"
		Me.Label6.Size = New System.Drawing.Size(320, 88)
		Me.Label6.TabIndex = 2
    Me.Label6.Text = "This wizard will take you through a series of steps to create a timed event."
		'
		'Label1
		'
		Me.Label1.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label1.Location = New System.Drawing.Point(0, 0)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(360, 48)
		Me.Label1.TabIndex = 1
		Me.Label1.Text = "Welcome to the event wizard."
		'
		'Page4
		'
		Me.Page4.Controls.Add(Me.grpDeterminator)
		Me.Page4.Controls.Add(Me.grpRun)
		Me.Page4.Controls.Add(Me.Label4)
		Me.Page4.Controls.Add(Me.grpSubroutine)
		Me.Page4.Location = New System.Drawing.Point(504, 72)
		Me.Page4.Name = "Page4"
		Me.Page4.Size = New System.Drawing.Size(352, 264)
		Me.Page4.TabIndex = 25
		'
		'grpDeterminator
		'
		Me.grpDeterminator.Controls.Add(Me.cmdNewDeterminator)
		Me.grpDeterminator.Controls.Add(Me.cmbDeterminators)
		Me.grpDeterminator.Controls.Add(Me.Label13)
		Me.grpDeterminator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpDeterminator.Location = New System.Drawing.Point(16, 120)
		Me.grpDeterminator.Name = "grpDeterminator"
		Me.grpDeterminator.Size = New System.Drawing.Size(320, 136)
		Me.grpDeterminator.TabIndex = 4
		Me.grpDeterminator.TabStop = False
		Me.grpDeterminator.Text = "Determinator"
		'
		'cmdNewDeterminator
		'
		Me.cmdNewDeterminator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdNewDeterminator.Location = New System.Drawing.Point(8, 72)
		Me.cmdNewDeterminator.Name = "cmdNewDeterminator"
		Me.cmdNewDeterminator.Size = New System.Drawing.Size(304, 23)
		Me.cmdNewDeterminator.TabIndex = 28
		Me.cmdNewDeterminator.Text = "Create a new determinator"
		'
		'cmbDeterminators
		'
		Me.cmbDeterminators.Location = New System.Drawing.Point(8, 32)
		Me.cmbDeterminators.Name = "cmbDeterminators"
		Me.cmbDeterminators.Size = New System.Drawing.Size(304, 21)
		Me.cmbDeterminators.Sorted = True
		Me.cmbDeterminators.TabIndex = 0
		'
		'Label13
		'
		Me.Label13.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label13.Location = New System.Drawing.Point(8, 16)
		Me.Label13.Name = "Label13"
		Me.Label13.Size = New System.Drawing.Size(152, 16)
		Me.Label13.TabIndex = 27
		Me.Label13.Text = "Name"
		'
		'grpRun
		'
		Me.grpRun.Controls.Add(Me.radDeterminator)
		Me.grpRun.Controls.Add(Me.radSubroutine)
		Me.grpRun.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpRun.Location = New System.Drawing.Point(16, 48)
		Me.grpRun.Name = "grpRun"
		Me.grpRun.Size = New System.Drawing.Size(216, 64)
		Me.grpRun.TabIndex = 1
		Me.grpRun.TabStop = False
		'
		'radDeterminator
		'
		Me.radDeterminator.Checked = True
		Me.radDeterminator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radDeterminator.Location = New System.Drawing.Point(16, 40)
		Me.radDeterminator.Name = "radDeterminator"
		Me.radDeterminator.Size = New System.Drawing.Size(160, 16)
		Me.radDeterminator.TabIndex = 1
		Me.radDeterminator.TabStop = True
		Me.radDeterminator.Text = "Execute a Determinator"
		'
		'radSubroutine
		'
		Me.radSubroutine.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radSubroutine.Location = New System.Drawing.Point(16, 16)
		Me.radSubroutine.Name = "radSubroutine"
		Me.radSubroutine.Size = New System.Drawing.Size(160, 16)
		Me.radSubroutine.TabIndex = 0
		Me.radSubroutine.Text = "Run a Subroutine"
		'
		'Label4
		'
		Me.Label4.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label4.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label4.Location = New System.Drawing.Point(0, 0)
		Me.Label4.Name = "Label4"
		Me.Label4.Size = New System.Drawing.Size(352, 48)
		Me.Label4.TabIndex = 0
		Me.Label4.Text = "Please select what you wish to happen when the event is activated."
		'
		'grpSubroutine
		'
		Me.grpSubroutine.Controls.Add(Me.Label12)
		Me.grpSubroutine.Controls.Add(Me.cmbSubs)
		Me.grpSubroutine.Controls.Add(Me.lblCombo)
		Me.grpSubroutine.Controls.Add(Me.txtParams)
		Me.grpSubroutine.Location = New System.Drawing.Point(16, 120)
		Me.grpSubroutine.Name = "grpSubroutine"
		Me.grpSubroutine.Size = New System.Drawing.Size(320, 136)
		Me.grpSubroutine.TabIndex = 2
		Me.grpSubroutine.TabStop = False
		Me.grpSubroutine.Text = "Subroutine"
		'
		'Label12
		'
		Me.Label12.Location = New System.Drawing.Point(8, 56)
		Me.Label12.Name = "Label12"
		Me.Label12.Size = New System.Drawing.Size(160, 16)
		Me.Label12.TabIndex = 24
		Me.Label12.Text = "Parameters"
		'
		'lblCombo
		'
		Me.lblCombo.Location = New System.Drawing.Point(8, 16)
		Me.lblCombo.Name = "lblCombo"
		Me.lblCombo.Size = New System.Drawing.Size(152, 16)
		Me.lblCombo.TabIndex = 25
		Me.lblCombo.Text = "Name"
		'
		'Page3
		'
		Me.Page3.Controls.Add(Me.Label11)
		Me.Page3.Controls.Add(Me.txtDescription)
		Me.Page3.Controls.Add(Me.Label3)
		Me.Page3.Controls.Add(Me.grpEventType)
		Me.Page3.Location = New System.Drawing.Point(120, 456)
		Me.Page3.Name = "Page3"
		Me.Page3.Size = New System.Drawing.Size(280, 256)
		Me.Page3.TabIndex = 25
		'
		'Label11
		'
		Me.Label11.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
		Me.Label11.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label11.Location = New System.Drawing.Point(0, 160)
		Me.Label11.Name = "Label11"
		Me.Label11.Size = New System.Drawing.Size(100, 16)
		Me.Label11.TabIndex = 24
		Me.Label11.Text = "Description"
		'
		'txtDescription
		'
		Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtDescription.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.txtDescription.Location = New System.Drawing.Point(0, 176)
		Me.txtDescription.Multiline = True
		Me.txtDescription.Name = "txtDescription"
		Me.txtDescription.ReadOnly = True
		Me.txtDescription.Size = New System.Drawing.Size(280, 80)
		Me.txtDescription.TabIndex = 3
		Me.txtDescription.Text = ""
		'
		'Label3
		'
		Me.Label3.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label3.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label3.Location = New System.Drawing.Point(0, 0)
		Me.Label3.Name = "Label3"
		Me.Label3.Size = New System.Drawing.Size(280, 48)
		Me.Label3.TabIndex = 1
		Me.Label3.Text = "Please select the type of event."
		'
		'Page2
		'
		Me.Page2.Controls.Add(Me.Label9)
		Me.Page2.Controls.Add(Me.txtName)
		Me.Page2.Controls.Add(Me.Label2)
		Me.Page2.Location = New System.Drawing.Point(24, 312)
		Me.Page2.Name = "Page2"
		Me.Page2.Size = New System.Drawing.Size(392, 112)
		Me.Page2.TabIndex = 25
		'
		'Label9
		'
		Me.Label9.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label9.Location = New System.Drawing.Point(32, 56)
		Me.Label9.Name = "Label9"
		Me.Label9.Size = New System.Drawing.Size(100, 16)
		Me.Label9.TabIndex = 23
		Me.Label9.Text = "Name"
		'
		'txtName
		'
		Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtName.Location = New System.Drawing.Point(32, 72)
		Me.txtName.Name = "txtName"
		Me.txtName.Size = New System.Drawing.Size(216, 20)
		Me.txtName.TabIndex = 22
		Me.txtName.Text = ""
		'
		'Label2
		'
		Me.Label2.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label2.Location = New System.Drawing.Point(0, 0)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(392, 48)
		Me.Label2.TabIndex = 1
		Me.Label2.Text = "Please select a name for the event."
		'
		'Page8
		'
		Me.Page8.Controls.Add(Me.Label5)
		Me.Page8.Controls.Add(Me.txtFinish)
		Me.Page8.Location = New System.Drawing.Point(872, 528)
		Me.Page8.Name = "Page8"
		Me.Page8.Size = New System.Drawing.Size(319, 247)
		Me.Page8.TabIndex = 26
		'
		'Label5
		'
		Me.Label5.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label5.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label5.Location = New System.Drawing.Point(0, 0)
		Me.Label5.Name = "Label5"
		Me.Label5.Size = New System.Drawing.Size(319, 48)
		Me.Label5.TabIndex = 1
		Me.Label5.Text = "You have now complete all the steps required to create an event."
		'
		'Page6
		'
		Me.Page6.Controls.Add(Me.nudRandom)
		Me.Page6.Controls.Add(Me.Label16)
		Me.Page6.Controls.Add(Me.Label7)
		Me.Page6.Location = New System.Drawing.Point(872, 80)
		Me.Page6.Name = "Page6"
		Me.Page6.Size = New System.Drawing.Size(280, 176)
		Me.Page6.TabIndex = 27
		'
		'nudRandom
		'
		Me.nudRandom.Location = New System.Drawing.Point(32, 88)
		Me.nudRandom.Maximum = New Decimal(New Integer() {60, 0, 0, 0})
		Me.nudRandom.Name = "nudRandom"
		Me.nudRandom.Size = New System.Drawing.Size(88, 20)
		Me.nudRandom.TabIndex = 25
		'
		'Label16
		'
		Me.Label16.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label16.Location = New System.Drawing.Point(32, 72)
		Me.Label16.Name = "Label16"
		Me.Label16.Size = New System.Drawing.Size(136, 16)
		Me.Label16.TabIndex = 24
		Me.Label16.Text = "Randomisation (minutes)"
		'
		'Label7
		'
		Me.Label7.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label7.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label7.Location = New System.Drawing.Point(0, 0)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(280, 48)
		Me.Label7.TabIndex = 1
		Me.Label7.Text = "Please select the randomisation to the times."
		'
		'Page5
		'
		Me.Page5.Controls.Add(Me.cmdAllDay)
		Me.Page5.Controls.Add(Me.lblEndTime)
		Me.Page5.Controls.Add(Me.dtpEndTime)
		Me.Page5.Controls.Add(Me.lblInterval)
		Me.Page5.Controls.Add(Me.lblTimes)
		Me.Page5.Controls.Add(Me.lblStartTime)
		Me.Page5.Controls.Add(Me.dtpStartTime)
		Me.Page5.Controls.Add(Me.nudInterval)
		Me.Page5.Location = New System.Drawing.Point(496, 504)
		Me.Page5.Name = "Page5"
		Me.Page5.Size = New System.Drawing.Size(320, 272)
		Me.Page5.TabIndex = 28
		'
		'cmdAllDay
		'
		Me.cmdAllDay.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdAllDay.Location = New System.Drawing.Point(216, 64)
		Me.cmdAllDay.Name = "cmdAllDay"
		Me.cmdAllDay.TabIndex = 4
		Me.cmdAllDay.Text = "All Day"
		'
		'lblEndTime
		'
		Me.lblEndTime.Location = New System.Drawing.Point(32, 96)
		Me.lblEndTime.Name = "lblEndTime"
		Me.lblEndTime.Size = New System.Drawing.Size(168, 16)
		Me.lblEndTime.TabIndex = 27
		Me.lblEndTime.Text = "End Time:"
		'
		'dtpEndTime
		'
		Me.dtpEndTime.CustomFormat = "hh:mm"
		Me.dtpEndTime.Format = System.Windows.Forms.DateTimePickerFormat.Custom
		Me.dtpEndTime.Location = New System.Drawing.Point(32, 112)
		Me.dtpEndTime.Name = "dtpEndTime"
		Me.dtpEndTime.ShowUpDown = True
		Me.dtpEndTime.Size = New System.Drawing.Size(168, 20)
		Me.dtpEndTime.TabIndex = 2
		'
		'lblInterval
		'
		Me.lblInterval.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblInterval.Location = New System.Drawing.Point(32, 152)
		Me.lblInterval.Name = "lblInterval"
		Me.lblInterval.Size = New System.Drawing.Size(184, 16)
		Me.lblInterval.TabIndex = 25
		Me.lblInterval.Text = "Interval (minutes)"
		'
		'lblTimes
		'
		Me.lblTimes.Dock = System.Windows.Forms.DockStyle.Top
		Me.lblTimes.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblTimes.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.lblTimes.Location = New System.Drawing.Point(0, 0)
		Me.lblTimes.Name = "lblTimes"
		Me.lblTimes.Size = New System.Drawing.Size(320, 48)
		Me.lblTimes.TabIndex = 0
		Me.lblTimes.Text = "stuff"
		'
		'Panel2
		'
		Me.Panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.Panel2.Controls.Add(Me.cmdCancel)
		Me.Panel2.Controls.Add(Me.cmdBack)
		Me.Panel2.Controls.Add(Me.cmdNext)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel2.Location = New System.Drawing.Point(0, 783)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(1194, 40)
		Me.Panel2.TabIndex = 29
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.Label10)
		Me.Panel1.Controls.Add(Me.PictureBox1)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Top
		Me.Panel1.Location = New System.Drawing.Point(0, 0)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(1194, 56)
		Me.Panel1.TabIndex = 30
		'
		'Label10
		'
		Me.Label10.Dock = System.Windows.Forms.DockStyle.Fill
		Me.Label10.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label10.Font = New System.Drawing.Font("Verdana", 20.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label10.Location = New System.Drawing.Point(80, 0)
		Me.Label10.Name = "Label10"
		Me.Label10.Size = New System.Drawing.Size(1114, 56)
		Me.Label10.TabIndex = 1
		Me.Label10.Text = "Event Wizard"
		Me.Label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		'
		'PictureBox1
		'
		Me.PictureBox1.Dock = System.Windows.Forms.DockStyle.Left
		Me.PictureBox1.Image = CType(resources.GetObject("PictureBox1.Image"), System.Drawing.Image)
		Me.PictureBox1.Location = New System.Drawing.Point(0, 0)
		Me.PictureBox1.Name = "PictureBox1"
		Me.PictureBox1.Size = New System.Drawing.Size(80, 56)
		Me.PictureBox1.TabIndex = 0
		Me.PictureBox1.TabStop = False
		'
		'Page7
		'
		Me.Page7.Controls.Add(Me.Label8)
		Me.Page7.Controls.Add(Me.grpDays)
		Me.Page7.Location = New System.Drawing.Point(880, 280)
		Me.Page7.Name = "Page7"
		Me.Page7.Size = New System.Drawing.Size(288, 224)
		Me.Page7.TabIndex = 31
		'
		'Label8
		'
		Me.Label8.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label8.Location = New System.Drawing.Point(0, 0)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(288, 48)
		Me.Label8.TabIndex = 1
		Me.Label8.Text = "On which days should the event be activated?"
		'
		'frmEventWizard
		'
		Me.AcceptButton = Me.cmdNext
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(1194, 823)
		Me.ControlBox = False
		Me.Controls.Add(Me.Page7)
		Me.Controls.Add(Me.Page5)
		Me.Controls.Add(Me.Page6)
		Me.Controls.Add(Me.Page8)
		Me.Controls.Add(Me.Page4)
		Me.Controls.Add(Me.Page1)
		Me.Controls.Add(Me.Page2)
		Me.Controls.Add(Me.Page3)
		Me.Controls.Add(Me.Panel1)
		Me.Controls.Add(Me.Panel2)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.MaximizeBox = False
		Me.MinimizeBox = False
		Me.Name = "frmEventWizard"
		Me.Text = "New Event Wizard"
		Me.grpEventType.ResumeLayout(False)
		CType(Me.nudInterval, System.ComponentModel.ISupportInitialize).EndInit()
		Me.grpDays.ResumeLayout(False)
		Me.Page1.ResumeLayout(False)
		Me.Page4.ResumeLayout(False)
		Me.grpDeterminator.ResumeLayout(False)
		Me.grpRun.ResumeLayout(False)
		Me.grpSubroutine.ResumeLayout(False)
		Me.Page3.ResumeLayout(False)
		Me.Page2.ResumeLayout(False)
		Me.Page8.ResumeLayout(False)
		Me.Page6.ResumeLayout(False)
		CType(Me.nudRandom, System.ComponentModel.ISupportInitialize).EndInit()
		Me.Page5.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		Me.Panel1.ResumeLayout(False)
		Me.Page7.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region


  Private CurrentPage As Integer
  Friend WithEvents HP As HelpProvider

  Private Sub SetUpStage()
    Select Case CurrentPage                                    




      '  Case 5 ' skip if single event
      '    If EventData.evEndTime.ToString("dd/MM/yyyy") = "01/01/0001" Then
      '      EventData.evEndTime = EventData.evStartTime
      '    End If
      '  Case 6 ' Randomisation
      '    nudRandom.Value = EventData.evRandom
      '    nudRandom.Focus()
      '  Case 7 ' Which days?
      '    chkSunday.Focus()
      '  Case 8 ' Name the event
      '    cmdNext.Text = "&Next >"
      '    txtParams.Text = EventData.evTag

      '    txtParams.Focus()
      '  Case 9 ' Finished

      '    cmdNext.Text = "Finish"
      '    txtFinish.Text = "The following event will be created:" & vbCrLf & vbCrLf & "Event Name: " & EventData.evTag & vbCrLf & "Event Type: "
      '    If EventData.IsRecurring Then
      '      txtFinish.Text &= "Recurring"
      '    Else
      '      txtFinish.Text &= "Single"
      '    End If
      '    txtFinish.Text &= vbCrLf & "Sub-routine: " & EventData.evSubName & vbCrLf & "Parameters: " & EventData.evParams & vbCrLf
      '    If EventData.IsRecurring Then
      '      txtFinish.Text &= "Start Time: " & EventData.evStartTime.ToString("HH:mm") & vbCrLf
      '      If Not EventData.evStartTime = EventData.evEndTime Then
      '        txtFinish.Text &= "Finish Time: " & EventData.evEndTime.ToString("HH:mm") & vbCrLf
      '        txtFinish.Text &= "Interval: " & EventData.evInterval.ToString & " minutes" & vbCrLf
      '      End If
      '    Else
      '      txtFinish.Text &= "Date/Time: " & EventData.evDate.ToString("dd MMM yyyy HH:mm") & vbCrLf
      '    End If
      '    If EventData.evRandom > 0 Then
      '      txtFinish.Text &= "Randomisation: " & EventData.evRandom.ToString & " minute(s)"
      '    Else
      '      txtFinish.Text &= "Randomisation: None"
      '    End If
      '    cmdNext.Focus()
      '  Case Else
      '    MsgBox("oops")
    End Select
  End Sub

  Private Sub cmdBack_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdBack.Click
    If CurrentPage > 1 Then
      If CurrentPage = 8 And RadSingle.Checked Then
        CurrentPage = 5
      Else
        CurrentPage -= 1
      End If
      UpdatePage()
    End If
  End Sub

  Private Sub cmdNext_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdNext.Click
    Select Case CurrentPage
      Case 1
        'If chkDisableWizard.Checked Then
        '  Dim f As New frmEditEvent
        '  f.EventName = ""
        '  f.Show()
        '  Me.Close()
        'Else
          CurrentPage += 1
          UpdatePage()
        'End If
      Case 2
        ' Validate the name
        If txtName.Text <> "" Then
          CurrentPage += 1
          UpdatePage()
        Else
          MsgBox("You must enter a name for this event.", vbExclamation)
        End If
      Case 3 ' SIngle, recurring etc.
        CurrentPage += 1
        UpdatePage()
      Case 4
        CurrentPage += 1
        UpdatePage()
      Case 5
        If RadSingle.Checked Then
          CurrentPage = 8
        Else
          CurrentPage += 1
        End If
        UpdatePage()
      Case 6
        CurrentPage += 1
        UpdatePage()
      Case 7
        CurrentPage += 1
        UpdatePage()
      Case 8
        SaveEvent()
        Me.Close()
    End Select
  End Sub

  Private Sub frmEventWizard_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    HP = New HelpProvider
    HP.SetHelpNavigator(Me, HelpNavigator.Topic)
    HP.SetShowHelp(Me, True)
    HP.HelpNamespace = "xplhal.chm"
    HP.SetHelpKeyword(Me, "topics/events/introduction.htm")    
    Me.Height = 390
    Me.Width = 542
    RadSingle.Checked = True
    CurrentPage = 1
    UpdatePage()
    PopulateSubs(cmbSubs)
    PopulateDeterminators(cmbDeterminators)
  End Sub

  Private Sub UpdatePage()
    Me.SuspendLayout()
    Page1.Visible = False
    Page1.Dock = DockStyle.Fill
    Page2.Visible = False
    Page2.Dock = DockStyle.Fill
    Page3.Visible = False
    Page3.Dock = DockStyle.Fill
    Page4.Visible = False
    Page4.Dock = DockStyle.Fill
    Page5.Visible = False
    Page5.Dock = DockStyle.Fill
    Page6.Visible = False
    Page6.Dock = DockStyle.Fill
    Page7.Visible = False
    Page7.Dock = DockStyle.Fill
    Page8.Visible = False
    Page8.Dock = DockStyle.Fill
    Select Case CurrentPage
      Case 1
        cmdBack.Enabled = False
        Page1.Visible = True
        'chkDisableWizard.Focus()
      Case 2 ' Event name
        Page2.Visible = True
        cmdBack.Enabled = True
        txtName.Focus()
      Case 3 ' SIngle, recurring etc.
        Page3.Visible = True
        If RadSingle.Checked Then
          RadSingle.Focus()
        End If
        If RadRecurring.Checked Then
          RadRecurring.Focus()
        End If
        If RadRepeating.Checked Then
          RadRepeating.Focus()
        End If

      Case 4 ' Sub/determinator selection
        Page4.Visible = True
        If radSubroutine.Checked Then
          radSubroutine.Focus()
        End If
        If radDeterminator.Checked Then
          radDeterminator.Focus()
        End If
      Case 5 ' Start/end/interval
        Page5.Visible = True
        dtpStartTime.Focus()
        cmdNext.Text = "&Next >>"
        If RadSingle.Checked Then

          lblTimes.Text = "Please select the date and time you wish your event to occur."
          lblStartTime.Text = "Date and Time"
          dtpStartTime.CustomFormat = "ddd d MMM yyyy HH:mm"
          dtpEndTime.CustomFormat = "ddd d MMM yyyy HH:mm"
          cmdAllDay.Visible = False
          dtpStartTime.Visible = True
          dtpEndTime.Visible = False
          lblEndTime.Visible = False
          nudInterval.Visible = False
          lblInterval.Visible = False
        ElseIf RadRecurring.Checked Then
          lblTimes.Text = "Please select the time you wish your event to occur."
          lblStartTime.Text = "Time"
          dtpStartTime.CustomFormat = "HH:mm"
          dtpEndTime.CustomFormat = "HH:mm"
          dtpStartTime.Visible = True
          dtpEndTime.Visible = False
          lblEndTime.Visible = False
          nudInterval.Visible = False
          lblInterval.Visible = False
          cmdAllDay.Visible = False
        ElseIf RadRepeating.Checked Then
          lblTimes.Text = "Please select the times between which you wish your event to occur, and the number of minutes between each occurrence."
          lblStartTime.Text = "Start time"
          dtpStartTime.CustomFormat = "HH:mm"
          dtpEndTime.CustomFormat = "HH:mm"
          dtpStartTime.Visible = True
          dtpEndTime.Visible = True
          cmdAllDay.Visible = True
          lblEndTime.Visible = True
          nudInterval.Visible = True
          lblInterval.Visible = True
        End If
      Case 6 ' Randomisation
        Page6.Visible = True
        nudRandom.Focus()
      Case 7 ' Days of week
        Page7.Visible = True
        chkSunday.Focus()
      Case 8 ' Finish
        Page8.Visible = True
        cmdNext.Text = "Finish"
        cmdNext.Focus()

    End Select
    Me.ResumeLayout()
  End Sub

  Private Sub cmdCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
    Me.Close()
  End Sub

  Private Sub SaveStage()
    'Select Case Stage
    '  Case 2 ' SIngle or recurring?
    '    If RadSingle.Checked = True Then
    '      EventData.IsRecurring = False
    '      HP.SetHelpKeyword(Me, "topics/events/single.htm")
    '    Else
    '      EventData.IsRecurring = True
    '      HP.SetHelpKeyword(Me, "topics/events/recurring.htm")
    '    End If
    '  Case 3 ' Sub and params
    '    EventData.evSubName = cmbSubs.Text
    '    EventData.evParams = txtParams.Text
    '  Case 4 ' Start time
    '    If EventData.IsRecurring Then
    '      EventData.evStartTime = dtpStartTime.Value
    '    Else
    '      EventData.evDate = dtpStartTime.Value
    '    End If
    '  Case 5 ' End time and interval
    '    EventData.evEndTime = dtpEndTime.Value
    '    EventData.evInterval = CInt(nudInterval.Value)
    '  Case 6 ' Randomisation
    '    EventData.evRandom = CInt(nudRandom.Value)
    '  Case 7 ' Days to execute
    '    If chkSunday.Checked Then
    '      EventData.evDOW = "Y"
    '    Else
    '      EventData.evDOW = "N"
    '    End If
    '    If chkMonday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '    If chkTuesday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '    If chkWednesday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '    If chkThursday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '    If chkFriday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '    If chkSaturday.Checked Then
    '      EventData.evDOW &= "Y"
    '    Else
    '      EventData.evDOW &= "N"
    '    End If
    '  Case 8 ' Event name
    '    EventData.evTag = txtParams.Text
    'End Select
  End Sub

  Private Sub frmEventWizard_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Activated
    If CurrentPage = 1 Then
      cmdNext.Focus()
    End If
  End Sub

  
  Private Sub cmdSelectAllDays_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectAllDays.Click
    SetWeekDays(True)
    SetWeekendDays(True)

  End Sub
  Private Sub SetWeekDays(ByVal Status As Boolean)
    chkMonday.Checked = Status
    chkTuesday.Checked = Status
    chkWednesday.Checked = Status
    chkThursday.Checked = Status
    chkFriday.Checked = Status
  End Sub
  Private Sub SetWeekendDays(ByVal Status As Boolean)
    chkSaturday.Checked = Status
    chkSunday.Checked = Status
  End Sub


  Private Sub cmdSelectWeekend_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectWeekend.Click
    SetWeekendDays(True)
    SetWeekDays(False)
  End Sub

  Private Sub cmdSelectWeekdays_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectWeekdays.Click
    SetWeekDays(True)
    SetWeekendDays(False)
  End Sub


  Private Sub rad_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radSubroutine.CheckedChanged, radDeterminator.CheckedChanged
    If radSubroutine.Checked Then
			grpSubroutine.Visible = True
			grpSubroutine.BringToFront()
      grpDeterminator.Visible = False
    Else
      grpSubroutine.Visible = False
			grpDeterminator.Visible = True
			grpDeterminator.BringToFront()
    End If
  End Sub

  Private Sub SaveEvent()
    ' Saves the event to the xPLHal server
    Dim ev As EventInfo
    If RadSingle.Checked Then
      ev.IsRecurring = False
    Else
      ev.IsRecurring = True
    End If
    ev.evDate = dtpStartTime.Value
    ev.evStartTime = dtpStartTime.Value
    If RadRecurring.Checked Then
      ev.evEndTime = ev.evStartTime
      ev.evInterval = 0
    Else
      ev.evEndTime = dtpEndTime.Value
      ev.evInterval = CInt(nudInterval.Text)
    End If
    ev.evRandom = CInt(nudRandom.Text)
    ev.evTag = txtName.Text
    If radDeterminator.Checked Then
      ev.evSubName = "{determinator}"
      ev.evParams = cmbDeterminators.Text
    Else
      ev.evSubName = cmbSubs.Text
      ev.evParams = txtParams.Text
    End If
    If chkSunday.Checked Then
      ev.evDOW = "Y"
    Else
      ev.evDOW = "N"
    End If
    If chkMonday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    If chkTuesday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    If chkWednesday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    If chkThursday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    If chkFriday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    If chkSaturday.Checked Then
      ev.evDOW &= "Y"
    Else
      ev.evDOW &= "N"
    End If
    createEvent(ev)
  End Sub

  Private Sub RadSingle_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles RadSingle.CheckedChanged, RadRecurring.CheckedChanged, RadRepeating.CheckedChanged
    If RadSingle.Checked = True Then
      txtDescription.Text = "A single event is one which occurs only once, on a specific day, and at a specific time."
    End If
    If RadRecurring.Checked = True Then
      txtDescription.Text = "Recurring events occur on a regular basis."
    End If
    If RadRepeating.Checked = True Then
      txtDescription.Text = "Repeating events occur a number of times during a specified time period."
    End If
  End Sub

  Private Sub cmdAllDay_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdAllDay.Click
    dtpStartTime.Text = "00:01"
    dtpEndTime.Text = "23:59"
    cmdNext.Focus()
  End Sub

	Private Sub cmdNewDeterminator_Click(ByVal sender As System.Object, ByVal e As System.EventArgs)
		Dim f As New frmDeterminatorWizard
		f.ShowDialog()
		populatedeterminators(cmbDeterminators)
	End Sub


End Class
