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
Imports xPL.xPL_Base

''' <summary>
''' The <see cref="xPLKeyValuePair" /> object represents a single Key-value pair in an xPL message. The object is stored
''' in the <see cref="xPLKeyValuePairs" /> object which represents all key value pairs in an xPL message.
''' </summary>
''' <remarks>The keys of the key-value pairs do not need to be unique in the list.</remarks>
Public Class xPLKeyValuePair
    Private mKey As String
    Private mValue As String

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLKeyValuePair" /> class.
    ''' </summary>
    ''' <param name="k">The key</param>
    ''' <param name="v">The value</param>
    ''' <exception cref="IllegalFieldContentsException">Condition: if either the key or the value doesn't 
    ''' match the xPL requirements.</exception>
    ''' <remarks>The value for key will always be converted to lowercase.</remarks>
    Public Sub New(ByVal k As String, ByVal v As String)
        ' use property handlers for error checking
        Me.Key = k
        Me.Value = v
    End Sub

    ''' <summary>
    ''' Gets or sets the key.
    ''' </summary>
    ''' <value>The key</value>
    ''' <exception cref="IllegalFieldContentsException">Condition: if the key doesn't match the xPL requirements.</exception>
    ''' <remarks>The key provided will always be converted to lowercase.</remarks>
    Public Property Key() As String
        Get
            Return mKey
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If IsValidxPL(value, 1, 16, XPL_STRING_TYPES.OtherElements) Then
                mKey = value
            Else
                Throw New IllegalFieldContentsException("Illegal field length (1 to 8) or illegal casing")
            End If
        End Set
    End Property

    ''' <summary>
    ''' Gets or sets the value.
    ''' </summary>
    ''' <value>The value.</value>
    ''' <exception cref="IllegalFieldContentsException">Condition: if the value doesn't match the xPL requirements.</exception>
    Public Property Value() As String
        Get
            Return mValue
        End Get
        Set(ByVal v As String)
            If IsValidxPL(v, 0, 0, XPL_STRING_TYPES.Values) Then
                mValue = v
            Else
                Throw New IllegalFieldContentsException("Illegal field; unallowed characters: " & v)
            End If
        End Set
    End Property

    ''' <summary>
    ''' Returns a string that represents this key value pair.
    ''' </summary>
    ''' <returns>A string that represents this instance in the format 'key=value'.</returns>
    Public Overrides Function ToString() As String
        Return mKey & "=" & mValue
    End Function
End Class

