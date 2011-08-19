<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.Button1 = New System.Windows.Forms.Button
        Me.ToDecode = New System.Windows.Forms.TextBox
        Me.Encoded = New System.Windows.Forms.Label
        Me.Decoded = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(379, 54)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(75, 23)
        Me.Button1.TabIndex = 0
        Me.Button1.Text = "En/Decode"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'ToDecode
        '
        Me.ToDecode.Location = New System.Drawing.Point(47, 54)
        Me.ToDecode.Multiline = True
        Me.ToDecode.Name = "ToDecode"
        Me.ToDecode.Size = New System.Drawing.Size(326, 61)
        Me.ToDecode.TabIndex = 1
        '
        'Encoded
        '
        Me.Encoded.AutoSize = True
        Me.Encoded.Location = New System.Drawing.Point(47, 133)
        Me.Encoded.Name = "Encoded"
        Me.Encoded.Size = New System.Drawing.Size(39, 13)
        Me.Encoded.TabIndex = 2
        Me.Encoded.Text = "Label1"
        '
        'Decoded
        '
        Me.Decoded.AutoSize = True
        Me.Decoded.Location = New System.Drawing.Point(46, 163)
        Me.Decoded.Name = "Decoded"
        Me.Decoded.Size = New System.Drawing.Size(39, 13)
        Me.Decoded.TabIndex = 3
        Me.Decoded.Text = "Label1"
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(596, 262)
        Me.Controls.Add(Me.Decoded)
        Me.Controls.Add(Me.Encoded)
        Me.Controls.Add(Me.ToDecode)
        Me.Controls.Add(Me.Button1)
        Me.Name = "Form1"
        Me.Text = "Form12"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents ToDecode As System.Windows.Forms.TextBox
    Friend WithEvents Encoded As System.Windows.Forms.Label
    Friend WithEvents Decoded As System.Windows.Forms.Label
End Class
