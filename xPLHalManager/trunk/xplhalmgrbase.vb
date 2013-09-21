Imports xPLHalMgr.xplhalMgrBase.DeterminatorRule.DeterminatorCondition.xplCondition

'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2007 John Bent & Ian Jeffery
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

Public Class xplhalMgrBase
    Inherits System.Windows.Forms.Form

    Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Integer, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Integer) As Integer

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

            Public Overrides Function ToString() As String
                Return DisplayName
            End Function

            Public Class dayCondition
                Public DOW As String
            End Class

            Public Class timeCondition
                Public Category As String
                Public Value As String
                Public [Operator] As String
            End Class

            Public Class x10Condition
                Public Device As String
                Public State As String
            End Class

            Public Class xplCondition
                Public msg_type As String
                Public source_vendor, source_device, source_instance As String
                Public target_vendor, target_device, target_instance As String
                Public schema_class, schema_type As String
                Public params As New Collection

                Public Class xplConditionParams
                    Public Name As String
                    Public [Operator] As String
                    Public Value As String
                End Class
            End Class

            Public Class globalCondition
                Public Name As String
                Public [Operator] As String
                Public Value As String
            End Class

            Public Class globalChanged
                Public globalName As String
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

            Public Overrides Function ToString() As String
                Return DisplayName
            End Function

            Public Class RunScriptAction
                Public ScriptName As String
                Public Parameters As String
            End Class

            Public Class DelayAction
                Public DelaySeconds As Double
            End Class

            Public Class stopAction
                ' No methods or properties are required
            End Class

            Public Class suspendAction
                Public SuspendMinutes As Integer
                Public SuspendTime As String
                Public SuspendRandomise As Integer
            End Class

            Public Class execRuleAction
                Public RuleName As String
            End Class

            Public Class executeAction
                Public Program As String
                Public Parameters As String
                Public Wait As Boolean
            End Class

            Public Class logAction
                Public logText As String
            End Class

            Public Class xplAction
                Public msg_type As String
                Public msg_target As String
                Public msg_schema As String
                Public params() As String

            End Class

            Public Class globalAction
                Public Name As String
                Public Value As String
            End Class

        End Class

        Public Enabled As Boolean
        Public IsGroup As Boolean
        Public RuleName As String
        Public GroupName As String
        Public RuleDescription As String
        Public MatchAny As Boolean
        Public Conditions() As DeterminatorCondition
        Public Actions() As DeterminatorAction

        Public Sub New()
            ReDim Actions(-1)
            ReDim Conditions(-1)
            MatchAny = False
            IsGroup = False
            RuleName = String.Empty
        End Sub

        Public Sub New(ByVal ruleText As String)
            Dim memStr As New MemoryStream(Encoding.UTF8.GetBytes(ruleText))
            Dim xml As New XmlTextReader(memStr)
            ReDim Actions(-1)
            ReDim Conditions(-1)
            MatchAny = False
            While xml.Read
                Select Case xml.NodeType
                    Case XmlNodeType.Element
                        Select Case xml.Name
                            Case "determinator"
                                RuleName = xml.GetAttribute("name")
                                RuleDescription = xml.GetAttribute("description")
                                GroupName = xml.GetAttribute("groupName")
                                If xml.GetAttribute("enabled") = "N" Then
                                    Enabled = False
                                Else
                                    Enabled = True
                                End If
                                If xml.GetAttribute("isGroup") = "Y" Then
                                    IsGroup = True
                                End If
                            Case "input"
                                If xml.GetAttribute("match") = "any" Then
                                    MatchAny = True
                                Else
                                    MatchAny = False
                                End If
                            Case "xplCondition"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.xPLMessage
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.xplCondition
                                    x.msg_type = xml.GetAttribute("msg_type")
                                    x.source_vendor = xml.GetAttribute("source_vendor")
                                    x.source_device = xml.GetAttribute("source_device")
                                    x.source_instance = xml.GetAttribute("source_instance")
                                    x.target_vendor = xml.GetAttribute("target_vendor")
                                    x.target_device = xml.GetAttribute("target_device")
                                    x.target_instance = xml.GetAttribute("target_instance")
                                    x.schema_class = xml.GetAttribute("schema_class")
                                    x.schema_type = xml.GetAttribute("schema_type")
                                    .Condition = x
                                End With
                            Case "param"
                                Dim x As DeterminatorCondition.xplCondition = CType(Conditions(Conditions.Length - 1).Condition, DeterminatorCondition.xplCondition)
                                Dim newparams As xplConditionParams = New xplConditionParams
                                With newparams
                                    .Name = xml.GetAttribute("name")
                                    .[Operator] = xml.GetAttribute("operator")
                                    .Value = xml.GetAttribute("value")
                                End With
                                x.params.Add(newparams)
                            Case "globalCondition"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.globalCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.globalCondition
                                    x.Name = xml.GetAttribute("name")
                                    x.[Operator] = xml.GetAttribute("operator")
                                    x.Value = xml.GetAttribute("value")
                                    .Condition = x
                                End With
                            Case "globalChanged"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.globalChanged
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.globalChanged
                                    x.globalName = xml.GetAttribute("name")
                                    .Condition = x
                                End With
                            Case "dayCondition"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.dayCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.dayCondition
                                    x.DOW = xml.GetAttribute("dow")
                                    .Condition = x
                                End With
                            Case "x10Condition"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.x10Condition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.x10Condition
                                    x.Device = xml.GetAttribute("device")
                                    x.State = xml.GetAttribute("state")
                                    .Condition = x
                                End With
                            Case "timeCondition"
                                ReDim Preserve Conditions(Conditions.Length)
                                Conditions(Conditions.Length - 1) = New DeterminatorRule.DeterminatorCondition
                                With Conditions(Conditions.Length - 1)
                                    .ConditionType = ConditionTypes.timeCondition
                                    .DisplayName = xml.GetAttribute("display_name")
                                    Dim x As New DeterminatorCondition.timeCondition
                                    x.[Operator] = xml.GetAttribute("operator")
                                    x.Value = xml.GetAttribute("value")
                                    x.Category = xml.GetAttribute("category")
                                    .Condition = x
                                End With
                            Case "output"
                            Case "stopAction"
                                ' The stopAction requires no additional info, so doesn't have an action object associated with it.
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                With Actions(Actions.Length - 1)
                                    .DisplayName = xml.GetAttribute("display_name")
                                    .ActionType = DeterminatorAction.ActionTypes.stopAction
                                End With
                            Case "suspendAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Dim x As New DeterminatorRule.DeterminatorAction.suspendAction
                                x.SuspendTime = xml.GetAttribute("suspend_time")
                                x.SuspendMinutes = CInt(xml.GetAttribute("suspend_minutes"))
                                x.SuspendRandomise = CInt(xml.GetAttribute("suspend_randomise"))
                                With Actions(Actions.Length - 1)
                                    .DisplayName = xml.GetAttribute("display_name")
                                    .Action = x
                                    .ActionType = DeterminatorAction.ActionTypes.suspendAction
                                End With
                            Case "logAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Dim x As New DeterminatorRule.DeterminatorAction.logAction
                                x.logText = xml.GetAttribute("logText")
                                With Actions(Actions.Length - 1)
                                    .DisplayName = xml.GetAttribute("display_name")
                                    .Action = x
                                    .ActionType = DeterminatorAction.ActionTypes.logAction
                                End With
                            Case "xplAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Dim x As New DeterminatorRule.DeterminatorAction.xplAction
                                x.msg_type = xml.GetAttribute("msg_type")
                                x.msg_target = xml.GetAttribute("msg_target")
                                x.msg_schema = xml.GetAttribute("msg_schema")
                                ReDim x.params(-1)
                                With Actions(Actions.Length - 1)
                                    .DisplayName = xml.GetAttribute("display_name")
                                    .Action = x
                                    .ActionType = DeterminatorAction.ActionTypes.xplAction
                                End With
                            Case "xplActionParam"
                                Dim x As DeterminatorRule.DeterminatorAction.xplAction = CType(Actions(Actions.Length - 1).Action, DeterminatorRule.DeterminatorAction.xplAction)
                                ReDim Preserve x.params(x.params.Length)
                                x.params(x.params.Length - 1) = xml.GetAttribute("expression")
                            Case "globalAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Actions(Actions.Length - 1).ActionType = DeterminatorAction.ActionTypes.globalAction
                                Actions(Actions.Length - 1).DisplayName = xml.GetAttribute("display_name")
                                Dim x As New DeterminatorRule.DeterminatorAction.globalAction
                                x.Name = xml.GetAttribute("name")
                                x.Value = xml.GetAttribute("value")
                                Actions(Actions.Length - 1).Action = x
                            Case "delayAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Actions(Actions.Length - 1).DisplayName = xml.GetAttribute("display_name")
                                Actions(Actions.Length - 1).ActionType = DeterminatorAction.ActionTypes.delayAction
                                Dim x As New DeterminatorRule.DeterminatorAction.DelayAction
                                x.DelaySeconds = CDbl(xml.GetAttribute("delay_seconds"))
                                Actions(Actions.Length - 1).Action = x
                            Case "execRuleAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Actions(Actions.Length - 1).DisplayName = xml.GetAttribute("display_name")
                                Actions(Actions.Length - 1).ActionType = DeterminatorAction.ActionTypes.execRuleAction
                                Dim x As New DeterminatorRule.DeterminatorAction.execRuleAction
                                x.RuleName = xml.GetAttribute("rule_name")
                                Actions(Actions.Length - 1).Action = x
                            Case "executeAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Actions(Actions.Length - 1).DisplayName = xml.GetAttribute("display_name")
                                Actions(Actions.Length - 1).ActionType = DeterminatorAction.ActionTypes.executeAction
                                Dim x As New DeterminatorRule.DeterminatorAction.executeAction
                                x.Program = xml.GetAttribute("program")
                                x.Parameters = xml.GetAttribute("parameters")
                                x.Wait = CBool(xml.GetAttribute("wait"))
                                Actions(Actions.Length - 1).Action = x
                            Case "runScriptAction"
                                ReDim Preserve Actions(Actions.Length)
                                Actions(Actions.Length - 1) = New DeterminatorRule.DeterminatorAction
                                Actions(Actions.Length - 1).DisplayName = xml.GetAttribute("display_name")
                                Actions(Actions.Length - 1).ActionType = DeterminatorAction.ActionTypes.runScriptAction
                                Dim x As New DeterminatorRule.DeterminatorAction.RunScriptAction
                                x.ScriptName = xml.GetAttribute("script_name")
                                x.Parameters = xml.GetAttribute("parameters")
                                Actions(Actions.Length - 1).Action = x
                        End Select
                End Select
            End While
            xml.Close()
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
                        For Each entry As xplConditionParams In x.params
                            xmlw.WriteStartElement("param")
                            xmlw.WriteAttributeString("name", entry.Name)
                            xmlw.WriteAttributeString("operator", entry.[Operator])
                            xmlw.WriteAttributeString("value", entry.Value)
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
                        xmlw.WriteAttributeString("name", x.globalName)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.dayCondition
                        Dim x As DeterminatorCondition.dayCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.dayCondition)
                        xmlw.WriteStartElement("dayCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("dow", x.DOW)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.x10Condition
                        Dim x As DeterminatorCondition.x10Condition = CType(Conditions(Counter).Condition, DeterminatorCondition.x10Condition)
                        xmlw.WriteStartElement("x10Condition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("device", x.Device)
                        xmlw.WriteAttributeString("state", x.State.ToLower)
                        xmlw.WriteEndElement()
                    Case ConditionTypes.timeCondition
                        Dim x As DeterminatorCondition.timeCondition = CType(Conditions(Counter).Condition, DeterminatorCondition.timeCondition)
                        xmlw.WriteStartElement("timeCondition")
                        xmlw.WriteAttributeString("display_name", Conditions(Counter).DisplayName)
                        xmlw.WriteAttributeString("category", x.Category)
                        xmlw.WriteAttributeString("operator", x.[Operator])
                        xmlw.WriteAttributeString("value", x.Value)
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
                        xmlw.WriteAttributeString("suspend_time", x.SuspendTime)
                        xmlw.WriteAttributeString("suspend_randomise", x.SuspendRandomise.ToString)
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

    Public Class FunctionItem
        Public pName As String
        Public CodeText As String

        Public Overrides Function ToString() As String
            Return pName
        End Function
    End Class

    Protected Structure ConfigItem
        Dim cName As String
        Dim confType As String
        Dim cValues() As String
    End Structure

    Protected Structure EventInfo
        Dim IsRecurring As Boolean
        Dim evTag As String
        Dim evSubName As String
        Dim evParams As String
        Dim evDOW As String
        Dim evDate As Date
        Dim evStartTime, evEndTime As Date
        Dim evInterval, evRandom As Integer
    End Structure

    Protected s As Socket
    Protected WelcomeBanner As String


    Protected Function ConnectToXplHal() As Boolean
        If Not s Is Nothing Then Return True
        Try
            s = New Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
            Dim IPResults() As IPAddress = Dns.GetHostEntry(globals.xPLHalServer).AddressList
            For Each IPresult As IPAddress In IPResults
                If IPresult.AddressFamily = AddressFamily.InterNetwork Then
                    s.Connect(New IPEndPoint(IPresult, 3865))
                    WelcomeBanner = GetLine()
                    WelcomeBanner = WelcomeBanner.Replace(vbCrLf, "")
                    globals.XplHalSource = WelcomeBanner.Substring(4, WelcomeBanner.Length - 4)
                    globals.XplHalSource = globals.XplHalSource.Substring(0, globals.XplHalSource.IndexOf(" "))
                    Return True
                End If
            Next
            WelcomeBanner = ""
            Return False
        Catch ex As Exception
            s = Nothing
            WelcomeBanner = ""
            Return False
        End Try
    End Function

    Protected Function GetLine() As String
        Dim buff(255) As Byte
        Dim bytes_read As Integer
        Dim inbuff As String = ""

        Do
            Try
                bytes_read = s.Receive(buff, SocketFlags.Peek)
                If bytes_read > 0 Then
                    If InStr(Encoding.ASCII.GetString(buff), vbCrLf) > 0 Then
                        bytes_read = s.Receive(buff, CInt(InStr(Encoding.ASCII.GetString(buff), vbCrLf) + 1), SocketFlags.None)
                    Else
                        bytes_read = s.Receive(buff, bytes_read, SocketFlags.None)
                    End If
                    inbuff = inbuff & Encoding.ASCII.GetString(buff).Substring(0, bytes_read)
                Else
                    inbuff = inbuff & vbCrLf
                End If
            Catch ex As Exception
                inbuff = vbCrLf
            End Try
        Loop Until inbuff.IndexOf(vbCrLf) >= 0
        Return (inbuff)
    End Function

    Protected Sub Disconnect()
        If Not s Is Nothing Then
            Try
                s.Send(Encoding.ASCII.GetBytes("quit" & vbCrLf))
                s.Shutdown(Net.Sockets.SocketShutdown.Both)
                s.Close()
            Catch ex As Exception
            End Try
            s = Nothing
        End If
    End Sub

    Protected Sub xplHalSend(ByVal str As String)
        Dim retry As Integer = 5

        Try
            s.Send(Encoding.ASCII.GetBytes(str))
        Catch ex As Exception
            ConnectToXplHal()
            Try
                s.Send(Encoding.ASCII.GetBytes(str))
            Catch innerex As Exception
                'try to reconnect 5 times...
                retry -= 1
                If retry > 0 Then
                    s = Nothing
                    ConnectToXplHal()

                    'retransmit the same data
                    xplHalSend(str)
                Else
                    MsgBox("Error sending data to the xPLHal server." & vbCrLf & vbCrLf & "Please make sure the server is operational and that you have a working network connection to the server.", vbCritical, "xPLHal Manager")
                End If
            End Try
        End Try
    End Sub

    Protected Function GetX10Status(ByVal status As Integer) As String
        Select Case status
            Case 2
                Return "ON"
            Case 3
                Return "OFF"
            Case Else
                Return ("Unknown")
        End Select
    End Function

    Protected Sub SendX10(ByVal dev As String, ByVal func As String)
        Dim str As String
        ConnectToXplHal()
        xplHalSend("SENDXPLMSG" & vbCrLf)
        str = GetLine()
        If str.StartsWith("313") Then
            str = "xpl-cmnd" & vbCrLf & "{" & vbCrLf & "hop=1" & vbCrLf & "source=" & globals.XplHalSource & vbCrLf & "target=*" & vbCrLf & "}" & vbCrLf
            str &= "x10.basic" & vbCrLf & "{" & vbCrLf & "command=" & func & vbCrLf & "device=" & dev & vbCrLf & "}" & vbCrLf
            xplHalSend(str & "." & vbCrLf)
            'MsgBox(str)

            str = GetLine()
            If Not str.StartsWith("213") Then
                globals.Unexpected(str)
            End If
        Else
            globals.Unexpected(str)
        End If
    End Sub

    Protected Function GetConfigXML() As String
        Dim str As String
        GetConfigXML = ""
        ConnectToXplHal()
        xplHalSend("GETCONFIGXML" & vbCrLf)
        str = GetLine()
        If str.StartsWith("209") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                GetConfigXML &= str
                str = GetLine()
            End While
        Else
            globals.Unexpected(str)
        End If
        Disconnect()
    End Function

    Protected Function CreateEvent(ByVal ev As EventInfo) As Boolean
        Dim str As String
        ConnectToXplHal()
        Select Case ev.IsRecurring
            Case True
                xplHalSend("ADDEVENT" & vbCrLf)
                str = GetLine()
                If str.StartsWith("319") Then
                    xplHalSend("tag=" & ev.evTag & vbCrLf)
                    xplHalSend("subname=" & ev.evSubName & vbCrLf)
                    xplHalSend("params=" & ev.evParams & vbCrLf)
                    xplHalSend("starttime=" & ev.evStartTime.ToString("HH:mm:ss") & vbCrLf)
                    xplHalSend("endtime=" & ev.evEndTime.ToString("HH:mm:ss") & vbCrLf)
                    xplHalSend("interval=" & ev.evInterval.ToString & vbCrLf)
                    xplHalSend("rand=" & ev.evRandom.ToString & vbCrLf)
                    xplHalSend("dow=" & ev.evDOW & vbCrLf)
                Else
                    globals.Unexpected(str)
                    Return False
                End If
            Case Else
                xplHalSend("ADDEVENT" & vbCrLf)
                str = GetLine()
                If str.StartsWith("319") Then
                    xplHalSend("tag=" & ev.evTag & vbCrLf)
                    xplHalSend("subname=" & ev.evSubName & vbCrLf)
                    xplHalSend("params=" & ev.evParams & vbCrLf)
                    xplHalSend("rand=" & ev.evRandom.ToString & vbCrLf)
                    xplHalSend("date=" & ev.evDate.ToString("dd/MMM/yyyy HH:mm") & ":00" & vbCrLf)
                Else
                    globals.Unexpected(str)
                    Return False
                End If
        End Select
        xplHalSend("." & vbCrLf)
        str = GetLine()
        If str.StartsWith("219") Then
            Return True
        Else
            globals.Unexpected(str)
            Return False
        End If
    End Function

    Protected Sub PopulateTargets(ByRef cmbTarget As ComboBox)
        Dim str As String
        cmbTarget.Items.Clear()
        ConnectToXplHal()
        xplHalSend("LISTDEVICES CONFIGURED" & vbCrLf)
        str = GetLine()
        If str.StartsWith("216") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                str = str.Substring(0, str.IndexOf(vbTab))
                cmbTarget.Items.Add(str)
                str = GetLine()
            End While
        Else
            globals.Unexpected(str)
        End If
    End Sub


    Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(xplhalMgrBase))
        '
        'xplhalMgrBase
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(492, 513)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "xplhalMgrBase"

    End Sub

    Protected Sub PopulateOptions(ByRef c() As globals.ConstructValue, ByVal ConstructName As String)
        Dim str As String, tempstr As String
        Dim Counter As Integer = 0
        ConnectToXplHal()
        xplHalSend("LISTOPTIONS " & ConstructName & vbCrLf)
        str = GetLine()
        If str.StartsWith("205") Then
            str = GetLine()
            While str <> ("." & vbCrLf) And str <> ""
                str = str.Replace(vbCrLf, "")
                tempstr = str.Substring(0, str.IndexOf(vbTab))
                str = str.Substring(str.IndexOf(vbTab) + 1, str.Length - str.IndexOf(vbTab) - 1)
                ReDim Preserve c(c.Length)
                c(c.Length - 1) = New globals.ConstructValue
                c(c.Length - 1).Index = Counter
                c(c.Length - 1).Name = tempstr
                c(c.Length - 1).Description = str
                str = GetLine()
                Counter += 1
            End While
        Else
            ReDim c(-1)
        End If
    End Sub

    Protected Sub SendXplMsg(ByVal t As String, ByVal target As String, ByVal schema As String, ByVal body As String)
        Dim str As String
        str = t & vbCrLf & "{" & vbCrLf & "hop=1" & vbCrLf & "source=" & globals.XplHalSource & vbCrLf & "target=" & target & vbCrLf & "}" & vbCrLf
        str &= schema & vbCrLf & "{" & vbCrLf & body & vbCrLf & "}" & vbCrLf & "." & vbCrLf
        ConnectToXplHal()
        xplHalSend("SENDXPLMSG" & vbCrLf)
        GetLine()
        xplHalSend(str)
        str = GetLine()
        If Not str.StartsWith("213") Then
            globals.Unexpected(str)
        End If
    End Sub

    Protected Sub SendXplMsg(ByVal t As String, ByVal target As String, ByVal body As String)
        Dim str As String
        str = t & vbCrLf & "{" & vbCrLf & "hop=1" & vbCrLf & "source=" & globals.XplHalSource & vbCrLf & "target=" & target & vbCrLf & "}" & vbCrLf
        str &= body & vbCrLf & "." & vbCrLf
        ConnectToXplHal()
        xplHalSend("SENDXPLMSG" & vbCrLf)
        GetLine()
        xplHalSend(str)
        str = GetLine()
        If Not str.StartsWith("213") Then
            globals.Unexpected(str)
        End If
    End Sub



    Protected Sub SaveXML(ByVal xmltext As String)
        Dim str As String
        ConnectToXplHal()
        xplHalSend("PUTCONFIGXML" & vbCrLf)
        str = GetLine()
        If Not str.StartsWith("315") Then
            MsgBox("Your updated xPLHal configuration could not be saved." & vbCrLf & vbCrLf & "The xPLHal server returned the following:" & vbCrLf & str, vbExclamation)
            Exit Sub
        End If
        xplHalSend(xmltext.Trim & vbCrLf)
        xplHalSend("." & vbCrLf)
        str = GetLine()
        If Not str.StartsWith("215") Then
            Unexpected(str)
        End If
    End Sub

    Protected Sub VersionCheck()
        Dim i As Integer = WelcomeBanner.IndexOf("Version ")
        If i = -1 Then Exit Sub
        Dim serverMajor, serverMinor, serverBuild As Integer
        Dim str As String = WelcomeBanner.Substring(i + 8, WelcomeBanner.Length - i - 9)
        Dim strs() As String = str.Split(CChar("."))
        If Not strs.Length >= 4 Then Exit Sub

        serverMajor = CInt(strs(0))
        serverMinor = CInt(strs(1))
        serverBuild = CInt(strs(2))
        Dim OutOfDate As Boolean = False
        If serverMajor < globals.MinMajor Or (serverMajor = globals.MinMajor And serverMinor < globals.MinMinor) Then
            OutOfDate = True
        ElseIf serverMajor = globals.MinMajor And serverMinor = globals.MinMinor And serverBuild < globals.MinBuild Then
            OutOfDate = True
        End If

        globals.ServerMajorVersion = serverMajor

        If OutOfDate Then
            globals.ServerOutOfDate = True
        Else
            globals.ServerOutOfDate = False
        End If
    End Sub

    Protected Sub ReloadScripts()
        Dim str As String
        Windows.Forms.Cursor.Current = Cursors.WaitCursor
        ConnectToXplHal()
        xplHalSend("RELOAD" & vbCrLf)
        str = GetLine()
        Windows.Forms.Cursor.Current = Cursors.Default
        If str.StartsWith("201") Then
            MsgBox(My.Resources.RES_SCRIPTS_RELOADED, vbInformation, My.Resources.RES_TITLE)
        ElseIf str.StartsWith("401") Then
            If MsgBox(My.Resources.RES_SCRIPTS_RELOADED_ERROR, vbYesNo Or vbQuestion, My.Resources.RES_TITLE) = MsgBoxResult.Yes Then
                Dim f As New frmErrorLog
                f.Show()
            End If
        Else
            globals.Unexpected(str)
        End If
        globals.NeedToReloadScripts = False
    End Sub

    Protected Sub PopulateXplDevices(ByVal c As ComboBox)
        Dim str As String, devName As String
        c.Items.Clear()
        xplHalSend("LISTDEVICES CONFIGURED" & vbCrLf)
        str = GetLine()
        If str.StartsWith("216") Then
            str = GetLine()
            While Not str = "." & vbCrLf
                devName = str.Substring(0, str.IndexOf(vbTab))
                c.Items.Add(devName)
                str = GetLine()
            End While
        End If
    End Sub

    Protected Sub PopulateGlobals(ByVal c As ComboBox)
        Dim bNeedToDisconnect As Boolean
        c.Items.Clear()
        If s Is Nothing Then
            ConnectToXplHal()
            bNeedToDisconnect = True
        End If
        Dim str As String, GlobalName As String
        xplHalSend("LISTGLOBALS" & vbCrLf)
        str = GetLine()
        If str.StartsWith("231") Then
            str = GetLine()
            While Not str = "." & vbCrLf
                GlobalName = str.Substring(0, str.IndexOf("="))
                c.Items.Add(GlobalName)
                str = GetLine()
            End While
        End If
        If bNeedToDisconnect Then
            Disconnect()
        End If
    End Sub

    Protected Sub PopulateSubs(ByVal c As ComboBox)
        Dim bNeedToDisconnect As Boolean
        If s Is Nothing Then
            ConnectToXplHal()
            bNeedToDisconnect = True
        End If
        Dim str As String, GlobalName As String
        xplHalSend("LISTSUBS" & vbCrLf)
        str = GetLine()
        If str.StartsWith("224") Then
            str = GetLine()
            While Not str = "." & vbCrLf
                GlobalName = str.Replace(vbCrLf, "")
                c.Items.Add(GlobalName)
                str = GetLine()
            End While
        End If
        If bNeedToDisconnect Then
            Disconnect()
        End If
    End Sub

    Protected Sub PopulateDeterminators(ByVal c As ComboBox)
        Dim bits() As String
        Dim bNeedToDisconnect As Boolean
        c.Items.Clear()
        If s Is Nothing Then
            ConnectToXplHal()
            bNeedToDisconnect = True
        End If
        Dim str As String, GlobalName As String
        xplHalSend("LISTRULES {ALL}" & vbCrLf)
        str = GetLine()
        If str.StartsWith("237") Then
            str = GetLine()
            While Not str = "." & vbCrLf
                bits = str.Split(CChar(vbTab))
                GlobalName = bits(1).Replace(vbCrLf, "")
                c.Items.Add(GlobalName)
                str = GetLine()
            End While
        End If
        If bNeedToDisconnect Then
            Disconnect()
        End If
    End Sub

    Public Sub GetCapabilities()
        Dim str As String, DefaultScriptingChar As String
        DefaultScriptingChar = ""
        xplHalSend("CAPABILITIES SCRIPTING" & vbCrLf)
        str = GetLine()
        If str.StartsWith("236") Or str.StartsWith("241") Then
            globals.Capabilities = str.Substring(4, str.Length - 4)
            If globals.Capabilities.Length > 3 Then
                DefaultScriptingChar = globals.Capabilities.Substring(2, 1)
            End If
        Else
            globals.Capabilities = String.Empty
        End If

        ' Do we have scripting information?
        If str.StartsWith("241") Then
            ' Read supported script languages
            str = GetLine()
            Dim Bits() As String
            Dim TheEngines As New ArrayList
            Dim TheEngine As globals.ScriptingEngine
            While (str <> "." And str <> ("." & vbCrLf))
                Bits = str.Split(CChar(vbTab))
                If Bits.Length >= 5 Then
                    TheEngine = New globals.ScriptingEngine
                    With TheEngine
                        .Code = Bits(0)
                        .Name = Bits(1)
                        .Version = Bits(2)
                        .Extension = Bits(3)
                        .Url = Bits(4)
                        If .Code = DefaultScriptingChar Then
                            globals.DefaultScriptingEngine = TheEngine
                        End If
                    End With
                    TheEngines.Add(TheEngine)
                End If
                str = GetLine()
            End While
            globals.ScriptingEngines = CType(TheEngines.ToArray(GetType(globals.ScriptingEngine)), globals.ScriptingEngine())
        End If
    End Sub

    Protected Function SetRule(ByVal myRuleGuid As String, ByVal ruletext As String) As String
        ' This routine adds or updates a determinator on the xPLHal server
        ConnectToXplHal()
        Dim str As String
        xplHalSend("SETRULE")
        If myRuleGuid <> "" Then
            xplHalSend(" " & myRuleGuid)
        End If
        xplHalSend(vbCrLf)
        str = GetLine()
        If str.StartsWith("338") Then
            xplHalSend(ruletext & vbCrLf & "." & vbCrLf)
            str = GetLine()
            If Not str.StartsWith("238") Then
                globals.Unexpected(str)
            End If
        End If
        Return str
    End Function

    Protected Sub PopulateComparisonCombo(ByRef c As ComboBox)
        With c
            .Sorted = False
            .DropDownStyle = ComboBoxStyle.DropDownList
            .Items.Add("Equal To")
            .Items.Add("Not Equal To")
            .Items.Add("Less Than")
            .Items.Add("Greater Than")
        End With
    End Sub


    Protected Function DeterminatorExists(ByVal determinatorName As String) As Boolean
        determinatorName = determinatorName.ToLower.Trim()
        ConnectToXplHal()
        xplHalSend("LISTRULES {ALL}" & vbCrLf)
        Dim str As String = GetLine()
        If Not str.StartsWith("237") Then
            globals.Unexpected(str)
            Return True
        End If
        Dim Found As Boolean = False
        str = GetLine()
        While (str <> "." And str <> ("." & vbCrLf))
            Dim Bits() As String = str.Split(CChar(vbTab))
            If Bits(1).ToLower.Trim() = determinatorName Then
                Found = True
            End If
            str = GetLine()
        End While
        Return Found
    End Function

End Class
