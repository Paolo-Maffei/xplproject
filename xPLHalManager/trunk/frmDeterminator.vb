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

Public Class frmDeterminator
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
    Friend WithEvents TabControl1 As System.Windows.Forms.TabControl
    Friend WithEvents tabConditions As System.Windows.Forms.TabPage
    Friend WithEvents tabActions As System.Windows.Forms.TabPage
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents Panel3 As System.Windows.Forms.Panel
    Friend WithEvents lvwConditions As System.Windows.Forms.ListView
    Friend WithEvents cmdAdd As System.Windows.Forms.Button
    Friend WithEvents cmdEdit As System.Windows.Forms.Button
    Friend WithEvents cmdRemove As System.Windows.Forms.Button
  Friend WithEvents lvwActions As System.Windows.Forms.ListView
    Friend WithEvents Panel4 As System.Windows.Forms.Panel
  Friend WithEvents cmdDownAction As System.Windows.Forms.Button
  Friend WithEvents cmdUpAction As System.Windows.Forms.Button
  Friend WithEvents cmdRemoveAction As System.Windows.Forms.Button
  Friend WithEvents cmdEditAction As System.Windows.Forms.Button
  Friend WithEvents cmdAddAction As System.Windows.Forms.Button
  Friend WithEvents tabGeneral As System.Windows.Forms.TabPage
  Friend WithEvents txtName As System.Windows.Forms.TextBox
  Friend WithEvents txtDescription As System.Windows.Forms.TextBox
  Friend WithEvents Label1 As System.Windows.Forms.Label
  Friend WithEvents Label2 As System.Windows.Forms.Label
  Friend WithEvents Panel5 As System.Windows.Forms.Panel
  Friend WithEvents radMatchAll As System.Windows.Forms.RadioButton
  Friend WithEvents radMatchAny As System.Windows.Forms.RadioButton
  Friend WithEvents chkIsEnabled As System.Windows.Forms.CheckBox
  Friend WithEvents cmdConditionWizard As System.Windows.Forms.Button
  Friend WithEvents cmdActionWizard As System.Windows.Forms.Button
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
    Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmDeterminator))
    Me.TabControl1 = New System.Windows.Forms.TabControl
    Me.tabGeneral = New System.Windows.Forms.TabPage
    Me.txtDescription = New System.Windows.Forms.TextBox
    Me.Panel5 = New System.Windows.Forms.Panel
    Me.chkIsEnabled = New System.Windows.Forms.CheckBox
    Me.Label1 = New System.Windows.Forms.Label
    Me.Label2 = New System.Windows.Forms.Label
    Me.txtName = New System.Windows.Forms.TextBox
    Me.tabConditions = New System.Windows.Forms.TabPage
    Me.lvwConditions = New System.Windows.Forms.ListView
    Me.Panel3 = New System.Windows.Forms.Panel
    Me.cmdConditionWizard = New System.Windows.Forms.Button
    Me.radMatchAny = New System.Windows.Forms.RadioButton
    Me.radMatchAll = New System.Windows.Forms.RadioButton
    Me.cmdRemove = New System.Windows.Forms.Button
    Me.cmdEdit = New System.Windows.Forms.Button
    Me.cmdAdd = New System.Windows.Forms.Button
    Me.tabActions = New System.Windows.Forms.TabPage
    Me.lvwActions = New System.Windows.Forms.ListView
    Me.Panel4 = New System.Windows.Forms.Panel
    Me.cmdActionWizard = New System.Windows.Forms.Button
    Me.cmdDownAction = New System.Windows.Forms.Button
    Me.cmdUpAction = New System.Windows.Forms.Button
    Me.cmdRemoveAction = New System.Windows.Forms.Button
    Me.cmdEditAction = New System.Windows.Forms.Button
    Me.cmdAddAction = New System.Windows.Forms.Button
    Me.Panel1 = New System.Windows.Forms.Panel
    Me.cmdCancel = New System.Windows.Forms.Button
    Me.cmdOK = New System.Windows.Forms.Button
    Me.Panel2 = New System.Windows.Forms.Panel
    Me.TabControl1.SuspendLayout()
    Me.tabGeneral.SuspendLayout()
    Me.Panel5.SuspendLayout()
    Me.tabConditions.SuspendLayout()
    Me.Panel3.SuspendLayout()
    Me.tabActions.SuspendLayout()
    Me.Panel4.SuspendLayout()
    Me.Panel1.SuspendLayout()
    Me.Panel2.SuspendLayout()
    Me.SuspendLayout()
    '
    'TabControl1
    '
    Me.TabControl1.Controls.Add(Me.tabGeneral)
    Me.TabControl1.Controls.Add(Me.tabConditions)
    Me.TabControl1.Controls.Add(Me.tabActions)
    Me.TabControl1.Dock = System.Windows.Forms.DockStyle.Fill
    Me.TabControl1.Location = New System.Drawing.Point(0, 0)
    Me.TabControl1.Name = "TabControl1"
    Me.TabControl1.SelectedIndex = 0
    Me.TabControl1.Size = New System.Drawing.Size(744, 473)
    Me.TabControl1.TabIndex = 0
    '
    'tabGeneral
    '
    Me.tabGeneral.Controls.Add(Me.txtDescription)
    Me.tabGeneral.Controls.Add(Me.Panel5)
    Me.tabGeneral.Location = New System.Drawing.Point(4, 22)
    Me.tabGeneral.Name = "tabGeneral"
    Me.tabGeneral.Size = New System.Drawing.Size(736, 447)
    Me.tabGeneral.TabIndex = 2
    Me.tabGeneral.Text = "General"
    '
    'txtDescription
    '
    Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.txtDescription.Dock = System.Windows.Forms.DockStyle.Fill
    Me.txtDescription.Location = New System.Drawing.Point(0, 72)
    Me.txtDescription.Multiline = True
    Me.txtDescription.Name = "txtDescription"
    Me.txtDescription.Size = New System.Drawing.Size(736, 375)
    Me.txtDescription.TabIndex = 1
    Me.txtDescription.Text = ""
    '
    'Panel5
    '
    Me.Panel5.Controls.Add(Me.chkIsEnabled)
    Me.Panel5.Controls.Add(Me.Label1)
    Me.Panel5.Controls.Add(Me.Label2)
    Me.Panel5.Controls.Add(Me.txtName)
    Me.Panel5.Dock = System.Windows.Forms.DockStyle.Top
    Me.Panel5.Location = New System.Drawing.Point(0, 0)
    Me.Panel5.Name = "Panel5"
    Me.Panel5.Size = New System.Drawing.Size(736, 72)
    Me.Panel5.TabIndex = 0
    '
    'chkIsEnabled
    '
    Me.chkIsEnabled.FlatStyle = FlatStyle.System
    Me.chkIsEnabled.Checked = True
    Me.chkIsEnabled.CheckState = System.Windows.Forms.CheckState.Checked
    Me.chkIsEnabled.Location = New System.Drawing.Point(224, 24)
    Me.chkIsEnabled.Name = "chkIsEnabled"
    Me.chkIsEnabled.Size = New System.Drawing.Size(176, 16)
    Me.chkIsEnabled.TabIndex = 4
    Me.chkIsEnabled.Text = "This determinator is enabled"
    '
    'Label1
    '
    Me.Label1.Location = New System.Drawing.Point(0, 56)
    Me.Label1.Name = "Label1"
    Me.Label1.Size = New System.Drawing.Size(216, 16)
    Me.Label1.TabIndex = 2
    Me.Label1.FlatStyle = FlatStyle.System
    Me.Label1.Text = "Determinator Description"
    '
    'Label2
    '
    Me.Label2.Location = New System.Drawing.Point(0, 8)
    Me.Label2.Name = "Label2"
    Me.Label2.Size = New System.Drawing.Size(192, 16)
    Me.Label2.TabIndex = 3
    Me.Label2.FlatStyle = FlatStyle.System
    Me.Label2.Text = "Determinator Name"
    '
    'txtName
    '
    Me.txtName.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.txtName.Location = New System.Drawing.Point(0, 24)
    Me.txtName.Name = "txtName"
    Me.txtName.Size = New System.Drawing.Size(192, 20)
    Me.txtName.TabIndex = 0
    Me.txtName.Text = ""
    '
    'tabConditions
    '
    Me.tabConditions.Controls.Add(Me.lvwConditions)
    Me.tabConditions.Controls.Add(Me.Panel3)
    Me.tabConditions.Location = New System.Drawing.Point(4, 22)
    Me.tabConditions.Name = "tabConditions"
    Me.tabConditions.Size = New System.Drawing.Size(736, 447)
    Me.tabConditions.TabIndex = 0
    Me.tabConditions.Text = "Conditions"
    '
    'lvwConditions
    '
    Me.lvwConditions.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.lvwConditions.Dock = System.Windows.Forms.DockStyle.Fill
    Me.lvwConditions.FullRowSelect = True
    Me.lvwConditions.Location = New System.Drawing.Point(0, 0)
    Me.lvwConditions.Name = "lvwConditions"
    Me.lvwConditions.Size = New System.Drawing.Size(640, 447)
    Me.lvwConditions.TabIndex = 0
    Me.lvwConditions.View = System.Windows.Forms.View.Details
    '
    'Panel3
    '
    Me.Panel3.Controls.Add(Me.cmdConditionWizard)
    Me.Panel3.Controls.Add(Me.radMatchAny)
    Me.Panel3.Controls.Add(Me.radMatchAll)
    Me.Panel3.Controls.Add(Me.cmdRemove)
    Me.Panel3.Controls.Add(Me.cmdEdit)
    Me.Panel3.Controls.Add(Me.cmdAdd)
    Me.Panel3.Dock = System.Windows.Forms.DockStyle.Right
    Me.Panel3.Location = New System.Drawing.Point(640, 0)
    Me.Panel3.Name = "Panel3"
    Me.Panel3.Size = New System.Drawing.Size(96, 447)
    Me.Panel3.TabIndex = 5
    '
    'cmdConditionWizard
    '
    Me.cmdConditionWizard.Location = New System.Drawing.Point(16, 120)
    Me.cmdConditionWizard.Name = "cmdConditionWizard"
    Me.cmdConditionWizard.Size = New System.Drawing.Size(64, 23)
    Me.cmdConditionWizard.TabIndex = 7
    Me.cmdConditionWizard.Text = "&Wizard"
    '
    'radMatchAny
    '
    Me.radMatchAny.Location = New System.Drawing.Point(8, 272)
    Me.radMatchAny.Name = "radMatchAny"
    Me.radMatchAny.Size = New System.Drawing.Size(80, 24)
    Me.radMatchAny.TabIndex = 6
    Me.radMatchAny.Text = "Match Any"
    '
    'radMatchAll
    '
    Me.radMatchAll.Checked = True
    Me.radMatchAll.Location = New System.Drawing.Point(8, 248)
    Me.radMatchAll.Name = "radMatchAll"
    Me.radMatchAll.Size = New System.Drawing.Size(80, 24)
    Me.radMatchAll.TabIndex = 5
    Me.radMatchAll.TabStop = True
    Me.radMatchAll.Text = "Match All"
    '
    'cmdRemove
    '
    Me.cmdRemove.Location = New System.Drawing.Point(16, 72)
    Me.cmdRemove.Name = "cmdRemove"
    Me.cmdRemove.Size = New System.Drawing.Size(64, 23)
    Me.cmdRemove.TabIndex = 2
    Me.cmdRemove.FlatStyle = FlatStyle.System
    Me.cmdRemove.Text = "&Remove"
    '
    'cmdEdit
    '
    Me.cmdEdit.Location = New System.Drawing.Point(16, 40)
    Me.cmdEdit.Name = "cmdEdit"
    Me.cmdEdit.Size = New System.Drawing.Size(64, 23)
    Me.cmdEdit.FlatStyle = FlatStyle.System
    Me.cmdEdit.TabIndex = 1
    Me.cmdEdit.Text = "&Edit"
    '
    'cmdAdd
    '
    Me.cmdAdd.Location = New System.Drawing.Point(16, 8)
    Me.cmdAdd.Name = "cmdAdd"
    Me.cmdAdd.Size = New System.Drawing.Size(64, 23)
    Me.cmdAdd.TabIndex = 0
    Me.cmdAdd.FlatStyle = FlatStyle.System
    Me.cmdAdd.Text = "&Add"
    '
    'tabActions
    '
    Me.tabActions.Controls.Add(Me.lvwActions)
    Me.tabActions.Controls.Add(Me.Panel4)
    Me.tabActions.Location = New System.Drawing.Point(4, 22)
    Me.tabActions.Name = "tabActions"
    Me.tabActions.Size = New System.Drawing.Size(736, 447)
    Me.tabActions.TabIndex = 1
    Me.tabActions.Text = "Actions"
    '
    'lvwActions
    '
    Me.lvwActions.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
    Me.lvwActions.Dock = System.Windows.Forms.DockStyle.Fill
    Me.lvwActions.FullRowSelect = True
    Me.lvwActions.Location = New System.Drawing.Point(0, 0)
    Me.lvwActions.Name = "lvwActions"
    Me.lvwActions.Size = New System.Drawing.Size(640, 447)
    Me.lvwActions.TabIndex = 3
    Me.lvwActions.View = System.Windows.Forms.View.Details
    '
    'Panel4
    '
    Me.Panel4.Controls.Add(Me.cmdActionWizard)
    Me.Panel4.Controls.Add(Me.cmdDownAction)
    Me.Panel4.Controls.Add(Me.cmdUpAction)
    Me.Panel4.Controls.Add(Me.cmdRemoveAction)
    Me.Panel4.Controls.Add(Me.cmdEditAction)
    Me.Panel4.Controls.Add(Me.cmdAddAction)
    Me.Panel4.Dock = System.Windows.Forms.DockStyle.Right
    Me.Panel4.Location = New System.Drawing.Point(640, 0)
    Me.Panel4.Name = "Panel4"
    Me.Panel4.Size = New System.Drawing.Size(96, 447)
    Me.Panel4.TabIndex = 5
    '
    'cmdActionWizard
    '
    Me.cmdActionWizard.Location = New System.Drawing.Point(16, 120)
    Me.cmdActionWizard.Name = "cmdActionWizard"
    Me.cmdActionWizard.Size = New System.Drawing.Size(64, 23)
    Me.cmdActionWizard.TabIndex = 8
    Me.cmdActionWizard.FlatStyle = FlatStyle.System
    Me.cmdActionWizard.Text = "&Wizard"
    '
    'cmdDownAction
    '
    Me.cmdDownAction.Location = New System.Drawing.Point(16, 208)
    Me.cmdDownAction.Name = "cmdDownAction"
    Me.cmdDownAction.Size = New System.Drawing.Size(64, 23)
    Me.cmdDownAction.TabIndex = 4
    Me.cmdDownAction.FlatStyle = FlatStyle.System
    Me.cmdDownAction.Text = "&Down"
    '
    'cmdUpAction
    '
    Me.cmdUpAction.Location = New System.Drawing.Point(16, 176)
    Me.cmdUpAction.Name = "cmdUpAction"
    Me.cmdUpAction.FlatStyle = FlatStyle.System
    Me.cmdUpAction.Size = New System.Drawing.Size(64, 23)
    Me.cmdUpAction.TabIndex = 3
    Me.cmdUpAction.Text = "&Up"
    '
    'cmdRemoveAction
    '
    Me.cmdRemoveAction.Location = New System.Drawing.Point(16, 72)
    Me.cmdRemoveAction.Name = "cmdRemoveAction"
    Me.cmdRemoveAction.Size = New System.Drawing.Size(64, 23)
    Me.cmdRemoveAction.TabIndex = 2
    Me.cmdRemoveAction.FlatStyle = FlatStyle.System
    Me.cmdRemoveAction.Text = "&Remove"
    '
    'cmdEditAction
    '
    Me.cmdEditAction.Location = New System.Drawing.Point(16, 40)
    Me.cmdEditAction.Name = "cmdEditAction"
    Me.cmdEditAction.FlatStyle = FlatStyle.System
    Me.cmdEditAction.Size = New System.Drawing.Size(64, 23)
    Me.cmdEditAction.TabIndex = 1
    Me.cmdEditAction.Text = "&Edit"
    '
    'cmdAddAction
    '
    Me.cmdAddAction.Location = New System.Drawing.Point(16, 8)
    Me.cmdAddAction.FlatStyle = FlatStyle.System
    Me.cmdAddAction.Name = "cmdAddAction"
    Me.cmdAddAction.Size = New System.Drawing.Size(64, 23)
    Me.cmdAddAction.TabIndex = 0
    Me.cmdAddAction.Text = "&Add"
    '
    'Panel1
    '
    Me.Panel1.Controls.Add(Me.cmdCancel)
    Me.Panel1.Controls.Add(Me.cmdOK)
    Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
    Me.Panel1.Location = New System.Drawing.Point(0, 473)
    Me.Panel1.Name = "Panel1"
    Me.Panel1.Size = New System.Drawing.Size(744, 40)
    Me.Panel1.TabIndex = 10
    '
    'cmdCancel
    '
    Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
    Me.cmdCancel.Location = New System.Drawing.Point(664, 8)
    Me.cmdCancel.Name = "cmdCancel"
    Me.cmdCancel.TabIndex = 1
    Me.cmdCancel.FlatStyle = FlatStyle.System
    Me.cmdCancel.Text = "&Cancel"
    '
    'cmdOK
    '
    Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
    Me.cmdOK.FlatStyle = FlatStyle.System
    Me.cmdOK.Location = New System.Drawing.Point(584, 8)
    Me.cmdOK.Name = "cmdOK"
    Me.cmdOK.TabIndex = 0
    Me.cmdOK.Text = "&OK"
    '
    'Panel2
    '
    Me.Panel2.Controls.Add(Me.TabControl1)
    Me.Panel2.Dock = System.Windows.Forms.DockStyle.Fill
    Me.Panel2.Location = New System.Drawing.Point(0, 0)
    Me.Panel2.Name = "Panel2"
    Me.Panel2.Size = New System.Drawing.Size(744, 473)
    Me.Panel2.TabIndex = 2
    '
    'frmDeterminator
    '
    Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
    Me.CancelButton = Me.cmdCancel
    Me.ClientSize = New System.Drawing.Size(744, 513)
    Me.Controls.Add(Me.Panel2)
    Me.Controls.Add(Me.Panel1)
    Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
    Me.Name = "frmDeterminator"
    Me.Text = "xPL Determinator"
    Me.TabControl1.ResumeLayout(False)
    Me.tabGeneral.ResumeLayout(False)
    Me.Panel5.ResumeLayout(False)
    Me.tabConditions.ResumeLayout(False)
    Me.Panel3.ResumeLayout(False)
    Me.tabActions.ResumeLayout(False)
    Me.Panel4.ResumeLayout(False)
    Me.Panel1.ResumeLayout(False)
    Me.Panel2.ResumeLayout(False)
    Me.ResumeLayout(False)

  End Sub

