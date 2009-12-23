'**************************************
'* xPL Determinator
'*
'* Version 1.60
'*
'* Copyright (C) 2003-2008 John Bent, Ian Jeffery, Tony Tofts & Ian Lowe
'* http://www.xplhal.org/
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

Imports xPLLogging.Logger
Imports xPLLogging.LogLevel
Imports System.Text
Imports System.Threading
Imports System.IO
Imports System.Xml
Imports System.Reflection
Imports GOCManager
Imports xPLLogging

Public Class Determinator

    Public Shared DataFileFolder As String = ""
    Public Shared xPLSourceTag As String = ""
    Private Shared xPLCache As xPLCache
    Public Shared Rules() As DeterminatorRule
    Public Shared RuleGroups() As DeterminatorRule
    Public Shared RulesMutex As New Mutex

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function


    Public Class DeterminatorRule

        Public Enum ConditionTypes
            xPLMessage = 0
            globalCondition = 1
            globalChanged = 2
            dayCondition = 3
            timeCondition = 4
            x10Condition = 5
        End Enum

        Public Class DeterminatorCondition
            Public ConditionType As ConditionTypes
            Public Condition As Object
            Public DisplayName As String

            Public Class dayCondition
                Public DOW As String

                Public Function Evaluate() As Boolean
                    If DOW.Length = 7 Then
                        Dim w As Integer = Weekday(Now) - 1
                        Logger.AddLogEntry(AppInfo, "rules", "Evaluated Weekday=" & w)
                        If DOW.Substring(w, 1) = "1" Then
                            Return True
                        End If
                    Else
                        Logger.AddLogEntry(AppWarn, "rules", "Length of DOW should be 7 and it's actually " & DOW.Length)
                    End If
                    Return False
                End Function
            End Class

            Public Class timeCondition
                Public Category As String
                Public [Operator] As String
                Public value As String

                Public Function Evaluate() As Boolean
                    Dim DateValue As Integer
                    Select Case Category
                        Case "day"
                            DateValue = CInt(value)
                            Select Case [Operator]
                                Case "="
                                    If DateTime.Today.Day = DateValue Then
                                        Return True
                                    End If
                                Case "!="
                                    If Not DateTime.Today.Day = DateValue Then
                                        Return True
                                    End If
                                Case "<"
                                    If DateTime.Today.Day < DateValue Then
                                        Return True
                                    End If
                                Case ">"
                                    If DateTime.Today.Day > DateValue Then
                                        Return True
                                    End If
                                Case Else
                                    Logger.AddLogEntry(AppWarn, "rules", "Unrecognised operator for timeCondition: " & [Operator])
                            End Select
                        Case "month"
                            DateValue = CInt(value)
                            Select Case [Operator]
                                Case "="
                                    If DateTime.Today.Month = DateValue Then
                                        Return True
                                    End If
                                Case "!="
                                    If Not DateTime.Today.Month = DateValue Then
                                        Return True
                                    End If
                                Case "<"
                                    If DateTime.Today.Month < DateValue Then
                                        Return True
                                    End If
                                Case ">"
                                    If DateTime.Today.Month > DateValue Then
                                        Return True
                                    End If
                                Case Else
                                    Logger.AddLogEntry(AppWarn, "rules", "Unrecognised operator for timeCondition: " & [Operator])
                            End Select
                        Case "year"
                            DateValue = CInt(value)
                            Select Case [Operator]
                                Case "="
                                    If DateTime.Today.Year = DateValue Then
                                        Return True
                                    End If
                                Case "!="
                                    If Not DateTime.Today.Year = DateValue Then
                                        Return True
                                    End If
                                Case "<"
                                    If DateTime.Today.Year < DateValue Then
                                        Return True
                                    End If
                                Case ">"
                                    If DateTime.Today.Year > DateValue Then
                                        Return True
                                    End If
                                Case Else
                                    Logger.AddLogEntry(AppWarn, "rules", "Unrecognised operator for timeCondition: " & [Operator])
                            End Select
                        Case Else ' Assume time
                            Select Case [Operator]
                                Case "="
                                    If Now.ToString("HH:mm") = value Then
                                        Return True
                                    End If
                                Case "!="
                                    If Not Now.ToString("HH:mm") = value Then
                                        Return True
                                    End If
                                Case "<"
                                    If CDate(Now.ToString("HH:mm")) < CDate(value) Then
                                        Return True
                                    End If
                                Case ">"
                                    If CDate(Now.ToString("HH:mm")) > CDate(value) Then
                                        Return True
                                    End If
                                Case Else
                                    Logger.AddLogEntry(AppWarn, "rules", "Unrecognised operator for timeCondition: " & [Operator])
                            End Select
                    End Select
                    Return False
                End Function
            End Class

            Public Class xplCondition
                Public msg_type As String
                Public source_vendor, source_device, source_instance As String
                Public target_vendor, target_device, target_instance As String
                Public schema_class, schema_type As String
                Public params() As xplConditionParams

                Public Class xplConditionParams
                    Public Name As String
                    Public [Operator] As String
                    Public Value As String
                End Class

                Public Function Evaluate(ByVal x As xpllib.XplMsg) As Boolean

                    Logger.AddLogEntry(AppInfo, "rules", "Checking xPL message against our conditions.")
                    ' Check type of message
                    If msg_type <> "*" Then
                        If ("xpl-" & msg_type) <> x.MsgTypeString Then
                            Logger.AddLogEntry(AppInfo, "rules", "Message types don't match. We're looking for xpl-" & msg_type & " and we've got " & x.MsgTypeString)
                            Return False
                        End If
                    End If

                    ' Check the source
                    If Not source_vendor = "*" Then
                        If Not source_vendor = x.SourceVendor.ToLower Then
                            Logger.AddLogEntry(AppInfo, "rules", "Source vendor does not match: " & source_vendor & "=" & x.SourceVendor.ToLower)
                            Return False
                        End If
                    End If
                    If Not source_device = "*" Then
                        If Not source_device = x.SourceDevice Then
                            Logger.AddLogEntry(AppInfo, "rules", "Source device does not match." & source_device & "=" & x.SourceDevice.ToLower)
                            Return False
                        End If
                    End If
                    If Not source_instance = "*" Then
                        If Not source_instance = x.SourceInstance Then
                            Logger.AddLogEntry(AppInfo, "rules", "Source instance does not match: " & source_instance & "=" & x.SourceInstance)
                            Return False
                        End If
                    End If

                    ' Check the target
                    If Not target_vendor = "*" Then
                        If Not target_vendor = x.TargetVendor Then
                            Logger.AddLogEntry(AppInfo, "rules", "Target vendor does not match.")
                            Return False
                        End If
                    End If
                    If Not target_device = "*" Then
                        If Not target_device = x.TargetDevice Then
                            Logger.AddLogEntry(AppInfo, "rules", "Target device does not match.")
                            Return False
                        End If
                    End If
                    If Not target_instance = "*" Then
                        If Not target_instance = x.TargetInstance Then
                            Logger.AddLogEntry(AppInfo, "rules", "Target instance does not match.")
                            Return False
                        End If
                    End If
                    ' Check the schema
                    If Not schema_class = "*" Then
                        If Not schema_class = x.Class Then
                            Logger.AddLogEntry(AppInfo, "rules", "Schema class does not match.")
                            Return False
                        End If
                    End If
                    If Not schema_type = "*" Then
                        If Not schema_type = x.Type Then
                            Logger.AddLogEntry(AppInfo, "rules", "Schema type does not match.")
                            Return False
                        End If
                    End If

                    ' Check body parameters
                    For Each parameter In params
                        Select Case parameter.[Operator]
                            Case "="
                                Dim messagevalue As String = x.GetKeyValue(parameter.Name.Trim).Trim.ToLower
                                If messagevalue <> parameter.Value Then
                                    Logger.AddLogEntry(AppInfo, "rules", "Parameter " & x.GetKeyValue(parameter.Name).Trim.ToLower & "=" & parameter.Value & " is not true.")
                                    Return False
                                End If
                        End Select
                    Next
                    Return True
                End Function

            End Class

            Public Class globalCondition
                Public Name As String
                Public [Operator] As String
                Public Value As String

                Public Function Evaluate() As Boolean
                    Try
                        Name = Name
                        If Not xPLCache.Contains(Name) Then
                            Return False
                        End If

                        ' If the value is a reference to a global, grab the value
                        If Value.StartsWith("{") And Value.IndexOf("}") > 1 Then
                            Dim ObjectName As String = Value.Substring(1, Value.IndexOf("}") - 1)
                            If xPLCache.Contains(ObjectName) Then
                                Value = xPLCache.ObjectValue(Name).ToString
                            End If
                        End If
                        Select Case [Operator]
                            Case "="
                                If xPLCache.ObjectValue(Name).ToString = Value Then
                                    Return True
                                Else
                                    Return False
                                End If
                            Case "!="
                                If xPLCache.ObjectValue(Name).ToString = Value Then
                                    Return False
                                Else
                                    Return True
                                End If
                            Case "<"
                                If Not IsNumeric(xPLCache.ObjectValue(Name).ToString) Then
                                    Return False
                                End If
                                If CDbl(xPLCache.ObjectValue(Name)) < CDbl(Value) Then
                                    Logger.AddLogEntry(AppInfo, "rules", "The value " & CDbl(xPLCache.ObjectValue(Name)) & " is less than " & CDbl(Value) & " - returning TRUE.")
                                    Return True
                                Else
                                    Return False
                                End If
                            Case ">"
                                If Not IsNumeric(xPLCache.ObjectValue(Name).ToString) Then
                                    Return False
                                End If
                                If CDbl(xPLCache.ObjectValue(Name)) > CDbl(Value) Then
                                    Return True
                                Else
                                    Return False
                                End If
                            Case "<="
                                If Not IsNumeric(xPLCache.ObjectValue(Name).ToString) Then
                                    Return False
                                End If
                                If CDbl(xPLCache.ObjectValue(Name)) <= CDbl(Value) Then
                                    Return True
                                Else
                                    Return False
                                End If
                            Case ">="
                                If Not IsNumeric(xPLCache.ObjectValue(Name).ToString) Then
                                    Return False
                                End If
                                If CDbl(xPLCache.ObjectValue(Name)) >= CDbl(Value) Then
                                    Return True
                                Else
                                    Return False
                                End If
                            Case Else
                                Logger.AddLogEntry(AppError, "rules", "Unrecognised global condition comparison operator: " & [Operator])
                        End Select
                    Catch ex As Exception
                        Logger.AddLogEntry(AppError, "rules", "Error evaluating global condition: " & ex.Message)
                        Evaluate = False
                    End Try
                End Function
            End Class

            Public Class globalChanged
                Public ObjectName As String

                Public Function Evaluate(ByVal name As String) As Boolean
                    If name = ObjectName Then
                        Return True
                    Else
                        Return False
                    End If
                End Function
            End Class

        End Class

        Public Class DeterminatorAction
            Public Enum ActionTypes
                xplAction = 0
                globalAction = 1
                executeAction = 2
                delayAction = 3
                execRuleAction = 4
                runScriptAction = 5
                logAction = 6
                suspendAction = 7
                stopAction = 8
            End Enum

            Public ActionType As ActionTypes
            Public Action As Object
            Public DisplayName As String
            Public ExecuteOrder As Integer

            Public Class RunScriptAction

                Public Event RunScript(ByVal _scriptname As String, ByVal _hasparams As Boolean, ByVal _parameters As String)

                Public ScriptName As String
                Public Parameters As String

                Public Sub Execute()
                    Dim res As Boolean
                    If Parameters = "" Then
                        RaiseEvent RunScript(ScriptName, False, "")
                    Else
                        RaiseEvent RunScript(ScriptName, True, Parameters)
                    End If
                    If Not res Then
                        Logger.AddLogEntry(AppError, "rules", "Script " & ScriptName & " failed to execute.")
                    End If
                End Sub
            End Class

            Public Class DelayAction
                Public DelaySeconds As Double

                Public Sub Execute()
                    Thread.Sleep(CInt(DelaySeconds * 1000))
                End Sub
            End Class

            Public Class execRuleAction
                Public RuleName As String

                Public Sub Execute()
                    ExecuteRule(RuleName, 0, False)
                End Sub

            End Class

            Public Class executeAction
                Public Program As String
                Public Parameters As String
                Public Wait As Boolean

                Public Sub Execute()
                    Try

                        Logger.AddLogEntry(AppError, "rules", "Executing " & Program & " with parameters " & Parameters)
                        Dim p As System.Diagnostics.Process = System.Diagnostics.Process.Start(Program, Parameters)
                        If Wait Then
                            p.WaitForExit(60000)
                        End If
                        p.Close()
                    Catch ex As Exception
                        Logger.AddLogEntry(AppError, "rules", "Error executing program " & Program & ": " & ex.Message)
                    End Try
                End Sub

            End Class

            Public Class logAction
                Public logText As String

                Public Sub Execute()
                    Logger.AddLogEntry(AppError, "rules", logText)
                End Sub
            End Class

            Public Class suspendAction
                Public SuspendMinutes As Integer
                Public suspendTime As String
                Public suspendRandomise As Integer

                Public Sub Execute(ByVal index As Integer, ByVal ruleName As String)
                    '' Handle relative minute suspensions
                    'If SuspendMinutes > 0 Then
                    '    Dim d As Date = Now.Add(New TimeSpan(0, SuspendMinutes, 0))
                    '    If suspendRandomise > 0 Then
                    '        d = DateAdd(DateInterval.Minute, (Int(Rnd() * (suspendRandomise + 1))), d)
                    '    End If
                    '    SYSClass.SingleEvent(d, "{suspended-determinator}", (index + 1).ToString & ":" & ruleName, "Suspended_" & Guid.NewGuid.ToString)
                    'Else
                    '    ' Handle absolute suspensions
                    '    Dim d As Date = CDate(Now.ToString("dd/MMM/yyyy") & " " & suspendTime)
                    '    If suspendRandomise > 0 Then
                    '        d = DateAdd(DateInterval.Minute, (Int(Rnd() * (suspendRandomise + 1))), d)
                    '    End If
                    '    SYSClass.SingleEvent(d, "{suspended-determinator}", index.ToString & ":" & ruleName, "Suspended_" & Guid.NewGuid.ToString)
                    'End If
                End Sub
            End Class

            Public Class stopAction
                ' No methods or properties required
            End Class

            Public Class xplAction
                Public msg_type As String
                Public msg_target As String
                Public msg_schema As String
                Public params() As String

                Public Sub Execute(ByRef xSource As xpllib.XplMsg, ByVal myxPLSourceTag As String)
                    Dim newParams(params.Length - 1) As String
                    params.CopyTo(newParams, 0)
                    Dim str As String = "xpl-" & msg_type & vbLf & "{" & vbLf
                    str &= "hop=1" & vbLf & "source=" & myxPLSourceTag & vbLf
                    str &= "target=" & msg_target & vbLf & "}" & vbLf & msg_schema & vbLf & "{" & vbLf
                    For Counter As Integer = 0 To params.Length - 1
                        If params(Counter).IndexOf("{") > 0 Then
                            ' Replace system variables
                            newParams(Counter) = ProcessSystemVariables(newParams(Counter))
                            ' Loop through all globals and replace as appropriate
                            For Each ObjectName As String In xPLCache.ListAllObjects
                                newParams(Counter) = newParams(Counter).Replace("{" & ObjectName & "}", xPLCache.ObjectValue(ObjectName).ToString)
                            Next
                            ' Loop through source parameters
                            If Not xSource Is Nothing Then
                                For Each entry In xSource.KeyValues
                                    newParams(Counter) = newParams(Counter).Replace("{XPL::" & entry.Key & "}", entry.Value)
                                Next
                            End If
                        End If
                        str &= newParams(Counter) & vbLf
                    Next
                    str &= "}" & vbLf
                    Dim x As New xpllib.XplMsg(str)
                    x.Send()
                End Sub
            End Class

            Public Class globalAction
                Public Name As String
                Public Value As String

                Public Sub Execute(ByRef xSource As xpllib.XplMsg)
                    Dim newValue As String = Value
                    Name = Name

                    Logger.AddLogEntry(AppInfo, "rules", "Setting global " & Name & " to " & newValue)
                    Try
                        ' De-reference any xPL body parameters
                        If Not xSource Is Nothing And newValue.IndexOf("{XPL::") >= 0 Then
                            For Each entry In xSource.KeyValues
                                newValue = newValue.Replace("{XPL::" & entry.Key.ToUpper & "}", entry.Value)
                            Next
                        End If

                        ' It's a normal global

                        ' De-reference any references to other globals
                        If newValue.StartsWith("{") And newValue.IndexOf("}") > 1 Then
                            Dim global2 As String = newValue.Substring(1, newValue.IndexOf("}") - 1)
                            Logger.AddLogEntry(AppInfo, "rules", "Global2=" & global2 & ".")

                            If newValue.EndsWith("++") Then
                                ' Increment global
                                xPLCache.ObjectValue(Name) = xPLCache.ObjectValue(Name) + 1
                            ElseIf newValue.EndsWith("--") Then
                                ' Decrement global
                                xPLCache.ObjectValue(Name) = xPLCache.ObjectValue(Name) - 1
                            ElseIf global2.StartsWith("SYS::") Then
                                ' Replace system variables
                                Logger.AddLogEntry(AppInfo, "rules", "Replacing system variables in " & newValue)
                                newValue = ProcessSystemVariables(newValue)
                                xPLCache.ObjectValue(Name) = newValue
                            Else
                                xPLCache.ObjectValue(Name) = xPLCache.ObjectValue(global2)
                            End If
                        Else
                            ' No de-referencing to do
                            If xPLCache.Contains(Name) Then
                                xPLCache.ObjectValue(Name) = newValue
                            Else
                                xPLCache.Add(Name, newValue, False)
                            End If
                        End If
                    Catch ex As Exception
                        Logger.AddLogEntry(AppError, "rules", "Error setting global " & Name & ": " & ex.Message)
                    End Try
                End Sub
            End Class

            Public Function Execute(ByVal ruleName As String, ByRef xSource As xpllib.XplMsg) As Boolean
                Try
                    Execute = True
                    Select Case ActionType
                        Case ActionTypes.delayAction
                            CType(Action, DelayAction).Execute()
                        Case ActionTypes.execRuleAction
                            CType(Action, execRuleAction).Execute()
                        Case ActionTypes.executeAction
                            CType(Action, executeAction).Execute()
                        Case ActionTypes.globalAction
                            CType(Action, globalAction).Execute(xSource)
                        Case ActionTypes.logAction
                            CType(Action, logAction).Execute()
                        Case ActionTypes.runScriptAction
                            CType(Action, RunScriptAction).Execute()
                        Case ActionTypes.stopAction
                            Execute = False
                        Case ActionTypes.suspendAction
                            CType(Action, suspendAction).Execute(ExecuteOrder, ruleName)
                            Execute = False
                        Case ActionTypes.xplAction
                            CType(Action, xplAction).Execute(xSource, xPLSourceTag)
                    End Select
                Catch ex As Exception
                    Logger.AddLogEntry(AppError, "rules", "Error executing action: " & DisplayName & ": " & ex.ToString)
                End Try
            End Function

            Public Shared Function ProcessSystemVariables(ByVal str As String) As String
                ' Date
                str = str.Replace("{SYS::DATE}", Now.ToString("dd/MM/yyyy"))
                str = str.Replace("{SYS::DATE_UK}", Now.ToString("dd/MM/yyyy"))
                str = str.Replace("{SYS::DATE_US}", Now.ToString("MM/dd/yyyy"))
                str = str.Replace("{SYS::DATE_YMD}", Now.ToString("yyyy/MM/dd"))

                ' Day
                str = str.Replace("{SYS::DAY}", Now.ToString("dd"))
                ' Month
                str = str.Replace("{SYS::MONTH}", Now.ToString("M"))

                ' Year
                str = str.Replace("{SYS::YEAR}", Now.ToString("yyyy"))

                ' Time
                str = str.Replace("{SYS::TIME}", Now.ToString("HH:mm:ss"))
                str = str.Replace("{SYS::HOUR}", Now.ToString("HH"))
                str = str.Replace("{SYS::MINUTE}", Now.ToString("MM"))
                str = str.Replace("{SYS::SECOND}", Now.ToString("ss"))

                ' Timestamp
                str = str.Replace("{SYS::TIMESTAMP}", Now.ToString("yyyyMMddHHmmss"))

                Return str
            End Function
        End Class

        Public RuleGUID As String
        Public IsGroup As Boolean
        Public GroupName As String
        Public Enabled As Boolean
        Public RuleName As String
        Public RuleDescription As String
        Public MatchAny As Boolean
        Public Conditions() As DeterminatorCondition
        Public Actions() As DeterminatorAction

        Public Sub New()
            ReDim Actions(-1)
            ReDim Conditions(-1)
            MatchAny = False
            IsGroup = False
        End Sub

        Public Function Save() As String
            Dim Counter As Integer
            Dim newstream As New MemoryStream
            Dim xmlw As New XmlTextWriter(newstream, Nothing)
            xmlw.Formatting = Formatting.Indented
            xmlw.WriteStartDocument(False)
            xmlw.WriteStartElement("xplDeterminator")
            xmlw.WriteStartElement("determinator")
            xmlw.WriteAttributeString("name", RuleName)
            xmlw.WriteAttributeString("description", RuleDescription)
            xmlw.WriteAttributeString("groupName", GroupName)
            If IsGroup Then
                xmlw.WriteAttributeString("isGroup", "Y")
            Else
                xmlw.WriteAttributeString("isGroup", "N")
            End If
            If Enabled Then
                xmlw.WriteAttributeString("enabled", "Y")
            Else
                xmlw.WriteAttributeString("enabled", "N")
            End If

            ' Input section
            xmlw.WriteStartElement("input")
            If MatchAny Then
                xmlw.WriteAttributeString("match", "any")
            Else
                xmlw.WriteAttributeString("match", "all")
            End If
            For Counter = 0 To Conditions.Length - 1
                Select Case Conditions(Counter).ConditionType
                    Case ConditionTypes.xPLMessage
                        xmlw.WriteStartElement("xplCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        Dim x As DeterminatorCondition.xplCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.xplCondition)
                        xmlw.WriteAttributeString("msg_type", x.msg_type)
                        xmlw.WriteAttributeString("source_vendor", x.source_vendor.ToLower.Trim)
                        xmlw.WriteAttributeString("source_device", x.source_device.ToLower.Trim)
                        xmlw.WriteAttributeString("source_instance", x.source_instance.ToLower.Trim)
                        xmlw.WriteAttributeString("target_vendor", x.target_vendor.ToLower.Trim)
                        xmlw.WriteAttributeString("target_device", x.target_device.ToLower.Trim)
                        xmlw.WriteAttributeString("target_instance", x.target_instance.ToLower.Trim)
                        xmlw.WriteAttributeString("schema_class", x.schema_class.ToLower.Trim)
                        xmlw.WriteAttributeString("schema_type", x.schema_type.ToLower.Trim)
                        For Counter2 As Integer = 0 To x.params.Length - 1
                            xmlw.WriteStartElement("param")
                            xmlw.WriteAttributeString("name", x.params(Counter2).Name)
                            xmlw.WriteAttributeString("operator", x.params(Counter2).[Operator])
                            xmlw.WriteAttributeString("value", x.params(Counter2).Value)
                            xmlw.WriteEndElement()
                        Next
                        xmlw.WriteEndElement()
                    Case ConditionTypes.globalCondition
                        Dim x As DeterminatorCondition.globalCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.globalCondition)
                        xmlw.WriteStartElement("globalCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("name", x.Name)
                        xmlw.WriteAttributeString("operator", x.[Operator])
                        xmlw.WriteAttributeString("value", x.Value)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.globalChanged
                        Dim x As DeterminatorCondition.globalChanged = CType(Conditions(Counter).Condition, DeterminatorCondition.globalChanged)
                        xmlw.WriteStartElement("globalChanged")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("name", x.ObjectName)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.dayCondition
                        Dim x As DeterminatorCondition.dayCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.dayCondition)
                        xmlw.WriteStartElement("dayCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("dow", x.DOW)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.timeCondition
                        Dim x As DeterminatorCondition.timeCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.timeCondition)
                        xmlw.WriteStartElement("timeCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("category", x.Category)
                        xmlw.WriteAttributeString("operator", x.[Operator])
                        xmlw.WriteAttributeString("value", x.value)
                        xmlw.WriteEndElement()
                End Select
            Next
            xmlw.WriteEndElement()

            ' Output section
            xmlw.WriteStartElement("output")
            For Counter = 0 To Actions.Length - 1
                Select Case Actions(Counter).ActionType
                    Case DeterminatorAction.ActionTypes.delayAction
                        Dim x As DeterminatorAction.DelayAction = CType(Actions(Counter).Action, DeterminatorAction.DelayAction)
                        xmlw.WriteStartElement("delayAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("delay_seconds", x.DelaySeconds.ToString)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.execRuleAction
                        Dim x As DeterminatorAction.execRuleAction = CType(Actions(Counter).Action, DeterminatorAction.execRuleAction)
                        xmlw.WriteStartElement("execRuleAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("rule_name", x.RuleName)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.executeAction
                        Dim x As DeterminatorAction.executeAction = CType(Actions(Counter).Action, DeterminatorAction.executeAction)
                        xmlw.WriteStartElement("executeAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("program", x.Program)
                        xmlw.WriteAttributeString("parameters", x.Parameters)
                        xmlw.WriteAttributeString("wait", x.Wait.ToString)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.globalAction
                        Dim x As DeterminatorAction.globalAction = CType(Actions(Counter).Action, DeterminatorAction.globalAction)
                        xmlw.WriteStartElement("globalAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("name", x.Name)
                        xmlw.WriteAttributeString("value", x.Value)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.logAction
                        Dim x As DeterminatorAction.logAction = CType(Actions(Counter).Action, DeterminatorAction.logAction)
                        xmlw.WriteStartElement("logAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("logText", x.logText)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.runScriptAction
                        Dim x As DeterminatorAction.RunScriptAction = CType(Actions(Counter).Action, DeterminatorAction.RunScriptAction)
                        xmlw.WriteStartElement("runScriptAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("script_name", x.ScriptName)
                        xmlw.WriteAttributeString("parameters", x.Parameters)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.stopAction
                        xmlw.WriteStartElement("stopAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.suspendAction
                        Dim x As DeterminatorAction.suspendAction = CType(Actions(Counter).Action, DeterminatorAction.suspendAction)
                        xmlw.WriteStartElement("suspendAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("suspend_minutes", x.SuspendMinutes.ToString)
                        xmlw.WriteAttributeString("suspend_time", x.suspendTime)
                        xmlw.WriteAttributeString("suspend_randomise", x.suspendRandomise.ToString)
                        xmlw.WriteEndElement()
                    Case DeterminatorAction.ActionTypes.xplAction
                        Dim x As DeterminatorAction.xplAction = CType(Actions(Counter).Action, DeterminatorAction.xplAction)
                        xmlw.WriteStartElement("xplAction")
                        xmlw.WriteAttributeString("executeOrder", Counter.ToString)
                        xmlw.WriteAttributeString("display_name", Actions(Counter).DisplayName)
                        xmlw.WriteAttributeString("msg_type", x.msg_type)
                        xmlw.WriteAttributeString("msg_target", x.msg_target)
                        xmlw.WriteAttributeString("msg_schema", x.msg_schema)
                        For counter3 As Integer = 0 To x.params.Length - 1
                            xmlw.WriteStartElement("xplActionParam")
                            xmlw.WriteAttributeString("expression", x.params(counter3))
                            xmlw.WriteEndElement()
                        Next
                        xmlw.WriteEndElement()
                End Select
            Next
            xmlw.WriteEndElement()

            xmlw.WriteEndElement()
            xmlw.WriteEndElement()
            xmlw.Close()

            Return Encoding.UTF8.GetString(newstream.ToArray)
        End Function

    End Class

    Public ReadOnly Property Rule(ByVal index As Integer) As DeterminatorRule
        Get
            RulesMutex.WaitOne()
            Dim r As DeterminatorRule = Rules(index)
            RulesMutex.ReleaseMutex()
            Return r
        End Get
    End Property

    Public ReadOnly Property RuleCount() As Integer
        Get
            Return Rules.Length
        End Get
    End Property

    Public Shared Sub InitRulesEngine()
        ReDim Rules(-1)
        ReDim RuleGroups(-1)
        LoadRules()
    End Sub

    Public Shared Sub CacheChanged(ByVal ObjectName As String)
        Try
            ' Loop through all rules
            For Each entry In Rules
                ' Loop through all conditions
                For Each detcond In entry.Conditions
                    If detcond.ConditionType = DeterminatorRule.ConditionTypes.globalChanged Then
                        If CType(detcond.Condition, DeterminatorRule.DeterminatorCondition.globalChanged).ObjectName = ObjectName Then
                            ExecuteRule(entry.RuleName)
                            Exit For
                        End If
                    End If
                Next
            Next
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "rules", "Error checking determinators following global value change: " & ex.Message)
        End Try
    End Sub

    Public Shared Sub ExecuteRule(ByVal rulename As String, Optional ByVal offset As Integer = 0, Optional ByVal RunIfDisabled As Boolean = True)
        rulename = rulename.ToLower
        For Each entry In Rules
            If Not entry.IsGroup And entry.RuleName.ToLower = rulename Or entry.RuleGUID.ToLower = rulename Then
                Logger.AddLogEntry(AppInfo, "rules", "Evaluating the rule " & rulename & " from offset " & offset)
                ' If disabled, don't run it if configured not to do so
                If Not RunIfDisabled And Not entry.Enabled Then
                    Logger.AddLogEntry(AppWarn, "rules", "Rule is disabled.")
                    Exit Sub
                End If

                Dim res As Boolean = True, found As Boolean = False

                ' Evaluate any group conditions
                If entry.GroupName <> "" Then

                End If

                ' Loop through all conditions and evaluate them
                If entry.Conditions.Length = 0 Or offset > 0 Then
                    ' No conditions defined, or we're resuming a suspended determinator
                    found = True
                Else
                    For Each entrycondition In entry.Conditions
                        Select Case entrycondition.ConditionType
                            Case DeterminatorRule.ConditionTypes.dayCondition
                                Dim x As DeterminatorRule.DeterminatorCondition.dayCondition = CType(entrycondition.Condition, DeterminatorRule.DeterminatorCondition.dayCondition)
                                res = x.Evaluate()
                            Case DeterminatorRule.ConditionTypes.timeCondition
                                Dim x As DeterminatorRule.DeterminatorCondition.timeCondition = CType(entrycondition.Condition, DeterminatorRule.DeterminatorCondition.timeCondition)
                                res = x.Evaluate()
                            Case DeterminatorRule.ConditionTypes.globalCondition
                                Dim x As DeterminatorRule.DeterminatorCondition.globalCondition = CType(entrycondition.Condition, DeterminatorRule.DeterminatorCondition.globalCondition)
                                res = x.Evaluate()
                                Logger.AddLogEntry(AppError, "rules", "Global condition " & x.Name & x.[Operator] & x.Value & " evaluated to " & res.ToString)
                        End Select
                        If entry.MatchAny = False And res = False Then
                            Exit Sub
                        ElseIf res Then
                            found = True
                        End If
                    Next
                End If
                If found Then
                    Logger.AddLogEntry(AppInfo, "rules", "Executing rule: " & entry.RuleName)

                    For Counter2 As Integer = offset To entry.Actions.Length - 1
                        If Not entry.Actions(Counter2).Execute(entry.RuleName, Nothing) Then
                            Exit For
                        End If
                    Next
                    Exit For
                Else
                    Logger.AddLogEntry(AppError, "rules", "Rule not executed.")
                End If
            End If
        Next
    End Sub

    Public Shared Sub SaveRule(ByVal ruleGuid As String)
        ' Saves a rule or rule group to disk
        For Each entry In Rules
            If entry.RuleGUID = ruleGuid Then
                Dim RuleText As String = entry.Save
                Dim fs As TextWriter = File.CreateText(DataFileFolder & ruleGuid & ".xml")
                fs.Write(RuleText)
                fs.Close()
                Exit For
            End If
        Next
    End Sub

    Public Shared Sub LoadRule(ByVal ruleGuid As String)
        ' Loads a rule or rule group into memory    
        Dim newRule As New DeterminatorRule
        Try
            ' If we already have the rule, remove it from memory first
            If Rules IsNot Nothing Then
                For Each entry In Rules
                    If entry.RuleGUID = ruleGuid Then
                        DeleteRule(ruleGuid, False)
                        Exit For
                    End If
                Next
            End If

            Dim xml As New XmlTextReader(DataFileFolder & ruleGuid & ".xml")

            newRule.RuleGUID = ruleGuid
            While xml.Read
                Select Case xml.NodeType
                    Case XmlNodeType.Element
                        Select Case xml.Name
                            Case "determinator"
                                newRule.RuleName = xml.GetAttribute("name")
                                newRule.RuleDescription = xml.GetAttribute("description")
                                newRule.GroupName = xml.GetAttribute("groupName")
                                If xml.GetAttribute("enabled") = "N" Then
                                    newRule.Enabled = False
                                Else
                                    newRule.Enabled = True
                                End If
                                If xml.GetAttribute("isGroup") = "Y" Then
                                    newRule.IsGroup = True
                                Else
                                    newRule.IsGroup = False
                                End If

                            Case "input"
                                If xml.GetAttribute("match") = "any" Then
                                    newRule.MatchAny = True
                                Else
                                    newRule.MatchAny = False
                                End If

                            Case "dayCondition"
                                ReDim Preserve newRule.Conditions(newRule.Conditions.Length)
                                newRule.Conditions(newRule.Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                Dim x As New DeterminatorRule.DeterminatorCondition.dayCondition
                                With newRule.Conditions(newRule.Conditions.Length - 1)
                                    .ConditionType = DeterminatorRule.ConditionTypes.dayCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    x.DOW = xml.GetAttribute("dow")
                                    .Condition = x
                                End With

                            Case "timeCondition"
                                ReDim Preserve newRule.Conditions(newRule.Conditions.Length)
                                newRule.Conditions(newRule.Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                Dim x As New DeterminatorRule.DeterminatorCondition.timeCondition
                                With newRule.Conditions(newRule.Conditions.Length - 1)
                                    .ConditionType = DeterminatorRule.ConditionTypes.timeCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    x.Category = xml.GetAttribute("category")
                                    x.[Operator] = xml.GetAttribute("operator")
                                    x.value = xml.GetAttribute("value")
                                    .Condition = x
                                End With

                            Case "xplCondition"
                                ReDim Preserve newRule.Conditions(newRule.Conditions.Length)
                                newRule.Conditions(newRule.Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                Dim x As New DeterminatorRule.DeterminatorCondition.xplCondition
                                With newRule.Conditions(newRule.Conditions.Length - 1)
                                    .ConditionType = DeterminatorRule.ConditionTypes.xPLMessage
                                    .DisplayName = xml.GetAttribute("display_name")
                                    x.msg_type = xml.GetAttribute("msg_type")
                                    x.source_vendor = xml.GetAttribute("source_vendor").ToLower
                                    x.source_device = xml.GetAttribute("source_device").ToLower
                                    x.source_instance = xml.GetAttribute("source_instance").ToLower
                                    x.target_vendor = xml.GetAttribute("target_vendor").ToLower
                                    x.target_device = xml.GetAttribute("target_device").ToLower
                                    x.target_instance = xml.GetAttribute("target_instance").ToLower
                                    x.schema_class = xml.GetAttribute("schema_class").ToLower
                                    x.schema_type = xml.GetAttribute("schema_type").ToLower
                                    ReDim x.params(-1)
                                    .Condition = x
                                End With

                            Case "param"
                                Dim x As DeterminatorRule.DeterminatorCondition.xplCondition = CType(newRule.Conditions(newRule.Conditions.Length - 1).Condition, DeterminatorRule.DeterminatorCondition.xplCondition)
                                ReDim Preserve x.params(x.params.Length)
                                x.params(x.params.Length - 1) = New DeterminatorRule.DeterminatorCondition.xplCondition.xplConditionParams
                                With x.params(x.params.Length - 1)
                                    .Name = xml.GetAttribute("name")
                                    .[Operator] = xml.GetAttribute("operator")
                                    .Value = xml.GetAttribute("value").ToLower.Trim
                                End With

                            Case "globalCondition"
                                ReDim Preserve newRule.Conditions(newRule.Conditions.Length)
                                newRule.Conditions(newRule.Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With newRule.Conditions(newRule.Conditions.Length - 1)
                                    .ConditionType = DeterminatorRule.ConditionTypes.globalCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                Dim x As New DeterminatorRule.DeterminatorCondition.globalCondition
                                x.Name = xml.GetAttribute("name").ToLower
                                x.[Operator] = xml.GetAttribute("operator")
                                x.Value = xml.GetAttribute("value")
                                newRule.Conditions(newRule.Conditions.Length - 1).Condition = x

                            Case "globalChanged"
                                ReDim Preserve newRule.Conditions(newRule.Conditions.Length)
                                newRule.Conditions(newRule.Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                newRule.Conditions(newRule.Conditions.Length - 1).ConditionType = DeterminatorRule.ConditionTypes.globalChanged
                                Dim x As New DeterminatorRule.DeterminatorCondition.globalChanged
                                x.ObjectName = xml.GetAttribute("name").ToLower
                                With newRule.Conditions(newRule.Conditions.Length - 1)
                                    .Condition = x
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With

                            Case "output"

                            Case "suspendAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.suspendAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.suspendAction
                                x.SuspendMinutes = CInt(xml.GetAttribute("suspend_minutes"))
                                x.suspendTime = xml.GetAttribute("suspend_time")
                                x.suspendRandomise = CInt(xml.GetAttribute("suspend_randomise"))
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "stopAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.stopAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If

                            Case "logAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.logAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.logAction
                                x.logText = xml.GetAttribute("logText")
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "xplAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.xplAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.xplAction
                                With x
                                    ReDim .params(-1)
                                    .msg_type = xml.GetAttribute("msg_type")
                                    .msg_target = xml.GetAttribute("msg_target")
                                    .msg_schema = xml.GetAttribute("msg_schema")
                                End With
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "xplActionParam"
                                Dim x As DeterminatorRule.DeterminatorAction.xplAction = CType(newRule.Actions(newRule.Actions.Length - 1).Action, DeterminatorRule.DeterminatorAction.xplAction)
                                ReDim Preserve x.params(x.params.Length)
                                x.params(x.params.Length - 1) = xml.GetAttribute("expression")

                            Case "globalAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.globalAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.globalAction
                                x.Name = xml.GetAttribute("name")
                                x.Value = xml.GetAttribute("value")
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "delayAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.delayAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.DelayAction
                                x.DelaySeconds = CDbl(xml.GetAttribute("delay_seconds"))
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "execRuleAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.execRuleAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                Dim x As New DeterminatorRule.DeterminatorAction.execRuleAction
                                x.RuleName = xml.GetAttribute("rule_name")
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "executeAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.executeAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.executeAction
                                x.Program = xml.GetAttribute("program")
                                x.Parameters = xml.GetAttribute("parameters")
                                x.Wait = CBool(xml.GetAttribute("wait"))
                                newRule.Actions(newRule.Actions.Length - 1).Action = x

                            Case "runScriptAction"
                                ReDim Preserve newRule.Actions(newRule.Actions.Length)
                                newRule.Actions(newRule.Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With newRule.Actions(newRule.Actions.Length - 1)
                                    .ActionType = DeterminatorRule.DeterminatorAction.ActionTypes.runScriptAction
                                    .DisplayName = xml.GetAttribute("display_name")
                                End With
                                If IsNumeric(xml.GetAttribute("executeOrder")) Then
                                    newRule.Actions(newRule.Actions.Length - 1).ExecuteOrder = CInt(xml.GetAttribute("executeOrder"))
                                End If
                                Dim x As New DeterminatorRule.DeterminatorAction.RunScriptAction
                                x.ScriptName = xml.GetAttribute("script_name")
                                x.Parameters = xml.GetAttribute("parameters")
                                newRule.Actions(newRule.Actions.Length - 1).Action = x
                        End Select
                End Select
            End While
            xml.Close()

            AddRule(newRule)
        Catch ex As Exception
            If newRule.RuleName Is Nothing Then
                Logger.AddLogEntry(AppError, "rules", "Error loading rule " & ruleGuid & ": " & ex.Message)
            Else
                Logger.AddLogEntry(AppError, "rules", "Error loading rule " & ruleGuid & ": " & ex.Message)
            End If
        End Try
    End Sub

    Public Shared Function DeleteRule(ByVal ruleGuid As String, ByVal deleteFromFileSystem As Boolean) As Boolean
        Dim newRules() As DeterminatorRule
        Dim IsGroup As Boolean = False
        Dim GroupName As String
        GroupName = ""
        ReDim newRules(-1)
        RulesMutex.WaitOne()
        DeleteRule = False
        For Counter As Integer = 0 To Rules.Length - 1
            If Rules(Counter).RuleGUID <> ruleGuid Then
                ReDim Preserve newRules(newRules.Length)
                newRules(newRules.Length - 1) = Rules(Counter)
            Else
                DeleteRule = True
                If Rules(Counter).IsGroup Then
                    IsGroup = True
                    GroupName = Rules(Counter).RuleName
                End If
            End If
        Next
        Rules = newRules

        ' If we're deleting a group, remove any references to that group
        If IsGroup Then
            For Counter As Integer = 0 To Rules.Length - 1
                If Rules(Counter).GroupName = GroupName Then
                    Rules(Counter).GroupName = ""
                    SaveRule(Rules(Counter).RuleGUID)
                End If
            Next
        End If
        RulesMutex.ReleaseMutex()
        ' Delete the file from disk
        If deleteFromFileSystem Then
            File.Delete(DataFileFolder & ruleGuid & ".xml")
        End If
    End Function

    Public Shared Sub AddRule(ByVal r As DeterminatorRule)
        RulesMutex.WaitOne()
        ReDim Preserve Rules(Rules.Length)
        Rules(Rules.Length - 1) = r
        RulesMutex.ReleaseMutex()

        Logger.AddLogEntry(AppInfo, "rules", "Loaded rule: " & r.RuleName)
    End Sub

    Public Shared Sub LoadRules()
        RulesMutex.WaitOne()
        'Try
        Dim files() As String = Directory.GetFiles(DataFileFolder)
        Dim f As String
        For Counter As Integer = 0 To files.Length - 1
            f = Path.GetFileName(files(Counter))
            LoadRule(f.Substring(0, f.Length - 4))
        Next
        'Catch ex As Exception
        'End Try
        RulesMutex.ReleaseMutex()
    End Sub

    Public Class DeterminatorProcessor
        Public Message As xpllib.XplMsg

        Public Sub Start()
            For Each entry As DeterminatorRule In Rules
                ProcessRule(entry)
            Next
        End Sub

        Private Sub ProcessRule(ByVal TargetRule As DeterminatorRule)

            Logger.AddLogEntry(AppInfo, "rules", "Evaluating rule: " & TargetRule.RuleName)
            If Not TargetRule.Enabled Then
                Logger.AddLogEntry(AppWarn, "rules", "Rule (" & TargetRule.RuleName & ") is disabled.")
                Exit Sub
            End If
            Dim res As Boolean, found As Boolean = False, Initiated As Boolean = False

            ' Loop through all conditions and evaluate them
            For Each entry In TargetRule.Conditions
                Logger.AddLogEntry(AppInfo, "rules", "Evaluating condition: " & entry.DisplayName)
                Select Case entry.ConditionType
                    Case DeterminatorRule.ConditionTypes.dayCondition
                        Dim x As DeterminatorRule.DeterminatorCondition.dayCondition = CType(entry.Condition, DeterminatorRule.DeterminatorCondition.dayCondition)
                        res = x.Evaluate()
                    Case DeterminatorRule.ConditionTypes.globalCondition
                        Dim x As DeterminatorRule.DeterminatorCondition.globalCondition = CType(entry.Condition, DeterminatorRule.DeterminatorCondition.globalCondition)
                        res = x.Evaluate()
                    Case DeterminatorRule.ConditionTypes.timeCondition
                        Dim x As DeterminatorRule.DeterminatorCondition.timeCondition = CType(entry.Condition, DeterminatorRule.DeterminatorCondition.timeCondition)
                        res = x.Evaluate()
                    Case DeterminatorRule.ConditionTypes.xPLMessage
                        Dim x As DeterminatorRule.DeterminatorCondition.xplCondition = CType(entry.Condition, DeterminatorRule.DeterminatorCondition.xplCondition)
                        res = x.Evaluate(Message)
                        If res And Not Initiated Then
                            Initiated = True
                        End If
                End Select
                If TargetRule.MatchAny = False And res = False Then
                    Exit Sub
                ElseIf res Then
                    found = True
                End If
            Next

            If found And Initiated Then
                Logger.AddLogEntry(AppInfo, "rules", "Executing rule: " & TargetRule.RuleName)
                ExecuteActions(TargetRule)
            End If
        End Sub

        Private Sub ExecuteActions(ByVal TargetRule As DeterminatorRule)
            For Each action In TargetRule.Actions
                If Not action.Execute(TargetRule.RuleName, Message) Then
                    Exit For
                End If
            Next
        End Sub

    End Class

End Class
