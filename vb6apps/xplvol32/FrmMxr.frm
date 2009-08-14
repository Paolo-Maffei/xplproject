VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "comctl32.ocx"
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Object = "{D9D65F26-40A3-4F6C-8DF0-998D98138058}#1.1#0"; "xPL.ocx"
Begin VB.Form FrmMxr 
   BorderStyle     =   0  'None
   ClientHeight    =   3705
   ClientLeft      =   45
   ClientTop       =   1725
   ClientWidth     =   15210
   Icon            =   "FrmMxr.frx":0000
   MaxButton       =   0   'False
   NegotiateMenus  =   0   'False
   ScaleHeight     =   247
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   1014
   ShowInTaskbar   =   0   'False
   Begin xPL.xPLCtl xPLSys 
      Left            =   4560
      Top             =   4080
      _ExtentX        =   1085
      _ExtentY        =   1296
   End
   Begin VB.Timer tmrxPL 
      Enabled         =   0   'False
      Interval        =   2000
      Left            =   2145
      Top             =   4320
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   0
      Left            =   0
      TabIndex        =   82
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute All"
         Height          =   195
         Index           =   0
         Left            =   165
         TabIndex        =   84
         Top             =   3285
         Width           =   865
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   0
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   83
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   0
         Left            =   165
         TabIndex        =   85
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   0
         Left            =   360
         TabIndex        =   86
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   0
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   89
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   0
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   88
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   0
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   87
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   0
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   0
         Left            =   135
         Picture         =   "FrmMxr.frx":030A
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   1
         Left            =   1035
         Picture         =   "FrmMxr.frx":0614
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   1
      Left            =   1470
      TabIndex        =   74
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   1
         Left            =   165
         TabIndex        =   76
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   1
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   75
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   1
         Left            =   165
         TabIndex        =   77
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   1
         Left            =   360
         TabIndex        =   78
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   2
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   3
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   1
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   81
         Top             =   495
         Width           =   630
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   1
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   80
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   1
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   79
         Top             =   225
         Width           =   420
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   2
         Left            =   135
         Picture         =   "FrmMxr.frx":091E
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   3
         Left            =   1035
         Picture         =   "FrmMxr.frx":0C28
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   2
      Left            =   2835
      TabIndex        =   66
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   2
         Left            =   165
         TabIndex        =   68
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   2
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   67
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   2
         Left            =   165
         TabIndex        =   69
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   2
         Left            =   360
         TabIndex        =   70
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   2
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   73
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   2
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   72
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   2
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   71
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   4
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   5
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   4
         Left            =   135
         Picture         =   "FrmMxr.frx":0F32
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   5
         Left            =   1035
         Picture         =   "FrmMxr.frx":123C
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   3
      Left            =   4200
      TabIndex        =   58
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   3
         Left            =   165
         TabIndex        =   60
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   3
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   59
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   3
         Left            =   165
         TabIndex        =   61
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   3
         Left            =   360
         TabIndex        =   62
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         SelStart        =   32
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   3
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   65
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   3
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   64
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   3
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   63
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   6
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   7
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   6
         Left            =   135
         Picture         =   "FrmMxr.frx":1546
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   7
         Left            =   1035
         Picture         =   "FrmMxr.frx":1850
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   4
      Left            =   5565
      TabIndex        =   50
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   4
         Left            =   165
         TabIndex        =   52
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   4
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   51
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   4
         Left            =   165
         TabIndex        =   53
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   4
         Left            =   360
         TabIndex        =   54
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   4
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   57
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   4
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   56
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   4
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   55
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   8
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   9
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   8
         Left            =   135
         Picture         =   "FrmMxr.frx":1B5A
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   9
         Left            =   1035
         Picture         =   "FrmMxr.frx":1E64
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   5
      Left            =   6930
      TabIndex        =   42
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   5
         Left            =   165
         TabIndex        =   44
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   5
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   43
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   5
         Left            =   165
         TabIndex        =   45
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   5
         Left            =   360
         TabIndex        =   46
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   5
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   49
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   5
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   48
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   5
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   47
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   10
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   11
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   10
         Left            =   135
         Picture         =   "FrmMxr.frx":216E
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   11
         Left            =   1035
         Picture         =   "FrmMxr.frx":2478
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   6
      Left            =   8295
      TabIndex        =   34
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   6
         Left            =   165
         TabIndex        =   36
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   6
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   35
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   6
         Left            =   165
         TabIndex        =   37
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   6
         Left            =   360
         TabIndex        =   38
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   6
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   41
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   6
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   40
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   6
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   39
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   12
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   13
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   12
         Left            =   135
         Picture         =   "FrmMxr.frx":2782
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   13
         Left            =   1035
         Picture         =   "FrmMxr.frx":2A8C
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   7
      Left            =   9660
      TabIndex        =   26
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   7
         Left            =   165
         TabIndex        =   28
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   7
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   27
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   7
         Left            =   165
         TabIndex        =   29
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   7
         Left            =   360
         TabIndex        =   30
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   7
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   33
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   7
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   32
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   7
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   31
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   14
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   15
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   14
         Left            =   135
         Picture         =   "FrmMxr.frx":2D96
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   15
         Left            =   1035
         Picture         =   "FrmMxr.frx":30A0
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   8
      Left            =   11025
      TabIndex        =   18
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   8
         Left            =   165
         TabIndex        =   20
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   8
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   19
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   8
         Left            =   165
         TabIndex        =   21
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   8
         Left            =   360
         TabIndex        =   22
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   8
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   25
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   8
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   24
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   8
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   23
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   16
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   17
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   16
         Left            =   135
         Picture         =   "FrmMxr.frx":33AA
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   19
         Left            =   1035
         Picture         =   "FrmMxr.frx":36B4
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   9
      Left            =   12390
      TabIndex        =   10
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   9
         Left            =   165
         TabIndex        =   12
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   9
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   11
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   9
         Left            =   165
         TabIndex        =   13
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   9
         Left            =   360
         TabIndex        =   14
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   9
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   17
         Top             =   225
         Width           =   420
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   9
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   16
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   9
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   15
         Top             =   495
         Width           =   630
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   18
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   19
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   17
         Left            =   135
         Picture         =   "FrmMxr.frx":39BE
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   20
         Left            =   1035
         Picture         =   "FrmMxr.frx":3CC8
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.Frame Fra 
      Height          =   3645
      Index           =   10
      Left            =   13755
      TabIndex        =   2
      Top             =   0
      Visible         =   0   'False
      Width           =   1395
      Begin VB.CheckBox ChkMute 
         Caption         =   "Mute"
         Height          =   195
         Index           =   10
         Left            =   165
         TabIndex        =   4
         Top             =   3285
         Width           =   660
      End
      Begin VB.PictureBox PicLed 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   1140
         Index           =   10
         Left            =   975
         LinkTimeout     =   0
         ScaleHeight     =   76
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   3
         TabStop         =   0   'False
         Top             =   1905
         Visible         =   0   'False
         Width           =   225
      End
      Begin ComctlLib.Slider SldrVol 
         Height          =   1365
         Index           =   10
         Left            =   165
         TabIndex        =   5
         Top             =   1785
         Width           =   615
         _ExtentX        =   1085
         _ExtentY        =   2408
         _Version        =   327682
         Orientation     =   1
         LargeChange     =   1024
         Max             =   65535
         SelStart        =   65535
         TickStyle       =   2
         TickFrequency   =   10923
         Value           =   65535
      End
      Begin ComctlLib.Slider SldrPan 
         Height          =   420
         Index           =   10
         Left            =   360
         TabIndex        =   6
         Top             =   795
         Width           =   675
         _ExtentX        =   1191
         _ExtentY        =   741
         _Version        =   327682
         LargeChange     =   1
         Min             =   -100
         Max             =   100
         TickFrequency   =   100
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000014&
         Index           =   21
         X1              =   165
         X2              =   1230
         Y1              =   1365
         Y2              =   1365
      End
      Begin VB.Line Ln 
         BorderColor     =   &H80000010&
         Index           =   20
         X1              =   165
         X2              =   1230
         Y1              =   1350
         Y2              =   1350
      End
      Begin VB.Label LblPan 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Balance:"
         Height          =   195
         Index           =   10
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   9
         Top             =   495
         Width           =   630
      End
      Begin VB.Label LblVol 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Volume:"
         Height          =   195
         Index           =   10
         Left            =   165
         LinkTimeout     =   0
         TabIndex        =   8
         Top             =   1485
         Width           =   570
      End
      Begin VB.Label LblName 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         Caption         =   "Name"
         Height          =   195
         Index           =   10
         Left            =   150
         LinkTimeout     =   0
         TabIndex        =   7
         Top             =   225
         Width           =   420
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   18
         Left            =   135
         Picture         =   "FrmMxr.frx":3FD2
         Top             =   840
         Width           =   480
      End
      Begin VB.Image Img 
         Appearance      =   0  'Flat
         Height          =   480
         Index           =   21
         Left            =   1035
         Picture         =   "FrmMxr.frx":42DC
         Top             =   840
         Width           =   480
      End
   End
   Begin VB.PictureBox PicLedRes 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      ForeColor       =   &H00000000&
      Height          =   1035
      Left            =   2865
      LinkTimeout     =   0
      Picture         =   "FrmMxr.frx":45E6
      ScaleHeight     =   69
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   22
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   4350
      Visible         =   0   'False
      Width           =   330
   End
   Begin VB.PictureBox PicBackBuffer 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      Height          =   1035
      Left            =   3345
      LinkTimeout     =   0
      ScaleHeight     =   69
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   11
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   4350
      Visible         =   0   'False
      Width           =   165
   End
   Begin VB.Timer TmrQuit 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   3705
      Top             =   4350
   End
   Begin MSWinsockLib.Winsock udpxPL 
      Left            =   1425
      Top             =   4320
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
   End
   Begin VB.Menu mPopupSys 
      Caption         =   "&SysTray"
      Visible         =   0   'False
      Begin VB.Menu mPopRestore 
         Caption         =   "Open Volume Control"
      End
      Begin VB.Menu mAudProps 
         Caption         =   "Adjust Audio Properties"
      End
   End
   Begin VB.Menu mOptions 
      Caption         =   "&Options"
      Begin VB.Menu mProps 
         Caption         =   "Properties"
      End
      Begin VB.Menu mOriginal 
         Caption         =   "Windows Mixer"
      End
      Begin VB.Menu mExit 
         Caption         =   "Exit"
      End
   End
   Begin VB.Menu mHelp 
      Caption         =   "Help"
      Begin VB.Menu mAbout 
         Caption         =   "About"
      End
   End
