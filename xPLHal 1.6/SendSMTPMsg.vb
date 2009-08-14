'* xPLHal SendMsg Implementation
'*
'* Version 1.0
'*
Option Strict On

Imports System.web.mail

Public Class SendSMTPMsg

    Public Shared Function HandleXplMessage(ByVal e As xpllib.XplMsg) As String
        ' We only support sendmsg.smtp, so exit if schema is not sendmsg.smtp
        If e.Schema.msgClass.ToUpper <> "SENDMSG" And e.Schema.msgType.ToUpper <> "SMTP" Then Return ""

        Dim mailMsg As New System.Net.Mail.MailMessage()

        ' Extract the elements from the xPL message
        Dim from As New System.Net.Mail.MailAddress(e.GetParam(1, "from"))
        mailMsg.From = from
        mailMsg.To.Add(e.GetParam(1, "to"))
        mailMsg.Subject = e.GetParam(1, "subject")
        mailMsg.Body = e.GetParam(1, "body").Replace("\n", vbCrLf)
        mailMsg.CC.Add(e.GetParam(1, "cc"))
        mailMsg.Bcc.Add(e.GetParam(1, "bcc"))

        Try
            Dim smtp As New System.Net.Mail.SmtpClient(e.GetParam(1, "server"))
            smtp.Send(mailMsg)
            HandleXplMessage = ""
        Catch ex As Exception
            HandleXplMessage = ex.Message
        End Try
    End Function
End Class