''' <summary>
''' The <see cref="xPLKeyValuePairs" /> object represents a list of key-value pairs in an xPL message. The object stores
''' members of <see cref="xPLKeyValuePair" /> which represent the individual key value pairs in an xPL message.
''' </summary>
''' <remarks>The keys of the key-value pairs do not need to be unique in the list.</remarks>
Public Class xPLKeyValuePairs

    Private mList As New ArrayList

    ''' <summary>
    ''' Gets or sets the <see cref="xPLKeyValuePair" /> at the specified index from/to the KeyValuePair list.
    ''' </summary>
    ''' <value>object of type <see cref="xPLKeyValuePair" /></value>
    ''' <exception cref="System.ArgumentOutOfRangeException">Condition: if the index provided is out of range (less than 0 or 
    ''' greater than or the index is equal to or greater than Count.</exception>
    ''' <exception cref="System.NullReferenceException">Condition: if the reference to the <see cref="xPLKeyValuePair" /> object <c>Is Nothing</c></exception>
    Default Public Property Item(ByVal idx As Integer) As xPLKeyValuePair
        Get
            Return CType(mList.Item(idx), xPLKeyValuePair)
        End Get
        Set(ByVal value As xPLKeyValuePair)
            If value Is Nothing Then
                Throw New System.NullReferenceException
            End If
            mList.Item(idx) = value
        End Set
    End Property
    ''' <summary>
    ''' Gets or sets the value of the first <see cref="xPLKeyValuePair" /> in the list with the specified key.
    ''' </summary>
    ''' <value>The value of the key-value pair</value>
    ''' <exception cref="System.ArgumentOutOfRangeException">Condition: if the key provided cannot be found in the list.</exception>
    ''' <exception cref="IllegalFieldContentsException">Condition: if the value doesn't match the xPL requirements.</exception>
    ''' <remarks>The same key value may appear more than once, this property accesses only the first match found. The value for Key is always 
    ''' converted to lowercase.</remarks>
    Default Public Property Item(ByVal key As String) As String
        Get
            key = key.ToLower
            Return CType(mList.Item(Me.IndexOf(key)), xPLKeyValuePair).Value
        End Get
        Set(ByVal value As String)
            key = key.ToLower
            CType(mList.Item(Me.IndexOf(key)), xPLKeyValuePair).Value = value
        End Set
    End Property
    ''' <summary>
    ''' Gets the number of <see cref="xPLKeyValuePair" /> objects in the list.
    ''' </summary>
    ''' <value>The number of items in the list</value>
    Public ReadOnly Property Count() As Integer
        Get
            Return mList.Count
        End Get
    End Property
    ''' <summary>
    ''' Returns the index of the first <see cref="xPLKeyValuePair" /> object with the specified key.
    ''' </summary>
    ''' <param name="key">The key.</param>
    ''' <returns>The index of the item, or -1 if it wasn't found.</returns>
    ''' <remarks>The key provided will always be converted to lowercase before looking it up.</remarks>
    Public Function IndexOf(ByVal key As String) As Integer
        key = key.ToLower
        Dim i As Integer
        For i = 0 To mList.Count - 1
            If CType(mList.Item(i), xPLKeyValuePair).Key = key Then Return i
        Next
        Return -1
    End Function
    ''' <summary>
    ''' Adds the specified <see cref="xPLKeyValuePair" /> object to the list.
    ''' </summary>
    ''' <param name="kvp">The key-valuepair.</param>
    ''' <remarks>if the value provided <c>Is Nothing</c> then it will not be added, no exception will be thrown.</remarks>
    Public Sub Add(ByVal kvp As xPLKeyValuePair)
        If Not kvp Is Nothing Then
            mList.Add(kvp)
        End If
    End Sub
    ''' <summary>
    ''' Adds a <see cref="xPLKeyValuePair" /> object to the list with the given key and value.
    ''' </summary>
    ''' <param name="key">The key of the keyvalue pair.</param>
    ''' <param name="value">The value of the keyvalue pair.</param>
    ''' <exception cref="IllegalFieldContentsException">Condition: if either the key or the value doesn't 
    ''' match the xPL requirements.</exception>
    ''' <remarks></remarks>
    Public Sub Add(ByVal key As String, ByVal value As String) 'ByVal kvp As xPLKeyValuePair)
        Dim kvp As xPLKeyValuePair
        kvp = New xPLKeyValuePair(key, value)
        mList.Add(kvp)
    End Sub
    ''' <summary>
    ''' Removes the <see cref="xPLKeyValuePair" /> object at the specified index from the list.
    ''' </summary>
    ''' <param name="index">The index of the item to be removed.</param>
    ''' <exception cref="System.ArgumentOutOfRangeException">Condition: if the index provided is less than 0 or 
    ''' greater than or equal to the <c>Count</c> property.</exception>
    Public Sub Remove(ByVal index As Integer)
        mList.RemoveAt(index)
    End Sub
    ''' <summary>
    ''' Clears the list, removing all <see cref="xPLKeyValuePair" /> objects from it.
    ''' </summary>
    Public Sub Clear()
        mList.Clear()
    End Sub
    ''' <summary>
    ''' Returns a <see cref="System.String" /> that represents this instance. It will be formatted as in the raw xPL message; each individual pair formatted as 'key=value' and the key-value pairs separated by the <c>XPL_LF</c> constant. 
    ''' </summary>
    ''' <returns>A <see cref="System.String" /> that represents this instance.</returns>
    ''' <remarks>Returns an empty string, eg. "", if there are no items in the list.</remarks>
    Public Overrides Function ToString() As String
        Dim result As String = ""
        Dim sb As New Text.StringBuilder("", 1500)
        If Me.Count <> 0 Then
            For Each x As xPLKeyValuePair In mList
                sb.Append(x.Key & "=" & x.Value & XPL_LF)
            Next
            sb.Remove(sb.Length - Len(XPL_LF), Len(XPL_LF)) ' remove final LF
            result = sb.ToString
        End If
        Return result
    End Function
End Class