End
Attribute VB_Name = "FrmMxr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Type PeakInfo
    PeakId As Long    ' Peak Meter ID.
    PicIdx As Long    ' Associated Picture Box.
End Type

Private PeakArray() As PeakInfo
Private bQuitLoop As Boolean
Public FullExit As Boolean

Private Sub Form_Load()
   Dim x As Integer
    
    ' initialise
    InTray = True
    If InStr(1, Command() & " ", "/hide ", vbTextCompare) > 0 Then InTray = False
    xPL_Source = "WMUTE-VOL32"
    If Dir(App.Path + "\source.cfg") <> "" Then
        x = FreeFile
        Open App.Path + "\source.cfg" For Input As #x
        Input #x, xPL_Source
        Close #x
    Else
        xPL_Source = xPL_Source & "." & Left$(xPLSys.HostName, 10) & Format(Now, "hhmmss")
        x = FreeFile
        Open App.Path + "\source.cfg" For Output As #x
        Print #x, xPL_Source
        Close #x
    End If
    xPL_WaitForConfig = True ' set to false if config not required (not recommended) @@@
    xPL_Ready = False
    xPL_Title = "xPL Mixer"
    Me.Caption = xPL_Title + " " + xPL_Source
    Me.mPopRestore.Caption = xPL_Source
    
    ' pre initialise
    If xPLSys.Initialise(xPL_Source, xPL_WaitForConfig, 5) = False Then
        ' failed to pre-initialise
        Unload Me
        Exit Sub
    End If
    
    ' add extra configs (set config/reconf/option as needed) @@@
    ' Call xPLSys.ConfigsAdd("MYFLAG", "CONFIG", 1)
    ' etc

    ' add default extra config values if possible @@@
    ' xPLSys.Configs("LATITUDE") = "1.04532"
