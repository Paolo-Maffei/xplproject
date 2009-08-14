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

Public Class frmProperties
    Inherits xplhalMgrBase

    Private Structure Construct
        Dim SubID As String
        Dim Key As String
        Dim Desc As String
    End Structure

    Public Structure Schema
        Public MsgType As String
        Public Vendor As String
        Public Device As String
        Public Instance As String
        Public SchemaClass As String
        Public SchemaType As String
        Public Subs As String
        Public [Continue] As Boolean
    End Structure

    Private ConfigStream As MemoryStream

    'Private ConfigDoc As String
    Private IsDirty As Boolean


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
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents Panel2 As System.Windows.Forms.Panel
    Friend WithEvents TabControl1 As System.Windows.Forms.TabControl
    Friend WithEvents TabPage1 As System.Windows.Forms.TabPage
    Friend WithEvents TabPage2 As System.Windows.Forms.TabPage    
    Friend WithEvents chkEnableConfigMgr As System.Windows.Forms.CheckBox
    Friend WithEvents chkEnableSMTP As System.Windows.Forms.CheckBox
    Friend WithEvents chkContinue As System.Windows.forms.CheckBox
    Friend WithEvents chkEnablexAP As System.Windows.Forms.CheckBox
    Friend WithEvents Panel4 As System.Windows.Forms.Panel
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents txtKey As System.Windows.Forms.TextBox
    Friend WithEvents txtSubID As System.Windows.Forms.TextBox
    Friend WithEvents txtDesc As System.Windows.Forms.TextBox
    Friend WithEvents tvwConstructs As System.Windows.Forms.TreeView
    Friend WithEvents TabPage3 As System.Windows.Forms.TabPage
    Friend WithEvents lvwSchemae As System.Windows.Forms.ListView
    Friend WithEvents cmdUp As System.Windows.Forms.Button
    Friend WithEvents cmdDown As System.Windows.Forms.Button
    Friend WithEvents cmdAdd As System.Windows.Forms.Button
    Friend WithEvents cmdRemove As System.Windows.Forms.Button
    Friend WithEvents Panel3 As System.Windows.Forms.Panel
    Friend WithEvents cmdEdit As System.Windows.Forms.Button
    Friend WithEvents ImageList1 As System.Windows.Forms.ImageList
  Friend WithEvents chkAutoScript As System.Windows.Forms.CheckBox
  <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Me.components = New System.ComponentModel.Container
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmProperties))
		Me.Panel1 = New System.Windows.Forms.Panel
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmdRemove = New System.Windows.Forms.Button
		Me.cmdAdd = New System.Windows.Forms.Button
		Me.cmdDown = New System.Windows.Forms.Button
		Me.cmdUp = New System.Windows.Forms.Button
		Me.Panel2 = New System.Windows.Forms.Panel
		Me.TabControl1 = New System.Windows.Forms.TabControl
		Me.TabPage1 = New System.Windows.Forms.TabPage
		Me.chkAutoScript = New System.Windows.Forms.CheckBox
		Me.chkEnableConfigMgr = New System.Windows.Forms.CheckBox
		Me.chkEnableSMTP = New System.Windows.Forms.CheckBox
		Me.chkEnablexAP = New System.Windows.Forms.CheckBox		
		Me.chkContinue = New System.Windows.Forms.CheckBox
		Me.TabPage2 = New System.Windows.Forms.TabPage
		Me.tvwConstructs = New System.Windows.Forms.TreeView
		Me.Panel4 = New System.Windows.Forms.Panel
		Me.Label2 = New System.Windows.Forms.Label
		Me.txtKey = New System.Windows.Forms.TextBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.txtSubID = New System.Windows.Forms.TextBox
		Me.Label3 = New System.Windows.Forms.Label
		Me.txtDesc = New System.Windows.Forms.TextBox
		Me.TabPage3 = New System.Windows.Forms.TabPage
		Me.lvwSchemae = New System.Windows.Forms.ListView
		Me.ImageList1 = New System.Windows.Forms.ImageList(Me.components)
		Me.Panel3 = New System.Windows.Forms.Panel
		Me.cmdEdit = New System.Windows.Forms.Button
		Me.Panel1.SuspendLayout()
		Me.Panel2.SuspendLayout()
		Me.TabControl1.SuspendLayout()
		Me.TabPage1.SuspendLayout()
		Me.TabPage2.SuspendLayout()
		Me.Panel4.SuspendLayout()
		Me.TabPage3.SuspendLayout()
		Me.Panel3.SuspendLayout()
		Me.SuspendLayout()
		'
		'Panel1
		'
		Me.Panel1.Controls.Add(Me.cmdCancel)
		Me.Panel1.Controls.Add(Me.cmdOK)
		Me.Panel1.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel1.Location = New System.Drawing.Point(0, 473)
		Me.Panel1.Name = "Panel1"
		Me.Panel1.Size = New System.Drawing.Size(744, 40)
		Me.Panel1.TabIndex = 1
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(656, 8)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 21
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(568, 8)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 20
		Me.cmdOK.Text = "OK"
		'
		'cmdRemove
		'
		Me.cmdRemove.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdRemove.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdRemove.Location = New System.Drawing.Point(648, 8)
		Me.cmdRemove.Name = "cmdRemove"
		Me.cmdRemove.TabIndex = 5
		Me.cmdRemove.Text = "&Remove"
		'
		'cmdAdd
		'
		Me.cmdAdd.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdAdd.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdAdd.Location = New System.Drawing.Point(568, 8)
		Me.cmdAdd.Name = "cmdAdd"
		Me.cmdAdd.TabIndex = 4
		Me.cmdAdd.Text = "&Add"
		'
		'cmdDown
		'
		Me.cmdDown.AccessibleDescription = "tosser down"
		Me.cmdDown.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdDown.Image = CType(resources.GetObject("cmdDown.Image"), System.Drawing.Image)
		Me.cmdDown.Location = New System.Drawing.Point(88, 8)
		Me.cmdDown.Name = "cmdDown"
		Me.cmdDown.TabIndex = 2
		'
		'cmdUp
		'
		Me.cmdUp.AccessibleDescription = "tosser up"
		Me.cmdUp.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdUp.Image = CType(resources.GetObject("cmdUp.Image"), System.Drawing.Image)
		Me.cmdUp.Location = New System.Drawing.Point(8, 8)
		Me.cmdUp.Name = "cmdUp"
		Me.cmdUp.TabIndex = 1
		'
		'Panel2
		'
		Me.Panel2.Controls.Add(Me.TabControl1)
		Me.Panel2.Dock = System.Windows.Forms.DockStyle.Fill
		Me.Panel2.Location = New System.Drawing.Point(0, 0)
		Me.Panel2.Name = "Panel2"
		Me.Panel2.Size = New System.Drawing.Size(744, 473)
		Me.Panel2.TabIndex = 6
		'
		'TabControl1
		'
		Me.TabControl1.Controls.Add(Me.TabPage1)
		Me.TabControl1.Controls.Add(Me.TabPage2)
		Me.TabControl1.Controls.Add(Me.TabPage3)
		Me.TabControl1.Dock = System.Windows.Forms.DockStyle.Fill
		Me.TabControl1.Location = New System.Drawing.Point(0, 0)
		Me.TabControl1.Name = "TabControl1"
		Me.TabControl1.SelectedIndex = 0
		Me.TabControl1.Size = New System.Drawing.Size(744, 473)
		Me.TabControl1.TabIndex = 0
		'
		'TabPage1
		'
		Me.TabPage1.Controls.Add(Me.chkAutoScript)
		Me.TabPage1.Controls.Add(Me.chkEnableConfigMgr)
		Me.TabPage1.Controls.Add(Me.chkEnableSMTP)
		Me.TabPage1.Controls.Add(Me.chkEnablexAP)		
		Me.TabPage1.Controls.Add(Me.chkContinue)
		Me.TabPage1.Location = New System.Drawing.Point(4, 22)
		Me.TabPage1.Name = "TabPage1"
		Me.TabPage1.Size = New System.Drawing.Size(736, 447)
		Me.TabPage1.TabIndex = 0
		Me.TabPage1.Text = "General"
		'
		'chkAutoScript
		'
		Me.chkAutoScript.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkAutoScript.Location = New System.Drawing.Point(16, 136)
		Me.chkAutoScript.Name = "chkAutoScript"
		Me.chkAutoScript.Size = New System.Drawing.Size(352, 16)
		Me.chkAutoScript.TabIndex = 5
		Me.chkAutoScript.Text = "Enable automatic script generation"
		'
		'chkEnableConfigMgr
		'
		Me.chkEnableConfigMgr.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkEnableConfigMgr.Location = New System.Drawing.Point(16, 40)
		Me.chkEnableConfigMgr.Name = "chkEnableConfigMgr"
		Me.chkEnableConfigMgr.Size = New System.Drawing.Size(352, 16)
		Me.chkEnableConfigMgr.TabIndex = 1
		Me.chkEnableConfigMgr.Text = "Enable config manager"
		'
		'chkEnableSMTP
		'
		Me.chkEnableSMTP.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkEnableSMTP.Location = New System.Drawing.Point(16, 64)
		Me.chkEnableSMTP.Name = "chkEnableSMTP"
		Me.chkEnableSMTP.Size = New System.Drawing.Size(352, 16)
		Me.chkEnableSMTP.TabIndex = 2
		Me.chkEnableSMTP.Text = "Enable SMTP email processing"
		'
		'chkEnablexAP
		'
		Me.chkEnablexAP.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkEnablexAP.Location = New System.Drawing.Point(16, 112)
		Me.chkEnablexAP.Name = "chkEnablexAP"
		Me.chkEnablexAP.Size = New System.Drawing.Size(352, 16)
		Me.chkEnablexAP.TabIndex = 4
		Me.chkEnablexAP.Text = "Enable xAP support"





		'
		'chkContinue
		'
		Me.chkContinue.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.chkContinue.Location = New System.Drawing.Point(16, 88)
		Me.chkContinue.Name = "chkContinue"
		Me.chkContinue.Size = New System.Drawing.Size(352, 16)
		Me.chkContinue.TabIndex = 3
		Me.chkContinue.Text = "Continue processing after first match"
		'
		'TabPage2
		'
		Me.TabPage2.Controls.Add(Me.tvwConstructs)
		Me.TabPage2.Controls.Add(Me.Panel4)
		Me.TabPage2.Location = New System.Drawing.Point(4, 22)
		Me.TabPage2.Name = "TabPage2"
		Me.TabPage2.Size = New System.Drawing.Size(736, 447)
		Me.TabPage2.TabIndex = 1
		Me.TabPage2.Text = "Constructs"
		'
		'tvwConstructs
		'
		Me.tvwConstructs.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.tvwConstructs.Dock = System.Windows.Forms.DockStyle.Fill
		Me.tvwConstructs.ImageIndex = -1
		Me.tvwConstructs.Location = New System.Drawing.Point(0, 0)
		Me.tvwConstructs.Name = "tvwConstructs"
		Me.tvwConstructs.SelectedImageIndex = -1
		Me.tvwConstructs.Size = New System.Drawing.Size(624, 447)
		Me.tvwConstructs.TabIndex = 0
		'
		'Panel4
		'
		Me.Panel4.Controls.Add(Me.Label2)
		Me.Panel4.Controls.Add(Me.txtKey)
		Me.Panel4.Controls.Add(Me.Label1)
		Me.Panel4.Controls.Add(Me.txtSubID)
		Me.Panel4.Controls.Add(Me.Label3)
		Me.Panel4.Controls.Add(Me.txtDesc)
		Me.Panel4.Dock = System.Windows.Forms.DockStyle.Right
		Me.Panel4.Location = New System.Drawing.Point(624, 0)
		Me.Panel4.Name = "Panel4"
		Me.Panel4.Size = New System.Drawing.Size(112, 447)
		Me.Panel4.TabIndex = 2
		'
		'Label2
		'
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Location = New System.Drawing.Point(8, 56)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(96, 16)
		Me.Label2.TabIndex = 3
		Me.Label2.Text = "Key"
		'
		'txtKey
		'
		Me.txtKey.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtKey.Location = New System.Drawing.Point(8, 72)
		Me.txtKey.Name = "txtKey"
		Me.txtKey.Size = New System.Drawing.Size(96, 20)
		Me.txtKey.TabIndex = 2
		Me.txtKey.Text = ""
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 8)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(96, 16)
		Me.Label1.TabIndex = 1
		Me.Label1.Text = "Sub ID"
		'
		'txtSubID
		'
		Me.txtSubID.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtSubID.Location = New System.Drawing.Point(8, 24)
		Me.txtSubID.Name = "txtSubID"
		Me.txtSubID.Size = New System.Drawing.Size(96, 20)
		Me.txtSubID.TabIndex = 1
		Me.txtSubID.Text = ""
		'
		'Label3
		'
		Me.Label3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label3.Location = New System.Drawing.Point(8, 104)
		Me.Label3.Name = "Label3"
		Me.Label3.Size = New System.Drawing.Size(96, 16)
		Me.Label3.TabIndex = 3
		Me.Label3.Text = "Description"
		'
		'txtDesc
		'
		Me.txtDesc.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtDesc.Location = New System.Drawing.Point(8, 120)
		Me.txtDesc.Name = "txtDesc"
		Me.txtDesc.Size = New System.Drawing.Size(96, 20)
		Me.txtDesc.TabIndex = 3
		Me.txtDesc.Text = ""
		'
		'TabPage3
		'
		Me.TabPage3.Controls.Add(Me.lvwSchemae)
		Me.TabPage3.Controls.Add(Me.Panel3)
		Me.TabPage3.Location = New System.Drawing.Point(4, 22)
		Me.TabPage3.Name = "TabPage3"
		Me.TabPage3.Size = New System.Drawing.Size(736, 447)
		Me.TabPage3.TabIndex = 2
		Me.TabPage3.Text = "Rules"
		'
		'lvwSchemae
		'
		Me.lvwSchemae.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lvwSchemae.Dock = System.Windows.Forms.DockStyle.Fill
		Me.lvwSchemae.FullRowSelect = True
		Me.lvwSchemae.HideSelection = False
		Me.lvwSchemae.Location = New System.Drawing.Point(0, 0)
		Me.lvwSchemae.Name = "lvwSchemae"
		Me.lvwSchemae.Size = New System.Drawing.Size(736, 407)
		Me.lvwSchemae.SmallImageList = Me.ImageList1
		Me.lvwSchemae.TabIndex = 0
		Me.lvwSchemae.View = System.Windows.Forms.View.Details
		'
		'ImageList1
		'
		Me.ImageList1.ImageSize = New System.Drawing.Size(16, 16)
		Me.ImageList1.ImageStream = CType(resources.GetObject("ImageList1.ImageStream"), System.Windows.Forms.ImageListStreamer)
		Me.ImageList1.TransparentColor = System.Drawing.Color.Transparent
		'
		'Panel3
		'
		Me.Panel3.Controls.Add(Me.cmdEdit)
		Me.Panel3.Controls.Add(Me.cmdDown)
		Me.Panel3.Controls.Add(Me.cmdAdd)
		Me.Panel3.Controls.Add(Me.cmdRemove)
		Me.Panel3.Controls.Add(Me.cmdUp)
		Me.Panel3.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.Panel3.Location = New System.Drawing.Point(0, 407)
		Me.Panel3.Name = "Panel3"
		Me.Panel3.Size = New System.Drawing.Size(736, 40)
		Me.Panel3.TabIndex = 3
		'
		'cmdEdit
		'
		Me.cmdEdit.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdEdit.Location = New System.Drawing.Point(448, 8)
		Me.cmdEdit.Name = "cmdEdit"
		Me.cmdEdit.TabIndex = 3
		Me.cmdEdit.Text = "&Edit"
		'
		'frmProperties
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.ClientSize = New System.Drawing.Size(744, 513)
		Me.Controls.Add(Me.Panel2)
		Me.Controls.Add(Me.Panel1)
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmProperties"
		Me.Text = "xPLHal Properties"
		Me.Panel1.ResumeLayout(False)
		Me.Panel2.ResumeLayout(False)
		Me.TabControl1.ResumeLayout(False)
		Me.TabPage1.ResumeLayout(False)
		Me.TabPage2.ResumeLayout(False)
		Me.Panel4.ResumeLayout(False)
		Me.TabPage3.ResumeLayout(False)
		Me.Panel3.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub

