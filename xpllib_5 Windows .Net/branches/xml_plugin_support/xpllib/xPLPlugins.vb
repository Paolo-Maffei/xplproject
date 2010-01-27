'* xPL Library for .NET
'*
'* Version 5.1
'*
'* Copyright (c) 2009-2010 Thijs Schreijer
'* http://www.thijsschreijer.nl
'*
'* Copyright (c) 2008-2009 Tom Van den Panhuyzen
'* http://blog.boxedbits.com/xpl
'*
'* Copyright (C) 2003-2005 John Bent
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
'* Linking this library statically or dynamically with other modules is
'* making a combined work based on this library. Thus, the terms and
'* conditions of the GNU General Public License cover the whole
'* combination.
'* As a special exception, the copyright holders of this library give you
'* permission to link this library with independent modules to produce an
'* executable, regardless of the license terms of these independent
'* modules, and to copy and distribute the resulting executable under
'* terms of your choice, provided that you also meet, for each linked
'* independent module, the terms and conditions of the license of that
'* module. An independent module is a module which is not derived from
'* or based on this library. If you modify this library, you may extend
'* this exception to your version of the library, but you are not
'* obligated to do so. If you do not wish to do so, delete this
'* exception statement from your version.

Option Strict On
Imports System.IO
Imports System.Environment
Imports System.Xml
Imports System
Imports System.Threading
Imports xPL.xPL_Base

''' <summary>
''' Represents a Vendor from the central vendor xml list downloaded from the xPL site
''' </summary>
''' <remarks></remarks>
Public Class xPLPluginVendor
    Private pID As String
    ''' <summary>
    ''' Plugin name, source is the central xPL plugin download list
    ''' </summary>
    Public Name As String
    ''' <summary>
    ''' Plugin type, source is the central xPL plugin download list
    ''' </summary>
    ''' <remarks>Should be 'plugin'.</remarks>
    Public Type As String
    ''' <summary>
    ''' Plugin description, source is the central xPL plugin download list
    ''' </summary>
    Public Description As String
    ''' <summary>
    ''' Plugin download URL, source is the central xPL plugin download list
    ''' </summary>
    ''' <remarks>This URL is used to download the plugin itself</remarks>
    Public URL As String
    ''' <summary>
    ''' Vendor name, source is the vendor provided plugin download
    ''' </summary>
    Public Vendor As String
    ''' <summary>
    ''' Informational URL, source is the vendor provided plugin download
    ''' </summary>
    Public InfoURL As String
    ''' <summary>
    ''' Parse a string to a version object, any missing or uncovertable element will be set to 0
    ''' </summary>
    Public Shared Function StrToVersion(ByVal strVersion As String) As Version
        Dim s() As String = strVersion.Split("."c)
        Dim major As Integer
        Dim minor As Integer
        Dim build As Integer
        Dim revision As Integer
        Dim r As Integer
        For n As Integer = 0 To 3
            If n > s.Length - 1 Then
                r = 0
            Else
                Try
                    r = CInt(s(n))
                Catch ex As Exception
                    r = 0
                End Try
            End If
            Select Case n
                Case 0 : major = r
                Case 1 : minor = r
                Case 2 : build = r
                Case 3 : revision = r
            End Select
        Next
        Return New Version(major, minor, build, revision)
    End Function
    Private pVersion As Version
    ''' <summary>
    ''' Version, source is the vendor provided plugin download
    ''' </summary>
    ''' <remarks>Version is provided as a string</remarks>
    Public Property VersionStr() As String
        Get
            Return pVersion.ToString()
        End Get
        Set(ByVal value As String)
            pVersion = xPLPluginVendor.StrToVersion(value)
        End Set
    End Property
    ''' <summary>
    ''' Version, source is the vendor provided plugin download
    ''' </summary>
    ''' <remarks>Version is provided as a Version object</remarks>
    Public Property VersionV() As Version
        Get
            Return pVersion
        End Get
        Set(ByVal value As Version)
            pVersion = value
        End Set
    End Property
    ''' <summary>
    ''' Plugin download URL, source is the vendor provided plugin download
    ''' </summary>
    ''' <remarks>This URL is NOT used, for downloading the central URL is used, see <seealso cref="xPLPluginVendor.URL"/>.</remarks>
    Public PluginURL As String

    Private pAttributes As New Dictionary(Of String, String)
    ''' <summary>
    ''' Collection containing remaining xml attributes of the vendor
    ''' </summary>
    ''' <remarks></remarks>
    Public ReadOnly Property Attributes() As Dictionary(Of String, String)
        Get
            Return pAttributes
        End Get
    End Property

    ''' <summary>Contains the Vendor ID, as used in the xPL address notation 'vendor-device.instance'</summary>
    Public ReadOnly Property ID() As String
        Get
            Return pID
        End Get
    End Property
    ''' <summary>
    ''' Creates a new xPLVendor object with the given Vendor ID
    ''' </summary>
    ''' <param name="strID">Vendor ID, as used in the xPL address notation 'vendor-device.instance'</param>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentException">Condition: ID provided is an empty string</exception>
    Public Sub New(ByVal strID As String)
        pVersion = New Version(0, 0, 0, 0)
        If strID Is Nothing Then strID = ""
        If strID <> "" Then
            pID = strID
        Else
            Throw New ArgumentException("ID cannot be an empty string")
        End If
    End Sub
