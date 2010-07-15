'* xPL Library for .NET
'*
'* Version 5.2
'*
'* Copyright (c) 2009-2010 Thijs Schreijer
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
Imports xPL.xPLMessage

''' <summary>
''' Represents an xPL filter for filtering incoming messages. Filters exist of 5 parts; 1) messagetype (cmnd/trig/stat), 2) Target vendor, 3) Target device, 4)Target instance, 5) Schema class, 6) Schema type
''' Each part can be either wildcarded or set to a specific value.
''' </summary>
''' <remarks>The xPLFilter objects can be stored in an xPLFilters object.</remarks>
Public Class xPLFilter

#Region "Properties"
    Dim mType As xPLMessageTypeEnum = xPLMessageTypeEnum.Any
    ''' <summary>
    ''' A xPLMessageTypeEnum value representing the value for the messagetype in the filter.
    ''' </summary>
    ''' <value>A valid message type value.</value>
    ''' <returns>The current messagetype</returns>
    ''' <remarks>The default value is wildcard (Any, or "*").</remarks>
    Public Property MsgType() As xPLMessageTypeEnum
        Get
            Return mType
        End Get
        Set(ByVal value As xPLMessageTypeEnum)
            mType = value
        End Set
    End Property

    Dim mAddress As New xPLAddress(xPLAddressType.Target, "*", "*", "*")
    ''' <summary>
    ''' A xPLMessageAddress object representing the value for the vendor, device and instance in the filter.
    ''' </summary>
    ''' <value>A valid xPLaddress object. Please note that not a reference to the object provided will be set, but the values within the object will be copied to the filter.</value>
    ''' <returns>A reference to the xPLAddress object.</returns>
    ''' <remarks>If the value is set to <c>Nothing</c> then a wildcard will be put in place for the address elements, no exception will be thrown.
    ''' The default value is wildcard ("*").</remarks>
    Public Property Address() As xPLAddress
        Get
            If mAddress Is Nothing Then mAddress = New xPLAddress(xPLAddressType.Target, "*", "*", "*")
            Return mAddress
        End Get
        Set(ByVal value As xPLAddress)
            If mAddress Is Nothing Then mAddress = New xPLAddress(xPLAddressType.Target, "*", "*", "*")
            If Not value Is Nothing Then
                mAddress.Vendor = value.Vendor
                mAddress.Device = value.Device
                mAddress.Instance = value.Instance
            End If
        End Set
    End Property
    Dim mSchema As New xPLSchema("*", "*")
    ''' <summary>
    ''' A xPLSchema object representing the value for the schema class and schema type in the filter.
    ''' </summary>
    ''' <value>A valid xPLSchema object. Please note that not a reference to the object provided will be set, but the values within the object will be copied to the filter.</value>
    ''' <returns>A reference to the xPLSchema object</returns>
    ''' <remarks>If the value is set to <c>Nothing</c> then a wildcard will be put in place for the schema elements, no exception will be thrown.
    ''' The default value is wildcard ("*").</remarks>
    Public Property Schema() As xPLSchema
        Get
            If mSchema Is Nothing Then mSchema = New xPLSchema("*", "*")
            Return mSchema
        End Get
        Set(ByVal value As xPLSchema)
            If mSchema Is Nothing Then mSchema = New xPLSchema("*", "*")
            If Not value Is Nothing Then
                mSchema.SchemaClass = value.SchemaClass
                mSchema.SchemaType = value.SchemaType
            End If
        End Set
    End Property

#End Region

#Region "Constructors"

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLFilter" /> class.
    ''' </summary>
    ''' <param name="t">The message type to be set</param>
    ''' <param name="a">The address to be set</param>
    ''' <param name="s">The schema to be set</param>
    Public Sub New(ByVal t As xPLMessageTypeEnum, ByVal a As xPLAddress, ByVal s As xPLSchema)
        Me.MsgType = t
        Me.Address = a
        Me.Schema = s
    End Sub
    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLFilter" /> class.
    ''' </summary>
    ''' <param name="flt">A valid filter string in the format 'msgtype.vendor.device.instance.schemaclass.schematype'. Any of the elements may be wildcarded.</param>
    ''' <remarks></remarks>
    ''' <exception cref="IllegalFieldContentsException">Condition: any of the elements has illegal content, by means of length or characters used.</exception>
    Public Sub New(ByVal flt As String)
        Dim itm() As String = flt.Split("."c)
        If flt = "" Then
            Throw New IllegalFieldContentsException("Illegal filter value specified is an empty string.")
        End If
        Try
            mType = MsgType2Enum(itm(0))
            Me.Address.Vendor = itm(1)
            Me.Address.Device = itm(2)
            Me.Address.Instance = itm(3)
            Me.Schema.SchemaClass = itm(4)
            Me.Schema.SchemaType = itm(5)
        Catch ex As Exception
            Throw New IllegalFieldContentsException("Illegal filter value specified: " & flt, ex)
        End Try
    End Sub

#End Region

#Region "Matches"

    ''' <summary>
    ''' Matches the provided set of type, address and schema with the values in the filter object
    ''' </summary>
    ''' <param name="t">Message Type to be matched against the filter</param>
    ''' <param name="a">Address to be matched against the filter</param>
    ''' <param name="s">Schema to be matched against the filter</param>
    ''' <returns>True if the individual elements are equal or wildcarded.</returns>
    ''' <remarks>If either the address or the schema <c>Is Nothing</c> then they will be wildcarded</remarks>
    Public Function Matches(ByVal t As xPLMessageTypeEnum, ByVal a As xPLAddress, ByVal s As xPLSchema) As Boolean
        If a Is Nothing Then a = New xPLAddress(xPLAddressType.Target, "*")
        If s Is Nothing Then s = New xPLSchema("*", "*")
        Return ((Me.mType = t Or Me.mType = xPLMessageTypeEnum.Any Or t = xPLMessageTypeEnum.Any) And _
                Me.Address.Matches(a) And Me.Schema.Matches(s))
    End Function

    ''' <summary>
    ''' Matches the provided xPLMessage against with the values in the filter object
    ''' </summary>
    ''' <param name="msg">The xPL message to match against the filter</param>
    ''' <returns>True if the individual elements are equal or wildcarded.</returns>
    Public Function Matches(ByVal msg As xPLMessage) As Boolean
        Return Me.Matches(msg.MsgType, New xPLAddress(xPLAddressType.Target, msg.Target), New xPLSchema(msg.Schema))
    End Function
