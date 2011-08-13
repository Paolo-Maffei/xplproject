'* xPL Library for .NET
'*
'* Version 5.4
'*
'* Copyright (c) 2009-2011 Thijs Schreijer
'* http://www.thijsschreijer.nl
'*
'* Copyright (c) 2008-2009 Tom Van den Panhuyzen
'* http://blog.boxedbits.com/xpl
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
Imports xPL
Imports xPL.xPL_Base
Imports System.Text

''' <summary>
''' represents a fragmented xPL message, either received from the xPL network, or created from an internal message as preparation to send it.
''' </summary>
''' <remarks></remarks>
Public Class xPLFragmentedMsg

    ''' <summary>
    ''' Simple class to dissect a fragment key into its components; fragment nr, total number of fragments and message ID
    ''' </summary>
    ''' <remarks></remarks>
    Private Class FragmentKey
        Public FragmentNumber As Integer = 0
        Public FragmentTotal As Integer = 0
        Public MessageID As String = ""
        ''' <summary>
        ''' Returns the fragmentkey as a formatted fragment key;  'nr/max:id'
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Overrides Function ToString() As String
            Return FragmentNumber.ToString & "/" & FragmentTotal.ToString & ":" & MessageID
        End Function
        Private Sub DissectKey(ByVal FragKey As String)
            Try
                Dim n1 As Integer = FragKey.IndexOf("/")
                Dim n2 As Integer = FragKey.IndexOf(":")
                FragmentNumber = CInt(Left(FragKey, n1))
                FragmentTotal = CInt(Mid(FragKey, n1 + 1, n2 - n1 - 1))
                MessageID = Mid(FragKey, n2 + 1)
            Catch ex As Exception
                Throw New Exception("Cannot extract fragmentnr, number of fragments and/or message ID from the 'fragment' key in the message. Key provided : 'fragment=" & FragKey & "'.", ex)
            End Try

        End Sub
        ''' <summary>
        ''' Dissects fragmentkey 'nr/max:id' into its underlying components as a FragmentKey object
        ''' </summary>
        ''' <param name="FragKey"></param>
        ''' <remarks></remarks>
        Public Sub New(ByVal FragKey As String)
            Me.DissectKey(FragKey)
        End Sub
        ''' <summary>
        ''' Dissects the partidkey 'nr/max:id' from the provided message into its underlying components as a FragmentKey object
        ''' </summary>
        ''' <param name="msg"></param>
        ''' <remarks></remarks>
        Public Sub New(ByVal msg As xPLMessage)
            Dim FragKey As String
            Try
                FragKey = msg.KeyValueList("partid")
            Catch ex As Exception
                Throw New Exception("Cannot find 'partid' key in provided message", ex)
            End Try
            Me.DissectKey(FragKey)
        End Sub
    End Class
    ''' <summary>
    ''' Will hold the original xPLMessage object that created, or was reconstructed from, the fragments
    ''' </summary>
    ''' <remarks></remarks>
    Private _Message As xPLMessage
    ''' <summary>
    ''' Holds all the individual message fragments (xPLMessage objects), by their fragment number
    ''' </summary>
    ''' <remarks></remarks>
    Private _Fragments As New SortedList(Of Integer, xPLMessage)
    ''' <summary>
    ''' A checklist containing the numbers of the parts still missing/expected, if the list is empty, the message is complete.
    ''' </summary>
    ''' <remarks></remarks>
    Private _Checklist As New ArrayList
    Private _Source As String
    ''' <summary>
    ''' The source address the message originates from
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Source() As String
        Get
            Return _Source
        End Get
    End Property
    Private _MessageID As String    ' senderaddress & ":" & (ID in partid key)
    ''' <summary>
    ''' The message ID of a fragmented message is the senders xPL addres with the message specific ID in the partid key, separated by a colon ':'
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property MessageID() As String
        Get
            Return _MessageID
        End Get
    End Property
    Private _NoOfFragments As Integer
    ''' <summary>
    ''' Total number of fragments for the message
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property NoOfFragments() As Integer
        Get
            Return _NoOfFragments
        End Get
    End Property

    ''' <summary>
    ''' If True, the message was received, false it was created
    ''' </summary>
    ''' <remarks></remarks>
    Private _blnReceived As Boolean
    ''' <summary>
    ''' Returns <c>True</c> if the message was received from the network, this allows other fragments to be added to this message.
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Received() As Boolean
        Get
            Return _blnReceived
        End Get
    End Property
    ''' <summary>
    ''' Returns <c>True</c> if the message was self created (and not received), this prevents other fragments of being added to this message
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Created() As Boolean
        Get
            Return Not _blnReceived
        End Get
    End Property

    ''' <summary>
    ''' Returns true is the message can be fragmented; eg. message (and fragmentation) overhead 
    ''' combined with the longest value do not exceed the maximum message size.
    ''' </summary>
    ''' <param name="msg"></param>
    ''' <remarks></remarks>
    Public Shared Function CanFragment(ByVal msg As xPLMessage) As Boolean
        If msg Is Nothing Then Throw New NullReferenceException("Must provide an xPLMessage object.")

        Dim raw As String = msg.RawxPL
        ' extract header and add the fragment overhead
        Dim d As String = msg.Schema & XPL_LF & "{" & XPL_LF
        Dim header As String = Left(raw, raw.IndexOf(d)) & "fragment.basic" & XPL_LF & "{" & XPL_LF & "partid=000/000:000" & XPL_LF
        ' define footer
        Dim footer As String = "}" & XPL_LF
        ' calculate maximum size for a single key/value pair available
        Dim max As Integer = XPL_MAX_MSG_SIZE - (header.Length + footer.Length)
        Dim result As Boolean = True    ' start of assuming we're ok
        For n As Integer = 0 To msg.KeyValueList.Count - 1
            With msg.KeyValueList(n)
                If .Key.Length + Encoding.UTF8.GetByteCount(.Value) + XPL_LF.Length + 1 > max Then
                    ' Too large, so it fails
                    result = False
                    Exit For
                End If
            End With
        Next
        Return result
    End Function

    ''' <summary>
    ''' Creates a new fragmented message, if the provided message has a 'fragment.basic' schema then it becomes a
    ''' 'received' message, otherwise it becomes a 'created' message.
    ''' </summary>
    ''' <param name="msg"></param>
    ''' <remarks></remarks>
    Public Sub New(ByVal msg As xPLMessage)
        If msg Is Nothing Then Throw New NullReferenceException("Must provide an xPLMessage object.")
        If msg.Schema = "fragment.basic" Then
            CreateFromReceived(msg)
        Else
            CreateFromMessage(msg)
        End If
    End Sub

    Private Sub CreateFromReceived(ByVal msg As xPLMessage)
        _blnReceived = True
        _Fragments.Clear()
        _Checklist.Clear()
        Dim FragKey As New FragmentKey(msg)
        Me._MessageID = msg.Source & ":" & FragKey.MessageID
        Me._NoOfFragments = FragKey.FragmentTotal
        Me._Message = New xPLMessage
        Me._Source = msg.Source
        With Me._Message
            .MsgType = msg.MsgType
            .Hop = msg.Hop
            .Source = msg.Source
            .Target = msg.Target
        End With
        ' Fill checklist with all message fragments, 1 to max, to be checked off when receiving them
        For n As Integer = 1 To FragKey.FragmentTotal
            _Checklist.Add(n)
        Next
        Me.AddFragment(msg)
    End Sub
    Private Sub CreateFromMessage(ByVal msg As xPLMessage)
        _blnReceived = False

        Dim frag As xPLMessage = Nothing
        Dim done1 As Boolean = False
        Dim done2 As Boolean = False
        Dim count As Integer = 0
        Dim index As Integer = 0
        Dim bytesleft As Integer = 0
        While Not done1
            count = count + 1
            frag = New xPLMessage
            frag.MsgType = msg.MsgType
            frag.Source = msg.Source
            frag.Target = msg.Target
            frag.Hop = msg.Hop
            frag.Schema = "fragment.basic"
            frag.KeyValueList.Add("partid", "000/000:000")
            If count = 1 Then
                frag.KeyValueList.Add("schema", msg.Schema)
            End If
            bytesleft = XPL_MAX_MSG_SIZE - frag.RawxPL.Length
            done2 = False
            While Not done2
                ' get size of next key/value pair
                Dim b As Integer = Encoding.UTF8.GetByteCount(msg.KeyValueList(index).ToString) + 1
                If b <= bytesleft Then
                    ' still fits in this fragment, so add it
                    frag.KeyValueList.Add(msg.KeyValueList(index).Key, msg.KeyValueList(index).Value)
                    index = index + 1
                Else
                    ' won't fit anymore
                    If (count = 1 And frag.KeyValueList.Count = 2) Or (count > 1 And frag.KeyValueList.Count = 1) Then
                        ' nothing was added, so key/value at position 'index' is too large to fit
                        Throw New Exception("Cannot fragment; key/value pair at position " & index & " is too large for a single message.")
                    End If
                    ' move to next fragment
                    done2 = True
                End If
            End While
            ' fragment construction done
            _Fragments.Add(count, frag)
            done1 = (index = msg.KeyValueList.Count)
        End While
        ' set all the proper IDs
        Dim msgid As Integer = xPLListener.GetNewFragmentedID
        For n As Integer = 1 To _Fragments.Count
            _Fragments(n).KeyValueList.Item("partid") = n.ToString & "/" & count.ToString & ":" & msgid.ToString
        Next
        ' set other properties
        _Message = msg
        _Source = msg.Source
        _MessageID = _Source & ":" & msgid.ToString
        _NoOfFragments = count
    End Sub

    ''' <summary>
    ''' If the object is set as received from the network, this methods allows for the addition of new fragments received. Only if the
    ''' partid matches the existing parts it will be added. No exceptions will be thrown if it doesn't match
    ''' </summary>
    ''' <param name="msg"></param>
    ''' <remarks></remarks>
    Public Sub AddFragment(ByVal msg As xPLMessage)
        Dim FragKey As New FragmentKey(msg)
        If Me.Created Then Throw New Exception("Cannot add fragments to a created message, only to received messages.")
        If msg.Source & ":" & FragKey.MessageID <> Me.MessageID Then Exit Sub
        If FragKey.FragmentNumber = 1 Then
            If (msg.KeyValueList.IndexOf("schema") <> -1) Then
                ' got the schema, go set it
                Try
                    _Message.Schema = msg.KeyValueList("schema")
                Catch ex As Exception
                    Throw New Exception("Fragmented message contained an illegal schema value; 'schema=" & msg.KeyValueList("schema") & "'.")
                End Try
            Else
                Throw New Exception("1st fragment does not contain the 'schema' key")
            End If
        End If

        If Not _Checklist.Contains(FragKey.FragmentNumber) Then
            ' fragment number wasn't in the checklist, so we already had this one. Do nothing.
        Else
            ' the fragment number is still in the checklist, so we were waiting for this one, go process it
            _Checklist.Remove(FragKey.FragmentNumber)   ' remove it so we won't process it again
            _Fragments.Add(FragKey.FragmentNumber, msg) ' add to our list of fragments
            If _Checklist.Count = 0 Then
                ' we've got all fragments, so go reconstruct the message
                Me.Reconstruct()
            End If
        End If
    End Sub
    ''' <summary>
    ''' Once the last fragment has been received, this will reconstruct the original message. Header is already done, now restore key-valuepairs in correct order
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub Reconstruct()
        ' loop through all fragments
        Dim msgfrag As xPLMessage
        For i As Integer = 1 To _Fragments.Count
            msgfrag = _Fragments(i - 1)

            Dim SkipPartID As Boolean = True     ' first key named 'partid' must be skipped, is fragment.basic overhead
            Dim SkipSchema As Boolean = (i = 1)    ' only if its the 1st fragment, also the first key 'schema' must be handled separately
            For n As Integer = 1 To msgfrag.KeyValueList.Count
                Dim kv As xPLKeyValuePair = msgfrag.KeyValueList(n - 1)
                If kv.Key = "partid" And SkipPartID Then
                    ' must skip this partid key
                    SkipPartID = False  ' only the first, so now disable
                Else
                    If kv.Key = "schema" And SkipSchema Then
                        ' must skip this schema key
                        SkipSchema = False    ' only the first, so now disable
                    Else
                        ' add this key to the reconstrud message
                        _Message.KeyValueList.Add(kv)
                    End If
                End If
            Next
        Next
    End Sub

    ''' <summary>
    ''' Returns <c>True</c> if the message is complete. Only usefull for received messages, which wait for other fragments to come in.
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property IsComplete() As Boolean
        Get
            Return (_Checklist.Count = 0)
        End Get
    End Property

    ''' <summary>
    ''' Requests the still missing parts of the message through the provided device (will be used as the sender for the request). If no 
    ''' device provided an active device will be gotten from the xPLListener to send it through.
    ''' </summary>
    ''' <param name="dev"></param>
    ''' <remarks></remarks>
    Private Sub RequestMissingParts(Optional ByVal dev As xPLDevice = Nothing)
        If Me.Created Then Throw New Exception("Can only request missing parts for received fragmented messages, not for created ones")
        Dim msg As New xPLMessage
        msg.Target = Me.Source
        msg.MsgType = xPLMessageTypeEnum.Command
        msg.Schema = "fragment.request"
        msg.KeyValueList.Add("command", "resend")
        msg.KeyValueList.Add("message", Mid(MessageID, MessageID.IndexOf(":") + 1))
        For Each nr As Integer In _Checklist
            msg.KeyValueList.Add("part", nr.ToString)
        Next
        If dev Is Nothing And xPLListener.Count <> 0 Then
            dev = xPLListener.Device(0) ' no device provided, just pick first one in the list
        End If
        If dev Is Nothing Then
            Throw New Exception("Cannot request missing parts of fragmented message, no device available through which to send the request.")
        Else
            dev.Send(msg)
        End If
    End Sub

    ''' <summary>
    ''' Returns <c>True</c> if the message is incomplete, the last message was received to long ago, missing parts have been requested
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Expiring() As Boolean
        Get

        End Get
    End Property
End Class