End Class

''' <summary>
''' Represents a device plugin from the vendor specific xml, downloaded from the vendors site
''' </summary>
''' <remarks></remarks>
Public Class xPLPluginDevice
    Private pID As String = ""

    ''' <summary>
    ''' Device specific information URL. Source is the vendor specific xml file.
    ''' </summary>
    Public URLinfo As String = ""
    ''' <summary>
    ''' Device description. Source is the vendor specific xml file.
    ''' </summary>
    Public Description As String = ""
    Private pVersion As Version
    ''' <summary>
    ''' Most recent device version. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Version is provided as a string</remarks>
    Public Property VersionStr() As String
        Get
            Return pVersion.ToString()
        End Get
        Set(ByVal value As String)
            pVersion = xPLPluginVendor.StrToVersion(value)
        End Set
    End Property
    ''' <summary>
    ''' Most recent device version. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Version is provided as a Version object</remarks>
    Public Property VersionV() As Version
        Get
            Return pVersion
        End Get
        Set(ByVal value As Version)
            pVersion = value
        End Set
    End Property
    Private pBetaVersion As Version
    ''' <summary>
    ''' Most recent device beta version. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Beta Version is provided as a string</remarks>
    Public Property BetaVersionStr() As String
        Get
            Return pBetaVersion.ToString()
        End Get
        Set(ByVal value As String)
            pBetaVersion = xPLPluginVendor.StrToVersion(value)
        End Set
    End Property
    ''' <summary>
    ''' Most recent device beta version. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Beta Version is provided as a Version object</remarks>
    Public Property BetaVersionV() As Version
        Get
            Return pBetaVersion
        End Get
        Set(ByVal value As Version)
            pBetaVersion = value
        End Set
    End Property
    ''' <summary>
    ''' Download URL for the xml-plugin that (also) contains this device. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>This URL is NOT used. For downloading the central URL is used, see <seealso cref="xPLPluginVendor.URL"/>.</remarks>
    Public URLplugin As String = ""
    ''' <summary>
    ''' Download URL for the software package. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks></remarks>
    Public URLdownload As String = ""
    ''' <summary>
    ''' The type of device; real xPL device package, or another piece of software that is not an xPL device.
    ''' Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Examples of non-device items are; xPL code libraries, hubs, diagnostic tools, etc.</remarks>
    Public Type As String = "unknown"
    ''' <summary>
    ''' Target platform for the device. Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Examples; windows, os x, linux, java, perl.</remarks>
    Public Platform As String = "unknown"
    ''' <summary>
    ''' Contains the xml of the device.
    ''' </summary>
    ''' <remarks></remarks>
    Public XML As String = ""
    Private pAttributes As New Dictionary(Of String, String)
    ''' <summary>
    ''' Collection containing remaining xml attributes of the device
    ''' </summary>
    ''' <remarks></remarks>
    Public ReadOnly Property Attributes() As Dictionary(Of String, String)
        Get
            Return pAttributes
        End Get
    End Property

    ''' <returns>Contains the Device ID in format 'vendor-device', as used in the xPL address notation 'vendor-device.instance'</returns>
    Public ReadOnly Property ID() As String
        Get
            Return pID
        End Get
    End Property

    ''' <summary>
    ''' Creates a new xPLDevicePlugin object with the given Device ID
    ''' </summary>
    ''' <param name="strID">Device ID in format 'vendor-device', as used in the xPL address notation 'vendor-device.instance'</param>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentException">Condition: ID provided is an empty string</exception>
    Public Sub New(ByVal strID As String)
        pVersion = New Version(0, 0, 0, 0)
        pBetaVersion = New Version(0, 0, 0, 0)
        If strID Is Nothing Then strID = ""
        If strID <> "" Then
            pID = strID
        Else
            Throw New ArgumentException("ID cannot be an empty string")
        End If
    End Sub
End Class

