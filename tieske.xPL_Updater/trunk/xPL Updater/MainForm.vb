Option Strict On

Public Class MainForm

    ''' <summary>
    ''' Constant with the registry location of the installed apps
    ''' </summary>
    ''' <remarks></remarks>
    Private Const RegLocation As String = "Software\xPL"
    ''' <summary>
    ''' xPL device object used for scanning the xPL network
    ''' </summary>
    ''' <remarks></remarks>
    Private xDev As New xPLDevice
    ''' <summary>
    ''' Plugin store object fro downloading latest version information
    ''' </summary>
    ''' <remarks></remarks>
    Private xStore As New xPLPluginStore
    ''' <summary>
    ''' Filepath of the pluginstore (holding downloaded info from plugins by Vendors)
    ''' </summary>
    ''' <remarks></remarks>
    Private xStoreFile As String = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData) & _
                                       IO.Path.DirectorySeparatorChar & "xPL" & IO.Path.DirectorySeparatorChar & _
                                       "xPL Updater" & IO.Path.DirectorySeparatorChar & _
                                       "PluginStore.xml"

    ''' <summary>
    ''' Form showing progress of plugin downloads
    ''' </summary>
    ''' <remarks></remarks>
    Private xStoreForm As New xPLPluginUpdateDlgLog

    ''' <summary>
    ''' Form to display device details
    ''' </summary>
    ''' <remarks></remarks>
    Private frmDeviceDisplay As New DeviceDetails

    ' Class and dictionary to hold the previous state of devices
    Private Class clsOldState
        Public Version As String = ""
        Public Beta As String = ""
        Public Status As String = ""
        Public Sub New(Optional ByVal Version As String = "", Optional ByVal Beta As String = "", Optional ByVal Status As String = "")
            Me.Version = Version
            Me.Beta = Beta
            Me.Status = Status
        End Sub
    End Class
    Private OldStates As New Dictionary(Of String, clsOldState)

#Region "Starting up and closing down"

    Private Sub MainForm_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        ' Set form icon
        Me.Icon = xPL_Base.XPL_Icon

        ' add handlers for detecting devices on the network
        AddHandler xPLNetwork.xPLDeviceFound, AddressOf NetworkEvent
        AddHandler xPLNetwork.xPLDeviceLost, AddressOf NetworkEvent

        ' Setup the xPL Device to be used for scanning
        xDev.VendorID = My.Settings.VendorID
        xDev.DeviceID = My.Settings.DeviceID
        '#If DEBUG Then
        '        xDev.Debug = True
        '#Else
        xDev.Debug = False
        '#End If
        xDev.InstanceIDType = xPL_Base.InstanceCreation.HostNameBased
        xDev.Configurable = False
        AddHandler xDev.xPLStatusChange, AddressOf DeviceStateChange

        ' Plugin updater
        AddHandler xStore.UpdateComplete, AddressOf xStoreUpdated
        xStore.PluginStoreFile = xStoreFile     ' set file to be used
        xStore.LoadPluginStore()                ' load file into store
        ' Build collection with Old states
        BuildOldStateCollection()
        ControlUpdatePlugin()                   ' update controls based upon current store contents
        xStore.UpdatePluginStore(False)         ' start the plugin download
        btnClearFlags.Enabled = False           ' disable button while update runs
        xStoreForm.Plugin = xStore
        xStoreForm.Show()                       ' show the progress form with logging

        ' Setup device display form
        frmDeviceDisplay.xStore = xStore

        ' Get locally installed devices from registry
        LoadRegistryApps()

        ' config done, now go and start it up
        xDev.Enable()
    End Sub

    Private Sub MainForm_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        ' cleanup device display form
        If frmDeviceDisplay.Visible Then frmDeviceDisplay.Close()
        frmDeviceDisplay.xStore = Nothing
        frmDeviceDisplay = Nothing

        ' cleanup update form if shown
        If Not xStoreForm Is Nothing Then xStoreForm.Close()
        xStoreForm = Nothing

        ' save and close store
        RemoveHandler xStore.UpdateComplete, AddressOf xStoreUpdated
        xStore.SavePluginStore()
        xStore = Nothing

        ' remove handlers for detecting devices on the network
        RemoveHandler xPLNetwork.xPLDeviceFound, AddressOf NetworkEvent
        RemoveHandler xPLNetwork.xPLDeviceLost, AddressOf NetworkEvent

        ' cleanup xPL device
        RemoveHandler xDev.xPLStatusChange, AddressOf DeviceStateChange
        xDev.Disable()
        xDev.Dispose()
    End Sub

