'* xPL Library for .NET
'*
'* Version 5.5
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
''' Class representing an xPL schema. The class contains verification for valid values and matching methods for filters.
''' </summary>
''' <remarks></remarks>
Public Class xPLSchema

#Region "Properties"

    Dim mClass As String = "hbeat"
    ''' <summary>
    ''' Returns or sets the CLASS part of a schema name, defined as 'class.type'. 
    ''' </summary>
    ''' <value>Class name to be set.</value>
    ''' <returns>Class name currently set.</returns>
    ''' <exception cref="IllegalSchema">condition when setting the value: length must be between 1 and 8 and allowed characters are a-z, 0-9 
    ''' and - (dash or hyphen), all lowercase.</exception>
    ''' <remarks>All input will be converted to lower case. Default value is 'hbeat'. Wildcards are allowed as a special case, 1 character only; '*'</remarks>
    Public Property SchemaClass() As String
        Get
            Return mClass
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If value = "*" OrElse IsValidxPL(value, 1, 8, XPL_STRING_TYPES.OtherElements) Then
                mClass = value
            Else
                Throw New IllegalSchema("Illegal characters or length in class name")
            End If
        End Set
    End Property

    Dim mType As String = "app"
    ''' <summary>
    ''' Returns or sets the TYPE part of a schema name, defined as 'schema.type'. 
    ''' </summary>
    ''' <value>Type name to be set.</value>
    ''' <returns>Type name currently set.</returns>
    ''' <exception cref="IllegalSchema">condition when setting the value: length must be between 1 and 8 and allowed characters are a-z, 0-9 and - (dash or hyphen), all lowercase.</exception>
    ''' <remarks>All input will be converted to lower case. Default value is 'app'. Wildcards are allowed as a special case, 1 character only; '*'</remarks>
    Public Property SchemaType() As String
        Get
            Return mType
        End Get
        Set(ByVal value As String)
            value = value.ToLower
            If value = "*" OrElse IsValidxPL(value, 1, 8, XPL_STRING_TYPES.OtherElements) Then
                mType = value
            Else
                Throw New IllegalSchema("Illegal characters or length in type name")
            End If
        End Set
    End Property

#End Region

#Region "Matching"

    ''' <summary>
    ''' Compares two schema's.
    ''' </summary>
    ''' <param name="CompareTo">xPLSchema object to compare with the current values</param>
    ''' <returns>True if the schemas are equal or the wildcards match, False otherwise</returns>
    ''' <remarks>Wildcard character is '*', for either or both Class and Type.</remarks>
    Public Function Matches(ByVal CompareTo As xPLSchema) As Boolean
        Dim result As Boolean = False
        If Not CompareTo Is Nothing Then
            If CompareTo.SchemaClass = "*" Or Me.SchemaClass = "*" Or Me.SchemaClass = CompareTo.SchemaClass Then
                If CompareTo.SchemaType = "*" Or Me.SchemaType = "*" Or Me.SchemaType = CompareTo.SchemaType Then
                    Return True
                End If
            End If
        End If
        Return result
    End Function

    ''' <summary>
    ''' Compares two schema's.
    ''' </summary>
    ''' <param name="xPLschema1">first xPLSchema object to compare</param>
    ''' <param name="xPLschema2">second xPLSchema object to compare with the first one</param>
    ''' <returns>True if the schemas are equal or the wildcards match, False otherwise</returns>
    ''' <remarks>Wildcard character is '*', for either or both Class and Type.</remarks>
    Public Shared Function Matches(ByVal xPLschema1 As xPLSchema, ByVal xPLschema2 As xPLSchema) As Boolean
        Dim result As Boolean = False
        If Not xPLschema1 Is Nothing Then
            result = xPLschema1.Matches(xPLschema2)
        End If
        Return result
    End Function

    ''' <summary>
    ''' Compares two schema's.
    ''' </summary>
    ''' <param name="CompareTo">xPLSchema in string format 'class.type' to compare with the current values</param>
    ''' <returns>True if the schemas are equal or the wildcards match, False otherwise</returns>
    ''' <exception cref="IllegalSchema">condition for both class and type: length must be between 1 and 8 and allowed 
    ''' characters are a-z, 0-9 and - (dash or hyphen), all lowercase. Schema and Class must be separated by a single '.' (dot)</exception>
    ''' <remarks>All input will be converted to lower case. Wildcard character is '*', for either or both Class and Type.</remarks>
    Public Function Matches(ByVal CompareTo As String) As Boolean
        Dim temp As New xPLSchema(CompareTo)
        Return Me.Matches(temp)
    End Function

    ''' <summary>
    ''' Compares two schema's.
    ''' </summary>
    ''' <param name="xPLschema1">first xPLSchema in string format 'class.type' to compare</param>
    ''' <param name="xPLschema2">second xPLSchema in string format 'class.type' to compare with the first one</param>
    ''' <returns>True if the schemas are equal or the wildcards match, False otherwise</returns>
    ''' <exception cref="IllegalSchema">condition for both class and type: length must be between 1 and 8 and allowed 
    ''' characters are a-z, 0-9 and - (dash or hyphen), all lowercase. Schema and Class must be separated by a single '.' (dot)</exception>
    ''' <remarks>All input will be converted to lower case. Wildcard character is '*', for either or both Class and Type.</remarks>
    Public Shared Function Matches(ByVal xPLschema1 As String, ByVal xPLschema2 As String) As Boolean
        Dim temp As New xPLSchema(xPLschema1)
        Return temp.Matches(xPLschema2)
    End Function

