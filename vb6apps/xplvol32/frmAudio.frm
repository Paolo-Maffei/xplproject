VERSION 5.00
Begin VB.Form frmAudio 
   Caption         =   "Properties"
   ClientHeight    =   3840
   ClientLeft      =   60
   ClientTop       =   510
   ClientWidth     =   4575
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   12
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmAudio.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   3840
   ScaleWidth      =   4575
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   1560
      TabIndex        =   3
      Top             =   3360
      Width           =   1335
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3120
      TabIndex        =   2
      Top             =   3360
      Width           =   1335
   End
   Begin VB.ListBox lstSliders 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2760
      Left            =   120
      Style           =   1  'Checkbox
      TabIndex        =   0
      Top             =   480
      Width           =   4335
   End
   Begin VB.Label Label1 
      Caption         =   "Show the following volume controls:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   3615
   End
End
Attribute VB_Name = "frmAudio"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Me.Hide
End Sub

Private Sub cmdOK_Click()
    Dim X As Integer
    
    For X = 1 To MaxSources
        If lstSliders.Selected(X - 1) Then
            MixerState(X).MxrVisible = True
            SaveSetting xPL_Setting, "Properties", "Slider" + Str(X), True
        Else
            MixerState(X).MxrVisible = False
            SaveSetting xPL_Setting, "Properties", "Slider" + Str(X), False
        End If
    Next
    Me.Hide
End Sub

Private Sub Form_Activate()
    Dim X As Integer
    For X = 1 To MaxSources
        lstSliders.Selected(X - 1) = MixerState(X).MxrVisible
    Next
End Sub

Private Sub Form_Load()
    Dim X As Integer
    lstSliders.Clear
    For X = 1 To MaxSources
        lstSliders.AddItem (MixerState(X).MxrName)
    Next
End Sub

