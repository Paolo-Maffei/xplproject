'**************************************
'* xPLHal Configuration Engine
'*
'* Version 2.2
'*
'* Copyright (C) 2003-2008 Tony Tofts & Ian Lowe
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
'**************************************

Imports xPLLogging.Logger
Imports xPLLogging.LogLevel
Imports System.IO
Imports DeviceManager

Public Class Config
    Public vendorFileFolder As String
    Public ConfigFileFolder As String
    Public xPLConfigDisabled As Boolean = True
    Public Shared xPLDevices As DevManager

    Public Event SendxPLMessage(ByVal _msgtype As String, ByVal _sourcetag As String, ByVal _msgclass As String, ByVal _msgbody As String)

    Public Shared Function Version() As String
        Return System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
    End Function



End Class
