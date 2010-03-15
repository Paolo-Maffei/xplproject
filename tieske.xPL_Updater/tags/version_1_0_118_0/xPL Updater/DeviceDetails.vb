Public Class DeviceDetails

    Private Sub DeviceDetails_FormClosing(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing
        ' don't close, just hide
        Me.Visible = False
        e.Cancel = True
    End Sub

    Private Sub DeviceDetails_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Me.Icon = xPL_Base.XPL_Icon
    End Sub

    Friend xStore As xPLPluginStore = Nothing
    Private xDevAddr As String = ""

    ''' <summary>
    ''' Set to the device id in format 'vendor-device' to show that id's details on the form
    ''' </summary>
    Friend Property Device() As String
        Get
            Return xDevAddr
        End Get
        Set(ByVal value As String)
            Dim xDev As xPLPluginDevice = Nothing
            Me.Text = "Details: " & value
            xDevAddr = value.Split("."c)(0)
            If Not xStore.Devices.ContainsKey(xDevAddr) Then
                ' unknown device, not listed in store
                tbVendor.Text = xDevAddr.Split("-"c)(0)
                tbDevice.Text = xDevAddr.Split("-"c)(1)
                tbType.Text = "unknown"
                tbVersionStable.Text = "unknown"
                tbVersionBeta.Text = "unknown"
                tbPlatform.Text = "unknown"
                tbDescription.Text = ""
                llblDeviceInfo.Text = "Unavailable"
                llblDownload.Text = "Unavailable"

                If Not xStore.Vendors.ContainsKey(xDevAddr.Split("-"c)(0)) Then
                    ' unknown vendor
                    llblVendorInfo.Text = ""
                Else
                    ' vendor known, get info url
                    llblVendorInfo.Text = xStore.Vendors(xDevAddr.Split("-"c)(0)).InfoURL
                End If
                If llblVendorInfo.Text = "" Then llblVendorInfo.Text = "Unavailable"
            Else
                ' device found in store
                xDev = xStore.Devices(xDevAddr)
                tbVendor.Text = xDevAddr.Split("-"c)(0)
                tbDevice.Text = xDevAddr.Split("-"c)(1)
                tbType.Text = xDev.Type
                tbVersionStable.Text = xDev.VersionStr
                tbVersionBeta.Text = xDev.BetaVersionStr
                tbPlatform.Text = xDev.Platform
                tbDescription.Text = xDev.Description

                llblVendorInfo.Text = xStore.Vendors(xDevAddr.Split("-"c)(0)).InfoURL
                If llblVendorInfo.Text = "" Then llblVendorInfo.Text = "Unavailable"
                If xDev.URLinfo = "" Then
                    llblDeviceInfo.Text = "Unavailable"
                Else
                    llblDeviceInfo.Text = xDev.URLinfo
                End If
                If xDev.URLdownload = "" Then
                    llblDownload.Text = "Unavailable"
                Else
                    llblDownload.Text = xDev.URLdownload
                End If
            End If
        End Set
    End Property

    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        ' don't close, just hide
        Me.Visible = False
    End Sub

    Private Sub llblVendorInfo_LinkClicked(ByVal sender As System.Object, ByVal e As System.Windows.Forms.LinkLabelLinkClickedEventArgs) Handles llblVendorInfo.LinkClicked
        If llblVendorInfo.Text <> "Unavailable" Then
            ' open URL
            Try
                System.Diagnostics.Process.Start(llblVendorInfo.Text)
            Catch ex As Exception
                MsgBox("URL could not be opened.")
            End Try
        End If
    End Sub

    Private Sub llblDeviceInfo_LinkClicked(ByVal sender As System.Object, ByVal e As System.Windows.Forms.LinkLabelLinkClickedEventArgs) Handles llblDeviceInfo.LinkClicked
        If llblDeviceInfo.Text <> "Unavailable" Then
            ' open URL
            Try
                System.Diagnostics.Process.Start(llblDeviceInfo.Text)
            Catch ex As Exception
                MsgBox("URL could not be opened.")
            End Try
        End If
    End Sub

    Private Sub llblDownload_LinkClicked(ByVal sender As System.Object, ByVal e As System.Windows.Forms.LinkLabelLinkClickedEventArgs) Handles llblDownload.LinkClicked
        If llblDownload.Text <> "Unavailable" Then
            ' open URL
            Try
                System.Diagnostics.Process.Start(llblDownload.Text)
            Catch ex As Exception
                MsgBox("URL could not be opened.")
            End Try
        End If
    End Sub
End Class