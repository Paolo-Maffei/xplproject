'* xPL Nabaztag Service
'*      portion of code by Juan Estrada 
'* Copyright (C) 2007 Gael L'hopital
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

Option Strict On

Public Class frmNabaztag
    Inherits System.Windows.Forms.Form

    Private FrmShown As Boolean
    Public WithEvents TrayIcon As NotifyIcon

    Private WithEvents myXplListener As xpllib.XplListener
    Private myNabaztag As clsNabaztag

    Private Sub frmNabaztag_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ' Initialise the XPL listener
        Try
            myXplListener = New xpllib.XplListener("gael-nabaztag", 1)
        Catch ex As Exception
            EventLog.AppendText("XPL initialisation failed")
            Throw ex
        End Try

        myXplListener.Listen()

        ' Initialise the Nabaztag
        If Not myXplListener.AwaitingConfiguration Then
            InitNabaztag()
        Else
            myXplListener.ConfigItems.Add("Token", "", xpllib.xplConfigTypes.xReconf)
            myXplListener.ConfigItems.Add("SerialNum", "", xpllib.xplConfigTypes.xOption)
            myXplListener.ConfigItems.Add("BaseUrl", "http://api.nabaztag.com/vl/FR/api.jsp", xpllib.xplConfigTypes.xReconf)
        End If

        TrayIcon = New NotifyIcon
        With TrayIcon
            .Visible = False
            .Icon = Me.Icon
            .Text = "gael-nabaztag"
            .ContextMenu = Me.IconMenu
        End With

        FrmShown = False '              The form is currently hided, so...
        Me.ShowInTaskbar = False '      Hides the Taskbar button of the form
        TrayIcon.Visible = True '       Shows the tray icon
    End Sub

    Private Sub myXplListener_XplConfigDone() Handles myXplListener.XplConfigDone
        InitNabaztag()
    End Sub

    Private Sub frmNabaztag_FormClosing(ByVal sender As System.Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles MyBase.FormClosing
        ' Shut down everything
        Try
            myNabaztag = Nothing
            myXplListener.SaveState()
            myXplListener = Nothing
        Catch ex As Exception
            EventLog.AppendText("Error while closing down: " & ex.ToString())
        End Try
    End Sub

    Private Sub InitNabaztag()
        Try
            myNabaztag = New clsNabaztag()
            myNabaztag.myXplListener = myXplListener

            myNabaztag.sToken = myXplListener.ConfigItems.Item("Token")
            myNabaztag.sSerial = myXplListener.ConfigItems.Item("SerialNum")
            myNabaztag.sBaseUrl = myXplListener.ConfigItems.Item("BaseUrl")
            myNabaztag.Init()

        Catch ex As Exception
            EventLog.AppendText("Error initialising Nabaztag. " & Err.Description)
        End Try
    End Sub

#Region "Gestion de l'iconisation"

    Private Sub MenuOpen_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles TrayIcon.DoubleClick, MenuOpen.Click
        Me.WindowState = FormWindowState.Normal '   Restores the window
        Me.ShowInTaskbar = True                 '   Show the TaskBar button
        FrmShown = True                         '   The form is currently FrmShown, so...
        TrayIcon.Visible = False                '   Hides the tray icon
    End Sub

    Private Sub MenuExit_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MenuExit.Click
        TrayIcon.Visible = False
        Call frmNabaztag_FormClosing(sender, Nothing)
        Me.Close()                  '                Closes the form
        End                         '                       Ends the program
    End Sub

    Private Sub frmNabaztag_SizeChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.SizeChanged
        If FrmShown And Me.WindowState = FormWindowState.Minimized Then
            FrmShown = False            '  The form is currently hided, so...
            Me.ShowInTaskbar = False    '  Hides the Taskbar button of the form
            TrayIcon.Visible = True     '  Shows the tray icon
        End If
    End Sub

#End Region


End Class
