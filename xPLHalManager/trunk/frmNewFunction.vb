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

Public Class frmNewFunction
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
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmbFunction As System.Windows.Forms.ComboBox
    Friend WithEvents txtItem1 As System.Windows.Forms.TextBox
    Friend WithEvents txtItem2 As System.Windows.Forms.TextBox
    Friend WithEvents txtItem3 As System.Windows.Forms.TextBox
    Friend WithEvents cmbItem1 As System.Windows.Forms.ComboBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents lblItem1 As System.Windows.Forms.Label
    Friend WithEvents lblItem2 As System.Windows.Forms.Label
    Friend WithEvents lblItem3 As System.Windows.Forms.Label
    Friend WithEvents lblItem4 As System.Windows.Forms.Label
    Friend WithEvents dtpItem4 As System.Windows.Forms.DateTimePicker
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmNewFunction))
		Me.cmdCancel = New System.Windows.Forms.Button
		Me.cmdOK = New System.Windows.Forms.Button
		Me.cmbFunction = New System.Windows.Forms.ComboBox
		Me.txtItem1 = New System.Windows.Forms.TextBox
		Me.txtItem2 = New System.Windows.Forms.TextBox
		Me.txtItem3 = New System.Windows.Forms.TextBox
		Me.cmbItem1 = New System.Windows.Forms.ComboBox
		Me.Label1 = New System.Windows.Forms.Label
		Me.lblItem1 = New System.Windows.Forms.Label
		Me.lblItem2 = New System.Windows.Forms.Label
		Me.lblItem3 = New System.Windows.Forms.Label
		Me.lblItem4 = New System.Windows.Forms.Label
		Me.dtpItem4 = New System.Windows.Forms.DateTimePicker
		Me.SuspendLayout()
		'
		'cmdCancel
		'
		Me.cmdCancel.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
		Me.cmdCancel.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdCancel.Location = New System.Drawing.Point(440, 264)
		Me.cmdCancel.Name = "cmdCancel"
		Me.cmdCancel.TabIndex = 6
		Me.cmdCancel.Text = "Cancel"
		'
		'cmdOK
		'
		Me.cmdOK.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.cmdOK.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.cmdOK.Location = New System.Drawing.Point(360, 264)
		Me.cmdOK.Name = "cmdOK"
		Me.cmdOK.TabIndex = 5
		Me.cmdOK.Text = "OK"
		'
		'cmbFunction
		'
		Me.cmbFunction.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cmbFunction.Location = New System.Drawing.Point(8, 24)
		Me.cmbFunction.Name = "cmbFunction"
		Me.cmbFunction.Size = New System.Drawing.Size(504, 21)
		Me.cmbFunction.TabIndex = 0
		'
		'txtItem1
		'
		Me.txtItem1.Location = New System.Drawing.Point(8, 80)
		Me.txtItem1.Name = "txtItem1"
		Me.txtItem1.Size = New System.Drawing.Size(504, 20)
		Me.txtItem1.TabIndex = 1
		Me.txtItem1.Text = ""
		Me.txtItem1.Visible = False
		'
		'txtItem2
		'
		Me.txtItem2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtItem2.Location = New System.Drawing.Point(8, 128)
		Me.txtItem2.Name = "txtItem2"
		Me.txtItem2.Size = New System.Drawing.Size(504, 20)
		Me.txtItem2.TabIndex = 2
		Me.txtItem2.Text = ""
		Me.txtItem2.Visible = False
		'
		'txtItem3
		'
		Me.txtItem3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
		Me.txtItem3.Location = New System.Drawing.Point(8, 176)
		Me.txtItem3.Name = "txtItem3"
		Me.txtItem3.Size = New System.Drawing.Size(504, 20)
		Me.txtItem3.TabIndex = 3
		Me.txtItem3.Text = ""
		Me.txtItem3.Visible = False
		'
		'cmbItem1
		'
		Me.cmbItem1.Location = New System.Drawing.Point(8, 80)
		Me.cmbItem1.Name = "cmbItem1"
		Me.cmbItem1.Size = New System.Drawing.Size(504, 21)
		Me.cmbItem1.TabIndex = 1
		Me.cmbItem1.Visible = False
		'
		'Label1
		'
		Me.Label1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.Label1.Location = New System.Drawing.Point(8, 8)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(504, 16)
		Me.Label1.TabIndex = 23
		Me.Label1.Text = "Function"
		'
		'lblItem1
		'
		Me.lblItem1.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblItem1.Location = New System.Drawing.Point(8, 64)
		Me.lblItem1.Name = "lblItem1"
		Me.lblItem1.Size = New System.Drawing.Size(504, 16)
		Me.lblItem1.TabIndex = 24
		Me.lblItem1.Text = "Function"
		Me.lblItem1.Visible = False
		'
		'lblItem2
		'
		Me.lblItem2.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblItem2.Location = New System.Drawing.Point(8, 112)
		Me.lblItem2.Name = "lblItem2"
		Me.lblItem2.Size = New System.Drawing.Size(504, 16)
		Me.lblItem2.TabIndex = 25
		Me.lblItem2.Text = "Function"
		Me.lblItem2.Visible = False
		'
		'lblItem3
		'
		Me.lblItem3.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblItem3.Location = New System.Drawing.Point(8, 160)
		Me.lblItem3.Name = "lblItem3"
		Me.lblItem3.Size = New System.Drawing.Size(504, 16)
		Me.lblItem3.TabIndex = 26
		Me.lblItem3.Text = "Function"
		Me.lblItem3.Visible = False
		'
		'lblItem4
		'
		Me.lblItem4.FlatStyle = System.Windows.Forms.FlatStyle.System
		Me.lblItem4.Location = New System.Drawing.Point(8, 208)
		Me.lblItem4.Name = "lblItem4"
		Me.lblItem4.Size = New System.Drawing.Size(504, 16)
		Me.lblItem4.TabIndex = 27
		Me.lblItem4.Text = "Function"
		Me.lblItem4.Visible = False
		'
		'dtpItem4
		'
		Me.dtpItem4.CustomFormat = "ddd d MMM yyyy HH:mm"
		Me.dtpItem4.Format = System.Windows.Forms.DateTimePickerFormat.Custom
		Me.dtpItem4.Location = New System.Drawing.Point(8, 224)
		Me.dtpItem4.Name = "dtpItem4"
		Me.dtpItem4.Size = New System.Drawing.Size(504, 20)
		Me.dtpItem4.TabIndex = 4
		'
		'frmNewFunction
		'
		Me.AcceptButton = Me.cmdOK
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.CancelButton = Me.cmdCancel
		Me.ClientSize = New System.Drawing.Size(520, 293)
		Me.Controls.Add(Me.dtpItem4)
		Me.Controls.Add(Me.lblItem4)
		Me.Controls.Add(Me.lblItem3)
		Me.Controls.Add(Me.lblItem2)
		Me.Controls.Add(Me.lblItem1)
		Me.Controls.Add(Me.Label1)
		Me.Controls.Add(Me.cmbItem1)
		Me.Controls.Add(Me.txtItem3)
		Me.Controls.Add(Me.txtItem2)
		Me.Controls.Add(Me.txtItem1)
		Me.Controls.Add(Me.cmbFunction)
		Me.Controls.Add(Me.cmdCancel)
		Me.Controls.Add(Me.cmdOK)
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
		Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
		Me.Name = "frmNewFunction"
		Me.Text = "New Function"
		Me.ResumeLayout(False)

	End Sub

