'* xPL Library for .NET
'*
'* LocalIPAddresses
'*
'* Version 4.0
'* Written by Tom Van den Panhuyzen
'*
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
'*
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

Imports System.Runtime.InteropServices
Imports System.Net

Module IPAddresses

    Declare Function GetIpAddrTable Lib "Iphlpapi" (ByVal pAddrTable As IntPtr, ByRef pdwSize As Integer, ByVal bOrder As Boolean) As Integer

    <StructLayout(LayoutKind.Sequential)> Public Structure _MIB_IPADDRROW
        Public dwAddr As UInt32
        Public dwIndex As UInt32
        Public dwMask As UInt32
        Public dwBCastAddr As UInt32
        Public dwReasmSize As UInt32
        Public unused1 As Int16
        Public unused2 As Int16
    End Structure

    Public Function LocalIPAddresses(ByVal ErrorLog As EventLog) As ArrayList
        Dim MIB_IPADDRROW As _MIB_IPADDRROW
        Dim pStructPointer As IntPtr = IntPtr.Zero
        Dim pdwSize As Integer
        Dim IPInfo As New ArrayList(10)
        Dim la As Long
        Dim iReturn As Integer
        Dim iNumberOfStructures As Integer
        Try
            'get the table size
            iReturn = GetIpAddrTable(pStructPointer, pdwSize, False)
            'allocate the table
            pStructPointer = Marshal.AllocHGlobal(pdwSize)
            'now get the addresses
            iReturn = GetIpAddrTable(pStructPointer, pdwSize, False)

            iNumberOfStructures = CType(Marshal.PtrToStructure(pStructPointer, GetType(Int32)), Int32)
            For i As Integer = 0 To iNumberOfStructures - 1
                MIB_IPADDRROW = CType(Marshal.PtrToStructure(IntPtr.op_Explicit(pStructPointer.ToInt32() + 4 + i * Marshal.SizeOf(GetType(_MIB_IPADDRROW))), GetType(_MIB_IPADDRROW)), _MIB_IPADDRROW)
                la = Long.Parse(MIB_IPADDRROW.dwAddr.ToString())
                IPInfo.Add((New IPAddress(la)).ToString())
            Next

        Catch ex As Exception
            If Not ErrorLog Is Nothing Then
                ErrorLog.WriteEntry("Error looking for local ip address(es): " & ex.Message)
            End If

        Finally
            If Not pStructPointer.Equals(IntPtr.Zero) Then
                Marshal.FreeHGlobal(pStructPointer)
            End If

        End Try

        If IPInfo.Count < 1 Then
            'at least return the loopback
            IPInfo.Add(IPAddress.Loopback.ToString())
        ElseIf IPInfo.Count > 1 AndAlso IPInfo.Item(0) = IPAddress.Loopback.ToString() Then
            'switch 1 & 2 because we don't want to return the loopback as default when asked for a local IP
            IPInfo.Item(0) = IPInfo.Item(1)
            IPInfo.Item(1) = IPAddress.Loopback.ToString()
        End If

        Return IPInfo
    End Function

End Module
