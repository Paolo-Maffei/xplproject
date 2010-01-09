Option Strict On
Imports xPL
Imports xPL.xPL_Base
Imports Microsoft
Imports Microsoft.VisualBasic

Public Class UnitInterface

    Friend xdev As xPL.xPLDevice = Nothing
    Friend ConfigCurrent As xPL.xPLMessage = Nothing
    Friend ConfigList As xPL.xPLMessage = Nothing
    Friend ExtDev As xPL.xPLExtDevice = Nothing

    Private Function GetECIvalue(ByVal param As String) As String
        ' read the concatenated value of a CI's valuemlist
        Dim n As Integer
        Dim s As String = ""
        Dim eci As xPL.xPLExtConfigItem
        Try
            s = ""
            eci = ExtDev(param)
            For n = 0 To eci.Count - 1
                s += eci(n)
            Next
        Catch ex As Exception
        End Try
        Return s
    End Function

    Private Sub UnitInterface_Shown(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Shown
        Dim eci As xPLExtConfigItem
        ' set form icon
        Me.Icon = XPL_Icon
        ' set dialog title
        Me.Text = ConfigCurrent.Source
        ' Get config info
        ExtDev = xPL.xPLNetwork.Devices(ConfigList.Source)
        ' fill dialog
        Me.tbNewConf.Text = GetECIvalue("newconf")
        Me.tbInterval.Value = CInt(GetECIvalue("interval"))
        Me.tbSMSurl.Text = GetECIvalue("urlsend")
        Me.tbSMSresponse.Text = GetECIvalue("lookfor")
        Me.rbSuccess.Checked = (GetECIvalue("lookfors") = "yes")
        Me.rbFailure.Checked = (GetECIvalue("lookfors") <> "yes")
        Me.tbCreditURL.Text = GetECIvalue("urlcred")
        Me.tbDelimStart.Text = GetECIvalue("crstart")
        Me.tbDelimEnd.Text = GetECIvalue("crend")
        ' add groups
        If ExtDev.IndexOf("group") <> -1 Then
            eci = ExtDev("group")
            For n = 0 To eci.Count - 1
                Me.lbGroups.Items.Add(eci(n))
            Next
        End If
        ' add filters
        If ExtDev.IndexOf("filter") <> -1 Then
            eci = ExtDev("filter")
            For n = 0 To eci.Count - 1
                Me.lbFilters.Items.Add(eci(n))
            Next
        End If
    End Sub

    Private Sub btnCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        Me.Close()
    End Sub

    Private Sub btnOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnOK.Click
        ' go update stuff here
        Dim xResp As New xPL.xPLMessage
        Dim s As String

        xResp.MsgType = xPL.xPL_Base.xPLMessageTypeEnum.Command
        xResp.Source = xdev.Address
        xResp.Target = ExtDev.Address.ToString
        xResp.Schema = "config.response"

        xResp.KeyValueList.Add("newconf", tbNewConf.Text)
        xResp.KeyValueList.Add("interval", CStr(tbInterval.Value))
        For n = 0 To lbGroups.Items.Count - 1
            xResp.KeyValueList.Add("group", CStr(lbGroups.Items(n)))
        Next
        For n = 0 To lbFilters.Items.Count - 1
            xResp.KeyValueList.Add("filter", CStr(lbFilters.Items(n)))
        Next
        s = VisualBasic.Left(Me.tbSMSurl.Text, 3 * 127)  ' maximize to 3 values
        While s <> ""
            xResp.KeyValueList.Add("urlsend", VisualBasic.Left(s, 127))
            s = VisualBasic.Mid(s, 128)
        End While
        xResp.KeyValueList.Add("lookfor", VisualBasic.Left(Me.tbSMSresponse.Text, 127))
        If Me.rbSuccess.Checked Then
            xResp.KeyValueList.Add("lookfors", "yes")
        Else
            xResp.KeyValueList.Add("lookfors", "no")
        End If

        s = VisualBasic.Left(Me.tbCreditURL.Text, 3 * 127)  ' maximize to 3 values
        While s <> ""
            xResp.KeyValueList.Add("urlcred", VisualBasic.Left(s, 127))
            s = VisualBasic.Mid(s, 128)
        End While

        xResp.KeyValueList.Add("crstart", VisualBasic.Left(Me.tbDelimStart.Text, 127))
        xResp.KeyValueList.Add("crend", VisualBasic.Left(Me.tbDelimEnd.Text, 127))

        ' send message
        xResp.Send()

        Me.Close()
    End Sub

    Private Sub tbNewConf_Validating(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles tbNewConf.Validating
        tbNewConf.Text = tbNewConf.Text.ToLower
        If Not IsValidxPL(tbNewConf.Text.ToLower, 1, 16, XPL_STRING_TYPES.OtherElements) Then
            e.Cancel = True
            MsgBox("A valid Instance has a length between 1 and 16 characters and may only contain the following " & _
                   "characters: " & XPL_ALLOWED_ELEMENTS, MsgBoxStyle.Information)
        End If
    End Sub

    Private Sub tbGroup_Validating(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles tbGroup.Validating
        If Not IsValidxPL(tbGroup.Text.ToLower, 0, 16, XPL_STRING_TYPES.OtherElements) Then
            e.Cancel = True
            MsgBox("A valid Group has a length between 1 and 16 characters and may only contain the following " & _
                   "characters: " & XPL_ALLOWED_ELEMENTS, MsgBoxStyle.Information)
        End If
    End Sub

    Private Sub btnAddGroup_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAddGroup.Click
        If tbGroup.Text <> "" Then
            If lbGroups.Items.IndexOf("xpl-group." & tbGroup.Text.ToLower) = -1 Then
                lbGroups.Items.Add("xpl-group." & tbGroup.Text.ToLower)
                tbGroup.Text = ""
            Else
                MsgBox("Value is already present in the list", MsgBoxStyle.Information)
                tbGroup.Text = ""
            End If
        Else
            MsgBox("Please enter a valid Group name first", MsgBoxStyle.Information)
        End If
    End Sub

    Private Sub btnRemoveGroup_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnRemoveGroup.Click
        If Not lbGroups.SelectedItem Is Nothing Then
            If MsgBox("Are you sure you want to remove the group '" & CStr(lbGroups.SelectedItem) & "' from the group list?", _
                      MsgBoxStyle.Question Or MsgBoxStyle.OkCancel Or MsgBoxStyle.DefaultButton2) = MsgBoxResult.Ok Then
                lbGroups.Items.Remove(lbGroups.SelectedItem)
            End If
        Else
            MsgBox("Please select a Group from the list first", MsgBoxStyle.Information)
        End If
    End Sub

    Private Sub tbFilter_Validating(ByVal sender As Object, ByVal e As System.ComponentModel.CancelEventArgs) Handles tbFilter.Validating
        Dim flt As xPLFilter
        If tbFilter.Text <> "" Then
            Try
                flt = New xPLFilter(tbFilter.Text)
            Catch ex As Exception
                MsgBox("Please enter a valid Filter value. A valid Filter consists of 6 elements, " & _
                "separated by '.' (dot) characters." & vbCrLf & _
                "1st part, messagetype: can be either '*', 'xpl-cmnd', 'xpl-trig', or 'xpl-stat'" & vbCrLf & _
                "2nd part, vendor: can be either '*', or a value of 3 to 8 in length and containing only; " & XPL_ALLOWED_VENDOR_DEVICE & vbCrLf & _
                "3rd part, device: can be either '*', or a value of 1 to 8 in length and containing only; " & XPL_ALLOWED_VENDOR_DEVICE & vbCrLf & _
                "4th part, instance: can be either '*', or a value of 1 to 16 in length and containing only; " & XPL_ALLOWED_ELEMENTS & vbCrLf & _
                "5th part, schema class: can be either '*', or a value of 1 to 8 in length and containing only; " & XPL_ALLOWED_ELEMENTS & vbCrLf & _
                "6th part, schema type: can be either '*', or a value of 1 to 8 in length and containing only; " & XPL_ALLOWED_ELEMENTS & vbCrLf & _
                vbCrLf & "Example: 'xpl-stat.*.*.*.sendmsg.*'")
                e.Cancel = True
            End Try
        End If
    End Sub

    Private Sub btnAddFilter_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnAddFilter.Click
        Dim flt As xPLFilter
        Try
            flt = New xPLFilter(tbFilter.Text)
            If lbFilters.Items.IndexOf(flt.ToString) = -1 Then
                If flt.ToString = "*.*.*.*.*.*" Then
                    MsgBox("There is no use for this filter, this is the same as using no filter at all", MsgBoxStyle.Information)
                Else
                    lbFilters.Items.Add(flt.ToString)
                End If
                tbFilter.Text = ""
            Else
                MsgBox("Value is already present in the list", MsgBoxStyle.Information)
                tbFilter.Text = ""
            End If
        Catch ex As Exception
            MsgBox("Please enter a valid Filter first", MsgBoxStyle.Information)
        End Try
    End Sub

    Private Sub btnRemoveFilter_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnRemoveFilter.Click
        If Not lbFilters.SelectedItem Is Nothing Then
            If MsgBox("Are you sure you want to remove the filter '" & CStr(lbFilters.SelectedItem) & "' from the filter list?", _
                      MsgBoxStyle.Question Or MsgBoxStyle.OkCancel Or MsgBoxStyle.DefaultButton2) = MsgBoxResult.Ok Then
                lbFilters.Items.Remove(lbFilters.SelectedItem)
            End If
        Else
            MsgBox("Please select a Filter from the list first", MsgBoxStyle.Information)
        End If
    End Sub

    Private Sub SMSurlInsert(ByVal ph As String)
        Dim s1 As String = VisualBasic.Left(tbSMSurl.Text, tbSMSurl.SelectionStart)
        Dim s2 As String = VisualBasic.Mid(tbSMSurl.Text, tbSMSurl.SelectionStart + tbSMSurl.SelectionLength + 1)
        tbSMSurl.Text = s1 & ph & s2
        tbSMSurl.SelectionStart = Len(s1)
        tbSMSurl.SelectionLength = Len(ph)
    End Sub
    Private Sub btnPhMessage_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnPhMessage.Click
        SMSurlInsert("[[MESSAGE]]")
    End Sub

    Private Sub btnPhRecipient_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnPhRecipient.Click
        SMSurlInsert("[[RECIPIENT]]")
    End Sub
End Class