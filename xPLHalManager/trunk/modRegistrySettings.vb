'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2004 John Bent & Ian Jeffery
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
'**************************************
Option Strict On

Module modRegistrySettings
  '* This module contains all routines
  '* related to reading and writing information to and from the registry.

  Public RegKeyStr As String = "Software\\xPL\\xPLHALManager"

  Public Sub GetlvwSettings(ByRef l As ListView, ByVal ColWidths() As Integer)
    ' saves listview column widths to registry
    ' the form name is appended to RegKeyStr to create a seperate key for each form
    ' colwidths is an integer array of default widths if there is no key
    Dim MyKey As RegistryKey
    MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & l.FindForm.Name, False)
    If MyKey Is Nothing Then
      Registry.CurrentUser.CreateSubKey(RegKeyStr & "\\" & l.FindForm.Name)
      MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & l.FindForm.Name, False)
    End If
    For i As Integer = 0 To l.Columns.Count - 1
      l.Columns(i).Width = CInt(MyKey.GetValue(l.Name & "col" & i, ColWidths(i)))
    Next
    MyKey.Close()
  End Sub

  Public Sub SetlvwSettings(ByRef l As ListView)
    ' gets listview column widths from registry
    Dim MyKey As RegistryKey
    MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & l.FindForm.Name, True)
    If MyKey Is Nothing Then
      Registry.CurrentUser.CreateSubKey(RegKeyStr & "\\" & l.FindForm.Name)
      MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & l.FindForm.Name, True)
    End If
    For i As Integer = 0 To l.Columns.Count - 1
      MyKey.SetValue(l.Name & "Col" & i, l.Columns(i).Width)
    Next
    MyKey.Close()
  End Sub

  Public Sub SetFormSettings(ByRef f As Form)
    ' saves the form size to the registry
    Dim MyKey As RegistryKey
    MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & f.Name, True)
    If MyKey Is Nothing Then
      Registry.CurrentUser.CreateSubKey(RegKeyStr & "\\" & f.Name)
      MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & f.Name, True)
    End If
    MyKey.SetValue("FormWidth", f.Width)
    MyKey.SetValue("FormHeight", f.Height)
    MyKey.SetValue("FormLeft", f.Left)
    MyKey.SetValue("FormTop", f.Top)
    MyKey.Close()
  End Sub

  Public Sub GetFormSettings(ByRef f As Form, ByVal Width As Integer, ByVal Height As Integer)
    ' gets the form size from the registry using height and width as default values
    Dim MyKey As RegistryKey
    MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & f.Name, True)
    If MyKey Is Nothing Then
      Registry.CurrentUser.CreateSubKey(RegKeyStr & "\\" & f.Name)
      MyKey = Registry.CurrentUser.OpenSubKey(RegKeyStr & "\\" & f.Name, True)
    End If
    f.Width = CInt(MyKey.GetValue("FormWidth", Width))
    f.Height = CInt(MyKey.GetValue("FormHeight", Height))
    f.Left = CInt(MyKey.GetValue("FormLeft", 0))
    f.Top = CInt(MyKey.GetValue("FormTop", 0))
    MyKey.Close()
  End Sub

  Public Function GetRegistryValue(ByVal paramName As String, ByVal defaultValue As String) As String
    ' Retrieves a specific value from the registry
    Try
      Dim RegKey As RegistryKey = Registry.CurrentUser.OpenSubKey(RegKeyStr)
      GetRegistryValue = CStr(RegKey.GetValue(paramName, defaultValue))
      RegKey.Close()
    Catch ex As Exception
      GetRegistryValue = defaultValue
    End Try
  End Function

  Public Sub SetRegistryValue(ByVal paramName As String, ByVal paramValue As String)
    Dim RegKey As RegistryKey = Registry.CurrentUser.CreateSubKey(RegKeyStr)
    RegKey.SetValue(paramName, paramValue)
    RegKey.Close()
  End Sub

End Module
