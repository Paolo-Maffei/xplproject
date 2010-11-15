'* xPL Comfort Service
'*
'* Copyright (C) 2004 John Bent
'* http://www.xpl.myby.co.uk/
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
Imports System.ComponentModel
Imports System.Configuration.Install

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
    Me.ServiceProcessInstaller1 = New System.ServiceProcess.ServiceProcessInstaller
    Me.ServiceInstaller1 = New System.ServiceProcess.ServiceInstaller
    '
    'ServiceProcessInstaller1
    '
    Me.ServiceProcessInstaller1.Account = System.ServiceProcess.ServiceAccount.LocalSystem        '
    Me.ServiceProcessInstaller1.Password = Nothing
    Me.ServiceProcessInstaller1.Username = Nothing
    '
    'ServiceInstaller1
    '
    Me.ServiceInstaller1.DisplayName = "xPL Comfort"        
    Me.ServiceInstaller1.ServiceName = "xPLComfort"
    Me.ServiceInstaller1.StartType = System.ServiceProcess.ServiceStartMode.Automatic
    '
    'ProjectInstaller
    '
    Me.Installers.AddRange(New System.Configuration.Install.Installer() {Me.ServiceProcessInstaller1, Me.ServiceInstaller1})

  End Sub

#End Region

  Private Sub ServiceInstaller1_AfterInstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles ServiceInstaller1.AfterInstall
    Try
      Dim myService As New ServiceProcess.ServiceController("xplcomfort")
      myService.Start()
    Catch ex As Exception
    End Try
  End Sub

  Private Sub ServiceInstaller1_BeforeUninstall(ByVal sender As Object, ByVal e As System.Configuration.Install.InstallEventArgs) Handles ServiceInstaller1.BeforeUninstall
    Try
      Dim myService As New ServiceProcess.ServiceController("xplcomfort")
      If Not myService.Status = ServiceProcess.ServiceControllerStatus.Stopped Then
        myService.Stop()
        myService.WaitForStatus(ServiceProcess.ServiceControllerStatus.Stopped, New TimeSpan(0, 0, 30))
      End If
    Catch ex As Exception
    End Try
  End Sub

  Private Sub CheckForHub()
    ' This routine tries to bind to 3865 UDP.
    ' If it can bind, it assumes that a hub isn't warning and
    ' pops up a box to warn the user.
    Try
      Dim sock As New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
      sock.Bind(New IPEndPoint(ipaddress.any, 3865))
      sock.Close()
      MsgBox("Setup detected that no xPL Hub is currently running on this computer." & vbCrLf & "This application requires that an xPL Hub be installed and running before it will operate successfully." & vbCrLf & vbCrLf & "Please see www.xplproject.org.uk for a suitable xPL Hub for your environment.", vbInformation, "xPL Hub Not Found")
    Catch ex As Exception
      ' Bind failed, so hub must be running.      
    End Try
  End Sub

  Public Overrides Sub Install(ByVal _
 stateSaver As _
 System.Collections.IDictionary)
    MyBase.Install(stateSaver)
    Try
      Dim ConfigMode As String = MyBase.Context.Parameters("CONFIGMODE")
      If ConfigMode = "2" Or ConfigMode = "3" Then
        ' Create an XML configuration document
        Dim filename As String = Environment.SystemDirectory & "\xpl_johnb-comfort.instance1.xml"
        Dim instanceName As String = Environment.MachineName
        Dim xml As New XmlTextWriter(filename, Nothing)
        If instanceName.Length > 16 Then
          instanceName = instanceName.Substring(0, 16)
        End If
        instanceName = instanceName.Replace("-", "").Replace("_", "")
        xml.Formatting = Formatting.Indented
        xml.WriteStartDocument(False)
        xml.WriteStartElement("xplConfiguration")

        ' SOurce
        xml.WriteStartElement("instance")
        xml.WriteAttributeString("value", Environment.MachineName)
        xml.WriteEndElement()

        ' COnfig items
        xml.WriteStartElement("configItems")
        ' Ucmhost
        If ConfigMode = "2" Then ' RS232
          xml.WriteStartElement("configItem")
          xml.WriteAttributeString("key", "ucmhost")
          xml.WriteAttributeString("value", "RS232")
          xml.WriteEndElement()
          ' Ask for port number
          Dim port As String
          Do
            port = InputBox("Enter the serial port number that Comfort's UCM is connected to:", "xPL Comfort", "1")
            If Not IsNumeric(port) Then
              MsgBox("Please enter a value between 1 and 99.", vbExclamation)
            End If
          Loop Until IsNumeric(port)
          xml.WriteStartElement("configItem")
          xml.WriteAttributeString("key", "ucmport")
          xml.WriteAttributeString("value", port)
          xml.WriteEndElement()
        Else
          ' Ask for UCM host
          Dim host As String = InputBox("Enter the IP address of the UCM/Ethernet module:", "")
          xml.WriteStartElement("configItem")
          xml.WriteAttributeString("key", "ucmhost")
          xml.WriteAttributeString("value", host)
          xml.WriteEndElement()

          xml.WriteStartElement("configItem")
          xml.WriteAttributeString("key", "ucmport")
          xml.WriteAttributeString("value", "1001")
          xml.WriteEndElement()
        End If
        ' Usercode
        Dim usercode As String = InputBox("Please enter a valid user code that xPL Comfort may use to log into Comfort:")
        xml.WriteStartElement("configItem")
        xml.WriteAttributeString("key", "usercode")
        xml.WriteAttributeString("value", usercode)
        xml.WriteEndElement()
        ' Clocksync
        xml.WriteStartElement("configItem")
        xml.WriteAttributeString("key", "clocksync")
        If MsgBox("Would you like xPL Comfort to synchronise Comfort's internal date/time with your computer?", vbYesNo Or vbQuestion) = MsgBoxResult.Yes Then
          xml.WriteAttributeString("value", "Y")
        Else
          xml.WriteAttributeString("clocksync", "N")
        End If
        xml.WriteEndElement()
        ' X10 support
        xml.WriteStartElement("configItem")
        xml.WriteAttributeString("key", "x10")
        If MsgBox("If your Comfort system is fitted with an X10 powerline interface, you can control and monitor your X10 devices via xPL messages." & vbCrLf & vbCrLf & "Would you like to enable X10 support?", vbYesNo Or vbQuestion) = MsgBoxResult.Yes Then
          xml.WriteAttributeString("value", "Y")
        Else
          xml.WriteAttributeString("value", "N")
        End If
        xml.WriteEndElement()

        xml.WriteEndElement()

        xml.WriteEndElement()
        xml.WriteEndDocument()
        xml.Close()
      End If
    Catch ex As Exception
      MsgBox("There was a problem configuring xPL VIOM:" & vbCrLf & ex.ToString, vbCritical)
    End Try
    CheckForHub()
  End Sub

End Class
