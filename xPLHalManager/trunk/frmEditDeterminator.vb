'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2005 John Bent & Ian Jeffery
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

Imports xPLHalMgr.xplhalMgrBase.DeterminatorRule.DeterminatorCondition.xplCondition

Public Class frmEditDeterminator
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
    Friend WithEvents cmbSource As System.Windows.Forms.ComboBox
    Friend WithEvents cmbTarget As System.Windows.Forms.ComboBox
    Friend WithEvents cmbSchema As System.Windows.Forms.ComboBox
    Friend WithEvents txtName As System.Windows.Forms.TextBox
    Friend WithEvents cmbConditionType As System.Windows.Forms.ComboBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents lstBody As System.Windows.Forms.ListBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdRemove As System.Windows.Forms.Button
    Friend WithEvents cmdAdd As System.Windows.Forms.Button
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents grpDays As System.Windows.Forms.GroupBox
    Friend WithEvents cmdSelectWeekend As System.Windows.Forms.Button
    Friend WithEvents cmdSelectWeekdays As System.Windows.Forms.Button
    Friend WithEvents cmdSelectAllDays As System.Windows.Forms.Button
    Friend WithEvents chkMonday As System.Windows.Forms.CheckBox
    Friend WithEvents chkTuesday As System.Windows.Forms.CheckBox
    Friend WithEvents chkWednesday As System.Windows.Forms.CheckBox
    Friend WithEvents chkThursday As System.Windows.Forms.CheckBox
    Friend WithEvents chkFriday As System.Windows.Forms.CheckBox
    Friend WithEvents chkSaturday As System.Windows.Forms.CheckBox
    Friend WithEvents chkSunday As System.Windows.Forms.CheckBox
    Friend WithEvents PnlXpl As System.Windows.Forms.Panel
    Friend WithEvents pnlDays As System.Windows.Forms.Panel
    Friend WithEvents Label8 As System.Windows.Forms.Label

    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents dtpTime As System.Windows.Forms.DateTimePicker
    Friend WithEvents cmbCompare As System.Windows.Forms.ComboBox
    Friend WithEvents pnlCompareTime As System.Windows.Forms.Panel
    Friend WithEvents cmdEdit As System.Windows.Forms.Button
    Friend WithEvents radYear As System.Windows.Forms.RadioButton
    Friend WithEvents radMonth As System.Windows.Forms.RadioButton
    Friend WithEvents radDay As System.Windows.Forms.RadioButton
    Friend WithEvents radDate As System.Windows.Forms.RadioButton
    Friend WithEvents radtime As System.Windows.Forms.RadioButton
    Friend WithEvents lblCompareTime As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditDeterminator))
        Me.cmbMessageType = New System.Windows.Forms.ComboBox
        Me.cmbSource = New System.Windows.Forms.ComboBox
        Me.cmbTarget = New System.Windows.Forms.ComboBox
        Me.cmbSchema = New System.Windows.Forms.ComboBox
        Me.txtName = New System.Windows.Forms.TextBox
        Me.cmbConditionType = New System.Windows.Forms.ComboBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.Label4 = New System.Windows.Forms.Label
        Me.Label5 = New System.Windows.Forms.Label
        Me.lstBody = New System.Windows.Forms.ListBox
        Me.Label6 = New System.Windows.Forms.Label
        Me.cmdOK = New System.Windows.Forms.Button
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.cmdRemove = New System.Windows.Forms.Button
        Me.cmdAdd = New System.Windows.Forms.Button
        Me.Label7 = New System.Windows.Forms.Label
        Me.PnlXpl = New System.Windows.Forms.Panel
        Me.cmdEdit = New System.Windows.Forms.Button
        Me.pnlDays = New System.Windows.Forms.Panel
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
        Me.Label9 = New System.Windows.Forms.Label
        Me.Label8 = New System.Windows.Forms.Label
        Me.pnlCompareTime = New System.Windows.Forms.Panel
        Me.radYear = New System.Windows.Forms.RadioButton
        Me.radMonth = New System.Windows.Forms.RadioButton
        Me.radDay = New System.Windows.Forms.RadioButton
        Me.radDate = New System.Windows.Forms.RadioButton
        Me.radtime = New System.Windows.Forms.RadioButton
        Me.lblCompareTime = New System.Windows.Forms.Label
        Me.dtpTime = New System.Windows.Forms.DateTimePicker
        Me.Label10 = New System.Windows.Forms.Label
        Me.cmbCompare = New System.Windows.Forms.ComboBox
        Me.PnlXpl.SuspendLayout()
        Me.pnlDays.SuspendLayout()
        Me.grpDays.SuspendLayout()
        Me.pnlCompareTime.SuspendLayout()
        Me.SuspendLayout()
        '
        'cmbMessageType
        '
        Me.cmbMessageType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbMessageType.Location = New System.Drawing.Point(144, 8)
        Me.cmbMessageType.Name = "cmbMessageType"
        Me.cmbMessageType.Size = New System.Drawing.Size(216, 21)
        Me.cmbMessageType.TabIndex = 0
        '
        'cmbSource
        '
        Me.cmbSource.Location = New System.Drawing.Point(144, 32)
        Me.cmbSource.Name = "cmbSource"
        Me.cmbSource.Size = New System.Drawing.Size(216, 21)
        Me.cmbSource.Sorted = True
        Me.cmbSource.TabIndex = 1
        '
        'cmbTarget
        '
        Me.cmbTarget.Location = New System.Drawing.Point(144, 56)
        Me.cmbTarget.Name = "cmbTarget"
        Me.cmbTarget.Size = New System.Drawing.Size(216, 21)
        Me.cmbTarget.Sorted = True
        Me.cmbTarget.TabIndex = 2
        '
        'cmbSchema
        '
        Me.cmbSchema.Location = New System.Drawing.Point(144, 80)
        Me.cmbSchema.Name = "cmbSchema"
        Me.cmbSchema.Size = New System.Drawing.Size(216, 21)
        Me.cmbSchema.Sorted = True
        Me.cmbSchema.TabIndex = 3
        '
        'txtName
        '
        Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.txtName.Location = New System.Drawing.Point(152, 8)
        Me.txtName.Name = "txtName"
        Me.txtName.Size = New System.Drawing.Size(216, 20)
        Me.txtName.TabIndex = 0
        Me.txtName.Text = ""
        '
        'cmbConditionType
        '
        Me.cmbConditionType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbConditionType.Location = New System.Drawing.Point(152, 40)
        Me.cmbConditionType.Name = "cmbConditionType"
        Me.cmbConditionType.Size = New System.Drawing.Size(216, 21)
        Me.cmbConditionType.TabIndex = 1
        '
        'Label1
        '
        Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label1.Location = New System.Drawing.Point(8, 8)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(128, 23)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "Message Type"
        Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'Label2
        '
        Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label2.Location = New System.Drawing.Point(8, 32)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(128, 23)
        Me.Label2.TabIndex = 6
        Me.Label2.Text = "Source"
        Me.Label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'Label3
        '
        Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label3.Location = New System.Drawing.Point(8, 56)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(128, 23)
        Me.Label3.TabIndex = 7
        Me.Label3.Text = "Target"
        Me.Label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'Label4
        '
        Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label4.Location = New System.Drawing.Point(8, 80)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(128, 23)
        Me.Label4.TabIndex = 8
        Me.Label4.Text = "Schema"
        Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'Label5
        '
        Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label5.Location = New System.Drawing.Point(16, 40)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(128, 23)
        Me.Label5.TabIndex = 9
        Me.Label5.Text = "Condition Type"
        Me.Label5.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'lstBody
        '
        Me.lstBody.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstBody.Location = New System.Drawing.Point(144, 112)
        Me.lstBody.Name = "lstBody"
        Me.lstBody.Size = New System.Drawing.Size(216, 210)
        Me.lstBody.TabIndex = 4
        '
        'Label6
        '
        Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label6.Location = New System.Drawing.Point(32, 112)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(104, 40)
        Me.Label6.TabIndex = 11
        Me.Label6.Text = "Message Parameters"
        Me.Label6.TextAlign = System.Drawing.ContentAlignment.TopRight
        '
        'cmdOK
        '
        Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdOK.Location = New System.Drawing.Point(810, 538)
        Me.cmdOK.Name = "cmdOK"
        Me.cmdOK.TabIndex = 3
        Me.cmdOK.Text = "OK"
        '
        'cmdCancel
        '
        Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdCancel.Location = New System.Drawing.Point(898, 538)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.TabIndex = 4
        Me.cmdCancel.Text = "Cancel"
        '
        'cmdRemove
        '
        Me.cmdRemove.Anchor = System.Windows.Forms.AnchorStyles.Right
        Me.cmdRemove.Enabled = False
        Me.cmdRemove.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdRemove.Location = New System.Drawing.Point(368, 176)
        Me.cmdRemove.Name = "cmdRemove"
        Me.cmdRemove.TabIndex = 7
        Me.cmdRemove.Text = "Remove"
        '
        'cmdAdd
        '
        Me.cmdAdd.Anchor = System.Windows.Forms.AnchorStyles.Right
        Me.cmdAdd.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdAdd.Location = New System.Drawing.Point(368, 112)
        Me.cmdAdd.Name = "cmdAdd"
        Me.cmdAdd.TabIndex = 5
        Me.cmdAdd.Text = "Add"
        '
        'Label7
        '
        Me.Label7.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label7.Location = New System.Drawing.Point(16, 8)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(128, 23)
        Me.Label7.TabIndex = 13
        Me.Label7.Text = "Condition Name"
        Me.Label7.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'PnlXpl
        '
        Me.PnlXpl.Controls.Add(Me.cmdEdit)
        Me.PnlXpl.Controls.Add(Me.Label4)
        Me.PnlXpl.Controls.Add(Me.lstBody)
        Me.PnlXpl.Controls.Add(Me.Label6)
        Me.PnlXpl.Controls.Add(Me.cmbMessageType)
        Me.PnlXpl.Controls.Add(Me.cmbSource)
        Me.PnlXpl.Controls.Add(Me.cmbTarget)
        Me.PnlXpl.Controls.Add(Me.cmbSchema)
        Me.PnlXpl.Controls.Add(Me.Label1)
        Me.PnlXpl.Controls.Add(Me.Label2)
        Me.PnlXpl.Controls.Add(Me.Label3)
        Me.PnlXpl.Controls.Add(Me.cmdRemove)
        Me.PnlXpl.Controls.Add(Me.cmdAdd)
        Me.PnlXpl.Location = New System.Drawing.Point(8, 72)
        Me.PnlXpl.Name = "PnlXpl"
        Me.PnlXpl.Size = New System.Drawing.Size(448, 368)
        Me.PnlXpl.TabIndex = 2
        '
        'cmdEdit
        '
        Me.cmdEdit.Anchor = System.Windows.Forms.AnchorStyles.Right
        Me.cmdEdit.Enabled = False
        Me.cmdEdit.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdEdit.Location = New System.Drawing.Point(368, 144)
        Me.cmdEdit.Name = "cmdEdit"
        Me.cmdEdit.TabIndex = 6
        Me.cmdEdit.Text = "Edit"
        '
        'pnlDays
        '
        Me.pnlDays.Controls.Add(Me.grpDays)
        Me.pnlDays.Location = New System.Drawing.Point(464, 8)
        Me.pnlDays.Name = "pnlDays"
        Me.pnlDays.Size = New System.Drawing.Size(448, 224)
        Me.pnlDays.TabIndex = 32
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
        Me.grpDays.Location = New System.Drawing.Point(120, 8)
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
        'pnlCompareTime
        '
        Me.pnlCompareTime.Controls.Add(Me.radYear)
        Me.pnlCompareTime.Controls.Add(Me.radMonth)
        Me.pnlCompareTime.Controls.Add(Me.radDay)
        Me.pnlCompareTime.Controls.Add(Me.radDate)
        Me.pnlCompareTime.Controls.Add(Me.radtime)
        Me.pnlCompareTime.Controls.Add(Me.lblCompareTime)
        Me.pnlCompareTime.Controls.Add(Me.dtpTime)
        Me.pnlCompareTime.Controls.Add(Me.Label10)
        Me.pnlCompareTime.Controls.Add(Me.cmbCompare)
        Me.pnlCompareTime.Location = New System.Drawing.Point(464, 336)
        Me.pnlCompareTime.Name = "pnlCompareTime"
        Me.pnlCompareTime.Size = New System.Drawing.Size(448, 160)
        Me.pnlCompareTime.TabIndex = 34
        '
        'radYear
        '
        Me.radYear.Location = New System.Drawing.Point(8, 136)
        Me.radYear.Name = "radYear"
        Me.radYear.Size = New System.Drawing.Size(136, 16)
        Me.radYear.TabIndex = 10
        Me.radYear.Text = "Year"
        '
        'radMonth
        '
        Me.radMonth.Location = New System.Drawing.Point(8, 120)
        Me.radMonth.Name = "radMonth"
        Me.radMonth.Size = New System.Drawing.Size(136, 16)
        Me.radMonth.TabIndex = 9
        Me.radMonth.Text = "Month"
        '
        'radDay
        '
        Me.radDay.Location = New System.Drawing.Point(8, 104)
        Me.radDay.Name = "radDay"
        Me.radDay.Size = New System.Drawing.Size(136, 16)
        Me.radDay.TabIndex = 8
        Me.radDay.Text = "Day of Month"
        '
        'radDate
        '
        Me.radDate.Location = New System.Drawing.Point(8, 88)
        Me.radDate.Name = "radDate"
        Me.radDate.Size = New System.Drawing.Size(136, 16)
        Me.radDate.TabIndex = 7
        Me.radDate.Text = "Date"
        '
        'radtime
        '
        Me.radtime.Location = New System.Drawing.Point(8, 72)
        Me.radtime.Name = "radtime"
        Me.radtime.Size = New System.Drawing.Size(136, 16)
        Me.radtime.TabIndex = 6
        Me.radtime.Text = "Time"
        '
        'lblCompareTime
        '
        Me.lblCompareTime.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.lblCompareTime.Location = New System.Drawing.Point(8, 40)
        Me.lblCompareTime.Name = "lblCompareTime"
        Me.lblCompareTime.Size = New System.Drawing.Size(128, 20)
        Me.lblCompareTime.TabIndex = 5
        Me.lblCompareTime.Text = "Time"
        Me.lblCompareTime.TextAlign = System.Drawing.ContentAlignment.BottomRight
        '
        'dtpTime
        '
        Me.dtpTime.CustomFormat = "HH:mm"
        Me.dtpTime.Format = System.Windows.Forms.DateTimePickerFormat.Custom
        Me.dtpTime.Location = New System.Drawing.Point(144, 40)
        Me.dtpTime.Name = "dtpTime"
        Me.dtpTime.ShowUpDown = True
        Me.dtpTime.Size = New System.Drawing.Size(216, 20)
        Me.dtpTime.TabIndex = 4
        '
        'Label10
        '
        Me.Label10.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label10.Location = New System.Drawing.Point(8, 8)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(128, 20)
        Me.Label10.TabIndex = 3
        Me.Label10.Text = "Compare"
        Me.Label10.TextAlign = System.Drawing.ContentAlignment.BottomRight
        '
        'cmbCompare
        '
        Me.cmbCompare.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbCompare.Location = New System.Drawing.Point(144, 8)
        Me.cmbCompare.Name = "cmbCompare"
        Me.cmbCompare.Size = New System.Drawing.Size(216, 21)
        Me.cmbCompare.TabIndex = 2
        '
        'frmEditDeterminator
        '
        Me.AcceptButton = Me.cmdOK
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.CancelButton = Me.cmdCancel
        Me.ClientSize = New System.Drawing.Size(978, 567)
        Me.Controls.Add(Me.pnlCompareTime)
        Me.Controls.Add(Me.pnlDays)
        Me.Controls.Add(Me.PnlXpl)
        Me.Controls.Add(Me.Label7)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdOK)
        Me.Controls.Add(Me.txtName)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.cmbConditionType)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MaximizeBox = False
        Me.Name = "frmEditDeterminator"
        Me.Text = "Edit Determinator"
        Me.PnlXpl.ResumeLayout(False)
        Me.pnlDays.ResumeLayout(False)
        Me.grpDays.ResumeLayout(False)
        Me.pnlCompareTime.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Public myCondition As DeterminatorRule.DeterminatorCondition
    Private PanelLoc As Point, PanelSize As Size

    Private Sub frmEditDeterminator_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        HideAll()
        ConnectToXplHal()
        PopulateComparisonCombo(cmbCompare)
        cmbCompare.SelectedIndex = 0
        PanelLoc.X = 8
        PanelLoc.Y = 72
        PanelSize.Height = 368
        PanelSize.Width = 448
        cmbConditionType.Items.Add("xPL Message")
        cmbConditionType.Items.Add("Compare global variable")
        cmbConditionType.Items.Add("Global variable changed")
        cmbConditionType.Items.Add("Execute days")
        cmbConditionType.Items.Add("Compare Date/Time")
        If myCondition.DisplayName = "" Then
            Me.Text = "New Condition"
            txtName.Text = "New Condition"
            cmbConditionType.SelectedIndex = 0
            radtime.Checked = True
            dtpTime.Value = Now
            If System.DateTime.DaysInMonth(DatePart(DateInterval.Year, Now), DatePart(DateInterval.Month, Now)) < 31 Then
                dtpTime.Value = Now.AddMonths(1)
            End If
        Else
            Me.Text = "Edit Condition"
            txtName.Text = myCondition.DisplayName
            Select Case myCondition.ConditionType
                Case DeterminatorRule.ConditionTypes.xPLMessage
                    Dim x As DeterminatorRule.DeterminatorCondition.xplCondition = CType(myCondition.Condition, DeterminatorRule.DeterminatorCondition.xplCondition)
                    cmbConditionType.SelectedIndex = 0
                    Select Case x.msg_type
                        Case "cmnd"
                            cmbMessageType.SelectedIndex = 0
                        Case "trig"
                            cmbMessageType.SelectedIndex = 1
                        Case "stat"
                            cmbMessageType.SelectedIndex = 2
                    End Select
                    cmbSource.Text = x.source_vendor & "-" & x.source_device & "." & x.source_instance
                    cmbTarget.Text = x.target_vendor & "-" & x.target_device & "." & x.target_instance
                    If cmbSource.Text = "*-*.*" Then cmbSource.Text = "*"
                    If cmbTarget.Text = "*-*.*" Then cmbTarget.Text = "*"
                    cmbSchema.Text = x.schema_class & "." & x.schema_type
                    For Each entry As xplConditionParams In x.params
                        lstBody.Items.Add(entry.Name & " " & entry.[Operator] & " " & entry.Value)
                    Next
                Case DeterminatorRule.ConditionTypes.globalCondition
                    Dim x As DeterminatorRule.DeterminatorCondition.globalCondition = CType(myCondition.Condition, DeterminatorRule.DeterminatorCondition.globalCondition)
                    cmbConditionType.SelectedIndex = 1
                    cmbMessageType.Text = x.Name
                    cmbTarget.Text = x.Value

                    Select Case x.[Operator]
                        Case "="
                            cmbSource.SelectedIndex = 0
                        Case "!="
                            cmbSource.SelectedIndex = 1
                        Case "<"
                            cmbSource.SelectedIndex = 2
                        Case ">"
                            cmbSource.SelectedIndex = 3
                        Case Else
                            MsgBox("Unrecognised operator.")
                            Me.Close()
                            Exit Sub
                    End Select
                Case DeterminatorRule.ConditionTypes.globalChanged
                    Dim x As DeterminatorRule.DeterminatorCondition.globalChanged = CType(myCondition.Condition, DeterminatorRule.DeterminatorCondition.globalChanged)
                    cmbConditionType.SelectedIndex = 2
                    cmbMessageType.Text = x.globalName
                Case DeterminatorRule.ConditionTypes.dayCondition
                    cmbConditionType.SelectedIndex = 3
                    Dim x As DeterminatorRule.DeterminatorCondition.dayCondition = CType(myCondition.Condition, DeterminatorRule.DeterminatorCondition.dayCondition)
                    If x.DOW.Substring(0, 1) = "1" Then
                        chkSunday.Checked = True
                    Else
                        chkSunday.Checked = False
                    End If
                    If x.DOW.Substring(1, 1) = "1" Then
                        chkMonday.Checked = True
                    Else
                        chkMonday.Checked = False
                    End If
                    If x.DOW.Substring(2, 1) = "1" Then
                        chkTuesday.Checked = True
                    Else
                        chkTuesday.Checked = False
                    End If
                    If x.DOW.Substring(3, 1) = "1" Then
                        chkWednesday.Checked = True
                    Else
                        chkWednesday.Checked = False
                    End If
                    If x.DOW.Substring(4, 1) = "1" Then
                        chkThursday.Checked = True
                    Else
                        chkThursday.Checked = False
                    End If
                    If x.DOW.Substring(5, 1) = "1" Then
                        chkFriday.Checked = True
                    Else
                        chkFriday.Checked = False
                    End If
                    If x.DOW.Substring(6, 1) = "1" Then
                        chkSaturday.Checked = True
                    Else
                        chkSaturday.Checked = False
                    End If
                Case DeterminatorRule.ConditionTypes.timeCondition
                    cmbConditionType.SelectedIndex = 5
                    Dim x As DeterminatorRule.DeterminatorCondition.timeCondition = CType(myCondition.Condition, DeterminatorRule.DeterminatorCondition.timeCondition)
                    Select Case x.[Operator]
                        Case ">"
                            cmbCompare.SelectedIndex = 3
                        Case "<"
                            cmbCompare.SelectedIndex = 2
                        Case "="
                            cmbCompare.SelectedIndex = 0
                        Case "!="
                            cmbCompare.SelectedIndex = 1
                    End Select
                    Select Case x.Category
                        Case "date"
                            radDate.Checked = True
                            dtpTime.Value = CDate(x.Value)
                        Case "day"
                            dtpTime.Value = CDate(x.Value & "/01/2000")
                            radDay.Checked = True
                        Case "month"
                            dtpTime.Value = CDate("01/" & x.Value & "/2000")
                            radMonth.Checked = True
                        Case "year"
                            dtpTime.Value = CDate("01/01/" & x.Value)
                            radYear.Checked = True
                        Case Else
                            radtime.Checked = True
                            dtpTime.Value = CDate("01/01/2000 " & x.Value)
                    End Select

                Case Else
                    MsgBox("You cannot edit this type of condition. Please upgrade to a newer version of xPLHal Manager.", vbCritical)
                    Me.Close()
                    Exit Sub
            End Select
        End If
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        If txtName.Text = "" Then
            MsgBox("The condition name is invalid." & vbCrLf & vbCrLf & "Please specify a valid name for this condition to help you identify it.", vbExclamation)
            Exit Sub
        End If
        ' Save the condition's name
        myCondition.DisplayName = txtName.Text

        ' Save the condition, depending on the selected condition type
        Select Case cmbConditionType.SelectedIndex
            Case 0 ' xPL Condition'
                ' Validate the form
                cmbSource.Text = cmbSource.Text.ToUpper
                cmbTarget.Text = cmbTarget.Text.ToUpper

                ' Source
                If Not RegularExpressions.Regex.IsMatch(cmbSource.Text, "^\*|(([A-Z]|[0-9]){1,8}-([A-Z]|[0-9]){1,8}\.([A-Z]|[0-9]){1,16})$") Then
                    MsgBox("The source of the xPL message is invalid.", vbExclamation)
                    cmbSource.Focus()
                    Exit Sub
                End If
                ' Schema        
                If Not RegularExpressions.Regex.IsMatch(cmbSchema.Text, "^([a-z]|[A-Z]|[0-9]){1,8}\.([a-z]|[A-Z]|[0-9]){1,8}$") Then
                    MsgBox("The message schema " & cmbSchema.Text & " is invalid.", vbExclamation)
                    cmbSchema.Focus()
                    Exit Sub
                End If
                myCondition.ConditionType = DeterminatorRule.ConditionTypes.xPLMessage
                Dim x As New DeterminatorRule.DeterminatorCondition.xplCondition
                Select Case cmbMessageType.SelectedIndex
                    Case 0
                        x.msg_type = "cmnd"
                    Case 1
                        x.msg_type = "trig"
                    Case 2
                        x.msg_type = "stat"
                End Select
                ' Set the source
                If cmbSource.Text = "*" Then
                    x.source_vendor = "*"
                    x.source_device = "*"
                    x.source_instance = "*"
                Else
                    x.source_vendor = cmbSource.Text.Substring(0, cmbSource.Text.IndexOf("-"))
                    x.source_device = cmbSource.Text.Substring(0, cmbSource.Text.IndexOf("."))
                    x.source_device = x.source_device.Substring(x.source_device.IndexOf("-") + 1, x.source_device.Length - x.source_device.IndexOf("-") - 1)
                    x.source_instance = cmbSource.Text.Substring(cmbSource.Text.IndexOf(".") + 1, cmbSource.Text.Length - cmbSource.Text.IndexOf(".") - 1)
                End If

                ' Set target
                If cmbTarget.Text = "*" Then
                    x.target_vendor = "*"
                    x.target_device = "*"
                    x.target_instance = "*"
                Else
                    x.target_vendor = cmbTarget.Text.Substring(0, cmbTarget.Text.IndexOf("-"))
                    x.target_device = cmbTarget.Text.Substring(0, cmbTarget.Text.IndexOf("."))
                    x.target_device = x.target_device.Substring(x.target_device.IndexOf("-") + 1, x.target_device.Length - x.target_device.IndexOf("-") - 1)
                    x.target_instance = cmbTarget.Text.Substring(cmbTarget.Text.IndexOf(".") + 1, cmbTarget.Text.Length - cmbTarget.Text.IndexOf(".") - 1)
                End If

                ' Set schema
                x.schema_class = cmbSchema.Text.Substring(0, cmbSchema.Text.IndexOf("."))
                x.schema_type = cmbSchema.Text.Substring(cmbSchema.Text.IndexOf(".") + 1, cmbSchema.Text.Length - cmbSchema.Text.IndexOf(".") - 1)

                ' Body bits


                For Each entry As String In lstBody.Items
                    Dim paramparts() As String = Split(entry, "=")
                    If paramparts.Length >= 2 Then
                        Dim newparams As New xplConditionParams
                        newparams.Name = paramparts(0)
                        newparams.Operator = "="
                        newparams.Value = paramparts(1)
                        x.params.Add(newparams)

                    End If
                Next

                'ReDim x.params(lstBody.Items.Count - 1)
                'For counter As Integer = 0 To lstBody.Items.Count - 1
                '    x.params(counter) = New DeterminatorRule.DeterminatorCondition.xplCondition.xplConditionParams
                '    x.params(counter).Name = lstBody.Items(counter).ToString.Substring(0, lstBody.Items(counter).ToString.IndexOf(" "))
                '    x.params(counter).[Operator] = lstBody.Items(counter).ToString.Substring(lstBody.Items(counter).ToString.IndexOf(" ") + 1, lstBody.Items(counter).ToString.Length - lstBody.Items(counter).ToString.IndexOf(" ") - 1)
                '    x.params(counter).[Operator] = x.params(counter).[Operator].Substring(0, x.params(counter).[Operator].IndexOf(" "))
                '    x.params(counter).value = lstBody.Items(counter).ToString.Substring(lstBody.Items(counter).ToString.IndexOf(" ") + 1, lstBody.Items(counter).ToString.Length - lstBody.Items(counter).ToString.IndexOf(" ") - 1)
                '    x.params(counter).Value = x.params(counter).Value.Substring(x.params(counter).Value.IndexOf(" ") + 1, x.params(counter).Value.Length - x.params(counter).Value.IndexOf(" ") - 1)
                'Next
                myCondition.Condition = x
            Case 1 ' Global
                ' Validate form
                If cmbMessageType.Text = "" Then
                    MsgBox("You must select the global variable whose value you wish to check.", vbExclamation)
                    cmbMessageType.Focus()
                    Exit Sub
                End If
                If cmbSource.SelectedIndex < 0 Then
                    MsgBox("Please select a comparison operator.", vbExclamation)
                    cmbSource.Focus()
                    Exit Sub
                End If
                myCondition.ConditionType = DeterminatorRule.ConditionTypes.globalCondition
                Dim x As New DeterminatorRule.DeterminatorCondition.globalCondition
                x.Name = cmbMessageType.Text.ToUpper
                Select Case cmbSource.SelectedIndex
                    Case 0
                        x.[Operator] = "="
                    Case 1
                        x.[Operator] = "!="
                    Case 2
                        x.[Operator] = "<"
                    Case 3
                        x.[Operator] = ">"
                End Select
                x.Value = cmbTarget.Text
                If x.Name = "MODE" Then
                    x.Value = x.Value.ToUpper
                    If Not IsNumeric(x.Value) Then
                        ' Find a friendly mode
                        For Counter As Integer = 0 To globals.Modes.Length - 1
                            If globals.Modes(Counter).Name = x.Value Then
                                x.Value = Counter.ToString
                                Exit For
                            End If
                        Next
                    End If
                ElseIf x.Name = "PERIOD" Then
                    x.Value = x.Value.ToUpper
                    If Not IsNumeric(x.Value) Then
                        ' Find a friendly period
                        For Counter As Integer = 0 To globals.Periods.Length - 1
                            If globals.Periods(Counter).Name = x.Value Then
                                x.Value = Counter.ToString
                                Exit For
                            End If
                        Next
                    End If
                End If
                myCondition.Condition = x
            Case 2 ' Global changed
                myCondition.ConditionType = DeterminatorRule.ConditionTypes.globalChanged
                Dim x As New DeterminatorRule.DeterminatorCondition.globalChanged
                x.globalName = cmbMessageType.Text
                myCondition.Condition = x
            Case 3 ' Day of week
                myCondition.ConditionType = xplhalMgrBase.DeterminatorRule.ConditionTypes.dayCondition
                Dim x As New DeterminatorRule.DeterminatorCondition.dayCondition
                If chkSunday.Checked Then
                    x.DOW = "1"
                Else
                    x.DOW = "0"
                End If
                If chkMonday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                If chkTuesday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                If chkWednesday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                If chkThursday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                If chkFriday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                If chkSaturday.Checked Then
                    x.DOW &= "1"
                Else
                    x.DOW &= "0"
                End If
                myCondition.Condition = x
            Case 4 ' Time
                myCondition.ConditionType = DeterminatorRule.ConditionTypes.timeCondition
                Dim x As New DeterminatorRule.DeterminatorCondition.timeCondition
                Select Case cmbCompare.Text.ToUpper
                    Case "EQUAL TO"
                        x.[Operator] = "="
                    Case "NOT EQUAL TO"
                        x.[Operator] = "!="
                    Case "LESS THAN"
                        x.[Operator] = "<"
                    Case "GREATER THAN"
                        x.[Operator] = ">"
                End Select
                x.Value = dtpTime.Text
                If radDay.Checked Then
                    x.Category = "day"
                End If
                If radtime.Checked Then
                    x.Category = "time"
                End If
                If radDate.Checked Then
                    x.Category = "date"
                End If
                If radMonth.Checked Then
                    x.Category = "month"
                End If
                If radYear.Checked Then
                    x.Category = "year"
                End If
                myCondition.Condition = x
        End Select
        Me.DialogResult = Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub

    Private Sub HideAll()
        Me.Width = 464
        Me.Height = 504
        cmbMessageType.Visible = False
        cmbSource.Visible = False
        cmbTarget.Visible = False
        cmbSchema.Visible = False
        cmdAdd.Visible = False
        cmdRemove.Visible = False
        cmdEdit.Visible = False
        lstBody.Visible = False
        Label3.Visible = False
        Label4.Visible = False
        Label6.Visible = False
        PnlXpl.Visible = False
        PnlXpl.Location = PanelLoc
        PnlXpl.Size = PanelSize
        pnlDays.Visible = False
        pnlDays.Location = PanelLoc
        pnlDays.Size = PanelSize
        pnlCompareTime.Visible = False
        pnlCompareTime.Location = PanelLoc
        pnlCompareTime.Size = PanelSize

        'chkIsInitiator.Visible = False
    End Sub

    Private Sub cmbConditionType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbConditionType.SelectedIndexChanged
        Me.SuspendLayout()
        HideAll()
        Select Case cmbConditionType.SelectedIndex
            Case 0 ' xPL message
                PnlXpl.Visible = True

                cmbMessageType.Items.Clear()
                cmbSource.Items.Clear()
                cmbSource.Text = "*"
                cmbTarget.Items.Clear()
                'cmbSource.Location = New System.Drawing.Point(152, 112)        
                cmbTarget.Text = "*"
                ' Populate types of xPL message
                cmbMessageType.Items.Add("Command")
                cmbMessageType.Items.Add("Trigger")
                cmbMessageType.Items.Add("Status")
                ' Populate xPL sources and targets
                PopulateXplDevices(cmbSource)
                For Counter As Integer = 0 To cmbSource.Items.Count - 1
                    cmbTarget.Items.Add(cmbSource.Items(Counter))
                Next
                cmbMessageType.Visible = True
                cmbSource.DropDownStyle = ComboBoxStyle.DropDown
                cmbSource.Visible = True
                cmbTarget.Visible = True
                cmbSchema.Visible = True
                cmdAdd.Visible = True
                cmdRemove.Visible = True
                cmdEdit.Visible = True
                lstBody.Visible = True
                Label1.Text = "Message Type"
                Label1.Visible = True
                Label2.Text = "Source"
                Label2.Visible = True
                Label3.Text = "Target"
                Label3.Visible = True
                Label4.Text = "Schema"
                Label4.Visible = True
                Label6.Visible = True
            Case 1 ' Global
                PnlXpl.Visible = True
                'cmbSource.Location = New System.Drawing.Point(152, 72)
                cmbSource.Text = ""
                'cmbMessageType.Location = New System.Drawing.Point(152, 96)
                'cmbTarget.Location = New System.Drawing.Point(152, 120)
                cmbTarget.Text = ""
                Label1.Text = "Global Name"
                Label1.Visible = True
                Label2.Text = "Condition"
                Label2.Visible = True
                Label3.Text = "Value"
                Label3.Visible = True

                cmbSource.DropDownStyle = ComboBoxStyle.DropDownList
                cmbSource.Items.Clear()
                cmbSource.Visible = True
                PopulateComparisonCombo(cmbSource)

                cmbMessageType.DropDownStyle = ComboBoxStyle.DropDown
                cmbMessageType.Items.Clear()
                cmbMessageType.Visible = True
                PopulateGlobals(cmbMessageType)

                cmbTarget.Items.Clear()
                cmbTarget.Visible = True

            Case 2 ' Global changed                        
                'cmbSource.Location = New System.Drawing.Point(152, 88)
                PnlXpl.Visible = True
                cmbSource.Text = ""
                cmbSource.DropDownStyle = ComboBoxStyle.DropDown
                Label1.Text = "Global Name"
                Label1.Visible = True
                Label2.Visible = False
                cmbMessageType.Items.Clear()
                cmbMessageType.Visible = True
                PopulateGlobals(cmbMessageType)
            Case 3 ' pick yer days
                pnlDays.Visible = True
            Case 4 ' compare time
                pnlCompareTime.Visible = True
        End Select
        Me.ResumeLayout()
    End Sub

    Private Sub cmdAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAdd.Click
        Dim f As New frmNewBodyBits
        If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
            Dim s As String
            s = f.cmbName.Text & " "
            Select Case f.cmbOperator.SelectedIndex
                Case 0
                    s &= "="
                Case 1
                    s &= "!="
                Case 2
                    s &= "<"
                Case 3
                    s &= ">"
            End Select
            s &= " " & f.txtValue.Text
            lstBody.Items.Add(s)
        End If
    End Sub

    Private Sub cmdRemove_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRemove.Click
        If lstBody.SelectedIndex >= 0 Then
            lstBody.Items.Remove(lstBody.Items(lstBody.SelectedIndex))
        End If
    End Sub

    Private Sub cmbSource_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbSource.SelectedIndexChanged
        Select Case cmbConditionType.SelectedIndex
            Case 0 ' xPL message
                ' Find schema for this device
                For COunter As Integer = 0 To globals.Plugins.Length - 1
                    If cmbSource.Text.ToUpper.StartsWith(globals.Plugins(COunter).DeviceID) Then
                        cmbSchema.Items.Clear()
                        For Counter2 As Integer = 0 To globals.Plugins(COunter).Triggers.Length - 1
                            ' Ensure we haven't already got it
                            Dim Found As Boolean = False
                            For COunter3 As Integer = 0 To cmbSchema.Items.Count - 1
                                If globals.Plugins(COunter).Triggers(Counter2).msg_schema = cmbSchema.Items(COunter3).ToString Then
                                    Found = True
                                    Exit For
                                End If
                            Next
                            If Not Found Then
                                cmbSchema.Items.Add(globals.Plugins(COunter).Triggers(Counter2).msg_schema)
                            End If
                        Next
                        Exit For
                    End If
                Next
            Case 2 ' Setting
                Dim str As String
                xplHalSend("LISTOPTIONS " & cmbSource.Text & vbCrLf)
                str = GetLine()
                If str.StartsWith("205") Then
                    cmbTarget.Items.Clear()
                    cmbTarget.Text = ""
                    str = GetLine()
                    While Not str = ("." & vbCrLf)
                        str = str.Replace(vbTab, " (").Replace(vbCrLf, "")
                        str &= ")"
                        cmbTarget.Items.Add(str)
                        str = GetLine()
                    End While
                End If
        End Select
    End Sub


    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
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

    Private Sub cmdEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEdit.Click
        If lstBody.SelectedIndex < 0 Then Exit Sub
        Dim s As String = lstBody.Text
        Dim f As New frmNewBodyBits
        f.cmbName.Text = s.Substring(0, s.IndexOf(" "))
        Select Case s.Substring(s.IndexOf(" ") + 1, 1)
            Case "="
                f.cmbOperator.SelectedIndex = 0
            Case "!"
                f.cmbOperator.SelectedIndex = 1
            Case "<"
                f.cmbOperator.SelectedIndex = 2
            Case ">"
                f.cmbOperator.SelectedIndex = 3
        End Select
        s = s.Substring(s.IndexOf(" ") + 1, s.Length - s.IndexOf(" ") - 1)
        s = s.Substring(s.IndexOf(" ") + 1, s.Length - s.IndexOf(" ") - 1)
        f.txtValue.Text = s
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            s = f.cmbName.Text & " "
            Select Case f.cmbOperator.SelectedIndex
                Case 0
                    s &= "="
                Case 1
                    s &= "!="
                Case 2
                    s &= "<"
                Case 3
                    s &= ">"
            End Select
            s &= " " & f.txtValue.Text
            lstBody.Items(lstBody.SelectedIndex) = s
        End If
    End Sub

    Private Sub lstBody_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lstBody.SelectedIndexChanged
        If lstBody.SelectedItems.Count > 0 Then
            cmdEdit.Enabled = True
            cmdRemove.Enabled = True
        Else
            cmdEdit.Enabled = False
            cmdRemove.Enabled = False
        End If
    End Sub


    Private Sub radtime_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radtime.CheckedChanged
        lblCompareTime.Text = "Time"
        dtpTime.CustomFormat = "HH:mm"
        dtpTime.ShowUpDown = True
    End Sub
    Private Sub radDate_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radDate.CheckedChanged
        lblCompareTime.Text = "Date"
        dtpTime.CustomFormat = "d MMM yyyy"
        dtpTime.ShowUpDown = False
    End Sub
    Private Sub radDay_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radDay.CheckedChanged
        lblCompareTime.Text = "Day"
        dtpTime.CustomFormat = "d"
        dtpTime.ShowUpDown = True
    End Sub
    Private Sub radMonth_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radMonth.CheckedChanged
        lblCompareTime.Text = "Month"
        dtpTime.CustomFormat = "MMMM"
        dtpTime.ShowUpDown = False
    End Sub
    Private Sub radYear_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radYear.CheckedChanged
        lblCompareTime.Text = "Year"
        dtpTime.CustomFormat = "yyyy"
        dtpTime.ShowUpDown = True
    End Sub
End Class
