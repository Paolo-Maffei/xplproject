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
Option Strict On

Module xPLHalUtil

    ' schema filter structure
    Public Structure xPLSchemaStruc
        Public Type As String
        Public Vendor As String
        Public Device As String
        Public Instance As String
        Public SchemaClass As String
        Public SchemaType As String
        Public SubDef As String
        Public IsX10 As Boolean
        Public ActionContinue As Boolean
    End Structure

    ' component structure
    Public Structure xPLHalStruc
        Public SubID As String ' sub id e.g. P for periods
        Public Name As String ' system sub name or user-defined sub type
        Public Desc As String ' meaningful description
        Public Values() As xPLTypesStruc ' allowed values for user defined
    Public ValuesCount As Integer ' number of values -1 is none
        Public Value As Short ' current value of user defined
        Public Init As Boolean ' has been initialised
    End Structure

    ' xplhal types structure
    Public Structure xPLTypesStruc
        Public Name As String
        Public Desc As String
    End Structure

    ' xplhal device structure
    Public Structure xPLDeviceStruc
        Public VDI As String ' vendor / device / instance = unique id
        Public Expires As Date ' time expires 
        Public Interval As Integer ' current heartbeat interval
        Public ConfigType As Boolean ' true = config. false = hbeat.
        Public ConfigDone As Boolean ' false = new waiting check, true = sent/not required
        Public WaitingConfig As Boolean ' false = waiting check or not needed, true = manual intervention
        Public ConfigSource As String ' v-d.xml / v-d.cache.xml or empty
        Public ConfigMissing As Boolean ' true = no config file, no response from device, false = have/waiting config
        Public Suspended As Boolean ' lost heartbeat
        Public Current As Boolean ' asked for current
    End Structure

    ' xplhal device for determinator structure
    Public Structure xPLDevStruc
        Public VDI As String
        Public Expires As Date
        Public Suspended As Boolean
    End Structure

    ' xplhal parameters
    Public xPLHals() As xPLHalStruc
  Public xPLHalCount As Integer
    Public xPLHalsHash As New Hashtable

    ' schema filters
    Public xPLSchemas() As xPLSchemaStruc
  Public xPLSchemaCount As Integer

    ' xplhal
    Public xPLHalSource As String

    ' globals
    Public xPLGlobals As New xPLHalGlobals
    Public xPLEvents As New xPLHalEvents

    ' xplhal paths
    Public xPLHalData As String
    Public xPLHalScripts As String
    Public xPLHalVendorFiles As String
    Public xPLHalConfigFiles As String

    ' xpl devices
    Public xPLDevices() As xPLDeviceStruc
    Public xPLDeviceCount As Integer
    Public xPLDevice As New Hashtable

    ' xpl determinator devices
    Public xPLDevs() As xPLDevStruc
    Public xPLDevCount As Integer
  Public xPLDev As New Hashtable

    ' xpl config manager
    Public xPLConfigDisabled As Boolean

    ' xpl smtp mail
    Public xPLSMTPDisabled As Boolean

    ' xpl master/slave
    Public xPLHalMaster As String
    Public xPLHalIsActive As Boolean

    ' xpl auto script creation
    Public xPLAutoScripts As Boolean

    ' xpl determinator
    Public Determinator As xplDeterminator
    Public xPLHalBooting As Boolean

    ' xpl groups
  Public xPLHalGroups As New Hashtable

  ' Statistics
  Public TotalMessagesRx As Integer


    ' routine to load schema filters, settings and constructs
    Public Sub LoadSettings(ByVal IsReload As Boolean)
    Dim x As Integer
        Dim ConstructName As String
        ConstructName = ""
    
    Dim XplhalSettings As TextWriter = File.CreateText(xPLHalScripts & "\Headers\xPLHal_Settings.xpl")
    XplhalSettings.WriteLine("' Note: This file has been automatically created by xPLHal.")
    XplhalSettings.WriteLine("' Do not modify it, as your changes will be lost the next time xPLHal reloads your scripts.")

        xPLSchemaCount = 0
        ReDim xPLSchemas(0)
        xPLHalsHash.Clear()
        xPLHalCount = 0
        ReDim xPLHals(0)
    xPLHalIsActive = True
    If File.Exists(xPLHalData + "\xplhal.xml") Then
      Dim xml As New XmlTextReader(xPLHalData + "\xplhal.xml")
      While xml.Read()
        Select Case xml.NodeType
          Case XmlNodeType.Element
            Select Case xml.Name
              Case "control"
                If IsReload = False Then
                  'xPLHubActive = False
                  Try
                    If xml.GetAttribute("loadhub").ToUpper = "Y" Then
                      'xPLHubActive = True
                    End If
                  Catch ex As Exception
                  End Try
                  xAPSupport = False
                  Try
                    If xml.GetAttribute("xapsupport").ToUpper = "Y" Then
                      xAPSupport = True
                    End If
                  Catch ex As Exception
                  End Try
                  xPLMatchAll = False
                  Try
                    If xml.GetAttribute("matchall").ToUpper = "Y" Then
                      xPLMatchAll = True
                    End If
                  Catch ex As Exception
                  End Try
                End If
              Case "autoscripts"
                xPLAutoScripts = True
                Try
                  If xml.GetAttribute("create").ToUpper = "N" Then
                    xPLAutoScripts = False
                  End If
                Catch ex As Exception
                End Try
              Case "authentication"
                xhcp.Password = ""
                Try
                  xhcp.Password = xml.GetAttribute("password")
                Catch ex As Exception
                End Try
              Case "xhcp"
                xhcp.EnableLogging = False
                Try
                  If xml.GetAttribute("logging").ToUpper = "Y" Then
                    xhcp.EnableLogging = True
                  End If
                Catch ex As Exception
                End Try
              Case "config"
                xPLConfigDisabled = False
                Try
                  If xml.GetAttribute("disableconfig").ToUpper = "Y" Then
                    xPLConfigDisabled = True
                  End If
                Catch ex As Exception
                End Try
              Case "smtp"
                xPLSMTPDisabled = False
                Try
                  If xml.GetAttribute("disablesmtp").ToUpper = "Y" Then
                    xPLSMTPDisabled = True
                  End If
                Catch ex As Exception
                End Try
              Case "master"
                Try
                  xPLHalMaster = xml.GetAttribute("masterip")
                Catch ex As Exception
                  xPLHalMaster = ""
                End Try
                If xPLHalMaster <> "" Then
                  xPLHalIsActive = False
                Else
                  xPLHalIsActive = True
                End If
              Case "schema"
                xPLSchemaCount += 1
                ReDim Preserve xPLSchemas(xPLSchemaCount)
                xPLSchemas(xPLSchemaCount).Type = xml.GetAttribute("msgtype").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).Vendor = xml.GetAttribute("source_vendor").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).Device = xml.GetAttribute("source_device").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).Instance = xml.GetAttribute("source_instance").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).SchemaClass = xml.GetAttribute("schema_class").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).SchemaType = xml.GetAttribute("schema_type").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).SubDef = xml.GetAttribute("subs").ToUpper.Trim
                xPLSchemas(xPLSchemaCount).IsX10 = False
                If InStr(xPLSchemas(xPLSchemaCount).SubDef, "H", CompareMethod.Binary) > 0 Then xPLSchemas(xPLSchemaCount).IsX10 = True
                If InStr(xPLSchemas(xPLSchemaCount).SubDef, "D", CompareMethod.Binary) > 0 Then xPLSchemas(xPLSchemaCount).IsX10 = True
                If InStr(xPLSchemas(xPLSchemaCount).SubDef, "X", CompareMethod.Binary) > 0 Then xPLSchemas(xPLSchemaCount).IsX10 = True
                Try
                  xPLSchemas(xPLSchemaCount).ActionContinue = False
                  If xml.GetAttribute("action").ToUpper = "CONTINUE" Then
                    xPLSchemas(xPLSchemaCount).ActionContinue = True
                  End If
                Catch ex As Exception
                End Try
              Case "construct"
                xPLHalCount = xPLHalCount + 1
                ReDim Preserve xPLHals(xPLHalCount)
                xPLHals(xPLHalCount).SubID = xml.GetAttribute("subid").ToUpper.Trim
                xPLHals(xPLHalCount).Name = xml.GetAttribute("key").ToUpper.Trim
                xPLHals(xPLHalCount).Desc = xml.GetAttribute("desc").Trim
                xPLHals(xPLHalCount).Init = False
                xPLHals(xPLHalCount).ValuesCount = -1
                ReDim Preserve xPLHals(xPLHalCount).Values(0)
                If xPLHals(xPLHalCount).Name.Substring(0, 1) <> "%" Then
                  xPLHalsHash.Add(xPLHals(xPLHalCount).Name, xPLHalCount)
                  ConstructName = "sys_" & xPLHals(xPLHalCount).Name.ToLower & "_"
                  XplhalSettings.WriteLine("' constants for " & xPLHals(xPLHalCount).Name.ToLower)
                Else
                  ConstructName = ""
                End If
              Case "values"
                xPLHals(xPLHalCount).ValuesCount = xPLHals(xPLHalCount).ValuesCount + 1
                ReDim Preserve xPLHals(xPLHalCount).Values(xPLHals(xPLHalCount).ValuesCount)
                xPLHals(xPLHalCount).Values(xPLHals(xPLHalCount).ValuesCount).Name = xml.GetAttribute("key").ToUpper.Trim
                xPLHals(xPLHalCount).Values(xPLHals(xPLHalCount).ValuesCount).Desc = xml.GetAttribute("desc").Trim
                If ConstructName.Length > 0 Then
                  XplhalSettings.WriteLine("const " & ConstructName & xPLHals(xPLHalCount).Values(xPLHals(xPLHalCount).ValuesCount).Name.ToLower & "=" & xPLHals(xPLHalCount).ValuesCount)
                End If
            End Select
        End Select
      End While
      xml.Close()
    Else
      ' XML file wasn't found, so write to the log to tell the user
      WriteErrorLog("Warning: The xplhal.xml configuration file was not found.")
    End If
    XplhalSettings.Close()

    ' validate globals
    For x = 1 To xPLHalCount
      If xPLHals(x).Name.Substring(0, 1) <> "%" Then
        If xPLGlobals.Exists(xPLHals(x).Name.ToUpper) = False Then
          xPLGlobals.Value(xPLHals(x).Name.ToUpper) = "0"
        Else
          If xPLGlobals.Value(xPLHals(x).Name.ToUpper()).ToString() = "" Then
            xPLGlobals.Value(xPLHals(x).Name.ToUpper) = "0"
          End If
        End If
      End If
    Next

    End Sub

    ' routine to write error log
    Public Sub WriteErrorLog(ByVal ErrMsg As String)
        Dim ErrorLog As TextWriter
        ErrorLog = Nothing
    Try
      ErrorLog = File.AppendText(xPLHalData & "\error_log.txt")
      ErrorLog.WriteLine(Format(Now, "ddd dd/MM/yy HH:mm:ss") + " : " + ErrMsg)
    Catch ex As Exception
      ' Nothing we can really do about it. Something's obviously badly screwed.
    Finally
      If Not ErrorLog Is Nothing Then
        ErrorLog.Close()
      End If
    End Try
    End Sub

    ' function to check for vendor file
    Function CheckVendor(ByVal Device As String) As Boolean
        Dim x As Integer
        If xPLDevice.ContainsKey(Device.ToUpper) = True Then
      x = CInt(xPLDevice(Device.ToUpper))
            If xPLDevices(x).ConfigMissing = True Then Return False
        Else
            Return False
        End If
        If Dir(xPLHalVendorFiles & "\" & xPLDevices(x).ConfigSource) <> "" Then Return True
        xPLDevices(x).ConfigSource = ""
        xPLDevices(x).ConfigMissing = True
        xPLSendMsg("xpl-cmnd", Device, "CONFIG.LIST", "COMMAND=REQUEST")
        Return False
    End Function

  ' routine to convert number to text
  Public Function ReturnValueStr(ByVal WhichValue As Integer) As Object
        Dim StrValue As String
        StrValue = ""
    Dim x As Integer
    If WhichValue = 0 Then Return "Zero"
    Select Case WhichValue
      Case Is > 49
        StrValue = "Fifty "
        x = WhichValue - 50
      Case Is > 39
        StrValue = "Forty "
        x = WhichValue - 40
      Case Is > 29
        StrValue = "Thirty "
        x = WhichValue - 30
      Case Is > 19
        StrValue = "Twenty "
        x = WhichValue - 20
      Case Is > 9
        Select Case WhichValue
          Case 10
            StrValue = "Ten"
          Case 11
            StrValue = "Eleven"
          Case 12
            StrValue = "Twelve"
          Case 13
            StrValue = "Thirteen"
          Case 14
            StrValue = "Fourteen"
          Case 15
            StrValue = "Fifteen"
          Case 16
            StrValue = "Sixteen"
          Case 17
            StrValue = "Seventeen"
          Case 18
            StrValue = "Eighteen"
          Case 19
            StrValue = "Nineteen"
        End Select
        Return StrValue
      Case Else
        x = WhichValue
    End Select
    If x > 0 Then StrValue = StrValue + Mid("One  Two  ThreeFour Five Six  SevenEightNine ", (5 * x) - 4, 5)
    Return StrValue
  End Function

  ' routine to save x10 state
  Public Sub SaveGroups()
    Dim xml As New Xml.XmlTextWriter(xPLHalData + "\xplhal_groups.xml", System.Text.Encoding.ASCII)
    Dim str As String
    xml.Formatting = Formatting.Indented
    xml.WriteStartDocument()
    xml.WriteStartElement("groups")
    For Each str In xPLHalGroups.Keys
      Try
        xml.WriteStartElement("group")
        xml.WriteAttributeString("name", str)
        xml.WriteAttributeString("when", xPLHalGroups(str).ToString())
        xml.WriteEndElement()
      Catch ex As Exception
        Call WriteErrorLog("Error Writing Group " & str & " to XML (" & Err.Description & ")")
      End Try
    Next
    xml.WriteEndElement()
    xml.WriteEndDocument()
    xml.Flush()
    xml.Close()

  End Sub

  Public Sub LoadGroups()

    Dim str As String
    xPLHalGroups.Clear()
    If Dir(xPLHalData & "\xplhal_groups.xml") = "" Then Exit Sub
    Dim xml As New Xml.XmlTextReader(xPLHalData & "\xplhal_groups.xml")
    While xml.Read()
      Select Case xml.NodeType
        Case XmlNodeType.Element
          Select Case xml.Name
            Case "group"
              str = xml.GetAttribute("name").ToUpper
              If xPLHalGroups.ContainsKey(str) = False Then
                xPLHalGroups.Add(str, xml.GetAttribute("when"))
              End If
          End Select
      End Select
    End While
    xml.Close()

  End Sub

  Public Sub ProcessControlMessage(ByVal e As xpllib.XplMsg)
    Try
      Dim sDevice As String = e.GetParam(1, "device").Trim
      Dim sType As String = e.GetParam(1, "type").Trim.ToLower
      Dim sCurrent As String = e.GetParam(1, "current")
      Select Case sType
        Case "determinator"
          Select Case sCurrent.ToLower.Trim
            Case "execute"
                            xplDeterminator.ExecuteRule(sDevice)
          End Select
        Case "sub"
          Select Case sCurrent.ToLower.Trim
            Case "execute"
              RunScript(sDevice, False, "")
          End Select
      End Select
    Catch ex As Exception
    End Try
  End Sub


  ' general routine to send a message
  Public Sub xPLSendMsg(ByVal strMsgType As String, ByVal strTarget As String, ByVal strSchema As String, ByVal strMessage As String)
    Dim xPLMessage As String
        Dim xPLMsg As xpllib.XplMsg
        Try
            ' Add a trailing Lf if it is missing
            If Right(strMessage, 1) <> vbLf Then
                strMessage &= vbLf
            End If

            If Len(strMsgType) = 0 Then strMsgType = "xpl-cmnd"
            If Len(strTarget) = 0 Then strTarget = "*"
            If Len(strSchema) = 0 Then Exit Sub
            If Len(strMessage) = 0 Then Exit Sub
            xPLMessage = strMsgType & vbLf & "{" & Chr(10)
            xPLMessage = xPLMessage & "hop=1" & Chr(10)
            xPLMessage = xPLMessage & "source=" & xPLHalSource.ToLower & Chr(10)
            xPLMessage = xPLMessage & "target=" & strTarget & Chr(10)
            xPLMessage = xPLMessage & "}" & Chr(10)
            xPLMessage = xPLMessage & strSchema & Chr(10) & "{" & Chr(10)
            xPLMessage = xPLMessage & strMessage
            xPLMessage = xPLMessage & "}" & Chr(10)
            xPLMsg = New xpllib.XplMsg(xPLMessage)
            xPLMsg.Send()
        Catch ex As Exception
            WriteErrorLog("Error sending xPL message: " & ex.Message)
        End Try
  End Sub

End Module
