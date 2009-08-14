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

Public Class frmMain
  Inherits xplhalMgrBase

  Private WithEvents Timer1 As System.Timers.Timer
  
  ' Variable to indicate whether form is receiving focus for the first time
  Private FirstActivation As Boolean


  ' The default treeview node that should
  ' be selected at startup
  Private DefaultNode As String


  Private Const DEFAULT_SCRIPT_NAME As String = "NewScript"
	Private AutoRefreshGlowBalls As Boolean = False

	Public Shared CurrentMode As String

	' Reference to the splash screen form
	Private SplashScreen As frmSplash

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
	Friend WithEvents MainMenu1 As System.Windows.Forms.MainMenu
  Friend WithEvents mnuCtxOpen As MenuItem
  Friend WithEvents mnuNewDeterminatorGroup As MenuItem
  Friend WithEvents mnuDeleteDeterminatorGroup As MenuItem
  Friend WithEvents mnuCtxPoll As MenuItem
	Friend WithEvents mnuFile As MenuItem
	Friend WithEvents mnuFileNew As MenuItem
  'Friend WithEvents mnuFileNewScript As MenuItem
	Friend WithEvents mnuFileNewEvent As MenuItem	
	Friend WithEvents mnuFileNewDeterminator As MenuItem
	Friend WithEvents mnuFileRunSub As MenuItem
	Friend WithEvents mnuFileProperties As MenuItem
	Friend WithEvents mnuFileBreak1 As MenuItem
	Friend WithEvents mnuFileExit As MenuItem
	Friend WithEvents mnuTools As MenuItem
	Friend WithEvents mnuToolsSendXplMsg As MenuItem
	Friend WithEvents mnuToolsHVX10Import As MenuItem
	Friend WithEvents mnuHelp As MenuItem
	Friend WithEvents mnuHelpCheckForUpdates As MenuItem
	Friend WithEvents mnuHelpUpdatePlugins As MenuItem
	Friend WithEvents mnuHelpAbout As MenuItem
	Friend WithEvents mnuSetDefaultNode As MenuItem
	Friend WithEvents mnuView As MenuItem
	Friend WithEvents mnuViewRefresh As MenuItem

	Friend WithEvents NodesContextMenu As ContextMenu
	Friend WithEvents ResultsContextMenu As ContextMenu
	Friend WithEvents mnuConnect As MenuItem
	Friend WithEvents mnuNewDeterminatorRule As MenuItem
	Friend WithEvents mnuFileReloadScripts As MenuItem
	Friend WithEvents mnuRestart As MenuItem
	Friend WithEvents mnuErrorLog As MenuItem
	Friend WithEvents mnuEditXML As MenuItem
	Friend WithEvents mnuProperties As MenuItem


	Friend WithEvents mnuNewScript As MenuItem
	Friend WithEvents mnuReloadScripts As MenuItem
	Friend WithEvents mnuRefreshScripts As MenuItem
	Friend WithEvents mnuDeleteScript As MenuItem

	Friend WithEvents mnuNewEvent As MenuItem
	Friend WithEvents mnuDeleteDeterminator As MenuItem
	Friend WithEvents mnuDeleteEvent As MenuItem
	Friend WithEvents mnuEditEvent As MenuItem
  Friend WithEvents mnuCtxRefresh As MenuItem
	Friend WithEvents mnuRunEvent As MenuItem
	Friend WithEvents mnuRunDeterminator As MenuItem
	Friend WithEvents mnuDuplicateDeterminator As System.Windows.Forms.MenuItem
  Friend WithEvents mnuEditDeterminator As MenuItem
  Friend WithEvents mnuExportDeterminator As MenuItem
  Friend WithEvents mnuImportDeterminator As MenuItem

	Friend WithEvents mnuDeleteX10 As MenuItem
	Friend WithEvents mnuX10On As MenuItem
	Friend WithEvents mnuX10Off As MenuItem
	Friend WithEvents mnuX10StatusRequest As MenuItem
	Friend WithEvents mnuX10NewDevice As MenuItem
	Friend WithEvents mnuRefreshX10 As MenuItem

	Friend WithEvents mnuNewGlobal As MenuItem
	Friend WithEvents mnuUpdateGlobal As MenuItem
	Friend WithEvents mnuDelGlobal As MenuItem
	Friend WithEvents mnuDelConfig As MenuItem
	Friend WithEvents mnuConfigure As MenuItem
	Friend WithEvents mnuViewScript As MenuItem
	Friend WithEvents mnuBreak As MenuItem
  Friend WithEvents mnuAllTasks As MenuItem
  Friend WithEvents mnuMoreInfo As MenuItem
	Friend WithEvents Panel1 As System.Windows.Forms.Panel
	Friend WithEvents tvwNodes As System.Windows.Forms.TreeView
	Friend WithEvents Splitter1 As System.Windows.Forms.Splitter
	Friend WithEvents Panel2 As System.Windows.Forms.Panel
	Friend WithEvents lvwItems As System.Windows.Forms.ListView
	Friend WithEvents mnuHelpTopics As System.Windows.Forms.MenuItem
	Friend WithEvents MenuItem2 As System.Windows.Forms.MenuItem
	Friend WithEvents HelpProvider1 As System.Windows.Forms.HelpProvider
	Friend WithEvents rtbSplash As System.Windows.Forms.RichTextBox
	Friend WithEvents mnuLanguage As System.Windows.Forms.MenuItem
	Friend WithEvents ToolBar1 As System.Windows.Forms.ToolBar
	Friend WithEvents imlToolbar As System.Windows.Forms.ImageList
	Friend WithEvents tbbAbout As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbChangeServer As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbHelp As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbSendxPL As System.Windows.Forms.ToolBarButton
	Friend WithEvents ttbRefresh As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbReload As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbNew As System.Windows.Forms.ToolBarButton
	Friend WithEvents ToolbarNew As System.Windows.Forms.ContextMenu
	Friend WithEvents mnuMonitor As System.Windows.Forms.MenuItem
	Friend WithEvents mnuToolsEthernet As System.Windows.Forms.MenuItem
	Friend WithEvents tbbMonitor As System.Windows.Forms.ToolBarButton
	Friend WithEvents imlTreeView As System.Windows.Forms.ImageList
	Friend WithEvents tbbOn As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbOff As System.Windows.Forms.ToolBarButton
	Friend WithEvents mnuToolNewScript As System.Windows.Forms.MenuItem
	Friend WithEvents mnuToolNewEvent As System.Windows.Forms.MenuItem
	Friend WithEvents mnuToolNewGlobal As System.Windows.Forms.MenuItem
	Friend WithEvents mnuToolNewDeterminator As System.Windows.Forms.MenuItem
	Friend WithEvents mnuToolNewX10 As System.Windows.Forms.MenuItem
	Friend WithEvents tbbRunSub As System.Windows.Forms.ToolBarButton
	Friend WithEvents tbbRunDeterminator As System.Windows.Forms.ToolBarButton
	Friend WithEvents separator1 As System.Windows.Forms.ToolBarButton
	Friend WithEvents separator2 As System.Windows.Forms.ToolBarButton
	Friend WithEvents separator3 As System.Windows.Forms.ToolBarButton
	Friend WithEvents MenuItem1 As System.Windows.Forms.MenuItem
	Friend WithEvents StatusBar1 As System.Windows.Forms.StatusBar
	Friend WithEvents sbpServer As System.Windows.Forms.StatusBarPanel
	Friend WithEvents sbpStuff1 As System.Windows.Forms.StatusBarPanel
	Friend WithEvents sbpManglerVersion As System.Windows.Forms.StatusBarPanel
	Friend WithEvents mnuRefreshGlowBalls As System.Windows.Forms.MenuItem

	<System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Me.components = New System.ComponentModel.Container
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmMain))
		Me.MainMenu1 = New System.Windows.Forms.MainMenu
		Me.mnuFile = New System.Windows.Forms.MenuItem
		Me.mnuFileNew = New System.Windows.Forms.MenuItem
		Me.mnuFileNewDeterminator = New System.Windows.Forms.MenuItem
    'Me.mnuFileNewScript = New System.Windows.Forms.MenuItem
		Me.mnuFileNewEvent = New System.Windows.Forms.MenuItem
		Me.mnuNewGlobal = New System.Windows.Forms.MenuItem
		Me.mnuFileReloadScripts = New System.Windows.Forms.MenuItem
		Me.mnuRestart = New System.Windows.Forms.MenuItem
		Me.mnuFileProperties = New System.Windows.Forms.MenuItem
		Me.MenuItem1 = New System.Windows.Forms.MenuItem
		Me.mnuConnect = New System.Windows.Forms.MenuItem
		Me.mnuFileBreak1 = New System.Windows.Forms.MenuItem
		Me.mnuFileExit = New System.Windows.Forms.MenuItem
		Me.mnuView = New System.Windows.Forms.MenuItem
		Me.mnuViewRefresh = New System.Windows.Forms.MenuItem
		Me.mnuTools = New System.Windows.Forms.MenuItem
		Me.mnuFileRunSub = New System.Windows.Forms.MenuItem
		Me.mnuToolsSendXplMsg = New System.Windows.Forms.MenuItem
		Me.mnuMonitor = New System.Windows.Forms.MenuItem
		Me.mnuToolsEthernet = New System.Windows.Forms.MenuItem
		Me.mnuToolsHVX10Import = New System.Windows.Forms.MenuItem
		Me.mnuRefreshGlowBalls = New System.Windows.Forms.MenuItem
		Me.mnuHelp = New System.Windows.Forms.MenuItem
		Me.mnuHelpTopics = New System.Windows.Forms.MenuItem
		Me.mnuHelpCheckForUpdates = New System.Windows.Forms.MenuItem
		Me.mnuHelpUpdatePlugins = New System.Windows.Forms.MenuItem
		Me.mnuLanguage = New System.Windows.Forms.MenuItem
		Me.MenuItem2 = New System.Windows.Forms.MenuItem
		Me.mnuHelpAbout = New System.Windows.Forms.MenuItem
		Me.mnuSetDefaultNode = New System.Windows.Forms.MenuItem
		Me.mnuNewDeterminatorRule = New System.Windows.Forms.MenuItem
		Me.mnuCtxOpen = New System.Windows.Forms.MenuItem
		Me.mnuNewDeterminatorGroup = New System.Windows.Forms.MenuItem
		Me.mnuDeleteDeterminatorGroup = New System.Windows.Forms.MenuItem
		Me.mnuCtxPoll = New System.Windows.Forms.MenuItem
		Me.NodesContextMenu = New System.Windows.Forms.ContextMenu
		Me.ResultsContextMenu = New System.Windows.Forms.ContextMenu
		Me.mnuErrorLog = New System.Windows.Forms.MenuItem
		Me.mnuEditXML = New System.Windows.Forms.MenuItem
		Me.mnuProperties = New System.Windows.Forms.MenuItem
		Me.mnuNewScript = New System.Windows.Forms.MenuItem
		Me.mnuDeleteScript = New System.Windows.Forms.MenuItem
		Me.mnuReloadScripts = New System.Windows.Forms.MenuItem
		Me.mnuRefreshScripts = New System.Windows.Forms.MenuItem
		Me.mnuDeleteDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuDeleteEvent = New System.Windows.Forms.MenuItem
		Me.mnuEditEvent = New System.Windows.Forms.MenuItem
		Me.mnuNewEvent = New System.Windows.Forms.MenuItem
		Me.mnuCtxRefresh = New System.Windows.Forms.MenuItem
		Me.mnuRunEvent = New System.Windows.Forms.MenuItem
		Me.mnuRunDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuDuplicateDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuEditDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuExportDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuImportDeterminator = New System.Windows.Forms.MenuItem
		Me.mnuDeleteX10 = New System.Windows.Forms.MenuItem
		Me.mnuX10On = New System.Windows.Forms.MenuItem
		Me.mnuX10Off = New System.Windows.Forms.MenuItem
		Me.mnuX10StatusRequest = New System.Windows.Forms.MenuItem
		Me.mnuX10NewDevice = New System.Windows.Forms.MenuItem
		Me.mnuRefreshX10 = New System.Windows.Forms.MenuItem
		Me.mnuUpdateGlobal = New System.Windows.Forms.MenuItem
		Me.mnuDelGlobal = New System.Windows.Forms.MenuItem
		Me.mnuDelConfig = New System.Windows.Forms.MenuItem
		Me.mnuConfigure = New System.Windows.Forms.MenuItem
		Me.mnuViewScript = New System.Windows.Forms.MenuItem
		Me.mnuBreak = New System.Windows.Forms.MenuItem
		Me.mnuAllTasks = New System.Windows.Forms.MenuItem
		Me.mnuMoreInfo = New System.Windows.Forms.MenuItem
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.tvwNodes = New System.Windows.Forms.TreeView
		Me.imlTreeView = New System.Windows.Forms.ImageList(Me.components)
		Me.Splitter1 = New System.Windows.Forms.Splitter
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.lvwItems = New System.Windows.Forms.ListView
		Me.rtbSplash = New System.Windows.Forms.RichTextBox
		Me.HelpProvider1 = New System.Windows.Forms.HelpProvider
		Me.ToolBar1 = New System.Windows.Forms.ToolBar
		Me.tbbNew = New System.Windows.Forms.ToolBarButton
		Me.ToolbarNew = New System.Windows.Forms.ContextMenu
		Me.mnuToolNewScript = New System.Windows.Forms.MenuItem
		Me.mnuToolNewEvent = New System.Windows.Forms.MenuItem
		Me.mnuToolNewGlobal = New System.Windows.Forms.MenuItem
		Me.mnuToolNewX10 = New System.Windows.Forms.MenuItem
		Me.mnuToolNewDeterminator = New System.Windows.Forms.MenuItem
		Me.tbbChangeServer = New System.Windows.Forms.ToolBarButton
		Me.tbbSendxPL = New System.Windows.Forms.ToolBarButton
		Me.separator1 = New System.Windows.Forms.ToolBarButton
		Me.tbbReload = New System.Windows.Forms.ToolBarButton
		Me.tbbRunSub = New System.Windows.Forms.ToolBarButton
		Me.tbbRunDeterminator = New System.Windows.Forms.ToolBarButton
		Me.ttbRefresh = New System.Windows.Forms.ToolBarButton
		Me.tbbMonitor = New System.Windows.Forms.ToolBarButton
		Me.separator2 = New System.Windows.Forms.ToolBarButton
		Me.tbbHelp = New System.Windows.Forms.ToolBarButton
		Me.tbbAbout = New System.Windows.Forms.ToolBarButton
		Me.separator3 = New System.Windows.Forms.ToolBarButton
		Me.tbbOn = New System.Windows.Forms.ToolBarButton
		Me.tbbOff = New System.Windows.Forms.ToolBarButton
		Me.imlToolbar = New System.Windows.Forms.ImageList(Me.components)
		Me.StatusBar1 = New System.Windows.Forms.StatusBar
		Me.sbpServer = New System.Windows.Forms.StatusBarPanel
		Me.sbpStuff1 = New System.Windows.Forms.StatusBarPanel
		Me.sbpManglerVersion = New System.Windows.Forms.StatusBarPanel
		Me.Panel1.SuspendLayout()
		Me.Panel2.SuspendLayout()
		CType(Me.sbpServer, System.ComponentModel.ISupportInitialize).BeginInit()
		CType(Me.sbpStuff1, System.ComponentModel.ISupportInitialize).BeginInit()
		CType(Me.sbpManglerVersion, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.SuspendLayout()
		'
		'MainMenu1
		'
		Me.MainMenu1.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFile, Me.mnuView, Me.mnuTools, Me.mnuHelp})
		'
		'mnuFile
		'
		Me.mnuFile.Index = 0
		Me.mnuFile.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFileNew, Me.mnuFileReloadScripts, Me.mnuRestart, Me.mnuFileProperties, Me.MenuItem1, Me.mnuConnect, Me.mnuFileBreak1, Me.mnuFileExit})
		Me.mnuFile.Text = "&File"
		'
		'mnuFileNew
		'
		Me.mnuFileNew.Index = 0
    Me.mnuFileNew.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFileNewDeterminator, Me.mnuNewScript, Me.mnuFileNewEvent, Me.mnuNewGlobal})
		Me.mnuFileNew.Text = "New"
		'
		'mnuFileNewDeterminator
		'
		Me.mnuFileNewDeterminator.Index = 0
    Me.mnuFileNewDeterminator.Text = "New Determinator"
		'
		'mnuFileNewScript
		'
    'Me.mnuFileNewScript.Index = 1
    'Me.mnuFileNewScript.Text = "New Script"
		'
		'mnuFileNewEvent
		'
		Me.mnuFileNewEvent.Index = 2
    Me.mnuFileNewEvent.Text = "New Event"
    Me.mnuFileNewEvent.Visible = False
		'
		'mnuNewGlobal
		'
		Me.mnuNewGlobal.Index = 3
    Me.mnuNewGlobal.Text = ""
		'
		'mnuFileReloadScripts
		'
		Me.mnuFileReloadScripts.Index = 1
		Me.mnuFileReloadScripts.Shortcut = System.Windows.Forms.Shortcut.F11
		Me.mnuFileReloadScripts.Text = ""
		'
		'mnuRestart
		'
		Me.mnuRestart.Index = 2
		Me.mnuRestart.Text = "Restart Service"
		'
		'mnuFileProperties
		'
		Me.mnuFileProperties.Index = 3
		Me.mnuFileProperties.Text = "Properties"
		'
		'MenuItem1
		'
		Me.MenuItem1.Index = 4
		Me.MenuItem1.Text = "-"
		'
		'mnuConnect
		'
		Me.mnuConnect.Index = 5
		Me.mnuConnect.Text = ""
		'
		'mnuFileBreak1
		'
		Me.mnuFileBreak1.Index = 6
		Me.mnuFileBreak1.Text = "-"
		'
		'mnuFileExit
		'
		Me.mnuFileExit.Index = 7
		Me.mnuFileExit.Text = "E&xit"
		'
		'mnuView
		'
		Me.mnuView.Index = 1
		Me.mnuView.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuViewRefresh})
		Me.mnuView.Text = "&View"
		'
		'mnuViewRefresh
		'
		Me.mnuViewRefresh.Index = 0
		Me.mnuViewRefresh.Shortcut = System.Windows.Forms.Shortcut.F5
		Me.mnuViewRefresh.Text = "Refresh"
		'
		'mnuTools
		'
		Me.mnuTools.Index = 2
		Me.mnuTools.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuFileRunSub, Me.mnuToolsSendXplMsg, Me.mnuMonitor, Me.mnuToolsEthernet, Me.mnuToolsHVX10Import, Me.mnuRefreshGlowBalls})
		Me.mnuTools.Text = "&Tools"
		'
		'mnuFileRunSub
		'
		Me.mnuFileRunSub.Index = 0
		Me.mnuFileRunSub.Shortcut = System.Windows.Forms.Shortcut.F10
		Me.mnuFileRunSub.Text = "Run Sub"
		'
		'mnuToolsSendXplMsg
		'
		Me.mnuToolsSendXplMsg.Index = 1
		Me.mnuToolsSendXplMsg.Shortcut = System.Windows.Forms.Shortcut.F11
		Me.mnuToolsSendXplMsg.Text = "Send xPL Message"
		'
		'mnuMonitor
		'
		Me.mnuMonitor.Index = 2
		Me.mnuMonitor.Shortcut = System.Windows.Forms.Shortcut.F12
		Me.mnuMonitor.Text = "xPL Monitor"
		'
		'mnuToolsEthernet
		'
		Me.mnuToolsEthernet.Index = 3
		Me.mnuToolsEthernet.Text = "Network Settings"
		'
		'mnuToolsHVX10Import
		'
		Me.mnuToolsHVX10Import.Index = 4
		Me.mnuToolsHVX10Import.Text = "Import HomeVision X10 Devices"
		'
		'mnuRefreshGlowBalls
		'
		Me.mnuRefreshGlowBalls.Index = 5
		Me.mnuRefreshGlowBalls.Text = "Automatically Refresh Globals"
		'
		'mnuHelp
		'
		Me.mnuHelp.Index = 3
		Me.mnuHelp.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuHelpTopics, Me.mnuHelpCheckForUpdates, Me.mnuHelpUpdatePlugins, Me.mnuLanguage, Me.MenuItem2, Me.mnuHelpAbout})
		Me.mnuHelp.Text = "&Help"
		'
		'mnuHelpTopics
		'
		Me.mnuHelpTopics.Index = 0
		Me.mnuHelpTopics.Text = "Help Topics"
		'
		'mnuHelpCheckForUpdates
		'
		Me.mnuHelpCheckForUpdates.Index = 1
		Me.mnuHelpCheckForUpdates.Text = "Check for Updates"
		'
		'mnuHelpUpdatePlugins
		'
		Me.mnuHelpUpdatePlugins.Index = 2
		Me.mnuHelpUpdatePlugins.Text = "Update Plugins"
		'
		'mnuLanguage
		'
		Me.mnuLanguage.Index = 3
		Me.mnuLanguage.Text = "Language"
		'
		'MenuItem2
		'
		Me.MenuItem2.Index = 4
		Me.MenuItem2.Text = "-"
		'
		'mnuHelpAbout
		'
		Me.mnuHelpAbout.Index = 5
		Me.mnuHelpAbout.Text = "About"
		'
		'mnuSetDefaultNode
		'
		Me.mnuSetDefaultNode.Index = -1
		Me.mnuSetDefaultNode.Text = "Set as Default"
		'
		'mnuNewDeterminatorRule
		'
		Me.mnuNewDeterminatorRule.Index = -1
		Me.mnuNewDeterminatorRule.Text = ""
		'
		'mnuCtxOpen
		'
		Me.mnuCtxOpen.Index = -1
		Me.mnuCtxOpen.Text = "Edit"
		'
		'mnuNewDeterminatorGroup
		'
		Me.mnuNewDeterminatorGroup.Index = -1
		Me.mnuNewDeterminatorGroup.Text = "New Determinator group"
		'
		'mnuDeleteDeterminatorGroup
		'
		Me.mnuDeleteDeterminatorGroup.Index = -1
		Me.mnuDeleteDeterminatorGroup.Text = "Delete"
		'
		'mnuCtxPoll
		'
		Me.mnuCtxPoll.Index = -1
		Me.mnuCtxPoll.Text = "Poll for Devices"
		'
		'NodesContextMenu
		'
		'
		'ResultsContextMenu
		'
		'
		'mnuErrorLog
		'
		Me.mnuErrorLog.Index = -1
		Me.mnuErrorLog.Text = ""
		'
		'mnuEditXML
		'
		Me.mnuEditXML.Index = -1
		Me.mnuEditXML.Text = ""
		'
		'mnuProperties
		'
		Me.mnuProperties.Index = -1
		Me.mnuProperties.Text = ""
		'
		'mnuNewScript
		'
		Me.mnuNewScript.Text = "New Script"
		'
		'mnuDeleteScript
		'
		Me.mnuDeleteScript.Index = -1
		Me.mnuDeleteScript.Text = "Delete"
		'
		'mnuReloadScripts
		'
		Me.mnuReloadScripts.Index = -1
		Me.mnuReloadScripts.Text = ""
		'
		'mnuRefreshScripts
		'
		Me.mnuRefreshScripts.Index = -1
		Me.mnuRefreshScripts.Text = ""
		'
		'mnuDeleteDeterminator
		'
		Me.mnuDeleteDeterminator.Index = -1
		Me.mnuDeleteDeterminator.Text = "Delete"
		'
		'mnuDeleteEvent
		'
		Me.mnuDeleteEvent.Index = -1
		Me.mnuDeleteEvent.Text = "Delete"
		'
		'mnuEditEvent
		'
		Me.mnuEditEvent.Index = -1
		Me.mnuEditEvent.Text = "Edit"
		'
		'mnuNewEvent
		'
		Me.mnuNewEvent.Index = -1
    Me.mnuNewEvent.Text = "New Event"
		'
		'mnuCtxRefresh
		'
		Me.mnuCtxRefresh.Index = -1
		Me.mnuCtxRefresh.Text = ""
		'
		'mnuRunEvent
		'
		Me.mnuRunEvent.Index = -1
		Me.mnuRunEvent.Text = "Execute Now"
		'
		'mnuRunDeterminator
		'
		Me.mnuRunDeterminator.Index = -1
		Me.mnuRunDeterminator.Text = "Execute Now"
		'
		'mnuDuplicateDeterminator
		'
		Me.mnuDuplicateDeterminator.Index = -1
		Me.mnuDuplicateDeterminator.Text = "Duplicate"
		'
		'mnuEditDeterminator
		'
		Me.mnuEditDeterminator.Index = -1
		Me.mnuEditDeterminator.Text = ""
		'
		'mnuExportDeterminator
		'
		Me.mnuExportDeterminator.Index = -1
		Me.mnuExportDeterminator.Text = "Export"
		'
		'mnuImportDeterminator
		'
		Me.mnuImportDeterminator.Index = -1
		Me.mnuImportDeterminator.Text = "Import"
		'
		'mnuDeleteX10
		'
		Me.mnuDeleteX10.Index = -1
		Me.mnuDeleteX10.Text = "Delete"
		'
		'mnuX10On
		'
		Me.mnuX10On.Index = -1
		Me.mnuX10On.Text = "Switch On"
		'
		'mnuX10Off
		'
		Me.mnuX10Off.Index = -1
		Me.mnuX10Off.Text = "Switch Off"
		'
		'mnuX10StatusRequest
		'
		Me.mnuX10StatusRequest.Index = -1
		Me.mnuX10StatusRequest.Text = "Status Request"
		'
		'mnuX10NewDevice
		'
		Me.mnuX10NewDevice.Index = -1
		Me.mnuX10NewDevice.Text = ""
		'
		'mnuRefreshX10
		'
		Me.mnuRefreshX10.Index = -1
		Me.mnuRefreshX10.Text = ""
		'
		'mnuUpdateGlobal
		'
		Me.mnuUpdateGlobal.Index = -1
		Me.mnuUpdateGlobal.Text = "Set Value"
		'
		'mnuDelGlobal
		'
		Me.mnuDelGlobal.Index = -1
		Me.mnuDelGlobal.Text = "Delete"
		'
		'mnuDelConfig
		'
		Me.mnuDelConfig.Index = 2
		Me.mnuDelConfig.Text = ""
		'
		'mnuConfigure
		'
		Me.mnuConfigure.Index = 1
		Me.mnuConfigure.Text = ""
		'
		'mnuViewScript
		'
		Me.mnuViewScript.Index = 0
		Me.mnuViewScript.Text = ""
		'
		'mnuBreak
		'
		Me.mnuBreak.Index = -1
		Me.mnuBreak.Text = "-"
		'
		'mnuAllTasks
		'
		Me.mnuAllTasks.Index = -1
		Me.mnuAllTasks.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuViewScript, Me.mnuConfigure, Me.mnuDelConfig, Me.mnuMoreInfo})
		Me.mnuAllTasks.Text = "All Tasks"
		'
		'mnuMoreInfo
		'
		Me.mnuMoreInfo.Index = 3
		Me.mnuMoreInfo.Text = "More Info"
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.tvwNodes)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Left
		Me.Panel1.Location = New System.Drawing.Point(0, 28)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(140, 442)
		Me.Panel1.TabIndex = 2
		'
		'tvwNodes
		'
		Me.tvwNodes.AllowDrop = True
		Me.tvwNodes.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.tvwNodes.ContextMenu = Me.NodesContextMenu
		Me.tvwNodes.Dock = System.Windows.Forms.DockStyle.Fill
		Me.tvwNodes.ImageList = Me.imlTreeView
		Me.tvwNodes.Location = New System.Drawing.Point(0, 0)
		Me.tvwNodes.Name = "tvwNodes"
		Me.tvwNodes.SelectedImageIndex = 3
		Me.tvwNodes.Size = New System.Drawing.Size(140, 442)
		Me.tvwNodes.TabIndex = 1
		'
		'imlTreeView
		'
		Me.imlTreeView.ImageSize = New System.Drawing.Size(16, 16)
		Me.imlTreeView.ImageStream = CType(resources.GetObject("imlTreeView.ImageStream"), System.Windows.Forms.ImageListStreamer)
		Me.imlTreeView.TransparentColor = System.Drawing.Color.Transparent
		'
		'Splitter1
		'
		Me.Splitter1.Location = New System.Drawing.Point(140, 28)
		Me.Splitter1.Name = "Splitter1"
		Me.Splitter1.Size = New System.Drawing.Size(5, 442)
		Me.Splitter1.TabIndex = 3
		Me.Splitter1.TabStop = False
		'
		'Panel2
		'
		Me.Panel2.Controls.Add(Me.lvwItems)
		Me.Panel2.Controls.Add(Me.rtbSplash)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Fill
		Me.Panel2.Location = New System.Drawing.Point(145, 28)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(599, 442)
		Me.Panel2.TabIndex = 4
		'
		'lvwItems
		'
		Me.lvwItems.AllowDrop = True
		Me.lvwItems.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lvwItems.ContextMenu = Me.ResultsContextMenu
		Me.lvwItems.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lvwItems.HideSelection = False
		Me.lvwItems.Location = New System.Drawing.Point(0, 0)
		Me.lvwItems.Name = "lvwItems"
		Me.lvwItems.Size = New System.Drawing.Size(599, 442)
		Me.lvwItems.SmallImageList = Me.imlTreeView
		Me.lvwItems.TabIndex = 2
		'
		'rtbSplash
		'
		Me.rtbSplash.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.rtbSplash.Dock = System.Windows.Forms.DockStyle.Fill
		Me.rtbSplash.Location = New System.Drawing.Point(0, 0)
		Me.rtbSplash.Name = "rtbSplash"
		Me.rtbSplash.ReadOnly = True
		Me.rtbSplash.Size = New System.Drawing.Size(599, 442)
		Me.rtbSplash.TabIndex = 3
		Me.rtbSplash.Text = "RichTextBox1"
		'
		'HelpProvider1
		'
		Me.HelpProvider1.HelpNamespace = "xplhal.chm"
		'
		'ToolBar1
		'
		Me.ToolBar1.Appearance = System.Windows.Forms.ToolBarAppearance.Flat
		Me.ToolBar1.Buttons.AddRange(New System.Windows.Forms.ToolBarButton() {Me.tbbNew, Me.tbbChangeServer, Me.tbbSendxPL, Me.separator1, Me.tbbReload, Me.tbbRunSub, Me.tbbRunDeterminator, Me.ttbRefresh, Me.tbbMonitor, Me.separator2, Me.tbbHelp, Me.tbbAbout, Me.separator3, Me.tbbOn, Me.tbbOff})
		Me.ToolBar1.ButtonSize = New System.Drawing.Size(16, 16)
		Me.ToolBar1.DropDownArrows = True
		Me.ToolBar1.ImageList = Me.imlToolbar
		Me.ToolBar1.Location = New System.Drawing.Point(0, 0)
		Me.ToolBar1.Name = "ToolBar1"
		Me.ToolBar1.ShowToolTips = True
		Me.ToolBar1.Size = New System.Drawing.Size(744, 28)
		Me.ToolBar1.TabIndex = 5
		'
		'tbbNew
		'
		Me.tbbNew.DropDownMenu = Me.ToolbarNew
		Me.tbbNew.ImageIndex = 6
		Me.tbbNew.Style = System.Windows.Forms.ToolBarButtonStyle.DropDownButton
		Me.tbbNew.Tag = "new"
		Me.tbbNew.ToolTipText = "done from res file"
		'
		'ToolbarNew
		'
		Me.ToolbarNew.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.mnuToolNewScript, Me.mnuToolNewEvent, Me.mnuToolNewGlobal, Me.mnuToolNewX10, Me.mnuToolNewDeterminator})
		'
		'mnuToolNewScript
		'
		Me.mnuToolNewScript.Index = 0
		Me.mnuToolNewScript.Text = "New Script"
		'
		'mnuToolNewEvent
		'
		Me.mnuToolNewEvent.Index = 1
		Me.mnuToolNewEvent.Text = "New Event"
		'
		'mnuToolNewGlobal
		'
		Me.mnuToolNewGlobal.Index = 2
		Me.mnuToolNewGlobal.Text = "New Global"
		'
		'mnuToolNewX10
		'
		Me.mnuToolNewX10.Index = 3
		Me.mnuToolNewX10.Text = "New X10"
		'
		'mnuToolNewDeterminator
		'
		Me.mnuToolNewDeterminator.Index = 4
		Me.mnuToolNewDeterminator.Text = "New Determinator"
		Me.mnuToolNewDeterminator.Visible = False
		'
		'tbbChangeServer
		'
		Me.tbbChangeServer.ImageIndex = 1
		Me.tbbChangeServer.Tag = "changeserver"
		Me.tbbChangeServer.ToolTipText = "done from res file"
		'
		'tbbSendxPL
		'
		Me.tbbSendxPL.ImageIndex = 3
		Me.tbbSendxPL.Tag = "sendxpl"
		Me.tbbSendxPL.ToolTipText = "done from res file"
		'
		'separator1
		'
		Me.separator1.Style = System.Windows.Forms.ToolBarButtonStyle.Separator
		'
		'tbbReload
		'
		Me.tbbReload.ImageIndex = 5
		Me.tbbReload.Tag = "reload"
		Me.tbbReload.ToolTipText = "done from res file"
		'
		'tbbRunSub
		'
		Me.tbbRunSub.ImageIndex = 8
		Me.tbbRunSub.Tag = "runsub"
		Me.tbbRunSub.ToolTipText = "done from res file"
		'
		'tbbRunDeterminator
		'
		Me.tbbRunDeterminator.ImageIndex = 11
		Me.tbbRunDeterminator.Tag = "rundeterminator"
		Me.tbbRunDeterminator.ToolTipText = "done from res file"
		'
		'ttbRefresh
		'
		Me.ttbRefresh.ImageIndex = 4
		Me.ttbRefresh.Tag = "refresh"
		Me.ttbRefresh.ToolTipText = "done from res file"
		'
		'tbbMonitor
		'
		Me.tbbMonitor.ImageIndex = 7
		Me.tbbMonitor.Tag = "monitor"
		Me.tbbMonitor.ToolTipText = "done from res file"
		'
		'separator2
		'
		Me.separator2.Style = System.Windows.Forms.ToolBarButtonStyle.Separator
		'
		'tbbHelp
		'
		Me.tbbHelp.ImageIndex = 2
		Me.tbbHelp.Tag = "help"
		Me.tbbHelp.ToolTipText = "done from res file"
		'
		'tbbAbout
		'
		Me.tbbAbout.ImageIndex = 0
		Me.tbbAbout.Tag = "about"
		Me.tbbAbout.ToolTipText = "done from res file"
		'
		'separator3
		'
		Me.separator3.Style = System.Windows.Forms.ToolBarButtonStyle.Separator
		'
		'tbbOn
		'
		Me.tbbOn.Enabled = False
		Me.tbbOn.ImageIndex = 10
		Me.tbbOn.Tag = "on"
		Me.tbbOn.ToolTipText = "done from res file"
		'
		'tbbOff
		'
		Me.tbbOff.Enabled = False
		Me.tbbOff.ImageIndex = 9
		Me.tbbOff.Tag = "off"
		Me.tbbOff.ToolTipText = "done from res file"
		'
		'imlToolbar
		'
		Me.imlToolbar.ImageSize = New System.Drawing.Size(16, 16)
		Me.imlToolbar.ImageStream = CType(resources.GetObject("imlToolbar.ImageStream"), System.Windows.Forms.ImageListStreamer)
		Me.imlToolbar.TransparentColor = System.Drawing.Color.Transparent
		'
		'StatusBar1
		'
		Me.StatusBar1.Location = New System.Drawing.Point(0, 470)
		Me.StatusBar1.Name = "StatusBar1"
		Me.StatusBar1.Panels.AddRange(New System.Windows.Forms.StatusBarPanel() {Me.sbpServer, Me.sbpStuff1, Me.sbpManglerVersion})
		Me.StatusBar1.ShowPanels = True
		Me.StatusBar1.Size = New System.Drawing.Size(744, 22)
		Me.StatusBar1.TabIndex = 6
		Me.StatusBar1.Text = "StatusBar1"
		'
		'sbpServer
		'
		Me.sbpServer.AutoSize = System.Windows.Forms.StatusBarPanelAutoSize.Contents
		Me.sbpServer.ToolTipText = "Server version"
		Me.sbpServer.Width = 10
		'
		'sbpStuff1
		'
		Me.sbpStuff1.AutoSize = System.Windows.Forms.StatusBarPanelAutoSize.Spring
		Me.sbpStuff1.Width = 708
		'
		'sbpManglerVersion
		'
		Me.sbpManglerVersion.AutoSize = System.Windows.Forms.StatusBarPanelAutoSize.Contents
		Me.sbpManglerVersion.Width = 10
		'
		'frmMain
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.ClientSize = New System.Drawing.Size(744, 492)
		Me.Controls.Add(Me.Panel2)
		Me.Controls.Add(Me.Splitter1)
		Me.Controls.Add(Me.Panel1)
		Me.Controls.Add(Me.ToolBar1)
		Me.Controls.Add(Me.StatusBar1)
		Me.HelpProvider1.SetHelpNavigator(Me, System.Windows.Forms.HelpNavigator.TableOfContents)
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Menu = Me.MainMenu1
		Me.Name = "frmMain"
		Me.HelpProvider1.SetShowHelp(Me, True)
		Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
		Me.Text = "xPLHal Manager"
		Me.Panel1.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		CType(Me.sbpServer, System.ComponentModel.ISupportInitialize).EndInit()
		CType(Me.sbpStuff1, System.ComponentModel.ISupportInitialize).EndInit()
		CType(Me.sbpManglerVersion, System.ComponentModel.ISupportInitialize).EndInit()
		Me.ResumeLayout(False)

	End Sub

