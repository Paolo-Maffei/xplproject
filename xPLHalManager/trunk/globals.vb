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
Option Strict On

Public Class globals

    Public Class xplSchema
        Public Name As String
    End Class

    Public Class ScriptingEngine
        Public Code As String
        Public Name As String
        Public Version As String
        Public Extension As String
        Public Url As String
    End Class

    Public Shared Capabilities As String
    Public Shared xplSchemaCollection() As xplSchema
    Public Shared ScriptingEngines() As ScriptingEngine
    Public Shared DefaultScriptingEngine As ScriptingEngine

    Public Enum SubWizardMode
        'Initiator
        Condition
        Action
    End Enum
    Public Enum DeterminatorActionType
        Send
        SetGlobal
        RunEXE
        Pause
        ExecuteRule
        ExecuteScript
        IncrementGlobal
        DecrementGlobal
        AddToLog
    End Enum

    Public Class Plugin
        Public DeviceID As String
        Public InfoUrl As String
        Public ConfigItems() As pluginConfigItem
        Public Functions() As pluginFunction
        Public MenuItems() As pluginMenuItem
        Public Commands() As Trigger
        Public Triggers() As Trigger


        Public Class Trigger
            Public Name As String
            Public Description As String
            Public msg_type As String
            Public msg_schema As String
            Public elements() As TriggerElement

            Public Sub New()
                ReDim elements(-1)
            End Sub
        End Class

        Public Class TriggerElement
            Public Name As String
            Public Label As String
            Public ControlType As String
            Public MaxVal, MinVal As String
            Public DefaultValue As String
            Public ConditionalVisibility As String
            Public Choices() As TriggerChoice
            Public RegExp As String

            Public Sub New()
                ReDim Choices(-1)
            End Sub

        End Class

        Public Class TriggerChoice
            Public Label As String
            Public Value As String
        End Class

        Public Class pluginConfigItem
            Public Name As String
            Public FormatRegEx As String
            Public Description As String
        End Class

        Public Class pluginMenuItem
            Public mi As MenuItem
            Public xplMsg As String

            Public Sub New(ByVal menuItemName As String)
                mi = New MenuItem
                mi.Text = menuItemName
            End Sub
        End Class

        Public Class pluginFunction
            Public fName As String
            Public Item1Text As String, Item2Text As String, Item3Text As String, Item4Text As String
            Public Item1Type As String, Item2Type As String, item3type As String, item4type As String
            Public Item1DS As String, Item2DS As String, item3ds As String, item4ds As String
            Public Item1Val As String, Item2Val As String, Item3Val As String, item4val As String
            Public DisplayText As String
            Public CodeText As String

            Public ReadOnly Property DisplayMember() As String
                Get
                    Return fName
                End Get
            End Property
        End Class

        Public Sub New()
            ReDim ConfigItems(-1)
            ReDim Functions(-1)
            ReDim MenuItems(-1)
            ReDim Commands(-1)
            ReDim Triggers(-1)
        End Sub
    End Class

    Public Class ConstructValue
        Public Index As Integer
        Public Name As String
        Public Description As String
        Public Overrides Function ToString() As String
            Return Name & "[" & Description & "]"
        End Function

    End Class

    Public Shared Periods() As ConstructValue
    Public Shared Modes() As ConstructValue

    Public Shared xPLHalServer As String
    Public Shared EnableAutoUpdate As Boolean
    Public Shared AutoUpdateMode As String
    Public Shared AutoUpdateInterval As String
    Public Shared LastAutoUpdate As Date
    Public Shared AutoUpdateResult As String

    Public Shared XplHalSource As String
    Public Shared NeedToReloadScripts As Boolean
    Public Shared Plugins() As Plugin

    ' Path to the plug-ins directory
    Public Shared PluginsPath As String

    ' Minimum version of xPLHal Server
    Public Const MinMajor As Integer = 1
    Public Const MinMinor As Integer = 52
    Public Const MinBuild As Integer = 0
    Public Const MinRevision As Integer = 0
    Public Shared ServerMajorVersion As Integer
    Public Shared ServerOutOfDate As Boolean
    Public Shared LastRunSub As String
    Public Shared LastRunSubParam As String
    Private Shared ServerCaps As String


    Public Shared Sub Unexpected(ByVal str As String)
        MsgBox("The xPLHal server returned an unexpected response." & vbCrLf & vbCrLf & "Please ensure that you are using the latest version of both the xPLHal server and the xPLHal Manager." & vbCrLf & vbCrLf & "The following response data was returned by the server:" & vbCrLf & str, vbCritical, "xPLHal Manager")
    End Sub

    Public Shared Sub SaveSettings()
        Dim fs As TextWriter = File.CreateText("xplhalmgr.ini")
        fs.WriteLine("[General]")
        fs.WriteLine("server=" & globals.xPLHalServer)
        fs.WriteLine("language=" & Threading.Thread.CurrentThread.CurrentUICulture.ToString)
        fs.WriteLine()
        fs.WriteLine("[AutoUpdate]")
        fs.WriteLine("EnableAutoUpdate=" & EnableAutoUpdate.ToString)
        fs.WriteLine("AutoUpdateMode=" & AutoUpdateMode)
        fs.WriteLine("AutoUpdateInterval=" & AutoUpdateInterval)
        fs.WriteLine("LastAutoUpdate=" & LastAutoUpdate.ToString("dd/MMM/yyyy"))
        fs.WriteLine("AutoUpdateResult=" & AutoUpdateResult)
        fs.Close()
    End Sub

    Public Shared Function DownloadPlugin(ByVal url As String, ByVal bMustExist As Boolean) As Integer
        Try
            If bMustExist Then
                If Not File.Exists(PluginsPath & "\" & Path.GetFileName(url)) Then
                    Return 0
                End If
            End If
            Dim http As HttpWebRequest, Response As HttpWebResponse
            Dim s As Stream
            http = CType(HttpWebRequest.Create(url), HttpWebRequest)
            Response = CType(http.GetResponse, HttpWebResponse)
            s = Response.GetResponseStream
            If CInt(Response.ContentLength) > 1 Then
                Dim buff(CInt(Response.ContentLength) - 1) As Byte
                Dim bytes_read As Integer = 0
                While bytes_read < buff.Length
                    bytes_read += s.Read(buff, bytes_read, buff.Length - bytes_read)
                End While
                s.Close()
                url = PluginsPath & "\" & Path.GetFileName(url)
                Dim fs As FileStream = File.Create(url, FileMode.Create)
                fs.Write(buff, 0, buff.Length)
                fs.Close()
            End If
        Catch ex As Exception
            MsgBox("xPLHal Manager was unable to download the plug-in " & url & ".", vbExclamation)
            Return 0
        End Try
        Return 1
    End Function
    Public Enum ComboOperators
        Equal = 0
        NotEqual = 1
        LessThan = 2
        GreaterThan = 3
    End Enum
    Public Function MakeComboOperator(ByRef C As ComboBox) As ComboBox
        C.DropDownStyle = ComboBoxStyle.DropDownList
        C.Width = 50
        C.Sorted = False
        C.Items.Add("=")
        C.Items.Add("<>")
        C.Items.Add("<")
        C.Items.Add(">")
        C.SelectedIndex = 0
        Return C
    End Function
End Class
