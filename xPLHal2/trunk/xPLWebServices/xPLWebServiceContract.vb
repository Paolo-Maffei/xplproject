'**************************************
'* xPL Web Services Definition Module
'*
'* Version 1.04
'*
'* Copyright (C) 2008 Ian Lowe
'* http://www.xplhal.org/
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

Imports System.ServiceModel

<ServiceContract()> _
Public Interface xPLWebServiceContract
    <OperationContract()> Function DisplayCacheObject(ByVal oName As String) As String
    <OperationContract()> Function DisplayCache() As String
    <OperationContract()> Sub SetCacheObjectValue(ByVal oName As String, ByVal oValue As String)
    <OperationContract()> Sub CreateCacheObject(ByVal oName As String, ByVal oValue As String)
    <OperationContract()> Sub RunDeterminator(ByVal objectName As String)
End Interface