'    etc

    ' add default filters @@@
    Call xPLSys.FiltersAdd("*.*.*.*.CONTROL.*")
    ' etc
    
    ' set up other options @@@
    xPLSys.PassCONFIG = False
    xPLSys.PassHBEAT = False
    xPLSys.PassNOMATCH = False
    xPLSys.StatusSchema = "" ' schema for status in heartbeat
    xPLSys.StatusMsg = "" ' message for status in heartbeat
    
    ' initialise xPL
    If xPLSys.Start = False Then
        ' failed to initialise
        Unload Me
        Exit Sub
    End If
    
    ' for icon tray form must be fully visible before calling Shell_NotifyIcon
    Me.Show
    Me.Refresh
    If InTray = True Then
        With nid
            .cbSize = Len(nid)
            .hwnd = Me.hwnd
            .uId = vbNull
            .uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
            .uCallBackMessage = WM_MOUSEMOVE
            .hIcon = Me.Icon
            .szTip = Me.Caption & vbNullChar
        End With
        Shell_NotifyIcon NIM_ADD, nid
    End If
    'Me.WindowState = vbMinimized
    
    ' flag as configured
    If xPL_WaitForConfig = False Then xPL_Ready = True


End Sub

Private Sub Form_Activate()
   Dim K%, Q%  ' Counter's.
   Dim strCmd As String
   Dim x As Integer
   Dim active As Integer
    
    Q = -1
    For K = 0 To MaxSources
        ' If The Source Is Mono, Disable The Pan Control For That Source.
        If MixerState(K).MxrChannels < 2 Then SldrPan(K).Enabled = 0
        ' Set The Volume Of Source.
        SldrVol(K).Value = MixerState(K).MxrVol
        ' Set The Mute Status.
        chkAutoTick = 1
        ChkMute(K).Value = MixerState(K).MxrMute
        ' If The Source Has A PeakMeter, Dimension Our Array
        ' And Show The PeakMeter Picture Box (Not All Sources Have Them).
        If MixerState(K).MxrPeakID Then
           PicLed(K).Visible = 1
           Q = Q + 1
           ReDim Preserve PeakArray(Q)
           PeakArray(Q).PeakId = MixerState(K).MxrPeakID
           PeakArray(Q).PicIdx = K
        Else
           ' Let The PeakMeter Picture Box Remain Invisible
           ' And Centre The Volume Fader In It's Frame.
           SldrVol(K).Left = 390
        End If
        ' Show The Frame Control For The Current Source.
        ' Note: The First Frame Is For The Master Volume (That Is A Destination).
        Fra(K).Visible = 1
    Next
 
    ' Hide the unwanted sliders
    active = 1
    K = 1
    For K = 1 To MaxSources
        If MixerState(K).MxrVisible Then
           Fra(K).Visible = True
           Fra(K).Left = active * 92
           active = active + 1
        Else
           Fra(K).Visible = False
        End If
    Next
  
    ' Size And Position The Form According To How Many Sources We Found.
    Me.Width = (active * 1400)

    ' If The User's Mixer Has PeakMeter/s, Scan For Activity.
    If Q > -1 Then RunPeakScanner