''' <summary>
''' Class to manage and update the local shared PluginStore. Provides methods to download an update plugins
''' and update the local store.
''' </summary>
''' <remarks></remarks>
Public Class xPLPluginStore

    ''' <summary>
    ''' EventArgs class used with the <seealso cref="xPLPluginStore.UpdateProgress"/> event
    ''' </summary>
    ''' <remarks></remarks>
    Public Class UpdateInfo
        Inherits EventArgs
        ''' <summary>
        ''' Percentage complete of current update operation
        ''' </summary>
        ''' <remarks></remarks>
        Public PercentComplete As Integer = 0
        ''' <summary>
        ''' Status message of current activity
        ''' </summary>
        ''' <remarks></remarks>
        Public StatusMsg As String = ""
        ''' <summary>
        ''' Log lines added since last event
        ''' </summary>
        ''' <remarks></remarks>
        Public LogUpdate As String = ""
        ''' <summary>
        ''' Complete log, including the last lines.
        ''' </summary>
        ''' <remarks></remarks>
        Public LogComplete As String = ""
        ''' <summary>
        ''' True if this LogUpd contains errors, false otherwise
        ''' </summary>
        ''' <remarks></remarks>
        Public HasError As Boolean = False
    End Class

    Private PluginStore As XmlDocument = Nothing
    Private PluginMain As XmlElement = Nothing        ' Contains the main element in the PluginStore
    Private PluginList As XmlDocument = Nothing       ' Contains last downloaded pluginlist

    Private pSaveStore As Boolean ' should store be saved at end of update?

#Region "Events"

    ''' <summary>
    ''' Event raised during the update process to inform owner about progress
    ''' </summary>
    ''' <param name="e">Event parameters containing status information</param>
    ''' <remarks></remarks>
    Public Event UpdateProgress(ByVal e As xPLPluginStore.UpdateInfo)
    ''' <summary>
    ''' Event raised when the update process is completed
    ''' </summary>
    ''' <param name="e">Event parameters containing status information</param>
    ''' <remarks></remarks>
    Public Event UpdateComplete(ByVal e As xPLPluginStore.UpdateInfo)

#End Region

#Region "Properties"
    Private pPluginStoreFile As String = _
        GetFolderPath(SpecialFolder.CommonApplicationData) & XPL_PLUGINSTORE_PATH & XPL_PLUGIN_EXTENSION
    ''' <summary>
    ''' Filename of the plugin store, fullpath and name including the '.xml' extension
    ''' </summary>
    ''' <remarks></remarks>
    Public Property PluginStoreFile() As String
        Get
            Return pPluginStoreFile
        End Get
        Set(ByVal value As String)
            pPluginStoreFile = Path.GetFullPath(value)
            If Debug Then LogError("xPLPluginStore.PluginStoreFile", "PluginStoreFile = " & pPluginStoreFile)
        End Set
    End Property

    Private pUpdateRunning As Boolean = False
    ''' <summary>
    ''' Indicates whether an update is currently running
    ''' </summary>
    ''' <remarks>call <seealso cref="xPLPluginStore.UpdatePluginStore"/> to start an update.</remarks>
    Public ReadOnly Property UpdateRunning() As Boolean
        Get
            Return pUpdateRunning
        End Get
    End Property

    Private pIsLoaded As Boolean = False
    ''' <summary>
    ''' Returns True if the store is loaded.
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property IsLoaded() As Boolean
        Get
            Return pIsLoaded
        End Get
    End Property

    Private pLastUpdate As New Date(2000, 1, 1, 0, 0, 0)
    ''' <summary>
    ''' Returns the date/time the last succesfull update (downloading plugins) was performed.
    ''' </summary>
    Public ReadOnly Property LastUpdate() As Date
        Get
            Return pLastUpdate
        End Get
    End Property

    Private mDebug As Boolean = False
    ''' <summary>
    ''' Sets or gets the debugging status of the object. If set to <c>True</c> there will be substantially more
    ''' logging.
    ''' </summary>
    Public Property Debug() As Boolean
        Get
            Return mDebug
        End Get
        Set(ByVal value As Boolean)
            mDebug = value
            If Debug Then LogError("xPLPluginStore.Debug", "Debug = " & mDebug.ToString)
        End Set
    End Property

    Private pVendors As New Dictionary(Of String, xPLPluginVendor)
    ''' <summary>
    ''' Collection representing all vendors in the PluginStore
    ''' </summary>
    ''' <remarks>The key is the Vendor ID. Changes made to this collection and its items will not be stored
    ''' in the PluginStore.</remarks>
    Public ReadOnly Property Vendors() As Dictionary(Of String, xPLPluginVendor)
        Get
            Return pVendors
        End Get
    End Property

    Private pDevices As New Dictionary(Of String, xPLPluginDevice)
    ''' <summary>
    ''' Collection representing all devices in the PluginStore
    ''' </summary>
    ''' <remarks>The key is a combination of the Vendor ID and the Device ID in the xPL address 
    ''' format; 'vendor-device'. Changes made to this collection and its items will not be stored
    ''' in the PluginStore.</remarks>
    Public ReadOnly Property Devices() As Dictionary(Of String, xPLPluginDevice)
        Get
            Return pDevices
        End Get
    End Property

    ''' <summary>
    ''' Collection representing all devices in the PluginStore by the specified vendor
    ''' </summary>
    ''' <param name="VendorID">The ID of the vendor of which the devices should be returned</param>
    ''' <remarks>The key is a combination of the Vendor ID and the Device ID in the xPL address 
    ''' format; 'vendor-device'. Changes made to this collection and its items will not be stored
    ''' in the PluginStore.</remarks>
    Public ReadOnly Property DevicesByVendor(ByVal VendorID As String) As Dictionary(Of String, xPLPluginDevice)
        Get
            ' create a new list
            Dim l As New Dictionary(Of String, xPLPluginDevice)
            Dim d As KeyValuePair(Of String, xPLPluginDevice)
            ' loop through all devices in the list
            For Each d In Me.Devices
                Try
                    If Split(d.Value.ID, "-"c)(1) = VendorID Then
                        ' device matches vendorid, so add to list
                        l.Add(d.Value.ID, d.Value)
                    End If
                Catch ex As Exception
                End Try
            Next
            Return l
        End Get
    End Property

