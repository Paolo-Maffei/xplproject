'* xPL Library for .NET
'*
'* Version 5.1
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

''' <summary>
''' The xPLAdress class represents a valid xPL address, containing a vendor id, device id and instance id. The type of 
''' address (source or target), must be set upon creation, and cannot be changed.
''' </summary>
''' <remarks>The type indication makes the difference for allowing the wildcard ('*') as a value for any of the ID's. If any of the ID's is set to the wildcard, 
''' the overall result will also be a wildcard. Example: 
''' <c>x = New xPLAddress(xPLAddressType.Target, "vendor-dev.*").ToString</c>
''' will always result in <c>x = "*"</c></remarks>
Public Class xPLAddress

#Region "Constructors"

    ''' <summary>
    ''' Creates a new xPLAddress object with default "vendorid", "deviceid" and a randomized instance ID
    ''' </summary>
    ''' <param name="AddrType">Indicates the address type; source or target</param>
    Public Sub New(ByVal AddrType As xPLAddressType)
        Me.New(AddrType, "vendorid", "deviceid", GetRandomInstanceId)
    End Sub

    ''' <summary>
    ''' Creates a new xPLaddress object from a properly formatted string.
    ''' </summary>
    ''' <param name="AddrType">Indicates the address type; source or target</param>
    ''' <param name="address">The address string in the xPL prescribed format; "vendor-device.instance", or a wildcard "*"</param>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or any of the elements 
    ''' has a length outside allowed boundaries, or any of the elements contains unallowed characters.</exception>
    Public Sub New(ByVal AddrType As xPLAddressType, ByVal address As String)
        mType = AddrType
        Me.FullAddress = address
    End Sub

    ''' <summary>
    ''' Creates a new xPLAddress object with the given vendor ID and device ID. The instance ID will be randomized.
    ''' </summary>
    ''' <param name="AddrType">Indicates the address type; source or target</param>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or any of the elements 
    ''' has a length outside allowed boundaries, or any of the elements contains unallowed characters.</exception>
    Public Sub New(ByVal AddrType As xPLAddressType, ByVal vendorid As String, ByVal deviceid As String)
        Me.New(AddrType, vendorid, deviceid, GetRandomInstanceId)
    End Sub
    ''' <summary>
    ''' Creates a new xPLAddress object with the given vendor ID, device ID and instance ID.
    ''' </summary>
    ''' <param name="AddrType">Indicates the address type; source or target</param>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or any of the elements 
    ''' has a length outside allowed boundaries, or any of the elements contains unallowed characters.</exception>
    Public Sub New(ByVal AddrType As xPLAddressType, ByVal vendorid As String, ByVal deviceid As String, ByVal instanceid As String)
        mType = AddrType
        ' set values through property handlers for additional checks
        Vendor = vendorid
        Device = deviceid
        Instance = instanceid
    End Sub
#End Region

