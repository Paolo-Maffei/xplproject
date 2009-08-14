'**************************************
'* xPLHal Service Launcher
'*
'* Version 1.04
'*
'* Copyright (C) 2009 Ian Lowe
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

Imports System.ServiceProcess

Module xPLHalSystem

    'MAIN ENTRY POINT
    Sub Main(ByVal ParamArray parameters As String())

        If (parameters.Length > 0) Then
            If (parameters(0).ToLower() = "/console") Then
                Dim xPLDebugConsole As New xPLConsole
                xPLDebugConsole.StartupConsole()
            End If
        Else
            ServiceBase.Run(New ServiceBase() {New xPLService()})
        End If
    End Sub

End Module