#End Region

#Region "Manage xPL device state changes"

    ''' <summary>
    ''' Event handler for state changes of the xPL device object, indicating on/offline status
    ''' </summary>
    Friend Sub DeviceStateChange(ByVal x As xPLDevice, _
                                 ByVal oldState As xPL_Base.xPLDeviceStatus, _
                                 ByVal newState As xPL_Base.xPLDeviceStatus)
        ' when status changes to online, immediately request a heartbeat
        If newState = xPL_Base.xPLDeviceStatus.Online Then
            xPLNetwork.RequestHeartbeat(xDev)
        End If
        ' Update status label
        If Me.lblxPLstatus.InvokeRequired Then
            Dim d As dUpdateStatusLabel
            d = AddressOf UpdateStatusLabel
            Me.lblxPLstatus.Invoke(d, newState)
        Else
            UpdateStatusLabel(newState)
        End If
    End Sub
    Private Delegate Sub dUpdateStatusLabel(ByVal newState As xPL_Base.xPLDeviceStatus)
    Friend Sub UpdateStatusLabel(ByVal newState As xPL_Base.xPLDeviceStatus)
        Select Case newState
            Case xPL_Base.xPLDeviceStatus.Offline
                lblxPLstatus.Text = "xPL status: Offline"
            Case xPL_Base.xPLDeviceStatus.Connecting
                lblxPLstatus.Text = "xPL status: Connecting..."
            Case xPL_Base.xPLDeviceStatus.Online
                lblxPLstatus.Text = "xPL status: Online"
        End Select
    End Sub
#End Region

#Region "Plugin store updating"

    ''' <summary>
    ''' Event handler for the pluginstore.updatecomplete event
    ''' </summary>
    Friend Sub xStoreUpdated(ByVal e As xPLPluginStore.UpdateInfo)
        Dim attr As Xml.XmlAttribute
        ' After the update, the OldState info has been removed from the xml by the update process.
        ' Add the OldState info back into the xml, loop through all elements within 'Devices'
        For Each dev As Xml.XmlNode In xStore.DevicesXmlElement.ChildNodes
            If dev.NodeType = Xml.XmlNodeType.Element Then
                If dev.Name = "device" Then
                    If OldStates.ContainsKey(dev.Attributes("id").Value) Then
                        ' we now have a device element, and there is a matching OldState, update attributes

                        ' version
                        attr = CType(dev.Attributes.GetNamedItem("tieske-updater-version"), Xml.XmlAttribute)
                        If attr Is Nothing Then
                            ' create a new attribute and append it
                            attr = dev.OwnerDocument.CreateAttribute("tieske-updater-version")
                            dev.Attributes.Append(attr)
                        End If
                        ' store the value
                        attr.Value = OldStates.Item(dev.Attributes("id").Value).Version

                        ' beta
                        attr = CType(dev.Attributes.GetNamedItem("tieske-updater-beta"), Xml.XmlAttribute)
                        If attr Is Nothing Then
                            ' create a new attribute and append it
                            attr = dev.OwnerDocument.CreateAttribute("tieske-updater-beta")
                            dev.Attributes.Append(attr)
                        End If
                        ' store the value
                        attr.Value = OldStates.Item(dev.Attributes("id").Value).Beta

                        ' status
                        attr = CType(dev.Attributes.GetNamedItem("tieske-updater-status"), Xml.XmlAttribute)
                        If attr Is Nothing Then
                            ' create a new attribute and append it
                            attr = dev.OwnerDocument.CreateAttribute("tieske-updater-status")
                            dev.Attributes.Append(attr)
                        End If
                        ' store the value
                        attr.Value = OldStates.Item(dev.Attributes("id").Value).Status
                    End If
                End If
            End If
        Next

        ' save file
        xStore.SavePluginStore()
        ' Go update controls with latest info
        If Me.InvokeRequired Then
            Dim d As dControlUpdatePlugin
            d = AddressOf ControlUpdatePlugin
            Me.Invoke(d)
        Else
            ControlUpdatePlugin()
        End If
    End Sub
    Private Delegate Sub dControlUpdatePlugin()
    Friend Sub ControlUpdatePlugin()
        Dim completed As Boolean = False
        ' Go update controls with latest info
        lblLastUpdate.Text = "Last update: " & xStore.LastUpdate.ToShortDateString & " " & xStore.LastUpdate.ToShortTimeString

        ' Go update rows of installed devices
        While Not completed
            ' use a while loop because if the collection of rows changes, it will result in an exception, the
            ' loop will just retry updating again, until succesfull
            Try
                For Each row As DataGridViewRow In dgInstalled.Rows
                    Try
                        UpdateDeviceRow(row, CStr(row.Cells("insAddress").Value))
                    Catch ex As Exception
                    End Try
                Next
                completed = True
            Catch ex As Exception
                completed = False
            End Try
        End While
        ' update done, so enable button to clear flags
        If Not xStore.UpdateRunning Then
            btnClearFlags.Enabled = True
        End If
        ' Go update rows of available software
        UpdateAvailableGrid()
    End Sub

    Private Sub UpdateAvailableGrid()
        Dim ico As System.Drawing.Icon
        Dim old As clsOldState
        Dim row As DataGridViewRow = Nothing
        'loop through all devices in the pluginstore
        For Each d As KeyValuePair(Of String, xPLPluginDevice) In xStore.Devices
            ' lookup device in the datagrid, try find row
            For Each row In dgAvailable.Rows
                If CStr(row.Cells("avID").Value) = d.Key Then
                    ' found its row
                    Exit For
                End If
                row = Nothing
            Next
            If row Is Nothing Then
                ' if no row found, then add a row with current ID
                row = dgAvailable.Rows(dgAvailable.Rows.Add)
                row.Cells("avID").Value = d.Key
            End If

            ' we have a row, now fill it with the (updated) data
            ico = My.Resources.OkIcon       ' default
            If OldStates.ContainsKey(d.Key) Then
                ' Key was already present last time
                old = OldStates.Item(d.Key)
                Select Case old.Status
                    Case "added"
                        ico = My.Resources.AddedIcon
                    Case "ok"
                        ico = My.Resources.OkIcon
                        If Not VersionEqual(old.Version, d.Value.VersionStr) Or _
                               (Not VersionEqual(old.Beta, d.Value.BetaVersionStr) And d.Value.BetaVersionStr <> "0.0") Then
                            ' Version info changed, so its updated
                            ico = My.Resources.UpdateIcon
                        End If
                    Case "updated"
                        ico = My.Resources.UpdateIcon
                End Select
            Else
                ' no such key found, so its new
                ico = My.Resources.AddedIcon
            End If
            row.Cells("avIcon").Value = ico
            row.Cells("avDescription").Value = d.Value.Description
            row.Cells("avVersion").Value = d.Value.VersionStr
            row.Cells("avBeta").Value = d.Value.BetaVersionStr
            row.Cells("avPlatform").Value = d.Value.Platform
            row.Cells("avType").Value = d.Value.Type
            If CStr(row.Cells("avVersion").Value) = "0.0" Then
                row.Cells("avVersion").Value = "unknown"
            End If
            If CStr(row.Cells("avBeta").Value) = "0.0" Then
                row.Cells("avBeta").Value = ""
            End If

        Next
    End Sub

    Private Sub BuildOldStateCollection()
        Dim s1 As String
        Dim s2 As String
        Dim s3 As String
        OldStates.Clear()
        For Each d As xPLPluginDevice In xStore.Devices.Values
            s1 = "0.0"
            s2 = "0.0"
            s3 = "added"
            If d.Attributes.ContainsKey("tieske-updater-version") Then s1 = d.Attributes.Item("tieske-updater-version")
            If d.Attributes.ContainsKey("tieske-updater-beta") Then s2 = d.Attributes.Item("tieske-updater-beta")
            If d.Attributes.ContainsKey("tieske-updater-status") Then s3 = d.Attributes.Item("tieske-updater-status")
            OldStates.Add(d.ID, New clsOldState(s1, s2, s3))
        Next
    End Sub
