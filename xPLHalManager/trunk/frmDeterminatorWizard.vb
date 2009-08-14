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

Public Class frmDeterminatorWizard
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
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents Page1 As System.Windows.Forms.Panel
    Friend WithEvents Page2 As System.Windows.Forms.Panel
    Friend WithEvents Page3 As System.Windows.Forms.Panel
    Friend WithEvents Page6 As System.Windows.Forms.Panel
    Friend WithEvents Page4 As System.Windows.Forms.Panel
    Friend WithEvents Page5 As System.Windows.Forms.Panel
  Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cmdBack As System.Windows.Forms.Button
    Friend WithEvents cmdNext As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label6 As System.Windows.Forms.Label
  Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents chkDisableWizard As System.Windows.Forms.CheckBox
  Friend WithEvents Label7 As System.Windows.Forms.Label
  Friend WithEvents Label8 As System.Windows.Forms.Label
  Friend WithEvents txtName As System.Windows.Forms.TextBox
  Friend WithEvents txtDescription As System.Windows.Forms.TextBox
  Friend WithEvents Panel3 As System.Windows.Forms.Panel
  Friend WithEvents cmdAddInitiator As System.Windows.Forms.Button
  Friend WithEvents cmdEditInitiator As System.Windows.Forms.Button
  Friend WithEvents cmdRemoveInitiator As System.Windows.Forms.Button
  Friend WithEvents Panel4 As System.Windows.Forms.Panel
  Friend WithEvents cmdRemoveCondition As System.Windows.Forms.Button
  Friend WithEvents cmdEditCondition As System.Windows.Forms.Button
  Friend WithEvents cmdAddCondition As System.Windows.Forms.Button
  Friend WithEvents lstConditions As System.Windows.Forms.ListBox
  Friend WithEvents Panel5 As System.Windows.Forms.Panel
  Friend WithEvents cmdRemoveAction As System.Windows.Forms.Button
  Friend WithEvents cmdEditAction As System.Windows.Forms.Button
  Friend WithEvents cmdAddAction As System.Windows.Forms.Button
  Friend WithEvents lstActions As System.Windows.Forms.ListBox
  Friend WithEvents lstInitiators As System.Windows.Forms.ListBox
  Friend WithEvents cmdDownAction As System.Windows.Forms.Button
  Friend WithEvents cmdUpAction As System.Windows.Forms.Button
  Friend WithEvents radMatchAll As System.Windows.Forms.RadioButton
  Friend WithEvents radMatchAny As System.Windows.Forms.RadioButton
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmDeterminatorWizard))
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.cmdBack = New System.Windows.Forms.Button
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdNext = New System.Windows.Forms.Button
		Me.Page1 = New System.Windows.Forms.Panel
		Me.chkDisableWizard = New System.Windows.Forms.CheckBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.Page2 = New System.Windows.Forms.Panel
		Me.txtDescription = New System.Windows.Forms.TextBox
		Me.txtName = New System.Windows.Forms.TextBox
		Me.Label8 = New System.Windows.Forms.Label
		Me.Label7 = New System.Windows.Forms.Label
		Me.Label2 = New System.Windows.Forms.Label
		Me.Page3 = New System.Windows.Forms.Panel
		Me.lstInitiators = New System.Windows.Forms.ListBox
		Me.Panel3 = New System.Windows.Forms.Panel
		Me.cmdRemoveInitiator = New System.Windows.Forms.Button
		Me.cmdEditInitiator = New System.Windows.Forms.Button
		Me.cmdAddInitiator = New System.Windows.Forms.Button
		Me.Label3 = New System.Windows.Forms.Label
		Me.Page6 = New System.Windows.Forms.Panel
		Me.Label6 = New System.Windows.Forms.Label
		Me.Page4 = New System.Windows.Forms.Panel
		Me.lstConditions = New System.Windows.Forms.ListBox
		Me.Panel4 = New System.Windows.Forms.Panel
		Me.radMatchAny = New System.Windows.Forms.RadioButton
		Me.radMatchAll = New System.Windows.Forms.RadioButton
		Me.cmdRemoveCondition = New System.Windows.Forms.Button
		Me.cmdEditCondition = New System.Windows.Forms.Button
		Me.cmdAddCondition = New System.Windows.Forms.Button
		Me.Label4 = New System.Windows.Forms.Label
		Me.Page5 = New System.Windows.Forms.Panel
		Me.lstActions = New System.Windows.Forms.ListBox
		Me.Panel5 = New System.Windows.Forms.Panel
		Me.cmdDownAction = New System.Windows.Forms.Button
		Me.cmdUpAction = New System.Windows.Forms.Button
		Me.cmdRemoveAction = New System.Windows.Forms.Button
		Me.cmdEditAction = New System.Windows.Forms.Button
		Me.cmdAddAction = New System.Windows.Forms.Button
		Me.Label5 = New System.Windows.Forms.Label
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.Label10 = New System.Windows.Forms.Label
		Me.PictureBox1 = New System.Windows.Forms.PictureBox
		Me.Panel1.SuspendLayout()
		Me.Page1.SuspendLayout()
		Me.Page2.SuspendLayout()
		Me.Page3.SuspendLayout()
		Me.Panel3.SuspendLayout()
		Me.Page6.SuspendLayout()
		Me.Page4.SuspendLayout()
		Me.Panel4.SuspendLayout()
		Me.Page5.SuspendLayout()
		Me.Panel5.SuspendLayout()
		Me.Panel2.SuspendLayout()
		Me.SuspendLayout()
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.cmdBack)
		Me.Panel1.Controls.Add(Me.cmdCancel)
		Me.Panel1.Controls.Add(Me.cmdNext)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel1.Location = New System.Drawing.Point(0, 541)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(824, 40)
		Me.Panel1.TabIndex = 20
		'
		'cmdBack
		'
		Me.cmdBack.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdBack.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdBack.Location = New System.Drawing.Point(568, 8)
		Me.cmdBack.Name = "cmdBack"
		Me.cmdBack.TabIndex = 0
		Me.cmdBack.Text = "<< &Back"
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(736, 8)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 2
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdNext
		'
		Me.cmdNext.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdNext.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdNext.Location = New System.Drawing.Point(648, 8)
		Me.cmdNext.Name = "cmdNext"
		Me.cmdNext.TabIndex = 1
		Me.cmdNext.Text = "&Next >>"
		'
		'Page1
		'
		Me.Page1.Controls.Add(Me.chkDisableWizard)
		Me.Page1.Controls.Add(Me.Label1)
		Me.Page1.Location = New System.Drawing.Point(24, 64)
		Me.Page1.Name = "Page1"
		Me.Page1.Size = New System.Drawing.Size(256, 224)
		Me.Page1.TabIndex = 1
		'
		'chkDisableWizard
		'
		Me.chkDisableWizard.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkDisableWizard.Location = New System.Drawing.Point(8, 56)
		Me.chkDisableWizard.Name = "chkDisableWizard"
		Me.chkDisableWizard.Size = New System.Drawing.Size(280, 56)
		Me.chkDisableWizard.TabIndex = 0
		Me.chkDisableWizard.Text = "Tick this box if you do not wish to use this wizard. This allows you to create a " & _
		"determinator manually."
		'
		'Label1
		'
		Me.Label1.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label1.Location = New System.Drawing.Point(0, 0)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(256, 48)
		Me.Label1.TabIndex = 0
		Me.Label1.Text = "Welcome to the determinator wizard."
		'
		'Page2
		'
		Me.Page2.Controls.Add(Me.txtDescription)
		Me.Page2.Controls.Add(Me.txtName)
		Me.Page2.Controls.Add(Me.Label8)
		Me.Page2.Controls.Add(Me.Label7)
		Me.Page2.Controls.Add(Me.Label2)
		Me.Page2.Location = New System.Drawing.Point(288, 64)
		Me.Page2.Name = "Page2"
		Me.Page2.Size = New System.Drawing.Size(256, 224)
		Me.Page2.TabIndex = 0
		'
		'txtDescription
		'
		Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtDescription.Location = New System.Drawing.Point(8, 120)
		Me.txtDescription.Multiline = True
		Me.txtDescription.Name = "txtDescription"
		Me.txtDescription.Size = New System.Drawing.Size(232, 88)
		Me.txtDescription.TabIndex = 1
		Me.txtDescription.Text = ""
		'
		'txtName
		'
		Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtName.Location = New System.Drawing.Point(8, 72)
		Me.txtName.Name = "txtName"
		Me.txtName.Size = New System.Drawing.Size(232, 20)
		Me.txtName.TabIndex = 0
		Me.txtName.Text = ""
		'
		'Label8
		'
		Me.Label8.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label8.Location = New System.Drawing.Point(8, 104)
		Me.Label8.Name = "Label8"
		Me.Label8.Size = New System.Drawing.Size(100, 16)
		Me.Label8.TabIndex = 3
		Me.Label8.Text = "Description"
		'
		'Label7
		'
		Me.Label7.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label7.Location = New System.Drawing.Point(8, 56)
		Me.Label7.Name = "Label7"
		Me.Label7.Size = New System.Drawing.Size(100, 16)
		Me.Label7.TabIndex = 2
		Me.Label7.Text = "Name"
		'
		'Label2
		'
		Me.Label2.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label2.Location = New System.Drawing.Point(0, 0)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(256, 48)
		Me.Label2.TabIndex = 1
		Me.Label2.Text = "Please choose a name for your determinator, and enter an optional description."
		'
		'Page3
		'
		Me.Page3.Controls.Add(Me.lstInitiators)
		Me.Page3.Controls.Add(Me.Panel3)
		Me.Page3.Controls.Add(Me.Label3)
		Me.Page3.Location = New System.Drawing.Point(552, 64)
		Me.Page3.Name = "Page3"
		Me.Page3.Size = New System.Drawing.Size(256, 224)
		Me.Page3.TabIndex = 2
		'
		'lstInitiators
		'
		Me.lstInitiators.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lstInitiators.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lstInitiators.Location = New System.Drawing.Point(0, 48)
		Me.lstInitiators.Name = "lstInitiators"
		Me.lstInitiators.Size = New System.Drawing.Size(184, 171)
		Me.lstInitiators.TabIndex = 3
		'
		'Panel3
		'
		Me.Panel3.Controls.Add(Me.cmdRemoveInitiator)
		Me.Panel3.Controls.Add(Me.cmdEditInitiator)
		Me.Panel3.Controls.Add(Me.cmdAddInitiator)
		Me.Panel3.Dock = System.Windows.Forms.DockStyle.Right
		Me.Panel3.Location = New System.Drawing.Point(184, 48)
		Me.Panel3.Name = "Panel3"
		Me.Panel3.Size = New System.Drawing.Size(72, 176)
		Me.Panel3.TabIndex = 2
		'
		'cmdRemoveInitiator
		'
		Me.cmdRemoveInitiator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdRemoveInitiator.Location = New System.Drawing.Point(8, 72)
		Me.cmdRemoveInitiator.Name = "cmdRemoveInitiator"
		Me.cmdRemoveInitiator.Size = New System.Drawing.Size(56, 23)
		Me.cmdRemoveInitiator.TabIndex = 2
		Me.cmdRemoveInitiator.Text = "Remove"
		'
		'cmdEditInitiator
		'
		Me.cmdEditInitiator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdEditInitiator.Location = New System.Drawing.Point(8, 40)
		Me.cmdEditInitiator.Name = "cmdEditInitiator"
		Me.cmdEditInitiator.Size = New System.Drawing.Size(56, 23)
		Me.cmdEditInitiator.TabIndex = 1
		Me.cmdEditInitiator.Text = "Edit"
		'
		'cmdAddInitiator
		'
		Me.cmdAddInitiator.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdAddInitiator.Location = New System.Drawing.Point(8, 8)
		Me.cmdAddInitiator.Name = "cmdAddInitiator"
		Me.cmdAddInitiator.Size = New System.Drawing.Size(56, 23)
		Me.cmdAddInitiator.TabIndex = 0
		Me.cmdAddInitiator.Text = "Add"
		'
		'Label3
		'
		Me.Label3.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label3.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label3.Location = New System.Drawing.Point(0, 0)
		Me.Label3.Name = "Label3"
		Me.Label3.Size = New System.Drawing.Size(256, 48)
		Me.Label3.TabIndex = 1
		Me.Label3.Text = "blank spare page  "
		'
		'Page6
		'
		Me.Page6.Controls.Add(Me.Label6)
		Me.Page6.Location = New System.Drawing.Point(552, 304)
		Me.Page6.Name = "Page6"
		Me.Page6.Size = New System.Drawing.Size(256, 224)
		Me.Page6.TabIndex = 5
		'
		'Label6
		'
		Me.Label6.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label6.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label6.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label6.Location = New System.Drawing.Point(0, 0)
		Me.Label6.Name = "Label6"
		Me.Label6.Size = New System.Drawing.Size(256, 96)
		Me.Label6.TabIndex = 1
		Me.Label6.Text = "You have now completed the determinator creation wizard. Click finish or cancel t" & _
		"o exit the wizard."
		'
		'Page4
		'
		Me.Page4.Controls.Add(Me.lstConditions)
		Me.Page4.Controls.Add(Me.Panel4)
		Me.Page4.Controls.Add(Me.Label4)
		Me.Page4.Location = New System.Drawing.Point(24, 304)
		Me.Page4.Name = "Page4"
		Me.Page4.Size = New System.Drawing.Size(256, 224)
		Me.Page4.TabIndex = 4
		'
		'lstConditions
		'
		Me.lstConditions.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lstConditions.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lstConditions.Location = New System.Drawing.Point(0, 48)
		Me.lstConditions.Name = "lstConditions"
		Me.lstConditions.Size = New System.Drawing.Size(184, 171)
		Me.lstConditions.TabIndex = 0
		'
		'Panel4
		'
		Me.Panel4.Controls.Add(Me.radMatchAny)
		Me.Panel4.Controls.Add(Me.radMatchAll)
		Me.Panel4.Controls.Add(Me.cmdRemoveCondition)
		Me.Panel4.Controls.Add(Me.cmdEditCondition)
		Me.Panel4.Controls.Add(Me.cmdAddCondition)
		Me.Panel4.Dock = System.Windows.Forms.DockStyle.Right
		Me.Panel4.Location = New System.Drawing.Point(184, 48)
		Me.Panel4.Name = "Panel4"
		Me.Panel4.Size = New System.Drawing.Size(72, 176)
		Me.Panel4.TabIndex = 4
		'
		'radMatchAny
		'
		Me.radMatchAny.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radMatchAny.Location = New System.Drawing.Point(8, 136)
		Me.radMatchAny.Name = "radMatchAny"
		Me.radMatchAny.Size = New System.Drawing.Size(56, 32)
		Me.radMatchAny.TabIndex = 4
		Me.radMatchAny.Text = "Match Any"
		Me.radMatchAny.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		'
		'radMatchAll
		'
		Me.radMatchAll.Checked = True
		Me.radMatchAll.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radMatchAll.Location = New System.Drawing.Point(8, 104)
		Me.radMatchAll.Name = "radMatchAll"
		Me.radMatchAll.Size = New System.Drawing.Size(56, 32)
		Me.radMatchAll.TabIndex = 3
		Me.radMatchAll.TabStop = True
		Me.radMatchAll.Text = "Match All"
		Me.radMatchAll.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		'
		'cmdRemoveCondition
		'
		Me.cmdRemoveCondition.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdRemoveCondition.Location = New System.Drawing.Point(8, 72)
		Me.cmdRemoveCondition.Name = "cmdRemoveCondition"
		Me.cmdRemoveCondition.Size = New System.Drawing.Size(56, 23)
		Me.cmdRemoveCondition.TabIndex = 2
		Me.cmdRemoveCondition.Text = "&Remove"
		'
		'cmdEditCondition
		'
		Me.cmdEditCondition.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdEditCondition.Location = New System.Drawing.Point(8, 40)
		Me.cmdEditCondition.Name = "cmdEditCondition"
		Me.cmdEditCondition.Size = New System.Drawing.Size(56, 23)
		Me.cmdEditCondition.TabIndex = 1
		Me.cmdEditCondition.Text = "&Edit"
		'
		'cmdAddCondition
		'
		Me.cmdAddCondition.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdAddCondition.Location = New System.Drawing.Point(8, 8)
		Me.cmdAddCondition.Name = "cmdAddCondition"
		Me.cmdAddCondition.Size = New System.Drawing.Size(56, 23)
		Me.cmdAddCondition.TabIndex = 0
		Me.cmdAddCondition.Text = "&Add"
		'
		'Label4
		'
		Me.Label4.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label4.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label4.Location = New System.Drawing.Point(0, 0)
		Me.Label4.Name = "Label4"
		Me.Label4.Size = New System.Drawing.Size(256, 48)
		Me.Label4.TabIndex = 1
		Me.Label4.Text = "Please specify the CONDITIONS that will cause the determinator to be initiated."
		'
		'Page5
		'
		Me.Page5.Controls.Add(Me.lstActions)
		Me.Page5.Controls.Add(Me.Panel5)
		Me.Page5.Controls.Add(Me.Label5)
		Me.Page5.Location = New System.Drawing.Point(288, 304)
		Me.Page5.Name = "Page5"
		Me.Page5.Size = New System.Drawing.Size(256, 224)
		Me.Page5.TabIndex = 3
		'
		'lstActions
		'
		Me.lstActions.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lstActions.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lstActions.Location = New System.Drawing.Point(0, 48)
		Me.lstActions.Name = "lstActions"
		Me.lstActions.Size = New System.Drawing.Size(184, 171)
		Me.lstActions.TabIndex = 0
		'
		'Panel5
		'
		Me.Panel5.Controls.Add(Me.cmdDownAction)
		Me.Panel5.Controls.Add(Me.cmdUpAction)
		Me.Panel5.Controls.Add(Me.cmdRemoveAction)
		Me.Panel5.Controls.Add(Me.cmdEditAction)
		Me.Panel5.Controls.Add(Me.cmdAddAction)
		Me.Panel5.Dock = System.Windows.Forms.DockStyle.Right
		Me.Panel5.Location = New System.Drawing.Point(184, 48)
		Me.Panel5.Name = "Panel5"
		Me.Panel5.Size = New System.Drawing.Size(72, 176)
		Me.Panel5.TabIndex = 4
		'
		'cmdDownAction
		'
		Me.cmdDownAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdDownAction.Location = New System.Drawing.Point(8, 144)
		Me.cmdDownAction.Name = "cmdDownAction"
		Me.cmdDownAction.Size = New System.Drawing.Size(56, 23)
		Me.cmdDownAction.TabIndex = 6
		Me.cmdDownAction.Text = "&Down"
		'
		'cmdUpAction
		'
		Me.cmdUpAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdUpAction.Location = New System.Drawing.Point(8, 112)
		Me.cmdUpAction.Name = "cmdUpAction"
		Me.cmdUpAction.Size = New System.Drawing.Size(56, 23)
		Me.cmdUpAction.TabIndex = 5
		Me.cmdUpAction.Text = "&Up"
		'
		'cmdRemoveAction
		'
		Me.cmdRemoveAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdRemoveAction.Location = New System.Drawing.Point(8, 72)
		Me.cmdRemoveAction.Name = "cmdRemoveAction"
		Me.cmdRemoveAction.Size = New System.Drawing.Size(56, 23)
		Me.cmdRemoveAction.TabIndex = 2
		Me.cmdRemoveAction.Text = "&Remove"
		'
		'cmdEditAction
		'
		Me.cmdEditAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdEditAction.Location = New System.Drawing.Point(8, 40)
		Me.cmdEditAction.Name = "cmdEditAction"
		Me.cmdEditAction.Size = New System.Drawing.Size(56, 23)
		Me.cmdEditAction.TabIndex = 1
		Me.cmdEditAction.Text = "&Edit"
		'
		'cmdAddAction
		'
		Me.cmdAddAction.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdAddAction.Location = New System.Drawing.Point(8, 8)
		Me.cmdAddAction.Name = "cmdAddAction"
		Me.cmdAddAction.Size = New System.Drawing.Size(56, 23)
		Me.cmdAddAction.TabIndex = 0
		Me.cmdAddAction.Text = "&Add"
		'
		'Label5
		'
		Me.Label5.Dock = System.Windows.Forms.DockStyle.Top
		Me.Label5.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label5.Font = New System.Drawing.Font("Verdana", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label5.Location = New System.Drawing.Point(0, 0)
		Me.Label5.Name = "Label5"
		Me.Label5.Size = New System.Drawing.Size(256, 48)
		Me.Label5.TabIndex = 1
		Me.Label5.Text = "Please  specify the ACTIONS to be performed when the determinator is initiated."
		'
		'Panel2
		'
		Me.Panel2.Controls.Add(Me.Label10)
		Me.Panel2.Controls.Add(Me.PictureBox1)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Top
		Me.Panel2.Location = New System.Drawing.Point(0, 0)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(824, 56)
		Me.Panel2.TabIndex = 9
		'
		'Label10
		'
		Me.Label10.Dock = System.Windows.Forms.DockStyle.Fill
		Me.Label10.Font = New System.Drawing.Font("Verdana", 20.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label10.Location = New System.Drawing.Point(80, 0)
		Me.Label10.Name = "Label10"
		Me.Label10.Size = New System.Drawing.Size(744, 56)
		Me.Label10.TabIndex = 1
		Me.Label10.Text = "Determinator Wizard"
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
		'frmDeterminatorWizard
		'
		Me.AcceptButton = Me.cmdNext
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(824, 581)
		Me.Controls.Add(Me.Page6)
		Me.Controls.Add(Me.Page4)
		Me.Controls.Add(Me.Page5)
		Me.Controls.Add(Me.Page3)
		Me.Controls.Add(Me.Page1)
		Me.Controls.Add(Me.Panel1)
		Me.Controls.Add(Me.Page2)
		Me.Controls.Add(Me.Panel2)
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmDeterminatorWizard"
		Me.Text = "Determinator Wizard"
		Me.Panel1.ResumeLayout(False)
		Me.Page1.ResumeLayout(False)
		Me.Page2.ResumeLayout(False)
		Me.Page3.ResumeLayout(False)
		Me.Panel3.ResumeLayout(False)
		Me.Page6.ResumeLayout(False)
		Me.Page4.ResumeLayout(False)
		Me.Panel4.ResumeLayout(False)
		Me.Page5.ResumeLayout(False)
		Me.Panel5.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region

  Public Group As String
    Private CurrentPage As Integer



    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

  Private Sub frmDeterminatorWizard_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    Me.Height = 390
    Me.Width = 542
    CurrentPage = 1
    UpdatePage()
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

    Select Case CurrentPage
      Case 1
        cmdBack.Enabled = False
        Page1.Visible = True        
        chkDisableWizard.Focus()
      Case 2
        Page2.Visible = True
        cmdBack.Enabled = True
        txtName.Focus()
        'Case 3
        '  Page3.Visible = True                
        '  lstInitiators.Focus()
      Case 4
        Page4.Visible = True                
        lstConditions.Focus()
      Case 5
        Page5.Visible = True                
        cmdNext.Text = "&Next >>"
        lstActions.Focus()
      Case 6
        Page6.Visible = True        
        cmdNext.Text = "Finish"
        cmdNext.Focus()
    End Select
    Me.ResumeLayout()
  End Sub


  Private Sub cmdNext_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdNext.Click
    Select Case CurrentPage
      Case 1 ' welcome and disable
        If chkDisableWizard.Checked Then
          Dim f As New frmDeterminator
          f.myRule = New xplhalMgrBase.DeterminatorRule
          f.Show()
          Me.Close()
        Else
          CurrentPage = 2
          UpdatePage()
        End If
      Case 2 ' Name and Description
        If RegularExpressions.Regex.IsMatch(txtName.Text, "^\w(\w|\s|:|\.|-){0,63}$") Then
          ' Make sure name is unique
          If determinatorExists(txtName.Text) Then
            MsgBox("A determinator with the specified name already exists.", MsgBoxStyle.Exclamation)
          Else
            CurrentPage = 4
            UpdatePage()
          End If
        Else
            MsgBox("The name of the Determinator is invalid.", vbExclamation)
            txtName.Focus()
          End If
      Case 3 ' Initiators
          'If lstInitiators.Items.Count > 0 Then
          'CurrentPage = 4
          'UpdatePage()
          'Else
          ' MsgBox("There must be at least one initiator.", vbExclamation)
          'End If
      Case 4 ' Conditions
          'If lstConditions.Items.Count > 0 Then
          CurrentPage = 5
          UpdatePage()
          'Else
          'MsgBox("There must be at lease one condition", MsgBoxStyle.Exclamation)
          'End If
      Case 5 ' Actions
          If lstActions.Items.Count > 0 Then
            CurrentPage = 6
            UpdatePage()
          Else
            MsgBox("There must be at least one action.", vbExclamation)
          End If
      Case 6 ' Finished
          SaveDeterminator()
    End Select
  End Sub

  Private Sub cmdBack_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdBack.Click
    Select Case CurrentPage
      Case 2
        CurrentPage = 1
        UpdatePage()
        'Case 3
        '  CurrentPage = 2
        '  UpdatePage()
      Case 4
        CurrentPage = 2
        UpdatePage()
      Case 5
        CurrentPage = 4
        UpdatePage()
      Case 6
        CurrentPage = 5
        UpdatePage()
    End Select
  End Sub

    Private Sub SaveDeterminator()
        'Try
            Dim r As New DeterminatorRule
            Dim Counter As Integer
            Dim ruleText As String
            r.RuleName = txtName.Text
    r.RuleDescription = txtDescription.Text
    r.GroupName = Group
    r.MatchAny = radMatchAny.Checked
    r.Enabled = True
    ' Add conditions
            ReDim r.Conditions(lstConditions.Items.Count - 1)
            For Counter = 0 To lstConditions.Items.Count - 1
                r.Conditions(Counter) = CType(lstConditions.Items(Counter), DeterminatorRule.DeterminatorCondition)
            Next
            ' Add actions
            ReDim r.Actions(lstActions.Items.Count - 1)
            For Counter = 0 To lstActions.Items.Count - 1
                r.Actions(Counter) = CType(lstActions.Items(Counter), DeterminatorRule.DeterminatorAction)
            Next
            ruleText = r.Save
            setRule("", ruleText)
            Me.Close()
            'Catch ex As Exception
            'MsgBox("xPLHal was unable to save your new Determinator because of the following error:" & vbCrLf & vbCrLf & ex.Message, vbExclamation)
            'End Try
    End Sub

    Private Sub cmdAddInitiator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAddInitiator.Click
        'Dim f As New frmDeterminatorSubWizard
        'f.Mode = SubWizardMode.Initiator
        'If f.ShowDialog = DialogResult.OK Then
        '  lstInitiators.Items.Add(f.myCondition)
        'End If
    End Sub

    Private Sub cmdAddCondition_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAddCondition.Click
        Dim f As New frmDeterminatorSubWizard
        f.Mode = SubWizardMode.Condition
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            lstConditions.Items.Add(f.myCondition)
        End If
    End Sub

    Private Sub cmdAddAction_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAddAction.Click
        Dim f As New frmDeterminatorSubWizard
        f.Mode = SubWizardMode.Action
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            lstActions.Items.Add(f.myAction)
        End If
    End Sub

    Private Sub cmdRemoveInitiator_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRemoveInitiator.Click
        If lstInitiators.SelectedIndex <> -1 Then
            lstInitiators.Items.RemoveAt(lstInitiators.SelectedIndex)
        End If
    End Sub

    Private Sub cmdRemoveCondition_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRemoveCondition.Click
        If lstConditions.SelectedIndex <> -1 Then
            lstConditions.Items.RemoveAt(lstConditions.SelectedIndex)
        End If
    End Sub

    Private Sub cmdRemoveAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRemoveAction.Click
        If lstActions.SelectedIndex <> -1 Then
            lstActions.Items.RemoveAt(lstActions.SelectedIndex)
        End If
    End Sub

    Private Sub cmdEditInitiator_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEditInitiator.Click
        If lstInitiators.SelectedIndex <> -1 Then
            Dim f As New frmEditDeterminator
            f.myCondition = CType(lstInitiators.Items(lstInitiators.SelectedIndex), DeterminatorRule.DeterminatorCondition)
            If f.ShowDialog = Windows.Forms.DialogResult.OK Then
                lstInitiators.Items(lstInitiators.SelectedIndex) = f.myCondition
            End If
        End If
    End Sub

    Private Sub cmdEditCondition_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEditCondition.Click
        If lstConditions.SelectedIndex <> -1 Then
            Dim f As New frmEditDeterminator
            f.myCondition = CType(lstConditions.Items(lstConditions.SelectedIndex), DeterminatorRule.DeterminatorCondition)
            If f.ShowDialog = Windows.Forms.DialogResult.OK Then
                lstConditions.Items(lstConditions.SelectedIndex) = f.myCondition
            End If
        End If
    End Sub

    Private Sub cmdEditAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEditAction.Click
        If lstActions.SelectedIndex <> -1 Then
            Dim f As New frmEditDeterminatorAction
            f.myAction = CType(lstActions.Items(lstActions.SelectedIndex), DeterminatorRule.DeterminatorAction)
            If f.ShowDialog = Windows.Forms.DialogResult.OK Then
                lstActions.Items(lstActions.SelectedIndex) = f.myAction
            End If
        End If
    End Sub

    Private Sub cmdUpAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdUpAction.Click
        If lstActions.SelectedItems.Count = 1 Then
            Dim I As Integer, lstItem As Object
            'li = lstActions.SelectedItems(0)
            I = lstActions.SelectedIndex
            lstItem = lstActions.Items(I)
            If I > 0 Then
                lstActions.Items.RemoveAt(lstActions.SelectedIndex)
                lstActions.Items.Insert(I - 1, lstItem)
                lstActions.SelectedIndex = I - 1
            End If
        End If
    End Sub


    Private Sub cmdDownAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdDownAction.Click
        If lstActions.SelectedItems.Count = 1 Then
            Dim I As Integer, lstItem As Object
            'li = lstActions.SelectedItems(0)
            I = lstActions.SelectedIndex
            lstItem = lstActions.Items(I)
            If I < lstActions.Items.Count - 1 Then
                lstActions.Items.RemoveAt(lstActions.SelectedIndex)
                lstActions.Items.Insert(I + 1, lstItem)
                lstActions.SelectedIndex = I + 1
            End If
        End If
    End Sub


End Class
