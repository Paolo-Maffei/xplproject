VERSION 5.00
Begin VB.Form RedRatIR 
   Caption         =   "RedRat2 IR Database"
   ClientHeight    =   3720
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   9540
   Icon            =   "RedRatIR.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3720
   ScaleWidth      =   9540
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   7920
      TabIndex        =   13
      Top             =   2280
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.CommandButton cmdReload 
      Caption         =   "&Reload"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6120
      TabIndex        =   12
      Top             =   240
      Width           =   1335
   End
   Begin VB.CommandButton cmdTest 
      Caption         =   "&Test"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6000
      TabIndex        =   11
      Top             =   1800
      Width           =   1215
   End
   Begin VB.CommandButton cmdLearn 
      Caption         =   "&Learn"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   7920
      TabIndex        =   10
      Top             =   1800
      Width           =   1215
   End
   Begin VB.CommandButton cmdSave 
      Caption         =   "&Save"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   7920
      TabIndex        =   9
      Top             =   3000
      Width           =   1215
   End
   Begin VB.CommandButton cmdNew 
      Caption         =   "&New"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3240
      TabIndex        =   8
      Top             =   3000
      Width           =   1215
   End
   Begin VB.CommandButton cmdDelete 
      Caption         =   "Delete"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   960
      TabIndex        =   7
      Top             =   3000
      Width           =   1215
   End
   Begin VB.TextBox txtIrCode 
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   4
      Top             =   1440
      Width           =   9255
   End
   Begin VB.TextBox txtButton 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   5760
      TabIndex        =   3
      Top             =   840
      Width           =   1815
   End
   Begin VB.TextBox txtDevice 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   1920
      TabIndex        =   2
      Top             =   840
      Width           =   1815
   End
   Begin VB.ComboBox cmbCodes 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   315
      Left            =   1800
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   240
      Width           =   3975
   End
   Begin VB.Label Label3 
      Caption         =   "Button Name"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4320
      TabIndex        =   6
      Top             =   840
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Device Name"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   360
      TabIndex        =   5
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Select IrCode"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   240
      TabIndex        =   1
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "RedRatIR"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************
'* xPL RedRat2
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
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

Option Explicit

Private Sub cmbCodes_Click()

    ' find command
    If cmbCodes.ListIndex = -1 Then
        txtDevice = ""
        txtDevice.Enabled = False
        txtButton = ""
        txtButton.Enabled = False
        txtIrCode = ""
        cmdDelete.Enabled = False
        cmdLearn.Enabled = False
    Else
        txtDevice = RedRat2(cmbCodes.ListIndex + 1).Device
        txtDevice.Enabled = True
        txtButton = RedRat2(cmbCodes.ListIndex + 1).Button
        txtButton.Enabled = True
        txtIrCode = RedRat2(cmbCodes.ListIndex + 1).IRCode
        cmdDelete.Enabled = True
        cmdLearn.Enabled = True
    End If

End Sub

Private Sub cmdCancel_Click()

    ' cancel
    LearnCancel = True
    xPL_Template.xPLCOM.Output = "[T]"
    cmdCancel.Visible = False
    
End Sub

Private Sub cmdDelete_Click()

    Dim x As Integer
    Dim y As Integer

    ' delete
    If MsgBox("Delete '" + cmbCodes.Text + "'?", vbYesNo + vbDefaultButton2 + vbQuestion, "Confirm Delete") = vbNo Then Exit Sub
    
    ' do it
    If cmbCodes.ListIndex + 1 <> RedRatCodes Then
        y = cmbCodes.ListIndex + 1
        For x = y + 1 To RedRatCodes
            RedRat2(x - 1).Device = RedRat2(x).Device
            RedRat2(x - 1).Button = RedRat2(x).Button
            RedRat2(x - 1).IRCode = RedRat2(x).IRCode
        Next x
    End If
    RedRatCodes = RedRatCodes - 1
    ReDim Preserve RedRat2(RedRatCodes) As RedRat
    Call SortIRCodes("", "")
    cmdSave.Enabled = True
    
End Sub

Private Sub cmdLearn_Click()

    ' learn
    cmbCodes.Enabled = False
    txtDevice.Locked = True
    txtButton.Locked = True
    cmdDelete.Enabled = False
    cmdNew.Enabled = False
    cmdTest.Enabled = False
    cmdLearn.Enabled = False
    cmdSave.Enabled = False
    cmdReload.Enabled = False
    Learning = True
    cmdCancel.Visible = True
    xPL_Template.xPLCOM.Output = "[S]"
    
End Sub

Private Sub cmdNew_Click()

    Dim strDevice As String
    Dim strButton As String
    
    ' add new
    RedRatCodes = RedRatCodes + 1
    ReDim Preserve RedRat2(RedRatCodes) As RedRat
    RedRat2(RedRatCodes).Device = "DEVICE"
    If cmbCodes.ListIndex <> -1 Then RedRat2(RedRatCodes).Device = RedRat2(cmbCodes.ListIndex + 1).Device
    RedRat2(RedRatCodes).Button = "newbutton"
    RedRat2(RedRatCodes).IRCode = ""
    strDevice = RedRat2(RedRatCodes).Device
    strButton = RedRat2(RedRatCodes).Button

    ' reload
    Call SortIRCodes(strDevice, strButton)
    cmdSave.Enabled = True

End Sub

