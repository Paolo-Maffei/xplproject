Imports xPL
Imports xPL.xPL_Base

Public Class Example6

    Private Sub tbDemoText_TextChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles tbDemoText.TextChanged
        'fill checkboxes by using the IsValidxPL function
        Me.chkValidXPLValue.Checked = IsValidxPL(tbDemoText.Text, 0, 128, XPL_STRING_TYPES.Values)
        Me.chkValidxPLVendor.Checked = IsValidxPL(tbDemoText.Text, 3, 8, XPL_STRING_TYPES.VendorAndDevice)
        Me.chkValidxPLOther.Checked = IsValidxPL(tbDemoText.Text, 1, 16, XPL_STRING_TYPES.OtherElements)

        ' use the cleanup function to create a best-effort match
        lblValue.Text = Strings.Left(RemoveInvalidxPLchars(tbDemoText.Text, XPL_STRING_TYPES.Values), 128)
        lblVendor.Text = Strings.Left(RemoveInvalidxPLchars(tbDemoText.Text, XPL_STRING_TYPES.VendorAndDevice), 8)
        lblOther.Text = Strings.Left(RemoveInvalidxPLchars(tbDemoText.Text, XPL_STRING_TYPES.OtherElements), 16)

        ' display the value State encoded
        lblState.Text = StateEncode(tbDemoText.Text)
    End Sub

    Private Sub Example6_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        ' programmatically set the icon of the form to the xPL icon
        Me.Icon = xPL_Base.XPL_Icon
        MsgBox("Check the icon of the form! its included in the xPLLib.")

        ' set initial values
        Call tbDemoText_TextChanged(Nothing, Nothing)
    End Sub
End Class