End Sub

Private Sub mAbout_Click()
    frmAbout.Show
End Sub

Private Sub mAudProps_Click()
    Dim cmd As String
    Dim r As Long
    cmd = "rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl"
    r = Shell(cmd, 1)
End Sub

Private Sub mExit_Click()
   FullExit = True
   Unload Me
End Sub

Private Sub mOriginal_Click()
    Dim cmd As String
    Dim r As Long
    cmd = "sndvol32.exe"
    r = Shell(cmd, 1)
End Sub

Private Sub mProps_Click()
    frmAudio.Show
End Sub


Private Sub SldrVol_Change(Idx%)
    Dim strTrigMsg As String

    ' Call The "AdjustOutput" Sub For The Given Control.
    AdjustOutput Idx
    
    'Send an xPL Trigger message
    If Fra(Idx).Visible Then
       strTrigMsg = "DEVICE=" & MixerState(Idx).MxrName
       strTrigMsg = strTrigMsg & Chr$(10) & "TYPE=SLIDER" & Chr$(10)
       strTrigMsg = strTrigMsg & "CURRENT=" & Str((Int(MixerState(Idx).MxrLeftVol / 256)))
       Call xPLSys.SendXplMsg("XPL-TRIG", "*", "SENSOR.BASIC", strTrigMsg)
    End If

