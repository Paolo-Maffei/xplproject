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

Imports xpllib
Imports xpllib.XplMsg
Imports xPLHalMgr.xplhalMgrBase.DeterminatorRule.DeterminatorCondition.xplCondition

Public Class frmMonitor
    Inherits xplhalMgrBase

    Private WithEvents Timer1 As System.Timers.Timer
    Private TimerCount As Integer
    Private MessageCount As Integer
    Private TimeStarted As Date
    Private xPLServer As String

    Delegate Sub SetLVWCallback(ByVal [text] As ListViewItem)

    Private WithEvents xplNetwork As New XplListener("xpl", "monitor")

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
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents lvwMonitor As System.Windows.Forms.ListView
    Friend WithEvents Panel3 As System.Windows.Forms.Panel
    Friend WithEvents Panel4 As System.Windows.Forms.Panel
    Friend WithEvents txtDescription As System.Windows.Forms.TextBox
    Friend WithEvents cmdStop As System.Windows.Forms.Button
    Friend WithEvents cmdExit As System.Windows.Forms.Button
    Friend WithEvents cmdStart As System.Windows.Forms.Button
    Friend WithEvents Splitter2 As System.Windows.Forms.Splitter
    Friend WithEvents chkEnableFilter As System.Windows.Forms.CheckBox
    Friend WithEvents cmdClear As System.Windows.Forms.Button
    Friend WithEvents cmdRefresh As System.Windows.Forms.Button
    Friend WithEvents grpFilter As System.Windows.Forms.GroupBox
    Friend WithEvents cmdSelectAll As System.Windows.Forms.Button
    Friend WithEvents cmdStats As System.Windows.Forms.Button
    Friend WithEvents cmdSave As System.Windows.Forms.Button
    Friend WithEvents ImageList1 As System.Windows.Forms.ImageList
    Friend WithEvents tabDevices As System.Windows.Forms.TabPage
    Friend WithEvents tabType As System.Windows.Forms.TabPage
    Friend WithEvents lstSchemata As System.Windows.Forms.CheckedListBox
    Friend WithEvents lstType As System.Windows.Forms.CheckedListBox
    Friend WithEvents cmdNone As System.Windows.Forms.Button
    Friend WithEvents lstSource As System.Windows.Forms.CheckedListBox
    Friend WithEvents tabSchema As System.Windows.Forms.TabPage
    Friend WithEvents HelpProvider1 As System.Windows.Forms.HelpProvider
    Friend WithEvents tabFilter As System.Windows.Forms.TabControl
    Friend WithEvents lblFilterOptions As System.Windows.Forms.Label
    Friend WithEvents lblXPL As System.Windows.Forms.Label
    Friend WithEvents ctxMonitor As System.Windows.Forms.ContextMenu
    Friend WithEvents mnuCreateDeterminator As System.Windows.Forms.MenuItem
    Friend WithEvents mnuPopulateGlowBall As System.Windows.Forms.MenuItem
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmMonitor))
        Me.Panel2 = New System.Windows.Forms.Panel
        Me.tabFilter = New System.Windows.Forms.TabControl
        Me.tabDevices = New System.Windows.Forms.TabPage
        Me.lstSource = New System.Windows.Forms.CheckedListBox
        Me.tabSchema = New System.Windows.Forms.TabPage
        Me.lstSchemata = New System.Windows.Forms.CheckedListBox
        Me.tabType = New System.Windows.Forms.TabPage
        Me.lstType = New System.Windows.Forms.CheckedListBox
        Me.Panel3 = New System.Windows.Forms.Panel
        Me.cmdSave = New System.Windows.Forms.Button
        Me.cmdStats = New System.Windows.Forms.Button
        Me.grpFilter = New System.Windows.Forms.GroupBox
        Me.cmdNone = New System.Windows.Forms.Button
        Me.cmdSelectAll = New System.Windows.Forms.Button
        Me.cmdRefresh = New System.Windows.Forms.Button
        Me.chkEnableFilter = New System.Windows.Forms.CheckBox
        Me.cmdClear = New System.Windows.Forms.Button
        Me.cmdExit = New System.Windows.Forms.Button
        Me.cmdStop = New System.Windows.Forms.Button
        Me.cmdStart = New System.Windows.Forms.Button
        Me.lblFilterOptions = New System.Windows.Forms.Label
        Me.lvwMonitor = New System.Windows.Forms.ListView
        Me.ctxMonitor = New System.Windows.Forms.ContextMenu
        Me.mnuCreateDeterminator = New System.Windows.Forms.MenuItem
        Me.mnuPopulateGlowBall = New System.Windows.Forms.MenuItem
        Me.ImageList1 = New System.Windows.Forms.ImageList(Me.components)
        Me.Panel4 = New System.Windows.Forms.Panel
        Me.Splitter2 = New System.Windows.Forms.Splitter
        Me.lblXPL = New System.Windows.Forms.Label
        Me.txtDescription = New System.Windows.Forms.TextBox
        Me.HelpProvider1 = New System.Windows.Forms.HelpProvider
        Me.Panel2.SuspendLayout()
        Me.tabFilter.SuspendLayout()
        Me.tabDevices.SuspendLayout()
        Me.tabSchema.SuspendLayout()
        Me.tabType.SuspendLayout()
        Me.Panel3.SuspendLayout()
        Me.grpFilter.SuspendLayout()
        Me.Panel4.SuspendLayout()
        Me.SuspendLayout()
        '
        'Panel2
        '
        Me.Panel2.Controls.Add(Me.tabFilter)
        Me.Panel2.Controls.Add(Me.Panel3)
        Me.Panel2.Controls.Add(Me.lblFilterOptions)
        Me.Panel2.Dock = System.Windows.Forms.DockStyle.Right
        Me.Panel2.Location = New System.Drawing.Point(584, 0)
        Me.Panel2.Name = "Panel2"
        Me.Panel2.Size = New System.Drawing.Size(208, 513)
        Me.Panel2.TabIndex = 0
        '
        'tabFilter
        '
        Me.tabFilter.Controls.Add(Me.tabDevices)
        Me.tabFilter.Controls.Add(Me.tabSchema)
        Me.tabFilter.Controls.Add(Me.tabType)
        Me.tabFilter.Dock = System.Windows.Forms.DockStyle.Fill
        Me.tabFilter.Location = New System.Drawing.Point(0, 16)
        Me.tabFilter.Name = "tabFilter"
        Me.tabFilter.SelectedIndex = 0
        Me.tabFilter.Size = New System.Drawing.Size(208, 337)
        Me.tabFilter.TabIndex = 3
        '
        'tabDevices
        '
        Me.tabDevices.Controls.Add(Me.lstSource)
        Me.tabDevices.Location = New System.Drawing.Point(4, 22)
        Me.tabDevices.Name = "tabDevices"
        Me.tabDevices.Size = New System.Drawing.Size(200, 311)
        Me.tabDevices.TabIndex = 0
        Me.tabDevices.Text = "Source"
        '
        'lstSource
        '
        Me.lstSource.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstSource.CheckOnClick = True
        Me.lstSource.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lstSource.IntegralHeight = False
        Me.lstSource.Location = New System.Drawing.Point(0, 0)
        Me.lstSource.Name = "lstSource"
        Me.lstSource.Size = New System.Drawing.Size(200, 311)
        Me.lstSource.Sorted = True
        Me.lstSource.TabIndex = 0
        '
        'tabSchema
        '
        Me.tabSchema.Controls.Add(Me.lstSchemata)
        Me.tabSchema.Location = New System.Drawing.Point(4, 22)
        Me.tabSchema.Name = "tabSchema"
        Me.tabSchema.Size = New System.Drawing.Size(200, 311)
        Me.tabSchema.TabIndex = 1
        Me.tabSchema.Text = "Schema"
        '
        'lstSchemata
        '
        Me.lstSchemata.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstSchemata.CheckOnClick = True
        Me.lstSchemata.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lstSchemata.IntegralHeight = False
        Me.lstSchemata.Location = New System.Drawing.Point(0, 0)
        Me.lstSchemata.Name = "lstSchemata"
        Me.lstSchemata.Size = New System.Drawing.Size(200, 311)
        Me.lstSchemata.Sorted = True
        Me.lstSchemata.TabIndex = 1
        '
        'tabType
        '
        Me.tabType.Controls.Add(Me.lstType)
        Me.tabType.Location = New System.Drawing.Point(4, 22)
        Me.tabType.Name = "tabType"
        Me.tabType.Size = New System.Drawing.Size(200, 311)
        Me.tabType.TabIndex = 2
        Me.tabType.Text = "Type"
        '
        'lstType
        '
        Me.lstType.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lstType.CheckOnClick = True
        Me.lstType.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lstType.IntegralHeight = False
        Me.lstType.Location = New System.Drawing.Point(0, 0)
        Me.lstType.Name = "lstType"
        Me.lstType.Size = New System.Drawing.Size(200, 311)
        Me.lstType.Sorted = True
        Me.lstType.TabIndex = 1
        '
        'Panel3
        '
        Me.Panel3.Controls.Add(Me.cmdSave)
        Me.Panel3.Controls.Add(Me.cmdStats)
        Me.Panel3.Controls.Add(Me.grpFilter)
        Me.Panel3.Controls.Add(Me.cmdClear)
        Me.Panel3.Controls.Add(Me.cmdExit)
        Me.Panel3.Controls.Add(Me.cmdStop)
        Me.Panel3.Controls.Add(Me.cmdStart)
        Me.Panel3.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Panel3.Location = New System.Drawing.Point(0, 353)
        Me.Panel3.Name = "Panel3"
        Me.Panel3.Size = New System.Drawing.Size(208, 160)
        Me.Panel3.TabIndex = 2
        '
        'cmdSave
        '
        Me.cmdSave.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdSave.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdSave.Location = New System.Drawing.Point(136, 112)
        Me.cmdSave.Name = "cmdSave"
        Me.cmdSave.Size = New System.Drawing.Size(64, 20)
        Me.cmdSave.TabIndex = 6
        Me.cmdSave.Text = "Sa&ve"
        '
        'cmdStats
        '
        Me.cmdStats.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdStats.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdStats.Location = New System.Drawing.Point(136, 88)
        Me.cmdStats.Name = "cmdStats"
        Me.cmdStats.Size = New System.Drawing.Size(64, 20)
        Me.cmdStats.TabIndex = 5
        Me.cmdStats.Text = "S&tats"
        '
        'grpFilter
        '
        Me.grpFilter.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.grpFilter.Controls.Add(Me.cmdNone)
        Me.grpFilter.Controls.Add(Me.cmdSelectAll)
        Me.grpFilter.Controls.Add(Me.cmdRefresh)
        Me.grpFilter.Controls.Add(Me.chkEnableFilter)
        Me.grpFilter.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.grpFilter.Location = New System.Drawing.Point(0, 0)
        Me.grpFilter.Name = "grpFilter"
        Me.grpFilter.Size = New System.Drawing.Size(208, 80)
        Me.grpFilter.TabIndex = 0
        Me.grpFilter.TabStop = False
        Me.grpFilter.Text = "Filter"
        '
        'cmdNone
        '
        Me.cmdNone.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdNone.Location = New System.Drawing.Point(152, 48)
        Me.cmdNone.Name = "cmdNone"
        Me.cmdNone.Size = New System.Drawing.Size(48, 23)
        Me.cmdNone.TabIndex = 4
        Me.cmdNone.Text = "&None"
        '
        'cmdSelectAll
        '
        Me.cmdSelectAll.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdSelectAll.Location = New System.Drawing.Point(152, 16)
        Me.cmdSelectAll.Name = "cmdSelectAll"
        Me.cmdSelectAll.Size = New System.Drawing.Size(48, 23)
        Me.cmdSelectAll.TabIndex = 2
        Me.cmdSelectAll.Text = "&All"
        '
        'cmdRefresh
        '
        Me.cmdRefresh.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdRefresh.Location = New System.Drawing.Point(16, 48)
        Me.cmdRefresh.Name = "cmdRefresh"
        Me.cmdRefresh.Size = New System.Drawing.Size(88, 23)
        Me.cmdRefresh.TabIndex = 3
        Me.cmdRefresh.Text = "&Refresh"
        '
        'chkEnableFilter
        '
        Me.chkEnableFilter.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.chkEnableFilter.Location = New System.Drawing.Point(16, 24)
        Me.chkEnableFilter.Name = "chkEnableFilter"
        Me.chkEnableFilter.Size = New System.Drawing.Size(120, 16)
        Me.chkEnableFilter.TabIndex = 0
        Me.chkEnableFilter.Text = "&Enable filter"
        '
        'cmdClear
        '
        Me.cmdClear.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdClear.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdClear.Location = New System.Drawing.Point(16, 136)
        Me.cmdClear.Name = "cmdClear"
        Me.cmdClear.Size = New System.Drawing.Size(64, 20)
        Me.cmdClear.TabIndex = 3
        Me.cmdClear.Text = "&Clear"
        '
        'cmdExit
        '
        Me.cmdExit.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdExit.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdExit.Location = New System.Drawing.Point(136, 136)
        Me.cmdExit.Name = "cmdExit"
        Me.cmdExit.Size = New System.Drawing.Size(64, 20)
        Me.cmdExit.TabIndex = 4
        Me.cmdExit.Text = "E&xit"
        '
        'cmdStop
        '
        Me.cmdStop.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdStop.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdStop.Location = New System.Drawing.Point(16, 112)
        Me.cmdStop.Name = "cmdStop"
        Me.cmdStop.Size = New System.Drawing.Size(64, 20)
        Me.cmdStop.TabIndex = 2
        Me.cmdStop.Text = "Sto&p"
        '
        'cmdStart
        '
        Me.cmdStart.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdStart.Enabled = False
        Me.cmdStart.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.cmdStart.Location = New System.Drawing.Point(16, 88)
        Me.cmdStart.Name = "cmdStart"
        Me.cmdStart.Size = New System.Drawing.Size(64, 20)
        Me.cmdStart.TabIndex = 1
        Me.cmdStart.Text = "&Start"
        '
        'lblFilterOptions
        '
        Me.lblFilterOptions.Dock = System.Windows.Forms.DockStyle.Top
        Me.lblFilterOptions.Location = New System.Drawing.Point(0, 0)
        Me.lblFilterOptions.Name = "lblFilterOptions"
        Me.lblFilterOptions.Size = New System.Drawing.Size(208, 16)
        Me.lblFilterOptions.TabIndex = 2
        Me.lblFilterOptions.Text = "Filter Options"
        '
        'lvwMonitor
        '
        Me.lvwMonitor.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.lvwMonitor.ContextMenu = Me.ctxMonitor
        Me.lvwMonitor.Dock = System.Windows.Forms.DockStyle.Fill
        Me.lvwMonitor.FullRowSelect = True
        Me.lvwMonitor.HideSelection = False
        Me.lvwMonitor.Location = New System.Drawing.Point(0, 16)
        Me.lvwMonitor.MultiSelect = False
        Me.lvwMonitor.Name = "lvwMonitor"
        Me.lvwMonitor.Size = New System.Drawing.Size(584, 340)
        Me.lvwMonitor.SmallImageList = Me.ImageList1
        Me.lvwMonitor.TabIndex = 0
        Me.lvwMonitor.View = System.Windows.Forms.View.Details
        '
        'ctxMonitor
        '
        Me.ctxMonitor.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuCreateDeterminator, Me.mnuPopulateGlowBall})
        '
        'mnuCreateDeterminator
        '
        Me.mnuCreateDeterminator.Index = 0
        Me.mnuCreateDeterminator.Text = "Create Determinator"
        '
        'mnuPopulateGlowBall
        '
        Me.mnuPopulateGlowBall.Index = 1
        Me.mnuPopulateGlowBall.Text = "Populate Global Variable"
        '
        'ImageList1
        '
        Me.ImageList1.ImageSize = New System.Drawing.Size(16, 16)
        Me.ImageList1.ImageStream = CType(resources.GetObject("ImageList1.ImageStream"), System.Windows.Forms.ImageListStreamer)
        Me.ImageList1.TransparentColor = System.Drawing.Color.Transparent
        '
        'Panel4
        '
        Me.Panel4.Controls.Add(Me.lvwMonitor)
        Me.Panel4.Controls.Add(Me.Splitter2)
        Me.Panel4.Controls.Add(Me.lblXPL)
        Me.Panel4.Controls.Add(Me.txtDescription)
        Me.Panel4.Dock = System.Windows.Forms.DockStyle.Fill
        Me.Panel4.Location = New System.Drawing.Point(0, 0)
        Me.Panel4.Name = "Panel4"
        Me.Panel4.Size = New System.Drawing.Size(584, 513)
        Me.Panel4.TabIndex = 6
        '
        'Splitter2
        '
        Me.Splitter2.BackColor = System.Drawing.SystemColors.Control
        Me.Splitter2.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.Splitter2.Location = New System.Drawing.Point(0, 356)
        Me.Splitter2.MinExtra = 256
        Me.Splitter2.MinSize = 48
        Me.Splitter2.Name = "Splitter2"
        Me.Splitter2.Size = New System.Drawing.Size(584, 5)
        Me.Splitter2.TabIndex = 8
        Me.Splitter2.TabStop = False
        '
        'lblXPL
        '
        Me.lblXPL.Dock = System.Windows.Forms.DockStyle.Top
        Me.lblXPL.FlatStyle = System.Windows.Forms.FlatStyle.System
        Me.lblXPL.Location = New System.Drawing.Point(0, 0)
        Me.lblXPL.Name = "lblXPL"
        Me.lblXPL.Size = New System.Drawing.Size(584, 16)
        Me.lblXPL.TabIndex = 2
        Me.lblXPL.Text = "xPL Messages Received"
        '
        'txtDescription
        '
        Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.txtDescription.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.txtDescription.Location = New System.Drawing.Point(0, 361)
        Me.txtDescription.Multiline = True
        Me.txtDescription.Name = "txtDescription"
        Me.txtDescription.ReadOnly = True
        Me.txtDescription.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtDescription.Size = New System.Drawing.Size(584, 152)
        Me.txtDescription.TabIndex = 1
        Me.txtDescription.Text = ""
        '
        'HelpProvider1
        '
        Me.HelpProvider1.HelpNamespace = "xplhal.chm"
        '
        'frmMonitor
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.CancelButton = Me.cmdExit
        Me.ClientSize = New System.Drawing.Size(792, 513)
        Me.Controls.Add(Me.Panel4)
        Me.Controls.Add(Me.Panel2)
        Me.HelpProvider1.SetHelpKeyword(Me, "\monitor\intro.htm")
        Me.HelpProvider1.SetHelpNavigator(Me, System.Windows.Forms.HelpNavigator.Topic)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "frmMonitor"
        Me.HelpProvider1.SetShowHelp(Me, True)
        Me.Text = "xPL Monitor"
        Me.Panel2.ResumeLayout(False)
        Me.tabFilter.ResumeLayout(False)
        Me.tabDevices.ResumeLayout(False)
        Me.tabSchema.ResumeLayout(False)
        Me.tabType.ResumeLayout(False)
        Me.Panel3.ResumeLayout(False)
        Me.grpFilter.ResumeLayout(False)
        Me.Panel4.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region

    Private Sub cmdClear_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdClear.Click
        lvwMonitor.Items.Clear()
        MessageCount = 0
        TimeStarted = Now
    End Sub

    Private Sub cmdExit_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdExit.Click
        Me.Close()
    End Sub

    Private Sub cmdSelectAll_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectAll.Click
        TickLists(True)
    End Sub

    Private Sub cmdNone_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdNone.Click
        TickLists(False)
    End Sub

    Private Sub TickLists(ByVal b As Boolean)
        If lstSource.Items.Count > 0 Then
            For I As Integer = 0 To lstSource.Items.Count - 1
                lstSource.SetItemChecked(I, b)
            Next
        End If
        If lstSchemata.Items.Count > 0 Then
            For I As Integer = 0 To lstSchemata.Items.Count - 1
                lstSchemata.SetItemChecked(I, b)
            Next
        End If
        If lstType.Items.Count > 0 Then
            For I As Integer = 0 To lstType.Items.Count - 1
                lstType.SetItemChecked(I, b)
            Next
        End If
    End Sub

    Class ListViewItemComparer
        Implements IComparer
        Private col As Integer, Order As SortOrder
        Public Sub New()
            col = 0
            Order = SortOrder.Ascending
        End Sub
        Public Sub New(ByVal column As Integer, ByVal n As SortOrder)
            col = column
            Order = n
        End Sub
        Public Function Compare(ByVal x As Object, ByVal y As Object) As Integer Implements IComparer.Compare
            Dim ReturnVal As Integer
            If IsNumeric(CType(x, ListViewItem).SubItems(col).Text) Then
                If CSng(CType(x, ListViewItem).SubItems(col).Text) > CSng(CType(y, ListViewItem).SubItems(col).Text) Then
                    ReturnVal = 1
                End If
                If CSng(CType(x, ListViewItem).SubItems(col).Text) < CSng(CType(y, ListViewItem).SubItems(col).Text) Then
                    ReturnVal = -1
                End If
                If CSng(CType(x, ListViewItem).SubItems(col).Text) = CSng(CType(y, ListViewItem).SubItems(col).Text) Then
                    ReturnVal = 0
                End If
            Else
                ReturnVal = [String].Compare(CType(x, ListViewItem).SubItems(col).Text, CType(y, ListViewItem).SubItems(col).Text)
            End If
            If Order = SortOrder.Descending Then
                ReturnVal *= -1
            End If
            Return ReturnVal
        End Function
    End Class

    Private Sub lvwMonitor_ColumnClick(ByVal sender As Object, ByVal e As System.Windows.Forms.ColumnClickEventArgs) Handles lvwMonitor.ColumnClick
        Static OldCol As Integer
        If OldCol = e.Column Then
            Select Case lvwMonitor.Sorting
                Case SortOrder.Ascending
                    lvwMonitor.Sorting = SortOrder.Descending
                Case SortOrder.Descending
                    lvwMonitor.Sorting = SortOrder.Ascending
                Case SortOrder.None
                    lvwMonitor.Sorting = SortOrder.Ascending
            End Select
        Else
            lvwMonitor.Sorting = SortOrder.Ascending
        End If
        OldCol = e.Column
        lvwMonitor.ListViewItemSorter = New ListViewItemComparer(e.Column, lvwMonitor.Sorting)
        lvwMonitor.Sort()
    End Sub

    Private Sub frmMonitor_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        GetFormSettings(Me, 752, 540)
        'If Screen.PrimaryScreen.WorkingArea.Width > 1023 Then
        '  Me.Width = 900
        'End If
        SetUpLVW()
        PopulateDevices()
        xplNetwork.InstanceName = Environment.MachineName.Replace("-", "")
        xplNetwork.Filters.AlwaysPassMessages = True

        cmdStart_Click(Nothing, Nothing)
        TimeStarted = Now
        lvwMonitor.Sorting = SortOrder.Descending
        lvwMonitor.ListViewItemSorter = New ListViewItemComparer(4, lvwMonitor.Sorting)
        lvwMonitor.Sort()

        cmdStart.Text = My.Resources.RES_START
        cmdStop.Text = My.Resources.RES_STOP
        cmdClear.Text = My.Resources.RES_CLEAR
        cmdStats.Text = My.Resources.RES_STATS
        cmdSelectAll.Text = My.Resources.RES_ALL
        cmdNone.Text = My.Resources.RES_NONE
        chkEnableFilter.Text = My.Resources.RES_ENABLE_FILTER
        grpFilter.Text = My.Resources.RES_FILTER
        tabSchema.Text = My.Resources.RES_SCHEMA
        tabType.Text = My.Resources.RES_TYPE
        tabDevices.Text = My.Resources.RES_SOURCE
        lblFilterOptions.Text = My.Resources.RES_FILTER_OPTIONS
        lblXPL.Text = My.Resources.RES_XPLMESSAGES_RECEIVED
        cmdRefresh.Text = My.Resources.RES_REFRESH
        cmdSave.Text = My.Resources.RES_SAVE
        cmdExit.Text = My.Resources.RES_EXIT
    End Sub

    Private Sub PopulateDevices()
        lstSource.SuspendLayout()
        Dim str As String, I As Integer, a As String
        lstSource.Items.Clear()
        lstSchemata.Items.Clear()
        lstType.Items.Clear()
        ConnectToXplHal()
        xplHalSend("LISTDEVICES CONFIGURED" & vbCrLf)
        str = GetLine()
        If str.StartsWith("216") Then
            str = GetLine()
            While Not str = ("." & vbCrLf) And Not str = ""
                str = str.Substring(0, str.IndexOf(vbTab))
                lstSource.Items.Add(str)
                str = GetLine()
            End While
        End If
        Disconnect()
        lstSource.ResumeLayout()

        lstType.Items.Clear()
        lstType.Items.Add("XPL-CMND")
        lstType.Items.Add("XPL-STAT")
        lstType.Items.Add("XPL-TRIG")

        lstSchemata.Items.Add("HBEAT")
        lstSchemata.Items.Add("CONFIG")
        If Not (globals.xplSchemaCollection Is Nothing) Then
            For I = 0 To globals.xplSchemaCollection.Length - 1
                a = UCase(globals.xplSchemaCollection(I).Name)
                a = a.Remove(a.IndexOf("."), a.Length - a.IndexOf("."))
                If lstSchemata.Items.Contains(a) Then
                Else
                    lstSchemata.Items.Add(a)
                End If
            Next
        Else
            MsgBox("The file 'xpl-schema-collection.xml' is missing." & vbCrLf & "Please update the plug-in library in the Help menu.")
        End If
    End Sub

    Private Sub SetUpLVW()
        lvwMonitor.Columns.Add(My.Resources.RES_TYPE, 60, HorizontalAlignment.Left)
        lvwMonitor.Columns.Add(My.Resources.RES_SOURCE, 150, HorizontalAlignment.Left)
        lvwMonitor.Columns.Add(My.Resources.RES_TARGET, 150, HorizontalAlignment.Left)
        lvwMonitor.Columns.Add(My.Resources.RES_SCHEMA, 120, HorizontalAlignment.Left)
        lvwMonitor.Columns.Add(My.Resources.RES_TIME, 100, HorizontalAlignment.Left)
        lvwMonitor.Columns.Add(My.Resources.RES_HOP, 50, HorizontalAlignment.Left)
        Dim cols() As Integer = {60, 150, 150, 120, 100, 50}
        GetlvwSettings(lvwMonitor, cols)
    End Sub

    Private Sub cmdRefresh_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRefresh.Click
        PopulateDevices()
    End Sub

    Private Sub ReceiveData(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles xplNetwork.XplMessageReceived

        If xplNetwork.JoinedxPLNetwork Then
            Try
                Dim Schema As String
                Dim CMD As String
                MessageCount += 1
                If e.XplMsg.IsMessageValid Then
                    Dim x As XplMsg = e.XplMsg
                    If WantMessage(e.XplMsg) Then
                        Dim li As New ListViewItem
                        CMD = x.XPL_Msg(0).Section
                        li.Text = CMD.Substring(4, 4)

                        li.SubItems.Add(x.GetParam(0, "source"))
                        li.SubItems.Add(x.GetParam(0, "target"))
                        Schema = x.XPL_Msg(1).Section
                        li.SubItems.Add(Schema)
                        li.SubItems.Add(Format(Now, "yy-MM-dd HH:mm:ss"))
                        li.SubItems.Add(x.GetParam(0, "Hop"))
                        Schema = Schema.Substring(0, Schema.IndexOf("."))
                        Select Case LCase(Schema)
                            Case "cid"
                                li.ImageIndex = 1
                            Case "config"
                                li.ImageIndex = 2
                            Case "dawndusk"
                                li.ImageIndex = 3
                            Case "hbeat"
                                li.ImageIndex = 4
                            Case "osd"
                                li.ImageIndex = 5
                            Case "sendmsg"
                                li.ImageIndex = 6
                            Case "webcam"
                                li.ImageIndex = 7
                            Case "x10"
                                li.ImageIndex = 8
                            Case "ups"
                                li.ImageIndex = 9
                            Case "datetime"
                                li.ImageIndex = 10
                            Case "audio"
                                li.ImageIndex = 11
                            Case "sensor"
                                li.ImageIndex = 12
                            Case "tts"
                                li.ImageIndex = 13

                            Case Else
                                li.ImageIndex = 0
                        End Select

                        '' We just want the body
                        'Str = Str.Substring(Str.IndexOf("}") + 1, Str.Length - Str.IndexOf("}") - 1)
                        'Str = Str.Substring(Str.IndexOf("{") + 2, Str.Length - Str.IndexOf("{") - 2)
                        'Str = Str.Substring(0, Str.IndexOf("}") - 1)
                        'Str = Str.Replace(vbLf, vbCrLf)

                        'MsgBox(str)
                        Dim messagebody As String = ""
                        For Each keypair As KeyValuePair In x.KeyValues
                            messagebody = messagebody & keypair.Key.ToString & "=" & keypair.Value.ToString & vbCrLf
                        Next
                        li.Tag = messagebody
                        AddTagtoListView(li)
                    End If
                End If

            Catch ex As Exception

            End Try
        End If
    End Sub

    Private Sub AddTagtoListView(ByVal [text] As ListViewItem)

        ' InvokeRequired required compares the thread ID of the
        ' calling thread to the thread ID of the creating thread.
        ' If these threads are different, it returns true.
        If Me.lvwMonitor.InvokeRequired Then
            Dim d As New SetLVWCallback(AddressOf AddTagtoListView)
            Me.Invoke(d, New Object() {[text]})
        Else
            lvwMonitor.Items.Add([text])
        End If
    End Sub


    Private Sub frmMonitor_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        If cmdStop.Enabled = True Then
            xplNetwork.Dispose()
        End If
    End Sub


    Private Function WantMessage(ByRef x As XplMsg) As Boolean
        'If chkIncludeHeartbeats.Checked = False Then
        '  If UCase(x.XPL_Msg(1).Section).StartsWith("HB") Then
        '    Return False
        '  End If
        'End If
        If chkEnableFilter.Checked Then
            Dim a As String
            ' source
            a = UCase(x.GetParam(0, "source"))
            If lstSource.CheckedItems.Contains(a) Then
                ' schema
                a = UCase(x.XPL_Msg(1).Section)
                a = a.Remove(a.IndexOf("."), a.Length - a.IndexOf("."))
                If lstSchemata.CheckedItems.Contains(a) Then
                    ' message type
                    a = UCase(x.XPL_Msg(0).Section)
                    If lstType.CheckedItems.Contains(a) Then
                        Return True
                    Else
                        Return False
                    End If
                End If
            End If
        Else
            Return True
        End If
    End Function

    Private Sub lvwMonitor_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lvwMonitor.SelectedIndexChanged
        If lvwMonitor.SelectedItems.Count > 0 Then
            txtDescription.Text = CStr(lvwMonitor.SelectedItems(0).Tag)
        End If
    End Sub

    Private Sub cmdStats_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdStats.Click
        ' lvwMonitor.Items.Count.ToString & "/" & MessageCount.ToString
        Dim a As Single
        txtDescription.Text = "Recieved: " & MessageCount.ToString & vbCrLf
        txtDescription.Text &= "Logged: " & lvwMonitor.Items.Count.ToString & vbCrLf
        a = DateDiff(DateInterval.Second, TimeStarted, Now)
        txtDescription.Text &= "Logging started: " & Format(TimeStarted, "d MMM yyyy HH:mm") & vbCrLf
        txtDescription.Text &= "Elapsed time: " & Format(a / 60, "######0.#") & " minutes" & vbCrLf
        txtDescription.Text &= "Received per minute: " & Format(MessageCount / a * 60, "#####0.#") & vbCrLf
    End Sub

    Private Sub cmdStop_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdStop.Click
        Try
            xplNetwork.Dispose()
        Catch
        End Try
        cmdStop.Enabled = False
        cmdStart.Enabled = True
    End Sub

    Private Sub cmdStart_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdStart.Click
        xplNetwork.Listen()
        cmdStop.Enabled = True
        cmdStart.Enabled = False
    End Sub

    Private Sub cmdSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSave.Click
        Dim SD As New SaveFileDialog, FileName As String, SDResult As DialogResult, str As String
        SD.DefaultExt = ".csv"
        SD.Filter = "csv files (*.csv)|*.csv"
        SD.FilterIndex = 0
        SD.Title = "Save log file"
        SDResult = SD.ShowDialog()
        If SD.FileName <> "" Then
            FileName = SD.FileName
            Dim FileNumber As Integer
            FileNumber = FreeFile()
            Try
                FileOpen(FileNumber, FileName, OpenMode.Output)
                WriteLine(FileNumber, "Message Type", "Source", "Target", "Schema", "Time", "Hop", "Data")

                For Each Li As ListViewItem In lvwMonitor.Items
                    str = Li.Tag.ToString
                    str = Replace(str, vbCrLf, ", ")
                    WriteLine(FileNumber, Li.Text, Li.SubItems(1).Text, Li.SubItems(2).Text, Li.SubItems(3).Text, Li.SubItems(4).Text, Li.SubItems(5).Text, str)
                Next
                FileClose(FileNumber)
            Catch ex As IOException
                If Err.Number = 75 Then
                    MsgBox("The file is locked by another application.")
                Else
                    MsgBox(ex.ToString)
                End If
            End Try
        End If
    End Sub


    Private Sub frmMonitor_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
        SetlvwSettings(lvwMonitor)
        SetFormSettings(Me)
    End Sub


    Private Sub mnuCreateDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuCreateDeterminator.Click
        If lvwMonitor.SelectedItems.Count = 1 Then
            Dim f As New frmDeterminatorWizard
            Dim myCondition As New DeterminatorRule.DeterminatorCondition
            Dim x As New DeterminatorRule.DeterminatorCondition.xplCondition
            Dim lvi As ListViewItem = lvwMonitor.SelectedItems(0)
            With x
                .msg_type = lvi.Text.ToLower
                .source_vendor = lvi.SubItems(1).Text
                .source_device = .source_vendor.Substring(0, .source_vendor.IndexOf("."))
                .source_device = .source_device.Substring(.source_device.IndexOf("-") + 1, .source_device.Length - .source_device.IndexOf("-") - 1)
                .source_instance = .source_vendor.Substring(.source_vendor.IndexOf(".") + 1, .source_vendor.Length - .source_vendor.IndexOf(".") - 1)
                .source_vendor = .source_vendor.Substring(0, .source_vendor.IndexOf("-"))
                If lvi.SubItems(2).Text = "*" Then
                    .target_vendor = "*"
                    .target_device = "*"
                    .target_instance = "*"
                End If
                .schema_class = lvi.SubItems(3).Text.ToLower
                .schema_type = .schema_class.Substring(.schema_class.IndexOf(".") + 1, .schema_class.Length - .schema_class.IndexOf(".") - 1)
                .schema_class = .schema_class.Substring(0, .schema_class.IndexOf("."))
                Dim lines() As String = CStr(lvi.Tag).Split(CChar(vbLf))
                For Each entry As String In lines
                    Dim paramparts() As String = Split(entry, "=")
                    If paramparts.Length >= 2 Then
                        Dim newparams As New xplConditionParams
                        newparams.Name = paramparts(0)
                        newparams.Operator = "="
                        newparams.Value = paramparts(1)
                        .params.Add(newparams)
                    End If
                Next
            End With
            With myCondition
                .ConditionType = xplhalMgrBase.DeterminatorRule.ConditionTypes.xPLMessage
                .Condition = x
                .DisplayName = x.schema_class & "." & x.schema_type & " message from " & x.source_vendor & "-" & x.source_device & "." & x.source_instance
            End With
            f.lstConditions.Items.Add(myCondition)
            f.Show()
        End If
    End Sub

    Private Sub mnuPopulateGlowBall_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuPopulateGlowBall.Click
        If Not lvwMonitor.SelectedItems.Count = 1 Then
            Exit Sub
        End If
        Dim d As New DeterminatorRule
        Dim eNames() As String, eValues() As String, lines() As String
        Dim lvi As ListViewItem = lvwMonitor.SelectedItems(0)
        lines = CStr(lvi.Tag).Split(CChar(vbLf))
        Dim lhs, rhs As String
        ReDim eNames(-1)
        ReDim eValues(-1)

        ' Ask the user to select the element
        Dim cs As New frmChangeStuff
        cs.Text = "Select Message Element"
        cs.lblStuff.Text = "Please select the message element that you want to store in the global."
        For Counter As Integer = 0 To lines.Length - 1
            lhs = lines(Counter).Substring(0, lines(Counter).IndexOf("="))
            rhs = lines(Counter).Substring(lhs.Length + 1, lines(Counter).Length - lhs.Length - 1).Trim
            ReDim Preserve eNames(eNames.Length)
            ReDim Preserve eValues(eValues.Length)
            eNames(eNames.Length - 1) = lhs
            eValues(eValues.Length - 1) = rhs
            cs.cmbStuffToChange.Items.Add(lhs)
        Next


        If Not cs.ShowDialog = Windows.Forms.DialogResult.OK Then
            Exit Sub
        End If
        Dim ElementToStore As String = cs.cmbStuffToChange.Text
        If ElementToStore = "" Then
            Exit Sub
        End If

        ' Ask for the global
        Dim globalName As String = InputBox("Enter the name of the global into which the value should be placed:", "Select Global Name", "")
        If globalName.Trim = "" Then
            Exit Sub
        End If

        ' Ask for a name for the determinator
        d.RuleName = InputBox("Enter a name to help you identify this determinator:", "Select Name", "")
        If d.RuleName.Trim = "" Then
            Exit Sub
        End If

        ' Configure the determinator
        Try
            d.Enabled = True
            d.RuleDescription = ""

            ReDim d.Conditions(0)
            d.Conditions(0) = New DeterminatorRule.DeterminatorCondition
            With d.Conditions(0)
                .DisplayName = "Capture message"
                .ConditionType = xplhalMgrBase.DeterminatorRule.ConditionTypes.xPLMessage
                Dim x As New DeterminatorRule.DeterminatorCondition.xplCondition
                With x
                    .msg_type = lvi.Text.ToLower
                    .source_vendor = lvi.SubItems(1).Text
                    .source_device = .source_vendor.Substring(0, .source_vendor.IndexOf("."))
                    .source_device = .source_device.Substring(.source_device.IndexOf("-") + 1, .source_device.Length - .source_device.IndexOf("-") - 1)
                    .source_instance = .source_vendor.Substring(.source_vendor.IndexOf(".") + 1, .source_vendor.Length - .source_vendor.IndexOf(".") - 1)
                    .source_vendor = .source_vendor.Substring(0, .source_vendor.IndexOf("-"))
                    If lvi.SubItems(2).Text = "*" Then
                        .target_vendor = "*"
                        .target_device = "*"
                        .target_instance = "*"
                    End If
                    .schema_class = lvi.SubItems(3).Text.ToLower
                    .schema_type = .schema_class.Substring(.schema_class.IndexOf(".") + 1, .schema_class.Length - .schema_class.IndexOf(".") - 1)
                    .schema_class = .schema_class.Substring(0, .schema_class.IndexOf("."))
                    For Each entry As String In eNames
                        Dim paramparts() As String = Split(entry, "=")
                        If Not paramparts(0) = ElementToStore Then
                            Dim newparams As New xplConditionParams
                            newparams.Name = paramparts(0)
                            newparams.Operator = "="
                            newparams.Value = paramparts(1)
                            .params.Add(newparams)
                        End If
                    Next
                End With
                .Condition = x
            End With


            ' Create the action
            ReDim d.Actions(0)
            d.Actions(0) = New DeterminatorRule.DeterminatorAction
            With d.Actions(0)
                .DisplayName = "Set the global"
                .ActionType = xplhalMgrBase.DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
                Dim a As New DeterminatorRule.DeterminatorAction.globalAction
                a.Name = globalName
                a.Value = "{XPL::" & ElementToStore.ToUpper & "}"
                .Action = a
            End With

            ' Send the new determinator to the xPLHal server
            Dim RuleText As String
            RuleText = d.Save()
            SetRule("", RuleText)
            MsgBox("A determinator has now been created that will populate the selected global variable when this message is received.", vbInformation)
        Catch ex As Exception
            MsgBox("Error creating the determinator: " & ex.Message, vbCritical)
        End Try
    End Sub

End Class