#End Region

#Region "Constructors/destructors"

    ''' <summary>
    ''' Creates a new object and loads the shared pluginstore, if it doesn't exist
    ''' a blank one will be created in memory (not yet written to disk)
    ''' </summary>
    ''' <remarks>Use SavePluginStore to save the store to disk</remarks>
    Public Sub New()
        pIsLoaded = False
        pLastUpdate = New Date(2000, 1, 1, 0, 0, 0)
        PluginStore = Nothing
        PluginMain = Nothing
        PluginList = Nothing
    End Sub

#End Region

#Region "Manage PluginStore"

    ''' <summary>
    ''' Loads the shared pluginstore, if it doesn't exist
    ''' a blank one will be created in memory (not yet written to disk)
    ''' </summary>
    ''' <remarks>Use SavePluginStore to save the store to disk</remarks>
    Public Sub LoadPluginStore()
        Dim s As String
        Dim e As XmlElement

        If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Starting load")

        ' clean up any old stuff if present
        PluginStore = Nothing
        PluginMain = Nothing
        PluginList = Nothing

        ' create new pluginstore
        PluginStore = New XmlDocument

        ' make sure common data directory exists
        Try
            If Not Directory.Exists(Path.GetDirectoryName(pPluginStoreFile)) Then
                Directory.CreateDirectory(Path.GetDirectoryName(pPluginStoreFile))
                LogError("xPLPluginStore.LoadPluginStore", "Created directory " & Path.GetDirectoryName(pPluginStoreFile))
            End If
        Catch ex As Exception
            ' Cannot access/create common data directory
            ' do nothing, new one will be created
            LogError("xPLPluginStore.LoadPluginStore", "Cannot access/create " & Path.GetDirectoryName(pPluginStoreFile) & vbCrLf & ex.ToString, EventLogEntryType.Warning)
        End Try

        Try
            ' Load store
            If File.Exists(Me.PluginStoreFile) Then
                PluginStore.Load(Me.PluginStoreFile)
                If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Load file " & pPluginStoreFile)
            Else
                ' create new store
                PluginStore = Me.CreateNewPluginStore
                If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Created new store in memory")
            End If
        Catch ex As Exception
            ' Could not load pluginstore, create new one
            PluginStore = Me.CreateNewPluginStore
            LogError("xPLPluginStore.LoadPluginStore", "Could not load store, creating a new one in memory. " & vbCrLf & ex.ToString, EventLogEntryType.Warning)
        End Try

        ' set the main element
        PluginMain = PluginStore.DocumentElement

        ' verify main elements, add if not present
        s = ""
        For n As Integer = 1 To 3
            Select Case n
                Case 1 : s = "vendors"
                Case 2 : s = "devices"
                Case 3 : s = "locations"
            End Select

            e = PluginMain.Item(s)
            If e Is Nothing Then
                ' not found, so it must be added; create it and add
                If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Element '" & s & "' not found")
                e = PluginStore.CreateElement(s)
                PluginMain.AppendChild(e)
                If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Element '" & s & "' added")
            Else
                If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Element '" & s & "' found")
            End If
        Next

        ' set Loaded property to true
        pIsLoaded = True

        ' set/get LastUpdate
        If PluginMain.GetAttribute("lastupdate") <> "" Then
            pLastUpdate = CDate(PluginMain.GetAttribute("lastupdate"))
            If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Attribute 'lastupdate' found; " & pLastUpdate.ToString)
        Else
            ' store empty (old) date value
            pLastUpdate = New Date(2000, 1, 1, 0, 0, 0)
            PluginMain.SetAttribute("lastupdate", pLastUpdate.ToString("u"))
            If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Attribute 'lastupdate' not found; created @ " & pLastUpdate.ToString)
        End If
        If Debug Then LogError("xPLPluginStore.LoadPluginStore", "Completed")
    End Sub

    ''' <summary>
    ''' Creates a new PluginStore, with the version attribute
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function CreateNewPluginStore() As XmlDocument
        Dim myStore As XmlDocument
        Dim root As XmlElement
        ' create new store
        If Debug Then LogError("xPLPluginStore.CreateNewPluginStore", "Starting creation")
        myStore = New XmlDocument
        root = myStore.CreateElement("pluginstore")
        myStore.AppendChild(root)
        root.SetAttribute("version", XPL_PLUGINSTORE_VERSION)
        root.SetAttribute("lastupdate", New Date(2000, 1, 1, 0, 0, 0).ToString("u"))
        If Debug Then LogError("xPLPluginStore.CreateNewPluginStore", "Store created version @ " & XPL_PLUGINSTORE_VERSION)
        Return myStore
    End Function

    ''' <summary>
    ''' Stores the PluginStore in memory to disk
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub SavePluginStore()

        If PluginStore Is Nothing Then Exit Sub

        ' make sure common data directory exists
        Try
            If Not Directory.Exists(Path.GetDirectoryName(pPluginStoreFile)) Then
                Directory.CreateDirectory(Path.GetDirectoryName(pPluginStoreFile))
                LogError("xPLPluginStore.SavePluginStore", "Created directory " & Path.GetDirectoryName(pPluginStoreFile))
            End If
        Catch ex As Exception
            ' Cannot access/create common data directory
            LogError("xPLPluginStore.SavePluginStore", "Could not create/access " & Path.GetDirectoryName(pPluginStoreFile) & vbCrLf & ex.ToString, EventLogEntryType.Warning)
            Throw New Exception("Could not create/access pluginstore directory", ex)
        End Try

        Try
            ' Save store
            PluginStore.Save(Me.PluginStoreFile)
            If Debug Then LogError("xPLPluginStore.SavePluginStore", "PluginStore saved succesfully to " & Me.PluginStoreFile)
        Catch ex As Exception
            ' Could not save pluginstore
            LogError("xPLPluginStore.SavePluginStore", "Error saving store: " & ex.ToString, EventLogEntryType.Error)
            Throw New Exception("Could not save pluginstore directory", ex)
        End Try

    End Sub

    ''' <summary>
    ''' Loads the central plugin list from the download location, and updates the list download locations
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub GetPluginList()
        Dim locations As XmlElement = Nothing
        Dim loclist As New ArrayList
        Dim listroot As XmlElement = Nothing
        Dim URL As String
        Dim iPos As Integer
        Dim elem As XmlElement

        If Debug Then LogError("xPLPluginStore.GetPluginList", "Starting update of pluginlist")

        ' get the locations node
        locations = PluginMain.Item("locations")

        ' copy URL's to arraylist
        For Each x As XmlElement In locations
            loclist.Add(x.GetAttribute("url"))
        Next

        ' Add default url's to list, if they are not in there
        If Trim(XPL_PLUGIN_URL1) <> "" And loclist.IndexOf(XPL_PLUGIN_URL1) = -1 Then loclist.Add(XPL_PLUGIN_URL1)
        If Trim(XPL_PLUGIN_URL2) <> "" And loclist.IndexOf(XPL_PLUGIN_URL2) = -1 Then loclist.Add(XPL_PLUGIN_URL2)
        If Trim(XPL_PLUGIN_URL3) <> "" And loclist.IndexOf(XPL_PLUGIN_URL3) = -1 Then loclist.Add(XPL_PLUGIN_URL3)

        ' try getting the list from the locations, top down
        For n As Integer = 0 To loclist.Count - 1
            URL = CStr(loclist(n))
            PluginList = New XmlDocument
            Try
                ' try reading xml from url, with extension
                PluginList.Load(URL & XPL_PLUGIN_EXTENSION)
                LogError("xPLPluginStore.GetPluginList", "Succesfully retrieved pluginlist from " & URL & XPL_PLUGIN_EXTENSION)
                Exit For     ' we have one, go exit
            Catch ex As Exception
                ' opening url failed, try again without extension
                Try
                    PluginList.Load(URL)
                    LogError("xPLPluginStore.GetPluginList", "Succesfully retrieved pluginlist from " & URL)
                    Exit For    ' we have one, go exit
                Catch
                    LogError("xPLPluginStore.GetPluginList", "Failed retrieving pluginlist from " & URL & XPL_PLUGIN_EXTENSION, EventLogEntryType.Error)
                    Me.EventUpdateAddLog("  URL failed: " & URL, True, True)
                    If n = loclist.Count - 1 Then
                        ' this was the last one
                        Me.EventUpdateAddLog("All URL's failed!", True, True)
                    End If
                    Me.EventUpdateRaiseNow()
                    PluginList = Nothing
                End Try
            End Try
        Next

        If PluginList Is Nothing Then
            ' pluginlist couldn't be downloaded...
            ' error shoud be logged here
            LogError("xPLPluginStore.GetPluginList", "xPL Plugin List could not be downloaded from any of the URLs available", EventLogEntryType.Error)
            Throw New Exception("Could not load Plugin list")
        Else
            ' we have a list, now go update the download locations

            ' get root element
            listroot = PluginList.DocumentElement
            locations = listroot.Item("locations")
            iPos = 0
            ' go update the arraylist with the locations
            For Each x As XmlElement In locations.ChildNodes
                If x.Name = "location" Then
                    URL = x.GetAttribute("url")
                    If URL Is Nothing Then URL = ""
                    If URL <> "" Then
                        ' we have a download location
                        If loclist.IndexOf(URL) <> -1 Then
                            ' its already in the list, go remove it
                            loclist.Remove(URL)
                        End If
                        ' now add at top of list, in order as specified in downloaded list, to always
                        ' make sure that the newest locations are at the top
                        loclist.Insert(iPos, URL)
                        iPos += 1
                    End If
                End If
            Next
            ' Array has been updated, now update our plugin store
            locations = PluginMain.Item("locations")            ' get the locations element
            locations.RemoveAll()                               ' delete all locations from it
            For n As Integer = 0 To loclist.Count - 1
                elem = PluginStore.CreateElement("location")    ' create location element
                elem.SetAttribute("url", CStr(loclist(n)))       ' add url attribute
                locations.AppendChild(elem)                     ' add element to locations list
            Next
            If Debug Then LogError("xPLPluginStore.GetPluginList", "Download locations updated!")
        End If
    End Sub

    ''' <summary>
    ''' Asynchroneously updates the plugins store, first downloads the plugin list, then downloads 
    ''' all plugins. If the store hasn't been loaded yet, it will be loaded.
    ''' </summary>
    ''' <param name="SaveStore">If <c>True</c>, the store will be saved to the default location. If 
    ''' <c>False</c>, then the store will not be saved but only stored in memory.</param>
    ''' <remarks>The update will be started on a new thread. Check the 
    ''' <seealso cref="xPLPluginStore.UpdateRunning"/> property to check the status or use the events to
    ''' receive progress information on the update.</remarks>
    Public Sub UpdatePluginStore(Optional ByVal SaveStore As Boolean = True)

        ' check if update is already running
        If pUpdateRunning Then
            If Debug Then LogError("xPLPluginStore.UpdatePluginStore", "Update is already running, no new update started")
            Exit Sub
        End If

        If Debug Then LogError("xPLPluginStore.UpdatePluginStore", "Starting update of pluginstore")

        ' Create a new thread for the update
        If Debug Then LogError("xPLPluginStore.UpdatePluginStore", "Starting on new thread")
        pSaveStore = SaveStore
        Dim myThreadDelegate As New ThreadStart(AddressOf PerformUpdate)
        Dim myThread As New Thread(myThreadDelegate)
        myThread.Start()
        If Debug Then LogError("xPLPluginStore.UpdatePluginStore", "Completed")
    End Sub

    Private Sub PerformUpdate()
        Dim plugin As XmlDocument
        Dim pRoot As XmlElement
        Dim vAttrib As New Dictionary(Of String, String)
        Dim vURL As String
        Dim DeviceID As String
        Dim VendorID As String
        Dim elDevices As XmlElement
        Dim elVendors As XmlElement
        Dim OneSuccess As Boolean = False
        Dim total As Integer = 0
        Dim count As Integer = 0

        pUpdateRunning = True
        Try
            If Debug Then LogError("xPLPluginStore.PerformUpdate", "Starting update of vendor plugins")

            Me.EventUpdateReset()
            Me.EventUpdateAddLog("Starting PluginStore update", False)
            Me.EventUpdateAddLog("Loading PluginStore... ")
            Me.EventUpdateStatus(0, "Loading PluginStore")

            ' If not loaded, load now
            If Not pIsLoaded Then Me.LoadPluginStore()
            Me.EventUpdateAddLog("completed.", False)
            Me.EventUpdateAddLog("PluginStore last update: " & _
                                 pLastUpdate.ToShortDateString & " " & pLastUpdate.ToShortTimeString, False)
            Me.EventUpdateAddLog("Downloading main list... ")
            Me.EventUpdateStatus(5, "Downloading main list")

            elDevices = PluginMain("devices")
            elVendors = PluginMain("vendors")

            ' Download latest plugin list
            Try
                GetPluginList()
                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Received main vendor plugin list")
            Catch ex As Exception
                ' log error here
                Me.EventUpdateAddLog("Downloading main list failed!")
                LogError("xPLPluginStore.PerformUpdate", "Failed to retreive main plugin list", EventLogEntryType.Error)
            End Try
            Me.EventUpdateStatus(10)

            If Not PluginList Is Nothing Then
                ' count files to download
                For Each vendor As XmlElement In PluginList.DocumentElement.ChildNodes
                    If vendor.Name = "plugin" Then
                        total += 1
                    End If
                Next

                ' Now update the individual plugins
                For Each vendor As XmlElement In PluginList.DocumentElement.ChildNodes
                    If vendor.Name = "plugin" Then
                        vAttrib.Clear()
                        Me.EventUpdateAddLog("Downloading plugin info '" & vendor.GetAttribute("name") & "'... ")
                        Me.EventUpdateStatus(, "Downloading plugin info '" & vendor.GetAttribute("name") & "'... ")
                        Me.EventUpdateRaiseNow()
                        ' we've got a plugin element, get plugin data
                        vAttrib.Add("name", vendor.GetAttribute("name"))
                        vAttrib.Add("type", vendor.GetAttribute("type"))
                        vAttrib.Add("description", vendor.GetAttribute("description"))
                        vURL = vendor.GetAttribute("url")
                        vAttrib.Add("url", vURL)
                        ' download plugin
                        plugin = New XmlDocument
                        Try
                            ' download file
                            plugin.Load(vURL & XPL_PLUGIN_EXTENSION)
                            ' if download succeeded, then set OneSuccess to true
                            OneSuccess = True
                            Me.EventUpdateAddLog("Success!", False)
                            If Debug Then LogError("xPLPluginStore.PerformUpdate", "Succesfully downloaded " & vURL & XPL_PLUGIN_EXTENSION)
                        Catch
                            Try
                                ' download failed, try again, without extension
                                plugin.Load(vURL)
                                ' if download succeeded, then set OneSuccess to true
                                OneSuccess = True
                                Me.EventUpdateAddLog("Success!", False)
                                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Succesfully downloaded " & vURL)
                            Catch ex As Exception
                                Me.EventUpdateAddLog("Failed!", False)
                                Me.EventUpdateAddLog("    Failed URL: " & vURL, , True)
                                LogError("xPLPluginStore.PerformUpdate", "Could not download plugin; " & vbCrLf & _
                                       "   Name: " & vAttrib.Item("name") & vbCrLf & _
                                       "   Type: " & vAttrib.Item("type") & vbCrLf & _
                                       "   Description: " & vAttrib.Item("description") & vbCrLf & _
                                       "   Url: " & vAttrib.Item("url") & vbCrLf & ex.ToString, EventLogEntryType.Error)
                                plugin = Nothing
                            End Try
                        End Try

                        If Not plugin Is Nothing Then
                            Try
                                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Parsing vendor plugin...")
                                ' Plugin succesfully downloaded, do updates
                                pRoot = plugin.DocumentElement
                                ' add attributes found on highest level to vendor list attributes
                                For Each x As XmlAttribute In pRoot.Attributes
                                    vAttrib.Add(x.Name, x.Value)
                                Next
                                ' now go through devices
                                For Each e As XmlElement In pRoot.ChildNodes
                                    If e.Name = "device" Then
                                        ' we've got a device, create a copy
                                        Dim d As XmlDocumentFragment = PluginStore.CreateDocumentFragment()
                                        d.InnerXml = e.OuterXml ' copy xml fragment
                                        ' get the Device ID ('vendor-device') and Vendor ID
                                        DeviceID = e.GetAttribute("id")
                                        VendorID = DeviceID.Split("-"c)(0)

                                        ' Lookup vendor info, and replace with/add current vendor info
                                        For Each vel As XmlElement In elVendors
                                            If vel.GetAttribute("id") = VendorID Then
                                                ' found it, remove it
                                                elVendors.RemoveChild(vel)
                                                Exit For
                                            End If
                                        Next
                                        ' Create new vendor element, with all its attributes
                                        Dim newvendor As XmlElement = PluginStore.CreateElement("vendor")
                                        newvendor.SetAttribute("id", VendorID)
                                        For Each kv As KeyValuePair(Of String, String) In vAttrib
                                            newvendor.SetAttribute(kv.Key, kv.Value)
                                        Next
                                        ' append it
                                        elVendors.AppendChild(newvendor)

                                        ' Lookup device info, and replace with/add current device info
                                        For Each del As XmlElement In elDevices
                                            If del.GetAttribute("id") = DeviceID Then
                                                ' found it, remove it
                                                elDevices.RemoveChild(del)
                                                Exit For
                                            End If
                                        Next
                                        ' append it, the copied element 'd'
                                        elDevices.AppendChild(d)
                                    End If
                                Next
                                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Parsing completed succesfully")
                            Catch ex As Exception
                                LogError("xPLPluginStore.PerformUpdate", "Parsing failed: " & ex.ToString, EventLogEntryType.Error)
                            End Try
                        End If
                        count += 1
                        Me.EventUpdateStatus(CInt(10 + (95 - 10) / total * count))  ' to be calculated correctly
                    End If
                Next
            End If

            ' did we at least have 1 success while downloading ( 0 could mean no connection...)
            If OneSuccess Then
                ' update last update
                pLastUpdate = Now
                ' store in xml, in universal format 'YYYY-MM-DD HH:MM:SSZ'
                PluginMain.SetAttribute("lastupdate", pLastUpdate.ToString("u"))
                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Download & parsing completed")
            Else
                LogError("xPLPluginStore.PerformUpdate", "Update failed, no successfull downloads", EventLogEntryType.Warning)
            End If

            ' Save store if required
            If pSaveStore Then
                Me.EventUpdateStatus(95, "Saving store")
                If Debug Then LogError("xPLPluginStore.PerformUpdate", "Saving pluginstore...")
                Me.SavePluginStore()
            End If

        Catch ex As Exception
            pUpdateRunning = False
            Me.EventUpdateDone()
            LogError("xPLPluginStore.PerformUpdate", "Error: " & ex.ToString)
            Me.ParsePluginStoreToCollections()
            Throw New Exception("Error updating pluginstore", ex)
        End Try

        ' now read pluginstore into devices and vendors collections
        Me.EventUpdateAddLog("Parsing final results")
        Me.EventUpdateStatus(98, "Parsing final results")
        Me.ParsePluginStoreToCollections()
        pUpdateRunning = False
        Me.EventUpdateAddLog("Update finished " & Now.ToShortDateString & " " & Now.ToShortTimeString)
        Me.EventUpdateDone("Done")
        If Debug Then LogError("xPLPluginStore.PerformUpdate", "Completed, exiting.")
    End Sub

    Private Sub ParsePluginStoreToCollections()
        Dim elem As XmlElement
        Dim vendor As xPLPluginVendor
        Dim device As xPLPluginDevice
        Dim id As String
        ' start with vendors
        Me.Vendors.Clear()
        elem = Me.PluginMain("vendors")
        ' loop though all sub-elements of the main vendors element
        For Each v As XmlElement In elem
            If v.Name = "vendor" Then
                id = v.GetAttribute("id")
                vendor = New xPLPluginVendor(id)
                For Each a As XmlAttribute In v.Attributes
                    Select Case a.Name
                        Case "description"
                            vendor.Description = a.Value
                        Case "id"
                            ' do nothing, already set in constructor
                        Case "info_url"
                            vendor.InfoURL = a.Value
                        Case "name"
                            vendor.Name = a.Value
                        Case "plugin_url"
                            vendor.PluginURL = a.Value
                        Case "type"
                            vendor.Type = a.Value
                        Case "url"
                            vendor.URL = a.Value
                        Case "vendor"
                            vendor.Vendor = a.Value
                        Case "version"
                            vendor.VersionStr = a.Value
                        Case Else
                            ' unknown attribute, add to collection
                            vendor.Attributes.Add(v.Name, v.Value)
                    End Select

                Next
                ' Vendor info completed, now add to vendor collection
                Me.Vendors.Add(vendor.ID, vendor)
            End If
        Next

        ' now add devices
        Me.Devices.Clear()
        elem = Me.PluginMain("devices")
        ' loop though all sub-elements of the main devices element
        For Each d As XmlElement In elem
            If d.Name = "device" Then
                id = d.GetAttribute("id")
                device = New xPLPluginDevice(id)
                device.XML = d.InnerXml
                For Each a As XmlAttribute In d.Attributes
                    Select Case a.Name
                        Case "id"
                            ' do nothing, already set in constructor
                        Case "type"
                            device.Type = a.Value
                        Case "download_url"
                            device.URLdownload = a.Value
                        Case "info_url"
                            device.URLinfo = a.Value
                        Case "version"
                            device.VersionStr = a.Value
                        Case "beta-version"
                            device.BetaVersionStr = a.Value
                        Case "platform"
                            device.Platform = a.Value
                        Case "description"
                            device.Platform = a.Value
                        Case Else
                            ' unknown attribute, add to collection
                            device.Attributes.Add(d.Name, d.Value)
                    End Select

                Next
                ' Vendor info completed, now add to vendor collection
                Me.Devices.Add(device.ID, device)
            End If
        Next

    End Sub

#End Region

#Region "Event arguments"
    Private pNextEventArgs As UpdateInfo
    ' Must be called before starting an update
    Private Sub EventUpdateReset()
        pNextEventArgs = New UpdateInfo
    End Sub
    ' Call RaiseNow to raise event and pass info
    Private Sub EventUpdateRaiseNow()
        Dim x As New UpdateInfo
        ' complete the log
        pNextEventArgs.LogComplete += pNextEventArgs.LogUpdate
        ' remove leading vbcrlf if present
        If InStr(pNextEventArgs.LogUpdate, vbCrLf) = 1 Then
            pNextEventArgs.LogUpdate = Mid(pNextEventArgs.LogUpdate, Len(vbCrLf) + 1)
        End If
        If InStr(pNextEventArgs.LogComplete, vbCrLf) = 1 Then
            pNextEventArgs.LogComplete = Mid(pNextEventArgs.LogComplete, Len(vbCrLf) + 1)
        End If
        ' copy current info
        x.PercentComplete = pNextEventArgs.PercentComplete
        x.StatusMsg = pNextEventArgs.StatusMsg
        x.LogUpdate = ""
        x.LogComplete = pNextEventArgs.LogComplete
        x.HasError = False
        ' raise event
        Try
            RaiseEvent UpdateProgress(pNextEventArgs)
        Catch ex As Exception
        End Try
        ' Prepare for next event
        pNextEventArgs = x
    End Sub
    ' Call this one to add text to the log and report an error
    Private Sub EventUpdateAddLog(ByVal message As String, _
                                  Optional ByVal NewLine As Boolean = True, _
                                  Optional ByVal IsError As Boolean = False)
        If NewLine Then
            pNextEventArgs.LogUpdate += vbCrLf & message
        Else
            pNextEventArgs.LogUpdate += message
        End If
        If IsError Then pNextEventArgs.HasError = True
    End Sub
    ' call UpdateStatus to update % complete or status message, will always raise event.
    Private Sub EventUpdateStatus(Optional ByVal PercCompl As Integer = -1, Optional ByVal Status As String = "")
        Dim upd As Boolean = False
        If PercCompl <> -1 Then
            upd = True
            pNextEventArgs.PercentComplete = PercCompl
        End If
        If Status <> "" Then
            upd = True
            pNextEventArgs.StatusMsg = Status
        End If
        If upd Then
            Me.EventUpdateRaiseNow()
        End If
    End Sub
    ' sets completed to 100%, optional status message, will always raise event. Completed event will also be raised.
    Private Sub EventUpdateDone(Optional ByVal Status As String = "")
        If Status <> "" Then
            pNextEventArgs.StatusMsg = Status
        End If
        Me.EventUpdateRaiseNow()
        ' raise event
        Try
            RaiseEvent UpdateComplete(pNextEventArgs)
        Catch ex As Exception
        End Try
    End Sub
#End Region

End Class