#End Region

#Region "Constructors"

    ''' <summary>
    ''' Creates a new object instance of xPLSchema, with default value 'hbeat.app'.
    ''' </summary>
    Public Sub New()
        ' nothing to, defaults to schema "hbeat.app"
    End Sub

    ''' <summary>
    ''' Creates an xPLSchema object from a properly formatted string
    ''' </summary>
    ''' <param name="sSchema">xPLSchema in string format 'class.type'</param>
    ''' <exception cref="IllegalSchema">condition for both class and type: length must be between 1 and 8 and allowed 
    ''' characters are a-z, 0-9 and - (dash or hyphen), all lowercase. Schema and Class must be separated by a single '.' (dot)</exception>
    ''' <remarks>All input will be converted to lower case.</remarks>
    Public Sub New(ByVal sSchema As String)
        Dim n As Integer
        Dim sClass As String = ""
        Dim sType As String = ""
        ' Find class
        n = InStr(sSchema, ".")
        If n <> 0 Then
            sClass = Left(sSchema, n - 1)
            sSchema = sSchema.Remove(0, n)
        End If
        ' Remainder is instance
        sType = sSchema
        ' Go set values through property handlers for additional checks
        SchemaClass = sClass
        SchemaType = sType
    End Sub

    ''' <summary>
    ''' Creates an xPLSchema object from a specified set of schema-class and schema-type.
    ''' </summary>
    ''' <param name="sClass">Class of the schema to be set.</param>
    ''' <param name="sType">Type of the schema to be set.</param>
    ''' <exception cref="IllegalSchema">condition for both class and type: length must be between 1 and 8 and allowed 
    ''' characters are a-z, 0-9 and - (dash or hyphen), all lowercase.</exception>
    ''' <remarks>All input will be converted to lower case.</remarks>
    Public Sub New(ByVal sClass As String, ByVal sType As String)
        ' Go set values through property handlers for additional checks
        SchemaClass = sClass
        SchemaType = sType
    End Sub

#End Region

#Region "Other..."

    ''' <returns>Schema in a string formatted as 'class.type'</returns>
    Public Overrides Function ToString() As String
        Return Me.SchemaClass & "." & Me.SchemaType
    End Function

    ''' <summary>
    ''' Checks wether either the Class or Type property have been set to a wildcard ('*')
    ''' </summary>
    ''' <returns>True if a wildcard is used in either class or type, False otherwise</returns>
    Public Function IsWildCarded() As Boolean
        If mClass = "*" Or mType = "*" Then Return True
        Return False
    End Function
#End Region

End Class