End Sub
Private Sub SldrVol_Scroll(Idx%)

    ' Call The "AdjustOutput" Sub For The Given Control.
    AdjustOutput Idx

End Sub
Private Sub SldrPan_Change(Idx%)
    Dim strTrigMsg As String

    ' Call The "AdjustOutput" Sub For The Given Control.
    AdjustOutput Idx
    
    'Send an xPL Trigger message
    If Fra(Idx).Visible Then
       strTrigMsg = "DEVICE=" & MixerState(Idx).MxrName
       strTrigMsg = strTrigMsg & Chr$(10) & "TYPE=BALANCE" & Chr$(10)
       strTrigMsg = strTrigMsg & "CURRENT=" & Str(SldrPan(Idx).Value)
       Call xPLSys.SendXplMsg("XPL-TRIG", "*", "SENSOR.BASIC", strTrigMsg)
    End If

End Sub
Private Sub SldrPan_Scroll(Idx%)

    ' Call The "AdjustOutput" Sub For The Given Control.
    AdjustOutput Idx

End Sub
Private Sub AdjustOutput(Idx%)

    Dim FaderVol&
    Dim PanPos&
    Dim hMem&
    Dim MCDMono As MIXERCONTROLDETAILS
    Dim MCDStereo As MIXERCONTROLDETAILS

    ' If The Volume Control Is For Stereo Then...
    If MixerState(Idx).MxrChannels = 2 Then
       ' Get The Position Of The Balance.
       PanPos = SldrPan(Idx).Value
       ' Get The Volume Of The Fader.
       FaderVol = 65535 - SldrVol(Idx).Value
       ' For Stereo, The Volume Is Calculated On The Setting Of The Pan Slider (Crazy).
       If PanPos >= 0 Then
          ' Pan Is To Right Of Centre So,
          ' Turn The Right Channel Up To The Volume Fader Setting,
          ' And Decrease The Left Channel Accordingly.
          MixerState(Idx).MxrRightVol = FaderVol
          MixerState(Idx).MxrLeftVol = FaderVol - ((PanPos / 100) * FaderVol)
       Else
          ' Pan Is To Left Of Centre So,
          ' Turn The Left Channel Up To The Volume Fader Setting,
          ' And Decrease The Right Channel Accordingly.
          MixerState(Idx).MxrLeftVol = FaderVol
          MixerState(Idx).MxrRightVol = FaderVol + ((PanPos / 100) * FaderVol)
       End If
       ' Prep The MCD Structure.
       MCDStereo.cbDetails = 4  ' Four Byte's (Size Of A Long)
       MCDStereo.cbStruct = 24
       MCDStereo.dwControlID = MixerState(Idx).MxrVolID ' Use The Vol Fader ID.
       MCDStereo.item = 0
       MCDStereo.cChannels = 2

       hMem = GlobalAlloc(&H40, 8)
       MCDStereo.paDetails = GlobalLock(hMem)
       ' Copy The Value's Of The Left And Right Channel's To The Structure.
       CopyPtrFromStruct MCDStereo.paDetails, MixerState(Idx).MxrRightVol, 8
       CopyPtrFromStruct MCDStereo.paDetails, MixerState(Idx).MxrLeftVol, 8
       ' Establish The Setting.
       mixerSetControlDetails hMixer, MCDStereo, MIXER_SETCONTROLDETAILSF_VALUE
       GlobalUnlock hMem
       GlobalFree hMem
    Else
       ' Save The New Mono Volume Setting.
       MixerState(Idx).MxrVol = 65535 - SldrVol(Idx).Value

       ' Prep The MCD Structure.
       MCDMono.cbDetails = Len(MixerState(Idx).MxrVol)
       MCDMono.cbStruct = Len(MCDMono)
       MCDMono.dwControlID = MixerState(Idx).MxrVolID
       MCDMono.item = 0
       MCDMono.cChannels = 1

       hMem = GlobalAlloc(&H40, 4)
       MCDMono.paDetails = GlobalLock(hMem)
       ' Copy The Value Of The Volume To The Structure.
       CopyPtrFromStruct MCDMono.paDetails, MixerState(Idx).MxrVol, 4
       mixerSetControlDetails hMixer, MCDMono, MIXER_SETCONTROLDETAILSF_VALUE
       ' Establish The Setting.
       GlobalUnlock hMem
       GlobalFree hMem
    End If

