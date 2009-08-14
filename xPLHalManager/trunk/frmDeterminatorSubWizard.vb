'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2004 John Bent & Ian Jeffery
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

Public Class frmDeterminatorSubWizard
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
    Friend WithEvents lstDevices As System.Windows.Forms.ListBox
    Friend WithEvents lstTriggers As System.Windows.Forms.ListBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents lblTitle As System.Windows.Forms.Label
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents pnlControls As System.Windows.Forms.Panel
    Friend WithEvents txtDescription As System.Windows.Forms.TextBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents txtName As System.Windows.Forms.TextBox
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents cmbGroup As System.Windows.Forms.ComboBox
    Friend WithEvents radGroup As System.Windows.Forms.RadioButton
    Friend WithEvents radAny As System.Windows.Forms.RadioButton
    Friend WithEvents radSpecifiedOnly As System.Windows.Forms.RadioButton
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmDeterminatorSubWizard))
        Me.lstDevices = New System.Windows.Forms.ListBox
        Me.lstTriggers = New System.Windows.Forms.ListBox
        Me.lblTitle = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.cmdOK = New System.Windows.Forms.Button
        Me.txtDescription = New System.Windows.Forms.TextBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.pnlControls = New System.Windows.Forms.Panel
        Me.Label4 = New System.Windows.Forms.Label
        Me.txtName = New System.Windows.Forms.TextBox
        Me.GroupBox1 = New System.Windows.Forms.GroupBox
        Me.cmbGroup = New System.Windows.Forms.ComboBox
        Me.radGroup = New System.Windows.Forms.RadioButton
        Me.radAny = New System.Windows.Forms.RadioButton
        Me.radSpecifiedOnly = New System.Windows.Forms.RadioButton
        Me.GroupBox1.SuspendLayout()
        Me.SuspendLayout()
        '
        'lstDevices
        '
        Me.lstDevices.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstDevices.Location = New System.Drawing.Point(8, 80)
        Me.lstDevices.Name = "lstDevices"
        Me.lstDevices.Size = New System.Drawing.Size(184, 145)
        Me.lstDevices.Sorted = True
        Me.lstDevices.TabIndex = 1
        '
        'lstTriggers
        '
        Me.lstTriggers.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstTriggers.Location = New System.Drawing.Point(208, 80)
        Me.lstTriggers.Name = "lstTriggers"
        Me.lstTriggers.Size = New System.Drawing.Size(184, 145)
        Me.lstTriggers.TabIndex = 2
        '
        'lblTitle
        '
        Me.lblTitle.Dock = System.Windows.Forms.DockStyle.Top
        Me.lblTitle.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.lblTitle.Font = New System.Drawing.Font("Verdana", 15.75!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.lblTitle.Location = New System.Drawing.Point(0, 0)
        Me.lblTitle.Name = "lblTitle"
        Me.lblTitle.Size = New System.Drawing.Size(650, 32)
        Me.lblTitle.TabIndex = 2
        Me.lblTitle.Text = "change me"
        '
        'Label2
        '
        Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label2.Location = New System.Drawing.Point(8, 64)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(184, 16)
        Me.Label2.TabIndex = 3
        Me.Label2.Text = "Devices"
        '
        'Label3
        '
        Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label3.Location = New System.Drawing.Point(208, 64)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(184, 16)
        Me.Label3.TabIndex = 4
        Me.Label3.Text = "triggery things"
        '
        'cmdCancel
        '
        Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdCancel.Location = New System.Drawing.Point(568, 520)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.TabIndex = 6
        Me.cmdCancel.Text = "Cancel"
        '
        'cmdOK
        '
        Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdOK.Location = New System.Drawing.Point(488, 520)
        Me.cmdOK.Name = "cmdOK"
        Me.cmdOK.TabIndex = 5
        Me.cmdOK.Text = "OK"
        '
        'txtDescription
        '
        Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.txtDescription.Location = New System.Drawing.Point(400, 80)
        Me.txtDescription.Multiline = True
        Me.txtDescription.Name = "txtDescription"
        Me.txtDescription.ReadOnly = True
        Me.txtDescription.Size = New System.Drawing.Size(240, 144)
        Me.txtDescription.TabIndex = 3
        Me.txtDescription.Text = ""
        '
        'Label1
        '
        Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label1.Location = New System.Drawing.Point(400, 64)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(184, 16)
        Me.Label1.TabIndex = 8
        Me.Label1.Text = "Description"
        '
        'pnlControls
        '
        Me.pnlControls.AutoScroll = True
        Me.pnlControls.Location = New System.Drawing.Point(8, 240)
        Me.pnlControls.Name = "pnlControls"
        Me.pnlControls.Size = New System.Drawing.Size(384, 304)
        Me.pnlControls.TabIndex = 4
        '
        'Label4
        '
        Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.Label4.Location = New System.Drawing.Point(8, 40)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(40, 20)
        Me.Label4.TabIndex = 10
        Me.Label4.Text = "Name"
        Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'txtName
        '
        Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.txtName.Location = New System.Drawing.Point(48, 40)
        Me.txtName.Name = "txtName"
        Me.txtName.Size = New System.Drawing.Size(344, 20)
        Me.txtName.TabIndex = 0
        Me.txtName.Text = ""
        '
        'GroupBox1
        '
        Me.GroupBox1.Controls.Add(Me.cmbGroup)
        Me.GroupBox1.Controls.Add(Me.radGroup)
        Me.GroupBox1.Controls.Add(Me.radAny)
        Me.GroupBox1.Controls.Add(Me.radSpecifiedOnly)
        Me.GroupBox1.Location = New System.Drawing.Point(400, 240)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(240, 104)
        Me.GroupBox1.TabIndex = 11
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "This action applies to:"
        '
        'cmbGroup
        '
        Me.cmbGroup.Location = New System.Drawing.Point(8, 72)
        Me.cmbGroup.Name = "cmbGroup"
        Me.cmbGroup.Size = New System.Drawing.Size(224, 21)
        Me.cmbGroup.TabIndex = 3
        '
        'radGroup
        '
        Me.radGroup.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.radGroup.Location = New System.Drawing.Point(8, 48)
        Me.radGroup.Name = "radGroup"
        Me.radGroup.Size = New System.Drawing.Size(144, 16)
        Me.radGroup.TabIndex = 2
        Me.radGroup.Text = "this group of devices:"
        '
        'radAny
        '
        Me.radAny.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.radAny.Location = New System.Drawing.Point(8, 32)
        Me.radAny.Name = "radAny"
        Me.radAny.Size = New System.Drawing.Size(176, 16)
        Me.radAny.TabIndex = 1
        Me.radAny.Text = "any device that understands it."
        '
        'radSpecifiedOnly
        '
        Me.radSpecifiedOnly.Checked = True
        Me.radSpecifiedOnly.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.radSpecifiedOnly.Location = New System.Drawing.Point(8, 16)
        Me.radSpecifiedOnly.Name = "radSpecifiedOnly"
        Me.radSpecifiedOnly.Size = New System.Drawing.Size(152, 16)
        Me.radSpecifiedOnly.TabIndex = 0
        Me.radSpecifiedOnly.TabStop = True
        Me.radSpecifiedOnly.Text = "the specified device only."
        '
        'frmDeterminatorSubWizard
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(650, 551)
        Me.Controls.Add(Me.GroupBox1)
        Me.Controls.Add(Me.txtName)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.pnlControls)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.txtDescription)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdOK)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.lblTitle)
        Me.Controls.Add(Me.lstTriggers)
        Me.Controls.Add(Me.lstDevices)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "frmDeterminatorSubWizard"
        Me.Text = "frmDeterminatorSubWizard"
        Me.GroupBox1.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Public Mode As SubWizardMode
    Public myAction As DeterminatorRule.DeterminatorAction
    Public myCondition As DeterminatorRule.DeterminatorCondition
    Private plugins As globals.Plugin
    Private triggers As globals.Plugin.Trigger
    Private dynamicControls() As Control
    Private dynamicLabels() As Label


    Private Sub frmDeterminatorSubWizard_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        PopulateLstDevices()
        Select Case Mode
            Case SubWizardMode.Action
                Me.Label3.Text = "Actions"
                lblTitle.Text = "ACTIONS"
                Me.Text = "Determinator Action"
            Case SubWizardMode.Condition
                Me.Label3.Text = "Triggers/Conditions"
                GroupBox1.Text = "This condition may be initiated by:"
                radAny.Text = "Any device"
                radGroup.Visible = False
                cmbGroup.Visible = False
                lblTitle.Text = "CONDITIONS"
                Me.Text = "Determinator Condition"
                'Case SubWizardMode.Initiator
                '  lblTitle.Text = "Please specify the device and the other thingy."
                '  Me.Text = "Determinator Initiator"
            Case Else
                MsgBox("Unsupported determinator mode!")
        End Select
    End Sub

    Private Sub PopulateLstDevices()
        Dim str As String
        ConnectToXplHal()
        xplHalSend("LISTALLDEVS" & vbCrLf)
        str = GetLine()
        If str.StartsWith("216") Then
            str = GetLine()
            While Not str = ("." & vbCrLf)
                str = str.Replace(vbCrLf, "")
                lstDevices.Items.Add(str)
                str = GetLine()
            End While
        End If
        Disconnect()
        For Counter As Integer = lstDevices.Items.Count - 1 To 0 Step -1
            If lstDevices.Items(Counter).ToString.ToUpper.StartsWith("XPL-XPLHAL") Then
                lstDevices.SelectedIndex = Counter
                Exit For
            End If
        Next
    End Sub

    Private Sub lstDevices_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstDevices.SelectedIndexChanged
        pnlControls.Visible = False
        lstTriggers.Items.Clear()
        pnlControls.Controls.Clear()
        txtDescription.Text = ""
        Dim CurrentDeviceID As String = CStr(lstDevices.Items(lstDevices.SelectedIndex))

        CurrentDeviceID = CurrentDeviceID.Substring(0, CurrentDeviceID.IndexOf(".")).ToUpper
        If CurrentDeviceID = "XPL-XPLHAL" Or CurrentDeviceID = "XPL-XPLHAL2" Then
            Select Case Mode
                Case globals.SubWizardMode.Condition  ' Conditions
                    lstTriggers.Items.Add("Compare global to a literal")
                    lstTriggers.Items.Add("Compare two globals")
                    lstTriggers.Items.Add("Detect a change in a global")
                    lstTriggers.Items.Add("Restrict execution to specific days")
                    lstTriggers.Items.Add("Restrict execution to specific time")
                    lstTriggers.Items.Add("Check state of X10 device")
                Case globals.SubWizardMode.Action  ' Actions                    
                    lstTriggers.Items.Add("Set the value of a global variable")
                    lstTriggers.Items.Add("Run a program")
                    lstTriggers.Items.Add("Pause")
                    lstTriggers.Items.Add("Execute another determinator")
                    lstTriggers.Items.Add("Execute a Script")
                    lstTriggers.Items.Add("Increment a global variable")
                    lstTriggers.Items.Add("Decrement a global variable")
                    lstTriggers.Items.Add("Write to the error log")
                    lstTriggers.Items.Add("Suspend execution")

            End Select
        Else
            ' Look for the device's plug-in
            lstTriggers.Items.Clear()
            For Counter As Integer = 0 To globals.Plugins.Length - 1
                If globals.Plugins(Counter).DeviceID = CurrentDeviceID Then
                    plugins = globals.Plugins(Counter)
                    Select Case Mode
                        Case SubWizardMode.Action
                            For Counter2 As Integer = 0 To plugins.Commands.Length - 1
                                lstTriggers.Items.Add(plugins.Commands(Counter2).Name)
                            Next
                        Case SubWizardMode.Condition ', SubWizardMode.Initiator
                            For Counter2 As Integer = 0 To plugins.Triggers.Length - 1
                                lstTriggers.Items.Add(plugins.Triggers(Counter2).Name)
                            Next
                    End Select
                    Exit For
                End If
            Next
        End If
    End Sub

    Private Sub lstTriggers_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstTriggers.SelectedIndexChanged
        Me.SuspendLayout()
        pnlControls.Controls.Clear()
        Select Case Mode
            Case SubWizardMode.Action
                If CStr(lstDevices.Items(lstDevices.SelectedIndex)).ToUpper.StartsWith("XPL-XPLHAL") Then
                    GroupBox1.Visible = False
                    Select Case lstTriggers.SelectedIndex
                        Case DeterminatorActionType.SetGlobal - 1   ' Set global variable
                            txtDescription.Text = "Allows you to set the value of a global variable."
                            ReDim dynamicControls(2)
                            dynamicControls(0) = New ComboBox
                            CType(dynamicControls(0), ComboBox).Sorted = True
                            dynamicControls(1) = New TextBox
                            dynamicControls(2) = New ComboBox
                            CType(dynamicControls(2), ComboBox).DropDownStyle = ComboBoxStyle.DropDownList
                            CType(dynamicControls(2), ComboBox).Visible = False
                            ReDim dynamicLabels(2)
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(2) = New Label
                            dynamicLabels(0).Text = "Global Name:"
                            dynamicLabels(1).Text = "Value:"
                            PopulateGlobals(CType(dynamicControls(0), ComboBox))
                            AddHandler CType(dynamicControls(0), ComboBox).SelectedIndexChanged, AddressOf dynamic_SelectedIndexChanged
                        Case DeterminatorActionType.RunEXE - 1
                            txtDescription.Text = "Allows you to run an external program, optionally passing command-line parameters."
                            ReDim dynamicControls(1)
                            dynamicControls(0) = New TextBox
                            dynamicControls(1) = New TextBox
                            ReDim dynamicLabels(1)
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(0).Text = "Program Name:"
                            dynamicLabels(1).Text = "Parameters:"
                        Case DeterminatorActionType.Pause - 1
                            txtDescription.Text = "Pauses execution of the determinator for the specified number of seconds."
                            ReDim dynamicControls(0)
                            dynamicControls(0) = New NumericUpDown
                            Dim c As NumericUpDown = CType(dynamicControls(0), NumericUpDown)
                            c.Minimum = 1
                            c.Maximum = 60
                            ReDim dynamicLabels(0)
                            dynamicLabels(0) = New Label
                            dynamicLabels(0).Text = "Pause seconds:"
                        Case DeterminatorActionType.ExecuteScript - 1
                            txtDescription.Text = "Allows you to execute a sub-routine."
                            ReDim dynamicControls(1)
                            dynamicControls(0) = New ComboBox
                            dynamicControls(1) = New TextBox
                            ReDim dynamicLabels(1)
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(0).Text = "Sub Name:"
                            dynamicLabels(1).Text = "Value:"
                            PopulateSubs(CType(dynamicControls(0), ComboBox))
                            CType(dynamicControls(0), ComboBox).Sorted = True
                        Case DeterminatorActionType.ExecuteRule - 1
                            txtDescription.Text = "Allows you to cause another determinator to be executed."
                            ReDim dynamicControls(0)
                            dynamicControls(0) = New ComboBox
                            ReDim dynamicLabels(1)
                            dynamicLabels(0) = New Label
                            dynamicLabels(0).Text = "Determinator Name:"
                            PopulateDeterminators(CType(dynamicControls(0), ComboBox))
                            CType(dynamicControls(0), ComboBox).Sorted = True
                        Case DeterminatorActionType.IncrementGlobal - 1, DeterminatorActionType.DecrementGlobal - 1
                            txtDescription.Text = "Allows incrementing/decrementing of global variables."
                            ReDim dynamicControls(0)
                            ReDim dynamicLabels(0)
                            dynamicControls(0) = New ComboBox
                            dynamicLabels(0) = New Label
                            Dim c As ComboBox = CType(dynamicControls(0), ComboBox)
                            PopulateGlobals(CType(dynamicControls(0), ComboBox))
                            dynamicLabels(0).Text = "Global variable"
                            c.DropDownStyle = ComboBoxStyle.DropDownList
                            c.Sorted = True
                            If c.Items.Count > 0 Then
                                c.SelectedIndex = 0
                            End If
                        Case DeterminatorActionType.DecrementGlobal ' Log to error log
                            txtDescription.Text = "Allows you to write information to the xPLHal Error Log - useful for debugging."
                            ReDim dynamicControls(0)
                            ReDim dynamicLabels(0)
                            dynamicControls(0) = New TextBox
                            dynamicLabels(0) = New Label
                            dynamicLabels(0).Text = "Text to log"
                        Case DeterminatorActionType.AddToLog
                            txtDescription.Text = "Allows you to suspend execution for upto 24 hours."
                            ReDim dynamicControls(3)
                            ReDim dynamicLabels(3)
                            dynamicControls(0) = New RadioButton
                            dynamicControls(1) = New RadioButton
                            dynamicControls(2) = New DateTimePicker
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(2) = New Label
                            dynamicLabels(3) = New Label
                            dynamicControls(3) = New NumericUpDown
                            dynamicLabels(0).Text = "Suspend execution"
                            dynamicLabels(3).Text = "Randomisation"
                            With CType(dynamicControls(0), RadioButton)
                                .Text = "for the specified number of minutes"
                                .Checked = True
                            End With
                            With CType(dynamicControls(1), RadioButton)
                                .Text = "until the specified time"
                            End With
                            With CType(dynamicControls(2), DateTimePicker)
                                .CustomFormat = "HH:mm"
                                .Format = System.Windows.Forms.DateTimePickerFormat.Custom
                                .ShowUpDown = True
                                .Value = CDate("1/1/2000 00:00")
                            End With
                        Case Else
                            MsgBox("The selected item is unsupported.")
                    End Select
                    FormatControls2()
                Else
                    GroupBox1.Visible = True
                    ' Find the command
                    For Counter As Integer = 0 To plugins.Commands.Length - 1
                        If CStr(lstTriggers.Items(lstTriggers.SelectedIndex)) = plugins.Commands(Counter).Name Then
                            triggers = plugins.Commands(Counter)
                            Exit For
                        End If
                    Next
                    PopulateControls()
                End If
            Case SubWizardMode.Condition
                If CStr(lstDevices.Items(lstDevices.SelectedIndex)).ToUpper.StartsWith("XPL-XPLHAL") Then
                    Select Case lstTriggers.SelectedIndex
                        Case 0 ' Compare global to literal
                            ReDim dynamicControls(3)
                            dynamicControls(0) = New ComboBox
                            dynamicControls(1) = New ComboBox
                            dynamicControls(2) = New TextBox
                            dynamicControls(3) = New ComboBox
                            CType(dynamicControls(3), ComboBox).DropDownStyle = ComboBoxStyle.DropDownList
                            CType(dynamicControls(3), ComboBox).Visible = False
                            ReDim dynamicLabels(3)
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(2) = New Label
                            dynamicLabels(3) = New Label
                            dynamicLabels(0).Text = "Global Name"
                            dynamicLabels(1).Text = "Comparison Operator"
                            dynamicLabels(2).Text = "Value"
                            PopulateGlobals(CType(dynamicControls(0), ComboBox))
                            CType(dynamicControls(0), ComboBox).Sorted = True
                            PopulateComparisonCombo(CType(dynamicControls(1), ComboBox))
                            AddHandler CType(dynamicControls(0), ComboBox).SelectedIndexChanged, AddressOf dynamic_SelectedIndexChanged
                        Case 1 ' compare two glow balls
                            ReDim dynamicControls(2)
                            dynamicControls(0) = New ComboBox
                            dynamicControls(1) = New ComboBox
                            CType(dynamicControls(1), ComboBox).DropDownStyle = ComboBoxStyle.DropDownList
                            dynamicControls(2) = New ComboBox
                            'dynamicControls(3) = New CheckBox
                            'CType(dynamicControls(3), CheckBox).Checked = False
                            ReDim dynamicLabels(2)
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(2) = New Label
                            'dynamicLabels(3) = New Label
                            dynamicLabels(0).Text = "First Global Name"
                            dynamicLabels(1).Text = "Comparison Operator"
                            dynamicLabels(2).Text = "Second  Global Name"
                            'dynamicLabels(3).Text = "Is Initiator"
                            PopulateGlobals(CType(dynamicControls(0), ComboBox))
                            PopulateComparisonCombo(CType(dynamicControls(1), ComboBox))
                            PopulateGlobals(CType(dynamicControls(2), ComboBox))
                            CType(dynamicControls(0), ComboBox).Sorted = True
                            CType(dynamicControls(2), ComboBox).Sorted = True
                        Case 2
                            ReDim dynamicControls(0)
                            dynamicControls(0) = New ComboBox
                            CType(dynamicControls(0), ComboBox).DropDownStyle = ComboBoxStyle.DropDownList
                            ReDim dynamicLabels(0)
                            dynamicLabels(0) = New Label
                            dynamicLabels(0).Text = "Global Name"
                            PopulateGlobals(CType(dynamicControls(0), ComboBox))
                            CType(dynamicControls(0), ComboBox).Sorted = True
                        Case 3 ' DayCondition
                            ReDim dynamicControls(6)
                            ReDim dynamicLabels(6)
                            For Counter2 As Integer = 0 To 6
                                dynamicControls(Counter2) = New CheckBox
                                dynamicLabels(Counter2) = New Label
                            Next
                            CType(dynamicControls(0), CheckBox).Text = "Sunday"
                            CType(dynamicControls(1), CheckBox).Text = "Monday"
                            CType(dynamicControls(2), CheckBox).Text = "Tuesday"
                            CType(dynamicControls(3), CheckBox).Text = "Wednesday"
                            CType(dynamicControls(4), CheckBox).Text = "Thursday"
                            CType(dynamicControls(5), CheckBox).Text = "Friday"
                            CType(dynamicControls(6), CheckBox).Text = "Saturday"
                        Case 4 ' TimeCondition
                            ReDim dynamicControls(1)
                            ReDim dynamicLabels(1)
                            dynamicControls(0) = New ComboBox
                            dynamicControls(1) = New DateTimePicker
                            With CType(dynamicControls(1), DateTimePicker)
                                .CustomFormat = "HH:mm"
                                .Format = System.Windows.Forms.DateTimePickerFormat.Custom
                                .ShowUpDown = True
                            End With
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(0).Text = "Operator"
                            dynamicLabels(1).Text = "Value"
                            With CType(dynamicControls(0), ComboBox)
                                .DropDownStyle = ComboBoxStyle.DropDownList
                            End With
                            PopulateComparisonCombo(CType(dynamicControls(0), ComboBox))
                        Case 5 ' X10 condition
                            ReDim dynamicControls(1)
                            ReDim dynamicLabels(1)
                            dynamicControls(0) = New TextBox
                            dynamicControls(1) = New ComboBox
                            dynamicLabels(0) = New Label
                            dynamicLabels(1) = New Label
                            dynamicLabels(0).Text = "X10 Address"
                            dynamicLabels(1).Text = "State"
                            With CType(dynamicControls(1), ComboBox)
                                .DropDownStyle = ComboBoxStyle.DropDownList
                                .Items.Add("Off")
                                .Items.Add("On")
                            End With
                    End Select
                    FormatControls2()
                Else ' not xPLHAL
                    ' Find the trigger
                    For Counter As Integer = 0 To plugins.Triggers.Length - 1
                        If CStr(lstTriggers.Items(lstTriggers.SelectedIndex)) = plugins.Triggers(Counter).Name Then
                            triggers = plugins.Triggers(Counter)
                            Exit For
                        End If
                    Next
                    PopulateControls()
                End If
        End Select
        Me.ResumeLayout()
    End Sub

    Private Sub FormatLayout(ByRef l As Label, ByRef c As Control, ByVal x As Integer)
        c.Parent = pnlControls
        l.Parent = pnlControls
        l.Top = x * 25
        l.Width = 150
        l.Visible = True
        l.TextAlign = ContentAlignment.MiddleRight
        l.Height = c.Height
        c.Top = x * 25
        c.Visible = True
        c.Left = l.Left + l.Width
        c.Width = 200
    End Sub

    Private Sub FormatControls2()
        pnlControls.SuspendLayout()
        Dim x As Integer = 0
        For Counter As Integer = 0 To dynamicControls.Length - 1
            FormatLayout(dynamicLabels(Counter), dynamicControls(Counter), x)
            If TypeOf (dynamicControls(Counter)) Is ComboBox Then
                CType(dynamicControls(Counter), ComboBox).Items.Add("")
            End If
            x += 1
        Next
        pnlControls.Visible = True
        pnlControls.ResumeLayout()
    End Sub

    Private Sub PopulateControls()
        ' Populate controls
        txtDescription.Text = triggers.Description
        ReDim dynamicControls(triggers.elements.Length - 1)
        ReDim dynamicLabels(triggers.elements.Length - 1)
        For Counter As Integer = 0 To triggers.elements.Length - 1
            dynamicLabels(Counter) = New Label
            dynamicLabels(Counter).Parent = pnlControls
            dynamicLabels(Counter).Text = triggers.elements(Counter).Label
            Select Case triggers.elements(Counter).ControlType
                Case "", "textbox"
                    dynamicControls(Counter) = New TextBox
                    dynamicControls(Counter).Parent = pnlControls
                Case "numeric"
                    dynamicControls(Counter) = New NumericUpDown
                    dynamicControls(Counter).Parent = pnlControls
                    Dim c As NumericUpDown = CType(dynamicControls(Counter), NumericUpDown)
                    c.Increment = 1
                    c.Maximum = CInt(triggers.elements(Counter).MaxVal)
                    c.Minimum = CInt(triggers.elements(Counter).MinVal)
                    c.Text = triggers.elements(Counter).DefaultValue
                Case "dropdownlist"
                    dynamicControls(Counter) = New ComboBox
                    CType(dynamicControls(Counter), ComboBox).Items.Add("")
                    CType(dynamicControls(Counter), ComboBox).DropDownStyle = ComboBoxStyle.DropDownList
                    AddHandler CType(dynamicControls(Counter), ComboBox).SelectedIndexChanged, AddressOf dynamic_SelectedIndexChanged
                    dynamicControls(Counter).Parent = pnlControls
                    dynamicControls(Counter).Visible = True
                    For Counter2 As Integer = 0 To triggers.elements(Counter).Choices.Length - 1
                        CType(dynamicControls(Counter), ComboBox).Items.Add(triggers.elements(Counter).Choices(Counter2).Label)
                    Next
                Case Else
                    MsgBox("Invalid control_type!")
            End Select
            dynamicLabels(Counter).Left = 0
            dynamicLabels(Counter).Visible = dynamicControls(Counter).Visible
            dynamicControls(Counter).Left = 100
        Next
        FormatControls()
        pnlControls.Visible = True
    End Sub


    Private Sub FormatControls()
        Dim x As Integer = 0
        For Counter As Integer = 0 To dynamicControls.Length - 1
            If Not triggers.elements(Counter).Label = "" And IsVisible(triggers.elements(Counter).ConditionalVisibility) Then
                FormatLayout(dynamicLabels(Counter), dynamicControls(Counter), x)
                x += 1
            Else
                dynamicLabels(Counter).Visible = False
                dynamicControls(Counter).Visible = False
            End If
        Next
    End Sub

    Private Function IsVisible(ByVal exp As String) As Boolean
        If exp Is Nothing Then Return True
        If exp.IndexOf("=") < 1 Then Return True
        Dim lhs, lhsvalue, rhs As String
        lhsvalue = Nothing
        lhs = exp.Substring(0, exp.IndexOf("="))
        rhs = exp.Substring(exp.IndexOf("=") + 1, exp.Length - exp.IndexOf("=") - 1)
        ' Get the value of lhs
        For Counter As Integer = 0 To triggers.elements.Length - 1
            If lhs = triggers.elements(Counter).Name Then
                If TypeOf (dynamicControls(Counter)) Is ComboBox Then
                    lhsvalue = CType(dynamicControls(Counter), ComboBox).Text
                ElseIf TypeOf (dynamicControls(Counter)) Is TextBox Then
                    lhsvalue = CType(dynamicControls(Counter), TextBox).Text
                ElseIf TypeOf (dynamicControls(Counter)) Is NumericUpDown Then
                    lhsvalue = CType(dynamicControls(Counter), NumericUpDown).Text
                Else
                    MsgBox("Invalid control type!")
                End If
                Exit For
            End If
        Next
        If lhsvalue Is Nothing Then Return False
        If RegularExpressions.Regex.IsMatch(lhsvalue, rhs) Then
            Return True
        Else
            Return False
        End If
    End Function

    Private Sub dynamic_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If CStr(lstDevices.Items(lstDevices.SelectedIndex)).ToUpper.StartsWith("XPL-XPLHAL") Then
            Select Case Mode
                Case SubWizardMode.Action
                    If lstTriggers.SelectedIndex = 0 Then
                        If CType(dynamicControls(0), ComboBox).Text.ToUpper = "MODE" Then
                            CType(dynamicControls(2), ComboBox).Location = CType(dynamicControls(1), TextBox).Location
                            CType(dynamicControls(2), ComboBox).Visible = True
                            CType(dynamicControls(1), TextBox).Visible = False
                            dynamicLabels(1).Text = "Modes"
                            CType(dynamicControls(2), ComboBox).Items.Clear()
                            For Counter As Integer = 0 To globals.Modes.Length - 1
                                CType(dynamicControls(2), ComboBox).Items.Add(globals.Modes(Counter))
                            Next
                        ElseIf CType(dynamicControls(0), ComboBox).Text.ToUpper = "PERIOD" Then
                            CType(dynamicControls(2), ComboBox).Location = CType(dynamicControls(1), TextBox).Location
                            CType(dynamicControls(2), ComboBox).Visible = True
                            CType(dynamicControls(1), TextBox).Visible = False
                            dynamicLabels(1).Text = "Periods"
                            CType(dynamicControls(2), ComboBox).Items.Clear()
                            For Counter As Integer = 0 To globals.Periods.Length - 1
                                CType(dynamicControls(2), ComboBox).Items.Add(globals.Periods(Counter))
                            Next
                        Else
                            CType(dynamicControls(2), ComboBox).Visible = False
                            CType(dynamicControls(1), TextBox).Visible = True
                            dynamicLabels(1).Text = "Value"
                        End If
                    End If
                Case SubWizardMode.Condition
                    If lstTriggers.SelectedIndex = 0 Or lstTriggers.SelectedIndex = 1 Then
                        If CType(dynamicControls(0), ComboBox).Text.ToUpper = "MODE" Then
                            CType(dynamicControls(3), ComboBox).Location = CType(dynamicControls(2), TextBox).Location
                            CType(dynamicControls(3), ComboBox).Visible = True
                            CType(dynamicControls(2), TextBox).Visible = False
                            dynamicLabels(2).Text = "Modes"
                            CType(dynamicControls(3), ComboBox).Items.Clear()
                            For Counter As Integer = 0 To globals.Modes.Length - 1
                                CType(dynamicControls(3), ComboBox).Items.Add(globals.Modes(Counter))
                            Next
                        ElseIf CType(dynamicControls(0), ComboBox).Text.ToUpper = "PERIOD" Then
                            CType(dynamicControls(3), ComboBox).Location = CType(dynamicControls(2), TextBox).Location
                            CType(dynamicControls(3), ComboBox).Visible = True
                            CType(dynamicControls(2), TextBox).Visible = False
                            dynamicLabels(2).Text = "Periods"
                            CType(dynamicControls(3), ComboBox).Items.Clear()
                            For Counter As Integer = 0 To globals.Periods.Length - 1
                                CType(dynamicControls(3), ComboBox).Items.Add(globals.Periods(Counter))
                            Next
                        Else
                            CType(dynamicControls(3), ComboBox).Visible = False
                            CType(dynamicControls(2), TextBox).Visible = True
                            dynamicLabels(2).Text = "Value"
                        End If
                    End If
            End Select
        Else
            FormatControls()
        End If
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        If txtName.Text = "" Then
            MsgBox("You must enter a name to help you identify this item.", vbExclamation)
            txtName.Focus()
            Exit Sub
        End If
        If lstDevices.SelectedIndex < 0 Then
            MsgBox("Please select a device from the list.", vbExclamation)
            lstDevices.Focus()
            Exit Sub
        End If
        If lstTriggers.SelectedIndex < 0 And lstTriggers.Items.Count > 0 Then
            MsgBox("Please select an item from the list.", vbExclamation)
            lstTriggers.Focus()
            Exit Sub
        ElseIf lstTriggers.Items.Count = 0 Then
            Select Case Mode
                Case SubWizardMode.Condition
                    MsgBox("The selected device has no items that can be used as conditions in a Determinator." & vbCrLf & vbCrLf & "Please select another device.", vbExclamation)
                    lstDevices.Focus()
                    Exit Sub
                Case SubWizardMode.Action
                    MsgBox("The selected device cannot perform any actions." & vbCrLf & vbCrLf & "Please select another device.", vbExclamation)
                    lstDevices.Focus()
                    Exit Sub
            End Select
        End If

        ' Validate controls
        If Not CStr(lstDevices.Items(lstDevices.SelectedIndex)).ToUpper.StartsWith("XPL-XPLHAL") Then
            Dim value As String
            value = ""
            For Counter As Integer = 0 To triggers.elements.Length - 1
                If Not triggers.elements(Counter).RegExp Is Nothing And dynamicControls(Counter).Visible Then
                    If TypeOf (dynamicControls(Counter)) Is TextBox Then
                        value = CType(dynamicControls(Counter), TextBox).Text
                    ElseIf TypeOf (dynamicControls(Counter)) Is ComboBox Then
                        value = CType(dynamicControls(Counter), ComboBox).Text
                    ElseIf TypeOf (dynamicControls(Counter)) Is NumericUpDown Then
                        value = CType(dynamicControls(Counter), NumericUpDown).Text
                    Else
                        MsgBox("Invalid control type!")
                    End If
                    If Not RegularExpressions.Regex.IsMatch(value, triggers.elements(Counter).RegExp) Then
                        MsgBox("The " & triggers.elements(Counter).Label & " is invalid.", vbExclamation)
                        Exit Sub
                    End If
                ElseIf triggers.elements(Counter).ControlType = "numeric" And dynamicControls(Counter).Visible Then
                    Dim v As Integer = CInt(CType(dynamicControls(Counter), NumericUpDown).Text)
                    If v > CInt(triggers.elements(Counter).MaxVal) Then
                        MsgBox("The value of " & triggers.elements(Counter).Label & " is too high.", vbExclamation)
                        Exit Sub
                    End If
                    If v < CInt(triggers.elements(Counter).MinVal) Then
                        MsgBox("The value of " & triggers.elements(Counter).Label & " is too low.", vbExclamation)
                        Exit Sub
                    End If
                End If
            Next
        End If

        Select Case Mode
            Case SubWizardMode.Action
                myAction = New DeterminatorRule.DeterminatorAction
                myAction.DisplayName = txtName.Text
                ' What type of action?
                If lstDevices.Text.ToUpper.StartsWith("XPL-XPLHAL") Then
                    Select Case lstTriggers.SelectedIndex
                        Case DeterminatorActionType.ExecuteRule - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.execRuleAction
                            Dim x As New DeterminatorRule.DeterminatorAction.execRuleAction
                            x.RuleName = CType(dynamicControls(0), ComboBox).Text
                            myAction.Action = x
                        Case DeterminatorActionType.ExecuteScript - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.runScriptAction
                            Dim x As New DeterminatorRule.DeterminatorAction.RunScriptAction
                            x.ScriptName = CType(dynamicControls(0), ComboBox).Text
                            x.Parameters = CType(dynamicControls(1), TextBox).Text
                            myAction.Action = x
                        Case DeterminatorActionType.Pause - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.delayAction
                            Dim x As New DeterminatorRule.DeterminatorAction.DelayAction
                            x.DelaySeconds = CInt(CType(dynamicControls(0), NumericUpDown).Text)
                            If x.DelaySeconds > 60 Then
                                MsgBox("You can only pause a determinator for a maximum of 60 seconds.", vbExclamation)
                                Exit Sub
                            End If
                            myAction.Action = x
                        Case DeterminatorActionType.RunEXE - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.executeAction
                            Dim x As New DeterminatorRule.DeterminatorAction.executeAction
                            x.Program = CType(dynamicControls(0), TextBox).Text
                            x.Parameters = CType(dynamicControls(1), TextBox).Text
                            myAction.Action = x
                        Case DeterminatorActionType.SetGlobal - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
                            Dim x As New DeterminatorRule.DeterminatorAction.globalAction
                            x.Name = CType(dynamicControls(0), ComboBox).Text
                            Dim str As String = CType(dynamicControls(0), ComboBox).Text
                            If str = "MODE" Or str = "PERIOD" Then
                                x.Value = CStr(CType(CType(dynamicControls(2), ComboBox).SelectedItem, globals.ConstructValue).Index)
                            Else
                                x.Value = CType(dynamicControls(1), TextBox).Text
                            End If
                            myAction.Action = x
                        Case DeterminatorActionType.IncrementGlobal - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
                            Dim x As New DeterminatorRule.DeterminatorAction.globalAction
                            x.Name = CType(dynamicControls(0), ComboBox).Text
                            x.Value = "{" & x.Name & "}++"
                            myAction.Action = x
                        Case DeterminatorActionType.DecrementGlobal - 1
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
                            Dim x As New DeterminatorRule.DeterminatorAction.globalAction
                            x.Name = CType(dynamicControls(0), ComboBox).Text
                            x.Value = "{" & x.Name & "}--"
                            myAction.Action = x
                        Case DeterminatorActionType.DecrementGlobal ' Log to error log
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.logAction
                            Dim x As New DeterminatorRule.DeterminatorAction.logAction
                            x.logText = CType(dynamicControls(0), TextBox).Text
                            myAction.Action = x
                        Case DeterminatorActionType.AddToLog ' Suspend execution
                            myAction.ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.suspendAction
                            Dim x As New DeterminatorRule.DeterminatorAction.suspendAction
                            If CType(dynamicControls(0), RadioButton).Checked Then
                                ' Suspend for specified number of minutes                
                                Dim d As Date = CType(dynamicControls(2), DateTimePicker).Value
                                Dim a As Integer = Hour(d) * 60 + Minute(d)
                                If a > 0 Then
                                    x.SuspendMinutes = a
                                Else
                                    MsgBox("Suspend period may not be zero.", vbExclamation)
                                    Exit Sub
                                End If
                            Else
                                ' Suspend until specified time
                                x.SuspendMinutes = 0
                                x.SuspendTime = CType(dynamicControls(2), DateTimePicker).Text
                            End If
                            x.SuspendRandomise = CInt(CType(dynamicControls(3), NumericUpDown).Text)
                            myAction.Action = x
                    End Select
                Else
                    'myAction.ActionType = xplhalMgrBase.DeterminatorRule.actionTypes.xPLMessage
                    Dim x As New DeterminatorRule.DeterminatorAction.xplAction
                    x.msg_type = triggers.msg_type
                    If radAny.Checked Then
                        x.msg_target = "*"
                    ElseIf radGroup.Checked Then
                        If cmbGroup.Text = "" Then
                            MsgBox("Please specify the name of the group to which this action will apply.", vbExclamation)
                            cmbGroup.Focus()
                            Exit Sub
                        End If
                        x.msg_target = "xpl-group." & cmbGroup.Text
                    Else
                        x.msg_target = lstDevices.Text
                    End If
                    x.msg_schema = triggers.msg_schema
                    ReDim x.params(-1)
                    For counter As Integer = 0 To triggers.elements.Length - 1
                        If dynamicControls(counter).Visible Or triggers.elements(counter).DefaultValue <> "" Then
                            Dim NewParam As String, NewValue As String = ""
                            NewParam = triggers.elements(counter).Name & "="
                            If triggers.elements(counter).DefaultValue <> "" And Not dynamicControls(counter).Visible Then
                                NewValue = triggers.elements(counter).DefaultValue
                            ElseIf TypeOf (dynamicControls(counter)) Is TextBox Then
                                NewValue = CType(dynamicControls(counter), TextBox).Text
                            ElseIf TypeOf (dynamicControls(counter)) Is NumericUpDown Then
                                NewValue = CType(dynamicControls(counter), NumericUpDown).Text
                            ElseIf TypeOf (dynamicControls(counter)) Is ComboBox Then
                                For Counter2 As Integer = 0 To triggers.elements(counter).Choices.Length - 1
                                    If CType(dynamicControls(counter), ComboBox).Text = triggers.elements(counter).Choices(Counter2).Label Then
                                        NewValue = triggers.elements(counter).Choices(Counter2).Value
                                        Exit For
                                    End If
                                Next
                            End If
                            If Not NewValue = "" Then
                                NewParam &= NewValue
                                ReDim Preserve x.params(x.params.Length)
                                x.params(x.params.Length - 1) = NewParam
                            End If
                        End If
                    Next
                    myAction.Action = x
                End If
            Case SubWizardMode.Condition
                myCondition = New DeterminatorRule.DeterminatorCondition
                myCondition.DisplayName = txtName.Text
                ' What type of condition?
                If lstDevices.Text.ToUpper.StartsWith("XPL-XPLHAL") Then
                    Select Case lstTriggers.SelectedIndex
                        Case 0 ' Compare glowball to literal
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.globalCondition
                            Dim x As New DeterminatorRule.DeterminatorCondition.globalCondition
                            x.Name = CType(dynamicControls(0), ComboBox).Text
                            Select Case CType(dynamicControls(1), ComboBox).SelectedIndex
                                Case 0 ' Equal To
                                    x.[Operator] = "="
                                Case 1 ' Not equal to
                                    x.[Operator] = "!="
                                Case 2 ' Less than
                                    x.[Operator] = "<"
                                Case 3 ' Greater than
                                    x.[Operator] = ">"
                            End Select
                            Dim str As String = CType(dynamicControls(0), ComboBox).Text
                            If str = "MODE" Or str = "PERIOD" Then
                                x.Value = CStr(CType(CType(dynamicControls(3), ComboBox).SelectedItem, globals.ConstructValue).Index)
                            Else
                                x.Value = CType(dynamicControls(2), TextBox).Text
                            End If
                            myCondition.Condition = x
                        Case 1 ' COmpare glowballs
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.globalCondition
                            Dim x As New DeterminatorRule.DeterminatorCondition.globalCondition
                            x.Name = CType(dynamicControls(0), ComboBox).Text
                            Select Case CType(dynamicControls(1), ComboBox).SelectedIndex
                                Case 0 ' Equal To
                                    x.[Operator] = "="
                                Case 1 ' Not equal to
                                    x.[Operator] = "!="
                                Case 2 ' Less than
                                    x.[Operator] = "<"
                                Case 3 ' Greater than
                                    x.[Operator] = ">"
                            End Select
                            x.Value = "{" & CType(dynamicControls(2), ComboBox).Text & "}"
                            myCondition.Condition = x
                        Case 2 ' Glowball changed
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.globalChanged
                            Dim x As New DeterminatorRule.DeterminatorCondition.globalChanged
                            x.globalName = CType(dynamicControls(0), ComboBox).Text
                            myCondition.Condition = x
                        Case 3 ' DayCondition
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.dayCondition
                            Dim x As New DeterminatorRule.DeterminatorCondition.dayCondition
                            x.DOW = ""
                            For Counter2 As Integer = 0 To 6
                                If CType(dynamicControls(Counter2), CheckBox).Checked Then
                                    x.DOW &= "1"
                                Else
                                    x.DOW &= "0"
                                End If
                            Next
                            myCondition.Condition = x
                        Case 4 ' TimeCondition
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.timeCondition
                            Dim x As New DeterminatorRule.DeterminatorCondition.timeCondition
                            x.[Operator] = CType(dynamicControls(0), ComboBox).Text
                            Select Case x.[Operator]
                                Case "Equal To"
                                    x.[Operator] = "="
                                Case "Not Equal To"
                                    x.[Operator] = "!="
                                Case "Less Than"
                                    x.[Operator] = "<"
                                Case "Greater Than"
                                    x.[Operator] = ">"
                            End Select
                            x.Value = CType(dynamicControls(1), DateTimePicker).Text
                            myCondition.Condition = x
                        Case 5 ' X10Condition
                            myCondition.ConditionType = DeterminatorRule.ConditionTypes.x10Condition
                            Dim x As New DeterminatorRule.DeterminatorCondition.x10Condition
                            x.Device = CType(dynamicControls(0), TextBox).Text
                            x.State = CType(dynamicControls(1), ComboBox).Text
                            myCondition.Condition = x
                    End Select
                Else
                    myCondition.ConditionType = xplhalMgrBase.DeterminatorRule.ConditionTypes.xPLMessage
                    Dim x As New DeterminatorRule.DeterminatorCondition.xplCondition
                    x.msg_type = triggers.msg_type
                    If radSpecifiedOnly.Checked Then
                        x.source_vendor = CStr(lstDevices.Items(lstDevices.SelectedIndex))
                        x.source_instance = x.source_vendor.Substring(x.source_vendor.IndexOf(".") + 1, x.source_vendor.Length - x.source_vendor.IndexOf(".") - 1)
                        x.source_device = x.source_vendor.Substring(x.source_vendor.IndexOf("-") + 1, x.source_vendor.IndexOf(".") - x.source_vendor.IndexOf("-") - 1)
                        x.source_vendor = x.source_vendor.Substring(0, x.source_vendor.IndexOf("-"))
                    Else
                        x.source_vendor = "*"
                        x.source_device = "*"
                        x.source_instance = "*"
                    End If
                    x.target_vendor = "*"
                    x.target_device = "*"
                    x.target_instance = "*"
                    x.schema_class = triggers.msg_schema.Substring(0, triggers.msg_schema.IndexOf("."))
                    x.schema_type = triggers.msg_schema.Substring(triggers.msg_schema.IndexOf(".") + 1, triggers.msg_schema.Length - triggers.msg_schema.IndexOf(".") - 1)

                    Dim counter As Integer = 0
                    For Each entry As Plugin.TriggerElement In triggers.elements
                        Dim newparams As New xplConditionParams
                        newparams.Name = entry.Name
                        newparams.[Operator] = "="
                        If entry.DefaultValue <> "" Then
                            newparams.Value = entry.DefaultValue
                        ElseIf TypeOf (dynamicControls(counter)) Is TextBox Then
                            newparams.Value = CType(dynamicControls(counter), TextBox).Text
                        ElseIf TypeOf (dynamicControls(counter)) Is NumericUpDown Then
                            newparams.Value = CType(dynamicControls(counter), NumericUpDown).Text
                        ElseIf TypeOf (dynamicControls(counter)) Is ComboBox Then
                            For Counter2 As Integer = 0 To entry.Choices.Length - 1
                                If CType(dynamicControls(counter), ComboBox).Text = entry.Choices(Counter2).Label Then
                                    newparams.Value = entry.Choices(Counter2).Value
                                    Exit For
                                End If
                            Next
                        End If
                        x.params.Add(newparams)
                        counter = counter + 1
                    Next

                    myCondition.Condition = x
                End If

        End Select

        Me.DialogResult = Windows.Forms.DialogResult.OK
        Me.Close()
    End Sub

End Class
