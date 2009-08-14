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

Public Class frmEditDeterminatorAction
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
  Friend WithEvents cmdAdd As System.Windows.Forms.Button
  Friend WithEvents cmdRemove As System.Windows.Forms.Button
  Friend WithEvents cmdCancel As System.Windows.Forms.Button
  Friend WithEvents cmdOK As System.Windows.Forms.Button
  Friend WithEvents Label6 As System.Windows.Forms.Label
  Friend WithEvents lstBody As System.Windows.Forms.ListBox
  Friend WithEvents Label5 As System.Windows.Forms.Label
  Friend WithEvents Label4 As System.Windows.Forms.Label
  Friend WithEvents Label3 As System.Windows.Forms.Label
  Friend WithEvents Label2 As System.Windows.Forms.Label
  Friend WithEvents Label1 As System.Windows.Forms.Label
  Friend WithEvents txtName As System.Windows.Forms.TextBox
  Friend WithEvents cmbConditionType As System.Windows.Forms.ComboBox
  Friend WithEvents cmbSchema As System.Windows.Forms.ComboBox
  Friend WithEvents cmbTarget As System.Windows.Forms.ComboBox
  Friend WithEvents cmbSource As System.Windows.Forms.ComboBox
  Friend WithEvents cmbMessageType As System.Windows.Forms.ComboBox
  Friend WithEvents Label7 As System.Windows.Forms.Label
  Friend WithEvents pnlSendxpl As System.Windows.Forms.Panel
  Friend WithEvents pnlPause As System.Windows.Forms.Panel
  Friend WithEvents pnlSetGlobal As System.Windows.Forms.Panel
  Friend WithEvents pnlExecuteRule As System.Windows.Forms.Panel
  Friend WithEvents pnlRunScript As System.Windows.Forms.Panel
  Friend WithEvents pnlRunProgram As System.Windows.Forms.Panel
  Friend WithEvents Label8 As System.Windows.Forms.Label
  Friend WithEvents cmbGlobalName As System.Windows.Forms.ComboBox
  Friend WithEvents Label9 As System.Windows.Forms.Label
  Friend WithEvents txtProgramName As System.Windows.Forms.TextBox
  Friend WithEvents Label10 As System.Windows.Forms.Label
  Friend WithEvents txtProgramParameters As System.Windows.Forms.TextBox
  Friend WithEvents Label11 As System.Windows.Forms.Label
  Friend WithEvents chkProgramWait As System.Windows.Forms.CheckBox
  Friend WithEvents nudPauseSeconds As System.Windows.Forms.NumericUpDown
  Friend WithEvents Label12 As System.Windows.Forms.Label
  Friend WithEvents Label13 As System.Windows.Forms.Label
  Friend WithEvents cmbExecuteDeterminator As System.Windows.Forms.ComboBox
  Friend WithEvents txtScriptParameters As System.Windows.Forms.TextBox
  Friend WithEvents Label14 As System.Windows.Forms.Label
  Friend WithEvents Label15 As System.Windows.Forms.Label
  Friend WithEvents cmbRunScript As System.Windows.Forms.ComboBox
  Friend WithEvents cmdDownAction As System.Windows.Forms.Button
  Friend WithEvents cmdUpAction As System.Windows.Forms.Button
  Friend WithEvents txtTextToLog As System.Windows.Forms.TextBox
  Friend WithEvents Label16 As System.Windows.Forms.Label
  Friend WithEvents pnlAddToLog As System.Windows.Forms.Panel
  Friend WithEvents cmdEdit As System.Windows.Forms.Button
  Friend WithEvents pnlSuspend As System.Windows.Forms.Panel
  Friend WithEvents Label19 As System.Windows.Forms.Label
  Friend WithEvents radSuspendUntil As System.Windows.Forms.RadioButton
  Friend WithEvents radSuspendFor As System.Windows.Forms.RadioButton
  Friend WithEvents lblSuspend As System.Windows.Forms.Label
  Friend WithEvents nudRandomisation As System.Windows.Forms.NumericUpDown
  Friend WithEvents dtpSuspend As System.Windows.Forms.DateTimePicker
  Friend WithEvents Label17 As System.Windows.Forms.Label
  Friend WithEvents Label18 As System.Windows.Forms.Label
  Friend WithEvents cmbGlobalValue As System.Windows.Forms.ComboBox
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmEditDeterminatorAction))
		Me.cmdAdd = New System.Windows.Forms.Button
		Me.cmdRemove = New System.Windows.Forms.Button
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.Label6 = New System.Windows.Forms.Label
		Me.lstBody = New System.Windows.Forms.ListBox
		Me.Label5 = New System.Windows.Forms.Label
		Me.Label4 = New System.Windows.Forms.Label
		Me.Label3 = New System.Windows.Forms.Label
		Me.Label2 = New System.Windows.Forms.Label
		Me.Label1 = New System.Windows.Forms.Label
		Me.txtName = New System.Windows.Forms.TextBox
		Me.cmbConditionType = New System.Windows.Forms.ComboBox
		Me.cmbSchema = New System.Windows.Forms.ComboBox
		Me.cmbTarget = New System.Windows.Forms.ComboBox
		Me.cmbSource = New System.Windows.Forms.ComboBox
		Me.cmbMessageType = New System.Windows.Forms.ComboBox
		Me.Label7 = New System.Windows.Forms.Label
		Me.pnlSendxpl = New System.Windows.Forms.Panel
		Me.cmdEdit = New System.Windows.Forms.Button
		Me.cmdDownAction = New System.Windows.Forms.Button
		Me.cmdUpAction = New System.Windows.Forms.Button
		Me.pnlPause = New System.Windows.Forms.Panel
		Me.Label12 = New System.Windows.Forms.Label
		Me.nudPauseSeconds = New System.Windows.Forms.NumericUpDown
		Me.pnlSetGlobal = New System.Windows.Forms.Panel
		Me.cmbGlobalValue = New System.Windows.Forms.ComboBox
		Me.Label9 = New System.Windows.Forms.Label
		Me.Label8 = New System.Windows.Forms.Label
		Me.cmbGlobalName = New System.Windows.Forms.ComboBox
		Me.pnlExecuteRule = New System.Windows.Forms.Panel
		Me.Label13 = New System.Windows.Forms.Label
		Me.cmbExecuteDeterminator = New System.Windows.Forms.ComboBox
		Me.pnlRunScript = New System.Windows.Forms.Panel
		Me.cmbRunScript = New System.Windows.Forms.ComboBox
		Me.txtScriptParameters = New System.Windows.Forms.TextBox
		Me.Label14 = New System.Windows.Forms.Label
		Me.Label15 = New System.Windows.Forms.Label
		Me.pnlAddToLog = New System.Windows.Forms.Panel
		Me.txtTextToLog = New System.Windows.Forms.TextBox
		Me.Label16 = New System.Windows.Forms.Label
		Me.pnlRunProgram = New System.Windows.Forms.Panel
		Me.chkProgramWait = New System.Windows.Forms.CheckBox
		Me.txtProgramParameters = New System.Windows.Forms.TextBox
		Me.Label11 = New System.Windows.Forms.Label
		Me.txtProgramName = New System.Windows.Forms.TextBox
		Me.Label10 = New System.Windows.Forms.Label
		Me.pnlSuspend = New System.Windows.Forms.Panel
		Me.Label18 = New System.Windows.Forms.Label
		Me.Label17 = New System.Windows.Forms.Label
		Me.radSuspendFor = New System.Windows.Forms.RadioButton
		Me.radSuspendUntil = New System.Windows.Forms.RadioButton
		Me.Label19 = New System.Windows.Forms.Label
		Me.nudRandomisation = New System.Windows.Forms.NumericUpDown
		Me.dtpSuspend = New System.Windows.Forms.DateTimePicker
		Me.lblSuspend = New System.Windows.Forms.Label
		Me.pnlSendxpl.SuspendLayout()
		Me.pnlPause.SuspendLayout()
		CType(Me.nudPauseSeconds, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.pnlSetGlobal.SuspendLayout()
		Me.pnlExecuteRule.SuspendLayout()
		Me.pnlRunScript.SuspendLayout()
		Me.pnlAddToLog.SuspendLayout()
		Me.pnlRunProgram.SuspendLayout()
		Me.pnlSuspend.SuspendLayout()
		CType(Me.nudRandomisation, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.SuspendLayout()
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
		'cmdRemove
		'
		Me.cmdRemove.Anchor = System.Windows.Forms.AnchorStyles.Right
		Me.cmdRemove.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdRemove.Location = New System.Drawing.Point(368, 176)
		Me.cmdRemove.Name = "cmdRemove"
		Me.cmdRemove.TabIndex = 7
		Me.cmdRemove.Text = "Remove"
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(1138, 610)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 9
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(1050, 610)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 8
		Me.cmdOK.Text = "OK"
		'
		'Label6
		'
		Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label6.Location = New System.Drawing.Point(40, 112)
		Me.Label6.Name = "Label6"
		Me.Label6.Size = New System.Drawing.Size(100, 40)
		Me.Label6.TabIndex = 27
		Me.Label6.Text = "Message Parameters"
		Me.Label6.TextAlign = System.Drawing.ContentAlignment.TopRight
		'
		'lstBody
		'
		Me.lstBody.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lstBody.Location = New System.Drawing.Point(144, 112)
		Me.lstBody.Name = "lstBody"
		Me.lstBody.Size = New System.Drawing.Size(216, 210)
		Me.lstBody.TabIndex = 4
		'
		'Label5
		'
		Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label5.Location = New System.Drawing.Point(16, 40)
		Me.Label5.Name = "Label5"
		Me.Label5.Size = New System.Drawing.Size(128, 23)
		Me.Label5.TabIndex = 25
		Me.Label5.Text = "Action Type"
		Me.Label5.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label4
		'
		Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label4.Location = New System.Drawing.Point(8, 80)
		Me.Label4.Name = "Label4"
		Me.Label4.Size = New System.Drawing.Size(128, 23)
		Me.Label4.TabIndex = 24
		Me.Label4.Text = "Schema"
		Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label3
		'
		Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label3.Location = New System.Drawing.Point(8, 56)
		Me.Label3.Name = "Label3"
		Me.Label3.Size = New System.Drawing.Size(128, 23)
		Me.Label3.TabIndex = 23
		Me.Label3.Text = "Target"
		Me.Label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label2
		'
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Location = New System.Drawing.Point(8, 32)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(128, 23)
		Me.Label2.TabIndex = 22
		Me.Label2.Text = "Source"
		Me.Label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 8)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(128, 23)
		Me.Label1.TabIndex = 21
		Me.Label1.Text = "Message Type"
		Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtName
		'
		Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtName.Location = New System.Drawing.Point(152, 8)
		Me.txtName.Name = "txtName"
		Me.txtName.Size = New System.Drawing.Size(216, 20)
		Me.txtName.TabIndex = 8
		Me.txtName.Text = ""
		'
		'cmbConditionType
		'
		Me.cmbConditionType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbConditionType.Location = New System.Drawing.Point(152, 40)
		Me.cmbConditionType.Name = "cmbConditionType"
		Me.cmbConditionType.Size = New System.Drawing.Size(216, 21)
		Me.cmbConditionType.TabIndex = 0
		'
		'cmbSchema
		'
		Me.cmbSchema.Location = New System.Drawing.Point(144, 80)
		Me.cmbSchema.Name = "cmbSchema"
		Me.cmbSchema.Size = New System.Drawing.Size(216, 21)
		Me.cmbSchema.Sorted = True
		Me.cmbSchema.TabIndex = 3
		'
		'cmbTarget
		'
		Me.cmbTarget.Location = New System.Drawing.Point(144, 56)
		Me.cmbTarget.Name = "cmbTarget"
		Me.cmbTarget.Size = New System.Drawing.Size(216, 21)
		Me.cmbTarget.Sorted = True
		Me.cmbTarget.TabIndex = 2
		'
		'cmbSource
		'
		Me.cmbSource.Enabled = False
		Me.cmbSource.Location = New System.Drawing.Point(144, 32)
		Me.cmbSource.Name = "cmbSource"
		Me.cmbSource.Size = New System.Drawing.Size(216, 21)
		Me.cmbSource.Sorted = True
		Me.cmbSource.TabIndex = 1
		'
		'cmbMessageType
		'
		Me.cmbMessageType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbMessageType.Location = New System.Drawing.Point(144, 8)
		Me.cmbMessageType.Name = "cmbMessageType"
		Me.cmbMessageType.Size = New System.Drawing.Size(216, 21)
		Me.cmbMessageType.TabIndex = 0
		'
		'Label7
		'
		Me.Label7.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label7.Location = New System.Drawing.Point(16, 8)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(128, 23)
		Me.Label7.TabIndex = 28
		Me.Label7.Text = "Action Name"
		Me.Label7.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'pnlSendxpl
		'
		Me.pnlSendxpl.Controls.Add(Me.cmdEdit)
		Me.pnlSendxpl.Controls.Add(Me.cmdDownAction)
		Me.pnlSendxpl.Controls.Add(Me.cmdUpAction)
		Me.pnlSendxpl.Controls.Add(Me.Label6)
		Me.pnlSendxpl.Controls.Add(Me.lstBody)
		Me.pnlSendxpl.Controls.Add(Me.Label4)
		Me.pnlSendxpl.Controls.Add(Me.Label3)
		Me.pnlSendxpl.Controls.Add(Me.Label2)
		Me.pnlSendxpl.Controls.Add(Me.Label1)
		Me.pnlSendxpl.Controls.Add(Me.cmbSchema)
		Me.pnlSendxpl.Controls.Add(Me.cmbTarget)
		Me.pnlSendxpl.Controls.Add(Me.cmbSource)
		Me.pnlSendxpl.Controls.Add(Me.cmbMessageType)
		Me.pnlSendxpl.Controls.Add(Me.cmdAdd)
		Me.pnlSendxpl.Controls.Add(Me.cmdRemove)
		Me.pnlSendxpl.Location = New System.Drawing.Point(8, 64)
		Me.pnlSendxpl.Name = "pnlSendxpl"
		Me.pnlSendxpl.Size = New System.Drawing.Size(448, 344)
		Me.pnlSendxpl.TabIndex = 29
		Me.pnlSendxpl.Visible = False
		'
		'cmdEdit
		'
		Me.cmdEdit.Anchor = System.Windows.Forms.AnchorStyles.Right
		Me.cmdEdit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdEdit.Location = New System.Drawing.Point(368, 144)
		Me.cmdEdit.Name = "cmdEdit"
		Me.cmdEdit.TabIndex = 6
		Me.cmdEdit.Text = "Edit"
		'
		'cmdDownAction
		'
		Me.cmdDownAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdDownAction.Location = New System.Drawing.Point(368, 248)
		Me.cmdDownAction.Name = "cmdDownAction"
		Me.cmdDownAction.TabIndex = 9
		Me.cmdDownAction.Text = "&Down"
		'
		'cmdUpAction
		'
		Me.cmdUpAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdUpAction.Location = New System.Drawing.Point(368, 216)
		Me.cmdUpAction.Name = "cmdUpAction"
		Me.cmdUpAction.TabIndex = 8
		Me.cmdUpAction.Text = "&Up"
		'
		'pnlPause
		'
		Me.pnlPause.Controls.Add(Me.Label12)
		Me.pnlPause.Controls.Add(Me.nudPauseSeconds)
		Me.pnlPause.Location = New System.Drawing.Point(8, 280)
		Me.pnlPause.Name = "pnlPause"
		Me.pnlPause.Size = New System.Drawing.Size(368, 344)
		Me.pnlPause.TabIndex = 30
		Me.pnlPause.Visible = False
		'
		'Label12
		'
		Me.Label12.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label12.Location = New System.Drawing.Point(40, 8)
		Me.Label12.Name = "Label12"
		Me.Label12.Size = New System.Drawing.Size(96, 23)
		Me.Label12.TabIndex = 25
		Me.Label12.Text = "Number of seconds to wait"
		Me.Label12.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'nudPauseSeconds
		'
		Me.nudPauseSeconds.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.nudPauseSeconds.DecimalPlaces = 3
		Me.nudPauseSeconds.Location = New System.Drawing.Point(144, 8)
		Me.nudPauseSeconds.Maximum = New Decimal(New Integer() {60, 0, 0, 0})
		Me.nudPauseSeconds.Name = "nudPauseSeconds"
		Me.nudPauseSeconds.Size = New System.Drawing.Size(80, 20)
		Me.nudPauseSeconds.TabIndex = 0
		Me.nudPauseSeconds.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
		'
		'pnlSetGlobal
		'
		Me.pnlSetGlobal.Controls.Add(Me.cmbGlobalValue)
		Me.pnlSetGlobal.Controls.Add(Me.Label9)
		Me.pnlSetGlobal.Controls.Add(Me.Label8)
		Me.pnlSetGlobal.Controls.Add(Me.cmbGlobalName)
		Me.pnlSetGlobal.Location = New System.Drawing.Point(448, 8)
		Me.pnlSetGlobal.Name = "pnlSetGlobal"
		Me.pnlSetGlobal.Size = New System.Drawing.Size(368, 344)
		Me.pnlSetGlobal.TabIndex = 31
		Me.pnlSetGlobal.Visible = False
		'
		'cmbGlobalValue
		'
		Me.cmbGlobalValue.Location = New System.Drawing.Point(144, 40)
		Me.cmbGlobalValue.Name = "cmbGlobalValue"
		Me.cmbGlobalValue.Size = New System.Drawing.Size(216, 21)
		Me.cmbGlobalValue.TabIndex = 26
		'
		'Label9
		'
		Me.Label9.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label9.Location = New System.Drawing.Point(8, 40)
		Me.Label9.Name = "Label9"
		Me.Label9.Size = New System.Drawing.Size(128, 23)
		Me.Label9.TabIndex = 24
		Me.Label9.Text = "Value"
		Me.Label9.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label8
		'
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Location = New System.Drawing.Point(8, 8)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(128, 23)
		Me.Label8.TabIndex = 23
		Me.Label8.Text = "Global Name"
		Me.Label8.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'cmbGlobalName
		'
		Me.cmbGlobalName.Location = New System.Drawing.Point(144, 8)
		Me.cmbGlobalName.Name = "cmbGlobalName"
		Me.cmbGlobalName.Size = New System.Drawing.Size(216, 21)
		Me.cmbGlobalName.Sorted = True
		Me.cmbGlobalName.TabIndex = 22
		'
		'pnlExecuteRule
		'
		Me.pnlExecuteRule.Controls.Add(Me.Label13)
		Me.pnlExecuteRule.Controls.Add(Me.cmbExecuteDeterminator)
		Me.pnlExecuteRule.Location = New System.Drawing.Point(360, 400)
		Me.pnlExecuteRule.Name = "pnlExecuteRule"
		Me.pnlExecuteRule.Size = New System.Drawing.Size(368, 344)
		Me.pnlExecuteRule.TabIndex = 32
		Me.pnlExecuteRule.Visible = False
		'
		'Label13
		'
		Me.Label13.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label13.Location = New System.Drawing.Point(8, 8)
		Me.Label13.Name = "Label13"
		Me.Label13.Size = New System.Drawing.Size(128, 23)
		Me.Label13.TabIndex = 25
		Me.Label13.Text = "Execute this determinator"
		Me.Label13.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'cmbExecuteDeterminator
		'
		Me.cmbExecuteDeterminator.Location = New System.Drawing.Point(144, 8)
		Me.cmbExecuteDeterminator.Name = "cmbExecuteDeterminator"
		Me.cmbExecuteDeterminator.Size = New System.Drawing.Size(216, 21)
		Me.cmbExecuteDeterminator.Sorted = True
		Me.cmbExecuteDeterminator.TabIndex = 24
		'
		'pnlRunScript
		'
		Me.pnlRunScript.Controls.Add(Me.cmbRunScript)
		Me.pnlRunScript.Controls.Add(Me.txtScriptParameters)
		Me.pnlRunScript.Controls.Add(Me.Label14)
		Me.pnlRunScript.Controls.Add(Me.Label15)
		Me.pnlRunScript.Location = New System.Drawing.Point(832, 264)
		Me.pnlRunScript.Name = "pnlRunScript"
		Me.pnlRunScript.Size = New System.Drawing.Size(368, 344)
		Me.pnlRunScript.TabIndex = 33
		Me.pnlRunScript.Visible = False
		'
		'cmbRunScript
		'
		Me.cmbRunScript.Location = New System.Drawing.Point(144, 8)
		Me.cmbRunScript.Name = "cmbRunScript"
		Me.cmbRunScript.Size = New System.Drawing.Size(216, 21)
		Me.cmbRunScript.Sorted = True
		Me.cmbRunScript.TabIndex = 35
		'
		'txtScriptParameters
		'
		Me.txtScriptParameters.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtScriptParameters.Location = New System.Drawing.Point(144, 40)
		Me.txtScriptParameters.Name = "txtScriptParameters"
		Me.txtScriptParameters.Size = New System.Drawing.Size(216, 20)
		Me.txtScriptParameters.TabIndex = 34
		Me.txtScriptParameters.Text = ""
		'
		'Label14
		'
		Me.Label14.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label14.Location = New System.Drawing.Point(8, 40)
		Me.Label14.Name = "Label14"
		Me.Label14.Size = New System.Drawing.Size(128, 23)
		Me.Label14.TabIndex = 33
		Me.Label14.Text = "Parameters (optional)"
		Me.Label14.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'Label15
		'
		Me.Label15.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label15.Location = New System.Drawing.Point(8, 8)
		Me.Label15.Name = "Label15"
		Me.Label15.Size = New System.Drawing.Size(128, 23)
		Me.Label15.TabIndex = 31
		Me.Label15.Text = "Run this script"
		Me.Label15.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'pnlAddToLog
		'
		Me.pnlAddToLog.Controls.Add(Me.txtTextToLog)
		Me.pnlAddToLog.Controls.Add(Me.Label16)
		Me.pnlAddToLog.Location = New System.Drawing.Point(456, 160)
		Me.pnlAddToLog.Name = "pnlAddToLog"
		Me.pnlAddToLog.Size = New System.Drawing.Size(368, 344)
		Me.pnlAddToLog.TabIndex = 35
		Me.pnlAddToLog.Visible = False
		'
		'txtTextToLog
		'
		Me.txtTextToLog.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtTextToLog.Location = New System.Drawing.Point(144, 8)
		Me.txtTextToLog.Name = "txtTextToLog"
		Me.txtTextToLog.Size = New System.Drawing.Size(216, 20)
		Me.txtTextToLog.TabIndex = 25
		Me.txtTextToLog.Text = ""
		'
		'Label16
		'
		Me.Label16.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label16.Location = New System.Drawing.Point(8, 8)
		Me.Label16.Name = "Label16"
		Me.Label16.Size = New System.Drawing.Size(128, 23)
		Me.Label16.TabIndex = 24
		Me.Label16.Text = "Text to write to error log"
		Me.Label16.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'pnlRunProgram
		'
		Me.pnlRunProgram.Controls.Add(Me.chkProgramWait)
		Me.pnlRunProgram.Controls.Add(Me.txtProgramParameters)
		Me.pnlRunProgram.Controls.Add(Me.Label11)
		Me.pnlRunProgram.Controls.Add(Me.txtProgramName)
		Me.pnlRunProgram.Controls.Add(Me.Label10)
		Me.pnlRunProgram.Location = New System.Drawing.Point(832, 8)
		Me.pnlRunProgram.Name = "pnlRunProgram"
		Me.pnlRunProgram.Size = New System.Drawing.Size(368, 344)
		Me.pnlRunProgram.TabIndex = 34
		Me.pnlRunProgram.Visible = False
		'
		'chkProgramWait
		'
		Me.chkProgramWait.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkProgramWait.Location = New System.Drawing.Point(144, 72)
		Me.chkProgramWait.Name = "chkProgramWait"
		Me.chkProgramWait.Size = New System.Drawing.Size(216, 32)
		Me.chkProgramWait.TabIndex = 30
		Me.chkProgramWait.Text = "Wait for program to complete execution before continuing."
		'
		'txtProgramParameters
		'
		Me.txtProgramParameters.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtProgramParameters.Location = New System.Drawing.Point(144, 40)
		Me.txtProgramParameters.Name = "txtProgramParameters"
		Me.txtProgramParameters.Size = New System.Drawing.Size(216, 20)
		Me.txtProgramParameters.TabIndex = 29
		Me.txtProgramParameters.Text = ""
		'
		'Label11
		'
		Me.Label11.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label11.Location = New System.Drawing.Point(8, 40)
		Me.Label11.Name = "Label11"
		Me.Label11.Size = New System.Drawing.Size(128, 23)
		Me.Label11.TabIndex = 28
		Me.Label11.Text = "Parameters (optional)"
		Me.Label11.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'txtProgramName
		'
		Me.txtProgramName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtProgramName.Location = New System.Drawing.Point(144, 8)
		Me.txtProgramName.Name = "txtProgramName"
		Me.txtProgramName.Size = New System.Drawing.Size(216, 20)
		Me.txtProgramName.TabIndex = 27
		Me.txtProgramName.Text = ""
		'
		'Label10
		'
		Me.Label10.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label10.Location = New System.Drawing.Point(8, 8)
		Me.Label10.Name = "Label10"
		Me.Label10.Size = New System.Drawing.Size(128, 23)
		Me.Label10.TabIndex = 26
		Me.Label10.Text = "Program Name"
		Me.Label10.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'pnlSuspend
		'
		Me.pnlSuspend.Controls.Add(Me.Label18)
		Me.pnlSuspend.Controls.Add(Me.Label17)
		Me.pnlSuspend.Controls.Add(Me.radSuspendFor)
		Me.pnlSuspend.Controls.Add(Me.radSuspendUntil)
		Me.pnlSuspend.Controls.Add(Me.Label19)
		Me.pnlSuspend.Controls.Add(Me.nudRandomisation)
		Me.pnlSuspend.Controls.Add(Me.dtpSuspend)
		Me.pnlSuspend.Controls.Add(Me.lblSuspend)
		Me.pnlSuspend.Location = New System.Drawing.Point(448, 264)
		Me.pnlSuspend.Name = "pnlSuspend"
		Me.pnlSuspend.Size = New System.Drawing.Size(368, 344)
		Me.pnlSuspend.TabIndex = 36
		Me.pnlSuspend.Visible = False
		'
		'Label18
		'
		Me.Label18.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label18.Location = New System.Drawing.Point(232, 112)
		Me.Label18.Name = "Label18"
		Me.Label18.Size = New System.Drawing.Size(84, 20)
		Me.Label18.TabIndex = 33
		Me.Label18.Text = "(minutes)"
		Me.Label18.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
		'
		'Label17
		'
		Me.Label17.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label17.Location = New System.Drawing.Point(232, 80)
		Me.Label17.Name = "Label17"
		Me.Label17.Size = New System.Drawing.Size(84, 20)
		Me.Label17.TabIndex = 32
		Me.Label17.Text = "(hours:minutes)"
		Me.Label17.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
		'
		'radSuspendFor
		'
		Me.radSuspendFor.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radSuspendFor.Location = New System.Drawing.Point(32, 16)
		Me.radSuspendFor.Name = "radSuspendFor"
		Me.radSuspendFor.Size = New System.Drawing.Size(248, 16)
		Me.radSuspendFor.TabIndex = 31
		Me.radSuspendFor.Text = "Suspend execution for a specified period."
		'
		'radSuspendUntil
		'
		Me.radSuspendUntil.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radSuspendUntil.Location = New System.Drawing.Point(32, 40)
		Me.radSuspendUntil.Name = "radSuspendUntil"
		Me.radSuspendUntil.Size = New System.Drawing.Size(264, 16)
		Me.radSuspendUntil.TabIndex = 30
		Me.radSuspendUntil.Text = "Suspend execution until a specified time."
		'
		'Label19
		'
		Me.Label19.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label19.Location = New System.Drawing.Point(8, 112)
		Me.Label19.Name = "Label19"
		Me.Label19.Size = New System.Drawing.Size(136, 20)
		Me.Label19.TabIndex = 29
		Me.Label19.Text = "Randomisation"
		Me.Label19.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'nudRandomisation
		'
		Me.nudRandomisation.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.nudRandomisation.Location = New System.Drawing.Point(144, 112)
		Me.nudRandomisation.Maximum = New Decimal(New Integer() {60, 0, 0, 0})
		Me.nudRandomisation.Name = "nudRandomisation"
		Me.nudRandomisation.Size = New System.Drawing.Size(80, 20)
		Me.nudRandomisation.TabIndex = 28
		'
		'dtpSuspend
		'
		Me.dtpSuspend.CustomFormat = "HH:mm"
		Me.dtpSuspend.Format = System.Windows.Forms.DateTimePickerFormat.Custom
		Me.dtpSuspend.Location = New System.Drawing.Point(144, 80)
		Me.dtpSuspend.Name = "dtpSuspend"
		Me.dtpSuspend.ShowUpDown = True
		Me.dtpSuspend.Size = New System.Drawing.Size(80, 20)
		Me.dtpSuspend.TabIndex = 27
		'
		'lblSuspend
		'
		Me.lblSuspend.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblSuspend.Location = New System.Drawing.Point(8, 80)
		Me.lblSuspend.Name = "lblSuspend"
		Me.lblSuspend.Size = New System.Drawing.Size(136, 20)
		Me.lblSuspend.TabIndex = 26
		Me.lblSuspend.Text = "Suspend execution until"
		Me.lblSuspend.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'frmEditDeterminatorAction
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(1218, 639)
		Me.Controls.Add(Me.pnlExecuteRule)
		Me.Controls.Add(Me.pnlSuspend)
		Me.Controls.Add(Me.pnlAddToLog)
		Me.Controls.Add(Me.pnlPause)
		Me.Controls.Add(Me.pnlSendxpl)
		Me.Controls.Add(Me.pnlRunScript)
		Me.Controls.Add(Me.pnlRunProgram)
		Me.Controls.Add(Me.Label7)
		Me.Controls.Add(Me.txtName)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.Label5)
		Me.Controls.Add(Me.cmbConditionType)
		Me.Controls.Add(Me.pnlSetGlobal)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.MaximizeBox = False
		Me.Name = "frmEditDeterminatorAction"
		Me.Text = "Edit Determinator Action"
		Me.pnlSendxpl.ResumeLayout(False)
		Me.pnlPause.ResumeLayout(False)
		CType(Me.nudPauseSeconds, System.ComponentModel.ISupportInitialize).EndInit()
		Me.pnlSetGlobal.ResumeLayout(False)
		Me.pnlExecuteRule.ResumeLayout(False)
		Me.pnlRunScript.ResumeLayout(False)
		Me.pnlAddToLog.ResumeLayout(False)
		Me.pnlRunProgram.ResumeLayout(False)
		Me.pnlSuspend.ResumeLayout(False)
		CType(Me.nudRandomisation, System.ComponentModel.ISupportInitialize).EndInit()
		Me.ResumeLayout(False)

	End Sub

