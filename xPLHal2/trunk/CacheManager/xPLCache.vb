'**************************************
'* xPL Cache Manager
'*
'* Version 1.04
'*
'* Copyright (C) 2008 Ian Lowe
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
Imports xpllib
Imports System.Xml.Linq
Imports System.Text.RegularExpressions
Imports System.Threading

Public Class xPLCache
    Private Shared RunDets As Boolean = False
    Private Shared _gocfilestore As String
    Private Shared _datafilepath As String = ""
    Private Shared ObjectCache As New Collection
    Private Shared FilterCache As New Collection

    '*Events
    Public Shared Event CacheChanged(ByVal _objectname As String)

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function

    Public Class CacheEntry
        Private nameTag As String = ""
        Private valueTag As String = ""
        Private dateTag As Date = Now()
        Private expiry As Boolean = False

        Property ObjectName() As String
            Get
                ObjectName = nameTag
            End Get
            Set(ByVal value As String)
                nameTag = value
            End Set
        End Property

        Property ObjectValue() As String
            Get
                ObjectValue = valueTag
            End Get
            Set(ByVal value As String)
                valueTag = value
            End Set
        End Property

        Property LastUpdated() As Date
            Get
                LastUpdated = dateTag
            End Get
            Set(ByVal value As Date)
                dateTag = value
            End Set
        End Property

        Property Expires() As Boolean
            Get
                Expires = expiry
            End Get
            Set(ByVal value As Boolean)
                expiry = value
            End Set
        End Property
    End Class

    Public Class CacheFilter
        Private FilterTag As String = "*.*.*.*.*.*"
        Private prefTag As String = "cache"
        Private mfType As String = "*"
        Private mfVendor As String = "*"
        Private mfDevice As String = "*"
        Private mfInstance As String = "*"
        Private mfSchemType As String = "*"
        Private mfSchemClass As String = "*"
        Private expiry As Boolean = False

        Public FieldMap As New Collection

        ' Field Mappings structure
        Public Structure FieldMapEntry
            Public TagtoMatch As String
            Public Content As String
        End Structure

        Property xPLFilter() As String
            Get
                xPLFilter = FilterTag
            End Get
            Set(ByVal value As String)
                FilterTag = value
                Dim FilterParts As String() = Split(value, ".")
                If FilterParts.Count = 6 Then
                    mfType = FilterParts(0)
                    mfVendor = FilterParts(1)
                    mfDevice = FilterParts(2)
                    mfInstance = FilterParts(3)
                    mfSchemClass = FilterParts(4)
                    mfSchemType = FilterParts(5)
                End If
            End Set
        End Property

        Property Prefix() As String
            Get
                Prefix = prefTag
            End Get
            Set(ByVal value As String)
                prefTag = value
            End Set
        End Property

        Property ExpiresFromCache() As Boolean
            Get
                ExpiresFromCache = expiry
            End Get
            Set(ByVal value As Boolean)
                expiry = value
            End Set
        End Property

        ReadOnly Property msgTypeFilter() As String
            Get
                msgTypeFilter = mfType
            End Get
        End Property

        ReadOnly Property msgVendorFilter() As String
            Get
                msgVendorFilter = mfVendor
            End Get
        End Property

        ReadOnly Property msgDeviceFilter() As String
            Get
                msgDeviceFilter = mfDevice
            End Get
        End Property

        ReadOnly Property msgInstanceFilter() As String
            Get
                msgInstanceFilter = mfInstance
            End Get
        End Property

        ReadOnly Property msgSchemaTypeFilter() As String
            Get
                msgSchemaTypeFilter = mfSchemType
            End Get
        End Property

        ReadOnly Property msgSchemClassFilter() As String
            Get
                msgSchemClassFilter = mfSchemClass
            End Get
        End Property

        Public Sub AddFieldMapping(ByRef xPLTagName As String, ByRef CacheObjectName As String)
            If Not FieldMap.Contains(xPLTagName) Then
                Dim CacheField As New FieldMapEntry
                CacheField.TagtoMatch = xPLTagName
                CacheField.Content = CacheObjectName
                FieldMap.Add(CacheField, xPLTagName)
            End If
        End Sub

    End Class

    Shared Property RunDeterminatorsOnChange() As Boolean
        Get
            RunDeterminatorsOnChange = RunDets
        End Get
        Set(ByVal value As Boolean)
            RunDets = value
        End Set
    End Property

    Shared Property DataFilePath() As String
        Get
            DataFilePath = _gocfilestore
        End Get
        Set(ByVal value As String)
            If value IsNot Nothing Then
                _gocfilestore = value
            End If
        End Set
    End Property

    Public Shared Function Contains(ByVal ObjectName As String) As Boolean
        Return ObjectCache.Contains(ObjectName.Trim)
    End Function

    Public Shared Function Add(ByVal oName As String, ByVal oValue As String, ByVal oExpires As Boolean) As Boolean
        Try
            If oName = "" Then Return False
            Dim ObjectKey As String = oName.ToLower.Trim

            If ObjectCache.Contains(ObjectKey) Then
                ObjectValue(ObjectKey) = oValue
                Logger.AddLogEntry(AppInfo, "goc", "Modified Object Cache Entry: " & ObjectKey.ToString.Trim)
            Else
                Dim newEntry As New CacheEntry
                With newEntry
                    .ObjectName = ObjectKey
                    .ObjectValue = oValue
                    .LastUpdated = Now
                    .Expires = oExpires
                End With
                Logger.AddLogEntry(AppInfo, "goc", "Added Entry to object cache: " & ObjectKey.ToString.Trim)

                ObjectCache.Add(newEntry, ObjectKey)
                Return True
            End If
        Catch ex As Exception
            Return False
        End Try
    End Function

    Public Shared Property ObjectValue(ByVal ObjectName As String) As String
        Get
            If ObjectName = "" Then Return Nothing
            Dim objectKey As String = ObjectName.Trim
            If ObjectCache.Contains(objectKey) Then
                Dim entry As CacheEntry = ObjectCache(objectKey)
                Return entry.ObjectValue
            Else
                Return Nothing
            End If
        End Get

        Set(ByVal Value As String)
            If ObjectName <> "" Then
                Dim objectKey As String = ObjectName.Trim
                If ObjectCache.Contains(objectKey) Then
                    Dim entry As CacheEntry = ObjectCache(objectKey)
                    If entry.ObjectValue <> Value Then
                        entry.ObjectValue = Value
                        entry.LastUpdated = Now
                        RaiseEvent CacheChanged(ObjectName)
                    End If
                End If
            End If
        End Set
    End Property

    Public Shared Function ListAllObjects() As String
        ListAllObjects = ""

        For Each entry As CacheEntry In ObjectCache
            If entry.ObjectName.StartsWith("device.") Then
                Dim showdevices = ObjectValue("xplhal.showdevices")
                If showdevices IsNot Nothing Then
                    If showdevices.ToLower = "true" Then
                        ListAllObjects = ListAllObjects & entry.ObjectName & "=" & entry.ObjectValue & vbCrLf
                    End If
                End If
            ElseIf entry.ObjectName.StartsWith("config.") Then
                Dim showconfigs = ObjectValue("xplhal.showconfigs")
                If showconfigs IsNot Nothing Then
                    If showconfigs.ToLower = "true" Then
                        ListAllObjects = ListAllObjects & entry.ObjectName & "=" & entry.ObjectValue & vbCrLf
                    End If
                End If
            Else
                ListAllObjects = ListAllObjects & entry.ObjectName & "=" & entry.ObjectValue & vbCrLf
            End If
        Next
    End Function

    Public Function ListAllObjectsXML() As XElement
        Dim OutputXML As New XElement("cache")
        For Each entry As CacheEntry In ObjectCache
            OutputXML.Add(<cacheentry>
                              <name><%= entry.ObjectName %></name>
                              <value><%= entry.ObjectValue %></value>
                          </cacheentry>)
        Next
        Return OutputXML
    End Function

    Public Shared Function ListAllObjectsDictionary() As Dictionary(Of String, String)
        Dim list As New Dictionary(Of String, String)
        For Each entry As CacheEntry In ObjectCache
            list.Add(entry.ObjectName, entry.ObjectValue)
        Next
        Return list
    End Function

    Public Shared Function Filtered(ByVal sFilter As String) As Collection
        Dim FilteredSet As New Collection
        For Each entry As CacheEntry In ObjectCache
            Dim entryName As String = entry.ObjectName
            If entry.ObjectName.Contains(sFilter.ToLower) Then
                FilteredSet.Add(entry)
            End If
        Next
        Return FilteredSet
    End Function

    Public Shared Function ChildNodes(ByVal sFilter As String) As Collection
        Dim FilteredSet As New Collection
        For Each entry As CacheEntry In ObjectCache
            Dim entryName As String = entry.ObjectName
            If entry.ObjectName.StartsWith(sFilter.ToLower) Then
                FilteredSet.Add(entry)
            End If
        Next
        Return FilteredSet
    End Function

    Public Shared Function FilterbyRegEx(ByVal sFilter As Regex) As Collection
        Dim FilteredSet As New Collection
        For Each entry As CacheEntry In ObjectCache
            Dim entryName As String = entry.ObjectName
            If sFilter.IsMatch(entry.ObjectName) Then
                FilteredSet.Add(entry)
            End If
        Next
        Return FilteredSet
    End Function

    Public Shared Function Remove(ByVal ObjectName As String) As Boolean
        Try
            If ObjectName = "" Then Return False
            ObjectCache.Remove(ObjectName.Trim)
            Logger.AddLogEntry(AppInfo, "goc", "Removed Object Cache Entry: " & ObjectName.Trim)
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function


    'Save Object Cache to XML
    Public Shared Sub Save()
        Dim xmlOutput As New XElement("globals")

        For Each Entry As CacheEntry In ObjectCache
            xmlOutput.Add(<global
                              name=<%= Entry.ObjectName %>
                              value=<%= Entry.ObjectValue %>
                              lastupdate=<%= Entry.LastUpdated %>
                              expires=<%= Entry.Expires %>
                          />)
        Next
        Try
            xmlOutput.Save(_gocfilestore)
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "goc", "Error Writing global Object Cache to XML.")
            Logger.AddLogEntry(AppError, "goc", "Cause: " & ex.Message)
        End Try
    End Sub

    'Load Object Cache from XML
    Public Shared Sub Load()
        ObjectCache.Clear()
        FilterCache.Clear()
        LoadFilters(_gocfilestore & "\cachemanager.standard.xml")
        LoadFilters(_gocfilestore & "\cachemanager.custom.xml")

        _gocfilestore = _gocfilestore & "\object_cache.xml"
        If Dir(_gocfilestore) <> "" Then
            Try
                Dim xmlInput = XDocument.Load(_gocfilestore)
                Dim AllGlobalsinXML = xmlInput.<globals>.Elements
                For Each GlobalEntry In AllGlobalsinXML
                    If GlobalEntry.Attribute("name") <> "" Then
                        Add(GlobalEntry.Attribute("name").Value, GlobalEntry.Attribute("value").Value, GlobalEntry.Attribute("expires"))
                    End If
                Next
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "goc", "Error Reading Global Object Cache from XML (" & Err.Description & ")")
                Exit Sub
            End Try
        Else
            Logger.AddLogEntry(AppError, "goc", "XML Global Object Cache not found. Creating new one at: " & _gocfilestore)
            Dim newCacheStore As New XDocument
            newCacheStore.Add(<globals>
                                  <global name="xplhal.period" value="0" lastupdate=<%= Now.ToString %> expires="false"/>
                                  <global name="xplhal.mode" value="0" lastupdate=<%= Now.ToString %> expires="false"/>
                              </globals>)
            newCacheStore.Save(_gocfilestore)

            'now update the GOC in memory 
            Add("xplhal.period", "0", False)
            Add("xplhal.mode", "0", False)
            Add("xplhal.showdevices", "true", False)
            Add("xplhal.showconfigs", "true", False)
        End If
    End Sub

    'Load Object Cache from XML
    Public Shared Sub LoadFilters(ByVal FilterStore As String)
        If Dir(FilterStore) <> "" Then
            Try
                Dim xmlInput = XDocument.Load(FilterStore)
                Dim AllFiltersinXML = xmlInput.<cachemanager>.Elements
                For Each XMLCacheFilter In AllFiltersinXML
                    If XMLCacheFilter.<filter>.Value <> "" Then
                        Dim newFilter As New CacheFilter
                        newFilter.xPLFilter = XMLCacheFilter.<filter>.Value
                        newFilter.Prefix = XMLCacheFilter.Attribute("cacheprefix")
                        If XMLCacheFilter.Attribute("expires") IsNot Nothing Then
                            newFilter.ExpiresFromCache = XMLCacheFilter.Attribute("expires")
                        End If
                        For Each fieldmapping In XMLCacheFilter.<fields>.Elements
                            newFilter.AddFieldMapping(fieldmapping.Attribute("xpltagname").Value, fieldmapping.Attribute("cacheobjectname").Value)
                        Next
                        FilterCache.Add(newFilter, newFilter.xPLFilter)
                    End If
                Next
            Catch ex As Exception
                Logger.AddLogEntry(AppError, "goc", "Error Reading Cache Filter from XML.")
                Logger.AddLogEntry(AppError, "goc", "Cause: " & ex.Message)
                Exit Sub
            End Try
        End If

    End Sub

    Public Shared Sub FlushExpiredEntries()
        For Each entry As CacheEntry In xPLCache.ObjectCache
            If entry.Expires Then
                Dim ageofentry As Int16 = DateDiff(DateInterval.Minute, entry.LastUpdated, Now)
                If ageofentry > 15 Then
                    xPLCache.ObjectCache.Remove(entry.ObjectName)
                End If
            End If
        Next
    End Sub

    Public Shared Sub ProcessXplMessage(ByVal x As xpllib.XplMsg)
        Try
            Dim m As New xPLParser
            Dim t As New Thread(AddressOf m.Parse)
            m.xPLMessage = x
            t.Start()
        Catch ex As Exception
            Logger.AddLogEntry(AppError, "goc", "Cannot Create xPLCache Parsing Thread.")
            Logger.AddLogEntry(AppError, "goc", "Cause: " & ex.Message)
        End Try
    End Sub


    Public Class xPLParser

        Public xPLMessage As XplMsg

        Public Sub Parse()
            'change this to use Filters, as per the defined CacheManager.standard.xml and CacheManager.custom.xml
            For Each msgFilter As CacheFilter In FilterCache
                Dim bPassMessage As Boolean = True
                If msgFilter.msgTypeFilter <> "*" And msgFilter.msgTypeFilter <> xPLMessage.MsgTypeString Then
                    bPassMessage = False
                End If
                If msgFilter.msgVendorFilter <> "*" And msgFilter.msgVendorFilter <> xPLMessage.SourceVendor.ToString Then
                    bPassMessage = False
                End If
                If msgFilter.msgDeviceFilter <> "*" And msgFilter.msgDeviceFilter <> xPLMessage.SourceDevice.ToString Then
                    bPassMessage = False
                End If
                If msgFilter.msgInstanceFilter <> "*" And msgFilter.msgInstanceFilter <> xPLMessage.SourceInstance.ToString Then
                    bPassMessage = False
                End If
                If msgFilter.msgSchemClassFilter <> "*" And msgFilter.msgSchemClassFilter <> xPLMessage.Class.ToString Then
                    bPassMessage = False
                End If
                If msgFilter.msgSchemaTypeFilter <> "*" And msgFilter.msgSchemaTypeFilter <> xPLMessage.Type.ToString Then
                    bPassMessage = False
                End If

                If bPassMessage And msgFilter.Prefix <> "" Then
                    Dim TagIndex As Integer = 1
                    For Each wantedTag As CacheFilter.FieldMapEntry In msgFilter.FieldMap
                        Dim GOCString As String = ""
                        If wantedTag.TagtoMatch = "*" Then
                            GOCString = msgFilter.Prefix & "."
                            StorexPLMessage(xPLMessage, FilterVars(xPLMessage, GOCString))
                        Else
                            If xPLMessage.GetKeyValue(wantedTag.TagtoMatch.ToLower) <> "" Then
                                GOCString = msgFilter.Prefix & "." & wantedTag.Content
                                xPLCache.Add(FilterVars(xPLMessage, GOCString), xPLMessage.GetKeyValue(wantedTag.TagtoMatch.ToLower), msgFilter.ExpiresFromCache)
                            End If
                        End If
                        TagIndex += 1
                    Next
                End If
            Next

            'Debug lines, which cache everything in a message.
            'If xPLMessage.MsgTypeString = "xpl-cmnd" Then
            '    GOCString = "cache." & xPLMessage.Class & "."
            '    If xPLMessage.TargetTag <> "*" Then
            '        GOCString = "device." & xPLMessage.TargetTag & "." & xPLMessage.Class & "."
            '        StorexPLMessage(x, GOCString)
            '    End If
            'Else
            '    If xPLMessage.Class = "hbeat" Or xPLMessage.Class = "config" Then
            '        GOCString = "device." & xPLMessage.SourceTag & "." & xPLMessage.Class & "."
            '        StorexPLMessage(x, GOCString)
            '    Else
            '        GOCString = "device." & xPLMessage.SourceTag & "." & xPLMessage.Class & "."
            '        StorexPLMessage(x, GOCString)
            '        GOCString = "cache." & xPLMessage.Class & "."
            '        StorexPLMessage(x, GOCString)
            '    End If
            'End If

        End Sub

        Private Sub StorexPLMessage(ByVal x As xpllib.XplMsg, ByVal CacheString As String)

            For Each MessageElement In x.KeyValues
                Dim keyname As String = CacheString & MessageElement.Key
                If ObjectCache.Contains(keyname.ToLower) Then
                    xPLCache.ObjectValue(keyname.ToLower) = MessageElement.Value
                Else
                    xPLCache.Add(keyname.ToLower, MessageElement.Value, True)
                End If
            Next
        End Sub

        Private Function FilterVars(ByVal x As XplMsg, ByVal str As String) As String

            'xPL Sturctural Elements
            str = str.Replace("{VDI}", x.SourceTag.ToLower)
            str = str.Replace("{INSTANCE}", x.SourceInstance.ToLower)
            str = str.Replace("{DEVICE}", x.SourceInstance.ToLower)
            str = str.Replace("{SCHEMA}", x.SourceInstance.ToLower)

            Dim RegexObj As New Regex("\{XPL::\w+\}")
            Dim MatchResults As Match = RegexObj.Match(str)

            While MatchResults.Success
                Dim xplTag As String = MatchResults.Value.Substring(6, MatchResults.Length - 7).ToLower
                If x.GetKeyValue(xplTag) <> "" Then
                    str = str.Replace(MatchResults.Value, x.GetKeyValue(xplTag).ToLower)
                Else
                    str = str.Replace(MatchResults.Value, "")
                End If
                MatchResults = MatchResults.NextMatch()
            End While

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

End Class