#End Region




    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

    Private Sub frmProperties_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load

        ' Set up defaults
        chkAutoScript.Checked = True        
        chkEnableConfigMgr.Checked = True
        chkEnableSMTP.Checked = True
        chkContinue.Checked = False
        chkEnablexAP.Checked = False

        Dim xml As XmlTextReader
    Dim c As Construct, tn As TreeNode, tnc As TreeNode
    tn = Nothing

        lvwSchemae.Columns.Add("Msg Type", 80, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Vendor", 100, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Device", 100, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Instance", 100, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Class", 100, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Type", 100, HorizontalAlignment.Left)
        lvwSchemae.Columns.Add("Subs", 100, HorizontalAlignment.Left)


    Try
      ConfigStream = New MemoryStream(Encoding.UTF8.GetBytes(getConfigXML()))
      xml = New XmlTextReader(ConfigStream)
      While xml.Read
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "autoscripts"
                If xml.GetAttribute("create") = "N" Then
                  chkAutoScript.Checked = False
                Else
                  chkAutoScript.Checked = True
                End If
              Case "control"
                If xml.GetAttribute("loadhub") = "Y" Then
                Else

                End If
                If xml.GetAttribute("xapsupport") = "Y" Then
                  chkEnablexAP.Checked = True
                Else
                  chkEnablexAP.Checked = False
                End If
                If xml.GetAttribute("matchall") = "Y" Then
                  chkContinue.Checked = True
                Else
                  chkContinue.Checked = False
                End If
              Case "construct"
                c = New Construct
                c.Desc = xml.GetAttribute("desc")
                c.Key = xml.GetAttribute("key")
                c.SubID = xml.GetAttribute("subid")
                tn = New TreeNode
                tn.Text = c.Desc
                tn.Tag = c
                tvwConstructs.Nodes.Add(tn)
              Case "schema"
                Dim li As New ListViewItem
                Dim s As Schema
                s.MsgType = xml.GetAttribute("msgtype")
                s.Vendor = xml.GetAttribute("source_vendor")
                s.Device = xml.GetAttribute("source_device")
                s.Instance = xml.GetAttribute("source_instance")
                s.SchemaClass = xml.GetAttribute("schema_class")
                s.SchemaType = xml.GetAttribute("schema_type")
                s.Subs = xml.GetAttribute("subs")
                If xml.GetAttribute("action") = "continue" Then
                  s.[Continue] = True
                Else
                  s.[Continue] = False
                End If
                li.Tag = s
                li.Text = s.MsgType
                li.SubItems.Add(s.Vendor)
                li.SubItems.Add(s.Device)
                li.SubItems.Add(s.Instance)
                li.SubItems.Add(s.SchemaClass)
                li.SubItems.Add(s.SchemaType)
                li.SubItems.Add(s.Subs)
                lvwSchemae.Items.Add(li)
                If chkContinue.Checked Then
                  If s.[Continue] Then
                    li.ImageIndex = 0 ' continue icon
                  Else
                    li.ImageIndex = 1 ' stop icon
                  End If
                Else
                  li.ImageIndex = -1
                End If
              Case "smtp"
                If xml.GetAttribute("disablesmtp") = "Y" Then
                  chkEnableSMTP.Checked = False
                End If
              Case "values"
                tnc = New TreeNode
                c = New Construct
                c.Desc = xml.GetAttribute("desc")
                c.Key = xml.GetAttribute("key")
                tnc.Tag = c
                tnc.Text = c.Desc
                tn.Nodes.Add(tnc)
            End Select
        End Select
      End While

      IsDirty = False
    Catch ex As Exception
      MsgBox("This server does not have any properties that can be configured.", vbExclamation)
      Me.Close()
    End Try
    End Sub

    Private Sub tvwConstructs_AfterSelect(ByVal sender As System.Object, ByVal e As System.Windows.Forms.TreeViewEventArgs) Handles tvwConstructs.AfterSelect
        Dim c As Construct = CType(tvwConstructs.SelectedNode.Tag, Construct)
        txtDesc.Text = c.Desc
        If c.SubID = "" Then
            txtSubID.Visible = False
            Label1.Visible = False
        Else
            txtSubID.Text = c.SubID
            Label1.Visible = True
            txtSubID.Visible = True
        End If
        txtKey.Text = c.Key
    End Sub

    Private Sub PopulateSchemas(ByVal s As String)
        Dim i As Integer, t As String, tempstr As String
        Dim li As ListViewItem
        Dim c As Schema
        i = s.IndexOf("<schemas>") + 10
        s = s.Substring(i, s.Length - i)
        s = s.Substring(0, s.IndexOf("</schemas>")).Replace(vbCrLf, "").Trim
        While s.IndexOf(">") > 0
            t = s.Substring(0, s.IndexOf(">") + 1)
            s = s.Substring(t.Length, s.Length - t.Length)
            t = t.Trim.Replace(vbTab, "")
            If t.StartsWith("<schema") Then
                li = New ListViewItem
                tempstr = t.Substring(t.IndexOf("msgtype=") + 9)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                li.Text = tempstr
                c = New Schema
                c.MsgType = tempstr

                tempstr = t.Substring(t.IndexOf("source_vendor=") + 15)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.Vendor = tempstr
                li.SubItems.Add(c.Vendor)

                tempstr = t.Substring(t.IndexOf("source_device=") + 15)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.Device = tempstr
                li.SubItems.Add(c.Device)

                tempstr = t.Substring(t.IndexOf("source_instance=") + 17)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.Instance = tempstr
                li.SubItems.Add(c.Instance)

                tempstr = t.Substring(t.IndexOf("schema_class=") + 14)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.SchemaClass = tempstr
                li.SubItems.Add(c.SchemaClass)

                tempstr = t.Substring(t.IndexOf("schema_type=") + 13)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.SchemaType = tempstr
                li.SubItems.Add(c.SchemaType)

                tempstr = t.Substring(t.IndexOf("subs=") + 6)
                tempstr = tempstr.Substring(0, tempstr.IndexOf(""""))
                c.Subs = tempstr
                li.SubItems.Add(c.Subs)

                li.Tag = c
                lvwSchemae.Items.Add(li)
            End If
        End While
    End Sub

    Private Sub lvwSchemae_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lvwSchemae.SelectedIndexChanged
        If lvwSchemae.SelectedItems.Count = 0 Then

            Exit Sub
        End If
        Dim s As Schema = CType(lvwSchemae.SelectedItems(0).Tag, Schema)

    End Sub

    Private Sub chkEnableConfigMgr_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkEnableConfigMgr.CheckedChanged
        IsDirty = True
    End Sub

    Private Sub chkEnableXap_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkEnablexAP.CheckedChanged
        IsDirty = True
    End Sub

    
    Private Sub SaveConfigDoc()
        Try
            Dim bAutoScripts As Boolean = False, bControl As Boolean = False, bConfig As Boolean = False, bSMTP As Boolean = False
            Dim newstream As New MemoryStream
            Dim oldDepth As Integer = -1, Counter As Integer
            ConfigStream.Position = 0
            Dim xmlr As New XmlTextReader(ConfigStream)
            Dim xmlw As New XmlTextWriter(newstream, Nothing)
            xmlw.Formatting = Formatting.Indented
            xmlw.WriteStartDocument(False)
            While xmlr.Read
                Select Case xmlr.NodeType
                    Case XmlNodeType.Element
                        Select Case xmlr.Name
                            Case "schema"
                                ' DOn't write the element
                            Case Else
                                If xmlr.Depth > oldDepth Then
                                    oldDepth = xmlr.Depth
                                ElseIf xmlr.Depth < oldDepth Then
                                    xmlw.WriteEndElement()
                                    If xmlr.Name = "constructs" Then
                                        If Not bAutoScripts Then
                                            xmlw.WriteStartElement("autoscripts")
                                            If chkAutoScript.Checked Then
                                                xmlw.WriteAttributeString("create", "Y")
                                            Else
                                                xmlw.WriteAttributeString("create", "N")
                                            End If
                                            xmlw.WriteEndElement()
                                        End If
                                        If Not bControl Then
                                            xmlw.WriteStartElement("control")
                                            xmlw.WriteEndElement()
                                        End If
                                        If Not bConfig Then
                                            xmlw.WriteStartElement("config")
                                            If chkEnableConfigMgr.Checked Then
                                                xmlw.WriteAttributeString("disableconfig", "N")
                                            Else
                                                xmlw.WriteAttributeString("disableconfig", "Y")
                                            End If
                                            xmlw.WriteEndElement()
                                        End If
                                        If Not bSMTP Then
                                            xmlw.WriteStartElement("smtp")
                                            If chkEnableSMTP.Checked Then
                                                xmlw.WriteAttributeString("disablesmtp", "N")
                                            Else
                                                xmlw.WriteAttributeString("disablesmtp", "Y")
                                            End If
                                            xmlw.WriteEndElement()
                                        End If
                                    End If
                                    xmlw.WriteEndElement()
                                    oldDepth = xmlr.Depth
                                Else
                                    xmlw.WriteEndElement()
                                End If
                                xmlw.WriteStartElement(xmlr.Name)
                                Select Case xmlr.Name
                                    Case "config"
                                        bConfig = True
                                        If chkEnableConfigMgr.Checked Then
                                            xmlw.WriteAttributeString("disableconfig", "N")
                                        Else
                                            xmlw.WriteAttributeString("disableconfig", "Y")
                                        End If
                                        For Counter = 0 To xmlr.AttributeCount - 1
                                            xmlr.MoveToAttribute(Counter)
                                            If xmlr.Name = "disableconfig" Then
                                                ' Ignore it
                                            Else
                                                xmlw.WriteAttributeString(xmlr.Name, xmlr.Value)
                                            End If
                                        Next
                                    Case "autoscripts"
                                        bAutoScripts = True
                                        If chkAutoScript.Checked Then
                                            xmlw.WriteAttributeString("create", "Y")
                                        Else
                                            xmlw.WriteAttributeString("create", "N")
                                        End If
                                    Case "control"
                                        bControl = True
                                        
                                        If chkEnablexAP.Checked Then
                                            xmlw.WriteAttributeString("xapsupport", "Y")
                                        Else
                                            xmlw.WriteAttributeString("xapsupport", "N")
                                        End If
                                        If chkContinue.Checked Then
                                            xmlw.WriteAttributeString("matchall", "Y")
                                        Else
                                            xmlw.WriteAttributeString("matchall", "N")
                                        End If
                                        For Counter = 0 To xmlr.AttributeCount - 1
                                            xmlr.MoveToAttribute(Counter)
                                            Select Case xmlr.Name
                                                Case "loadhub", "xapsupport", "matchall"
                                                    ' Ignore them
                                                Case Else
                                                    xmlw.WriteAttributeString(xmlr.Name, xmlr.Value)
                                            End Select
                                        Next
                                    Case "schemas"
                                        Dim s As Schema
                                        For Counter = 0 To lvwSchemae.Items.Count - 1
                                            xmlw.WriteStartElement("schema")
                                            s = CType(lvwSchemae.Items(Counter).Tag, Schema)
                                            xmlw.WriteAttributeString("msgtype", s.MsgType)
                                            xmlw.WriteAttributeString("source_vendor", s.Vendor)
                                            xmlw.WriteAttributeString("source_device", s.Device)
                                            xmlw.WriteAttributeString("source_instance", s.Instance)
                                            xmlw.WriteAttributeString("schema_class", s.SchemaClass)
                                            xmlw.WriteAttributeString("schema_type", s.SchemaType)
                                            xmlw.WriteAttributeString("subs", s.Subs)
                                            If s.[Continue] Then
                                                xmlw.WriteAttributeString("action", "continue")
                                            Else
                                                xmlw.WriteAttributeString("action", "break")
                                            End If
                                            xmlw.WriteEndElement()
                                        Next
                                    Case "schema"
                                        ' Ignore it
                                    Case "smtp"
                                        bSMTP = True
                                        If chkEnableSMTP.Checked Then
                                            xmlw.WriteAttributeString("disablesmtp", "N")
                                        Else
                                            xmlw.WriteAttributeString("disablesmtp", "Y")
                                        End If
                                    Case Else
                                        For Counter = 0 To xmlr.AttributeCount - 1
                                            xmlr.MoveToAttribute(Counter)
                                            xmlw.WriteAttributeString(xmlr.Name, xmlr.Value)
                                        Next
                                End Select
                        End Select
                        End Select
            End While
            xmlr.Close()
            xmlw.WriteEndDocument()
            xmlw.Close()
            SaveXML(Encoding.UTF8.GetString(newstream.ToArray))
        Catch ex As Exception
            MsgBox("The changes you made to your xPLHal configuration could not be saved." & vbCrLf & "Your xplhal.xml configuration file may be corrupt, missing, or in an unrecognised format." & vbCrLf & vbCrLf & "Please edit your XML configuration document manually to correct any errors.", vbExclamation)
        End Try
        IsDirty = False


    End Sub

    Private Sub frmProperties_Closing(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles MyBase.Closing
        If IsDirty Then
            Dim ret As Integer = MsgBox("You have made changes to the properties of this xPLHal server." & vbCrLf & vbCrLf & "Do you want to save these changes?", vbQuestion Or vbYesNoCancel, "xPLHal")
            If ret = vbYes Then
                SaveConfigDoc()
            ElseIf ret = vbCancel Then
                e.Cancel = True
            End If
        End If
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        If IsDirty Then
            SaveConfigDoc()
        End If
        Me.Close()
    End Sub


    Private Sub cmdAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAdd.Click
        Dim f As New frmEditSchema
        If chkContinue.Checked Then
            f.gbxContinue.Visible = True
        Else
            f.gbxContinue.Visible = False
        End If
        f.optContinueNo.Checked = True
		If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
			Dim s As Schema
			Dim li As New ListViewItem
			IsDirty = True
			s.MsgType = f.cmbMessageType.Text
			s.Vendor = f.txtVendor.Text
			s.Device = f.txtDevice.Text
			s.Instance = f.txtInstance.Text
			s.SchemaClass = f.txtSchemaClass.Text
			s.SchemaType = f.txtSchemaType.Text
			s.Subs = f.txtSubs.Text
			s.[Continue] = f.optContinueYes.Checked

			li.Text = s.MsgType
			li.SubItems.Add(s.Vendor)
			li.SubItems.Add(s.Device)
			li.SubItems.Add(s.Instance)
			li.SubItems.Add(s.SchemaClass)
			li.SubItems.Add(s.SchemaType)
			li.SubItems.Add(s.Subs)
			If chkContinue.Checked Then
				If s.[Continue] Then
					li.ImageIndex = 0
				Else
					li.ImageIndex = 1
				End If
			Else
				li.ImageIndex = -1
			End If
			li.Tag = s
			lvwSchemae.Items.Add(li)
		End If
    End Sub

    Private Sub cmdRemove_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdRemove.Click
        For Each li As ListViewItem In lvwSchemae.SelectedItems
            li.Remove()
        Next
        IsDirty = True
    End Sub

    Private Sub cmdUp_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdUp.Click
        If lvwSchemae.SelectedItems.Count = 1 Then
            Dim li As ListViewItem, I As Integer
            li = lvwSchemae.SelectedItems(0)
            I = li.Index
            If I > 0 Then
                lvwSchemae.SelectedItems(0).Remove()
                lvwSchemae.Items.Insert(I - 1, li)
            End If
        End If
    End Sub

    Private Sub cmdDown_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdDown.Click
        If lvwSchemae.SelectedItems.Count = 1 Then
            Dim li As ListViewItem, I As Integer
            li = lvwSchemae.SelectedItems(0)
            I = li.Index
            If I < lvwSchemae.Items.Count - 1 Then
                lvwSchemae.SelectedItems(0).Remove()
                lvwSchemae.Items.Insert(I + 1, li)
            End If
        End If
    End Sub

    Private Sub cmdEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEdit.Click
        If lvwSchemae.SelectedItems.Count = 1 Then
            Dim f As New frmEditSchema
            Dim s As Schema = CType(lvwSchemae.SelectedItems(0).Tag, Schema)
            f.cmbMessageType.Text = s.MsgType
            f.txtVendor.Text = s.Vendor
            f.txtDevice.Text = s.Device
            f.txtInstance.Text = s.Instance
            f.txtSchemaClass.Text = s.SchemaClass
            f.txtSchemaType.Text = s.SchemaType
            f.txtSubs.Text = s.Subs
            If chkContinue.Checked Then
                f.gbxContinue.Visible = True
            Else
                f.gbxContinue.Visible = False
            End If
            If s.[Continue] Then
                f.optContinueYes.Checked = True
            Else
                f.optContinueNo.Checked = True
            End If
			If f.ShowDialog() = Windows.Forms.DialogResult.OK Then
				' Update the list item
				IsDirty = True
				s.MsgType = f.cmbMessageType.Text
				s.Vendor = f.txtVendor.Text
				s.Device = f.txtDevice.Text
				s.Instance = f.txtInstance.Text
				s.SchemaClass = f.txtSchemaClass.Text
				s.SchemaType = f.txtSchemaType.Text
				s.Subs = f.txtSubs.Text
				s.[Continue] = f.optContinueYes.Checked
				With lvwSchemae.SelectedItems(0)
					.Tag = s
					.Text = s.MsgType
					.SubItems(1).Text = s.Vendor
					.SubItems(2).Text = s.Device
					.SubItems(3).Text = s.Instance
					.SubItems(4).Text = s.SchemaClass
					.SubItems(5).Text = s.SchemaType
					.SubItems(6).Text = s.Subs
					If chkContinue.Checked Then
						If s.[Continue] Then
							.ImageIndex = 0
						Else
							.ImageIndex = 1
						End If
					Else
						.ImageIndex = -1
					End If
				End With
			End If
        End If
    End Sub

    Private Sub chkContinue_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkContinue.CheckedChanged
        IsDirty = True
    End Sub

    Private Sub TabControl1_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TabControl1.SelectedIndexChanged
        Dim s As Schema, li As ListViewItem
        For Each li In lvwSchemae.Items
            If chkContinue.Checked Then
                s = CType(li.Tag, Schema)
                If s.[Continue] Then
                    li.ImageIndex = 0 ' continue icon
                Else
                    li.ImageIndex = 1 ' stop icon
                End If
            Else
                li.ImageIndex = -1
            End If
        Next

    End Sub

    Private Sub chkAutoScript_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkAutoScript.CheckedChanged
        IsDirty = True
    End Sub

End Class