#End Region

	Private Sub frmMain_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
		SplashScreen = New frmSplash
		SplashScreen.Show()
		Application.DoEvents()
		FirstActivation = True
		' Get path to plug-ins folder
		globals.PluginsPath = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData) & "\xPL\Plugins"

		Timer1 = New System.Timers.Timer
		Timer1.Interval = 30000
		Timer1.Enabled = True
		GetFormSettings(Me, 752, 540)
		InitResources()
    LoadPlugins()    
		rtbSplash.Visible = True
		lvwItems.Visible = False


		globals.XplHalSource = ""
		globals.NeedToReloadScripts = False
		lvwItems.Sorting = SortOrder.Ascending
		lvwItems.FullRowSelect = True
		LoadSettings()

		AutoRefreshGlowBalls = CBool(GetRegistryValue("RefreshGlowBalls", "0"))
		If AutoRefreshGlowBalls Then
			mnuRefreshGlowBalls.Checked = True
		Else
			mnuRefreshGlowBalls.Checked = False
		End If
		' Try and connect to the xPLHal server
		If Not connectToXplHal Then
			' Connection failed, so display the "Connect to Server" dialog      
			ChooseServer()
		Else
			PopulateNodes()
		End If
		SplashScreen.Close()
	End Sub

	Private Sub LoadSettings()
		' Initialise the settings to their defaults
		globals.xPLHalServer = "localhost"
		Try
			Dim fs As TextReader = File.OpenText("xplhalmgr.ini")
			Dim s As String
			Dim lhs, rhs As String

			s = fs.ReadLine
			While Not s Is Nothing
				If s.IndexOf("=") > 0 Then
					lhs = s.Substring(0, s.IndexOf("="))
					rhs = Microsoft.VisualBasic.Right(s, Len(s) - InStr(s, "="))
					Select Case lhs.ToUpper
						Case "AUTOUPDATEINTERVAL"
							globals.AutoUpdateInterval = rhs
						Case "AUTOUPDATEMODE"
							globals.AutoUpdateMode = rhs
						Case "AUTOUPDATERESULT"
							globals.AutoUpdateResult = rhs
						Case "ENABLEAUTOUPDATE"
							globals.EnableAutoUpdate = CBool(rhs)
						Case "LASTAUTOUPDATE"
							globals.LastAutoUpdate = CDate(rhs)
						Case "LANGUAGE"
							Threading.Thread.CurrentThread.CurrentUICulture = New CultureInfo(rhs)
              InitResources()
            Case "SERVER"
              globals.xPLHalServer = rhs
          End Select
				End If
				s = fs.ReadLine
			End While
			fs.Close()
		Catch ex As Exception
		End Try

		DefaultNode = GetRegistryValue("DefaultNode", "")
	End Sub

	Private Sub ChooseServer()
		Dim OldServer As String = globals.xPLHalServer
		Dim f As New frmConnect
		f.txtServer.Text = globals.xPLHalServer
		If f.ShowDialog(Me) = Windows.Forms.DialogResult.OK Then
			Disconnect()
			globals.xPLHalServer = f.txtServer.Text
			If ConnectToXplHal() Then
				SaveSettings()
				PopulateNodes()
			Else
				globals.xPLHalServer = OldServer
                MsgBox(My.Resources.RES_ERROR_CONNECT.Replace("\n", vbCrLf), vbCritical)
            End If
        End If
    End Sub

    Private Sub PopulateNodes()
        ' This routine populates the top-level nodes in the tree view

        ' First, ensure we've received a valid welcome banner from the xPLHal server
        If WelcomeBanner.Length < 10 Then
            globals.Unexpected(WelcomeBanner)
            Exit Sub
        Else
            ' Check on the version of the xPLHal server,
            ' and ask for it's capabilities
            VersionCheck()
            If globals.ServerMajorVersion = 1 Then
                mnuRestart.Visible = True
                mnuProperties.Visible = True
            Else
                mnuRestart.Visible = False
                mnuProperties.Visible = False
            End If
            GetCapabilities()
            If globals.Capabilities.Length >= 5 Then
                If Capabilities.Chars(5) = "W" Then
                    mnuRestart.Visible = True
                End If
            End If
            If globals.ServerOutOfDate Then
                rtbSplash.Text = "This xPLHal server is out of date." & vbCrLf & vbCrLf & "Please visit http://www.xplproject.org.uk and download the latest version of the xPLHal server to ensure optimum compatibility with the xPLHal Manager."
                rtbSplash.ForeColor = Color.Red
            Else
                rtbSplash.Rtf = My.Resources.homepage
            End If
        End If

        'Me.Text = My.resources.RES_TITLE") & " - " & welcomeBanner.Substring(welcomebanner.IndexOf(" "), welcomebanner.Length - welcomebanner.IndexOf(" "))
        sbpServer.Text = WelcomeBanner.Substring(WelcomeBanner.IndexOf(" "), WelcomeBanner.Length - WelcomeBanner.IndexOf(" "))
        sbpManglerVersion.Text = "Version " & System.Reflection.Assembly.GetExecutingAssembly.GetName().Version.Major.ToString & "." & Format(System.Reflection.Assembly.GetExecutingAssembly.GetName.Version.Minor, "####")
        ReDim globals.Modes(-1)
        ReDim globals.Periods(-1)
        PopulateOptions(globals.Modes, "Mode")
        PopulateOptions(globals.Periods, "Period")

        Dim tn As TreeNode, tn2 As TreeNode, tnParent As New TreeNode
        tvwNodes.Nodes.Clear()
        tnParent.Text = globals.xPLHalServer
        tnParent.ImageIndex = 8
        tnParent.Tag = Nothing
        tvwNodes.Nodes.Add(tnParent)

        If Capabilities.Length >= 3 Then
            If Capabilities.Chars(2) <> "0" Then
                tn = New TreeNode
                tn.Text = My.Resources.RES_SCRIPTS
                tn.Tag = "S"
                tn.ImageIndex = 1
                tnParent.Nodes.Add(tn)
                AddScriptingFolders(tn)

            Else
                mnuNewScript.Visible = False
                tbbRunSub.Visible = False
                mnuFileRunSub.Visible = False
            End If
        End If

        mnuToolNewDeterminator.Visible = False
        If Capabilities.Length >= 4 Then
            If Capabilities.Chars(3) = "1" Then
                mnuToolNewDeterminator.Visible = True
                tn = New TreeNode
                tn.Text = My.Resources.RES_DETERMINATORS
                tn.Tag = "T"
                tn.ImageIndex = 6
                AddDeterminatorGroups(tn)
                tnParent.Nodes.Add(tn)
            End If
        End If

        ' Make sure events are supported
        If Capabilities.Length >= 6 Then
            If Capabilities.Chars(4) = "1" Then
                tn = New TreeNode
                tn.Text = My.Resources.RES_EVENTS
                tn.Tag = "E"
                tn.ImageIndex = 4
                tnParent.Nodes.Add(tn)

                tn2 = New TreeNode
                tn2.Text = My.Resources.RES_RECURRING
                tn2.Tag = "R"
                tn2.ImageIndex = 4
                tn.Nodes.Add(tn2)

                tn2 = New TreeNode
                tn2.Text = My.Resources.RES_SINGLE
                tn2.Tag = "D"
                tn2.ImageIndex = 4
                tn.Nodes.Add(tn2)
                mnuFileNewEvent.Visible = True
            End If
        End If

        ' Make sure server supports VBScript
        'X10 support is retired!
        'If Capabilities.Length >= 5 Then
        '    If Capabilities.Chars(2) = "V" Then
        '        tn = New TreeNode
        '        tn.Text = "x10"
        '        tn.Tag = "X"
        '        tn.ImageIndex = 2
        '        tnParent.Nodes.Add(tn)
        '    End If
        'End If


        If Capabilities.Length >= 1 Then
            If Capabilities.Chars(0) = "1" Then

                tn = New TreeNode
                tn.Text = My.Resources.RES_XPL_DEVICES
                tn.Tag = "A"
                tn.ImageIndex = 5
                tnParent.Nodes.Add(tn)

                tn2 = New TreeNode
                tn2.Text = My.Resources.RES_AWAITING_CONFIG
                tn2.Tag = "B"
                tn2.ImageIndex = 5
                tn.Nodes.Add(tn2)
            End If
        End If

        tn = New TreeNode
        tn.Text = My.Resources.RES_GLOBALS
        tn.Tag = "C"
        tn.ImageIndex = 7
        tnParent.Nodes.Add(tn)

        lvwItems.Items.Clear()
        lvwItems.Columns.Clear()
        lvwItems.View = View.Details
        tvwNodes.Nodes(0).Expand()
    End Sub

    Private Sub tvwNodes_AfterSelect(ByVal sender As System.Object, ByVal e As System.Windows.Forms.TreeViewEventArgs) Handles tvwNodes.AfterSelect
        rtbSplash.Visible = False
        lvwItems.Visible = True
        tbbOn.Enabled = False
        tbbOff.Enabled = False
        tbbRunDeterminator.Enabled = False
        If TypeOf (e.Node.Tag) Is String Then
            If CStr(e.Node.Tag).Length > 0 Then
                Select Case CStr(e.Node.Tag).Substring(0, 1)
                    Case "R"                 ' Recurring events
                        If Not CurrentMode = "R" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_EVENTNAME, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_SUBROUTINE, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_NEXTRUNTIME, 200, HorizontalAlignment.Left)
                        End If

                        CurrentMode = "R"
                        GetEvents()
                    Case "S"
                        If Not CurrentMode = "S" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_SCRIPTNAME, lvwItems.Width - 10, HorizontalAlignment.Left)
                        End If
                        CurrentMode = "S"
                        GetScripts(CStr(e.Node.Tag), e.Node)
                    Case "E"
                        If Not CurrentMode = "E" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_EVENTNAME, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_TYPE, 60, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_SUBROUTINE, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_NEXTRUNTIME, 200, HorizontalAlignment.Left)
                        End If
                        CurrentMode = "E"
                        GetEvents()
                        GetSingleEvents(False)
                    Case "D"                 ' Single events
                        If Not CurrentMode = "D" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_EVENTNAME, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_SUBROUTINE, 200, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_DATETIME, 100, HorizontalAlignment.Left)
                        End If
                        CurrentMode = "D"
                        GetSingleEvents()
                    Case "X"
                        If Not CurrentMode = "X" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_DEVICENAME, 150, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_ADDRESS, 50, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_STATE, 70, HorizontalAlignment.Left)

                        End If
                        CurrentMode = "X"
                        GetX10()
                        tbbOn.Enabled = True
                        tbbOff.Enabled = True
                    Case "A"
                        If Not CurrentMode = "A" Then
                            CurrentMode = "A"
                            SetListviewForXplDevices()
                        End If
                        GetXPLDevices(False)
                    Case "B"
                        If Not CurrentMode = "B" Then
                            CurrentMode = "B"
                            SetListviewForXplDevices()
                        End If
                        GetXPLDevices(True)
                    Case "C"
                        If Not CurrentMode = "C" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_GLOBALNAME, 250, HorizontalAlignment.Left)
                            lvwItems.Columns.Add(My.Resources.RES_CURRENTVALUE, 500, HorizontalAlignment.Left)
                        End If
                        CurrentMode = "C"
                        GetGlobals()
                    Case "T"
                        If Not CurrentMode = "T" Then
                            lvwItems.Columns.Clear()
                            lvwItems.Columns.Add(My.Resources.RES_DETERMINATORNAME, 250, HorizontalAlignment.Left)
                            tbbRunDeterminator.Enabled = True
                        End If
                        CurrentMode = "T"
                        PopulateDeterminatorRules()
                    Case Else
                        lvwItems.Items.Clear()
                        lvwItems.Columns.Clear()
                End Select
            End If
        Else
            rtbSplash.Visible = True
            lvwItems.Visible = False
            lvwItems.Columns.Clear()
            lvwItems.Items.Clear()
            CurrentMode = ""
        End If
    End Sub

    Private Sub GetEvents()
        Dim str As String
        Dim params() As String
        Dim li As ListViewItem
        lvwItems.Items.Clear()
        ConnectToXplHal()
        xplHalSend("LISTEVENTS" & vbCrLf)
        str = GetLine()
        If str.StartsWith("218") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                params = str.Split(CChar(vbTab))
                li = New ListViewItem

                li.Text = params(0)

                If CStr(tvwNodes.SelectedNode.Tag).StartsWith("E") Then
                    li.SubItems.Add("Recurring")
                End If


                If params(1) = "{determinator}" Then
                    li.SubItems.Add(params(2))
                    li.ImageIndex = 6
                Else
                    li.SubItems.Add(params(1))
                    li.ImageIndex = 1
                End If
                '        li.SubItems.Add(params(1))


                If params.Length > 7 Then
                    li.SubItems.Add(params(6))
                End If
                lvwItems.Items.Add(li)
                str = GetLine()
            End While
        Else
            globals.Unexpected(str)
        End If
    End Sub

    Private Sub GetScripts(ByVal scriptPath As String, ByVal n As TreeNode)
        Dim str As String
        Dim FirstPopulation As Boolean
        If CStr(tvwNodes.SelectedNode.Tag) = "SMessages" Then
            lvwItems.Columns(0).Text = My.Resources.RES_MESSAGES
        Else
            lvwItems.Columns(0).Text = My.Resources.RES_SCRIPTNAME
        End If

        If scriptPath.Length = 1 Then
            scriptPath = ""
        Else
            scriptPath = Microsoft.VisualBasic.Right(scriptPath, Len(scriptPath) - 1)
        End If
        lvwItems.Items.Clear()
        ConnectToXplHal()
        xplHalSend("LISTSCRIPTS " & scriptPath & vbCrLf)
        str = GetLine()
        If Not str.StartsWith("212") Then
            globals.Unexpected(str)
        Else
            If n.Nodes.Count = 0 Then
                FirstPopulation = True
            Else
                FirstPopulation = False
            End If
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                str = str.Replace(vbCrLf, "")

                If str.EndsWith("\") Then
                    If FirstPopulation Then
                        Dim tn As New TreeNode
                        tn.Text = str.Substring(0, str.Length - 1)
                        tn.Tag = "S" & tn.Text
                        MsgBox(CStr(tn.Tag))
                        tn.ImageIndex = 1
                        n.Nodes.Add(tn)
                    End If
                Else
                    lvwItems.Items.Add(str)
                End If
                str = GetLine()
            End While
        End If
        Disconnect()
    End Sub

    Private Sub frmMain_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        Disconnect()
    End Sub

    Private Sub lvwItems_DoubleClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lvwItems.DoubleClick
        If lvwItems.SelectedItems.Count = 0 Then Exit Sub
        Select Case CurrentMode
            Case "E", "D", "R" ' Events
                EditEvent()
            Case "S" ' Script
                EditScript()
            Case "T"   ' Determinator
                EditDeterminator()
            Case "X" ' X10
                EditX10()
            Case "A"
                ConfigureDevice(True)
            Case "B"
                ConfigureDevice(False)
            Case "C"
                mnuUpdateGlobal_Click(Nothing, Nothing)
        End Select
    End Sub

    Private Sub EditScript()
        If tvwNodes.SelectedNode Is Nothing Then Exit Sub
        If lvwItems.SelectedItems.Count = 1 Then
            Dim f As New frmEditScript
            Dim str As String
            f.IsNewScript = False
            f.ScriptName = CStr(tvwNodes.SelectedNode.Tag)
            If f.ScriptName.Length > 1 Then
                f.ScriptName = f.ScriptName.Substring(1, f.ScriptName.Length - 1) & "\"
            Else
                f.ScriptName = ""
            End If
            f.ScriptName &= lvwItems.SelectedItems.Item(0).Text

            ConnectToXplHal()
            xplHalSend("GETSCRIPT " & f.ScriptName & vbCrLf)
            str = GetLine()
            If str.StartsWith("210") Then
                f.rtfScript.Text = ""
                str = GetLine()
                While str <> ("." & vbCrLf) And str <> ""
                    f.rtfScript.Text &= str
                    str = GetLine()
                End While
                f.Show()
            Else
                globals.Unexpected(str)
            End If
        End If
    End Sub

    Private Sub lvwItems_KeyPress(ByVal sender As System.Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles lvwItems.KeyPress
        If e.KeyChar = vbCr And lvwItems.SelectedItems.Count = 1 Then
            lvwItems_DoubleClick(sender, Nothing)
        End If
    End Sub

    Private Sub EditEvent()
        If lvwItems.SelectedItems.Count = 1 Then
            Dim f As New frmEditEvent
            If CurrentMode = "E" Or CurrentMode = "R" Then
                f.IsRecurring = True
            Else
                f.IsRecurring = False
            End If
            f.radSubroutine.Visible = mnuFileRunSub.Visible
            f.EventName = lvwItems.SelectedItems.Item(0).Text
            f.Show()
        End If
    End Sub

    Private Sub NodesContextMenu_Popup(ByVal sender As Object, ByVal e As System.EventArgs) Handles NodesContextMenu.Popup
        NodesContextMenu.MenuItems.Clear()
        If Not tvwNodes.SelectedNode Is Nothing Then
            If tvwNodes.SelectedNode.Tag Is Nothing Then
                With NodesContextMenu.MenuItems
                    .Add(mnuConnect)
                    .Add(mnuRestart)
                    .Add(mnuErrorLog)
                    .Add(mnuEditXML)
                    .Add(mnuProperties)
                    .Add(mnuSetDefaultNode)
                End With
            ElseIf TypeOf (tvwNodes.SelectedNode.Tag) Is String Then
                Select Case CStr(tvwNodes.SelectedNode.Tag).Substring(0, 1)
                    Case "A" ' xPL Devices
                        With NodesContextMenu.MenuItems
                            .Add(mnuCtxPoll)
                            .Add(mnuCtxRefresh)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "E" ' Events
                        With NodesContextMenu.MenuItems
                            .Add(mnuNewEvent)
                            .Add(mnuCtxRefresh)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "D", "R"
                        With NodesContextMenu.MenuItems
                            .Add(mnuNewEvent)
                            .Add(mnuCtxRefresh)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "C"     ' Globals
                        With NodesContextMenu.MenuItems
                            .Add(mnuNewGlobal)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "S"
                        With NodesContextMenu.MenuItems()
                            .Add(mnuNewScript)
                            .Add(mnuReloadScripts)
                            .Add(mnuRefreshScripts)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "X"
                        With NodesContextMenu.MenuItems
                            .Add(mnuX10NewDevice)
                            .Add(mnuRefreshX10)
                            .Add(mnuSetDefaultNode)
                        End With
                    Case "T" ' Determinators
                        With NodesContextMenu.MenuItems
                            .Add(mnuNewDeterminatorRule)
                            .Add(mnuNewDeterminatorGroup)
                            If tvwNodes.SelectedNode.Tag.ToString().Length > 1 Then
                                .Add(mnuDeleteDeterminatorGroup)
                            End If
                            .Add(mnuImportDeterminator)
                            .Add(mnuBreak)
                            .Add(mnuSetDefaultNode)
                        End With
                End Select
            End If
        End If
    End Sub

    Private Sub EditXML()
        Dim f As New frmEditXML
        f.Show()
    End Sub

    Private Sub ViewErrorLog()
        Dim f As New frmErrorLog
        f.Show()
    End Sub

    Private Sub mnuEditXML_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditXML.Click
        EditXML()
    End Sub

    Private Sub mnuErrorLog_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuErrorLog.Click
        ViewErrorLog()
    End Sub

    Private Sub ResultsContextMenu_Popup(ByVal sender As Object, ByVal e As System.EventArgs) Handles ResultsContextMenu.Popup
        ResultsContextMenu.MenuItems.Clear()
        If lvwItems.SelectedItems.Count = 1 Then
            Select Case CurrentMode
                Case "E", "D", "R"              ' Events
                    With ResultsContextMenu.MenuItems
                        .Add(mnuRunEvent)
                        .Add(mnuCtxOpen)
                        .Add(mnuDeleteEvent)
                        .Add(mnuNewEvent)
                        .Add(mnuCtxRefresh)
                    End With
                Case "S"                ' Scripts
                    With ResultsContextMenu.MenuItems
                        .Add(mnuCtxOpen)
                        .Add(mnuNewScript)
                        .Add(mnuDeleteScript)
                        .Add(mnuRefreshScripts)
                    End With
                Case "T"                ' Determinators
                    With ResultsContextMenu.MenuItems
                        .Add(mnuRunDeterminator)
                        .Add(mnuEditDeterminator)
                        .Add(mnuDuplicateDeterminator)
                        .Add(mnuDeleteDeterminator)
                        .Add(mnuExportDeterminator)
                        .Add(mnuNewDeterminatorRule)
                        .Add(mnuCtxRefresh)
                    End With
                Case "X"                ' X10 devices
                    With ResultsContextMenu.MenuItems
                        .Add(mnuCtxOpen)
                        .Add(mnuX10On)
                        .Add(mnuX10Off)
                        .Add(mnuX10StatusRequest)
                        .Add(MenuItem2)
                        .Add(mnuDeleteX10)
                        .Add(mnuX10NewDevice)
                        .Add(mnuRefreshX10)
                    End With
                Case "A"                ' xPL devices
                    HandleDeviceControl()
                    With ResultsContextMenu.MenuItems
                        If .Count > 0 Then
                            .Add(mnuBreak)
                        End If
                        .Add(mnuAllTasks)
                    End With
                Case "C"                ' Globals
                    With ResultsContextMenu.MenuItems
                        .Add(mnuNewGlobal)
                        .Add(mnuUpdateGlobal)
                        .Add(mnuDelGlobal)
                    End With
                    mnuUpdateGlobal.Enabled = True
            End Select
        End If
    End Sub

    Private Sub mnuNewScript_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuNewScript.Click
        Dim f As New frmEditScript
        f.IsNewScript = True
        If tvwNodes.SelectedNode Is Nothing Then
            f.ScriptName = DEFAULT_SCRIPT_NAME
        ElseIf tvwNodes.SelectedNode.Tag Is Nothing Then
            f.ScriptName = DEFAULT_SCRIPT_NAME
        ElseIf Not CStr(tvwNodes.SelectedNode.Tag).Substring(0, 1) = "S" Then
            f.ScriptName = DEFAULT_SCRIPT_NAME
        ElseIf CStr(tvwNodes.SelectedNode.Tag) = "SMessages" Then
            f.ScriptName = "Messages\NewMessage.txt"
        ElseIf CStr(tvwNodes.SelectedNode.Text) = "Powershell" Then
            f.ScriptName = CStr(tvwNodes.SelectedNode.Tag) & "\NewScript.ps1"
            f.ScriptName = f.ScriptName.Substring(1, f.ScriptName.Length - 1)
        ElseIf CStr(tvwNodes.SelectedNode.Text) = "Python" Then
            f.ScriptName = CStr(tvwNodes.SelectedNode.Tag) & "\NewScript.py"
            f.ScriptName = f.ScriptName.Substring(1, f.ScriptName.Length - 1)
        Else
            f.ScriptName = DEFAULT_SCRIPT_NAME
        End If
        f.Show()
    End Sub

    Private Sub mnuFileExit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileExit.Click
        Me.Close()
    End Sub

    Private Sub mnuHelpAbout_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuHelpAbout.Click
        SplashScreen = New frmSplash
        SplashScreen.ShowDialog()
    End Sub

    Private Sub GetX10()
        Dim str As String
        Dim params() As String, li As ListViewItem
        lvwItems.Items.Clear()
        ConnectToXplHal()
        xplHalSend("LISTX10STATES" & vbCrLf)
        str = GetLine()
        If str.StartsWith("292") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                params = str.Split(CChar(vbTab))
                li = New ListViewItem
                li.Text = params(1)
                li.SubItems.Add(params(0))
                li.SubItems.Add(GetX10Status(CInt(params(3))))
                lvwItems.Items.Add(li)
                str = GetLine()
            End While
        End If

    End Sub

    Private Sub EditX10()
        Dim f As New frmEditX10
        f.DeviceAddress = lvwItems.SelectedItems(0).SubItems(1).Text
        f.ShowDialog()
        GetX10()
    End Sub

    Private Sub lvwItems_KeyDown(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyEventArgs) Handles lvwItems.KeyDown
        If e.KeyData = 46 Then
            If lvwItems.SelectedItems.Count > 0 Then
                Select Case CurrentMode
                    Case "E", "D", "R"
                        DeleteEvent()
                    Case "C"     ' Globals
                        mnuDelGlobal_Click(Nothing, Nothing)
                    Case "S"
                        DeleteScript()
                    Case "X"
                        DeleteX10()
                    Case "T"
                        mnuDeleteDeterminator_Click(Nothing, Nothing)
                End Select
            End If
        End If
    End Sub

    Private Sub mnuDeleteDeterminator_Click(ByVal sender As Object, ByVal e As EventArgs) Handles mnuDeleteDeterminator.Click
        If MsgBox(My.Resources.RES_PROMPT_DEL_DETERMINATOR.Replace("%1", lvwItems.SelectedItems(0).Text) & "?", vbQuestion Or vbYesNo) = vbYes Then
            Dim str As String, prefix As String = CStr(lvwItems.SelectedItems(0).Tag)
            ConnectToXplHal()
            xplHalSend("DELRULE " & prefix & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("214") Then
                globals.Unexpected(str)
            Else
                lvwItems.SelectedItems(0).Remove()
            End If
        End If
    End Sub

    Private Sub DeleteScript()
        Dim ScriptName As String = lvwItems.SelectedItems(0).Text.ToUpper
        If ScriptName = "XPLHAL_LOAD.XPL" Then
            MsgBox(My.Resources.RES_CANNOT_DEL_SCRIPT, vbInformation)
            Exit Sub
        End If

        If MsgBox(My.Resources.RES_PROMPT_DEL_SCRIPT.Replace("%1", lvwItems.SelectedItems(0).Text) & "?", vbQuestion Or vbYesNo) = vbYes Then
            Dim str As String, prefix As String = CStr(tvwNodes.SelectedNode.Tag)
            ConnectToXplHal()
            str = lvwItems.SelectedItems(0).Text
            If prefix.Length > 1 Then
                str = prefix.Substring(1, prefix.Length - 1) & "\" & str
            End If
            xplHalSend("DELSCRIPT " & str & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("214") Then
                globals.Unexpected(str)
            Else
                lvwItems.SelectedItems(0).Remove()
            End If
        End If
    End Sub

    Private Sub mnuDeleteScript_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDeleteScript.Click
        If lvwItems.SelectedItems.Count = 1 Then
            DeleteScript()
        End If
    End Sub

    Private Sub mnuReloadScripts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuReloadScripts.Click
        ReloadScripts()
    End Sub

    Private Sub GetGlobals()
        Try
            Dim GlobalPrefix As String = tvwNodes.SelectedNode.Tag.ToString()
            If GlobalPrefix.Length > 1 Then
                GlobalPrefix = GlobalPrefix.Substring(1, GlobalPrefix.Length - 1)
            Else
                GlobalPrefix = ""
                tvwNodes.SelectedNode.Nodes.Clear()
            End If
            lvwItems.Items.Clear()
            Dim str, lhs, rhs As String
            Dim li As ListViewItem
            ConnectToXplHal()
            xplHalSend("LISTGLOBALS" & vbCrLf)
            str = GetLine()
            If str.StartsWith("231") Then
                str = GetLine()
                While str <> ("." & vbCrLf) And str <> ""
                    If str.IndexOf("=") > 1 Then
                        lhs = str.Substring(0, str.IndexOf("="))
                        rhs = Trim(str.Substring(str.IndexOf("=") + 1, str.Length - str.IndexOf("=") - 1).Replace(vbCrLf, ""))
                        If GlobalPrefix = "" And lhs.IndexOf("[") <= 0 Then
                            li = New ListViewItem
                            li.Text = lhs
                            li.Tag = lhs

                            Select Case lhs
                                Case "MODE"
                                    If IsNumeric(rhs) Then
                                        If globals.Modes.Length > CInt(rhs) Then
                                            li.SubItems.Add(globals.Modes(CInt(rhs)).Name)
                                        Else
                                            li.SubItems.Add(rhs)
                                        End If
                                    Else
                                        li.SubItems.Add(rhs)
                                    End If
                                Case "PERIOD"
                                    If IsNumeric(rhs) Then
                                        If globals.Periods.Length >= CInt(rhs) Then
                                            li.SubItems.Add(globals.Periods(CInt(rhs)).Name)
                                        Else
                                            li.SubItems.Add(rhs)
                                        End If
                                    Else
                                        li.SubItems.Add(rhs)
                                    End If
                                Case Else
                                    li.SubItems.Add(rhs)
                            End Select
                            lvwItems.Items.Add(li)
                        ElseIf GlobalPrefix = "" Then
                            Dim TN As TreeNode
                            TN = Nothing
                            Dim TreeText As String = lhs.Substring(0, lhs.IndexOf("["))
                            ' Find the treenode
                            For Each t As TreeNode In tvwNodes.SelectedNode.Nodes
                                If t.Text = TreeText Then
                                    TN = t
                                    Exit For
                                End If
                            Next
                            If TN Is Nothing Then
                                TN = New TreeNode
                                TN.Text = TreeText
                                TN.Tag = "C" & TreeText
                                tvwNodes.SelectedNode.Nodes.Add(TN)
                            End If
                            ' Look for the subnode
                            Dim tn2 As TreeNode
                            tn2 = Nothing
                            Dim TreeText2 As String
                            Try
                                TreeText2 = lhs.Substring(lhs.IndexOf("[") + 1, lhs.Length - lhs.IndexOf("[") - lhs.IndexOf(","))
                            Catch ex As Exception
                                TreeText2 = String.Empty
                                MsgBox("Invalid global: " & lhs)
                            End Try
                            For Each t As TreeNode In TN.Nodes
                                If t.Text = TreeText2 Then
                                    tn2 = t
                                End If
                            Next
                            If tn2 Is Nothing Then
                                tn2 = New TreeNode
                                tn2.Text = TreeText2
                                tn2.Tag = "C" & TreeText & "[" & TreeText2
                                TN.Nodes.Add(tn2)
                            End If
                        ElseIf lhs.IndexOf("[") > 0 Then
                            If lhs.StartsWith(GlobalPrefix) Then
                                li = New ListViewItem
                                li.Text = lhs.Substring(GlobalPrefix.Length, lhs.Length - GlobalPrefix.Length)
                                li.Text = li.Text.Replace(",", "").Replace("]", "").Replace("[", "")
                                li.Tag = lhs
                                li.SubItems.Add(rhs)
                                lvwItems.Items.Add(li)
                            End If

                        End If
                    Else
                        globals.Unexpected(str)
                        Exit While
                    End If
                    str = GetLine()
                End While
            Else
                globals.Unexpected(str)
            End If
        Catch ex As Exception
            Disconnect()
            MsgBox(ex.ToString())
        End Try
    End Sub

    Private Sub mnuX10On_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuX10On.Click
        SendX10(lvwItems.SelectedItems(0).SubItems(1).Text, "ON")
        lvwItems.SelectedItems(0).SubItems(2).Text = "ON"
    End Sub

    Private Sub mnuX10Off_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuX10Off.Click
        SendX10(lvwItems.SelectedItems(0).SubItems(1).Text, "OFF")
        lvwItems.SelectedItems(0).SubItems(2).Text = "OFF"
    End Sub

    Private Sub mnuX10NewDevice_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuX10NewDevice.Click
        Dim f As New frmEditX10
        f.DeviceAddress = ""
        f.ShowDialog()
        GetX10()
    End Sub

    Private Sub DeleteX10()
        Dim str As String
        If MsgBox("Are you sure you want to delete the selected X10 device(s)?", vbQuestion Or vbYesNo) = vbYes Then
            ConnectToXplHal()
            For Each li As ListViewItem In lvwItems.SelectedItems
                xplHalSend("DELX10DEVICE " & li.SubItems(1).Text & vbCrLf)
                str = GetLine()
                If str.StartsWith("228") Then
                    li.Remove()
                Else
                    globals.Unexpected(str)
                End If
            Next
        End If
    End Sub

    Private Sub DeleteEvent()
        Dim str As String
        If MsgBox("Are you sure you want to delete the selected event?", vbQuestion Or vbYesNo) = vbYes Then
            ConnectToXplHal()
            xplHalSend("DELEVENT " & lvwItems.SelectedItems(0).Text & vbCrLf)
            str = GetLine()
            If str.StartsWith("223") Then
                lvwItems.SelectedItems(0).Remove()
            Else
                globals.Unexpected(str)
            End If
        End If
    End Sub

    Private Sub mnuNewEvent_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuNewEvent.Click, mnuFileNewEvent.Click
        Dim f As New frmEventWizard
        f.ShowDialog()
        mnuCtxRefresh_Click(Nothing, Nothing)
    End Sub

    Private Sub GetXPLDevices(ByVal AwaitingConfig As Boolean)
        Dim str As String
        Dim li As ListViewItem
        Dim bits() As String
        lvwItems.SuspendLayout()
        lvwItems.Items.Clear()

        ConnectToXplHal()
        If AwaitingConfig Then
            xplHalSend("LISTDEVICES AWAITINGCONFIG" & vbCrLf)
        Else
            xplHalSend("LISTDEVICES CONFIGURED" & vbCrLf)
        End If
        str = GetLine()
        If str.StartsWith("216") Then
            str = GetLine()
            While Not str = ("." & vbCrLf) And Not str = ""
                bits = str.Split(CChar(vbTab))
                li = New ListViewItem
                str = str.Substring(0, str.IndexOf(vbTab))
                li.SubItems(0).Text = str.Substring(0, str.IndexOf("-"))
                li.SubItems.Add(str.Substring(str.IndexOf("-") + 1, str.IndexOf(".") - str.IndexOf("-") - 1))
                li.SubItems.Add(str.Substring(str.IndexOf(".") + 1, str.Length - str.IndexOf(".") - 1))
                bits(1) = bits(1).Substring(bits(1).IndexOf(" ") + 1, bits(1).Length - bits(1).IndexOf(" ") - 1)
                li.SubItems.Add(bits(1))
                li.Tag = str
                lvwItems.Items.Add(li)
                str = GetLine()
            End While
        End If
        lvwItems.ListViewItemSorter = New ListViewItemComparer(0, lvwItems.Sorting)
        lvwItems.Sort()
        lvwItems.ResumeLayout()
    End Sub

    Private Sub mnuProperties_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuProperties.Click, mnuFileProperties.Click
        Dim f As New frmProperties
        f.ShowDialog()
    End Sub

    Private Sub mnuConnect_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuConnect.Click
        ChooseServer()
    End Sub


    Private Sub tvwNodes_MouseDown(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles tvwNodes.MouseDown
        If e.Button = Windows.Forms.MouseButtons.Right Then

            tvwNodes.SelectedNode = tvwNodes.GetNodeAt(e.X, e.Y)

        End If
    End Sub

    Private Sub RestartXplHal()
        Disconnect()
        Dim f As New frmRestartService
        f.ShowDialog()
    End Sub

    Private Sub mnuRestart_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuRestart.Click
        If MsgBox("Are you sure you want to restart the xPLHal service on " & globals.xPLHalServer & "?", vbQuestion Or vbYesNo) = vbYes Then
            RestartXplHal()
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
            Try
                Dim ReturnVal As Integer
                Select Case CurrentMode
                    Case "A", "B"     ' xPL devices - so sort them differently
                        Dim i1 As ListViewItem = CType(x, ListViewItem)
                        Dim i2 As ListViewItem = CType(y, ListViewItem)
                        If col = 0 Then
                            ' Sort by VDI
                            ReturnVal = [String].Compare(i1.Tag.ToString, i2.Tag.ToString)
                        Else
                            ' Just sort one column
                            ReturnVal = [String].Compare(CType(x, ListViewItem).SubItems(col).Text, CType(y, ListViewItem).SubItems(col).Text)
                        End If
                    Case Else
                        If IsNumeric(CType(x, ListViewItem).SubItems(col).Text) And IsNumeric(CType(y, ListViewItem).SubItems(col).Text) Then
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
                End Select
                If Order = SortOrder.Descending Then
                    ReturnVal *= -1
                End If
                Return ReturnVal
            Catch ex As Exception
                col = 0
            End Try
        End Function

    End Class

    Private Sub lvwItems_ColumnClick(ByVal sender As Object, ByVal e As System.Windows.Forms.ColumnClickEventArgs) Handles lvwItems.ColumnClick
        Static OldCol As Integer

        If OldCol = e.Column Then
            Select Case lvwItems.Sorting
                Case SortOrder.Ascending
                    lvwItems.Sorting = SortOrder.Descending
                Case SortOrder.Descending
                    lvwItems.Sorting = SortOrder.Ascending
                Case SortOrder.None
                    lvwItems.Sorting = SortOrder.Ascending
            End Select
        Else
            lvwItems.Sorting = SortOrder.Ascending
        End If
        OldCol = e.Column
        lvwItems.ListViewItemSorter = New ListViewItemComparer(e.Column, lvwItems.Sorting)
        lvwItems.Sort()
    End Sub

    Private Sub GetSingleEvents(Optional ByVal ClearList As Boolean = True)
        Dim str As String
        Dim params() As String
        Dim li As ListViewItem
        If ClearList Then
            lvwItems.Items.Clear()
        End If
        ConnectToXplHal()
        xplHalSend("LISTSINGLEEVENTS" & vbCrLf)
        str = GetLine()
        If str.StartsWith("218") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                params = str.Split(CChar(vbTab))
                li = New ListViewItem
                li.Text = params(0)
                If CStr(tvwNodes.SelectedNode.Tag).StartsWith("E") Then
                    li.SubItems.Add("Single")
                End If
                If params(1) = "{determinator}" Then
                    li.SubItems.Add(params(2))
                    li.ImageIndex = 6
                Else
                    li.SubItems.Add(params(1))
                    li.ImageIndex = 1
                End If

                'If Not CStr(tvwNodes.SelectedNode.Tag).StartsWith("E") Then
                li.SubItems.Add(params(3))
                'End If

                lvwItems.Items.Add(li)
                str = GetLine()
            End While
        Else
            globals.Unexpected(str)
        End If
    End Sub

    Private Sub mnuEditEvent_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditEvent.Click
        EditEvent()
    End Sub

    Private Sub ConfigureDevice(ByVal firstConfig As Boolean)
        Try
            Windows.Forms.Cursor.Current = Cursors.WaitCursor
            Dim f As New frmConfigureDevice
            f.FirstConfig = firstConfig
            f.DevName = CStr(lvwItems.SelectedItems(0).Tag)
            If Not f.DevName = "" Then
                If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
                    mnuViewRefresh_Click(Nothing, Nothing)
                End If
            End If
        Catch ex As Exception
            Windows.Forms.Cursor.Current = Cursors.Default
            MsgBox("Unable to configure this device." & vbCrLf & vbCrLf & ex.ToString(), vbCritical)
        End Try
    End Sub

    Private Sub mnuDeleteEvent_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDeleteEvent.Click
        DeleteEvent()
    End Sub

    Private Sub mnuRefreshScripts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuRefreshScripts.Click
        GetScripts(CStr(tvwNodes.SelectedNode.Tag), tvwNodes.SelectedNode)
    End Sub

    Private Sub mnuCtxRefresh_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuCtxRefresh.Click
        mnuViewRefresh_Click(Nothing, Nothing)
    End Sub

    Private Sub frmMain_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
        'SetlvwSettings(lvwItems, Me.Name)
        If Me.OwnedForms.Length > 0 Then
            MsgBox("Close all sub forms before exiting the application.", MsgBoxStyle.OkOnly, "Close all forms.")
            e.Cancel = True
        Else
            SetFormSettings(Me)
            If globals.NeedToReloadScripts Then
                Select Case MsgBox(My.Resources.RES_RELOAD_NOW.Replace("\n", vbCrLf), vbQuestion Or vbYesNo)
                    Case vbCancel
                        e.Cancel = True
                    Case vbYes
                        mnuReloadScripts_Click(Nothing, Nothing)
                End Select
            End If
        End If
    End Sub

	Private Sub mnuRefreshX10_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuRefreshX10.Click
		GetX10()
	End Sub

	Private Sub mnuHelpTopics_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuHelpTopics.Click
		Help.ShowHelp(Me, "xplhal.chm")
	End Sub


	Private Sub mnuFileRunSub_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileRunSub.Click
		Dim f As New frmRunSub
		f.ShowDialog()
	End Sub

	Private Sub mnuRunEvent_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuRunEvent.Click
		' Executes the currently selected event
		Dim str, subname As String
    subname = ""
		Select Case CurrentMode
			Case "D", "R"
				subname = lvwItems.SelectedItems(0).SubItems(1).Text
			Case "E"
				subname = lvwItems.SelectedItems(0).SubItems(2).Text
		End Select
		ConnectToXplHal()
		If lvwItems.SelectedItems(0).ImageIndex = 1 Then
			xplHalSend("RUNSUB " & subname & vbCrLf)
			str = GetLine()
		Else
			' Get the GUID of the determinator
			xplHalSend("LISTRULES {ALL}" & vbCrLf)
			str = GetLine()
			If Not str.StartsWith("237") Then
				globals.Unexpected(str)
				Return
			End If
			Dim Bits() As String
			str = GetLine()
			While Not str = String.Empty And Not str = "." And Not str = "." & vbCrLf
				Bits = str.Split(CChar(vbTab))
				If Bits(1).ToLower() = subname.ToLower() Then
					subname = Bits(0)
				End If
				str = GetLine()
			End While
			xplHalSend("RUNRULE " & subname & vbCrLf)
			str = GetLine()
		End If
		' If a single event, delete it
		If CurrentMode = "D" Then
			xplHalSend("DELEVENT " & lvwItems.SelectedItems(0).Text & vbCrLf)
			str = GetLine()
			MsgBox(str)
		End If
	End Sub

	Private Sub mnuX10StatusRequest_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuX10StatusRequest.Click
		SendX10(lvwItems.SelectedItems(0).SubItems(1).Text, "STATUS")
		GetX10()
	End Sub



	Private Sub mnuToolsSendXplMsg_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuToolsSendXplMsg.Click
		Dim f As New frmSendRawXPL
		f.Show()
	End Sub


	Private Sub HandleDeviceControl()
		Dim device As String = CStr(lvwItems.SelectedItems(0).Tag)

		If device.IndexOf("-") < device.IndexOf(".") Then
			device = device.Substring(0, device.IndexOf("."))
			' Loop through all plugins
			For Counter As Integer = 0 To globals.Plugins.Length - 1
				If device = globals.Plugins(Counter).DeviceID Then
					Dim P As globals.Plugin = globals.Plugins(Counter)
					For Counter2 As Integer = 0 To P.MenuItems.Length - 1
						ResultsContextMenu.MenuItems.Add(P.MenuItems(Counter2).mi)
					Next
					If P.InfoUrl <> String.Empty Then
						mnuMoreInfo.Enabled = True
					Else
						mnuMoreInfo.Enabled = False
					End If
					Exit For
				End If
			Next
		End If
	End Sub

	Private Sub HandlePluginMenuItem(ByVal sender As Object, ByVal e As System.EventArgs)
		' Determine which menu item raised the event
		Dim Counter, Counter2 As Integer
		Dim SenderItem As MenuItem = CType(sender, MenuItem)
		For Counter = 0 To globals.Plugins.Length - 1
			For Counter2 = 0 To globals.Plugins(Counter).MenuItems.Length - 1
				If SenderItem Is globals.Plugins(Counter).MenuItems(Counter2).mi Then
					HandlePluginXplMsg(globals.Plugins(Counter).MenuItems(Counter2).xplMsg)
					Exit For
				End If
			Next
		Next
	End Sub

	Private Sub mnuNewGlobal_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuNewGlobal.Click
		Dim globalName As String = InputBox("Enter the name of the global variable to be created:")
		If globalName.Length > 0 Then
			Dim globalValue As String = InputBox("Enter the initial value of the global variable:", "New Global")
			Dim str As String
			ConnectToXplHal()
			xplHalSend("SETGLOBAL " & globalName & " " & globalValue & vbCrLf)
			str = GetLine()
			If Not str.StartsWith("232") Then
				globals.Unexpected(str)
			Else
				GetGlobals()
			End If
		End If
	End Sub

	Private Sub mnuUpdateGlobal_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuUpdateGlobal.Click
		If lvwItems.SelectedItems.Count = 1 Then
			Dim str As String
			If lvwItems.SelectedItems(0).Text = "MODE" Or lvwItems.SelectedItems(0).Text = "PERIOD" Then
				Dim f As New frmChangeStuff
				Dim globalName As String, globalValue As String
				f.SettingName = lvwItems.SelectedItems(0).Text
				f.SettingValue = lvwItems.SelectedItems(0).SubItems(1).Text
				globalName = f.SettingName
				If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
					globalValue = f.cmbStuffToChange.Text
					xplHalSend("SETSETTING " & globalName & " " & globalValue & vbCrLf)
					str = GetLine()
					If Not str.StartsWith("206") Then
						globals.Unexpected(str)
					Else
						GetGlobals()
					End If
				End If
			Else
				Dim globalName As String = lvwItems.SelectedItems(0).Tag.ToString()
				Dim globalValue As String = InputBox("Enter the new value for the global variable " & globalName & ":", "Set Global Value", lvwItems.SelectedItems(0).SubItems(1).Text)
				If Not globalValue = "" Then
					xplHalSend("SETGLOBAL " & globalName & " " & globalValue & vbCrLf)
					str = GetLine()
					If Not str.StartsWith("232") Then
						globals.Unexpected(str)
					Else
						GetGlobals()
					End If
				End If
			End If
		End If
	End Sub

  Private Sub mnuDelGlobal_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDelGlobal.Click
    If lvwItems.SelectedItems.Count = 1 Then
      Dim globalName As String = lvwItems.SelectedItems(0).Text
      If MsgBox("Are you sure you want to delete the global variable " & globalName & "?", vbYesNo Or vbQuestion) = vbYes Then
        xplHalSend("DELGLOBAL " & globalName & vbCrLf)
        Dim str As String = getLine
        If Not str.StartsWith("233") Then
          globals.Unexpected(str)
        Else
          GetGlobals()
        End If
      End If
    End If
  End Sub

  Private Sub mnuCtxOpen_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuCtxOpen.Click
    lvwItems_DoubleClick(Nothing, Nothing)
  End Sub

  Private Sub mnuDeleteX10_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDeleteX10.Click
    DeleteX10()
  End Sub

  Private Sub mnuViewRefresh_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuViewRefresh.Click
    Select Case CurrentMode
      Case "A"   ' Configured devices
        GetXPLDevices(False)
      Case "B"   ' Devices awaiting configuration
        GetXPLDevices(True)
      Case "C"   ' Globals
        GetGlobals()
      Case "R"
        GetEvents()
      Case "E"
        GetEvents()
        GetSingleEvents(False)
      Case "D"
        GetSingleEvents()
      Case "S"   ' Scripts
        AddScriptingFolders(Nothing)
        GetScripts(CStr(tvwNodes.SelectedNode.Tag), tvwNodes.SelectedNode)
      Case "T"   ' Determinator
        PopulateDeterminatorRules()
      Case "X"   ' X10 devices
        GetX10()
    End Select
  End Sub

  Private Sub rtbSplash_LinkClicked(ByVal sender As Object, ByVal e As System.Windows.Forms.LinkClickedEventArgs) Handles rtbSplash.LinkClicked
    ShellExecute(0, "Open", e.LinkText, "", "", 0)
  End Sub

  Private Sub mnuHelpCheckForUpdates_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuHelpCheckForUpdates.Click
    Try
      Dim LatestMajor, LatestMinor, LatestRevision, LatestBuild As Integer
      Dim CurrentMajor, CurrentMinor, CurrentRevision, CurrentBuild As Integer
      Dim ProductDescription As String, ReleaseDate As Date, moreInfoUrl As String
      Dim xml As New XmlTextReader("http://www.xpl.myby.co.uk/support/xplhalweb/xplhal.xml")
      Dim CurrentComponent As Boolean = False
			LatestMajor = 0
      ProductDescription = ""
      moreInfoUrl = ""

      While xml.Read
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "xplHalMgr"
                CurrentComponent = True
              Case "versionInfo"
                If CurrentComponent Then
                  LatestMajor = CInt(xml.GetAttribute("major"))
                  LatestMinor = CInt(xml.GetAttribute("minor"))
                  LatestRevision = CInt(xml.GetAttribute("revision"))
                  LatestBuild = CInt(xml.GetAttribute("build"))
                End If
              Case "moreInfoUrl"
                xml.Read()
                If CurrentComponent Then
                  moreInfoUrl = xml.Value
                End If
              Case "description"
                xml.Read()
                If CurrentComponent Then
                  ProductDescription = xml.Value.Replace("\n", vbCrLf)
                End If
              Case "releaseDate"
                xml.Read()
                If CurrentComponent Then
                  ReleaseDate = CDate(xml.Value)
                End If
              Case Else

                CurrentComponent = False

            End Select
        End Select
      End While
      xml.Close()

      If LatestMajor = 0 Then
        MsgBox("xPLHal Manager was unable to check for an updated version at this time." & vbCrLf & vbCrLf & "Please try again later.", vbExclamation)
        Exit Sub
      End If
      With System.Reflection.Assembly.GetExecutingAssembly.GetName.Version
        CurrentMajor = .Major
        CurrentMinor = .Minor
        CurrentBuild = .Build
        CurrentRevision = .Revision
      End With

      Dim s As String
      If (LatestRevision > CurrentRevision And LatestBuild = CurrentBuild) Or (LatestBuild > CurrentBuild) Then
        s = "A newer version of the xPLHal Manager is now available for download." & vbCrLf & vbCrLf
        s &= ProductDescription & vbCrLf & vbCrLf
        s &= "Current Version: " & CurrentMajor & "." & CurrentMinor & "." & CurrentBuild & "." & CurrentRevision & vbCrLf
        s &= "Latest Version: " & LatestMajor & "." & LatestMinor & "." & LatestBuild & "." & LatestRevision & vbCrLf & "Release Date: " & ReleaseDate.ToString("dd MMMM yyyy") & vbCrLf & vbCrLf
        s &= "Would you like to download the update now?"
        If MsgBox(s, vbYesNo Or vbQuestion) = MsgBoxResult.Yes Then
          ShellExecute(0, "Open", moreInfoUrl, "", "", 0)
        End If
      Else
        s = "No updates to the xPLHal Manager are currently available for download."
        MsgBox(s, vbInformation)
      End If
    Catch ex As Exception
      MsgBox("xPLHal Manager could not check for updated components at this time." & vbCrLf & vbCrLf & "Please make sure you are connected to the Internet and try again.", vbExclamation)
    End Try
  End Sub

  Private Sub LoadPlugins()
    ReDim globals.Plugins(-1)
    Dim files() As String
    Directory.CreateDirectory(globals.PluginsPath)

    files = Directory.GetFiles(globals.PluginsPath)
    If files.Length = 0 Then
      MsgBox("xPLHal Manager could not find any vendor plug-in files on your computer." & vbCrLf & vbCrLf & "If this is the first time you have used xPLHal Manager, please use the Update Plug-in Library option on the Help menu to download all the latest vendor plug-in files.", vbInformation)
    Else
      For Counter As Integer = 0 To files.Length - 1
        LoadPlugin(files(Counter))
      Next
    End If
  End Sub

  Private Sub LoadPlugin(ByVal filename As String)
    Dim xml As XmlTextReader
    xml = Nothing
    Dim VendorInfoUrl As String
    VendorInfoUrl = ""

    Try
      xml = New XmlTextReader(filename)
      Dim currentPlugin As globals.Plugin
      Dim Mode As Integer = 0
      currentPlugin = Nothing

      While xml.Read
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "xpl-plugin"
                VendorInfoUrl = xml.GetAttribute("info_url")
              Case "device"
                ' Add a new plugin device
                If Not currentPlugin Is Nothing Then
                  SavePlugin(currentPlugin)
                End If
                currentPlugin = New globals.Plugin
                With currentPlugin
                  .DeviceID = xml.GetAttribute("id").ToUpper
                  .InfoUrl = xml.GetAttribute("info_url")
                  If .InfoUrl = String.Empty Then
                    .InfoUrl = VendorInfoUrl
                  End If
                End With
              Case "command"
                Mode = 2
                ReDim Preserve currentPlugin.Commands(currentPlugin.Commands.Length)
                currentPlugin.Commands(currentPlugin.Commands.Length - 1) = New globals.Plugin.Trigger
                With currentPlugin.Commands(currentPlugin.Commands.Length - 1)
                  .Name = xml.GetAttribute("name")
                  .Description = xml.GetAttribute("description")
                  .msg_type = xml.GetAttribute("msg_type")
                  .msg_schema = xml.GetAttribute("msg_schema")
                End With
              Case "trigger"
                Mode = 1
                ReDim Preserve currentPlugin.Triggers(currentPlugin.Triggers.Length)
                currentPlugin.Triggers(currentPlugin.Triggers.Length - 1) = New globals.Plugin.Trigger
                With currentPlugin.Triggers(currentPlugin.Triggers.Length - 1)
                  .Name = xml.GetAttribute("name")
                  .Description = xml.GetAttribute("description")
                  .msg_type = xml.GetAttribute("msg_type")
                  .msg_schema = xml.GetAttribute("msg_schema")
                End With
              Case "element"
                Select Case Mode
                  Case 1        ' Trigger
                    Dim t As globals.Plugin.Trigger = currentPlugin.Triggers(currentPlugin.Triggers.Length - 1)
                    ReDim Preserve t.elements(t.elements.Length)
                    t.elements(t.elements.Length - 1) = New globals.Plugin.TriggerElement
                    With t.elements(t.elements.Length - 1)
                      .Name = xml.GetAttribute("name")
                      .ControlType = xml.GetAttribute("control_type")
                      .DefaultValue = xml.GetAttribute("default")
                      .Label = xml.GetAttribute("label")
                      .ConditionalVisibility = xml.GetAttribute("conditional-visibility")
                      .MaxVal = xml.GetAttribute("maxval")
                      .MinVal = xml.GetAttribute("minval")
                    End With
                  Case 2        ' Command
                    Dim t As globals.Plugin.Trigger = currentPlugin.Commands(currentPlugin.Commands.Length - 1)
                    ReDim Preserve t.elements(t.elements.Length)
                    t.elements(t.elements.Length - 1) = New globals.Plugin.TriggerElement
                    With t.elements(t.elements.Length - 1)
                      .Name = xml.GetAttribute("name")
                      .ControlType = xml.GetAttribute("control_type")
                      .MinVal = xml.GetAttribute("minval")
                      .MaxVal = xml.GetAttribute("maxval")
                      .DefaultValue = xml.GetAttribute("default")
                      .Label = xml.GetAttribute("label")
                      .ConditionalVisibility = xml.GetAttribute("conditional-visibility")
                    End With
                End Select
              Case "option"
                Select Case Mode
                  Case 1        ' Trigger
                    Dim e As globals.Plugin.TriggerElement = currentPlugin.Triggers(currentPlugin.Triggers.Length - 1).elements(currentPlugin.Triggers(currentPlugin.Triggers.Length - 1).elements.Length - 1)
                    ReDim Preserve e.Choices(e.Choices.Length)
                    e.Choices(e.Choices.Length - 1) = New globals.Plugin.TriggerChoice
                    e.Choices(e.Choices.Length - 1).Label = xml.GetAttribute("label")
                    e.Choices(e.Choices.Length - 1).Value = xml.GetAttribute("value")
                  Case 2        ' Command
                    Dim e As globals.Plugin.TriggerElement = currentPlugin.Commands(currentPlugin.Commands.Length - 1).elements(currentPlugin.Commands(currentPlugin.Commands.Length - 1).elements.Length - 1)
                    ReDim Preserve e.Choices(e.Choices.Length)
                    e.Choices(e.Choices.Length - 1) = New globals.Plugin.TriggerChoice
                    e.Choices(e.Choices.Length - 1).Label = xml.GetAttribute("label")
                    e.Choices(e.Choices.Length - 1).Value = xml.GetAttribute("value")
                End Select
              Case "regexp"
                xml.Read()
                Select Case Mode
                  Case 1        ' Trigger
                    currentPlugin.Triggers(currentPlugin.Triggers.Length - 1).elements(currentPlugin.Triggers(currentPlugin.Triggers.Length - 1).elements.Length - 1).RegExp = xml.Value
                  Case 2        ' Command
                    currentPlugin.Commands(currentPlugin.Commands.Length - 1).elements(currentPlugin.Commands(currentPlugin.Commands.Length - 1).elements.Length - 1).RegExp = xml.Value
                End Select
              Case "configItem"
                ReDim Preserve currentPlugin.ConfigItems(currentPlugin.ConfigItems.Length)
                currentPlugin.ConfigItems(currentPlugin.ConfigItems.Length - 1) = New Plugin.pluginConfigItem

                With currentPlugin.ConfigItems(currentPlugin.ConfigItems.Length - 1)
                  .Name = xml.GetAttribute("name")
                  .FormatRegEx = xml.GetAttribute("format")
                  .Description = xml.GetAttribute("description")
                End With
              Case "menuItem"
                ReDim Preserve currentPlugin.MenuItems(currentPlugin.MenuItems.Length)
                currentPlugin.MenuItems(currentPlugin.MenuItems.Length - 1) = New globals.Plugin.pluginMenuItem(xml.GetAttribute("name"))
                AddHandler currentPlugin.MenuItems(currentPlugin.MenuItems.Length - 1).mi.Click, AddressOf HandlePluginMenuItem
              Case "xplMsg"
                xml.Read()
                currentPlugin.MenuItems(currentPlugin.MenuItems.Length - 1).xplMsg = xml.Value.Trim
              Case "sbw-function"
                ReDim Preserve currentPlugin.Functions(currentPlugin.Functions.Length)
                currentPlugin.Functions(currentPlugin.Functions.Length - 1) = New globals.Plugin.pluginFunction
                With currentPlugin.Functions(currentPlugin.Functions.Length - 1)
                  .fName = xml.GetAttribute("name")
                  .Item1Text = xml.GetAttribute("item1text")
                  .Item1Type = xml.GetAttribute("item1type")
                  .Item1Val = xml.GetAttribute("item1value")
                  .Item1DS = xml.GetAttribute("item1datasource")
                  .Item2Text = xml.GetAttribute("item2text")
                  .Item2Type = xml.GetAttribute("item2type")
                  .Item2Val = xml.GetAttribute("item2value")
                  .Item2DS = xml.GetAttribute("item2datasource")
                  .Item3Text = xml.GetAttribute("item3text")
                  .item3type = xml.GetAttribute("item3type")
                  .Item3Val = xml.GetAttribute("item3value")
                  .item3ds = xml.GetAttribute("item3datasource")
                  .Item4Text = xml.GetAttribute("item4text")
                  .item4type = xml.GetAttribute("item4type")
                  .item4val = xml.GetAttribute("item4value")
                  .item4ds = xml.GetAttribute("item4datasource")
                  .DisplayText = xml.GetAttribute("displaytext")
                  .CodeText = xml.GetAttribute("code")
                End With
              Case "xplSchemaCollection"
                ReDim globals.xplSchemaCollection(-1)
              Case "xplSchema"
                ReDim Preserve globals.xplSchemaCollection(globals.xplSchemaCollection.Length)
                globals.xplSchemaCollection(globals.xplSchemaCollection.Length - 1) = New globals.xplSchema
              Case "name"
                xml.Read()
                globals.xplSchemaCollection(globals.xplSchemaCollection.Length - 1).Name = xml.Value
            End Select
        End Select
      End While
      If Not currentPlugin Is Nothing Then
        SavePlugin(currentPlugin)
      End If
    Catch ex As Exception
      MsgBox("Unable to load plug-in library " & filename & "." & vbCrLf & vbCrLf & "The library may be corrupt or contain errors." & vbCrLf & vbCrLf & "The specific error details are:" & vbCrLf & ex.Message, vbExclamation)
    Finally
      If Not xml Is Nothing Then
        xml.Close()
      End If
    End Try
  End Sub

  Private Sub SavePlugin(ByVal p As globals.Plugin)
    ReDim Preserve globals.Plugins(globals.Plugins.Length)
    globals.Plugins(globals.Plugins.Length - 1) = p
  End Sub

  Private Sub HandlePluginXplMsg(ByVal xplMsg As String)
    Dim lhs, rhs, promptText, promptValue As String
    While xplMsg.IndexOf("%") > 0
      lhs = xplMsg.Substring(0, xplMsg.IndexOf("%"))
      xplMsg = xplMsg.Substring(xplMsg.IndexOf("%") + 1, xplMsg.Length - xplMsg.IndexOf("%") - 1)
      rhs = xplMsg.Substring(xplMsg.IndexOf("%") + 1, xplMsg.Length - xplMsg.IndexOf("%") - 1)
      promptText = xplMsg.Substring(0, xplMsg.IndexOf("%"))
      If promptText.IndexOf("|") > 0 Then
        Dim f As New frmChangeStuff

        Dim values() As String = promptText.Split(CChar("|"))
        For COunter3 As Integer = 0 To values.Length - 1
          f.cmbStuffToChange.Items.Add(values(COunter3))
        Next
        f.SettingName = ""
        Dim s As String = Microsoft.VisualBasic.Right(lhs, lhs.Length - lhs.LastIndexOf(vbCrLf) - 2)
        s = s.Replace("=", "")
        f.Text = "Select " & s
        If f.ShowDialog = Windows.Forms.DialogResult.OK Then
          promptValue = f.cmbStuffToChange.Text
        Else
          Exit Sub
        End If
      Else
        promptValue = InputBox(promptText, "xPLHal Manager")
      End If

      promptValue = promptValue.Replace("%", "&percent;")
      xplMsg = lhs & promptValue & rhs
    End While
    xplMsg = xplMsg.Replace("&percent;", "%")
    SendXplMsg("xpl-cmnd", CStr(lvwItems.SelectedItems(0).Tag), xplMsg)
  End Sub

  Private Sub mnuHelpUpdatePlugins_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuHelpUpdatePlugins.Click
    Try
      Dim f As New frmUpdatePlugIn
      f.ShowDialog()
      LoadPlugins()
    Catch ex As Exception
      MsgBox("Error: " & ex.Message, vbCritical)
    End Try
  End Sub

  Private Sub mnuDelConfig_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDelConfig.Click
    Dim str As String
    ConnectToXplHal()
    xplHalSend("DELDEVCONFIG " & lvwItems.SelectedItems(0).Tag.ToString & vbCrLf)
    str = GetLine()
    If Not str.StartsWith("235") Then
      globals.Unexpected(str)
    End If
    Disconnect()
  End Sub

  Private Sub InitResources()
        mnuFile.Text = My.Resources.RES_FILE
        mnuFileNew.Text = My.Resources.RES_NEW
        mnuFileNewEvent.Text = My.Resources.RES_EVENT
        mnuRestart.Text = My.Resources.RES_RESTART
        mnuConnect.Text = My.Resources.RES_CHANGE_SERVER
        mnuNewDeterminatorRule.Text = My.Resources.RES_NEW_RULE
        mnuFileExit.Text = My.Resources.RES_EXIT
        mnuView.Text = My.Resources.RES_VIEW
        mnuViewRefresh.Text = My.Resources.RES_REFRESH
        mnuTools.Text = My.Resources.RES_TOOLS
        mnuFileRunSub.Text = My.Resources.RES_RUN_SUB
        mnuToolsSendXplMsg.Text = My.Resources.RES_SEND_XPL
        mnuHelp.Text = My.Resources.RES_HELP
        mnuHelpTopics.Text = My.Resources.RES_HELP_TOPICS
        mnuHelpCheckForUpdates.Text = My.Resources.RES_CHECK_UPDATES
        mnuHelpUpdatePlugins.Text = My.Resources.RES_UPDATE_PLUGINS
        mnuLanguage.Text = My.Resources.RES_SELECT_LANGUAGE
        mnuHelpAbout.Text = My.Resources.RES_ABOUT
        mnuNewGlobal.Text = My.Resources.RES_NEW_GLOBAL
        mnuRefreshScripts.Text = My.Resources.RES_REFRESH
        mnuCtxRefresh.Text = My.Resources.RES_REFRESH
        mnuRefreshX10.Text = My.Resources.RES_REFRESH
        mnuProperties.Text = My.Resources.RES_PROPERTIES
        mnuErrorLog.Text = My.Resources.RES_VIEW_ERROR
        mnuEditXML.Text = My.Resources.RES_EDIT_CONFIG
        mnuReloadScripts.Text = My.Resources.RES_RELOAD
        mnuFileReloadScripts.Text = My.Resources.RES_RELOAD
        mnuX10NewDevice.Text = My.Resources.RES_NEW_X10
        mnuViewScript.Text = My.Resources.RES_VIEW_SCRIPT
        mnuDelConfig.Text = My.Resources.RES_DEL_CONFIG
        mnuConfigure.Text = My.Resources.RES_CONFIG
        mnuEditDeterminator.Text = My.Resources.RES_EDIT

        ToolBar1.Buttons(0).ToolTipText = My.Resources.RES_TOOLBAR_NEW
        ToolBar1.Buttons(1).ToolTipText = My.Resources.RES_TOOLBAR_CHANGESERVER
        ToolBar1.Buttons(2).ToolTipText = My.Resources.RES_TOOLBAR_SENDXPL
        ToolBar1.Buttons(4).ToolTipText = My.Resources.RES_TOOLBAR_RELOAD
        ToolBar1.Buttons(5).ToolTipText = My.Resources.RES_TOOLBAR_RUNSUB
        ToolBar1.Buttons(6).ToolTipText = My.Resources.RES_TOOLBAR_RUNDET
        ToolBar1.Buttons(7).ToolTipText = My.Resources.RES_TOOLBAR_REFRESH
        ToolBar1.Buttons(8).ToolTipText = My.Resources.RES_TOOLBAR_MONITOR
        ToolBar1.Buttons(10).ToolTipText = My.Resources.RES_TOOLBAR_HELP
        ToolBar1.Buttons(11).ToolTipText = My.Resources.RES_TOOLBAR_ABOUT
        ToolBar1.Buttons(13).ToolTipText = My.Resources.RES_TOOLBAR_X10ON
        ToolBar1.Buttons(14).ToolTipText = My.Resources.RES_TOOLBAR_X10OFF

  End Sub

  Private Sub mnuConfigure_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuConfigure.Click
    lvwItems_DoubleClick(Nothing, Nothing)
  End Sub


  Private Sub mnuLanguage_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuLanguage.Click
    Dim f As New frmSelectLanguage
    f.ShowDialog()
  End Sub

  Private Sub mnuFileReloadScripts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileReloadScripts.Click
    ReloadScripts()
  End Sub

  Private Sub PopulateDeterminatorRules()
    Try
      lvwItems.SuspendLayout()
      lvwItems.Items.Clear()
      Dim str As String
      Dim ruleinfo() As String
      Dim li As ListViewItem
      ConnectToXplHal()
      Dim bits() As String = tvwNodes.SelectedNode.Tag.ToString().Split(CChar(vbTab))
      If bits.Length > 1 Then
        xplHalSend("LISTRULES " & bits(1) & vbCrLf)
      Else
        xplHalSend("LISTRULES" & vbCrLf)
      End If
      str = GetLine()
      If str.StartsWith("237") Then
        str = GetLine()
        While Not str = ("." & vbCrLf)
          ruleinfo = str.Replace(vbCrLf, "").Split(CChar(vbTab))
          li = New ListViewItem
          li.Text = ruleinfo(1)
          li.Tag = ruleinfo(0)
          If ruleinfo.Length > 2 Then
            If ruleinfo(2) = "Y" Then
              li.ImageIndex = 6   ' determinator is enabled
            Else
              li.ImageIndex = 10     ' determinator is enabled
            End If

          Else
            li.ImageIndex = 6
          End If
          lvwItems.Items.Add(li)
          str = GetLine()
        End While
      End If
      lvwItems.ResumeLayout()
    Catch ex As Exception
      MsgBox(ex.ToString, vbCritical)
    Finally
      Disconnect()
    End Try
  End Sub

  Private Sub mnuNewDeterminatorRule_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuNewDeterminatorRule.Click
    Dim f As New frmDeterminatorWizard
    Dim bits() As String = tvwNodes.SelectedNode.Tag.ToString().Split(CChar(vbTab))
    If bits.Length > 1 Then
      f.Group = bits(1)
    Else
      f.Group = ""
    End If
    f.Show()
  End Sub

  Private Sub EditDeterminator()
    'Try
    Dim f As New frmDeterminator
    Dim ruleText As String, str As String
    ConnectToXplHal()
    xplHalSend("GETRULE " & CStr(lvwItems.SelectedItems(0).Tag) & vbCrLf)
    str = GetLine()
    If str.StartsWith("210") Then
      ruleText = ""
      str = GetLine()
      While Not str = ("." & vbCrLf)
        ruleText &= str
        str = GetLine()
      End While
      f.myRuleGuid = CStr(lvwItems.SelectedItems(0).Tag)
      f.myRule = New DeterminatorRule(ruleText)
      f.Show()
    Else
      globals.Unexpected(str)
    End If
    'Catch ex As Exception
    'MsgBox("This determinator could not be edited." & vbCrLf & vbCrLf & ex.Message, vbCritical)
    'End Try
  End Sub

  Private Sub SetListviewForXplDevices()
    lvwItems.Columns.Clear()
        lvwItems.Columns.Add(My.Resources.RES_VENDOR, 120, HorizontalAlignment.Left)
        lvwItems.Columns.Add(My.Resources.RES_DEVICE, 120, HorizontalAlignment.Left)
        lvwItems.Columns.Add(My.Resources.RES_INSTANCE, 120, HorizontalAlignment.Left)
        lvwItems.Columns.Add(My.Resources.RES_EXPIRES, 120, HorizontalAlignment.Left)
  End Sub

  Private Sub ToolBar1_ButtonClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.ToolBarButtonClickEventArgs) Handles ToolBar1.ButtonClick
    Select Case LCase(e.Button.Tag.ToString)
      Case "sendxpl"
        mnuToolsSendXplMsg_Click(Nothing, Nothing)
      Case "changeserver"
        mnuConnect_Click(Nothing, Nothing)
      Case "help"
        mnuHelpTopics_Click(Nothing, Nothing)
      Case "about"
        mnuHelpAbout_Click(Nothing, Nothing)
      Case "refresh"
        mnuViewRefresh_Click(Nothing, Nothing)
      Case "new"
        mnuNewDeterminatorRule_Click(Nothing, Nothing)
      Case "monitor"
        mnuMonitor_Click(Nothing, Nothing)
      Case "reload"
        mnuFileReloadScripts_Click(Nothing, Nothing)
      Case "runsub"
        mnuFileRunSub_Click(Nothing, Nothing)
      Case "on"
        If lvwItems.SelectedItems.Count = 1 Then
          mnuX10On_Click(Nothing, Nothing)
        End If
      Case "off"
        If lvwItems.SelectedItems.Count = 1 Then
          mnuX10Off_Click(Nothing, Nothing)
        End If
      Case "rundeterminator"
        mnuRunDeterminator_Click(Nothing, Nothing)
    End Select
  End Sub


  Private Sub mnuMonitor_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuMonitor.Click
        'Dim f As New frmMonitor
        'f.Owner = Me
        'f.Show()
        frmMonitor.Show()
    End Sub



  Private Sub mnuToolNewScript_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuToolNewScript.Click
    mnuNewScript_Click(Nothing, Nothing)
  End Sub

  Private Sub mnuToolNewEvent_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuToolNewEvent.Click
    mnuNewEvent_Click(Nothing, Nothing)
  End Sub

  Private Sub mnuToolNewGlobal_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuToolNewGlobal.Click
    mnuNewGlobal_Click(Nothing, Nothing)
  End Sub

  Private Sub mnuToolNewX10_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuToolNewX10.Click
    mnuX10NewDevice_Click(Nothing, Nothing)
  End Sub

  Private Sub mnuToolNewDeterminator_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuToolNewDeterminator.Click
    mnuNewDeterminatorRule_Click(Nothing, Nothing)
  End Sub


  Private Sub mnuRunDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuRunDeterminator.Click
    If lvwItems.SelectedItems.Count <> 1 Then Exit Sub
    Try
      ConnectToXplHal()
      Dim str As String
      xplHalSend("RUNRULE " & lvwItems.SelectedItems(0).Tag.ToString() & vbCrLf)
      str = GetLine()
      If Not str.StartsWith("203") Then
        globals.Unexpected(str)
      End If
    Catch ex As Exception
      MsgBox("Error: " & ex.Message, vbCritical)
    End Try
  End Sub


  Private Sub mnueditNewDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuEditDeterminator.Click
    EditDeterminator()
  End Sub


  Private Sub mnuFileNewDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuFileNewDeterminator.Click
    mnuNewDeterminatorRule_Click(Nothing, Nothing)
  End Sub


  Private Sub Timer1_Elapsed(ByVal sender As Object, ByVal e As System.Timers.ElapsedEventArgs) Handles Timer1.Elapsed
    Timer1.Enabled = False
    If globals.EnableAutoUpdate Then
      DoAutoUpdateCheck()
    End If
    If CurrentMode = "C" And AutoRefreshGlowBalls Then
      ' Refresh globals
      GetGlobals()
    End If
    Timer1.Enabled = True
  End Sub

  Private Sub DoAutoUpdateCheck()
    If Now > globals.LastAutoUpdate.AddDays(CInt(globals.AutoUpdateInterval)) Then
      Dim t As New Thread(AddressOf DoAutoUpdate)
      t.Start()
    End If
  End Sub

  Private Sub DoAutoUpdate()
    globals.LastAutoUpdate = Now
    Dim pluginCount As Integer = 0
    Dim result As String = ""
    Dim xml As XmlTextReader
    xml = New XmlTextReader("http://www.xplproject.org.uk/plugins.xml")
    Try
      xml.Read()
    Catch ex As Exception
            xml = New XmlTextReader("http://www.xplproject.org.uk/plugins.xml")
      xml.Read()
    End Try
    Do
      Select Case xml.NodeType
        Case XmlNodeType.Element
          Select Case xml.Name
            Case "plugin"
              If globals.AutoUpdateMode = "ALL" Then
                pluginCount += globals.DownloadPlugin(xml.GetAttribute("url") & ".xml", False)
              Else
                pluginCount += globals.DownloadPlugin(xml.GetAttribute("url") & ".xml", True)
              End If
          End Select
      End Select
    Loop Until Not xml.Read

    xml.Close()
    If pluginCount = 1 Then
      result = "1 plugin was downloaded."
    ElseIf pluginCount > 1 Then
      result = pluginCount & " plugins were downloaded."
    End If
    globals.AutoUpdateResult = result
    globals.LastAutoUpdate = Now
    globals.SaveSettings()
  End Sub

  Private Sub HVX10Import(ByVal sender As Object, ByVal e As EventArgs) Handles mnuToolsHVX10Import.Click
    Dim filename As String
    Dim od As New OpenFileDialog
    od.CheckFileExists = True
    od.Filter = "HomeVision files (*.hvx)|*.hvx"
    If od.ShowDialog = Windows.Forms.DialogResult.OK Then
      filename = od.FileName
    Else
      Exit Sub
    End If

    Dim str As String
    ConnectToXplHal()

    Dim txt As TextReader = File.OpenText(filename)
    Dim params() As String
    Dim myLine As String = txt.ReadLine
    Dim FoundX10Devices As Boolean = False, X10DeviceCount As Integer = 0
    While Not myLine Is Nothing
      If myLine.ToLower.StartsWith("x-10 devices:") Then
        FoundX10Devices = True
      ElseIf FoundX10Devices Then
        params = Split(myLine, CChar(vbTab))
        If params.Length = 3 Then
          ' It's an X10 device
          If Not params(1) = "X10 " & params(2) And Not params(1) = "X10 " & params(2).Replace(" ", "") Then
            params(2) = params(2).Replace(" ", "")
            xplHalSend("ADDX10DEVICE" & vbCrLf)
            X10DeviceCount += 1
            str = GetLine()
            If str.StartsWith("326") Then
              xplHalSend("device=" & params(2) & vbCrLf)
              xplHalSend("label=" & params(1) & vbCrLf)
              xplHalSend("." & vbCrLf)
              str = GetLine()
              If Not str.StartsWith("226") Then
                globals.Unexpected(str)
                Exit While
              End If
            Else
              globals.Unexpected(str)
              Exit While
            End If
          End If
        Else
          Exit While
        End If
      End If
      myLine = txt.ReadLine
    End While
    txt.Close()
    If X10DeviceCount = 1 Then
      MsgBox("1 X10 device was successfully imported into xPLHal.", vbInformation)
    ElseIf X10DeviceCount > 1 Then
      MsgBox(X10DeviceCount & " X10 devices were successfully imported into xPLHal.", vbInformation)
    End If
  End Sub

  Private Sub DuplicateDeterminator_Click(ByVal sender As Object, ByVal e As EventArgs) Handles mnuDuplicateDeterminator.Click
    'Try    
    Dim rule As DeterminatorRule, ruleGuid As String
    Dim ruleText As String, str As String
    ConnectToXplHal()
    xplHalSend("GETRULE " & CStr(lvwItems.SelectedItems(0).Tag) & vbCrLf)
    str = GetLine()
    If str.StartsWith("210") Then
      ruleText = ""
      str = GetLine()
      While Not str = ("." & vbCrLf)
        ruleText &= str
        str = GetLine()
      End While
      ruleGuid = CStr(lvwItems.SelectedItems(0).Tag)
      rule = New DeterminatorRule(ruleText)
      str = InputBox("Enter a name for the new determinator:", "Duplicate Determinator", "Copy of " & rule.RuleName)
      If str.Length > 0 Then
        rule.RuleName = str
        rule.Enabled = False
        str = rule.Save
        SetRule("", str)
        mnuViewRefresh_Click(Nothing, Nothing)
      End If
    Else
      globals.Unexpected(str)
    End If
    'Catch ex As Exception
    'MsgBox("This determinator could not be edited." & vbCrLf & vbCrLf & ex.Message, vbCritical)
    'End Try
  End Sub

  Private Sub mnuToolsEthernet_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuToolsEthernet.Click
    Process.Start("xplsettings.exe")
  End Sub

  Private Sub mnuSetDefaultNode_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuSetDefaultNode.Click
    Try
      SetRegistryValue("DefaultNode", tvwNodes.SelectedNode.Tag.ToString)
    Catch ex As Exception
      SetRegistryValue("DefaultNode", "")
    End Try
  End Sub

  Private Sub SetDefaultNode()
    If Not DefaultNode = "" Then
      For Counter As Integer = 0 To tvwNodes.Nodes(0).Nodes.Count - 1
        Try
          If tvwNodes.Nodes(0).Nodes(Counter).Tag.ToString = DefaultNode Then
            tvwNodes.SelectedNode = tvwNodes.Nodes(0).Nodes(Counter)
            Exit For
          End If
        Catch ex As Exception
        End Try
      Next
    End If
  End Sub

  Private Sub frmMain_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Activated
    If FirstActivation Then
      FirstActivation = False
      SetDefaultNode()
    End If
  End Sub

  Private Sub mnuRefreshGlowBalls_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles mnuRefreshGlowBalls.Click

    If AutoRefreshGlowBalls Then
      AutoRefreshGlowBalls = False
      mnuRefreshGlowBalls.Checked = False
      SetRegistryValue("RefreshGlowBalls", "0")
    Else
      AutoRefreshGlowBalls = True
      mnuRefreshGlowBalls.Checked = True
      SetRegistryValue("RefreshGlowBalls", "1")
    End If

  End Sub

  Private Sub mnuCtxPoll_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuCtxPoll.Click
    Dim XplMsg As String = "hbeat.request" & vbCrLf & "{" & vbCrLf & "command=request" & vbCrLf & "}"
    SendXplMsg("xpl-cmnd", "*", XplMsg)
    Windows.Forms.Cursor.Current = Cursors.WaitCursor
    Threading.Thread.Sleep(5000)

    Windows.Forms.Cursor.Current = Cursors.WaitCursor
    mnuCtxRefresh_Click(Nothing, Nothing)
  End Sub

  Private Sub mnuMoreInfo_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuMoreInfo.Click
    Dim device As String = CStr(lvwItems.SelectedItems(0).Tag)

    If device.IndexOf("-") < device.IndexOf(".") Then
      device = device.Substring(0, device.IndexOf("."))
      ' Loop through all plugins
      For Counter As Integer = 0 To globals.Plugins.Length - 1
        If device = globals.Plugins(Counter).DeviceID Then
          Dim Url As String = globals.Plugins(Counter).InfoUrl
          ShellExecute(0, "Open", Url, "", "", 0)
        End If
      Next
    End If
  End Sub

  Private Sub mnuNewDeterminatorGroup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuNewDeterminatorGroup.Click
    tvwNodes.LabelEdit = True
    Dim tn As New TreeNode
    tn.Text = "New determinator group"
    tn.ImageIndex = 6
    tvwNodes.SelectedNode.Nodes.Add(tn)
    tvwNodes.SelectedNode = tn
    tn.BeginEdit()
  End Sub

  Private Sub tvwNodes_AfterLabelEdit(ByVal sender As Object, ByVal e As System.Windows.Forms.NodeLabelEditEventArgs) Handles tvwNodes.AfterLabelEdit
    If e.Label Is Nothing Then
      e.Node.Remove()
      Exit Sub
    End If

    ' Check for duplicate names
    Dim tn As TreeNode = e.Node.Parent
    Dim IsDuplicate As Boolean = False
    For Each t As TreeNode In tn.Nodes
      If t.Text = e.Label Then
        IsDuplicate = True
        Exit For
      End If
    Next
    If IsDuplicate Then
      MsgBox("A group with the specified name already exists.", vbExclamation)
      e.Node.BeginEdit()
    Else
      ' Create a new group and send it to the server
      Dim r As New DeterminatorRule
      r.RuleName = e.Label
      While tn.Tag.ToString() <> "T"
        r.RuleName = tn.Text & "/" & r.RuleName
        tn = tn.Parent
      End While
      r.IsGroup = True
      Dim ruleText As String = r.Save
      Dim RuleGuid As String = setRule("", ruleText)
      If RuleGuid.StartsWith("238 ") Then
        RuleGuid = RuleGuid.Substring(4, RuleGuid.Length - 4)
      End If
      e.Node.Tag = "T" & RuleGuid & vbTab & r.RuleName
      tvwNodes.LabelEdit = False
    End If
  End Sub

  Private Sub AddDeterminatorGroups(ByVal tn As TreeNode)
    xplhalsend("LISTRULEGROUPS" & vbCrLf)
    Dim str As String = getLine()
    If Not str.StartsWith("240") Then
      mnuNewDeterminatorGroup.Enabled = False
      Exit Sub
    Else
      mnuNewDeterminatorGroup.Enabled = True
    End If
    Dim NestedGroup As String
    While (Not str = "." & vbCrLf) And (Not str = vbCrLf)
      Dim bits() As String = str.Split(CChar(vbTab))
      If bits.Length >= 2 Then
        Dim t As New TreeNode
        t.Text = bits(1)
        t.Tag = "T" & bits(0) & vbTab & bits(1)
        t.ImageIndex = 6
        ' Is this a nested group?
        If t.Text.IndexOf("/") > 0 Then
          NestedGroup = t.Text.Substring(0, t.Text.LastIndexOf("/"))
          t.Text = t.Text.Substring(t.Text.LastIndexOf("/") + 1, t.Text.Length - t.Text.LastIndexOf("/") - 1)
          FindParentGroup(tn, t, NestedGroup)
        Else
          tn.Nodes.Add(t)
        End If
      End If
      str = getLine()
    End While
  End Sub

  Private Sub mnuExportDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuExportDeterminator.Click
    Dim SFD As New SaveFileDialog
    SFD.AddExtension = True
    SFD.Filter = "XML files (*.xml)|*.xml"
    SFD.Title = "Export Determinator"
    SFD.FileName = lvwItems.SelectedItems(0).Text & ".xml"
		If SFD.ShowDialog = Windows.Forms.DialogResult.OK Then
			Dim ruleText As String, str As String
			ConnectToXplHal()
			xplHalSend("GETRULE " & CStr(lvwItems.SelectedItems(0).Tag) & vbCrLf)
			str = GetLine()
			If str.StartsWith("210") Then
				ruleText = ""
				str = GetLine()
				While Not str = ("." & vbCrLf)
					ruleText &= str
					str = GetLine()
				End While
				Dim fs As TextWriter = File.CreateText(SFD.FileName)
				fs.Write(ruleText)
				fs.Close()
			End If
		End If
	End Sub

	Private Sub mnuImportDeterminator_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuImportDeterminator.Click
		Try
			Dim OFD As New OpenFileDialog
			OFD.Title = "Import Determinator"
			OFD.Filter = "XML files (*.xml)|*.xml"
			If OFD.ShowDialog = Windows.Forms.DialogResult.OK Then
				Dim fs As TextReader = File.OpenText(OFD.FileName)
				Dim str As String = String.Empty
				Dim buff As String = fs.ReadLine
				While Not buff Is Nothing
					str &= buff & vbCrLf
					buff = fs.ReadLine()
				End While
				fs.Close()
				fs = File.OpenText(OFD.FileName)
				Dim x As New XmlDocument
				x.Load(fs)
				fs.Close()
				Dim n As XmlNode = x.SelectSingleNode("/xplDeterminator/determinator")
				Dim DeterminatorName As String = n.Attributes("name").Value
				' Make sure determinator is unique
				Dim IsUnique As Boolean = True
				For Each li As ListViewItem In lvwItems.Items
					If li.Text.ToLower() = DeterminatorName.ToLower() Then
						IsUnique = False
					End If
				Next
				If IsUnique Then
					ConnectToXplHal()
					xplHalSend("SETRULE" & vbCrLf)
					buff = GetLine()
					If Not buff.StartsWith("338") Then
						globals.Unexpected(buff)
						Exit Sub
					End If
					xplHalSend(str & "." & vbCrLf)
					buff = GetLine()
					If Not buff.StartsWith("238") Then
						globals.Unexpected(buff)
					End If
					MsgBox("The determinator was imported successfully.", vbInformation)
				Else
					MsgBox("You already have a determinator called " & DeterminatorName & "." & vbCrLf & vbCrLf & "You must rename or delete your existing determinator before you can import one with the same name.", vbExclamation)
				End If
			End If
		Catch ex As Exception
			MsgBox("The determinator could not be imported." & vbCrLf & vbCrLf & ex.Message, vbCritical)
		End Try
	End Sub

  Private Sub mnuDeleteDeterminatorGroup_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles mnuDeleteDeterminatorGroup.Click
    If MsgBox("Are you sure you want to delete this group of determinators?", vbYesNo Or vbQuestion) = MsgBoxResult.Yes Then
      connectToXplHal()
      Dim Bits() As String = tvwNodes.SelectedNode.Tag.ToString().Split(CChar(vbTab))
      Dim GroupGuid As String = Bits(0).Substring(1, Bits(0).Length - 1)
      xplhalsend("DELRULE " & GroupGuid & vbCrLf)
      GroupGuid = getLine()
      If GroupGuid.StartsWith("214") Then
        tvwNodes.SelectedNode.Remove()
      Else
        globals.Unexpected(GroupGuid)
      End If
    End If
  End Sub

  Private Sub lvwItems_DragDrop(ByVal sender As Object, ByVal e As System.Windows.Forms.DragEventArgs) Handles lvwItems.DragDrop

  End Sub

  Private Sub lvwItems_ItemDrag(ByVal sender As Object, ByVal e As System.Windows.Forms.ItemDragEventArgs) Handles lvwItems.ItemDrag
    Select Case tvwNodes.SelectedNode.Tag.ToString().Substring(0, 1)
      Case "T" ' Determinators    
        ' Start a drag drop
        Dim lvi As ListViewItem = CType(e.Item, ListViewItem)
        DoDragDrop("T" & lvi.Tag.ToString(), DragDropEffects.Move Or DragDropEffects.Copy)
    End Select
  End Sub

  Private Sub tvwNodes_DragEnter(ByVal sender As Object, ByVal e As System.Windows.Forms.DragEventArgs) Handles tvwNodes.DragEnter
    ' Determine if we are dragging something, if we are, set the effect
    If e.Data.GetDataPresent(DataFormats.Text) Then
      e.Effect = DragDropEffects.Copy
    Else
      e.Effect = DragDropEffects.None
    End If
  End Sub

  Private Sub tvwNodes_DragDrop(ByVal sender As Object, ByVal e As System.Windows.Forms.DragEventArgs) Handles tvwNodes.DragDrop
    Try
      Dim s As String   '= e.Data.GetData(DataFormats.Text).ToString()
      Dim tn As TreeNode = tvwNodes.GetNodeAt(tvwNodes.PointToClient(New Point(e.X, e.Y)))
      If Not tn Is Nothing Then
        Dim TheTag As String = tn.Tag.ToString()
        If TheTag.StartsWith("T") Then
          Dim bits() As String = TheTag.Split(CChar(vbTab))
          For Each thing As ListViewItem In lvwItems.SelectedItems
            s = thing.Tag.ToString
            's = s.Substring(1, s.Length - 1)
            If bits.Length > 1 Then
              MoveDeterminator(s, bits(1))
            Else
              MoveDeterminator(s, "")
            End If
          Next
          mnuViewRefresh_Click(Nothing, Nothing)
        End If
      Else
        'MsgBox("treenode is nothing")
      End If
    Catch ex As Exception
      MsgBox(ex.ToString, vbCritical)
    End Try
  End Sub

  Private Sub lvwItems_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lvwItems.SelectedIndexChanged

  End Sub


  Private Sub tvwNodes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles tvwNodes.Click

  End Sub

  Private Sub MoveDeterminator(ByVal determinatorGuid As String, ByVal destinationGroup As String)
    connectToXplhal()
    Dim RuleText As String = String.Empty, buff As String
    xplHalSend("GETRULE " & determinatorGuid & vbCrLf)
    buff = getLine()

    If buff.StartsWith("210") Then
      buff = getLine()
      While (buff <> "." & vbCrLf) And (buff <> "")
        RuleText &= buff
        buff = getLine()
      End While
      Dim Rule As New DeterminatorRule(RuleText)
      Rule.GroupName = destinationGroup
      RuleText = Rule.Save
      SetRule(determinatorGuid, RuleText)
    Else
      globals.Unexpected(buff)
    End If
  End Sub

  Private Sub FindParentGroup(ByVal parentNode As TreeNode, ByVal tn As TreeNode, ByVal groupName As String)
    Dim bits() As String
    For Each t As TreeNode In parentNode.Nodes
      bits = t.Tag.ToString().Split(CChar(vbTab))
      If bits(1) = groupName Then
        t.Nodes.Add(tn)
      ElseIf t.Nodes.Count > 0 Then
        FindParentGroup(parentNode, tn, groupName)
      End If
    Next
  End Sub

  Private Sub AddScriptingFolders(ByVal tn As TreeNode)
    If tn Is Nothing Then
      ' FInd the node
      For Each t As TreeNode In tvwNodes.Nodes(0).Nodes
        If t.Tag.ToString() = "S" Then
          tn = t
          Exit For
        End If
      Next
    End If
    ' First remove any directories
    tn.Nodes.Clear()

    ' Add the directories
    ConnectToxPLHal()
    xplhalsend("LISTSCRIPTS" & vbCrLf)
    Dim TN2 As TreeNode
    Dim str As String
    str = getline()
    If str.StartsWith("212") Then
      str = getline().Trim()
      While (Not str.StartsWith("."))
        If str.EndsWith("\") Then
          str = str.Substring(0, str.Length - 1)
          TN2 = New TreeNode
          TN2.Text = str
          TN2.Tag = "S" & str
          TN2.ImageIndex = 1
          tn.Nodes.Add(TN2)
        End If
        str = getline().Trim()
      End While
    Else
      globals.Unexpected(str)
    End If
  End Sub

End Class