End Sub
Private Sub ChkMute_Click(Idx%)

    Dim hMem&   ' Handle To A Small Memory Block.
    Dim strTrigMsg As String
    
    ' Save The Status Of The Given Mute Control.
    MixerState(Idx).MxrMute = ChkMute(Idx).Value

    ' Set Up The Control Detail's Structure.
    MCD.cbStruct = Len(MCD)                      ' Structure Size.
    MCD.dwControlID = MixerState(Idx).MxrMuteID  ' Control ID.
    MCD.cbDetails = 4                            ' Size Of A Long Variable, In Byte's.
    MCD.cChannels = 1                            ' Mute Has Only One Channel.
    MCD.item = 0                                 ' No Item's.

    ' Allocate Some Memory.
    hMem = GlobalAlloc(&H40, 4)
    ' Give It To "MCD.paDetails"
    MCD.paDetails = GlobalLock(hMem)
    ' Copy The Mute Status Into "MCD.paDetails"
    CopyPtrFromStruct MCD.paDetails, MixerState(Idx).MxrMute, 4

    ' Set The Status Of The Mute Control.
    mixerSetControlDetails hMixer, MCD, MIXER_SETCONTROLDETAILSF_VALUE

    ' Tidy Up.
    GlobalUnlock hMem
    GlobalFree hMem

    'Send an xPL Trigger message
    If chkAutoTick = 0 Then
       strTrigMsg = "DEVICE=" & MixerState(Idx).MxrName
       strTrigMsg = strTrigMsg & Chr$(10) & "TYPE=MUTE" & Chr$(10)
       If ChkMute(Idx).Value = 0 Then
          strTrigMsg = strTrigMsg & "CURRENT=NO"
       Else
          strTrigMsg = strTrigMsg & "CURRENT=YES"
       End If
       
       Call xPLSys.SendXplMsg("XPL-TRIG", "*", "SENSOR.BASIC", strTrigMsg)
    End If
    ' Clear the "automated press" flag
    chkAutoTick = 0