#End Region

#Region "Installed applications and network scanning"

    ''' <summary>
    ''' Event handler for the device found and device lost events of the xplnetwork object
    ''' </summary>
    Friend Sub NetworkEvent(ByVal e As xPLNetwork.xPLNetworkEventArgs)
        ' go update the controls to reflect the changes
        Debug.Print("network device event: " & e.ExtDevice.Address.ToString)
        If Me.InvokeRequired Then
            Dim d As dControlUpdateDevice
            d = AddressOf ControlUpdateDevice
            Me.Invoke(d, e)
        Else
            ControlUpdateDevice(e)
        End If
    End Sub
    Private Delegate Sub dControlUpdateDevice(ByVal e As xPLNetwork.xPLNetworkEventArgs)
    Friend Sub ControlUpdateDevice(ByVal e As xPLNetwork.xPLNetworkEventArgs)
        Dim row As DataGridViewRow = Nothing

        ' do not add myself (as device) to the list, add myself through registry settings
        If e.ExtDevice.Address.FullAddress = xDev.Address Then Exit Sub

        If e.ExtDevice.Ended Or e.ExtDevice.TimedOut Then
            ' Device was removed from the network
            For n As Integer = 0 To dgInstalled.RowCount - 1
                row = dgInstalled.Rows(n)
                If CStr(row.Cells(1).Value) = e.ExtDevice.Address.FullAddress Then
                    ' found the row of the deleted item, remove it and exit loop
                    dgInstalled.Rows.RemoveAt(n)
                    Exit For
                End If
                row = Nothing
            Next
        Else
            ' Device is new to the network
            For n As Integer = 0 To dgInstalled.RowCount - 1
                row = dgInstalled.Rows(n)
                If CStr(row.Cells("insAddress").Value) = e.ExtDevice.Address.FullAddress Then
                    ' found the row of the added item, its already here
                    Exit For
                End If
                row = Nothing
            Next
            If row Is Nothing Then
                ' no existing row, so add one
                row = dgInstalled.Rows(dgInstalled.Rows.Add())
            End If
            ' update data
            UpdateDeviceRow(row, e.ExtDevice.Address.FullAddress)
        End If
    End Sub
    ''' <summary>
    ''' Updates a single datagrid row with the most up to date values
    ''' </summary>
    Private Sub UpdateDeviceRow(ByVal row As DataGridViewRow, ByVal addr As String)
        Dim xStoreDev As xPLPluginDevice = Nothing
        With row
            .Cells("insAddress").Value = addr

            If InStr(addr, ".(local installation)") = 0 Then
                ' add values from the network
                If xPLNetwork.IndexOf(addr) = -1 Then
                    ' device not found
                    .Cells("insVersion").Value = "unknown"
                Else
                    ' device found
                    If xPLNetwork.Devices(addr).HeartBeatItems.IndexOf("version") = -1 Then
                        ' version heartbeat item not found
                        .Cells("insVersion").Value = "unknown"
                    Else
                        ' version found, fill value
                        .Cells("insVersion").Value = xPLNetwork.Devices(addr).HeartBeatItems("version")
                    End If
                End If
                If CStr(.Cells("insVersion").Value) = "0.0" Then
                    .Cells("insVersion").Value = "unknown"
                End If
            End If

            ' Add values from pluginstore
            If Not xStore.Devices.TryGetValue(addr.Split("."c)(0), xStoreDev) Then
                ' key not found
                .Cells("insDescription").Value = "not found"
                .Cells("insLatest").Value = "0.0"
                .Cells("insBeta").Value = "0.0"
            Else
                ' device found
                .Cells("insDescription").Value = xStoreDev.Description
                .Cells("insLatest").Value = xStoreDev.VersionStr
                .Cells("insBeta").Value = xStoreDev.BetaVersionStr
            End If

            ' Update empty version values
            If CStr(.Cells("insLatest").Value) = "0.0" Then
                .Cells("insLatest").Value = "unknown"
            End If
            If CStr(.Cells("insBeta").Value) = "0.0" Then
                .Cells("insBeta").Value = ""
            End If

            ' update icon
            If VersionEqual(CStr(.Cells("insVersion").Value), CStr(.Cells("insLatest").Value)) Then
                ' latest stable version
                If CStr(.Cells("insBeta").Value) = "" Then
                    ' latest stable, and no beta version, is OK
                    .Cells("insIcon").Value = My.Resources.OkIcon
                Else
                    ' latest stable, but beta version available, is UPDATE
                    .Cells("insIcon").Value = My.Resources.UpdateIcon
                End If
            Else
                ' different from latest version
                If CStr(.Cells("insBeta").Value) <> "" And _
                   VersionEqual(CStr(.Cells("insVersion").Value), CStr(.Cells("insBeta").Value)) Then
                    ' latest beta version, is OK
                    .Cells("insIcon").Value = My.Resources.OkIcon
                Else
                    ' not latest, but also not latest beta, is UPDATE
                    .Cells("insIcon").Value = My.Resources.UpdateIcon
                End If
            End If
            ' check if it exists in our store at all
            If Not xStore.Devices.TryGetValue(addr.Split("."c)(0), xStoreDev) Then
                .Cells("insIcon").Value = My.Resources.QuestionIcon
            End If
        End With
    End Sub

    Friend Sub LoadRegistryApps()
        Dim xPLKey As RegistryKey = Nothing
        Dim VendorKey As RegistryKey = Nothing
        Dim DeviceKey As RegistryKey = Nothing
        Dim ValueNames As String()
        Dim ValueName As String
        Dim row As DataGridViewRow = Nothing
        Dim v As String
        Dim a As String
        Try
            ' open main xPL reg key
            xPLKey = Registry.LocalMachine.OpenSubKey(RegLocation)
            ' Loop through all sub keys (vendors)
            For Each subKeyName As String In xPLKey.GetSubKeyNames()
                Try
                    VendorKey = xPLKey.OpenSubKey(subKeyName)
                    ' Loop through all sub keys (devices)
                    For Each subKeyName2 As String In VendorKey.GetSubKeyNames()
                        Try
                            DeviceKey = VendorKey.OpenSubKey(subKeyName2)
                            ValueNames = DeviceKey.GetValueNames
                            ' Get the correct casing of the "version" value
                            ValueName = "version"
                            For Each s As String In ValueNames
                                If s.ToLower = ValueName Then
                                    ' found a case insensitive match, pick this one and exit loop
                                    ValueName = s
                                    Exit For
                                End If
                            Next
                            ' now get "version" value
                            v = Trim(CStr(DeviceKey.GetValue(ValueName, "")))
                            If xPL_Base.IsValidxPL(subKeyName.ToLower, 1, 8, xPL_Base.XPL_STRING_TYPES.VendorAndDevice) And _
                               xPL_Base.IsValidxPL(subKeyName2.ToLower, 1, 8, xPL_Base.XPL_STRING_TYPES.VendorAndDevice) Then
                                a = subKeyName.ToLower & "-" & subKeyName2.ToLower & ".(local installation)"
                                ' Vendor and device IDs are both valid xPL names, so register a row for this one
                                For n As Integer = 0 To dgInstalled.RowCount - 1
                                    row = dgInstalled.Rows(n)
                                    If CStr(row.Cells("insAddress").Value) = a Then
                                        ' found the row of the added item, its already here
                                        Exit For
                                    End If
                                    row = Nothing
                                Next
                                If row Is Nothing Then
                                    ' no existing row, so add one
                                    row = dgInstalled.Rows(dgInstalled.Rows.Add())
                                End If
                                ' update data
                                row.Cells("insVersion").Value = v
                                UpdateDeviceRow(row, a)

                            End If

                        Catch ex As Exception
                        Finally
                            ' close key if opened
                            If Not DeviceKey Is Nothing Then
                                DeviceKey.Close()
                                DeviceKey = Nothing
                            End If
                        End Try
                    Next
                Catch ex As Exception
                Finally
                    ' close key if opened
                    If Not VendorKey Is Nothing Then
                        VendorKey.Close()
                        VendorKey = Nothing
                    End If
                End Try
            Next
        Catch ex As Exception
        Finally
            ' close key if opened
            If Not xPLKey Is Nothing Then
                xPLKey.Close()
                xPLKey = Nothing
            End If
        End Try

    End Sub
