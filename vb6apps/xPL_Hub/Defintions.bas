Attribute VB_Name = "Defintions"
'**************************************
'* xPL Hub
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

Option Explicit

Public Type xPL_Hub

    Port As Long
    Refreshed As Date
    Interval As Integer
    Confirmed As Boolean
    VDI As String
    
End Type

Public Const MAX_HUBS = 64

Global HubIP As String
Global HubPort As Long
Global xPL_hubs(MAX_HUBS) As xPL_Hub
Global xPL_style As Integer

' 0 = hub listener
' 1 to 8 = manual configuration
' 9 to 255 = auto configuration


