'* xPL Library for .NET
'*
'* Version 5.0
'*
'* Copyright (c) 2009 Thijs Schreijer
'* http://www........
'*
'* Copyright (c) 2008 Tom Van den Panhuyzen
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
''' This object represents a single Configuration key. Each configuration key can have multiple values (no duplicates are allowed).
''' The ConfigItems collection holds the ConfigItem objects.
''' The names of the config item cannot be any of the required values; "newconf", "interval", "filter" or "group". The 
''' ConfigItems object has special properties for these.
''' </summary>
''' <remarks>Properties <c>Name</c> and <c>ConfigType</c> can only be set upon creation, they are read-only.</remarks>
Public Class xPLConfigItem

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLConfigItem" /> class.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem</param>
    ''' <param name="itemtype">The item type</param>
    ''' <param name="maxValues">The maximum number of values allowed for this ConfigItem</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name equals one of the reserved values ("newconf", "interval", "filter" or "group") or
    ''' it does not adhere to xPL standards.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only. If <c>maxValues</c> 
    ''' is set to less than 1, it will be set at 1, no exception will be thrown</remarks>
    Public Sub New(ByVal itemName As String, ByVal itemType As xPLConfigTypes, ByVal maxValues As Integer)
        itemName = itemName.ToLower
        If Not IsValidxPL(itemName, 1, 16, XPL_STRING_TYPES.OtherElements) Then
            Throw New IllegalConfigItemName
        End If
        If itemName = "newconf" Or itemName = "interval" Or itemName = "filter" Or itemName = "group" Then
            Throw New IllegalConfigItemName("Name '" & itemName & "' cannot be used for a ConfigItem, it is a reserved name")
        End If
        mName = itemName
        mConfigType = itemType
        ' use property handlers for extra checks
        Me.MaxValues = maxValues
    End Sub

    Private mName As String
    ''' <returns>The name of the ConfigItem</returns>
    ''' <remarks>Read-only. This value can only be set upon creation of the object instance.</remarks>
    Public ReadOnly Property Name() As String
        Get
            Return mName
        End Get
    End Property

    Private mItem As New ArrayList
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <value>The value to be set for the first value in the list (at index position 0)</value>
    ''' <returns>The value set at index position 0</returns>
    ''' <remarks>If <c>Count</c> is 0, then an empty string ("") will be returned, no exception will be thrown.</remarks>
    Public Property Item() As String
        Get
            If mItem.Count = 0 Then Return ""
            Return CStr(mItem(0))
        End Get
        Set(ByVal Value As String)
            ' use property handler for extra checks
            If mItem.Count = 0 Then
                Me.Add(Value)
            Else
                Me.Item(0) = Value
            End If
        End Set
    End Property
    ''' <param name="idx">Index of the item in the list to get/set.</param>
    ''' <value>Value to set at position <c>idx</c> in the list</value>
    ''' <returns>The current value set at position <c>idx</c> in the list.</returns>
    ''' <remarks></remarks>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than 0 or higher than or equal to <c>Count</c>.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <exception cref="DuplicateConfigItemValue">Condition: the assigned value already exists in the list</exception>
    Public Property Item(ByVal idx As Integer) As String
        Get
            Return CStr(mItem(idx))
        End Get
        Set(ByVal value As String)
            Dim i As Integer
            ' verify characters and store if OK, exception otherwise
            If Not IsValidxPL(value, 0, 128, XPL_STRING_TYPES.Values) Then
                Throw New IllegalConfigItemValue("Value '" & value & "' is not a valid value for a config item")
            Else
                ' Check for duplicates
                i = Me.IndexOf(value)
                If i <> -1 Then
                    If CStr(mItem(i)) <> value Then
                        Throw New DuplicateConfigItemValue
                    End If
                End If
                mItem(idx) = value
                End If
        End Set
    End Property

    Private mMaxValues As Integer
    ''' <value>Sets the maximum number of values that can be stored in the ConfigItem</value>
    ''' <returns>The maximum number of values allowed</returns>
    ''' <remarks>If the value is set to less than 1, it will be set at 1. If <c>value</c> is less than the current value of <c>Count</c>, 
    ''' then all excess items will be deleted from the list.</remarks>
    Public Property MaxValues() As Integer
        Get
            Return mMaxValues
        End Get
        Set(ByVal Value As Integer)
            ' handle special case "group" 
            If Value < 1 Then Value = 1
            mMaxValues = Value
            ' right-size array, ditch whatever is over the limit
            If mItem.Count > Value Then mItem.RemoveRange(Value, mItem.Count - Value)
        End Set
    End Property

    Private mConfigType As xPLConfigTypes
    ''' <returns>The xPL configuration item type; config, reconf or option.</returns>
    ''' <remarks>Read-only, can only be set upon creation.</remarks>
    Public ReadOnly Property ConfigType() As xPLConfigTypes
        Get
            Return mConfigType
        End Get
    End Property

    Private mHidden As Boolean = False
    ''' <summary>
    ''' If set to <c>True</c>, then the configitem will not be listed in config.list and config.current 
    ''' messages. Any settings received in a config.response message will be handled.
    ''' </summary>
    ''' <remarks>Creating hidden items can be handy for debugging purposes.</remarks>
    Public Property Hidden() As Boolean
        Get
            Return mHidden
        End Get
        Set(ByVal value As Boolean)
            mHidden = value
        End Set
    End Property

    ''' <returns>The number of values stored in the value list</returns>
    ''' <remarks></remarks>
    Public ReadOnly Property Count() As Integer
        Get
            Return mItem.Count
        End Get
    End Property

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="itemValue">The itemValue to be removed from the list</param>
    ''' <remarks>If the value isn't found, then no exception will be thrown.</remarks>
    Public Sub Remove(ByVal itemValue As String)
        Dim i As Integer = mItem.IndexOf(itemValue)
        If i <> -1 Then
            mItem.RemoveAt(i)
        End If
    End Sub

    ''' <summary>
    ''' Adds a value to the list of values stored in the <c>ConfigItem</c> object
    ''' </summary>
    ''' <param name="itemValue">Value to be added to the list</param>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>Count</c> equals <c>MaxValues</c>, no items can be added.</exception>
    ''' <remarks>If the <c>itemValue</c> is a duplicate of a value already in the list, then no item will be added and no exception will be thrown.</remarks>
    Public Sub Add(ByVal itemValue As String)
        'do not allow the same value twice
        If mItem.IndexOf(itemValue) = -1 Then  'not found, then add
            If mItem.Count >= mMaxValues Then
                ' too many items
                Throw New System.ArgumentOutOfRangeException
            Else
                ' set value through property handler for additional checks
                Try
                    mItem.Add("")
                    Me.Item(mItem.Count - 1) = itemValue
                Catch ex As Exception
                    ' something went wrong, strip added value and throw same exception
                    mItem.RemoveAt(mItem.Count - 1)
                    Throw ex
                End Try
            End If
        End If
    End Sub

    ''' <param name="v">The value being sought in the list</param>
    ''' <returns>The index at which the value <c>v</c> is located in the list, or -1 if it doesn't exist in the list</returns>
    Public Function IndexOf(ByVal v As String) As Integer
        Return mItem.IndexOf(v)
    End Function

    ''' <summary>
    ''' Clears the list with values
    ''' </summary>
    ''' <remarks>The <c>Name</c>, <c>ConfigType</c> and <c>MaxValues</c> properties of the config item remain unchanged.</remarks>
    Public Sub Clear()
        mItem.Clear()
    End Sub

    ''' <returns>A string representing the ConfigItem in the format used for raw XPL. Each value will be in the list in the format "name=value". Hence 'name' is 
    ''' the same for each value in the list. The individual values (lines) will be separated by the <c>XPL_LF</c> constant.</returns>
    ''' <remarks>If there are no items in the list, "name=" will be returned</remarks>
    Public Overrides Function ToString() As String
        Dim n As Integer
        Dim result As String = ""
        If mItem.Count = 0 Then
            result = Me.Name & "="
        Else
            For n = 0 To mItem.Count - 1
                result = Me.Name & "=" & Me.Item(n) & XPL_LF
            Next
            result = Left(result, Len(result) - Len(XPL_LF))
        End If
        Return result
    End Function