#End Region

  Public myAction As DeterminatorRule.DeterminatorAction

  Private Sub frmEditDeterminatorAction_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    Me.SuspendLayout()
    Me.Width = 464
    Me.Height = 464

    ' Populate the list of sub routines in the combo
    PopulateSubs(cmbRunScript)

    ' Populate the list of determinators in the combo
    PopulateDeterminators(cmbExecuteDeterminator)

    ' Populate types of action
    cmbConditionType.Items.Add("Send an xPL message")
    cmbConditionType.Items.Add("Set the value of a global variable")
    cmbConditionType.Items.Add("Execute a program")
    cmbConditionType.Items.Add("Pause")
    cmbConditionType.Items.Add("Execute another determinator")
    cmbConditionType.Items.Add("Execute a Script")
    cmbConditionType.Items.Add("Write to the error log")
    cmbConditionType.Items.Add("Suspend")

    If myAction.DisplayName Is Nothing Then
      ' It's a new action
      Me.Text = "Create New Action"
      cmbConditionType.SelectedIndex = 0
      txtName.Text = "New Action"
    Else
      ' We're editing an existing action
      Me.Text = "Edit Action"
      txtName.Text = myAction.DisplayName
      Select Case myAction.ActionType
        Case DeterminatorRule.DeterminatorAction.ActionTypes.delayAction
          cmbConditionType.SelectedIndex = 3
          Dim x As DeterminatorRule.DeterminatorAction.DelayAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.DelayAction)
          nudPauseSeconds.Text = CStr(x.DelaySeconds)
        Case DeterminatorRule.DeterminatorAction.ActionTypes.execRuleAction
          cmbConditionType.SelectedIndex = DeterminatorActionType.ExecuteRule
          Dim x As DeterminatorRule.DeterminatorAction.execRuleAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.execRuleAction)
          cmbExecuteDeterminator.Text = x.rulename
        Case DeterminatorRule.DeterminatorAction.ActionTypes.executeAction
          cmbConditionType.SelectedIndex = DeterminatorActionType.RunEXE
          Dim x As DeterminatorRule.DeterminatorAction.executeAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.executeAction)
          txtProgramName.Text = x.Program
          txtProgramParameters.Text = x.parameters
          chkProgramWait.Checked = x.wait
        Case DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
          cmbConditionType.SelectedIndex = DeterminatorActionType.SetGlobal
          Dim x As DeterminatorRule.DeterminatorAction.globalAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.globalAction)
          cmbGlobalName.Text = x.Name
          cmbGlobalValue.Text = x.value
        Case DeterminatorRule.DeterminatorAction.ActionTypes.logAction
          cmbConditionType.SelectedIndex = DeterminatorActionType.ExecuteScript + 1
          Dim x As DeterminatorRule.DeterminatorAction.logAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.logAction)
          txtTextToLog.Text = x.logtext
        Case DeterminatorRule.DeterminatorAction.ActionTypes.runScriptAction
          cmbConditionType.SelectedIndex = DeterminatorActionType.ExecuteScript
          Dim x As DeterminatorRule.DeterminatorAction.RunScriptAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.RunScriptAction)
          cmbRunScript.Text = x.scriptname
          txtScriptParameters.Text = x.parameters
        Case DeterminatorRule.DeterminatorAction.ActionTypes.xplAction
          cmbConditionType.SelectedIndex = 0
          Dim x As DeterminatorRule.DeterminatorAction.xplAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.xplAction)
          Select Case x.msg_type
            Case "cmnd"
              cmbMessageType.SelectedIndex = 0
            Case "trig"
              cmbMessageType.SelectedIndex = 1
            Case "stat"
              cmbMessageType.SelectedIndex = 2
          End Select
          cmbTarget.Text = x.msg_target
          cmbSchema.Text = x.msg_schema
          For Counter As Integer = 0 To x.params.Length - 1
            lstBody.Items.Add(x.params(Counter))
          Next
        Case DeterminatorRule.DeterminatorAction.ActionTypes.suspendAction
          cmbConditionType.SelectedIndex = 7
          Dim x As DeterminatorRule.DeterminatorAction.suspendAction = CType(myAction.Action, DeterminatorRule.DeterminatorAction.suspendAction)
          If x.SuspendMinutes > 0 Then
            Dim h, m As Integer
            radSuspendFor.Checked = True
            m = x.SuspendMinutes Mod 60
            h = CInt(Int(x.SuspendMinutes / 60))
            dtpSuspend.Value = CDate("01/01/2000 " & h.ToString & ":" & m.ToString)
          Else
            radSuspendUntil.Checked = True
            dtpSuspend.Value = CDate(x.SuspendTime)
          End If
          nudRandomisation.Value = x.SuspendRandomise

        Case Else
          MsgBox("Action type not supported.", MsgBoxStyle.Critical)
          Me.Close()
      End Select
    End If
    ' Populate targets
    connectToXplHal()
    populateXplDevices(cmbTarget)
    disconnect()
    Me.ResumeLayout()
  End Sub

  Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
    ' Ensure a name for the action has been entered
    If txtName.Text.Trim.Length = 0 Then
      MsgBox("You must enter a name for this action.", vbExclamation)
      Exit Sub
    End If

    myAction.DisplayName = txtName.Text

    Select Case cmbConditionType.Text
      Case "Send an xPL message"
        Dim x As New DeterminatorRule.DeterminatorAction.xplAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.xplAction
        Select Case cmbMessageType.SelectedIndex
          Case 0 ' Command
            x.msg_type = "cmnd"
          Case 1 ' Trigger
            x.msg_type = "trig"
          Case 2 ' Status
            x.msg_type = "stat"
        End Select
        x.msg_target = cmbTarget.Text
        x.msg_schema = cmbSchema.Text
        ReDim x.params(lstBody.Items.Count - 1)
        For Counter As Integer = 0 To lstBody.Items.Count - 1
          x.params(Counter) = lstBody.Items(Counter).ToString
        Next
        myAction.Action = x
      Case "Set the value of a global variable"
        If cmbGlobalName.Text = "" Then
          MsgBox("Please select a global variable.", vbExclamation)
          Exit Sub
        End If
        Dim x As New DeterminatorRule.DeterminatorAction.globalAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
        x.Name = cmbGlobalName.Text
        x.Value = cmbGlobalValue.Text
        myAction.Action = x
      Case "Execute another determinator"
        Dim x As New DeterminatorRule.DeterminatorAction.execRuleAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.execRuleAction
        x.RuleName = cmbExecuteDeterminator.Text
        myAction.Action = x
      Case "Execute a Script"
        Dim x As New DeterminatorRule.DeterminatorAction.RunScriptAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.runScriptAction
        x.ScriptName = cmbRunScript.Text
        x.Parameters = txtScriptParameters.Text
        myAction.Action = x
      Case "Write to the error log"
        Dim x As New DeterminatorRule.DeterminatorAction.logAction
        x.logText = txtTextToLog.Text
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.logAction
        myAction.Action = x
      Case "Pause"
        Dim x As New DeterminatorRule.DeterminatorAction.DelayAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.delayAction
        x.DelaySeconds = CDbl(nudPauseSeconds.Value)
        myAction.Action = x
      Case "Execute a program"
        Dim x As New DeterminatorRule.DeterminatorAction.executeAction
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.executeAction
        x.Program = txtProgramName.Text
        x.Parameters = txtProgramParameters.Text
        x.Wait = chkProgramWait.Checked
        myAction.Action = x
      Case "Suspend"
        Dim x As New DeterminatorRule.DeterminatorAction.suspendAction
        Dim a As Integer
        myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.suspendAction
        If radSuspendUntil.Checked Then
          x.SuspendMinutes = 0
          x.SuspendTime = dtpSuspend.Value.ToString
        Else
          a = Hour(dtpSuspend.Value) * 60 + Minute(dtpSuspend.Value)
          If a > 0 Then
            x.SuspendMinutes = a
          Else
            MsgBox("Suspend period may not be zero.")
            Exit Sub
          End If
        End If
        x.SuspendRandomise = CInt(nudRandomisation.Value)
        myAction.Action = x
      Case Else
        MsgBox("The selected action is not supported.", vbCritical)
        Exit Sub
    End Select
        Me.DialogResult = Windows.Forms.DialogResult.OK
    Me.Close()
  End Sub

  Private Sub cmbConditionType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbConditionType.SelectedIndexChanged
    Me.SuspendLayout()
    Dim PanelPos As Point
    PanelPos.X = 8
    PanelPos.Y = 64
		'Const PanelTop As Integer = 64
		'Const Panelleft As Integer = 64
    pnlSendxpl.Visible = False
    pnlSetGlobal.Visible = False
    pnlRunProgram.Visible = False
    pnlPause.Visible = False
    pnlExecuteRule.Visible = False
    pnlRunScript.Visible = False
    pnlAddToLog.Visible = False
    pnlSuspend.Visible = False
    pnlSendxpl.Location = PanelPos
    pnlSetGlobal.Location = PanelPos
    pnlRunProgram.Location = PanelPos
    pnlPause.Location = PanelPos
    pnlExecuteRule.Location = PanelPos
    pnlRunScript.Location = PanelPos
    pnlAddToLog.Location = PanelPos
    pnlSuspend.Location = PanelPos
    cmbMessageType.Items.Clear()
    cmbTarget.Items.Clear()
    cmbTarget.Text = ""
    Select Case cmbConditionType.Text
      Case "Send an xPL message"
        pnlSendxpl.Visible = True
        ' Populate types of xPL message
        cmbMessageType.Items.Clear()
        cmbMessageType.Items.Add("Command")
        cmbMessageType.Items.Add("Trigger")
        cmbMessageType.Items.Add("Status")
        populateTargets(cmbTarget)
      Case "Set the value of a global variable"
        populateglobals(cmbGlobalName)
        pnlSetGlobal.Visible = True
      Case "Execute a program"
        pnlRunProgram.Visible = True
      Case "Pause"
        pnlPause.Visible = True
      Case "Execute another determinator"
        pnlExecuteRule.Visible = True
      Case "Execute a Script"
        pnlRunScript.Visible = True
      Case "Write to the error log"
        pnlAddToLog.Visible = True
      Case "Suspend"
        pnlSuspend.Visible = True
        radSuspendFor.Checked = True
    End Select
    Me.ResumeLayout()
  End Sub

  Private Sub cmdAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAdd.Click
    Dim f As New frmNewBodyBits
    f.cmbOperator.Visible = False
    f.Label3.Visible = False
    f.Label2.Location = f.Label3.Location
    f.txtValue.Location = f.cmbOperator.Location
        If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
            Dim s As String
            s = f.cmbName.Text & "="
            s &= f.txtValue.Text
            lstBody.Items.Add(s)
        End If
  End Sub

  Private Sub cmdRemove_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRemove.Click
    If lstBody.SelectedIndex >= 0 Then
      lstBody.Items.Remove(lstBody.Items(lstBody.SelectedIndex))
    End If
  End Sub


  Private Sub cmdUpAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdUpAction.Click
    If lstBody.SelectedItems.Count = 1 Then
      Dim I As Integer, lstItem As Object
      'li = lstActions.SelectedItems(0)
      I = lstBody.SelectedIndex
      lstItem = lstBody.Items(I)
      If I > 0 Then
        lstBody.Items.RemoveAt(lstBody.SelectedIndex)
        lstBody.Items.Insert(I - 1, lstItem)
        lstBody.SelectedIndex = I - 1
      End If
    End If
  End Sub


  Private Sub cmdDownAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdDownAction.Click
    If lstBody.SelectedItems.Count = 1 Then
      Dim I As Integer, lstItem As Object
      'li = lstActions.SelectedItems(0)
      I = lstBody.SelectedIndex
      lstItem = lstBody.Items(I)
      If I < lstBody.Items.Count - 1 Then
        lstBody.Items.RemoveAt(lstBody.SelectedIndex)
        lstBody.Items.Insert(I + 1, lstItem)
        lstBody.SelectedIndex = I + 1
      End If
    End If
  End Sub

  Private Sub cmbTarget_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbTarget.SelectedIndexChanged
    Select Case cmbConditionType.SelectedIndex
      Case 0 ' xPL message
        ' Find schema for this device
        For COunter As Integer = 0 To globals.Plugins.Length - 1
          If cmbTarget.Text.ToUpper.StartsWith(globals.Plugins(COunter).DeviceID) Then
            cmbSchema.Items.Clear()
            For Counter2 As Integer = 0 To globals.Plugins(COunter).Commands.Length - 1
              Dim Found As Boolean = False
              For COunter3 As Integer = 0 To cmbSchema.Items.Count - 1
                If globals.Plugins(COunter).Commands(Counter2).msg_schema = cmbSchema.Items(COunter3).ToString Then
                  Found = True
                  Exit For
                End If
              Next
              If Not Found Then
                cmbSchema.Items.Add(globals.Plugins(COunter).Commands(Counter2).msg_schema)
              End If
            Next
            Exit For
          End If
        Next
    End Select
  End Sub

  Private Sub cmdEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEdit.Click
    If lstBody.SelectedIndex < 0 Then Exit Sub
    Dim s As String = lstBody.Text
    Dim f As New frmNewBodyBits
    f.cmbOperator.Visible = False
    f.Label3.Visible = False
    f.Label2.Location = f.Label3.Location
    f.txtValue.Location = f.cmbOperator.Location
    f.cmbName.Text = s.Substring(0, s.IndexOf("="))
    s = s.Substring(s.IndexOf("=") + 1, s.Length - s.IndexOf("=") - 1)
    f.txtValue.Text = s
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            s = f.cmbName.Text & "="
            s &= f.txtValue.Text
            lstBody.Items(lstBody.SelectedIndex) = s
        End If
  End Sub

  Private Sub radSuspendUntil_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles radSuspendUntil.CheckedChanged, radSuspendFor.CheckedChanged
    If radSuspendUntil.Checked Then
      lblSuspend.Text = "Suspend execution until"
      dtpSuspend.Value = Now.AddMinutes(30)
    Else
      lblSuspend.Text = "Suspend execution for"
      dtpSuspend.Value = Today
    End If
  End Sub


  Private Sub cmbGlobalName_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbGlobalName.SelectedIndexChanged
    cmbGlobalValue.Items.Clear()
    Select Case cmbGlobalName.Text.ToUpper
      Case "MODE"
        For Counter As Integer = 0 To globals.Modes.Length - 1
          cmbGlobalValue.Items.Add(globals.Modes(Counter).Name)
        Next
      Case "PERIOD"
        For Counter As Integer = 0 To globals.Periods.Length - 1
          cmbGlobalValue.Items.Add(globals.Periods(Counter).Name)
        Next
    End Select
  End Sub


End Class
