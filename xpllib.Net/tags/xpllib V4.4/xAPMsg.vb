'* XPL Library for .NET
'* xAPMsg Class
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

Public Class xAPMsg

    Private Const XAP_BASE_PORT As Integer = 3639
    Private xAP_Raw As String

    Public Sub New()
        MyBase.new()
    End Sub

    Public Sub New(ByVal xAPMsg As String)
        MyBase.new()
        xAP_Raw = xAPMsg
    End Sub

    Public ReadOnly Property Content() As String
        Get
            Return xAP_Raw
        End Get
    End Property

    Public Sub Send(ByVal ep As IPEndPoint)
        Dim s As New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
        s.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, 1)
        s.SendTo(Encoding.ASCII.GetBytes(xAP_Raw), ep)
    End Sub

    Public Sub Send()
        Dim ep As New IPEndPoint(IPAddress.Broadcast, XAP_BASE_PORT)
        Send(ep)
    End Sub

    Public Sub Send(ByVal s As String)
        xAP_Raw = s
        Dim ep As New IPEndPoint(IPAddress.Broadcast, XAP_BASE_PORT)
        Send(ep)
    End Sub

End Class
