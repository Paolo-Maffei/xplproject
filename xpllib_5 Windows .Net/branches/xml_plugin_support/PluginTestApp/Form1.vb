Option Strict On
Imports System.IO
Imports System.Environment
Imports System.Xml

Public Class Form1
    Private xplug As xPLPluginStore
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        xplug = New xPLPluginStore
        xplug.UpdatePluginStore()
        xplug.SavePluginStore()
    End Sub
End Class
