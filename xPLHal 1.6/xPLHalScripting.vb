'**************************************
'* xPLHal 
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

Imports System.Text

Module xPLHalScripting

    ' scripting
    Public xPLClass As New XPL
    Public X10Class As New X10
    Public SYSClass As New SYS
    Public XAPClass As New XAP
    Public xPLScripts As String
    Public chkScript As New Hashtable
    Public prechkScript As New Hashtable
    Public xPLMatchAll As Boolean

    ' run a script
    Public Function RunScript(ByVal strScript As String, ByVal HasParams As Boolean, ByVal strParams As Object) As Boolean
        Dim xPLThread As New Scripting
        Dim t As Thread
        Try
            If chkScript.ContainsKey(UCase(strScript)) Then
                xPLThread.InitThread()
                t = New Thread(AddressOf xPLThread.xPLHalRunScript)
                xPLThread.xPLHalRunScriptName = strScript
                xPLThread.xPLHalRunHasParams = HasParams
                xPLThread.xPLHalRunParams = strParams
                t.Start()
                Return True ' ok
            Else
                Return False ' doesnt exist
            End If
        Catch ex As Exception
            Return False ' error
        End Try
    End Function

    ' build safe name for script routine
  Public Function GetScriptSub(ByVal strSubName As String) As String
        Dim strSub As String
    strSub = ""
    Dim x As Integer
    strSubName = strSubName.Trim().ToUpper()
    For x = 1 To Len(strSubName)
      Select Case Mid(strSubName, x, 1)
        Case "0" To "9"
          strSub = strSub + Mid(strSubName, x, 1)
        Case "A" To "Z"
          strSub = strSub + Mid(strSubName, x, 1)
        Case Else
          strSub = strSub + "_"
      End Select
    Next x
    Return strSub
  End Function

  Public Structure xPLScriptStruc
    Public Source As String ' containing script file
    Public IsSub As Boolean ' true = sub, false = function
    Public Params As Short ' no of parameters
  End Structure

  ' initialise scripts
  Public Function InitScripts() As Boolean
    Dim scScript As New StringBuilder
    prechkScript.Clear()
    AddScripts(xPLHalScripts + "\headers\", scScript)
    AddScripts(xPLHalScripts + "\user\", scScript)
    AddScripts(xPLHalScripts + "\", scScript)
    Try
      Dim sc As New MSScriptControl.ScriptControl
      sc.Language = "VBScript"
      sc.AddCode(scScript.ToString)
      xPLScripts = scScript.ToString
      chkScript = prechkScript
      Return True
    Catch ex As Exception
      Call WriteErrorLog("Unable to (re)Load Scripts, original scripts restored (" & Err.Description & ")")
      Return False
    End Try
    Return True
  End Function

  ' process each script
  Sub AddScripts(ByVal strPath As String, ByRef sb As StringBuilder)
    Dim DirScripts As String
    Dim strInput As String
        Dim fs As TextReader
    Dim x As Integer, y As Integer, z As Integer, l As Integer
    For l = 1 To 2
      If l = 1 Then
        DirScripts = Dir(strPath + "*.xpl", FileAttribute.Normal)
      Else
        DirScripts = Dir(strPath + "*.xap", FileAttribute.Normal)
      End If
      While DirScripts <> ""
        fs = File.OpenText(strPath & DirScripts)
        strInput = fs.ReadLine
        While Not strInput Is Nothing
          strInput = strInput.Trim
          strInput = strInput & "       "
          If strInput.Substring(0, 1) = "'" Or strInput.Substring(0, 3).ToUpper = "REM " Or strInput.Substring(0, 7).ToUpper = "REMARK " Then strInput = " "
          strInput.Trim()
          If strInput.Length > 0 Then
            sb.Append(strInput & vbCrLf)
            If (strInput & "    ").ToUpper.Substring(0, 4) = "SUB " Or (strInput & "         ").ToUpper.Substring(0, 9) = "FUNCTION " Then
              x = InStr(strInput, " ", CompareMethod.Binary)
              While strInput.Substring(x, 1) = " "
                x = x + 1
              End While
              y = InStr(x + 1, strInput & " ", " ", CompareMethod.Binary)
              z = InStr(x + 1, strInput & "(", "(", CompareMethod.Binary)
              Dim s As New xPLScriptStruc
              s.Source = strPath + DirScripts
              s.IsSub = True
              If (strInput & "         ").ToUpper.Substring(0, 9) = "FUNCTION " Then s.IsSub = False
              s.Params = CountParams(strInput)
              Try
                If z < y Then
                  prechkScript.Add(strInput.ToUpper.Substring(x, z - x - 1), s)
                Else
                  prechkScript.Add(strInput.ToUpper.Substring(x, y - x - 1), s)
                End If
              Catch ex As Exception
                WriteErrorLog("Duplicate Sub/Function Loading Scripts (" & Err.Description & ")")
              End Try
            End If
          End If
          strInput = fs.ReadLine
        End While
        fs.Close()
        DirScripts = Dir()
      End While
    Next l
  End Sub

  ' routine to calculate number of params in a sub or function
  Private Function CountParams(ByVal SubLine As String) As Integer
    Dim w(2), x, z As Integer
    Dim y(4) As Boolean
    z = -1
    w(0) = InStr(1, SubLine, "(", CompareMethod.Binary)
    w(1) = w(0) + 1
    w(2) = w(0) - 1
    w(0) = InStr(w(0) + 1, SubLine, ")", CompareMethod.Binary)
    While w(0) > 0
      w(2) = w(0) - 1
      w(0) = InStr(w(0) + 1, SubLine, ")", CompareMethod.Binary)
    End While
    If w(1) < w(2) Then
      For x = w(1) To w(2)
        Select Case SubLine.Substring(x - 1, 1)
          Case ","
            If z = -1 Then z = 0
            If y(1) = False And y(2) = False And y(3) = False Then z = z + 1
          Case "("
            If z = -1 Then z = 0
            y(1) = True
          Case ")"
            If z = -1 Then z = 0
            y(1) = False
          Case "'"
            If z = -1 Then z = 0
            y(2) = Not y(2)
          Case Chr(34)
            If z = -1 Then z = 0
            y(3) = Not y(3)
          Case " ", vbTab
          Case Else
            If z = -1 Then z = 0
        End Select
      Next
    End If
    If z = -1 Then
      Return 0
    Else
      Return z + 1
    End If
  End Function

End Module
