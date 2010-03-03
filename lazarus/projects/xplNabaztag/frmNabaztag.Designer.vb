<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmNabaztag
    Inherits System.Windows.Forms.Form

    'Form remplace la méthode Dispose pour nettoyer la liste des composants.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing AndAlso components IsNot Nothing Then
            components.Dispose()
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Requise par le Concepteur Windows Form
    Private components As System.ComponentModel.IContainer

    'REMARQUE : la procédure suivante est requise par le Concepteur Windows Form
    'Elle peut être modifiée à l'aide du Concepteur Windows Form.  
    'Ne la modifiez pas à l'aide de l'éditeur de code.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(frmNabaztag))
        Me.EventLog = New System.Windows.Forms.TextBox
        Me.IconMenu = New System.Windows.Forms.ContextMenu
        Me.MenuOpen = New System.Windows.Forms.MenuItem
        Me.MenuExit = New System.Windows.Forms.MenuItem
        Me.SuspendLayout()
        '
        'EventLog
        '
        Me.EventLog.Location = New System.Drawing.Point(12, 12)
        Me.EventLog.Multiline = True
        Me.EventLog.Name = "EventLog"
        Me.EventLog.RightToLeft = System.Windows.Forms.RightToLeft.No
        Me.EventLog.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.EventLog.Size = New System.Drawing.Size(274, 187)
        Me.EventLog.TabIndex = 1
        '
        'IconMenu
        '
        Me.IconMenu.MenuItems.AddRange(New System.Windows.Forms.MenuItem() {Me.MenuOpen, Me.MenuExit})
        '
        'MenuOpen
        '
        Me.MenuOpen.Index = 0
        Me.MenuOpen.Text = "Open"
        '
        'MenuExit
        '
        Me.MenuExit.Index = 1
        Me.MenuExit.Text = "Exit"
        '
        'frmNabaztag
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(292, 212)
        Me.Controls.Add(Me.EventLog)
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "frmNabaztag"
        Me.Text = "xPL Nabaztag"
        Me.WindowState = System.Windows.Forms.FormWindowState.Minimized
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents EventLog As System.Windows.Forms.TextBox
    Friend WithEvents IconMenu As System.Windows.Forms.ContextMenu
    Friend WithEvents MenuOpen As System.Windows.Forms.MenuItem
    Friend WithEvents MenuExit As System.Windows.Forms.MenuItem

End Class
