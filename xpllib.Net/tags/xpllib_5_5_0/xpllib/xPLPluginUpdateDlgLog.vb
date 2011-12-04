'* xPL Library for .NET
'*
'* Version 5.5
'*
'* Copyright (c) 2009-2011 Thijs Schreijer
'* http://www.thijsschreijer.nl
'*
'* Copyright (c) 2008-2009 Tom Van den Panhuyzen
'* http://blog.boxedbits.com/xpl
'*
'* Copyright (C) 2003-2005 John Bent
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

Option Strict On

''' <summary>
''' Form to be used to show progress while updating the PluginStore. This form shows a message log, 
''' a progressbar and a close button when the update is complete. The form is not automatically 
''' dismissed when the update completes.
''' </summary>
''' <remarks>To use it, first set the <c>Plugin</c> property of the form, then start the update by
''' calling the <seealso cref="xPLPluginStore.UpdatePluginStore" /> method, finally call either the
''' <c>Show</c> or <c>ShowModal</c> methods of the form.</remarks>
Public Class xPLPluginUpdateDlgLog
    ''' <summary>
    ''' Plugin is to be set by the calling code to the pluginstore being updated
    ''' </summary>
    ''' <remarks></remarks>
    Public WithEvents Plugin As xPLPluginStore

    Private Sub xPLPluginUpdateDialog_FormClosing(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing
        Try
            RemoveHandler Plugin.UpdateComplete, AddressOf UpdProgrDone
            RemoveHandler Plugin.UpdateProgress, AddressOf UpdProgr
        Catch ex As Exception
        End Try
    End Sub
    Private Sub PluginUpdateDialog_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Try
            Me.Text = "Please wait..."
            Me.tbLog.Text = ""
            Me.pbProgress.Value = 0
            Me.btnClose.Enabled = False
            Me.Icon = xPL_Base.XPL_Icon
            AddHandler Plugin.UpdateProgress, AddressOf UpdProgr
            AddHandler Plugin.UpdateComplete, AddressOf UpdProgrDone
        Catch ex As Exception
        End Try
    End Sub
    Private Delegate Sub dUpdProgrEx(ByVal e As xPLPluginStore.UpdateInfo)
    Private Sub UpdProgrEx(ByVal e As xPLPluginStore.UpdateInfo)
        ' set caption
        Me.Text = "Updating plugins: " & e.StatusMsg
        ' set log
        Me.tbLog.Text = e.LogComplete
        Me.tbLog.SelectionStart = Me.tbLog.Text.Length
        Me.tbLog.ScrollToCaret()
        ' set progress bar
        Me.pbProgress.Value = e.PercentComplete
        ' enable close button
        If e.PercentComplete = 100 Then Me.btnClose.Enabled = True
    End Sub
    Private Sub UpdProgr(ByVal e As xPLPluginStore.UpdateInfo)
        If Me.tbLog.InvokeRequired Then
            Dim d As dUpdProgrEx = AddressOf UpdProgrEx
            Me.Invoke(d, e)
        Else
            UpdProgrEx(e)
        End If
    End Sub
    Private Sub UpdProgrDone(ByVal e As xPLPluginStore.UpdateInfo)
        ' progress done, make sure to set to 100% to enable the close button
        e.PercentComplete = 100
        Me.UpdProgr(e)
    End Sub
    Private Sub btnClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnClose.Click
        Me.Close()
    End Sub
End Class

