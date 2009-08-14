'* xPL xAP Hub Implementation
'*
'* Version 2.0
'*
'* Written by John Bent
'* http://www.xpl.myby.co.uk
'* Based on original work by Tony T
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
'*
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

Imports System.Net
Imports System.Net.Sockets
Imports System.Text
Imports System.Threading

Public Class hubxap

    Private Structure structXAPHub
        Public IP As String
        Public Port As Integer
        Public Refreshed As Date
    End Structure

    Private Const MAX_XAP_MSG_SIZE As Integer = 1500
    Private Const MAX_XAP_HUBS As Integer = 32
    Private Const XAP_BASE_PORT As Integer = 3639

    Private XAP_Hubs(MAX_XAP_HUBS) As structXAPHub
    Private XAP_Hubs_Count As Integer
    Private XAP_Buff(MAX_XAP_MSG_SIZE) As Byte
    Private sockIncoming As Socket, epIncoming As EndPoint
    Private ipLocal As IPAddress

    Public EventLog As EventLog

    Public Sub StartHub()
        Dim EP As New IPEndPoint(IPAddress.Any, XAP_BASE_PORT)
        ipLocal = Dns.GetHostEntry(Dns.GetHostName()).AddressList(0)
        XAP_Hubs_Count = -1
        sockIncoming = New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
        sockIncoming.Bind(EP)
        epIncoming = New IPEndPoint(IPAddress.Any, 0)
        sockIncoming.BeginReceiveFrom(XAP_Buff, 0, MAX_XAP_MSG_SIZE, SocketFlags.None, epIncoming, AddressOf Me.ReceiveData, Nothing)
        If Not EventLog Is Nothing Then
            EventLog.WriteEntry("The xPL xAP hub has started listening on IP address " & ipLocal.ToString() & ".")
        End If
    End Sub

    Public Sub StopHub()
        sockIncoming.Shutdown(SocketShutdown.Both)
        sockIncoming.Close()
        If Not EventLog Is Nothing Then
            EventLog.WriteEntry("The xPL xAP Hub has been stopped.")
        End If
    End Sub

    Private Sub ReceiveData(ByVal ar As IAsyncResult)
        Try
            Dim bytes_read As Integer = sockIncoming.EndReceiveFrom(ar, epIncoming)
            Dim ipaddr As String = CType(epIncoming, IPEndPoint).Address.ToString()
            Dim myXAP As String
            myXAP = Encoding.ASCII.GetString(XAP_Buff, 0, bytes_read).Trim
            Try
                BroadcastMessage(myXAP, ipaddr)
            Catch ex As Exception
                If Not EventLog Is Nothing Then
                    EventLog.WriteEntry("An unhandled exception was thrown during the handling of received data. The details of the exception are: " & vbCrLf & ex.ToString, EventLogEntryType.Error)
                End If
            End Try
            epIncoming = New IPEndPoint(IPAddress.Any, 0)
            sockIncoming.BeginReceiveFrom(XAP_Buff, 0, MAX_XAP_MSG_SIZE, SocketFlags.None, epIncoming, AddressOf ReceiveData, Nothing)
        Catch ex As Exception
        End Try
    End Sub

    Private Sub BroadcastMessage(ByRef myXAP As String, ByRef ipaddr As String)
        Dim portNum As Integer, Counter As Integer, hbeat As Integer
        Dim IsHeartbeat As Boolean
        Try
            Dim localIP As String = ipLocal.ToString()
            Dim FoundPort As Boolean
            ' check for possible message
            If myXAP.Substring(0, 4).ToUpper <> "XAP-" Or Not myXAP.ToUpper.EndsWith(Chr(10) & "}") Then Exit Sub
            ' check for heartbeat config message for me
            If myXAP.Substring(0, 9).ToUpper = "XAP-HBEAT" Then
                ' it's a heartbeat
                IsHeartbeat = True
                If ipaddr = localIP Then
                    ' it's local
                    portNum = CInt(xAP_GetParam(myXAP, 0, "PORT"))
                    hbeat = CInt(xAP_GetParam(myXAP, 0, "INTERVAL"))
                    If portNum > 0 And portNum <= 65535 And portNum <> XAP_BASE_PORT Then
                        ' See if we've got it already
                        FoundPort = False
                        For Counter = 0 To XAP_Hubs_Count
                            If XAP_Hubs(Counter).Port = portNum Then
                                FoundPort = True
                                ' Refresh it
                                XAP_Hubs(Counter).Refreshed = DateTime.Now().AddSeconds(hbeat * 2)
                            End If
                        Next

                        If Not FoundPort Then
                            ' It's new
                            If XAP_Hubs_Count < MAX_XAP_HUBS Then
                                XAP_Hubs_Count = XAP_Hubs_Count + 1
                                XAP_Hubs(XAP_Hubs_Count).IP = localIP
                                XAP_Hubs(XAP_Hubs_Count).Port = portNum
                                XAP_Hubs(Counter).Refreshed = DateTime.Now().AddSeconds(hbeat * 2)
                                If Not EventLog Is Nothing Then
                                    EventLog.WriteEntry("xPL xAP process " & xAP_GetParam(myXAP, 0, "source") & " detected on port " & portNum.ToString() & ".")
                                End If
                            Else
                                EventLog.WriteEntry("The hub has reached it's maximum number of supported xPL xAP processes.", EventLogEntryType.Error)
                            End If
                        End If
                    End If
                End If
            Else
                IsHeartbeat = False
            End If

        Catch ex As Exception
            EventLog.WriteEntry("Error during xPL xAP packet analysis: " & ex.ToString(), EventLogEntryType.Error)
        End Try

        Try
            ' Broadcast to all ports            
            For Counter = 0 To XAP_Hubs_Count
                Dim xapit As New xpllib.xAPMsg(myXAP)
                xapit.Send(New IPEndPoint(IPAddress.Loopback, XAP_Hubs(Counter).Port))
            Next
        Catch ex As Exception
            EventLog.WriteEntry("Exception during xPL xAP message broadcast: " & ex.ToString(), EventLogEntryType.Error)
        End Try

        ' scripting
        If IsHeartbeat = True Then Exit Sub
        If xPLHalIsActive = False Then Exit Sub

        Dim xAPSub As String
        Dim x As Integer
        xAPSub = UCase(xAP_GetParam(myXAP, 0, "SOURCE"))
        If xAPSub = "" Then Exit Sub
        x = InStr(1, xAPSub, ":", CompareMethod.Binary)
        If x = 1 Then Exit Sub
        If x > 0 Then xAPSub = Left(xAPSub, x - 1)
        xAPSub = "XAP_" & GetxAPSub(xAPSub)
        Dim xPLThread As Scripting
        Dim t As Thread
        xPLThread = New Scripting
        t = New Thread(AddressOf xPLThread.xAP_Scripting)
        xPLThread.xapmsg = myXAP
        xPLThread.xapsub = xAPSub
        t.Start()

    End Sub

    ' build safe name for xap script routine
    Public Function GetxAPSub(ByVal strSubName As String) As String
        Dim strSub As String
        strSub = ""
        Dim x As Integer
        strSubName = Trim(UCase(strSubName))
        For x = 1 To Len(strSubName)
            Select Case Mid(strSubName, x, 1)
                Case "0" To "9"
                    strSub = strSub + Mid(strSubName, x, 1)
                Case "A" To "Z"
                    strSub = strSub + Mid(strSubName, x, 1)
                Case Else
                    strSub = strSub + "_"
            End Select
        Next x
        While Right(strSub, 1) = "_"
            strSub = Left(strSub, Len(strSub) - 1)
        End While
        Return strSub
    End Function
End Class