Private Sub cmdReload_Click()

    Dim strDevice As String
    Dim strButton As String
    
    ' confirm
    If MsgBox("Reload IR Database File (looses any changes)?", vbYesNo + vbDefaultButton2 + vbQuestion, "Confirm Reload") = vbNo Then Exit Sub
    
    ' reload
    Call LoadIRDatabase
    If cmbCodes.ListIndex > -1 Then
        strDevice = RedRat2(cmbCodes.ListIndex + 1).Device
        strButton = RedRat2(cmbCodes.ListIndex + 1).Button
    End If
    Call SortIRCodes(strDevice, strButton)
    cmdSave.Enabled = False
    
End Sub

Private Sub cmdSave_Click()

    Dim x As Integer

    ' save current
    Open RedRatPath For Output As #1
    For x = 1 To RedRatCodes
        Print #1, RedRat2(x).Device & "," & RedRat2(x).Button & "," & RedRat2(x).IRCode
    Next x
    Close #1
    cmdSave.Enabled = False
    
End Sub

Private Sub cmdTest_Click()

    ' test ir
    If txtIrCode.Text = "" Then Exit Sub
    xPL_Template.xPLCOM.Output = txtIrCode.Text

End Sub

Private Sub Form_Load()

    ' load drop down
    Call SortIRCodes("", "")
    txtDevice.Enabled = False
    txtButton.Enabled = False
    cmdLearn.Enabled = False
    cmdDelete.Enabled = False
    cmdSave.Enabled = False
    
End Sub

Private Sub SortIRCodes(strDevice As String, strButton As String)

    Dim x As Integer
    Dim IsSorted As Boolean
    Dim strRedRat As RedRat
    
    ' sort codes
    If RedRatCodes > 1 Then
        IsSorted = False
        While IsSorted = False
            IsSorted = True
            For x = 1 To RedRatCodes - 1
                If RedRat2(x).Device > RedRat2(x + 1).Device Or (RedRat2(x).Device = RedRat2(x + 1).Device And RedRat2(x).Button > RedRat2(x + 1).Button) Then
                    ' sort
                    strRedRat.Device = RedRat2(x).Device
                    strRedRat.Button = RedRat2(x).Button
                    strRedRat.IRCode = RedRat2(x).IRCode
                    RedRat2(x).Device = RedRat2(x + 1).Device
                    RedRat2(x).Button = RedRat2(x + 1).Button
                    RedRat2(x).IRCode = RedRat2(x + 1).IRCode
                    RedRat2(x + 1).Device = strRedRat.Device
                    RedRat2(x + 1).Button = strRedRat.Button
                    RedRat2(x + 1).IRCode = strRedRat.IRCode
                    IsSorted = False
                End If
            Next x
        Wend
    End If
    
    ' relist
    cmbCodes.Clear
    If RedRatCodes > 0 Then
        For x = 1 To RedRatCodes
            cmbCodes.AddItem RedRat2(x).Device + "." + RedRat2(x).Button
        Next x
    End If
    
    ' find current
    If strDevice <> "" Then
        For x = 1 To RedRatCodes
            If UCase(RedRat2(x).Device) = UCase(strDevice) And LCase(RedRat2(x).Button) = LCase(strButton) Then
                cmbCodes.ListIndex = x - 1
                x = RedRatCodes + 1
            End If
        Next x
        Call cmbCodes_Click
    Else
        Call cmbCodes_Click
    End If
    
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

    ' check for changes
    If cmdSave.Enabled = True Then
        Select Case MsgBox("Save Changes to IR Database?", vbYesNoCancel + vbDefaultButton3 + vbQuestion, "Confirm Close")
        Case vbCancel
            Cancel = True
        Case vbYes
            Call cmdSave_Click
        Case vbNo
            Call LoadIRDatabase
        End Select
    End If
    
End Sub

Private Sub txtButton_LostFocus()

    Dim strDevice As String
    Dim strButton As String

    ' check for change
    If LCase(txtButton) <> LCase(RedRat2(cmbCodes.ListIndex + 1).Button) Then
        ' changed
        If txtButton = "" Then
            txtButton = LCase(RedRat2(cmbCodes.ListIndex + 1).Button)
        Else
            If RedRat2(cmbCodes.ListIndex + 1).Button <> "newbutton" Then
                If MsgBox("Change Name of Button '" + RedRat2(cmbCodes.ListIndex + 1).Button + "' to '" + LCase(txtButton) + "'?", vbYesNo + vbQuestion + vbDefaultButton2, "Confirm Name Change") = vbNo Then
                    txtButton = RedRat2(cmbCodes.ListIndex + 1).Button
                    Exit Sub
                End If
            End If
            RedRat2(cmbCodes.ListIndex + 1).Button = LCase(txtButton)
            strDevice = UCase(txtDevice)
            strButton = LCase(txtButton)
            Call SortIRCodes(strDevice, strButton)
            cmdSave.Enabled = True
        End If
    End If

End Sub

Private Sub txtDevice_LostFocus()

    Dim strDevice As String
    Dim strButton As String
    
    ' check for change
    If UCase(txtDevice) <> UCase(RedRat2(cmbCodes.ListIndex + 1).Device) Then
        ' changed
        If txtDevice = "" Then
            txtDevice = UCase(RedRat2(cmbCodes.ListIndex + 1).Device)
        Else
            RedRat2(cmbCodes.ListIndex + 1).Device = UCase(txtDevice)
            strDevice = UCase(txtDevice)
            strButton = LCase(txtButton)
            Call SortIRCodes(strDevice, strButton)
            cmdSave.Enabled = True
        End If
    End If

End Sub