End Class


''' <summary>
''' This class represents all configuration items of an xPL device. It has a list of ConfigItem objects and 
''' 4 special properties; <c>conf_Newconf</c>, <c>conf_Interval</c>, <c>conf_Groups</c> and 
''' <c>conf_Filters</c>
''' </summary>
''' <remarks>Duplicate configitemnames are not allowed.</remarks>
Public Class xPLConfigItems

#Region "Constructors"
    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLConfigItems" /> class.
    ''' </summary>
    Public Sub New()
        'nothing to do here
    End Sub
#End Region

#Region "Properties"

    Private mKeys As New ArrayList
    Private mConfigItemList As New ArrayList

    Private mAddress As New xPLAddress(xPLAddressType.Source)
    ''' <summary>
    ''' Returns the address of the device the ConfigItems collection belongs to.
    ''' </summary>
    ''' <returns>xPL Address of the device this <c>ConfigItems</c> object belongs to.</returns>
    ''' <remarks>The 'instance' part of the address can also be returned or set through the <c>conf_Newconf</c> property.</remarks>
    Public ReadOnly Property Address() As xPLAddress
        Get
            Return mAddress
        End Get
    End Property
    ''' <value>a valid xPL device instance name</value>
    ''' <returns>The Instance name of the xPL device. ConfigItem name is "newconf".</returns>
    ''' <remarks></remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; <c>value</c> contains a wildcard, or <c>value</c> has a length outside 
    ''' allowed boundaries, or <c>value</c> contains unallowed characters.</exception>
    Public Property conf_Newconf() As String
        Get
            Return mAddress.Instance
        End Get
        Set(ByVal value As String)
            mAddress.Instance = value
        End Set
    End Property

    Private mInterval As Integer = XPL_DEFAULT_HBEAT
    ''' <summary>
    ''' ConfigItem name is "interval" (set in minutes).
    ''' </summary>
    ''' <value>The heartbeat interval to be set (in seconds)</value>
    ''' <returns>Current heartbeat interval (in seconds)</returns>
    ''' <remarks>If the <c>value</c> is less than <c>XPL_MIN_HBEAT</c> then it will be set at <c>XPL_MIN_HBEAT</c>.
    ''' If the <c>value</c> is greater than <c>XPL_MAX_HBEAT</c> then it will be set at <c>XPL_MAX_HBEAT</c>.</remarks>
    Public Property conf_IntervalInSec() As Integer
        Get
            Return mInterval
        End Get
        Set(ByVal value As Integer)
            If value < XPL_MIN_HBEAT Then value = XPL_MIN_HBEAT
            If value > XPL_MAX_HBEAT Then value = XPL_MAX_HBEAT
            mInterval = value
        End Set
    End Property
    ''' <summary>
    ''' ConfigItem name is "interval".
    ''' </summary>
    ''' <value>The heartbeat interval to be set (in minutes)</value>
    ''' <returns>Current heartbeat interval (in minutes). Note that internally the interval is stored in seconds, any value returned will be the rounded number of minutes.</returns>
    ''' <remarks>If the <c>value</c> is less than <c>XPL_MIN_HBEAT / 60</c> then it will be set at <c>XPL_MIN_HBEAT / 60</c>.
    ''' If the <c>value</c> is greater than <c>XPL_MAX_HBEAT / 60</c> then it will be set at <c>XPL_MAX_HBEAT / 60</c>. No exceptions will be thrown.</remarks>
    Public Property conf_IntervalInMin() As Integer
        Get
            Return CInt(Int(mInterval / 60 + 0.5))  ' round to minutes
        End Get
        Set(ByVal value As Integer)
            Me.conf_IntervalInSec = value * 60
        End Set
    End Property

    Private mconf_Filter As New xPLFilters
    ''' <summary>
    ''' Contains the xPLFilters object that holds the filter collection. ConfigItem name "filter".
    ''' </summary>
    ''' <remarks>Read-only.</remarks>
    Public ReadOnly Property conf_Filter() As xPLFilters
        Get
            Return mconf_Filter
        End Get
    End Property

    Private mconf_Group As New xPLGroups
    ''' <summary>
    ''' Contains the xPLGroups object that holds the group collection. ConfigItem name "group".
    ''' </summary>
    ''' <remarks>Read-only.</remarks>
    Public ReadOnly Property conf_Group() As xPLGroups
        Get
            Return mconf_Group
        End Get
    End Property

    ''' <param name="key">The <c>Name</c> of the ConfigItem object being sought</param>
    ''' <returns>the xPLConfigItem from the list that has a <c>Name</c> value that corresponds to the provide <c>key</c> value</returns>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: the <c>key</c> cannot be found.</exception>
    ''' <remarks>Read-only, use <c>Add</c> or <c>Remove</c> to modify the list. Value of <c>key</c> will be converted to lowercase. The ConfigItems for "newconf", "interval", "group" and 
    ''' "filter" cannot be retrieved this way, they have their own properties; <c>xPLConfigItems.conf_xxxxxx</c></remarks>
    Default Public ReadOnly Property Item(ByVal key As String) As xPLConfigItem
        Get
            Return Me.Item(mKeys.IndexOf(key.ToLower()))
        End Get
    End Property

    ''' <param name="idx">The index of the ConfigItem object in the list</param>
    ''' <returns>A reference to the xPLConfigItem object in the list at position <c>idx</c>.</returns>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: the <c>idx</c> value is less than 0 or greater than <c>Count</c>.</exception>
    ''' <remarks>Read-only, use <c>Add</c> or <c>Remove</c> to modify the list. The ConfigItems for "newconf", "interval", "group" and "filter" cannot be retrieved this way, they have
    ''' their own properties; <c>xPLConfigItems.conf_xxxxxx</c></remarks>
    Default Public ReadOnly Property Item(ByVal idx As Integer) As xPLConfigItem
        Get
            Try
                Return CType(mConfigItemList(idx), xPLConfigItem)
            Catch ex As Exception
                Throw ex
            End Try
        End Get
    End Property

    ''' <returns>The number of ConfigItem objects in the list</returns>
    ''' <remarks><c>Count</c> does not include the 4 ConfigItems for "newconf", "interval", "group" and 
    ''' "filter". They are not in the list but have their own properties; <c>xPLConfigItems.conf_xxxxxx</c></remarks>
    Public ReadOnly Property Count() As Integer
        Get
            Return mKeys.Count
        End Get
    End Property

#End Region

#Region "Collection management"
    ''' <returns>The index of the ConfigItem with a <c>Name</c> that equals <c>itemName</c>.</returns>
    ''' <remarks><c>itemName</c> will be converted to lowercase. Returns -1 if not found. The ConfigItems for "newconf", 
    ''' "interval", "group" and "filter" cannot be retrieved this way, they have their own properties; <c>xPLConfigItems.conf_xxxxxx</c></remarks>
    Public Function IndexOf(ByVal itemName As String) As Integer
        Return mKeys.IndexOf(itemName.ToLower)
    End Function

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLConfigItem" /> class and adds it to the list.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem</param>
    ''' <param name="itemDefaultValue">The item value (the first one to add to list of values stored in the config item, use
    ''' the <c>Add</c> method to add more values to the list).</param>
    ''' <param name="itemtype">The item type</param>
    ''' <param name="maxValues">The maximum number of values allowed for this ConfigItem</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name equals one of the reserved values ("newconf", 
    ''' "interval", "filter" or "group") or it does not adhere to xPL standards.</exception>
    ''' <exception cref="IllegalConfigItemValue">Condition: the value doesn't adhere to xPL standards</exception>
    ''' <exception cref="DuplicateConfigItemName">Condition: If <c>itemName</c> is already present in the list, or it equals any of; 
    ''' "newconf", "interval", "filter" or "group".</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only. If <c>maxValues</c> 
    ''' is set to less than 1, it will be set at 1, no exception will be thrown</remarks>
    Public Sub Add(ByVal itemName As String, ByVal itemDefaultValue As String, ByVal itemType As xPLConfigTypes, ByVal MaxValues As Integer)
        Dim ci As xPLConfigItem
        ci = New xPLConfigItem(itemName, itemType, MaxValues)
        ci.Add(itemDefaultValue)
        Me.Add(ci)
    End Sub

    ''' <summary>
    ''' Initializes a new instance of the <see cref="xPLConfigItem" /> class and adds it to the list. The value will be set to an empty 
    ''' string (eg. ""), the type will be set to "option" and the maximum number of values allowed to 1.
    ''' </summary>
    ''' <param name="itemName">Name or key of the configitem.</param>
    ''' <exception cref="IllegalConfigItemName">Condition: The name equals one of the reserved values ("newconf", 
    ''' "interval", "filter" or "group") or it does not adhere to xPL standards.</exception>
    ''' <exception cref="DuplicateConfigItemName">Condition: If <c>itemName</c> is already present in the list, or it equals any of; 
    ''' "newconf", "interval", "filter" or "group".</exception>
    ''' <remarks>The <c>itemName</c> will always be converted to lowercase, and can only be set upon creation; it is read-only.</remarks>
    Public Sub Add(ByVal itemName As String)
        Me.Add(itemName, "", xPLConfigTypes.xOption, 1)
    End Sub

    ''' <summary>
    ''' Adds a ConfigItem object to the list of ConfigItems
    ''' </summary>
    ''' <param name="ci">ConfigItem object to be added to the list</param>
    ''' <exception cref="DuplicateConfigItemName">Condition: If the <c>Name</c> of the <c>ConfigItem</c> object 
    ''' provided is already present in the list, or it equals any of; "newconf", "interval", "filter" or "group".</exception>
    ''' <remarks></remarks>
    Public Sub Add(ByVal ci As xPLConfigItem)
        If ci Is Nothing Then Return
        If Me.IndexOf(ci.Name) = -1 Then
            ' Not in the list already
            Select Case ci.Name
                Case "newconf", "interval", "filter", "group"
                    ' duplicate!
                    Throw New DuplicateConfigItemName(ci.Name & " is fixed item in the configuration items list")
                Case Else
                    mConfigItemList.Add(ci)
                    mKeys.Add(ci.Name)
                    If Me.Debug Then
                        LogError("ConfigItems.Add", _
                                     "Added: " & _
                                     vbCrLf & "   Name: " & ci.Name & _
                                     vbCrLf & "   Max: " & ci.MaxValues.ToString & _
                                     vbCrLf & "   Type: " & ci.ConfigType.ToString, _
                                     EventLogEntryType.Information)
                    End If
            End Select
        Else
            ' duplicate!
            Throw New DuplicateConfigItemName(ci.Name & " is allready present in the configuration items list")
        End If
    End Sub

    ''' <param name="key">The <c>Name</c> of the ConfigItem object to remove from the list.</param>
    ''' <remarks><c>key</c> will be converted to lowercase. If the item is not found, no exception is thrown. The ConfigItems for 
    ''' "newconf", "interval", "group" and "filter" cannot be removed this way, they have their own properties; 
    ''' <c>xPLConfigItems.conf_xxxxxx</c> and cannot be removed.</remarks>
    Public Sub Remove(ByVal key As String)
        Dim i As Integer = Me.IndexOf(key.ToLower)
        If i <> -1 Then Me.Remove(i)
    End Sub

    ''' <param name="idx">The index of the item to remove from the list.</param>
    ''' <exception cref="ArgumentOutOfRangeException">Condition: <c>idx</c> is less than 0 or greater than or equal to <c>Count</c>.</exception>
    ''' <remarks>The ConfigItems for "newconf", "interval", "group" and "filter" cannot be removed this way, they have their own properties; 
    ''' <c>xPLConfigItems.conf_xxxxxx</c> and cannot be removed.</remarks>
    Public Sub Remove(ByVal idx As Integer)
        mConfigItemList.RemoveAt(idx)
        mKeys.RemoveAt(idx)
    End Sub
