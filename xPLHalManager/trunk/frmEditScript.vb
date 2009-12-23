'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2007 John Bent & Ian Jeffery
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

Public Class frmEditScript
    Inherits xplhalMgrBase

    Public IsNewScript As Boolean

    Private sName As String
    Private IsDirty As Boolean
    Friend WithEvents rtfscript As ScintillaNet.Scintilla
    Private FirstActivate As Boolean

  Public Property ScriptName() As String
    Get
      Return sName
    End Get
    Set(ByVal Value As String)
      sName = Value
      If sName = "" Or IsNewScript Then
        Me.Text = "Create New Script"
      Else
        Me.Text = "Edit Script " & sName
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
  Friend WithEvents mnuMain As System.Windows.Forms.MainMenu
  Friend WithEvents mnuFile As MenuItem
  Friend WithEvents mnuFileSave As MenuItem
  Friend WithEvents mnuFileSaveReload As MenuItem
  Friend WithEvents mnuFileBar1 As MenuItem
  Friend WithEvents mnuFileExit As MenuItem
  Friend WithEvents mnuEdit As MenuItem
  Friend WithEvents mnuEditUndo As MenuItem
  Friend WithEvents mnuEditBar2 As MenuItem
  Friend WithEvents mnuEditCut As MenuItem
  Friend WithEvents mnuEditCopy As MenuItem
  Friend WithEvents mnuEditPaste As MenuItem
  Friend WithEvents mnuEditDelete As MenuItem
  Friend WithEvents mnuEditBar3 As MenuItem
  Friend WithEvents mnuEditFind As System.Windows.Forms.MenuItem
  Friend WithEvents mnuEditFindNext As MenuItem
  Friend WithEvents mnuEditBar1 As MenuItem
  Friend WithEvents mnuEditSelectAll As MenuItem
  Friend WithEvents mnuHelp As MenuItem
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
  Friend WithEvents cmdCancel As System.Windows.Forms.Button
  Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(frmEditScript))
        Me.Panel2 = New System.Windows.Forms.Panel
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.cmdOK = New System.Windows.Forms.Button
        Me.Panel1 = New System.Windows.Forms.Panel
        Me.rtfscript = New ScintillaNet.Scintilla
        Me.mnuMain = New System.Windows.Forms.MainMenu(Me.components)
        Me.mnuFile = New System.Windows.Forms.MenuItem
        Me.mnuFileSave = New System.Windows.Forms.MenuItem
        Me.mnuFileSaveReload = New System.Windows.Forms.MenuItem
        Me.mnuFileBar1 = New System.Windows.Forms.MenuItem
        Me.mnuFileExit = New System.Windows.Forms.MenuItem
        Me.mnuEdit = New System.Windows.Forms.MenuItem
        Me.mnuEditUndo = New System.Windows.Forms.MenuItem
        Me.mnuEditBar2 = New System.Windows.Forms.MenuItem
        Me.mnuEditCut = New System.Windows.Forms.MenuItem
        Me.mnuEditCopy = New System.Windows.Forms.MenuItem
        Me.mnuEditPaste = New System.Windows.Forms.MenuItem
        Me.mnuEditDelete = New System.Windows.Forms.MenuItem
        Me.mnuEditBar3 = New System.Windows.Forms.MenuItem
        Me.mnuEditFind = New System.Windows.Forms.MenuItem
        Me.mnuEditFindNext = New System.Windows.Forms.MenuItem
        Me.mnuEditBar1 = New System.Windows.Forms.MenuItem
        Me.mnuEditSelectAll = New System.Windows.Forms.MenuItem
        Me.mnuHelp = New System.Windows.Forms.MenuItem
        Me.Panel2.SuspendLayout()
        Me.Panel1.SuspendLayout()
        CType(Me.rtfscript, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'Panel2
        '
        Me.Panel2.Controls.Add(Me.cmdCancel)
        Me.Panel2.Controls.Add(Me.cmdOK)
        Me.Panel2.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel2.Location = New System.Drawing.Point(0, 453)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(744, 40)
        Me.Panel2.TabIndex = 4
        '
        'cmdCancel
        '
        Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdCancel.Location = New System.Drawing.Point(664, 8)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.Size = New System.Drawing.Size(75, 23)
        Me.cmdCancel.TabIndex = 2
        Me.cmdCancel.Text = "Cancel"
        '
        'cmdOK
        '
        Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdOK.Location = New System.Drawing.Point(576, 8)
        Me.cmdOK.Name = "cmdOK"
        Me.cmdOK.Size = New System.Drawing.Size(75, 23)
        Me.cmdOK.TabIndex = 1
        Me.cmdOK.Text = "OK"
        '
        'Panel1
        '
        Me.Panel1.Controls.Add(Me.rtfscript)
        Me.Panel1.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel1.Location = New System.Drawing.Point(0, 0)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(744, 453)
        Me.Panel1.TabIndex = 5
        '
        'rtfscript
        '
        Me.rtfscript.Dock = System.Windows.Forms.DockStyle.Fill
        Me.rtfscript.Location = New System.Drawing.Point(0, 0)
        Me.rtfscript.Name = "rtfscript"
        Me.rtfscript.Size = New System.Drawing.Size(744, 453)
        Me.rtfscript.TabIndex = 1
        '
        'mnuMain
        '
        Me.mnuMain.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFile, Me.mnuEdit, Me.mnuHelp})
        '
        'mnuFile
        '
        Me.mnuFile.Index = 0
        Me.mnuFile.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFileSave, Me.mnuFileSaveReload, Me.mnuFileBar1, Me.mnuFileExit})
        Me.mnuFile.Text = "&File"
        '
        'mnuFileSave
        '
        Me.mnuFileSave.Index = 0
        Me.mnuFileSave.Text = "&Save"
        '
        'mnuFileSaveReload
        '
        Me.mnuFileSaveReload.Index = 1
        Me.mnuFileSaveReload.Shortcut = System.Windows.Forms.Shortcut.F11
        Me.mnuFileSaveReload.Text = "Save and Reload"
        '
        'mnuFileBar1
        '
        Me.mnuFileBar1.Index = 2
        Me.mnuFileBar1.Text = "-"
        '
        'mnuFileExit
        '
        Me.mnuFileExit.Index = 3
        Me.mnuFileExit.Text = "E&xit"
        '
        'mnuEdit
        '
        Me.mnuEdit.Index = 1
        Me.mnuEdit.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuEditUndo, Me.mnuEditBar2, Me.mnuEditCut, Me.mnuEditCopy, Me.mnuEditPaste, Me.mnuEditDelete, Me.mnuEditBar3, Me.mnuEditFind, Me.mnuEditFindNext, Me.mnuEditBar1, Me.mnuEditSelectAll})
        Me.mnuEdit.Text = "&Edit"
        '
        'mnuEditUndo
        '
        Me.mnuEditUndo.Index = 0
        Me.mnuEditUndo.Text = "Undo"
        '
        'mnuEditBar2
        '
        Me.mnuEditBar2.Index = 1
        Me.mnuEditBar2.Text = "-"
        '
        'mnuEditCut
        '
        Me.mnuEditCut.Index = 2
        Me.mnuEditCut.Shortcut = System.Windows.Forms.Shortcut.CtrlX
        Me.mnuEditCut.Text = "Cut"
        '
        'mnuEditCopy
        '
        Me.mnuEditCopy.Index = 3
        Me.mnuEditCopy.Shortcut = System.Windows.Forms.Shortcut.CtrlC
        Me.mnuEditCopy.Text = "Copy"
        '
        'mnuEditPaste
        '
        Me.mnuEditPaste.Index = 4
        Me.mnuEditPaste.Shortcut = System.Windows.Forms.Shortcut.CtrlV
        Me.mnuEditPaste.Text = "Paste"
        '
        'mnuEditDelete
        '
        Me.mnuEditDelete.Index = 5
        Me.mnuEditDelete.Text = "Delete"
        '
        'mnuEditBar3
        '
        Me.mnuEditBar3.Index = 6
        Me.mnuEditBar3.Text = "-"
        '
        'mnuEditFind
        '
        Me.mnuEditFind.Index = 7
        Me.mnuEditFind.Shortcut = System.Windows.Forms.Shortcut.CtrlF
        Me.mnuEditFind.Text = "&Find"
        '
        'mnuEditFindNext
        '
        Me.mnuEditFindNext.Index = 8
        Me.mnuEditFindNext.Shortcut = System.Windows.Forms.Shortcut.F3
        Me.mnuEditFindNext.Text = "Find Next"
        '
        'mnuEditBar1
        '
        Me.mnuEditBar1.Index = 9
        Me.mnuEditBar1.Text = "-"
        '
        'mnuEditSelectAll
        '
        Me.mnuEditSelectAll.Index = 10
        Me.mnuEditSelectAll.Shortcut = System.Windows.Forms.Shortcut.CtrlA
        Me.mnuEditSelectAll.Text = "Select &All"
        '
        'mnuHelp
        '
        Me.mnuHelp.Index = 2
        Me.mnuHelp.Text = "&Help"
        '
        'frmEditScript
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.CancelButton = Me.cmdCancel
        Me.ClientSize = New System.Drawing.Size(744, 493)
        Me.Controls.Add(Me.Panel1)
        Me.Controls.Add(Me.Panel2)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Menu = Me.mnuMain
        Me.Name = "frmEditScript"
        Me.Text = "frmEditScript"
        Me.Panel2.ResumeLayout(False)
        Me.Panel1.ResumeLayout(False)
        CType(Me.rtfscript, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub frmEditScript_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        GetFormSettings(Me, 750, 540)
        rtfscript.Scrolling.HorizontalWidth = Me.Width - 50
        If InStr(ScriptName, ".py") <> 0 Then
            rtfscript.ConfigurationManager.Language = "python"
            'If rtfscript.TextLength = 0 Then rtfscript.Text = "#xpl python script,NewPythonScript,false,"
        ElseIf InStr(ScriptName, ".ps1") <> 0 Then
            rtfscript.ConfigurationManager.Language = "batch"
            'If rtfscript.TextLength = 0 Then rtfscript.Text = "#xpl powershell script,NewPowershellScript,false,"
        End If
        InitResources()
        FirstActivate = True
        IsDirty = False
        SetLanguageOptions()
    End Sub

    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

    Private Sub SaveScript()
        Dim str As String
        If IsNewScript Or sName = "" Then ' New script - need to ask user what they want to call it
            sName = InputBox("Please enter a name for the new script:", "Save Script", ScriptName)
            If sName = "" Then Exit Sub

            ' If no extension, add one
            If sName.IndexOf(".") < 0 Then
                If Not globals.DefaultScriptingEngine Is Nothing Then
                    sName &= "." & globals.DefaultScriptingEngine.Extension
                Else
                    sName &= ".xpl"
                End If
            End If
        End If
        sName = sName.Replace(" ", "_")
        ConnectToXplHal()
        xplHalSend("PUTSCRIPT " & sName & vbCrLf)
        str = GetLine()
        If str.StartsWith("311") Then
            xplHalSend(rtfScript.Text.Trim & vbCrLf)
            xplHalSend("." & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("211") And Not str.StartsWith("242") Then
                globals.Unexpected(str)
            Else
                If str.StartsWith("242") Then
                    ' Read the response
                    str = GetLine()
                    While Not str.StartsWith(".")
                        str = GetLine()
                    End While
                    MsgBox(str)
                End If
                If IsDirty Then
                    globals.NeedToReloadScripts = True
                End If
                IsDirty = False
            End If
        End If
        Disconnect()
    End Sub

    Private Sub cmdOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        SaveScript()
        Me.Close()
    End Sub

    Private Sub rtfScript_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rtfscript.TextChanged
        IsDirty = True
    End Sub

    Private Sub frmEditScript_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Activated
        If FirstActivate Then
            FirstActivate = False
            rtfscript.Focus()
            rtfscript.Selection.Length = 0
            IsDirty = False
        End If
    End Sub

    Private Sub frmEditScript_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
        SetFormSettings(Me)
        If IsDirty Then
            If MsgBox(My.Resources.RES_SAVE_CHANGES.Replace("%1", sName), vbQuestion Or vbYesNo) = vbYes Then
                SaveScript()
            End If
        End If
    End Sub

    Private Sub mnuEditFind_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditFind.Click
        rtfscript.FindReplace.ShowFind()
    End Sub

    Private Sub mnuFileExit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileExit.Click
        Me.Close()
    End Sub

    Private Sub mnuEditSelectAll_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditSelectAll.Click
        rtfscript.Selection.Start = 0
        rtfscript.Selection.Length = rtfscript.Text.Length
    End Sub

    Private Sub mnuFileSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileSave.Click
        SaveScript()
    End Sub

    Private Sub mnuEditCut_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditCut.Click
        rtfscript.Clipboard.Cut()
    End Sub

    Private Sub mnuEditCopy_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditCopy.Click
        rtfscript.Clipboard.Copy()
    End Sub

    Private Sub mnuEditDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditDelete.Click
        rtfscript.Selection.Clear()
    End Sub

    Private Sub mnuEdit_Popup(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEdit.Popup
        If rtfscript.Selection.Length = 0 Then
            mnuEditCut.Enabled = False
            mnuEditCopy.Enabled = False
            mnuEditDelete.Enabled = False
        Else
            mnuEditCut.Enabled = True
            mnuEditCopy.Enabled = True
        End If
    End Sub

    Private Sub mnuEditPaste_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditPaste.Click
        rtfscript.Clipboard.Paste()
    End Sub


    Private Sub InitResources()
        mnuFile.Text = My.Resources.RES_FILE
        mnuFileSave.Text = My.Resources.RES_SAVE
        mnuFileSaveReload.Text = My.Resources.RES_SAVE_RELOAD
        mnuFileExit.Text = My.Resources.RES_EXIT
        mnuEditCut.Text = My.Resources.RES_CUT
        mnuEditCopy.Text = My.Resources.RES_COPY
        mnuEditPaste.Text = My.Resources.RES_PASTE
    End Sub

    Private Sub mnuFileSaveReload_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileSaveReload.Click
        mnuFileSave_Click(Nothing, Nothing)
        ReloadScripts()
    End Sub

  Private Sub SetLanguageOptions()
    ' Add help items
    mnuHelp.Visible = False
    If Not globals.ScriptingEngines Is Nothing Then
      For Counter As Integer = 0 To globals.ScriptingEngines.Length - 1
        Dim M As New MenuItem
        M.Text = globals.ScriptingEngines(Counter).Name & " help"
        M.Index = Counter
        AddHandler M.Click, AddressOf ShowHelp
        mnuHelp.MenuItems.Add(M)
      Next
    End If
    If mnuHelp.MenuItems.Count > 0 Then
      mnuHelp.Visible = True
    End If
  End Sub

  Private Sub ShowHelp(ByVal sender As Object, ByVal e As EventArgs)    
    Dim M As MenuItem = CType(sender, MenuItem)
    Dim Url As String = globals.ScriptingEngines(M.Index).Url    
    ShellExecute(0, "Open", Url, "", "", 0)
  End Sub


End Class
