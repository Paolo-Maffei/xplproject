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

Public Class frmUpdatePlugIn
    Inherits System.Windows.Forms.Form

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
    Friend WithEvents lvwPlugIns As System.Windows.Forms.ListView
    Friend WithEvents cmdSelectAll As System.Windows.Forms.Button
    Friend WithEvents cmdSelectNone As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
  Friend WithEvents TabControl1 As System.Windows.Forms.TabControl
  Friend WithEvents tabPlugins As System.Windows.Forms.TabPage
  Friend WithEvents tabOptions As System.Windows.Forms.TabPage
  Friend WithEvents chkAuto As System.Windows.Forms.CheckBox
  Friend WithEvents grpOptions As System.Windows.Forms.GroupBox
  Friend WithEvents Label1 As System.Windows.Forms.Label
  Friend WithEvents txtResults As System.Windows.Forms.TextBox
  Friend WithEvents nudDays As System.Windows.Forms.NumericUpDown
  Friend WithEvents radAll As System.Windows.Forms.RadioButton
  Friend WithEvents radSelected As System.Windows.Forms.RadioButton
  Friend WithEvents radAuto As System.Windows.Forms.RadioButton
  Friend WithEvents Panel2 As System.Windows.Forms.Panel
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmUpdatePlugIn))
		Me.lvwPlugIns = New System.Windows.Forms.ListView
		Me.cmdSelectAll = New System.Windows.Forms.Button
		Me.cmdSelectNone = New System.Windows.Forms.Button
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.TabControl1 = New System.Windows.Forms.TabControl
		Me.tabPlugins = New System.Windows.Forms.TabPage
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.tabOptions = New System.Windows.Forms.TabPage
		Me.grpOptions = New System.Windows.Forms.GroupBox
		Me.txtResults = New System.Windows.Forms.TextBox
		Me.radAuto = New System.Windows.Forms.RadioButton
		Me.radSelected = New System.Windows.Forms.RadioButton
		Me.radAll = New System.Windows.Forms.RadioButton
		Me.Label1 = New System.Windows.Forms.Label
		Me.nudDays = New System.Windows.Forms.NumericUpDown
		Me.chkAuto = New System.Windows.Forms.CheckBox
		Me.Panel1.SuspendLayout()
		Me.TabControl1.SuspendLayout()
		Me.tabPlugins.SuspendLayout()
		Me.Panel2.SuspendLayout()
		Me.tabOptions.SuspendLayout()
		Me.grpOptions.SuspendLayout()
		CType(Me.nudDays, System.ComponentModel.ISupportInitialize).BeginInit()
		Me.SuspendLayout()
		'
		'lvwPlugIns
		'
		Me.lvwPlugIns.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lvwPlugIns.CheckBoxes = True
		Me.lvwPlugIns.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lvwPlugIns.Location = New System.Drawing.Point(10, 10)
		Me.lvwPlugIns.MultiSelect = False
		Me.lvwPlugIns.Name = "lvwPlugIns"
		Me.lvwPlugIns.Size = New System.Drawing.Size(716, 427)
		Me.lvwPlugIns.TabIndex = 0
		Me.lvwPlugIns.View = System.Windows.Forms.View.Details
		'
		'cmdSelectAll
		'
		Me.cmdSelectAll.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
		Me.cmdSelectAll.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSelectAll.Location = New System.Drawing.Point(8, 8)
		Me.cmdSelectAll.Name = "cmdSelectAll"
		Me.cmdSelectAll.TabIndex = 1
		Me.cmdSelectAll.Text = "Select All"
		'
		'cmdSelectNone
		'
		Me.cmdSelectNone.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
		Me.cmdSelectNone.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdSelectNone.Location = New System.Drawing.Point(88, 8)
		Me.cmdSelectNone.Name = "cmdSelectNone"
		Me.cmdSelectNone.TabIndex = 2
		Me.cmdSelectNone.Text = "Select None"
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(656, 8)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 4
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(576, 8)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 3
		Me.cmdOK.Text = "OK"
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.cmdOK)
		Me.Panel1.Controls.Add(Me.cmdCancel)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel1.Location = New System.Drawing.Point(0, 473)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(744, 40)
		Me.Panel1.TabIndex = 5
		'
		'TabControl1
		'
		Me.TabControl1.Controls.Add(Me.tabPlugins)
		Me.TabControl1.Controls.Add(Me.tabOptions)
		Me.TabControl1.Dock = System.Windows.Forms.DockStyle.Fill
		Me.TabControl1.Location = New System.Drawing.Point(0, 0)
		Me.TabControl1.Name = "TabControl1"
		Me.TabControl1.SelectedIndex = 0
		Me.TabControl1.Size = New System.Drawing.Size(744, 473)
		Me.TabControl1.TabIndex = 6
		'
		'tabPlugins
		'
		Me.tabPlugins.Controls.Add(Me.Panel2)
		Me.tabPlugins.Controls.Add(Me.lvwPlugIns)
		Me.tabPlugins.DockPadding.All = 10
		Me.tabPlugins.Location = New System.Drawing.Point(4, 22)
		Me.tabPlugins.Name = "tabPlugins"
		Me.tabPlugins.Size = New System.Drawing.Size(736, 447)
		Me.tabPlugins.TabIndex = 0
		Me.tabPlugins.Text = "Plug-ins"
		'
		'Panel2
		'
		Me.Panel2.Controls.Add(Me.cmdSelectAll)
		Me.Panel2.Controls.Add(Me.cmdSelectNone)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel2.Location = New System.Drawing.Point(10, 397)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(716, 40)
		Me.Panel2.TabIndex = 6
		'
		'tabOptions
		'
		Me.tabOptions.Controls.Add(Me.grpOptions)
		Me.tabOptions.Controls.Add(Me.chkAuto)
		Me.tabOptions.Location = New System.Drawing.Point(4, 22)
		Me.tabOptions.Name = "tabOptions"
		Me.tabOptions.Size = New System.Drawing.Size(736, 447)
		Me.tabOptions.TabIndex = 1
		Me.tabOptions.Text = "Download Options"
		'
		'grpOptions
		'
		Me.grpOptions.Controls.Add(Me.txtResults)
		Me.grpOptions.Controls.Add(Me.radAuto)
		Me.grpOptions.Controls.Add(Me.radSelected)
		Me.grpOptions.Controls.Add(Me.radAll)
		Me.grpOptions.Controls.Add(Me.Label1)
		Me.grpOptions.Controls.Add(Me.nudDays)
		Me.grpOptions.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.grpOptions.Location = New System.Drawing.Point(40, 56)
		Me.grpOptions.Name = "grpOptions"
		Me.grpOptions.Size = New System.Drawing.Size(584, 304)
		Me.grpOptions.TabIndex = 1
		Me.grpOptions.TabStop = False
		Me.grpOptions.Text = "Auto Download Options"
		'
		'txtResults
		'
		Me.txtResults.Location = New System.Drawing.Point(32, 168)
		Me.txtResults.Multiline = True
		Me.txtResults.Name = "txtResults"
		Me.txtResults.ReadOnly = True
		Me.txtResults.Size = New System.Drawing.Size(528, 112)
		Me.txtResults.TabIndex = 4
		Me.txtResults.Text = ""
		'
		'radAuto
		'
		Me.radAuto.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radAuto.Location = New System.Drawing.Point(32, 128)
		Me.radAuto.Name = "radAuto"
		Me.radAuto.Size = New System.Drawing.Size(336, 24)
		Me.radAuto.TabIndex = 3
		Me.radAuto.Text = "Automatically decide which plug-ins to download.."
		Me.radAuto.Visible = False
		'
		'radSelected
		'
		Me.radSelected.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radSelected.Location = New System.Drawing.Point(32, 96)
		Me.radSelected.Name = "radSelected"
		Me.radSelected.Size = New System.Drawing.Size(336, 24)
		Me.radSelected.TabIndex = 2
		Me.radSelected.Text = "Download only selected plugins."
		'
		'radAll
		'
		Me.radAll.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.radAll.Location = New System.Drawing.Point(32, 64)
		Me.radAll.Name = "radAll"
		Me.radAll.Size = New System.Drawing.Size(336, 24)
		Me.radAll.TabIndex = 1
		Me.radAll.Text = "Download all plugins."
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(16, 24)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(232, 20)
		Me.Label1.TabIndex = 1
		Me.Label1.Text = "Automatically download after this many days"
		Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight
		'
		'nudDays
		'
		Me.nudDays.Location = New System.Drawing.Point(264, 24)
		Me.nudDays.Maximum = New Decimal(New Integer() {30, 0, 0, 0})
		Me.nudDays.Minimum = New Decimal(New Integer() {1, 0, 0, 0})
		Me.nudDays.Name = "nudDays"
		Me.nudDays.Size = New System.Drawing.Size(72, 20)
		Me.nudDays.TabIndex = 0
		Me.nudDays.Value = New Decimal(New Integer() {1, 0, 0, 0})
		'
		'chkAuto
		'
		Me.chkAuto.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkAuto.Location = New System.Drawing.Point(16, 16)
		Me.chkAuto.Name = "chkAuto"
		Me.chkAuto.Size = New System.Drawing.Size(216, 24)
		Me.chkAuto.TabIndex = 0
		Me.chkAuto.Text = "Automatically download plug-ins"
		'
		'frmUpdatePlugIn
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(744, 513)
		Me.Controls.Add(Me.TabControl1)
		Me.Controls.Add(Me.Panel1)
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmUpdatePlugIn"
		Me.Text = "Update Plug-ins"
		Me.Panel1.ResumeLayout(False)
		Me.TabControl1.ResumeLayout(False)
		Me.tabPlugins.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		Me.tabOptions.ResumeLayout(False)
		Me.grpOptions.ResumeLayout(False)
		CType(Me.nudDays, System.ComponentModel.ISupportInitialize).EndInit()
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private Sub cmdSelectAll_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectAll.Click
        Dim it As ListViewItem
        For Each it In lvwPlugIns.Items
            it.Checked = True
        Next
    End Sub

    Private Sub cmdSelectNone_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdSelectNone.Click
        Dim it As ListViewItem
        For Each it In lvwPlugIns.Items
            it.Checked = False
        Next
    End Sub


  Private Sub frmUpdatePlugIn_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
    lvwPlugIns.FullRowSelect = True
    chkAuto.Checked = globals.EnableAutoUpdate
    If Not globals.LastAutoUpdate = CDate("01/01/0001") Then
      txtResults.Text = globals.LastAutoUpdate.ToString("dd MMM yyyy") & ":" & vbCrLf & globals.AutoUpdateResult
    End If

    Select Case globals.AutoUpdateMode
      Case "ALL"
        radAll.Checked = True
      Case "AUTO"
        radAuto.Checked = True
      Case Else
        radSelected.Checked = True
    End Select
    nudDays.Text = globals.AutoUpdateInterval
    chkAuto_CheckedChanged(Nothing, Nothing)

    Try
      Dim files() As String = Directory.GetFiles(globals.PluginsPath)
      Dim li As ListViewItem
      Dim xml As XmlTextReader
      xml = New XmlTextReader("http://www.xplproject.org.uk/plugins.xml")
      Try
        xml.Read()
      Catch ex As Exception
        xml = New XmlTextReader("http://www.xpl.myby.co.uk/support/xplhalweb/plugins.xml")
        xml.Read()
      End Try

      Dim Counter As Integer
      lvwPlugIns.Columns.Add("Name", 175, HorizontalAlignment.Left)
      lvwPlugIns.Columns.Add("Description", 500, HorizontalAlignment.Left)

      Do
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "plugin"
                li = New ListViewItem
                li.Text = xml.GetAttribute("name")
                li.Tag = xml.GetAttribute("url") & ".xml"
                li.SubItems.Add(xml.GetAttribute("description"))
                For Counter = 0 To files.Length - 1
                  If GetPluginName(CStr(li.Tag)) = files(Counter) Then
                    li.Checked = True
                  End If
                Next
                lvwPlugIns.Items.Add(li)
            End Select
        End Select

      Loop Until Not xml.Read
      xml.Close()
    Catch ex As Exception
      MsgBox("xPLHal Manager could not download the list of currently available plug-ins." & vbCrLf & vbCrLf & "Please make sure your Internet connection is working properly and try again.", vbCritical)
      Me.Close()
    End Try
  End Sub

  Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
		Windows.Forms.Cursor.Current = Cursors.WaitCursor
    globals.EnableAutoUpdate = chkAuto.Checked
    If chkAuto.Checked Then
      globals.AutoUpdateInterval = nudDays.Text
      If radAuto.Checked Then
        globals.AutoUpdateMode = "AUTO"
      ElseIf radAll.Checked Then
        globals.AutoUpdateMode = "ALL"
      Else
        globals.AutoUpdateMode = "SELECTED"
      End If
    End If
    globals.SaveSettings()
    If lvwPlugIns.Visible = False Then
      Me.Close()
      Exit Sub
    End If
    Dim PluginCount As Integer = 0
    For Counter As Integer = 0 To lvwPlugIns.Items.Count - 1
      If lvwPlugIns.Items(Counter).Checked Then

        globals.DownloadPlugin(CStr(lvwPlugIns.Items(Counter).Tag), False)
        PluginCount += 1
      End If
    Next
		Windows.Forms.Cursor.Current = Cursors.Default
    If PluginCount = 0 Then
      MsgBox("No plug-ins were downloaded.", vbInformation, "xPLHal Manager")
    ElseIf PluginCount = 1 Then
      MsgBox("1 plug-in was downloaded.", vbInformation, "xPLHal Manager")
    Else
      MsgBox(PluginCount.ToString & " plug-ins were downloaded.", vbInformation, "xPLHal Manager")
    End If
    Me.Close()
  End Sub

  
  Private Function GetPluginName(ByVal s As String) As String
    s = s.Substring(s.LastIndexOf("/") + 1, s.Length - s.LastIndexOf("/") - 1)
    s = "plugins\" & s

    Return s
  End Function

  Private Sub chkAuto_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles chkAuto.CheckedChanged
    If chkAuto.Checked = True Then
      grpOptions.Enabled = True
    Else
      grpOptions.Enabled = False
    End If


  End Sub




End Class
