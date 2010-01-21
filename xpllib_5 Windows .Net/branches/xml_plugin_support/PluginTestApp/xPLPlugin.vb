Option Strict On
Imports System.IO
Imports System.Environment
Imports System.Xml
Imports System
Imports System.Threading

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
    ''' Version, source is the vendor provided plugin download
    ''' </summary>
    Public Version As String
    ''' <summary>
    ''' Plugin download URL, source is the vendor provided plugin download
    ''' </summary>
    ''' <remarks>This URL is NOT used, for downloading the central URL is used, see <seealso cref="xPLPluginVendor.URL"/>.</remarks>
    Public PluginURL As String

    ''' <returns>Contains the Vendor ID, as used in the xPL address notation 'vendor-device.instance'</returns>
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
        If strID Is Nothing Then strID = ""
        If strID <> "" Then
            pID = ID
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
    ''' <summary>
    ''' Most recent device version. Source is the vendor specific xml file.
    ''' </summary>
    Public Version As String = "0.0"
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
    ''' Is this device a real xPL device package, or a piece of software that is not a xPL device.
    ''' Source is the vendor specific xml file.
    ''' </summary>
    ''' <remarks>Examples of non-device items are; xPL code libraries, hubs, diagnostic tools, etc.</remarks>
    Public IsDevice As Boolean = True
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
        If strID Is Nothing Then strID = ""
        If strID <> "" Then
            pID = ID
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

    Public URL1 As String = "http://www.xplproject.org.uk/plugins"          ' Main xPL site, by Ian
    Public URL2 As String = "http://www.xPL4Java.org/plugins"               ' Gerry's copy
    Public URL3 As String = "http://www.xplmonkey.com/downloads/plugins"    ' Mal's copy
    Public Extension As String = ".xml"

    Private PluginStore As XmlDocument = Nothing
    Private PluginStoreVersion As String = "1.0"
    Private PluginMain As XmlElement = Nothing        ' Contains the main element in the PluginStore
    Private PluginList As XmlDocument = Nothing       ' Contains last downloaded pluginlist

    Private pSaveStore As Boolean ' should store be saved at end of update?

    ''' <summary>
    ''' Event raised during the update process to inform owner about progress
    ''' </summary>
    ''' <param name="e">Event parameters containing status information</param>
    ''' <remarks></remarks>
    Public Event UpdateProgress(ByVal e As xPLPluginStore.UpdateInfo)

    Private pPluginStoreFile As String = _
        GetFolderPath(SpecialFolder.CommonApplicationData) & "\xPL\xPLLib\PluginStore" & Extension
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
        End Set
    End Property

    Private pUpdateRunning As Boolean = False
    ''' <summary>
    ''' Indicates whether an update is currently running
    ''' </summary>
    ''' <remarks>call <seealso cref="xPLPluginStore.UpdatePluginStore"/> to start an update.</remarks>
    Friend ReadOnly Property UpdateRunning() As Boolean
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
    Friend ReadOnly Property IsLoaded() As Boolean
        Get
            Return pIsLoaded
        End Get
    End Property

    Private pLastUpdate As New Date(2000, 1, 1, 0, 0, 0)
    ''' <summary>
    ''' Returns the date/time the last succesfull update (downloading plugins) was performed.
    ''' </summary>
    Friend ReadOnly Property LastUpdate() As Date
        Get
            Return pLastUpdate
        End Get
    End Property

    ''' <summary>
    ''' Creates a new object and loads the shared pluginstore, if it doesn't exist
    ''' a blank one will be created in memory (not yet written to disk)
    ''' </summary>
    ''' <remarks>Use SavePluginStore to save the store to disk</remarks>
    Friend Sub New()
        pIsLoaded = False
        pLastUpdate = New Date(2000, 1, 1, 0, 0, 0)
        PluginStore = Nothing
        PluginMain = Nothing
        PluginList = Nothing
    End Sub

#Region "Manage PluginStore"

    ''' <summary>
    ''' Loads the shared pluginstore, if it doesn't exist
    ''' a blank one will be created in memory (not yet written to disk)
    ''' </summary>
    ''' <remarks>Use SavePluginStore to save the store to disk</remarks>
    Friend Sub LoadPluginStore()
        Dim s As String
        Dim e As XmlElement

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
            End If
        Catch ex As Exception
            ' Cannot access/create common data directory
            ' do nothing, new one will be created
        End Try

        Try
            ' Load store
            If File.Exists(Me.PluginStoreFile) Then
                PluginStore.Load(Me.PluginStoreFile)
            Else
                ' create new store
                PluginStore = Me.CreateNewPluginStore
            End If
        Catch ex As Exception
            ' Could not load pluginstore, create new one
            PluginStore = Me.CreateNewPluginStore
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
                e = PluginStore.CreateElement(s)
                PluginMain.AppendChild(e)
            End If
        Next

        ' set Loaded property to true
        pIsLoaded = True

        ' set/get LastUpdate
        If PluginMain.GetAttribute("lastupdate") <> "" Then
            pLastUpdate = CDate(PluginMain.GetAttribute("lastupdate"))
        Else
            ' store empty (old) date value
            pLastUpdate = New Date(2000, 1, 1, 0, 0, 0)
            PluginMain.SetAttribute("lastupdate", pLastUpdate.ToString("u"))
        End If
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
        myStore = New XmlDocument
        root = myStore.CreateElement("pluginstore")
        myStore.AppendChild(root)
        root.SetAttribute("version", PluginStoreVersion)
        Return myStore
    End Function

    ''' <summary>
    ''' Stores the PluginStore in memory to disk
    ''' </summary>
    ''' <remarks></remarks>
    Friend Sub SavePluginStore()

        If PluginStore Is Nothing Then Exit Sub

        ' make sure common data directory exists
        Try
            If Not Directory.Exists(Path.GetDirectoryName(pPluginStoreFile)) Then
                Directory.CreateDirectory(Path.GetDirectoryName(pPluginStoreFile))
            End If
        Catch ex As Exception
            ' Cannot access/create common data directory
            Throw ex
        End Try

        Try
            ' Save store
            PluginStore.Save(Me.PluginStoreFile)
        Catch ex As Exception
            ' Could not save pluginstore
            Throw ex
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
        Dim e As String
        Dim iPos As Integer
        Dim elem As XmlElement

        ' get the locations node
        locations = PluginMain.Item("locations")

        ' copy URL's to arraylist
        For Each x As XmlElement In locations
            loclist.Add(x.GetAttribute("url"))
        Next

        ' Add default url's to list, if they are not in there
        If Trim(URL1) <> "" And loclist.IndexOf(URL1) = -1 Then loclist.Add(URL1)
        If Trim(URL2) <> "" And loclist.IndexOf(URL2) = -1 Then loclist.Add(URL2)
        If Trim(URL3) <> "" And loclist.IndexOf(URL3) = -1 Then loclist.Add(URL3)

        ' try getting the list from the locations, top down
        For n = 0 To loclist.Count - 1
            URL = CStr(loclist(n))
            PluginList = New XmlDocument
            Try
                ' try reading xml from url, with extension
                PluginList.Load(URL & Extension)
                Exit For     ' we have one, go exit
            Catch ex As Exception
                ' opening url failed, try again without extension
                Try
                    PluginList.Load(URL)
                    Exit For    ' we have one, go exit
                Catch
                    Me.EventUpdateAddLog("  URL failed: " & URL, True, True)
                    Me.EventUpdateRaiseNow()
                End Try
            End Try
        Next

        If PluginList Is Nothing Then
            ' pluginlist couldn't be downloaded...
            ' error shoud be logged heer
            e = ""
            For Each s As String In loclist
                e += vbCrLf & "    " & s
                e += vbCrLf & "    " & s & Extension
            Next
            MsgBox("xPL Plugin List could not be downloaded from any of the following locations tried;" & e)
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

        End If
    End Sub

    ''' <summary>
    ''' Updates the plugins store, first downloads the plugin list, then downloads all plugins. If the store 
    ''' hasn't been loaded yet, it will be loaded.
    ''' </summary>
    ''' <param name="SaveStore">If <c>True</c>, the store will be saved to the default location. If 
    ''' <c>False</c>, then the store will not be saved but only stored in memory.</param>
    ''' <remarks>The update will be started on a new thread. Check the 
    ''' <seealso cref="xPLPluginStore.UpdateRunning"/> property to check the status.</remarks>
    Friend Sub UpdatePluginStore(Optional ByVal SaveStore As Boolean = True)
        ' check if update is already running
        If pUpdateRunning Then Exit Sub

        '  Create a new thread for the update
        pSaveStore = SaveStore
        Dim myThreadDelegate As New ThreadStart(AddressOf PerformUpdate)
        Dim myThread As New Thread(myThreadDelegate)
        myThread.Start()

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

        pUpdateRunning = True
        Try
            Me.EventUpdateReset()
            Me.EventUpdateAddLog("Starting PluginStore update", False)
            Me.EventUpdateAddLog("Loading PluginStore... ")
            Me.EventUpdateStatus(0, "Loading PluginStore")

            ' If not loaded, load now
            If Not pIsLoaded Then Me.LoadPluginStore()
            Me.EventUpdateAddLog("completed.", False)
            Me.EventUpdateAddLog("Downloading main list... ")
            Me.EventUpdateStatus(5, "Downloading main list")

            elDevices = PluginMain("devices")
            elVendors = PluginMain("vendors")

            ' Download latest plugin list
            Try
                GetPluginList()
            Catch ex As Exception
                ' log error here
                Me.EventUpdateAddLog("Downloading main list failed!")
            End Try
            Me.EventUpdateStatus(10)

            ' Now update the individual plugins
            For Each vendor As XmlElement In PluginList.DocumentElement.ChildNodes
                If vendor.Name = "plugin" Then
                    vAttrib.Clear()
                    Me.EventUpdateAddLog("Downloading plugin by '" & vendor.GetAttribute("name") & "'... ")
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
                        plugin.Load(vURL & Extension)
                        ' if download succeeded, then set OneSuccess to true
                        OneSuccess = True
                        Me.EventUpdateAddLog("Success!", False)
                    Catch
                        Try
                            ' download failed, try again, without extension
                            plugin.Load(vURL)
                            ' if download succeeded, then set OneSuccess to true
                            OneSuccess = True
                            Me.EventUpdateAddLog("Success!", False)
                        Catch
                            Me.EventUpdateAddLog("Failed!", False)
                            Me.EventUpdateAddLog("    Failed URL: " & vURL, , True)

                            MsgBox("Could not download plugin; " & vbCrLf & _
                                   "   Name: " & vAttrib.Item("name") & vbCrLf & _
                                   "   Type: " & vAttrib.Item("type") & vbCrLf & _
                                   "   Description: " & vAttrib.Item("description") & vbCrLf & _
                                   "   Url: " & vAttrib.Item("url"))
                            plugin = Nothing
                        End Try
                    End Try

                    If Not plugin Is Nothing Then
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
                    End If

                    Me.EventUpdateStatus(55)  ' to be calculated correctly
                End If
            Next

            ' did we at least have 1 success while downloading ( 0 could mean no connection...)
            If OneSuccess Then
                ' update last update
                pLastUpdate = Now
                ' store in xml, in universal format 'YYYY-MM-DD HH:MM:SSZ'
                PluginMain.SetAttribute("lastupdate", pLastUpdate.ToString("u"))
            End If

            ' Save store if required
            If pSaveStore Then
                Me.EventUpdateStatus(95, "Saving store")
                Me.SavePluginStore()
            End If

        Catch ex As Exception
            pUpdateRunning = False
            Me.EventUpdateStatus(100)
            Throw ex
        End Try
        pUpdateRunning = False
        Me.EventUpdateAddLog("Update finished " & Now.ToShortDateString & " " & Now.ToShortTimeString)
        Me.EventUpdateStatus(100, "Done")
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
#End Region

End Class
