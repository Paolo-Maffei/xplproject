Attribute VB_Name = "modSQ"
Option Explicit

' Declarations for mail.dll

' Call sqInit to initialise Winsock - make sure to call sqCleanup when you're finished
Public Declare Function sqInit Lib "squtil.dll" () As Long
Public Declare Function sqCleanup Lib "squtil.dll" () As Long
Public Declare Function sqConnect Lib "squtil.dll" (ByVal Host As String, ByVal portnum As Long) As Long
Public Declare Function sqDisconnect Lib "squtil.dll" (s As Long) As Long
Public Declare Function sqSend Lib "squtil.dll" (ByVal s As Long, ByVal buff As String, ByVal bytecount As Long) As Long
Public Declare Function sqRecv Lib "squtil.dll" (ByVal s As Long, ByVal buff As String, ByVal bytecount As Long) As Long
Public Declare Function sqGetChunk Lib "squtil.dll" (ByVal s As Long, ByVal buff As String, ByVal bytecount As Long) As Long
Public Declare Function sqRecvLine Lib "squtil.dll" (ByVal s As Long, ByVal buff As String, ByVal bytecount As Long) As Long
Public Declare Function sqPeek Lib "squtil.dll" (s As Long, ByVal buff As String, ByVal bytecount As Long) As Long
Public Declare Function sqQueryState Lib "squtil.dll" (ByVal s As Long) As Long
Public Declare Sub sqGetVersion Lib "squtil.dll" (ByVal pszVersion As String)
Public Declare Function sqSendUDPPacket Lib "squtil.dll" (ByVal Host As String, ByVal portnum As Long, ByVal buff As String, ByVal bytecount As Long) As Long


