Imports System.ComponentModel
Imports System.Configuration.Install
'**************************************
'* xPLHal for Windows
'*
'* Copyright (C) 2003-2007 John Bent & Tony Tofts
'* http://www.xplhal.org
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

<RunInstaller(True)> Public Class ProjectInstaller
    Inherits System.Configuration.Install.Installer

#Region " Component Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Installer overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Component Designer
    'It can be modified using the Component Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents ServiceProcessInstaller1 As System.ServiceProcess.ServiceProcessInstaller
    Friend WithEvents ServiceInstaller1 As System.ServiceProcess.ServiceInstaller
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.ServiceProcessInstaller1 = New System.ServiceProcess.ServiceProcessInstaller()
        Me.ServiceInstaller1 = New System.ServiceProcess.ServiceInstaller()
        '
        'ServiceProcessInstaller1
        '
        Me.ServiceProcessInstaller1.Account = System.ServiceProcess.ServiceAccount.LocalSystem
        Me.ServiceProcessInstaller1.Password = Nothing
        Me.ServiceProcessInstaller1.Username = Nothing
        '
        'ServiceInstaller1
        '
    Me.ServiceInstaller1.DisplayName = "xPLHal for Windows"
        Me.ServiceInstaller1.ServiceName = "xPLHal"
        Me.ServiceInstaller1.StartType = System.ServiceProcess.ServiceStartMode.Automatic
        '
        'ProjectInstaller
        '
        Me.Installers.AddRange(New System.Configuration.Install.Installer() {Me.ServiceProcessInstaller1, Me.ServiceInstaller1})

    End Sub

#End Region

    Private Sub ServiceInstaller1_BeforeUninstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles ServiceInstaller1.BeforeUninstall
        Try
            Dim myService As New ServiceProcess.ServiceController("xplhal")
            If Not myService.Status = ServiceProcess.ServiceControllerStatus.Stopped Then
                myService.Stop()
                myService.WaitForStatus(ServiceProcess.ServiceControllerStatus.Stopped, New TimeSpan(0, 0, 30))
            End If
        Catch ex As Exception
        End Try
    End Sub

    Private Sub ServiceInstaller1_AfterInstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles ServiceInstaller1.AfterInstall
        Try
            Dim myService As New ServiceProcess.ServiceController("xplhal")
            myService.Start()
        Catch ex As Exception
        End Try
    End Sub

    



  Private Sub ProjectInstaller_BeforeInstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles MyBase.BeforeInstall
    Try
      Me.Uninstall(Nothing)
    Catch
    End Try
  End Sub
End Class
