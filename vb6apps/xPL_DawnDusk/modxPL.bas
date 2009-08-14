Attribute VB_Name = "modxPL"
'**************************************
'* xPL Dawn/Dusk
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

' application specific definitions @@@
Public Longitude As Double
Public Latitude As Double
Public Dawn As Date
Public DawnAdj As Integer
Public NextDawn As Date
Public Dusk As Date
Public DuskAdj As Integer
Public NextDusk As Date
Public StatusIsDay As Boolean

' standard definitions
Public xPL_Source As String
Public xPL_Title As String
Public xPL_WaitForConfig As Boolean
Public xPL_Ready As Boolean

' this stuff is for icon tray
Public Type NOTIFYICONDATA
    cbSize As Long
    hwnd As Long
    uId As Long
    uFlags As Long
    uCallBackMessage As Long
    hIcon As Long
    szTip As String * 64
End Type
Public IconInit As Boolean
Public Const NIM_ADD = &H0
Public Const NIM_MODIFY = &H1
Public Const NIM_DELETE = &H2
Public Const NIF_MESSAGE = &H1
Public Const NIF_ICON = &H2
Public Const NIF_TIP = &H4
Public Const WM_MOUSEMOVE = &H200
Public Const WM_LBUTTONDOWN = &H201     'Button down
Public Const WM_LBUTTONUP = &H202       'Button up
Public Const WM_LBUTTONDBLCLK = &H203   'Double-click
Public Const WM_RBUTTONDOWN = &H204     'Button down
Public Const WM_RBUTTONUP = &H205       'Button up
Public Const WM_RBUTTONDBLCLK = &H206   'Double-click
Public Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function Shell_NotifyIcon Lib "shell32" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, pnid As NOTIFYICONDATA) As Boolean
Public nid As NOTIFYICONDATA
Public InTray As Boolean

' routine to get a parameter
Public Function xPL_GetParam(Msg As xPL.xPLMsg, strName As String, WithStrip As Boolean) As Variant

    Dim x As Integer
    Dim Y As Integer
    
    ' find name match
    For Y = 0 To Msg.NamePairs - 1
        If UCase(Msg.Names(Y)) Like UCase(strName) Then
            ' got match
            xPL_GetParam = Msg.Values(Y)
            If WithStrip = True Then xPL_GetParam = Trim(xPL_GetParam)
            Exit Function
        End If
    Next Y

End Function