#End Region

#Region "Config message handling"

    ''' <summary>
    ''' Creates an xPL message containing a valid 'config.current' status message, based upon the content of the
    ''' <c>ConfigItems</c> object.
    ''' </summary>
    ''' <returns>A complete xPL message containg a valid 'config.current' status message</returns>
    ''' <remarks>ConfigItems with the <seealso cref="xPLConfigItem.Hidden"/> property set to <c>True</c> 
    ''' will not be added to the message.</remarks>
    Public Function ConfigCurrent() As xPLMessage
        Dim xr As xPLMessage
        Dim n As Integer
        Dim i As Integer
        Dim d As Boolean = Me.Debug
        If d Then
            LogError("ConfigItems.ConfigCurrent", "Creating config.current message")
        End If
        xr = New xPLMessage()
        xr.MsgType = xPLMessageTypeEnum.Status
        xr.Source = mAddress.ToString
        xr.Target = "*"
        xr.Schema = "config.current"
        'add configuration as key-value pairs
        xr.KeyValueList.Add(New xPLKeyValuePair("newconf", conf_Newconf))
        xr.KeyValueList.Add(New xPLKeyValuePair("interval", CStr(conf_IntervalInMin)))
        If Me.conf_Filter.Count > 0 Then
            For n = 0 To conf_Filter.Count - 1
                xr.KeyValueList.Add(New xPLKeyValuePair("filter", conf_Filter.Item(n).ToString))
            Next
        Else
            If d Then
                LogError("ConfigItems.ConfigCurrent", "'filter' not added, has no items")
            End If
        End If
        If conf_Group.Count > 0 Then
            For n = 0 To conf_Group.Count - 1
                xr.KeyValueList.Add(New xPLKeyValuePair("group", conf_Group.Items(n)))
            Next
        Else
            If d Then
                LogError("ConfigItems.ConfigCurrent", "'group' not added, has no items")
            End If
        End If
        ' now add remaining items (if not hidden)
        For i = 0 To Me.Count - 1
            If Me.Item(i).Count > 0 And Not Me.Item(i).Hidden Then
                For n = 0 To Me.Item(i).Count - 1
                    xr.KeyValueList.Add(Me.Item(i).Name, Me.Item(i).Item(n))
                Next
            Else
                If d Then
                    If Me.Item(i).Hidden Then
                        LogError("ConfigItems.ConfigCurrent", "'" & Me.Item(i).Name & "' not added, is hidden")
                    Else
                        LogError("ConfigItems.ConfigCurrent", "'" & Me.Item(i).Name & "' not added, has no items")
                    End If
                End If
            End If
        Next

        If d Then
            LogError("ConfigItems.ConfigCurrent", "completed config.current message; " & vbCrLf & xr.RawxPL)
        End If

        Return xr
    End Function

    ''' <summary>
    ''' Creates an xPL message containing a valid 'config.list' status message, based upon the content of the
    ''' <c>ConfigItems</c> object.
    ''' </summary>
    ''' <returns>A complete xPL message containg a valid 'config.list' status message</returns>
    ''' <remarks>ConfigItems with the <seealso cref="xPLConfigItem.Hidden"/> property set to <c>True</c> 
    ''' will not be added to the message.</remarks>
    Public Function ConfigList() As xPLMessage
        Dim xr As xPLMessage
        Dim n As Integer
        Dim s As String = ""
        Dim d As Boolean = Me.Debug
        If d Then
            LogError("ConfigItems.ConfigList", "Creating config.list message")
        End If
        xr = New xPLMessage()
        xr.MsgType = xPLMessageTypeEnum.Status
        xr.Source = mAddress.ToString
        xr.Target = "*"
        xr.Schema = "config.list"
        'add configuration as key-value pairs
        xr.KeyValueList.Add(New xPLKeyValuePair("reconf", "newconf"))
        xr.KeyValueList.Add(New xPLKeyValuePair("option", "interval"))
        xr.KeyValueList.Add(New xPLKeyValuePair("option", "group[" & CStr(XPL_MAX_GROUPS) & "]"))
        xr.KeyValueList.Add(New xPLKeyValuePair("option", "filter[" & CStr(XPL_MAX_FILTERS) & "]"))
        If Me.Count <> 0 Then
            For n = 0 To Me.Count - 1
                ' only add items that are not marked as hidden
                If Not Me.Item(n).Hidden Then
                    Select Case Me.Item(n).ConfigType
                        Case xPLConfigTypes.xConfig : s = "config"
                        Case xPLConfigTypes.xOption : s = "option"
                        Case xPLConfigTypes.xReconf : s = "reconf"
                    End Select
                    If Me.Item(n).MaxValues > 1 Then
                        xr.KeyValueList.Add(New xPLKeyValuePair(s, Me.Item(n).Name & "[" & CStr(Me.Item(n).MaxValues) & "]"))
                    Else
                        xr.KeyValueList.Add(New xPLKeyValuePair(s, Me.Item(n).Name))
                    End If
                Else
                    If d Then
                        LogError("ConfigItems.ConfigList", "'" & Me.Item(n).Name & "' not added, is hidden")
                    End If
                End If
            Next n
        End If

        If d Then
            LogError("ConfigItems.ConfigList", "completed config.list message; " & vbCrLf & xr.RawxPL)
        End If

        Return xr
    End Function

    ''' <summary>
    ''' Replaces current configuration settings with the setting received in a 'config.response' xPL message. NOTE: if
    ''' after handling the message the <c>conf_Newconf</c> property has changed then the device has a new address and
    ''' appropriate hbeat/config messages must be sent by the device (the xPLDevice object takes care of this).
    ''' </summary>
    ''' <param name="myxpl">xPL message containing the 'config.response' message. If this parameter 
    ''' <c>Is Nothing</c> then the method immediately exits without making any changes to the <c>ConfigItems</c> 
    ''' object</param>
    ''' <remarks>The message must be a 'command' message and the schema must be 'config.response', if not no changes
    ''' will be made and no exception will be thrown.</remarks>
    Public Sub ConfigResponse(ByVal myxpl As xPLMessage)
        Dim n As Integer = 0
        Dim kv As xPLKeyValuePair
        Dim ListWasReset As New ArrayList
        Dim d As Boolean = False
        ' find parent to check for debug logging
        d = Me.Debug

        ' new configuration received, deal with new settings
        If myxpl Is Nothing Then Exit Sub
        If myxpl.MsgType <> xPLMessageTypeEnum.Command Or _
           myxpl.Schema.ToString <> "config.response" Then Exit Sub

        If d Then
            LogError("ConfigItems.ConfigResponse for " & Me.mAddress.ToString, _
                     "Raw xPL received:" & vbCrLf & myxpl.RawxPLReceived)
        End If

        For n = 0 To myxpl.KeyValueList.Count - 1
            kv = myxpl.KeyValueList.Item(n)
            If ListWasReset.IndexOf(kv.Key) = -1 Then
                ' list wasn't reset yet, first key found, so reset now
                Select Case kv.Key
                    Case "newconf", "interval"
                        ' do nothing
                    Case "group"
                        conf_Group.Clear()
                    Case "filter"
                        conf_Filter.Clear()
                    Case Else
                        If Not Item(kv.Key) Is Nothing Then
                            Item(kv.Key).Clear()
                        Else
                            LogError("ConfigItems.ConfigResponse", _
                                         "Unknown config item received: " & kv.ToString, _
                                         EventLogEntryType.Warning)
                        End If
                End Select
                ' now add to list, so it won't be reset again
                ListWasReset.Add(kv.Key)
            End If

            Select Case kv.Key
                Case "newconf"
                    Try
                        conf_Newconf = kv.Value
                    Catch
                        LogError("ConfigItems.ConfigResponse", _
                                     "Setting failed: " & kv.ToString, _
                                     EventLogEntryType.Warning)
                    End Try
                Case "interval"
                    Try
                        If kv.Value <> "" Then
                            conf_IntervalInMin = CInt(kv.Value)
                        End If
                    Catch
                        LogError("ConfigItems.ConfigResponse", _
                                     "Setting failed: " & kv.ToString, _
                                     EventLogEntryType.Warning)
                    End Try
                Case "filter"
                    Try
                        If kv.Value <> "" Then
                            conf_Filter.Add(kv.Value)
                        End If
                    Catch
                        LogError("ConfigItems.ConfigResponse", _
                                     "Setting failed: " & kv.ToString, _
                                     EventLogEntryType.Warning)
                    End Try
                Case "group"
                    Try
                        If kv.Value <> "" Then
                            conf_Group.Add(kv.Value)
                        End If
                    Catch
                        LogError("ConfigItems.ConfigResponse", _
                                     "Setting failed: " & kv.ToString, _
                                     EventLogEntryType.Warning)
                    End Try
                Case Else
                    Try
                        If Not Item(kv.Key) Is Nothing And kv.Value <> "" Then
                            Item(kv.Key).Add(kv.Value)
                        Else
                            LogError("ConfigItems.ConfigResponse", _
                                         "Setting of unknown item failed: " & kv.ToString, _
                                         EventLogEntryType.Warning)
                        End If
                    Catch
                        LogError("ConfigItems.ConfigResponse", _
                                     "Setting failed: " & kv.ToString, _
                                     EventLogEntryType.Warning)
                    End Try
            End Select
        Next

        If d Then
            LogError("ConfigItems.ConfigResponse for " & Me.mAddress.ToString, "Completed")
        End If
    End Sub