#End Region

    ' This is a reference to the rule being edited.
    ' The caller should either set this to a new rule, or an existing rule to be edited, prior to showing this form.
    Public myRule As DeterminatorRule
    Public myRuleGuid As String

    Private Sub cmdAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAdd.Click
        Dim f As New frmEditDeterminator
        f.myCondition = New DeterminatorRule.DeterminatorCondition
        If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
            Dim li As New ListViewItem
            li.Text = f.myCondition.DisplayName
            li.Tag = f.myCondition
            lvwConditions.Items.Add(li)
        End If
    End Sub

    Private Sub cmdAddAction_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAddAction.Click
        Dim f As New frmEditDeterminatorAction
        f.myAction = New DeterminatorRule.DeterminatorAction
		If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
			Dim li As New ListViewItem
			li.Text = f.myAction.DisplayName
			li.Tag = f.myAction
			lvwActions.Items.Add(li)
		End If
    End Sub

  Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
    Dim Counter As Integer
    ' Validate the form
    If Not RegularExpressions.Regex.IsMatch(txtName.Text, "^\w(\w|\s|:|-|_|\.){0,63}$") Then
      MsgBox("The name of the determinator is invalid.", vbExclamation)
      TabControl1.SelectedIndex = 0
      txtName.Focus()
      Exit Sub
    End If

    ' Update name and description
    If txtName.Text.ToLower().Trim() <> myRule.RuleName.ToLower().Trim() Then
      ' Name has changed. Make sure it's not a duplicate.
      If determinatorExists(txtName.Text) Then
        MsgBox("A determinator with the specified name already exists.", MsgBoxStyle.Exclamation)
        Exit Sub
      End If
    End If
    myRule.RuleName = txtName.Text


    myRule.RuleDescription = txtDescription.Text
    myRule.Enabled = chkIsEnabled.Checked

    If radMatchAll.Checked Then
      myRule.MatchAny = False
    Else
      myRule.MatchAny = True
    End If


    ' Set conditions
    ReDim myRule.Conditions(lvwConditions.Items.Count - 1)
    For Counter = 0 To lvwConditions.Items.Count - 1
      myRule.Conditions(Counter) = CType(lvwConditions.Items(Counter).Tag, DeterminatorRule.DeterminatorCondition)
    Next

    ' Set actions
    ReDim myRule.Actions(lvwActions.Items.Count - 1)
    For Counter = 0 To lvwActions.Items.Count - 1
      myRule.Actions(Counter) = CType(lvwActions.Items(Counter).Tag, DeterminatorRule.DeterminatorAction)
    Next

    Dim ruletext As String
    ruletext = myRule.Save()
    setrule(myRuleGuid, ruletext)
    Me.Close()
  End Sub

  Private Sub frmDeterminator_load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load    
    lvwConditions.Columns.Add("Condition Name", 250, HorizontalAlignment.Left)    
    lvwActions.Columns.Add("Action Name", 250, HorizontalAlignment.Left)
    radMatchAll.Checked = True
    If myRuleGuid = "" Then
      ' New determinator
      Me.Text = "New Determinator"
      chkIsEnabled.Checked = True
    Else
      Me.Text = "Edit Determinator (" & myRule.RuleName & ")"
      txtName.Text = myRule.RuleName
      txtDescription.Text = myRule.RuleDescription
      radMatchAny.Checked = myRule.MatchAny
      chkIsEnabled.Checked = myRule.Enabled
      Dim Counter As Integer
      Dim li As ListViewItem
      For Counter = 0 To myRule.Conditions.Length - 1
        li = New ListViewItem
        li.Text = myRule.Conditions(Counter).DisplayName
        li.Tag = myRule.Conditions(Counter)
        lvwConditions.Items.Add(li)
      Next
      For Counter = 0 To myRule.Actions.Length - 1
        li = New ListViewItem
        If Not myRule.Actions(Counter) Is Nothing Then
          li.Text = myRule.Actions(Counter).DisplayName
          li.Tag = myRule.Actions(Counter)
          lvwActions.Items.Add(li)
        End If
      Next
    End If
  End Sub

  Private Sub cmdEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEdit.Click
    If lvwConditions.SelectedItems.Count <> 1 Then Exit Sub
    Dim f As New frmEditDeterminator
    f.myCondition = CType(lvwConditions.SelectedItems(0).Tag, DeterminatorRule.DeterminatorCondition)
        If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
            lvwConditions.SelectedItems(0).Text = f.myCondition.DisplayName
            lvwConditions.SelectedItems(0).Tag = f.myCondition
        End If
  End Sub

  Private Sub cmdEditAction_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEditAction.Click
    If lvwActions.SelectedItems.Count <> 1 Then Exit Sub
    Dim f As New frmEditDeterminatorAction
    f.myAction = CType(lvwActions.SelectedItems(0).Tag, DeterminatorRule.DeterminatorAction)
        If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
            lvwActions.SelectedItems(0).Text = f.myAction.DisplayName
            lvwActions.SelectedItems(0).Tag = f.myAction
        End If
  End Sub

  Private Sub cmdRemove_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRemove.Click
    If lvwConditions.SelectedItems.Count = 1 Then
      lvwConditions.SelectedItems(0).Remove()
    End If
  End Sub

  Private Sub cmdRemoveAction_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRemoveAction.Click
    If lvwActions.SelectedItems.Count = 1 Then
      lvwActions.SelectedItems(0).Remove()
    End If
  End Sub

  Private Sub cmdUpAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdUpAction.Click
    If lvwActions.SelectedItems.Count = 1 Then
      Dim li As ListViewItem, I As Integer
      li = lvwActions.SelectedItems(0)
      I = li.Index
      If I > 0 Then
        lvwActions.SelectedItems(0).Remove()
        lvwActions.Items.Insert(I - 1, li)
      End If
    End If
  End Sub

  Private Sub cmdDownAction_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdDownAction.Click
    If lvwActions.SelectedItems.Count = 1 Then
      Dim li As ListViewItem, I As Integer
      li = lvwActions.SelectedItems(0)
      I = li.Index
      If I < lvwActions.Items.Count - 1 Then
        lvwActions.SelectedItems(0).Remove()
        lvwActions.Items.Insert(I + 1, li)
      End If
    End If
  End Sub

  Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
    Me.Close()
  End Sub

  Private Sub lvwConditions_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles lvwConditions.DoubleClick
    cmdEdit_Click(Nothing, Nothing)
  End Sub

  Private Sub lvwActions_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles lvwActions.DoubleClick
    cmdEditAction_Click(Nothing, Nothing)
  End Sub

  Private Sub cmdActionWizard_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdActionWizard.Click
    Dim f As New frmDeterminatorSubWizard
    f.Mode = SubWizardMode.Action
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            Dim li As New ListViewItem
            li.Text = f.myAction.DisplayName
            li.Tag = f.myAction
            lvwActions.Items.Add(li)
        End If
  End Sub

  Private Sub cmdConditionWizard_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdConditionWizard.Click
    Dim f As New frmDeterminatorSubWizard
    f.Mode = SubWizardMode.Condition
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
            Dim li As New ListViewItem
            li.Text = f.myCondition.DisplayName
            li.Tag = f.myCondition
            lvwConditions.Items.Add(li)
        End If
  End Sub

  Private Sub txtName_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles txtName.TextChanged
    Me.Text = "Edit Determinator (" & txtName.Text & ")"
  End Sub
End Class
