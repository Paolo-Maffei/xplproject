'**************************************
'* xPL xPLHal 
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
Public Class SYS

    ' handle settings
    Public Property Setting(ByVal SettingName As Object) As Object
        Get
            Try
                If Not xPLHalsHash.ContainsKey(UCase(SettingName)) Then Return Nothing
                Return xPLHals(xPLHalsHash(UCase(SettingName))).Value
            Catch ex As Exception
                Return Nothing
            End Try
        End Get
        Set(ByVal Value As Object)
            Dim strScript As String
            Dim oValue As Short
            Dim x As Integer
            Dim sc As New MSScriptControl.ScriptControl

            Try
                SettingName = UCase(SettingName)
                If xPLHalsHash.ContainsKey(SettingName) Then
                    x = xPLHalsHash(SettingName)
                    If Value >= 0 Or Value < xPLHals(x).ValuesCount Then
                        oValue = xPLHals(x).Value
                        xPLHals(x).Value = Value
                        xPLGlobals.Value(SettingName) = Value
                        xPLGlobals.Value(SettingName & "_UPDATED") = Now
                        If xPLHals(x).Value <> oValue Or xPLHals(x).Init = False Then
                            strScript = GetScriptSub(SettingName & "_" & xPLHals(x).Values(Value).Name)
                            sc.Language = "VBScript"
                            If Len(xPLScripts) > 0 Then
                                Try
                                    sc.AddCode(xPLScripts)
                                Catch ex As Exception
                                    Call WriteErrorLog("Unable to Load Scripts (" & Err.Description & ")")
                                    Exit Property
                                End Try
                            End If
                            sc.AddObject("xPL", xPLClass) ' xPL function library
                            sc.AddObject("SYS", SYSClass) ' System function library
                            sc.AddObject("X10", X10Class) ' x10 function library
                            sc.AddObject("XAP", XAPClass) ' xAP support library
                            sc.AllowUI = False
                            CType(sc, MSScriptControl.IScriptControl).Timeout = 90000
                            If chkScript.ContainsKey(strScript.ToUpper) Then
                                Try
                                    Call sc.Run(strScript)
                                Catch ex As Exception
                                    Call WriteErrorLog("Error Executing Script '" + strScript + "' (" & Err.Description & ")")
                                End Try
                            End If
                        End If
                        xPLHals(x).Init = True
                    End If
                End If
            Catch ex As Exception
            End Try
        End Set
    End Property

    ' handle globals
    Public Property Value(ByVal GlobalName As Object) As Object
        Get
            If GlobalName = "" Then Return ""
            Return xPLGlobals.Value(UCase(GlobalName))
        End Get
        Set(ByVal Value As Object)
            Dim oValue As Object
            Dim strScript As String
            Dim sc As New MSScriptControl.ScriptControl

            Try
                GlobalName = UCase(GlobalName)
                If GlobalName = "" Then Exit Property
                oValue = xPLGlobals.Value(GlobalName)
                xPLGlobals.Value(GlobalName) = Value
                If oValue <> Value Then
                    strScript = GetScriptSub(GlobalName) + "_GLOBAL"
                    sc.Language = "VBScript"
                    If Len(xPLScripts) > 0 Then
                        Try
                            sc.AddCode(xPLScripts)
                        Catch ex As Exception
                            Call WriteErrorLog("Unable to Load Scripts (" & Err.Description & ")")
                            Exit Property
                        End Try
                    End If
                    sc.AddObject("xPL", xPLClass) ' xPL function library
                    sc.AddObject("SYS", SYSClass) ' System function library
                    sc.AddObject("X10", X10Class) ' x10 function library
                    sc.AddObject("XAP", XAPClass) ' xAP support library
                    sc.AllowUI = False
                    CType(sc, MSScriptControl.IScriptControl).Timeout = 90000
                    If chkScript.ContainsKey(strScript.ToUpper) Then
                        Try
                            Call sc.Run(strScript)
                        Catch ex As Exception
                            Call WriteErrorLog("Error Executing Script '" + strScript + "' (" & Err.Description & ")")
                        End Try
                    End If
                End If
            Catch ex As Exception
            End Try
        End Set
    End Property
    Public Function GlobalExists(ByVal GlobalName As Object) As Object
        Return xPLGlobals.Exists(UCase(GlobalName))
    End Function
    Public Function GlobalDelete(ByVal GlobalName As Object) As Object
        Return xPLGlobals.Delete(UCase(GlobalName))
    End Function
    Public Sub SaveGlobals()
        xPLGlobals.Save()
    End Sub

    ' handle events
    Public Function SingleEvent(ByVal evtDateTime As Object, ByVal evtRunSub As Object, ByVal evtParam As Object, ByVal evtTag As Object) As Object
        Dim e As New xPLHalEvents.xPLEventStruc
        Try
            If Not IsDate(evtDateTime) Then Return Nothing
            e.Recurring = False
            e.EventDateTime = evtDateTime
            e.EventRunTime = e.EventDateTime
            e.RunSub = evtRunSub
            e.Param = evtParam
            e.Tag = UCase(evtTag)
        Catch ex As Exception
            Return False
        End Try
        If e.RunSub.Length = 0 Then Return False
        If e.Tag.Length = 0 Then Return False
        e.RandomTime = 0
        e.Active = True
        Return xPLEvents.Add(e)
    End Function
    Public Function RecurringEvent(ByVal evtStart As Object, ByVal evtEnd As Object, ByVal evtInterval As Object, ByVal evtRandom As Object, ByVal evtDoW As Object, ByVal evtRunSub As Object, ByVal evtParam As Object, ByVal evtTag As Object, ByVal evtOverWrite As Object) As Object
        If evtOverWrite = False And EventExists(evtTag) = True Then Return Nothing
        Dim e As New xPLHalEvents.xPLEventStruc
        e.Recurring = True
        Try
            e.EventDateTime = DateAdd(DateInterval.Day, 1, Now)
            e.EventRunTime = e.EventDateTime
            e.StartTime = evtStart
            e.EndTime = evtEnd
            e.Interval = Int(Val(evtInterval))
            If e.Interval < 0 Then e.Interval = 0
            If e.Interval = 0 Then e.EndTime = e.StartTime
            e.RandomTime = Int(Val(evtRandom))
            If e.RandomTime < 0 Then e.RandomTime = 0
            e.DoW = evtDoW
            e.RunSub = evtRunSub
            e.Param = evtParam
            e.Tag = UCase(evtTag)
        Catch ex As Exception
            Return False
        End Try
        If e.DoW.Length > 7 Then e.DoW = e.DoW.Substring(0, 7)
        If e.DoW.Length < 7 Then e.DoW = e.DoW & "YYYYYYY".Substring(0, 7 - e.DoW.Length)
        If e.DoW = "NNNNNNN" Then Return False
        If e.RunSub.Length = 0 Then Return False
        If e.Tag.Length = 0 Then Return False
        e.Active = True
        Return xPLEvents.Add(e)
    End Function
    Public Sub EventDelete(ByVal evtTag As Object)
        Call xPLEvents.Delete(UCase(evtTag))
    End Sub
    Public Function EventExists(ByVal evtTag As Object) As Boolean
        Return xPLEvents.Exists(UCase(evtTag))
    End Function
    Public Sub SaveEvents()
        xPLEvents.Save()
    End Sub

    ' handle macros
    Public Sub RunMacro(ByVal MacroName As Object, ByVal MacroParam As Object)
        Try
            If MacroParam = "" Then
                Call RunScript(GetScriptSub(MacroName), False, "")
            Else
                Call RunScript(GetScriptSub(MacroName), True, MacroParam)
            End If
        Catch ex As Exception
        End Try
    End Sub

    ' get web page
    Function GetHTTP(ByVal varURL As Object, ByVal varSize As Object) As Object
        Dim objResponse As WebResponse
        Dim objRequest As WebRequest
        Dim result As String
        Dim l As Integer
        objRequest = HttpWebRequest.Create(varURL)
        objResponse = objRequest.GetResponse()
        Dim sr As New StreamReader(objResponse.GetResponseStream())
        result = sr.ReadToEnd
        sr.Close()
        l = result.Length
        If l > varSize Then result = result.Substring(0, varSize)
        Return result
    End Function

    ' routine to convert a time to text
    Function TextTime(ByVal Duration As Object) As Object
        'Dim strDuration As String
        Dim strHours As String
        Dim strMinutes As String
        Dim strSeconds As String
        strHours = Mid(Duration, 1, 2)
        If Left(strHours, 1) = "0" Then strHours = Mid(strHours, 2)
        strMinutes = Mid(Duration, 4, 2)
        If Left(strMinutes, 1) = "0" Then strMinutes = Mid(strMinutes, 2)
        strSeconds = Mid(Duration, 7, 2)
        If Left(strSeconds, 1) = "0" Then strSeconds = Mid(strSeconds, 2)
        TextTime = ""
        Select Case strHours
            Case "0"
            Case "1"
                TextTime = TextTime + "one hour "
            Case Else
                TextTime = TextTime + ReturnValueStr(Val(strHours)) + " hours "
        End Select
        Select Case strMinutes
            Case "0"
            Case "1"
                TextTime = TextTime + "one minute "
            Case Else
                TextTime = TextTime + ReturnValueStr(Val(strMinutes)) + " minutes "
        End Select
        Select Case strSeconds
            Case "0"
            Case "1"
                TextTime = TextTime + "one second"
            Case Else
                TextTime = TextTime + ReturnValueStr(Val(strSeconds)) + " seconds"
        End Select
    End Function

    Sub Waiting(ByVal HowLong As Object)
        'Dim WaitTimeOut As Date = DateAdd(DateInterval.Second, Int(Val(HowLong)), Now)
        'While WaitTimeOut > Now
        'End While
        If HowLong > 60 Then HowLong = 60
        If HowLong < 0.01 Then HowLong = 0.01
        Thread.Sleep(CInt(Int(Val(HowLong)) * 1000))

    End Sub

    Function SendSMTP(ByVal From As Object, ByVal Too As Object, ByVal Subject As Object, ByVal Body As Object, ByVal CC As Object, ByVal BCC As Object, ByVal Server As Object) As Object

        ' Extract the elements from the xPL message
        Dim mailMsg As New System.Net.Mail.MailMessage
        mailMsg.From = From
        mailMsg.To.Add(Too)
        mailMsg.Subject = Subject
        mailMsg.Body = Body
        mailMsg.Body = mailMsg.Body.Replace("\n", vbCrLf)
        mailMsg.CC.Add(CC)
        mailMsg.Bcc.Add(BCC)
        Try
            Dim smtp As New System.Net.Mail.SmtpClient(Server)
            smtp.Send(mailMsg)
            SendSMTP = ""
        Catch ex As Exception
            SendSMTP = ex.Message
        End Try

    End Function

    Function SendSMTPAttach(ByVal From As Object, ByVal Too As Object, ByVal Subject As Object, ByVal Body As Object, ByVal CC As Object, ByVal BCC As Object, ByVal Attachment As Object, ByVal Server As Object) As Object

        Dim mailMsg As New System.Net.Mail.MailMessage()

        ' Extract the elements from the xPL message
        mailMsg.From = From
        mailMsg.To.Add(Too)
        mailMsg.Subject = Subject
        mailMsg.Body = Body
        mailMsg.Body = mailMsg.Body.Replace("\n", vbCrLf)
        mailMsg.CC.Add(CC)
        mailMsg.Bcc.Add(BCC)
        If Attachment <> "" Then
            Try
                mailMsg.Attachments.Add(New System.Net.Mail.Attachment(Attachment))
            Catch ex As Exception
            End Try
        End If
        Try
            Dim smtp As New System.Net.Mail.SmtpClient(Server)
            smtp.Send(mailMsg)
            SendSMTPAttach = ""
        Catch ex As Exception
            SendSMTPAttach = ex.Message
        End Try

    End Function

    ' run external program
    Public Function Execute(ByVal programName As Object, ByVal Parameters As Object, ByVal WaitUntilDone As Object) As Object
        Dim p As System.Diagnostics.Process = System.Diagnostics.Process.Start(programName, Parameters)
        If WaitUntilDone Then
            If p.WaitForExit(60000) Then
                Execute = p.ExitCode
            Else
                Execute = 0
            End If
        Else
            Execute = 0
        End If
        p.Close()
    End Function

    ' log message
    Public Sub Log(ByVal logmessage As Object)
        Call WriteErrorLog("User Message (" & logmessage & ")")
    End Sub

End Class