#End Region

#Region "Other..."

    ''' <summary>
    ''' Returns a raw xPL string containing all the configuration items. In the order; "newconf", "interval", "group", "filter" followed by the custom items
    ''' in the list.
    ''' </summary>
    ''' <returns>String representation of configuration values.</returns>
    ''' <remarks>Each line has a format 'name=value', lines are separated by XPL_LF.</remarks>
    Public Overrides Function ToString() As String
        Dim result As String = ""
        ' setup required 4 items
        result += "newconf=" & mAddress.Instance & XPL_LF
        result += "interval=" & CStr(mInterval) & XPL_LF
        result += conf_Filter.ToString & XPL_LF
        result += conf_Group.ToString
        ' add remaining items
        For Each x As xPLConfigItem In mConfigItemList
            result = result & XPL_LF & x.ToString
        Next
        Return result
    End Function

    ''' <summary>
    ''' Determine whether the object is running in debugging mode, by looking up its parent xPLDevice
    ''' </summary>
    ''' <returns><c>True</c> if the xPLDevice object with address <c>mAddress</c> is in debug mode.</returns>
    ''' <remarks>Default value (if not found) is <c>False</c>.</remarks>
    Private ReadOnly Property Debug() As Boolean
        Get
            Dim d As Boolean = False
            ' find parent to check for debug logging
            If xPLListener.IndexOf(Me.mAddress) <> -1 Then
                d = xPLListener.Device(Me.mAddress).Debug
            End If
            Return d
        End Get
    End Property

#End Region

End Class