#Region "Properties"

    Private mType As xPLAddressType
    ''' <summary>
    ''' Read-only indicator of address type; source or target
    ''' </summary>
    ''' <returns>Type of address; source or target</returns>
    ''' <remarks>Can only be set during creation of the xPLAddress object</remarks>
    Public ReadOnly Property Type() As xPLAddressType
        Get
            Return mType
        End Get
    End Property

    Private mVendor As String
    ''' <summary>
    ''' Reads or sets the vendor ID
    ''' </summary>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or <c>value</c> has a length outside 
    ''' allowed boundaries, or <c>value</c> contains unallowed characters.</exception>
    Public Property Vendor() As String
        Get
            Return mVendor
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If value = "*" OrElse IsValidxPL(value, 3, 8, XPL_STRING_TYPES.VendorAndDevice) Then
                If value = "*" And mType = xPLAddressType.Source Then
                    Throw New IllegalIDsInAddress("Wildcard not allowed in source address")
                Else
                    mVendor = value
                End If
            Else
                Throw New IllegalIDsInAddress("Illegal characters or length in vendorid")
            End If
        End Set
    End Property

    Private mDevice As String
    ''' <summary>
    ''' Reads or sets the device ID
    ''' </summary>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or <c>value</c> has a length outside 
    ''' allowed boundaries, or <c>value</c> contains unallowed characters.</exception>
    Public Property Device() As String
        Get
            Return mDevice
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If value = "*" OrElse IsValidxPL(value, 3, 8, XPL_STRING_TYPES.VendorAndDevice) Then
                If value = "*" And mType = xPLAddressType.Source Then
                    Throw New IllegalIDsInAddress("Wildcard not allowed in source address")
                Else
                    mDevice = value
                End If
            Else
                Throw New IllegalIDsInAddress("Illegal characters or length in deviceid")
            End If
        End Set
    End Property

    Private mInstance As String
    ''' <summary>
    ''' Reads or sets the instance ID
    ''' </summary>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or <c>value</c> has a length outside 
    ''' allowed boundaries, or <c>value</c> contains unallowed characters.</exception>
    Public Property Instance() As String
        Get
            Return mInstance
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If value = "*" OrElse IsValidxPL(value, 1, 16, XPL_STRING_TYPES.OtherElements) Then
                If value = "*" And mType = xPLAddressType.Source Then
                    Throw New IllegalIDsInAddress("Wildcard not allowed in source address")
                Else
                    mInstance = value
                End If
            Else
                Throw New IllegalIDsInAddress("Illegal characters or length in instanceid")
            End If
        End Set
    End Property

    ''' <summary>
    ''' Property representing the full xPL address in format 'vendor-device.instance'.
    ''' </summary>
    ''' <value>xPL address in format 'vendor-device.instance'</value>
    ''' <returns>xPL address in format 'vendor-device.instance'</returns>
    ''' <remarks>The wildcard "*" value is only allowed for <c>Target</c> type addresses. All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; source type address contains a wildcard, or <c>value</c> has a length outside 
    ''' allowed boundaries, or <c>value</c> contains unallowed characters.</exception>
    Public Property FullAddress() As String
        Get
            Return Me.ToString
        End Get
        Set(ByVal address As String)
            Dim n As Integer
            Dim tmpAddr As New xPLAddress(mType)

            Try
                ' check on wildcard
                If address = "*" Then address = "*-*.*"
                ' Find vendor
                n = InStr(address, "-")
                If n <> 0 Then
                    tmpAddr.Vendor = Left(address, n - 1)
                    address = address.Remove(0, n)
                End If
                ' Find device
                n = InStr(address, ".")
                If n <> 0 Then
                    tmpAddr.Device = Left(address, n - 1)
                    address = address.Remove(0, n)
                End If
                ' Remainder is instance
                tmpAddr.Instance = address
            Catch ex As Exception
                ' something didn't go as expected, so raise same exception
                Throw ex
            End Try

            ' Go set values
            mVendor = tmpAddr.Vendor
            mDevice = tmpAddr.Device
            mInstance = tmpAddr.Instance
        End Set
    End Property
#End Region