#End Region

#Region "Details form"

    ' Double click on datagrids, open details form with selection
    Private Sub dgAvailable_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles dgAvailable.DoubleClick
        If dgAvailable.SelectedRows.Count <> 0 Then
            ' Display form if not already shown
            If Not frmDeviceDisplay.Visible Then frmDeviceDisplay.Show()
            ' update details
            dgAvailable_SelectionChanged(sender, e)
        End If
    End Sub
    Private Sub dgInstalled_DoubleClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles dgInstalled.DoubleClick
        If dgInstalled.SelectedRows.Count <> 0 Then
            ' Display form if not already shown
            If Not frmDeviceDisplay.Visible Then frmDeviceDisplay.Show()
            ' update details
            dgInstalled_SelectionChanged(sender, e)
        End If
    End Sub

    ' selection changed in datagrid, display newly selected device in details form
    Private Sub dgAvailable_SelectionChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles dgAvailable.SelectionChanged
        If dgAvailable.SelectedRows.Count = 0 Then
            ' there are no rows, so do nothing, no update
        Else
            ' update form contents
            Try
                Dim addr As String = CStr(dgAvailable.SelectedRows(0).Cells("avID").Value)
                frmDeviceDisplay.Device = addr
            Catch ex As Exception
            End Try
        End If
    End Sub
    Private Sub dgInstalled_SelectionChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles dgInstalled.SelectionChanged
        If dgInstalled.SelectedRows.Count = 0 Then
            ' there are no rows, so do nothing, no update
        Else
            ' update form contents
            Try
                Dim addr As String = CStr(dgInstalled.SelectedRows(0).Cells("insAddress").Value)
                frmDeviceDisplay.Device = addr
            Catch ex As Exception
            End Try
        End If
    End Sub
