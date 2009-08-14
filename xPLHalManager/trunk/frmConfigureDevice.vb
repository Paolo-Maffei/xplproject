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

Public Class frmConfigureDevice
    Inherits xplhalMgrBase

    Private ConfigItems() As ConfigItem
    Private DevicePlugin As Plugin
    Private FirstActivate As Boolean = True



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
    Friend WithEvents lstConfigItems As System.Windows.Forms.ListBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents txtValue As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents txtDescription As System.Windows.Forms.TextBox
    Friend WithEvents cmbItem As System.Windows.Forms.ComboBox
    Friend WithEvents lblItem As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmConfigureDevice))
		Me.lstConfigItems = New System.Windows.Forms.ListBox
		Me.txtValue = New System.Windows.Forms.TextBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.Label2 = New System.Windows.Forms.Label
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.txtDescription = New System.Windows.Forms.TextBox
		Me.lblItem = New System.Windows.Forms.Label
		Me.cmbItem = New System.Windows.Forms.ComboBox
		Me.SuspendLayout()
		'
		'lstConfigItems
		'
		Me.lstConfigItems.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.lstConfigItems.Location = New System.Drawing.Point(8, 24)
		Me.lstConfigItems.Name = "lstConfigItems"
		Me.lstConfigItems.Size = New System.Drawing.Size(160, 236)
		Me.lstConfigItems.TabIndex = 0
		'
		'txtValue
		'
		Me.txtValue.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtValue.Location = New System.Drawing.Point(176, 72)
		Me.txtValue.Name = "txtValue"
		Me.txtValue.Size = New System.Drawing.Size(176, 20)
		Me.txtValue.TabIndex = 1
		Me.txtValue.Text = ""
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(176, 56)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(160, 16)
		Me.Label1.TabIndex = 2
		Me.Label1.Text = "Value"
		'
		'Label2
		'
		Me.Label2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label2.Location = New System.Drawing.Point(8, 8)
		Me.Label2.Name = "Label2"
		Me.Label2.Size = New System.Drawing.Size(160, 16)
		Me.Label2.TabIndex = 3
		Me.Label2.Text = "Configurable Items"
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(264, 240)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 6
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(176, 240)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 5
		Me.cmdOK.Text = "OK"
		'
		'txtDescription
		'
		Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtDescription.Dock = System.Windows.Forms.DockStyle.Bottom
		Me.txtDescription.Location = New System.Drawing.Point(0, 271)
		Me.txtDescription.Multiline = True
		Me.txtDescription.Name = "txtDescription"
		Me.txtDescription.ReadOnly = True
		Me.txtDescription.Size = New System.Drawing.Size(362, 72)
		Me.txtDescription.TabIndex = 7
		Me.txtDescription.Text = ""
		'
		'lblItem
		'
		Me.lblItem.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblItem.Location = New System.Drawing.Point(176, 8)
		Me.lblItem.Name = "lblItem"
		Me.lblItem.Size = New System.Drawing.Size(160, 16)
		Me.lblItem.TabIndex = 8
		Me.lblItem.Text = "Pick item from list:"
		'
		'cmbItem
		'
		Me.cmbItem.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbItem.Location = New System.Drawing.Point(176, 24)
		Me.cmbItem.Name = "cmbItem"
		Me.cmbItem.Size = New System.Drawing.Size(176, 21)
		Me.cmbItem.TabIndex = 9
		'
		'frmConfigureDevice
		'
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(362, 343)
		Me.Controls.Add(Me.cmbItem)
		Me.Controls.Add(Me.lblItem)
		Me.Controls.Add(Me.txtDescription)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.cmdOK)
		Me.Controls.Add(Me.Label2)
		Me.Controls.Add(Me.Label1)
		Me.Controls.Add(Me.txtValue)
		Me.Controls.Add(Me.lstConfigItems)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmConfigureDevice"
		Me.Text = "Configure Device"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Private pDevName As String
    Public FirstConfig As Boolean

    Public Property DevName() As String
        Get
            Return pDevName
        End Get
        Set(ByVal Value As String)
            pDevName = Value
            Me.Text = "Configure Device " & pDevName
            If Not GetDeviceInfo() Then
                pDevName = ""
            End If
        End Set
    End Property

    Private Function GetDeviceInfo() As Boolean
        Dim str, lhs, rhs As String
        Dim ItemCount As Integer
        Dim Counter As Integer
        connectToXplHal()
        xplHalSend("GETDEVCONFIG " & pDevName & vbCrLf)
        str = getLine
        ReDim ConfigItems(-1)
        If str.StartsWith("217") Then
            str = getLine
            While Not str = ("." & vbCrLf) And Not str = "" And Not str.StartsWith("503 ")
                If str.IndexOf(vbTab) > 0 Then
                    lhs = str.Substring(0, str.IndexOf(vbTab))
                    rhs = str.Substring(str.IndexOf(vbTab) + 1, str.Length - str.IndexOf(vbTab) - 1)
                    If rhs.IndexOf(vbTab) > 0 Then
                        If IsNumeric(rhs.Substring(rhs.IndexOf(vbTab) + 1, rhs.Length - rhs.IndexOf(vbTab) - 1)) Then
                            ItemCount = CInt(rhs.Substring(rhs.IndexOf(vbTab) + 1, rhs.Length - rhs.IndexOf(vbTab) - 1))
                        Else
                            ItemCount = 1
                        End If
                        rhs = rhs.Substring(0, rhs.IndexOf(vbTab))
                    Else
                        ItemCount = 1
                    End If
                    ReDim Preserve ConfigItems(ConfigItems.Length)
                    ConfigItems(ConfigItems.Length - 1).cName = lhs
                    ConfigItems(ConfigItems.Length - 1).confType = rhs
                    ReDim ConfigItems(ConfigItems.Length - 1).cValues(ItemCount - 1)
                End If
                str = GetLine
            End While
            If str.StartsWith("503 ") Then
                Throw New Exception(str)
            End If
        ElseIf str.StartsWith("416") Then
            Throw New Exception("The selected device does not support remote configuration. Please consult the documentation for the device to determine how it can be configured.")
        ElseIf str.StartsWith("417") Then
      Throw New Exception("The selected device does not exist.")
    ElseIf str.StartsWith("418") Then
      Throw New Exception("No information is currently available about this device." & vbCrLf & vbCrLf & "The device has not issued a config.list message, therefore xPLHal is not aware of which items can be configured.")
    Else
      globals.Unexpected(str)
      Return False
    End If

    ' Populate with current values
    For Counter = 0 To ConfigItems.Length - 1
      If ConfigItems(Counter).cName = "newconf" Then
        ConfigItems(Counter).cValues(0) = pDevName.Substring(pDevName.IndexOf(".") + 1, pDevName.Length - pDevName.IndexOf(".") - 1)
      Else
        xplhalsend("GETDEVCONFIGVALUE " & pDevName & " " & ConfigItems(Counter).cName & vbCrLf)
        str = getLine
        If str.StartsWith("234") Then
          str = getLine
          Dim COunter2 As Integer = 0
          While Not str = "" And Not str = ("." & vbCrLf)            
            If str.IndexOf("=") > 0 Then
              lhs = str.Substring(str.IndexOf("=") + 1, str.Length - str.IndexOf("=") - 1).Replace(vbCrLf, "")
              If COunter2 >= ConfigItems(Counter).cValues.Length Then
                MsgBox("Warning: xPLHal sent more configuration values than we were expecting - some will be ignored." & vbCrLf & vbCrLf & "This usually occurs if you have recently upgraded this device to a newer version, where there are differences in the range of supported configuration items." & vbCrLf & vbCrLf & "You can usually ignore this warning, but please check the configuration values when the dialog appears to make sure they are all correct.")
              Else
                ConfigItems(Counter).cValues(COunter2) = lhs
              End If
              COunter2 += 1
            End If
              str = getLine
          End While
        End If
      End If
    Next
    Disconnect()

    ' Populate the combo
    cmbItem.Visible = False
    lblItem.Visible = False
    lstConfigItems.BeginUpdate()
    lstConfigItems.Items.Clear()
    For Counter = 0 To ConfigItems.Length - 1
      If Not FirstConfig Or ConfigItems(Counter).confType.ToLower <> "config" Then
        lstConfigItems.Items.Add(ConfigItems(Counter).cName)
      End If
    Next
    lstConfigItems.EndUpdate()

    ' See if this device has a plugin
    Dim DeviceID As String = pDevName.Substring(0, pDevName.IndexOf("."))
    For Counter = 0 To globals.Plugins.Length - 1
      If DeviceID = Plugins(Counter).DeviceID Then
        DevicePlugin = Plugins(Counter)
      End If
    Next
    Return True
    End Function

    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

    Private Sub lstConfigItems_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstConfigItems.SelectedIndexChanged
        Dim FOundMatch As Boolean = False
        txtValue.Text = ""
        txtDescription.Text = ""
        If lstConfigItems.SelectedItem Is Nothing Then Exit Sub
        Dim CurrentItem As String = CStr(lstConfigItems.SelectedItem)
        For Counter As Integer = 0 To ConfigItems.Length - 1
            If ConfigItems(Counter).cName = CurrentItem Then
                If ConfigItems(Counter).cValues.Length = 1 Then
                    lblItem.Visible = False
                    cmbItem.Visible = False
                    txtValue.Text = ConfigItems(Counter).cValues(0)
                    FOundMatch = True
                ElseIf ConfigItems(Counter).cValues.Length > 1 Then
                    FOundMatch = True
                    lblItem.Visible = True
                    cmbItem.Items.Clear()
                    For Counter2 As Integer = 1 To ConfigItems(counter).cValues.Length
            cmbItem.Items.Add(ConfigItems(counter).cName & " [" & Counter2 & "]")
                    Next
                    cmbItem.SelectedIndex = 0
                    cmbItem.Visible = True
                    txtValue.Text = ConfigItems(counter).cValues(0)
                End If
                Exit For
            End If
        Next
        CurrentItem = CurrentItem.ToLower
        Select Case CurrentItem
            Case "newconf"
                txtDescription.Text = "Enter the name that will be used to identify this device on the xPL network."
            Case "interval"
        txtDescription.Text = "Specify the number of minutes between heartbeat messages. The value should be between 5 and 9."
            Case Else
                If Not DevicePlugin Is Nothing Then
                    For Counter As Integer = 0 To DevicePlugin.ConfigItems.Length - 1
                        If CurrentItem = DevicePlugin.ConfigItems(counter).Name Then
                            txtDescription.Text = DevicePlugin.ConfigItems(counter).Description
                            Exit For
                        End If
                    Next
                End If
        End Select
    End Sub

    Private Sub txtValue_LostFocus(ByVal sender As Object, ByVal e As System.EventArgs) Handles txtValue.LostFocus
        Dim CurrentItem As String = CStr(lstConfigItems.SelectedItem)
        Dim Counter As Integer
        Select Case CurrentItem
            Case "group"
                If Not txtValue.Text = "" And Not RegularExpressions.Regex.IsMatch(txtValue.Text.ToLower, "^xpl-group\.[a-z0-9]{1,16}$") Then
                    MsgBox("All xPL groups must be in the form of xpl-group.<group_name>", vbInformation)
                    Exit Sub
                End If
            Case "interval"
                If txtValue.Text = "" Then
                    txtValue.Text = "5"
                ElseIf Not IsNumeric(txtValue.Text) Then
                    MsgBox("You must enter a numeric value.", vbExclamation)
                    Exit Sub
        ElseIf CInt(txtValue.Text) < 5 Or CInt(txtValue.Text) > 9 Then
          MsgBox("Heartbeat intervals must be between 5 and 9 minutes.", vbExclamation)
          Exit Sub
        End If
            Case "newconf"
                If txtValue.Text.ToLower.Trim = "default" Then
                    MsgBox("You must change the instance name to something other than default.", vbExclamation)
                    Exit Sub
                End If
                If Not RegularExpressions.Regex.IsMatch(txtValue.Text, "^[A-Za-z0-9]{1,16}$") Then
                    MsgBox("The instance name is invalid." & vbCrLf & vbCrLf & "Instance names may only contain alphanumeric characters, and must be no longer than 16 characters in length.", vbInformation)
                    Exit Sub
                End If
            Case Else
                    If Not txtValue.Text = "" And Not DevicePlugin Is Nothing Then
                        For Counter = 0 To DevicePlugin.ConfigItems.Length - 1
                            If DevicePlugin.ConfigItems(Counter).Name = CurrentItem Then
                                If Not DevicePlugin.ConfigItems(Counter).FormatRegEx = "" Then
                                    If Not RegularExpressions.Regex.IsMatch(txtValue.Text, DevicePlugin.ConfigItems(Counter).FormatRegEx) Then
                                        MsgBox("The value for this configuration item is invalid.", vbExclamation)
                                        Exit Sub
                                    End If
                                End If
                            End If
                        Next
                    End If
        End Select
        For Counter = 0 To ConfigItems.Length - 1
            If CurrentItem = ConfigItems(Counter).cName Then
                ' Validate the item
                If cmbItem.Visible Then
                    ConfigItems(Counter).cValues(cmbItem.SelectedIndex) = txtValue.Text
                Else
                    ConfigItems(Counter).cValues(0) = txtValue.Text
                End If
                Exit For
            End If
        Next
    End Sub

    Private Sub SaveConfig()
        Dim str As String
        connectToXplHal()
        xplHalSend("PUTDEVCONFIG " & pDevName & vbCrLf)
        str = getLine
        If str.StartsWith("320") Then
            For Counter As Integer = 0 To ConfigItems.Length - 1
                For COunter2 As Integer = 0 To ConfigItems(Counter).cValues.Length - 1
                    If COunter2 = 0 Or ConfigItems(Counter).cValues(COunter2) <> "" Then
                        xplHalSend(ConfigItems(Counter).cName & "=" & ConfigItems(Counter).cValues(COunter2) & vbCrLf)
                    End If
                Next
            Next
            xplHalSend("." & vbCrLf)
            str = getLine
            If Not str.StartsWith("220") Then
                globals.Unexpected(str)
            End If
        End If
        Disconnect()
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        For Counter As Integer = 0 To ConfigItems.Length - 1
            If ConfigItems(Counter).cName.ToLower = "newconf" Then
                If ConfigItems(Counter).cValues(0).ToLower.Trim = "default" Then
                    MsgBox("You must change the instance name (newconf) to something other than default.", vbExclamation)
                    Exit Sub
                End If
            End If
        Next
        SaveConfig()
        Me.Close()
    End Sub

    Private Sub frmConfigureDevice_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Activated
        If FirstActivate Then
            FirstActivate = False
            Windows.Forms.Cursor.Current = Cursors.Default
            If lstConfigItems.Items.Count > 0 Then
                lstConfigItems.SelectedIndex = 0
            End If
        End If
    End Sub

    Private Sub cmbItem_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbItem.SelectedIndexChanged
        Dim CurrentItem As String = CStr(lstConfigItems.SelectedItem)
        For Counter As Integer = 0 To ConfigItems.Length - 1
            If CurrentItem = ConfigItems(Counter).cName Then
                txtValue.Text = ConfigItems(Counter).cValues(cmbItem.SelectedIndex)
            End If
        Next
    End Sub


End Class