#End Region

#Region "Other..."

    ''' <returns>A filter string in the format 'msgtype.vendor.device.instance.schemaclass.schematype'.</returns>
    Public Overrides Function ToString() As String
        Return MsgType2String(Me.MsgType) & "." & Me.Address.Vendor & "." & Me.Address.Device & "." & _
        Me.Address.Instance & "." & Me.Schema.ToString
    End Function

#End Region

End Class


''' <summary>
''' This object represents a list of filters, as set for an xPL device.
''' </summary>
''' <remarks>Duplicate values are not allowed in the filter list.</remarks>
Public Class xPLFilters

    Private mList As New ArrayList

    ''' <summary>
    ''' Get or sets a filter in the filters list based on the index provided.
    ''' </summary>
    ''' <param name="idx">Index of the item to get/set</param>
    ''' <value>A valid xPLFilter object</value>
    ''' <returns>a reference to the filter at the position <c>idx</c> in the list</returns>
    ''' <remarks></remarks>
    ''' <exception cref="DuplicateNameException">Condition: if the filter string being set is already present in the list.</exception>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than zero or <c>idx</c> is equal to or greater than <c>Count</c></exception>
    Public Property Item(ByVal idx As Integer) As xPLFilter
        Get
            Return CType(mList.Item(idx), xPLFilter)
        End Get
        Set(ByVal value As xPLFilter)
            If Me.IndexOf(value.ToString) = -1 Then
                mList.Item(idx) = value
            Else
                Throw New DuplicateNameException("Filter '" & value.ToString & "' is already present in the list.")
            End If
        End Set
    End Property
    ''' <returns>The number of filters currently in the list</returns>
    Public ReadOnly Property Count() As Integer
        Get
            Return mList.Count
        End Get
    End Property
    ''' <summary>
    ''' Looks up a filter string in the list of filters.
    ''' </summary>
    ''' <param name="flt">the filter being searched for</param>
    ''' <returns>Index position of the filter in the list, or -1 if it isn't found</returns>
    ''' <remarks>Match is made on the filter CONTENT (the <c>flt.ToString</c> value), not on the xPLFilter-objectreference.</remarks>
    Public Function IndexOf(ByVal flt As xPLFilter) As Integer
        If flt Is Nothing Then Return -1
        Return Me.IndexOf(flt.ToString)
    End Function
    ''' <summary>
    ''' Looks up a filter string in the list of filters.
    ''' </summary>
    ''' <param name="flt">the filter being searched for</param>
    ''' <returns>Index position of the filter in the list, or -1 if it isn't found</returns>
    ''' <remarks>Filter string provided will always be converted to lowercase, no exception will be thrown.</remarks>
    Public Function IndexOf(ByVal flt As String) As Integer
        flt = flt.ToLower
        Dim i As Integer
        For i = 0 To mList.Count - 1
            If mList.Item(i).ToString = flt Then Return i
        Next
        Return -1
    End Function
    ''' <summary>
    ''' Add a filter object to the list.
    ''' </summary>
    ''' <param name="flt">The filter object to be added.</param>
    ''' <remarks>The filter will only be added if it is not a duplicate. If it is a duplicate, no exception will be thrown.
    ''' Note that the filter value (eg. <c>flt.ToString</c>) is used to check for duplicates, not the reference to the filter object.</remarks>
    Public Sub Add(ByVal flt As xPLFilter)
        If Me.IndexOf(flt.ToString) = -1 Then
            mList.Add(flt)
        End If
    End Sub
    ''' <summary>
    ''' Creates a new filter object and adds it to the list.
    ''' </summary>
    ''' <param name="flt">The filter to be added. If an empty string ("") is provided, it will 
    ''' not be added and no exception will be thrown.</param>
    ''' <exception cref="IllegalFieldContentsException">Condition: any of the filter elements has illegal content, by means of length or characters used.</exception>
    ''' <remarks>The filter will only be added if it is not a duplicate. If it is a duplicate, no exception will be thrown.
    ''' Note that the filter value (eg. <c>flt.ToString</c>) is used to check for duplicates, not the reference 
    ''' to the filter object. The string provided will be converted to lowercase.</remarks>
    Public Sub Add(ByVal flt As String)
        flt = flt.ToLower
        If flt = "" Then Exit Sub
        If Me.IndexOf(flt) = -1 Then
            mList.Add(New xPLFilter(flt))
        End If
    End Sub
    ''' <summary>
    ''' Removes the item at the position <c>idx</c>
    ''' </summary>
    ''' <param name="idx">The index of the item to be removed</param>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than zero or <c>idx</c> is equal to or greater than <c>Count</c></exception>
    Public Sub Remove(ByVal idx As Integer)
        mList.RemoveAt(idx)
    End Sub
    ''' <summary>
    ''' Removes the filter from the list
    ''' </summary>
    ''' <param name="flt">The filter object to be removed.</param>
    ''' <remarks>Note that the filter that matches <c>flt.ToString</c> will be removed. If the filter in't found in 
    ''' the list, no exception will be thrown.</remarks>
    Public Sub Remove(ByVal flt As xPLFilter)
        If Not flt Is Nothing Then
            Me.Remove(flt.ToString)
        End If
    End Sub
    ''' <summary>
    ''' Removes the filter from the list
    ''' </summary>
    ''' <param name="flt">The filter string to be removed.</param>
    ''' <remarks>If the filter in't found in the list, no exception will be thrown.</remarks>
    Public Sub Remove(ByVal flt As String)
        Dim i As Integer
        i = Me.IndexOf(flt)
        If i <> -1 Then Me.Remove(i)
    End Sub
    ''' <summary>
    ''' Clears the filter list.
    ''' </summary>
    Public Sub Clear()
        mList.Clear()
    End Sub

    ''' <summary>
    ''' Returns a string representation of the filter list.
    ''' </summary>
    ''' <returns>String representation of the filter list in the format as found in an raw xPL string; each filter listed in the 
    ''' format 'filter=value', with the different filter values separated by XPL_LF constant.</returns>
    ''' <remarks>If the list has no items, then "filter=" will be the return value.</remarks>
    Public Overrides Function ToString() As String
        Dim result As String = ""
        If Me.Count = 0 Then
            Return "filter="
        Else
            For Each x As xPLFilter In mList
                result += "filter=" & x.ToString & XPL_LF
            Next
            result = Left(result, result.Length - XPL_LF.Length) ' remove final LF
        End If
        Return result
    End Function

    ''' <summary>
    ''' Matches a specific xPL messagetype with the entire list of filters.
    ''' </summary>
    ''' <param name="t">The xPL message type to check</param>
    ''' <returns>True if it matches any of the filters in the list, or if there are no filters in the list. False otherwise.</returns>
    ''' <remarks></remarks>
    Public Function Matches(ByVal t As xPLMessageTypeEnum) As Boolean
        Return Me.Matches(t, New xPLAddress(xPLAddressType.Target, "*"), New xPLSchema("*.*"))
    End Function
    ''' <summary>
    ''' Matches a specific xPL address with the entire list of filters.
    ''' </summary>
    ''' <param name="a">The xPL address to check</param>
    ''' <returns>True if it matches any of the filters in the list, or if there are no filters in the list. False otherwise.</returns>
    ''' <remarks></remarks>
    Public Function Matches(ByVal a As xPLAddress) As Boolean
        Return Me.Matches(xPLMessageTypeEnum.Any, a, New xPLSchema("*.*"))
    End Function
    ''' <summary>
    ''' Matches a specific xPL schema with the entire list of filters.
    ''' </summary>
    ''' <param name="s">The xPL schema to check</param>
    ''' <returns>True if it matches any of the filters in the list, or if there are no filters in the list. False otherwise.</returns>
    ''' <remarks></remarks>
    Public Function Matches(ByVal s As xPLSchema) As Boolean
        Return Me.Matches(xPLMessageTypeEnum.Any, New xPLAddress(xPLAddressType.Target, "*"), s)
    End Function
    ''' <summary>
    ''' Matches a specific xPL messagetype, xPL address and xPL schema with the entire list of filters.
    ''' </summary>
    ''' <param name="t">The xPL message type to check</param>
    ''' <param name="a">The xPL address to check</param>
    ''' <param name="s">The xPL schema to check</param>
    ''' <returns>True if the values match any of the filters in the list, or if there are no filters in the list. False otherwise.</returns>
    ''' <remarks></remarks>
    Public Function Matches(ByVal t As xPLMessageTypeEnum, ByVal a As xPLAddress, ByVal s As xPLSchema) As Boolean
        If a Is Nothing Then Return False
        If s Is Nothing Then Return False
        If mList.Count = 0 Then Return True
        For Each flt As xPLFilter In mList
            If flt.Matches(t, a, s) Then Return True
        Next
        Return False
    End Function
    ''' <summary>
    ''' Matches a specific xPL message with the entire list of filters.
    ''' </summary>
    ''' <param name="m">The xPL message to check</param>
    ''' <returns>True if the message values for Type, Address and Schema match any of the filters in the list, or if there are no filters in the list. False otherwise.</returns>
    ''' <remarks></remarks>
    Public Function Matches(ByVal m As xPLMessage) As Boolean
        Return Me.Matches(m.MsgType, New xPLAddress(xPLAddressType.Target, m.Source), New xPLSchema(m.Schema))
    End Function

End Class

