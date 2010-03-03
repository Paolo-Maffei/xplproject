'* xPL Nabaztag Service
'*
'* Copyright (C) 2007 Gael L'hopital
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
Option Strict On

Imports System.IO
Imports System.Text
Imports System.Threading

Public Class clsNabaztag

    Public WithEvents myXplListener As xpllib.XplListener
    Public EventLog As EventLog

    Public sToken As String
    Public sSerial As String
    Public sBaseUrl As String

    Dim sLeftEar As String
    Dim sRightEar As String

    Public Sub Init()
        sLeftEar = ""
        sRightEar = ""

        ' Add supported remote config items
        myXplListener.XplOnTimer = AddressOf myXpl_OnTimer
        'myXplListener.XplMessageReceived = AddressOf myXpl_XplMessageReceived
        'myXplListener.Listen()
    End Sub

    Private Function RecupHTTP(ByVal URL As String) As String
        ' Déclaration des variables
        Dim LeDomaine As Integer
        Dim LeURL As String = ""
        Dim LeHost As String = ""
        Dim LeChemin As String = ""
        Dim Resultat As String = ""
        Dim RecupHTTPChaine As String = ""
        Dim WebClient As New TcpClient()
        Dim WebStream As NetworkStream
        Dim WebWriter As StreamWriter
        Dim WebReader As StreamReader
        ' On découpe l'url envoyée en paramètre à la fonction
        LeDomaine = InStr(UCase(URL), "HTTP://")
        If LeDomaine > 0 Then
            LeURL = Mid(URL, LeDomaine + 7)
        Else
            LeURL = URL
        End If
        LeDomaine = InStr(LeURL, "/")
        If LeDomaine > 0 Then
            LeHost = Mid(LeURL, 1, LeDomaine - 1)
            LeChemin = Mid(LeURL, LeDomaine)
        Else
            LeHost = LeURL
            LeChemin = "/"
        End If

        ' On construit notre requete HTTP
        RecupHTTPChaine = "GET " & LeChemin & " HTTP/1.1" & vbCrLf & "Host: " & LeHost & vbCrLf & "Connection: Close" & vbCrLf & vbCrLf

        ' On ouvre une socket sur le port 80
        WebClient.Connect(LeHost, 80)
        WebStream = WebClient.GetStream
        WebWriter = New StreamWriter(WebStream)
        WebWriter.Write(RecupHTTPChaine)
        WebWriter.Flush()
        WebReader = New StreamReader(WebStream)

        ' On stock la page html dans notre variable "Resultat"
        Resultat = WebReader.ReadToEnd()

        ' On ferme la socket
        WebStream.Close()
        WebClient.Close()

        ' On renvoi ce que l'on a récupéré
        RecupHTTP = Resultat
    End Function

    Private Function GetValueBetweenTags(ByVal aString As String, ByVal aTag As String) As String
        Dim a As Integer
        Dim b As Integer

        a = InStr(1, aString, "<" & aTag & ">") + Len(aTag) + 2
        b = InStr(a, aString, "</" & aTag & ">")
        GetValueBetweenTags = Mid(aString, a, b - a) 'Gets Whats Inbetween Beginning And End
    End Function

    Private Sub myXpl_OnTimer()
        Dim resultat As String
        Dim GetEarResult As Integer
        Dim c As String

        resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&ears=ok")

        GetEarResult = InStr(1, resultat, "POSITIONEAR", CompareMethod.Text)
        If GetEarResult > 0 Then
            'Search For Left Ear Position
            c = GetValueBetweenTags(resultat, "leftposition")
            If c <> sLeftEar Then
                sLeftEar = c
                myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=leftear" & Chr(10) & "type=count" & Chr(10) & "current=" & sLeftEar & Chr(10))
            End If

            'Search For Right Ear Position
            c = GetValueBetweenTags(resultat, "rightposition")
            If c <> sRightEar Then
                sRightEar = c
                myXplListener.SendMessage("xpl-trig", "*", "sensor.basic", "device=rightear" & Chr(10) & "type=count" & Chr(10) & "current=" & sRightEar & Chr(10))
            End If
        Else
            AnalyseResultatErreur(resultat)
        End If
    End Sub

    Private Sub AnalyseResultatErreur(ByVal aResultat As String)
        Dim aPos As Integer
        If aResultat = "about:blank" Then
            myXplListener.SendMessage("xpl-trig", "*", "log.basic", "type=inf" & Chr(10) & "text=Empty Page" & Chr(10))
        Else
            'If Page Loaded Up OK - Unsuccessful (Serial or Token)
            aPos = InStr(1, aResultat, "NOGOODTOKENORSERIAL")
            If aPos > 0 Then
                myXplListener.SendMessage("xpl-trig", "*", "log.basic", "type=err" & Chr(10) & "text=Incorrect Serial or Token" & Chr(10))
            Else
                myXplListener.SendMessage("xpl-trig", "*", "log.basic", "type=wrn" & Chr(10) & "text=Cannot Connect or Message not delivered" & Chr(10))
                frmNabaztag.EventLog.AppendText(aResultat)
            End If
        End If
    End Sub

    Private Sub myXplListener_XplMessageReceived(ByVal sender As Object, ByVal e As xpllib.XplListener.XplEventArgs) Handles myXplListener.XplMessageReceived
        Dim x As xpllib.XplMsg = e.XplMsg
        Dim sTTS As String
        Dim SelectedVoice As String, sVoice As String
        Dim ValidVoice() As String = {"heather22k", "ryan22k", "graham22s", "lucy22s", "aaron22s", "laura22s", "claire22s", "julie22k"}
        Dim sCheckVoice As String
        Dim sDevice As String
        Dim sAction As String
        Dim resultat As String
        Dim ttsResult As Integer
        Dim GetEarResult As Integer
        Dim c As String
        Dim sValue As String

        ' Look for command messages
        Select Case x.XPL_Msg(0).Section.ToLower
            Case "xpl-cmnd"
                Select Case x.Schema.msgClass
                    Case "tts"
                        Select Case x.Schema.msgType
                            Case "basic"                ' Envoie d'un message TTS
                                sTTS = Replace(e.XplMsg.GetParam(1, "speech"), " ", "+")
                                sVoice = e.XplMsg.GetParam(1, "voice")
                                SelectedVoice = ""
                                For Each sCheckVoice In ValidVoice
                                    If sCheckVoice = sVoice Then SelectedVoice = sVoice
                                Next sCheckVoice
                                If SelectedVoice = "" Then SelectedVoice = "julie22"
                                If sTTS <> "" Then
                                    resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&ttl=1" & "&tts=" & sTTS & "&voice=" & SelectedVoice)
                                    ' on pourrait aussi bouger les oreilles en même temps
                                    ttsResult = InStr(1, resultat, "SENT")
                                    If ttsResult = 0 Then AnalyseResultatErreur(resultat)
                                End If
                        End Select
                    Case "sensor"
                        Select Case x.Schema.msgType
                            Case "request"
                                sDevice = e.XplMsg.GetParam(1, "device")
                                Select Case sDevice
                                    Case "leftear"
                                        resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&ears=ok")
                                        GetEarResult = InStr(1, resultat, "POSITIONEAR", CompareMethod.Text)
                                        If GetEarResult > 0 Then
                                            sLeftEar = GetValueBetweenTags(resultat, "leftposition")
                                            myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=leftear" & Chr(10) & "type=count" & Chr(10) & "current=" & sLeftEar & Chr(10))
                                        Else
                                            AnalyseResultatErreur(resultat)
                                        End If
                                    Case "rightear"
                                        resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&ears=ok")
                                        GetEarResult = InStr(1, resultat, "POSITIONEAR", CompareMethod.Text)
                                        If GetEarResult > 0 Then
                                            sRightEar = GetValueBetweenTags(resultat, "rightposition")
                                            myXplListener.SendMessage("xpl-stat", "*", "sensor.basic", "device=rightear" & Chr(10) & "type=count" & Chr(10) & "current=" & sRightEar & Chr(10))
                                        Else
                                            AnalyseResultatErreur(resultat)
                                        End If
                                End Select
                        End Select
                    Case "audio"
                        Select Case x.Schema.msgType
                            Case "basic"
                                c = e.XplMsg.GetParam(1, "command")
                                If c = "play" Then
                                    c = e.XplMsg.GetParam(1, "extended")
                                    If c <> "" Then
                                        resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&idmessage=" & c)
                                        ttsResult = InStr(1, resultat, "Your message has been sent")
                                        If ttsResult = 0 Then AnalyseResultatErreur(resultat)
                                    End If
                                End If

                        End Select
                    Case "control"
                        Select Case x.Schema.msgType
                            Case "basic"
                                sDevice = e.XplMsg.GetParam(1, "device")
                                sValue = e.XplMsg.GetParam(1, "current")
                                If sDevice = "leftear" Then sDevice = "posleft"
                                If sDevice = "rightear" Then sDevice = "posright"
                                resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&" & sDevice & "=" & sValue)
                        End Select
                    Case "media"
                        Select Case x.Schema.msgType
                            Case "basic"
                                sAction = ""
                                sDevice = e.XplMsg.GetParam(1, "command")
                                sValue = e.XplMsg.GetParam(1, "state")
                                If sDevice = "power" Then
                                    If sValue = "on" Then sAction = "14"
                                    If sValue = "off" Then sAction = "13"
                                    If sAction <> "" Then
                                        resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&action=" & sAction)
                                    End If
                                End If
                                If sDevice = "reboot" Then
                                    resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&action=13")
                                    resultat = RecupHTTP(sBaseUrl & "?&sn=" & sSerial & "&token=" & sToken & "&action=14")
                                End If
                        End Select
                End Select
        End Select
    End Sub


End Class
