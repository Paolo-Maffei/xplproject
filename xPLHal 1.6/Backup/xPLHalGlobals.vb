'**************************************
'* xPL xPLHal 
'*
'* Copyright (C) 2003 Tony Tofts
'* http://www.xplhal.com
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
Public Class xPLHalGlobals

    Public Globals As New Hashtable

    ' add/update globals
    Public Property Value(ByVal GlobalName As String) As Object
        Get
            If GlobalName = "" Then Return Nothing
            Try
                Return Globals(GlobalName.ToUpper.Trim)
            Catch ex As Exception
                Return Nothing
            End Try
        End Get
        Set(ByVal Value As Object)
            If GlobalName <> "" Then
                Try
                    If Globals(GlobalName.ToUpper.Trim) <> Value Then
                        Globals(GlobalName.ToUpper.Trim) = Value
                        If xPLHalBooting = False Then Determinator.GlobalChanged(GlobalName)
                    Else
                        Globals(GlobalName.ToUpper.Trim) = Value
                    End If
                Catch ex As Exception
                    Globals.Add(GlobalName.ToUpper.Trim, Value)
                End Try
            End If
        End Set
    End Property

    ' exists
    Public Function Exists(ByVal GlobalName As String) As Boolean
        Return Globals.ContainsKey(GlobalName.ToUpper.Trim)
    End Function

    ' delete
    Public Function Delete(ByVal GlobalName As String) As Boolean
        Try
            If GlobalName = "" Then Return False
            Globals.Remove(GlobalName.ToUpper.Trim)
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function

    ' save globals
    Public Sub Save()
        Dim xml As New Xml.XmlTextWriter(xPLHalData + "\xplhal_globals.xml", System.Text.Encoding.ASCII)
        Dim o As Object

        xml.Formatting = Formatting.Indented
        xml.WriteStartDocument()
        xml.WriteStartElement("globals")
        For Each o In xPLGlobals.Globals.Keys
            Try
                If CStr(o) <> "" Then
                    xml.WriteStartElement("global")
                    xml.WriteAttributeString("name", CStr(o).ToUpper)
                    '                    Debug.WriteLine(CStr(o).ToUpper)
                    xml.WriteAttributeString("value", CStr(xPLGlobals.Value(CStr(o))))
                    '                    Debug.WriteLine(CStr(xPLGlobals.Value(CStr(o))))
                    xml.WriteEndElement()
                End If
            Catch ex As Exception
                Call WriteErrorLog("Error Writing Global " & CStr(o).ToUpper & " to XML (" & Err.Description & ")")
            End Try
        Next
        xml.WriteEndElement()
        xml.WriteEndDocument()
        xml.Flush()
        xml.Close()
    End Sub

    ' load globals
    Public Sub Load()
        Globals.Clear()
        If Dir(xPLHalData & "\xplhal_globals.xml") <> "" Then
            ' got xml globals so load
            Try
                Dim xml As New Xml.XmlTextReader(xPLHalData & "\xplhal_globals.xml")
                While xml.Read()
                    Select Case xml.NodeType
                        Case XmlNodeType.Element
                            Select Case xml.Name
                                Case "global"
                                    If xml.GetAttribute("name") <> "" Then
                                        Globals.Add(xml.GetAttribute("name").ToUpper, xml.GetAttribute("value"))
                                    End If
                            End Select
                    End Select
                End While
                xml.Close()
            Catch ex As Exception
                Call WriteErrorLog("Error Reading Globals XML (" & Err.Description & ")")
                Exit Sub
            End Try
        Else
            ' no xml globals, so load bin if it exists and save as xml
            If Dir(xPLHalData & "\xplhal_globals.bin") <> "" Then
                Call LoadBin()
                Call Save()
            End If
        End If

    End Sub

    ' load old binary globals
    Public Sub LoadBin()
        Dim BinFormatter As New Binary.BinaryFormatter
        Dim FS As FileStream
        Globals.Clear()
        Try
            FS = New FileStream(xPLHalData + "\xplhal_globals.bin", FileMode.Open)
            Globals = CType(BinFormatter.Deserialize(FS), Hashtable)
            FS.Close()
            Rename(xPLHalData & "\xplhal_globals.bin", xPLHalData & "\xplhal_globals.bin.old")
        Catch ex As Exception
        End Try
    End Sub

End Class