End Sub
Private Sub RunPeakScanner()

    Static z%          ' Counter.
    Static Ub%         ' Upper Bound Of The PeakArray (For Loop Speed).
    Dim Lev&           ' Current PeakMeter Level.
    Dim LineHeight%    ' Height Of The Rect We Will Draw To Cover Up The
                       ' Cell's Of The Peak Display That Are Not Lit.

    ' Another "MIXERCONTROLDETAILS" Structure.
    Dim MxrCD As MIXERCONTROLDETAILS

    ' Set Up The Back Buffer Before Entering The Loop.
    BitBlt PicBackBuffer.hDC, 0, 0, 11, 69, PicLedRes.hDC, 0, 0, vbSrcAnd
    BitBlt PicBackBuffer.hDC, 0, 0, 11, 69, PicLedRes.hDC, 11, 0, vbSrcInvert
    ' The Back Buffer Will Need To Be Cleared Using .Cls, But I Want To Keep The Led's.
    PicBackBuffer.Picture = PicBackBuffer.Image

    ' Set The Ub Variable Ready For The Loop.
    Ub = UBound(PeakArray)

    ' Scan For PeakMeter Activity.
    Do
      For z = 0 To Ub
          ' Reset The Lev Variable.
          Lev = 0
          With MxrCD
              .cbStruct = 24                      ' Structure Size.
              .dwControlID = PeakArray(z).PeakId  ' Control ID.
              .cbDetails = 4                      ' Size Of A Long Variable, In Byte's.
              .cChannels = 1                      ' One Channel.
              .item = 0                           ' No Item's.
              .paDetails = VarPtr(Lev)            ' Address Of The Lev Variable That Will Recieve Level Info.
          End With
          ' Get A Peak Meter Reading.
          mixerGetControlDetails hMixer, MxrCD, MIXER_GETCONTROLDETAILSF_VALUE
          ' It Can Be Negative, So Make It Positive.
          Lev = Abs(Lev)
          ' Did We Get A Value?
          If Lev Then
             ' What Range Did The Value Fall Into?
             Select Case Lev
                    Case Is <= 6445:  LineHeight = 61  ' We'll Be Covering All Led Cell's On The Back Buffer Except The First One.
                    Case Is <= 9768:  LineHeight = 54
                    Case Is <= 13029: LineHeight = 47
                    Case Is <= 16143: LineHeight = 40
                    Case Is <= 19494: LineHeight = 33
                    Case Is <= 22677: LineHeight = 26
                    Case Is <= 25978: LineHeight = 19
                    Case Is <= 29435: LineHeight = 12
                    Case Is <= 30260: LineHeight = 5
                    Case Is <= 32768:                  ' We'll Be Sh0wing All The Led Cell's.
             End Select
             ' Clear The Back Buffer.
             PicBackBuffer.Cls
             ' Cover The Unlit Led's With A Box Filled Rectangle.
             PicBackBuffer.Line (0, 0)-(11, LineHeight), vbButtonFace, BF
             ' Display The Status Of The Current Peak Meter.
             BitBlt PicLed(PeakArray(z).PicIdx).hDC, 2, 3, 11, 69, PicBackBuffer.hDC, 0, 0, vbSrcCopy
             DoEvents
          Else
             ' No Activity, Keep The Led Display Clear.
             PicLed(PeakArray(z).PicIdx).Line (1, 1)-(13, 74), vbButtonFace, BF
          End If
          DoEvents
          If bQuitLoop Then Exit Sub
      Next
    Loop Until bQuitLoop

End Sub
Private Sub PicLed_Paint(Idx%)

    ' Purpose: Draw's A Slim Border Around Visible PeakMeter Picture Boxes.

    Dim Rct As RECT

    SetRect Rct, 0, 0, 15, 76
    DrawEdge PicLed(Idx).hDC, Rct, 2, 15

End Sub

Private Sub TmrQuit_Timer()

    End

End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
        
    'this procedure receives the callbacks from the System Tray icon.
    Dim Result As Long
    Dim Msg As Long
         
    'the value of X will vary depending upon the scalemode setting
    If Me.ScaleMode = vbPixels Then
        Msg = x
    Else
        Msg = x / Screen.TwipsPerPixelX
    End If
    Select Case Msg
    Case WM_LBUTTONUP        '514 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        On Error Resume Next
        Me.Show
        On Error GoTo 0
    Case WM_LBUTTONDBLCLK    '515 restore form window
        Me.WindowState = vbNormal
        Result = SetForegroundWindow(Me.hwnd)
        On Error Resume Next
        Me.Show
        On Error GoTo 0
    Case WM_RBUTTONUP        '517 display popup menu
        Result = SetForegroundWindow(Me.hwnd)
        Me.PopupMenu Me.mPopupSys
    End Select
        
End Sub
 
