VERSION 5.00
Begin VB.Form IRManIR 
   Caption         =   "IRMan IR Database"
   ClientHeight    =   3720
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   9540
   Icon            =   "IRManIR.frx":0000
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
      TabIndex        =   12
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
      TabIndex        =   11
      Top             =   240
      Width           =   1335
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
Attribute VB_Name = "IRManIR"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************
'* xPL IRMan
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
        txtDevice = IRMan(cmbCodes.ListIndex + 1).Device
        txtDevice.Enabled = True
        txtButton = IRMan(cmbCodes.ListIndex + 1).Button
        txtButton.Enabled = True
        txtIrCode = IRMan(cmbCodes.ListIndex + 1).IRCode
        cmdDelete.Enabled = True
        cmdLearn.Enabled = True
    End If

End Sub

Private Sub cmdCancel_Click()

    ' cancel
    Learning = False
    IRManIR.cmbCodes.Enabled = True
    IRManIR.txtDevice.Locked = False
    IRManIR.txtButton.Locked = False
    IRManIR.cmdDelete.Enabled = True
    IRManIR.cmdNew.Enabled = True
    IRManIR.cmdLearn.Enabled = True
    IRManIR.cmdSave.Enabled = True
    IRManIR.cmdReload.Enabled = True
    Me.cmdSave.SetFocus
    Me.cmdCancel.Visible = False
    
End Sub

Private Sub cmdDelete_Click()

    Dim x As Integer
    Dim y As Integer

    ' delete
    If MsgBox("Delete '" + cmbCodes.Text + "'?", vbYesNo + vbDefaultButton2 + vbQuestion, "Confirm Delete") = vbNo Then Exit Sub
    
    ' do it
    If cmbCodes.ListIndex + 1 <> IRManCodes Then
        y = cmbCodes.ListIndex + 1
        For x = y + 1 To IRManCodes
            IRMan(x - 1).Device = IRMan(x).Device
            IRMan(x - 1).Button = IRMan(x).Button
            IRMan(x - 1).IRCode = IRMan(x).IRCode
        Next x
    End If
    IRManCodes = IRManCodes - 1
    ReDim Preserve IRMan(IRManCodes) As IRManStruc
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
    cmdLearn.Enabled = False
    cmdSave.Enabled = False
    cmdReload.Enabled = False
    Learning = True
    cmdCancel.Visible = True
    
End Sub

Private Sub cmdNew_Click()

    Dim strDevice As String
    Dim strButton As String
    
    ' add new
    IRManCodes = IRManCodes + 1
    ReDim Preserve IRMan(IRManCodes) As IRManStruc
    IRMan(IRManCodes).Device = "DEVICE"
    If cmbCodes.ListIndex <> -1 Then IRMan(IRManCodes).Device = IRMan(cmbCodes.ListIndex + 1).Device
    IRMan(IRManCodes).Button = "newbutton"
    IRMan(IRManCodes).IRCode = ""
    strDevice = IRMan(IRManCodes).Device
    strButton = IRMan(IRManCodes).Button

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
        strDevice = IRMan(cmbCodes.ListIndex + 1).Device
        strButton = IRMan(cmbCodes.ListIndex + 1).Button
    End If
    Call SortIRCodes(strDevice, strButton)
    cmdSave.Enabled = False
    
End Sub

Private Sub cmdSave_Click()

    Dim x As Integer

    ' save current
    Open IRManPath For Output As #1
    For x = 1 To IRManCodes
        Print #1, IRMan(x).Device & "," & IRMan(x).Button & "," & IRMan(x).IRCode
    Next x
    Close #1
    cmdSave.Enabled = False
    
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
    Dim strIRMan As IRManStruc
    
    ' sort codes
    If IRManCodes > 1 Then
        IsSorted = False
        While IsSorted = False
            IsSorted = True
            For x = 1 To IRManCodes - 1
                If IRMan(x).Device > IRMan(x + 1).Device Or (IRMan(x).Device = IRMan(x + 1).Device And IRMan(x).Button > IRMan(x + 1).Button) Then
                    ' sort
                    strIRMan.Device = IRMan(x).Device
                    strIRMan.Button = IRMan(x).Button
                    strIRMan.IRCode = IRMan(x).IRCode
                    IRMan(x).Device = IRMan(x + 1).Device
                    IRMan(x).Button = IRMan(x + 1).Button
                    IRMan(x).IRCode = IRMan(x + 1).IRCode
                    IRMan(x + 1).Device = strIRMan.Device
                    IRMan(x + 1).Button = strIRMan.Button
                    IRMan(x + 1).IRCode = strIRMan.IRCode
                    IsSorted = False
                End If
            Next x
        Wend
    End If
    
    ' relist
    cmbCodes.Clear
    If IRManCodes > 0 Then
        For x = 1 To IRManCodes
            cmbCodes.AddItem IRMan(x).Device + "." + IRMan(x).Button
        Next x
    End If
    
    ' find current
    If strDevice <> "" Then
        For x = 1 To IRManCodes
            If UCase(IRMan(x).Device) = UCase(strDevice) And LCase(IRMan(x).Button) = LCase(strButton) Then
                cmbCodes.ListIndex = x - 1
                x = IRManCodes + 1
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
    If LCase(txtButton) <> LCase(IRMan(cmbCodes.ListIndex + 1).Button) Then
        ' changed
        If txtButton = "" Then
            txtButton = LCase(IRMan(cmbCodes.ListIndex + 1).Button)
        Else
            If IRMan(cmbCodes.ListIndex + 1).Button <> "newbutton" Then
                If MsgBox("Change Name of Button '" + IRMan(cmbCodes.ListIndex + 1).Button + "' to '" + LCase(txtButton) + "'?", vbYesNo + vbQuestion + vbDefaultButton2, "Confirm Name Change") = vbNo Then
                    txtButton = IRMan(cmbCodes.ListIndex + 1).Button
                    Exit Sub
                End If
            End If
            IRMan(cmbCodes.ListIndex + 1).Button = LCase(txtButton)
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
    If UCase(txtDevice) <> UCase(IRMan(cmbCodes.ListIndex + 1).Device) Then
        ' changed
        If txtDevice = "" Then
            txtDevice = UCase(IRMan(cmbCodes.ListIndex + 1).Device)
        Else
            IRMan(cmbCodes.ListIndex + 1).Device = UCase(txtDevice)
            strDevice = UCase(txtDevice)
            strButton = LCase(txtButton)
            Call SortIRCodes(strDevice, strButton)
            cmdSave.Enabled = True
        End If
    End If

End Sub