#End Region

#Region "Searching"

    Private Sub btnClearSearch_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClearSearch.Click
        tbSearch.Text = ""
    End Sub

    Private Sub tbSearch_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles tbSearch.TextChanged
        Dim s As String = tbSearch.Text
        Dim l() As String
        ' clean up search string
        s = Replace(s, ",", " ")
        While InStr(s, "  ") <> 0
            Replace(s, "  ", " ")
        End While
        s = Trim(s)
        l = s.Split(" "c)

        ' start by hiding all rows, unless no search string, then show all
        For Each row As DataGridViewRow In dgAvailable.Rows
            row.Visible = (s = "")
        Next
        For Each row As DataGridViewRow In dgInstalled.Rows
            row.Visible = (s = "")
        Next

        ' If a search string has been set, unhide the matches
        If s <> "" Then
            For Each si In l
                For Each row As DataGridViewRow In dgAvailable.Rows
                    If InStr(CStr(row.Cells("avID").Value) & " " & _
                                 CStr(row.Cells("avDescription").Value) & " " & _
                                 CStr(row.Cells("avType").Value) & " " & _
                                 CStr(row.Cells("avPlatform").Value), si, CompareMethod.Text) <> 0 Then
                        row.Visible = True
                    End If
                Next
                For Each row As DataGridViewRow In dgInstalled.Rows
                    If InStr(CStr(row.Cells("insAddress").Value) & " " & _
                                 CStr(row.Cells("insDescription").Value), _
                                 si, CompareMethod.Text) <> 0 Then
                        row.Visible = True
                    End If
                Next
            Next
        End If
    End Sub