Private Sub Form_Resize()
    
    ' this is necessary to assure that the minimized window is hidden
    If Me.WindowState = vbMinimized Then Me.Hide
    If Me.WindowState <> vbMinimized Then Me.Show
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    If FullExit <> True Then
        Cancel = True
        Me.WindowState = vbMinimized
        Exit Sub
    Else
        'Check this is what the user wants?
        If MsgBox("This will disable xPL Control of your audio settings. Really Exit?", vbYesNo + vbDefaultButton2 + vbQuestion, Me.Caption) = vbNo Then
           Cancel = True
           Exit Sub
        End If
    End If
    ' this removes the icon from the system tray
    If xPL_View = 0 Then Shell_NotifyIcon NIM_DELETE, nid
End Sub
 
Private Sub mPopExit_click()
         
    ' called when user clicks the popup menu Exit command
    Unload Me
        
End Sub
 
Private Sub mPopRestore_click()
    
    Dim Result As Long
    
    ' called when the user clicks the popup menu Restore command
    Me.WindowState = vbNormal
    Result = SetForegroundWindow(Me.hwnd)
    Me.Show
    
End Sub

' process config item
Private Sub xPLSys_Config(item As String, Value As String, Occurance As Integer)

    ' process config items @@@
    ' IF you want to use your own variables
    ' OR you want to take some action
    Select Case UCase(item)
'    Case "LATITUDE"

    End Select
    
End Sub

' configuration process complete
Private Sub xPLSys_Configured(Source As String)
    
    Dim f As Integer
    
    ' update source and title
    xPL_Source = Source
    Me.Caption = xPL_Title + " " + xPL_Source
    If InTray = True Then
        Shell_NotifyIcon NIM_DELETE, nid
        Me.mPopRestore.Caption = xPL_Source
        Me.mPopupSys.Caption = xPL_Source
        nid.szTip = Me.Caption & vbNullChar
        Shell_NotifyIcon NIM_ADD, nid
    End If
    f = FreeFile
    Open App.Path + "\source.cfg" For Output As #f
    Print #f, xPL_Source
    Close #f
    
    ' application specific processing @@@
    ' e.g. do calculations, set com ports etc etc
    
    ' flag as configured
    xPL_Ready = True
    
End Sub

' process message
Private Sub xPLSys_Received(Msg As xPLMsg)

   ' Additions for Volume Control
    Dim strDevice As String
    Dim strType As String
    Dim strCurrent As String
    Dim intChosen As Integer
    Dim intProcPairs As Integer
    Dim x As Integer
    
    ' check we are configured okay
    If xPL_Ready = False Then Exit Sub
    
    ' Initialise the variables
    strDevice = ""
    strType = ""
    strCurrent = ""
    
    If Msg.xPLType = "xpl-cmnd" And Msg.NamePairs > 0 Then
       For intProcPairs = 0 To Msg.NamePairs
           Select Case UCase(Msg.Names(intProcPairs))
           Case "DEVICE"
                strDevice = UCase(Msg.Values(intProcPairs))
           Case "TYPE"
                strType = UCase(Msg.Values(intProcPairs))
           Case "CURRENT"
                strCurrent = UCase(Msg.Values(intProcPairs))
           End Select
       Next
    
       'try to match the slider name to one we know about
       intChosen = 255
       x = 0
       For x = 0 To MaxSources
           If UCase(Trim(strDevice)) = UCase(Trim(MixerState(x).MxrName)) Then
              intChosen = x
           End If
       Next
       If UCase(Trim(strDevice)) = "MASTER" Then 'hardcode in "master"
          intChosen = 0
       End If
    
       If intChosen = 255 Then
          Exit Sub ' no Match
       Else
          Select Case strType
           Case "SLIDER"
                SldrVol(intChosen).Value = 655 * (100 - Val(strCurrent))
           Case "BALANCE"
                SldrPan(intChosen).Value = Val(strCurrent)
           Case "MUTE"
                chkAutoTick = 1
                If UCase(strCurrent) = "YES" Then
                   ChkMute(intChosen).Value = vbChecked
                End If
                If UCase(strCurrent) = "NO" Then
                   ChkMute(intChosen).Value = vbUnchecked
                End If
           End Select
       End If
    End If
End Sub