#End Region

    Public i As functionitem

    Private Sub frmNewFunction_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load
        i = New FunctionItem
        i.pName = ""
        dtpItem4.Visible = False
        cmbFunction.Sorted = True
        ' Load plugin functions
        For Counter As Integer = 0 To globals.Plugins.Length - 1
            For Counter2 As Integer = 0 To globals.Plugins(Counter).Functions.Length - 1
                cmbFunction.Items.Add(globals.Plugins(Counter).Functions(Counter2).fName)
            Next
        Next
    End Sub

    Private Sub cmbFunction_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmbFunction.SelectedIndexChanged                    
                For Counter As Integer = 0 To globals.Plugins.Length - 1
                    For Counter2 As Integer = 0 To globals.Plugins(counter).Functions.Length - 1
                        If globals.Plugins(Counter).Functions(Counter2).fName = cmbFunction.Text Then                            
                            With globals.Plugins(Counter).Functions(Counter2)
                                ' Setup item1
                                lblItem1.Visible = True
                                lblItem1.Text = .Item1Text
                                txtItem1.Visible = False
                                cmbItem1.Visible = False
                                Select Case .Item1Type
                                    Case "textbox"
                                        txtItem1.Text = .Item1Val
                                        txtItem1.Visible = True
                                        txtItem1.Enabled = True
                                    Case "combobox", "dropdownlist"
                                        cmbItem1.Items.Clear()
                                        If .Item1Type = "dropdownlist" Then
                                            cmbItem1.DropDownStyle = ComboBoxStyle.DropDownList
                                        Else
                                            cmbItem1.DropDownStyle = ComboBoxStyle.DropDown
                                        End If
                                        Select Case GetWord(.Item1DS)
                                            Case "list"
                                                Dim tempstr As String = .Item1DS
                                                tempstr = tempstr.Substring(tempstr.IndexOf(":") + 1, tempstr.Length - tempstr.IndexOf(":") - 1)
                                                Dim listItems() As String = tempstr.Split(CChar(","))
                                                For Counter3 As Integer = 0 To listItems.Length - 1
                                                    cmbItem1.Items.Add(listItems(counter3))
                                                Next
                                            Case "modes"
                                                For Counter3 As Integer = 0 To globals.Modes.Length - 1
                                                    cmbItem1.Items.Add(globals.Modes(Counter3).name)
                                                Next
                                            Case "periods"
                                                For Counter3 As Integer = 0 To globals.Periods.Length - 1
                                                    cmbItem1.Items.Add(globals.Periods(Counter3).name)
                                                Next
                                            Case "subs"
                                                populateSubs(cmbItem1)
                                            Case "xpldevices"
                                                populateTargets(cmbItem1)
                                        End Select
                                        cmbItem1.Visible = True
                                        If cmbItem1.DropDownStyle = ComboBoxStyle.DropDown Then
                                            cmbItem1.Text = .Item1Val
                                        End If
                                End Select

                                ' Setup item2
                                lblItem2.Text = .Item2Text
                                lblItem2.Visible = True
                                txtItem2.Visible = False
                                Select Case .Item2Type
                                    Case "textbox"
                                        txtItem2.Text = .Item2Val
                                        txtItem2.Visible = True
                                        txtItem2.Enabled = True
                                End Select

                                ' Setup item3
                                lblItem3.Text = .Item3Text
                                txtItem3.Visible = False
                                txtItem3.Enabled = True
                                lblItem3.Visible = True
                                Select Case .item3type
                                    Case "textbox"
                                        txtItem3.Text = .Item3Val
                                        txtItem3.Visible = True
                                        txtItem3.Enabled = True
                                End Select

                                ' Setup item4
                                lblItem4.Text = .Item4Text
                                dtpItem4.Visible = False
                                lblItem4.Visible = True
                                Select Case .item4type
                                    Case "datetime"
                                        dtpItem4.Visible = True
                                End Select
                            End With
                            Exit For
                        End If
                    Next
                Next        
    End Sub

    Private Sub cmdOK_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdOK.Click        
                For Counter As Integer = 0 To globals.Plugins.Length - 1
                    For Counter2 As Integer = 0 To globals.Plugins(Counter).Functions.Length - 1
                        If cmbFunction.Text = globals.Plugins(Counter).Functions(Counter2).fName Then
                            With globals.Plugins(Counter).Functions(Counter2)
                                i.pName = .DisplayText
                                i.CodeText = .CodeText
                                ' Process item1
                                Select Case .Item1Type
                                    Case "combobox", "dropdownlist"
                                        i.pName = i.pName.Replace("%item1%", cmbItem1.Text)
                                        i.CodeText = i.CodeText.Replace("%item1%", cmbItem1.Text)
                                    Case "textbox"
                                        i.pName = i.pName.Replace("%item1%", txtItem1.Text)
                                        i.CodeText = i.CodeText.Replace("%item1%", txtItem1.Text)
                                End Select
                                ' Process item2
                                Select Case .Item2Type
                                    Case "textbox"
                                        i.pName = i.pName.Replace("%item2%", txtItem2.Text)
                                        i.CodeText = i.CodeText.Replace("%item2%", txtItem2.Text)
                                End Select
                                ' Process item3
                                Select Case .item3type
                                    Case "textbox"
                                        i.pName = i.pName.Replace("%item3%", txtItem3.Text)
                                        i.CodeText = i.CodeText.Replace("%item3%", txtItem3.Text)
                                End Select

                                ' Process item4
                                Select Case .item4type
                                    Case "datetime"
                                        i.pName = i.pName.Replace("%item4%", dtpItem4.Value.ToString("dd/MMM/yyyy HH:mm"))
                                        i.CodeText = i.CodeText.Replace("%item4%", dtpItem4.Value.ToString("dd/MMM/yyyy HH:mm"))
                                End Select
                            End With
                        End If
                    Next
                Next
        Me.Close()
    End Sub

    Private Function GetWord(ByVal s As String) As String
        Dim i As Integer = s.IndexOf(":")
        If i > 0 Then
            Return s.Substring(0, i)
        Else
            Return s
        End If
    End Function

End Class