' function to calculate dusk and dawn for given date
' this code is based on code written by Thomas Laureanno
Public Function CalculateDuskDawn(WhichDate As Date) As Boolean

    Dim PL, J, DA, M, GM
    Dim N(12)
    Dim DEGTMP, LA, LO, TD, CNT
    Dim x, E, D, Y, Z
    Dim CL, SD, CD, ST, CT
    Dim T, TT, T1, T2
    Dim strT1, strT2, strGM
    Dim Lat As Double
    Dim Lng As Double
    
    ' get day, month etc
    DA = Day(WhichDate)
    M = Month(WhichDate)
    Lat = Latitude
    Lng = Longitude
    
    ' fixed values
    CalculateDuskDawn = False
    PL = 3.14159 / 26
    J = 57.2958
    N(1) = 0
    N(2) = 31
    N(3) = 59
    N(4) = 90
    N(5) = 120
    N(6) = 151
    N(7) = 181
    N(8) = 212
    N(9) = 243
    N(10) = 273
    N(11) = 304
    N(12) = 334
    
    ' calculate
    DEGTMP = (Abs(Lat) - Abs(Fix(Lat))) * 100 / 60
    Lat = (Fix(Abs(Lat)) + DEGTMP) * Sgn(Lat)
    DEGTMP = (Abs(Lng) - Abs(Fix(Lng))) * 100 / 60
    Lng = (Fix(Abs(Lng)) + DEGTMP) * Sgn(Lng)
    LA = Lat
    If LA < 0 Then LA = LA + 180
    If Lng < 0 Then Lng = Lng + 360
    LO = Fix(Lng / 15) * 15
    TD = (Lng - LO) / 15
    x = (N(M) + DA) / 7
    D = 0.456 - 22.195 * Cos(PL * x) - 0.43 * Cos(2 * PL * x) - 0.156 * Cos(3 * PL * x) + 3.83 * Sin(PL * x) + 0.06 * Sin(2 * PL * x) - 0.082 * Sin(3 * PL * x)
    E = 0.008000001 + 0.51 * Cos(PL * x) - 3.197 * Cos(2 * PL * x) - 0.106 * Cos(3 * PL * x) - 0.15 * Cos(4 * PL * x) - 7.317001 * Sin(PL * x) - 9.471001 * Sin(2 * PL * x) - 0.391 * Sin(3 * PL * x) - 0.242 * Sin(4 * PL * x)
    CL = Cos(LA / J): SD = Sin(D / J): CD = Cos(D / J): Y = SD / CL
    If Abs(Y) >= 1 Then Exit Function
    Z = 90 - J * Atn(Y / Sqr(1 - Y * Y))
    ST = Sin(Z / J) / CD
    If Abs(ST) >= 1 Then
        T = 6
        TT = 6
    Else
        CT = Sqr(1 - ST * ST)
        T = J / 15 * Atn(ST / CT)
        TT = T
    End If
    
    ' dawn
    If D < 0 And LA < 90 Then T = 12 - T: TT = T
    If D > 0 And LA > 90 Then T = 12 - T: TT = T
    T = T + TD - E / 60 - 0.04
    T1 = Int(T): T2 = T - T1: strT1 = Str$(T1): T2 = Int((T2 * 600 + 5) / 10)
    If T2 = 60 Then T2 = 59
    strT2 = Str$(T2): strT2 = Right$(strT2, Len(strT2) - 1)
    If Int(T2) < 10 Then strT2 = "0" + strT2
    GM = Fix(Lng / 15): Rem calculate difference between GM and local time
    If CNT = 0 Then GM = Val(strT1) + GM: Rem GMT for sunrise
    If CNT > 0 Then GM = Val(strT1) + 12 + GM: Rem GMT for sunset
    If GM + (Val(strT2) / 60) > 24 Then GM = GM - 24
    strGM = Str$(GM): strGM = Right$("0" + strGM, 2)
    Dawn = Format(WhichDate, "dd/mm/yyyy " + strT1 + ":" + strT2 + ":00")
    Dawn = DateAdd("n", DawnAdj, Dawn)
    
    ' dusk
    T = 12 - TT: T = T + TD - E / 60 + 0.04
    CNT = 1
    T1 = Int(T): T2 = T - T1: strT1 = Str$(T1): T2 = Int((T2 * 600 + 5) / 10)
    If T2 = 60 Then T2 = 59
    strT2 = Str$(T2): strT2 = Right$(strT2, Len(strT2) - 1)
    If Int(T2) < 10 Then strT2 = "0" + strT2
    GM = Fix(Lng / 15): Rem calculate difference between GM and local time
    If CNT = 0 Then GM = Val(strT1) + GM: Rem GMT for sunrise
    If CNT > 0 Then GM = Val(strT1) + 12 + GM: Rem GMT for sunset
    If GM + (Val(strT2) / 60) > 24 Then GM = GM - 24
    strGM = Str$(GM): strGM = Right$("0" + strGM, 2)
    Dusk = Format(WhichDate, "dd/mm/yyyy " + strT1 + ":" + strT2 + ":00")
    Dusk = DateAdd("h", 12, Dusk) ' 24 hour clock
    Dusk = DateAdd("n", DuskAdj, Dusk)
    CalculateDuskDawn = True
    
End Function


Public Function xPL_BuildInstance(strInstance As String) As String
    
    Dim strHost As String
    Dim NewInst As String
    Dim x As Integer
    
    ' build
    strHost = UCase(strInstance)
    For x = 1 To Len(strHost)
        Select Case Mid$(strHost, x, 1)
        Case "0" To "9", "A" To "Z"
            NewInst = NewInst + Mid$(strHost, x, 1)
        End Select
    Next x
    NewInst = Left$(NewInst, 10)
    If NewInst = "" Then NewInst = "INSTANCE"
    xPL_BuildInstance = NewInst & Format(Now, "hhmmss")
    
End Function


