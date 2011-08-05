Imports xPL
Imports xPL.xPL_Base

Public Class Form1

    Dim xdev As New xPLDevice

    Private Sub Form1_Shown(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Shown
        Me.Icon = XPL_Icon
        'xdev.Configurable = False
        'xdev.Enable()
    End Sub
    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
        'xdev.Disable()
    End Sub

    Private Sub btnStart_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnStart.Click
        Dim msg As String

        ' Send an OK message
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=This message is supposed to be OK" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)

        ' capitalized characters
        msg = "XPL-STAT" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=PART1-PART2.part3" & XPL_LF & _
              "TARGET=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "KEY1=msgtype, sourceaddress, target key and first keyvalue are capitalized" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)

        ' non-broadcast for stat or trig type messages
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=part1-part2.part3" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=trig & stat must be broadcast" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-trig" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=part1-part2.part3" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=trig & stat must be broadcast" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)

        ' missing parts
        msg = "xpl-stat" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=1st open accolade is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=source address is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=hop count is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=target address is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=1st closing accolade is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=schema is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "key1=2nd open accolade is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=Ke2 has no '=' character, hence no value" & XPL_LF & _
              "key2" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=2nd closing accolade is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=final linefeed is missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}"
        Send(msg)
        msg = "xpl-stxws" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=message type unknown" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=source address device & instance missing" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=*" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=source is broadcast" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=Key2 is way too long" & XPL_LF & _
              "kdjhfjdshfjhdsjhfjdshfsdey2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=value2 is too long, warning on this" & XPL_LF & _
              "key2=somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue-somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=illegal character in value2 and key3 (control characters; dec 20 and 30)" & XPL_LF & _
              "key" & Chr(20) & "2=somevalue" & XPL_LF & _
              "key3=some" & Chr(30) & "value" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=UTF-8 characters in key2" & XPL_LF & _
              "key2=some UTF8 values: üéèö€" & Chr(240) & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=no schema class" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)
        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class." & XPL_LF & _
              "{" & XPL_LF & _
              "key1=no schema type" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)





        msg = "xpl-stat" & XPL_LF & _
              "{" & XPL_LF & _
              "hop=1" & XPL_LF & _
              "source=part1-part2.part3" & XPL_LF & _
              "target=*" & XPL_LF & _
              "}" & XPL_LF & _
              "class.type" & XPL_LF & _
              "{" & XPL_LF & _
              "key1=This message is supposed to be OK" & XPL_LF & _
              "key2=somevalue" & XPL_LF & _
              "}" & XPL_LF
        Send(msg)

        ' missing items
        MsgBox("Completed!")
    End Sub

    Private Sub Send(ByVal msg As String)
        xPLListener.SendRawxPL(msg)
        Threading.Thread.Sleep(100)
    End Sub

End Class