#End Region


    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.Close()
    End Sub

    Private Sub btnDetails_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDetails.Click
        ' Display form if not already shown
        If Not frmDeviceDisplay.Visible Then frmDeviceDisplay.Show()
    End Sub

    Private Sub btnCheckUpdates_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCheckUpdates.Click
        ' send heartbeat request
        xPLNetwork.RequestHeartbeat(xDev)
        MsgBox("A heartbeat request has been send to scan the xPL network")
    End Sub

    Private Sub btnAbout_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAbout.Click
        Dim dlg As New About
        dlg.Icon = xPL_Base.XPL_Icon
        dlg.ShowDialog()
    End Sub

    ''' <summary>
    ''' Clears the status based on the OldStates collection, by updating the OldStates collection
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Sub btnClearFlags_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClearFlags.Click
        Dim Attr As Xml.XmlAttribute

        If MsgBoxResult.Ok = MsgBox("Are you sure you want to clear all current update flags?", MsgBoxStyle.OkCancel Or MsgBoxStyle.Question Or MsgBoxStyle.DefaultButton1, "Clear update flags?") Then

            ' loop through all devices and update them
            For Each d As xPLPluginDevice In xStore.Devices.Values

                ' update version to current one
                If Not d.Attributes.ContainsKey("tieske-updater-version") Then d.Attributes.Add("tieske-updater-version", "")
                d.Attributes.Item("tieske-updater-version") = d.VersionStr

                ' update beta to current one
                If Not d.Attributes.ContainsKey("tieske-updater-beta") Then d.Attributes.Add("tieske-updater-beta", "")
                d.Attributes.Item("tieske-updater-beta") = d.BetaVersionStr

                ' update status to "ok"
                If Not d.Attributes.ContainsKey("tieske-updater-status") Then d.Attributes.Add("tieske-updater-status", "")
                d.Attributes.Item("tieske-updater-status") = "ok"

            Next

            ' Now update the xml file, loop through all elements within 'Devices'
            For Each dev As Xml.XmlNode In xStore.DevicesXmlElement.ChildNodes
                If dev.NodeType = Xml.XmlNodeType.Element Then
                    If dev.Name = "device" Then
                        ' we now have a device element, update attributes

                        ' version
                        Attr = CType(dev.Attributes.GetNamedItem("tieske-updater-version"), Xml.XmlAttribute)
                        If Attr Is Nothing Then
                            ' create a new attribute and append it
                            Attr = dev.OwnerDocument.CreateAttribute("tieske-updater-version")
                            dev.Attributes.Append(Attr)
                        End If
                        ' store the value
                        Attr.Value = xStore.Devices(dev.Attributes("id").Value).Attributes("tieske-updater-version")

                        ' beta
                        Attr = CType(dev.Attributes.GetNamedItem("tieske-updater-beta"), Xml.XmlAttribute)
                        If Attr Is Nothing Then
                            ' create a new attribute and append it
                            Attr = dev.OwnerDocument.CreateAttribute("tieske-updater-beta")
                            dev.Attributes.Append(Attr)
                        End If
                        ' store the value
                        Attr.Value = xStore.Devices(dev.Attributes("id").Value).Attributes("tieske-updater-beta")

                        ' status
                        Attr = CType(dev.Attributes.GetNamedItem("tieske-updater-status"), Xml.XmlAttribute)
                        If Attr Is Nothing Then
                            ' create a new attribute and append it
                            Attr = dev.OwnerDocument.CreateAttribute("tieske-updater-status")
                            dev.Attributes.Append(Attr)
                        End If
                        ' store the value
                        Attr.Value = xStore.Devices(dev.Attributes("id").Value).Attributes("tieske-updater-status")
                    End If
                End If
            Next

            ' build colection based upon current xStore content
            BuildOldStateCollection()
            ' Update display
            UpdateAvailableGrid()
        End If
    End Sub

    Private Sub btnHelp_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnHelp.Click
        Dim frm As New HelpForm
        frm.ShowDialog()
    End Sub

    Private Function VersionEqual(ByVal v1 As String, ByVal v2 As String) As Boolean
        ' strings must contain at least 3 decimal dots
        While Len(v1) - Len(v1.Replace("."c, "")) < 3
            v1 += ".0"
        End While
        While Len(v2) - Len(v2.Replace("."c, "")) < 3
            v2 += ".0"
        End While
        ' now compare version strings
        Return (v1 = v2)
    End Function
End Class