#Region "Matching"

    ''' <summary>
    ''' Compares the address with the given address and returns TRUE if there is a match. Use of wildcards is allowed.
    ''' The <c>xPLAddress.Type</c> property (source or target) is not used in the comparison!! 
    ''' </summary>
    ''' <param name="CompareTo">The <c>xPLAddress</c> to compare with</param>
    ''' <returns><c>True</c> if the address matches, <c>False</c> otherwise</returns>
    ''' <remarks>If the given object is <c>Nothing</c> it returns FALSE.</remarks>
    Public Function Matches(ByVal CompareTo As xPLAddress) As Boolean
        If CompareTo Is Nothing Then Return False
        If CompareTo.Vendor = "*" Or Me.Vendor = "*" Or Me.Vendor = CompareTo.Vendor Then
            If CompareTo.Device = "*" Or Me.Device = "*" Or Me.Device = CompareTo.Device Then
                If CompareTo.Instance = "*" Or Me.Instance = "*" Or Me.Instance = CompareTo.Instance Then
                    Return True
                End If
            End If
        End If
        Return False
    End Function

    ''' <summary>
    ''' Compares 2 addresses and returns TRUE if there is a match. Use of wildcards is allowed.
    ''' The <c>xPLAddress.Type</c> properties (source or target) will not be used in the comparison!! 
    ''' </summary>
    ''' <returns><c>True</c> if the addresses match, <c>False</c> otherwise</returns>
    ''' <remarks>If either of the given objects is <c>Nothing</c> it returns <c>False</c>.</remarks>
    Public Shared Function Matches(ByVal xPLAddr1 As xPLAddress, ByVal xPLAddr2 As xPLAddress) As Boolean
        If xPLAddr1 Is Nothing Then Return False
        Return xPLAddr1.Matches(xPLAddr2)
    End Function

    ''' <summary>
    ''' Compares the address with the provided address and returns TRUE if there is a match. Use of wildcards is allowed.
    ''' The <c>xPLAddress.Type</c> properties (source or target) will not be used in the comparison!! 
    ''' </summary>
    ''' <returns><c>True</c> if the addresses match, <c>False</c> otherwise</returns>
    ''' <remarks>All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either; <c>CompareTo</c> elements have a length outside 
    ''' allowed boundaries, or <c>CompareTo</c> elements contain unallowed characters.</exception>
    Public Function Matches(ByVal CompareTo As String) As Boolean
        Dim temp As New xPLAddress(xPLAddressType.Target, CompareTo)
        Return Matches(temp)
    End Function

    ''' <summary>
    ''' Compares 2 addresses and returns TRUE if there is a match. Use of wildcards is allowed.
    ''' The <c>xPLAddress.Type</c> properties (source or target) will not be used in the comparison!! 
    ''' </summary>
    ''' <returns><c>True</c> if the addresses match, <c>False</c> otherwise</returns>
    ''' <remarks>All provided values will be converted to lowercase.</remarks>
    ''' <exception cref="IllegalIDsInAddress">Condition: Either of the addresses has elements that have a length outside 
    ''' allowed boundaries, or either of the addresses have elements that contain unallowed characters.</exception>
    Public Shared Function Matches(ByVal xPLAddr1 As String, ByVal xPLAddr2 As String) As Boolean
        Dim temp As New xPLAddress(xPLAddressType.Target, xPLAddr1)
        Return temp.Matches(xPLAddr2)
    End Function

#End Region

#Region "Other..."
    ''' <returns>Full xPLaddress in text format</returns>
    ''' <remarks>Format is; "vendor-device.instance" (without the quotes). If any of the elements has been wildcarded ("*") then the result will be "*".</remarks>
    Public Overrides Function ToString() As String
        If mVendor = "*" Or mDevice = "*" Or mInstance = "*" Then
            Return "*"
        Else
            Return mVendor & "-" & mDevice & "." & mInstance
        End If
    End Function

    ''' <summary>
    ''' Returns a randomized instance id, 16 characters long
    ''' </summary>
    ''' <returns>String containing a randomized instance id, 16 characters long</returns>
    ''' <remarks>It will just return a random ID, it will not be set (shared method). Possibility of duplicates is extremely small; 36^16.</remarks>
    Public Shared Function GetRandomInstanceId() As String
        GetRandomInstanceId = GenerateRandomString(XPL_ALLOWED_VENDOR_DEVICE, 16)
    End Function

    ''' <summary>
    ''' Returns a hostname based instance id
    ''' </summary>
    ''' <returns>String containing a (valid) hostname-based instance id</returns>
    ''' <remarks>It will just return the ID, it will not be set. When using multiple xPL software devices on the same system, with the 
    ''' same vendor and device ID's, there is a large possibility of an address conflict (duplicate) in the xPL network! Use the 
    ''' <c>GetRandomInstanceID</c> function to get a random ID to resolve this. If no instance ID can be deducted from the hostname, 
    ''' then a randomized ID is returned.</remarks>
    Public Shared Function GetHostBasedInstanceId() As String
        ' Setup default instance
        Dim defaultName As String = ""
        Try
            defaultName = RemoveInvalidxPLchars(Environment.MachineName(), XPL_STRING_TYPES.OtherElements)
        Catch
        End Try
        ' too long?
        If defaultName.Length > 16 Then
            defaultName = defaultName.Substring(0, 16)
        End If
        ' too short?
        If defaultName.Length < 1 Then
            defaultName = GetRandomInstanceId()
        End If
        Return defaultName
    End Function


#End Region

End Class
