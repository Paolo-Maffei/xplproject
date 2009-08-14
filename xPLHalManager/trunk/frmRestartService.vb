'**************************************
'* xPLHal Manager
'*                                    
'* Copyright (C) 2003-2005 John Bent & Ian Jeffery
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

Public Class frmRestartService
    Inherits xplhalMgrBase

    Private FirstActivation As Boolean = True
    Private Counter As Integer


#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents ProgressBar1 As System.Windows.Forms.ProgressBar
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
    Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(frmRestartService))
    Me.Label1 = New System.Windows.Forms.Label
    Me.cmdCancel = New System.Windows.Forms.Button
    Me.ProgressBar1 = New System.Windows.Forms.ProgressBar
    Me.SuspendLayout()
    '
    'Label1
    '
    Me.Label1.FlatStyle = FlatStyle.System
    Me.Label1.Location = New System.Drawing.Point(8, 8)
    Me.Label1.Name = "Label1"
    Me.Label1.Size = New System.Drawing.Size(368, 16)
    Me.Label1.TabIndex = 0
    Me.Label1.Text = "Please wait while the xPLHal service restarts..."
    '
    'cmdCancel
    '
    Me.cmdCancel.FlatStyle = FlatStyle.System
    Me.cmdCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
    Me.cmdCancel.Location = New System.Drawing.Point(304, 72)
    Me.cmdCancel.Name = "cmdCancel"
    Me.cmdCancel.TabIndex = 1
    Me.cmdCancel.Text = "Cancel"
    '
    'ProgressBar1
    '
    Me.ProgressBar1.Location = New System.Drawing.Point(11, 32)
    Me.ProgressBar1.Name = "ProgressBar1"
    Me.ProgressBar1.Size = New System.Drawing.Size(368, 24)
    Me.ProgressBar1.TabIndex = 2
    Me.ProgressBar1.TabStop = False
    '
    'frmRestartService
    '
    Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
    Me.CancelButton = Me.cmdCancel
    Me.ClientSize = New System.Drawing.Size(384, 101)
    Me.Controls.Add(Me.ProgressBar1)
    Me.Controls.Add(Me.cmdCancel)
    Me.Controls.Add(Me.Label1)
    Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
    Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
    Me.MaximizeBox = False
    Me.MinimizeBox = False
    Me.Name = "frmRestartService"
    Me.Text = "Restart xPLHal Service"
    Me.ResumeLayout(False)

  End Sub

#End Region

    Private Sub frmRestartService_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        ProgressBar1.Minimum = 0
        ProgressBar1.Maximum = 100
        ProgressBar1.Step = 2
    End Sub

    Private Sub frmRestartService_Activated(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Activated
        If FirstActivation Then
            FirstActivation = False
            Try
                Dim ServiceName As String = ""
                Disconnect()
                Select Case ServerMajorVersion
                    Case 1
                        ServiceName = "xplhal"
                    Case 2
                        ServiceName = "xPLHal 2 Server"
                    Case Else
                        Exit Sub
                End Select
                Dim srv As System.ServiceProcess.ServiceController
                If globals.xPLHalServer.ToLower.Trim = "localhost" Then
                    srv = New System.ServiceProcess.ServiceController(ServiceName)
                Else
                    srv = New System.ServiceProcess.ServiceController(ServiceName, globals.xPLHalServer)
                End If
                Counter = 50
                srv.Stop()
                While Counter > 0
                    Application.DoEvents()
                    Counter -= 1
                    ProgressBar1.PerformStep()
                    System.Threading.Thread.Sleep(200)
                End While

                srv.Start()
                MsgBox("The xPLHal service has been restarted.", vbInformation)
            Catch ex As Exception
                MsgBox("The following error occurred whilst attempting to restart the xPLHal service on " & globals.xPLHalServer & ":" & vbCrLf & ex.Message, vbCritical)
            End Try
            Me.Close()
        End If
    End Sub

    Private Sub cmdCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Counter = -1
        Me.Close()
    End Sub
End Class
