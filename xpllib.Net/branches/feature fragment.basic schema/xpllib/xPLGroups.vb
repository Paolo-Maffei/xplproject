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
Imports xPL.xPLConfigItem

''' <summary>
''' Object to hold the xPL groups a device belongs to.
''' </summary>
''' <remarks>No duplicates are allowed. This object is a used as the <see cref="xPLConfigItems.conf_Group" /> property in an ConfigItems object.</remarks>
Public Class xPLGroups

    Private mItems As New ArrayList
    ''' <summary>
    ''' Gets or sets the value of an item at the specififed index in the list.
    ''' </summary>
    ''' <param name="idx">The index at which to get/set the value</param>
    ''' <value>The value to be set. If an empty string value ("") is set, then the item will be removed from the list.</value>
    ''' <returns>String with the group address</returns>
    ''' <remarks>Values must be in full xPL address format, with 'xpl' as vendor value and 'group' as device value. 
    ''' Example: 'xpl-group.mygroup'. Values will always be converted to lowercase.</remarks>
    ''' <exception cref="IllegalConfigItemValue">Condition: Value doesn't adhere to the xPL requirements for groupnames.</exception>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than zero, or <c>idx</c> is equal to or greater than <c>Count</c></exception>
    ''' <exception cref="DuplicateNameException">Condition: Groupname as provided is already present in the list</exception>
    Public Property Items(ByVal idx As Integer) As String
        Get
            Return CStr(mItems(idx))
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            ' not empty; must start with group identifier and have sufficent length
            If Left(value, 10) <> "xpl-group." Or value.Length <= 10 Then
                Throw New IllegalConfigItemValue("'group' values must start with 'xpl-group.'")
            End If
            ' all characters must remain within the limits of allowed chars for ELEMENTS
            If IsValidxPL(Mid(value, 11), 1, 16, XPL_STRING_TYPES.OtherElements) Then
                Throw New IllegalConfigItemValue("group value '" & value & "' contains illegal characters has an inappropriate length")
            End If
            If mItems.IndexOf(value) = -1 Or mItems.IndexOf(value) = idx Then
                mItems(idx) = value
            Else
                Throw New DuplicateNameException("Group '" & value & "' already exists in the list")
            End If
        End Set
    End Property

    ''' <summary>Gets the maximum number of values allowed in the list.</summary>
    ''' <remarks>Read-only. The maximum is set by the <c>XPL_MAX_GROUPS</c> constant</remarks>
    Public ReadOnly Property MaxValues() As Integer
        Get
            Return XPL_MAX_GROUPS
        End Get
    End Property

    ''' <returns>The number of values stored in the list</returns>
    Public ReadOnly Property Count() As Integer
        Get
            Return mItems.Count
        End Get
    End Property

    ''' <summary>
    ''' Removes the specified value from the list.
    ''' </summary>
    ''' <param name="itemValue">The value being removed.</param>
    ''' <remarks>If the value isn't found in the list, no changes will be made nor any exceptions thrown.</remarks>
    Public Sub Remove(ByVal itemValue As String)
        Dim i As Integer = mItems.IndexOf(itemValue)
        If i <> -1 Then
            mItems.RemoveAt(i)
        End If
    End Sub

    ''' <summary>
    ''' Adds a new item to the list.
    ''' </summary>
    ''' <param name="itemValue">The group address to be added in full xPL address format, with 'xpl' as vendor value and 
    ''' 'group' as device value. Example: 'xpl-group.mygroup'. There is one excpetion; if the value is an empty 
    ''' string ("") then it will simply not be added and no exception will be thrown.</param>
    ''' <exception cref="IllegalConfigItemValue">Condition: Value doesn't adhere to the xPL requirements for groupnames.</exception>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: if the <c>Count</c> is equal to the <c>MaxValues</c>, no values can be added.</exception>
    ''' <remarks>Values will always be converted to lowercase. If the value is already present in the list, then it will not be added and no exception will be thrown.</remarks>
    Public Sub Add(ByVal itemValue As String)
        If itemValue = "" Then Exit Sub ' can't add empty values
        'do not allow the same value twice
        itemValue = itemValue.ToLower
        If mItems.IndexOf(itemValue) = -1 Then  'not found, then add
            If mItems.Count >= XPL_MAX_GROUPS Then
                ' too many items
                Throw New System.ArgumentOutOfRangeException
            Else
                ' set value through property handler for additional checks
                Try
                    mItems.Add("")
                    Me.Items(mItems.Count - 1) = itemValue
                Catch ex As Exception
                    ' something went wrong, strip added value and throw same exception
                    mItems.RemoveAt(mItems.Count - 1)
                    Throw ex
                End Try
            End If
        End If
    End Sub
    ''' <returns>The index if the specified value in the list or -1 if it isn't found.</returns>
    ''' <remarks>The value provided will always be converted to lowercase before looking it up.</remarks>
    Public Function IndexOf(ByVal v As String) As Integer
        Return mItems.IndexOf(v.ToLower)
    End Function
    ''' <summary>
    ''' Clears all values from the list
    ''' </summary>
    Public Sub Clear()
        mItems.Clear()
    End Sub

    ''' <summary>
    ''' Returns a String that represents this instance. It will be formatted as in the raw xPL message; each individual group formatted as 'group=value' and the groups will separated by the <c>XPL_LF</c> constant. 
    ''' </summary>
    ''' <returns>A String that represents this instance.</returns>
    ''' <remarks>Returns an empty group value, eg. "group=", if there are no items in the list.</remarks>
    Public Overrides Function ToString() As String
        Dim n As Integer
        Dim result As String = ""
        If mItems.Count = 0 Then
            result = "group="
        Else
            For n = 0 To mItems.Count - 1
                result = "group=" & Me.Items(n) & XPL_LF
            Next
            result = Left(result, Len(result) - Len(XPL_LF))
        End If
        Return result
    End Function
End Class
