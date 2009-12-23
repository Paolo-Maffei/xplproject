namespace xPLHalScriptHelper {
    partial class frmMainForm {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMainForm));
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.btnRunScript = new System.Windows.Forms.ToolStripButton();
            this.btnRunSelection = new System.Windows.Forms.ToolStripButton();
            this.btnSaveScript = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.btnAddTab = new System.Windows.Forms.ToolStripButton();
            this.btnAbout = new System.Windows.Forms.ToolStripButton();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.btnReload = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStrip1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // toolStrip1
            // 
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.btnRunScript,
            this.btnRunSelection,
            this.btnSaveScript,
            this.toolStripSeparator1,
            this.btnReload,
            this.toolStripSeparator2,
            this.btnAddTab,
            this.btnAbout});
            this.toolStrip1.Location = new System.Drawing.Point(0, 0);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Size = new System.Drawing.Size(819, 25);
            this.toolStrip1.TabIndex = 4;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // btnRunScript
            // 
            this.btnRunScript.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnRunScript.Enabled = false;
            this.btnRunScript.Image = ((System.Drawing.Image)(resources.GetObject("btnRunScript.Image")));
            this.btnRunScript.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnRunScript.Name = "btnRunScript";
            this.btnRunScript.Size = new System.Drawing.Size(65, 22);
            this.btnRunScript.Text = "Run Script";
            this.btnRunScript.ToolTipText = "Run current script (F5)";
            this.btnRunScript.Click += new System.EventHandler(this.btnRunScript_Click);
            // 
            // btnRunSelection
            // 
            this.btnRunSelection.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnRunSelection.Enabled = false;
            this.btnRunSelection.Image = ((System.Drawing.Image)(resources.GetObject("btnRunSelection.Image")));
            this.btnRunSelection.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnRunSelection.Name = "btnRunSelection";
            this.btnRunSelection.Size = new System.Drawing.Size(83, 22);
            this.btnRunSelection.Text = "Run Selection";
            this.btnRunSelection.ToolTipText = "Run Selection (Shift+F5)";
            this.btnRunSelection.Click += new System.EventHandler(this.btnRunSelection_Click);
            // 
            // btnSaveScript
            // 
            this.btnSaveScript.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnSaveScript.Enabled = false;
            this.btnSaveScript.Image = ((System.Drawing.Image)(resources.GetObject("btnSaveScript.Image")));
            this.btnSaveScript.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnSaveScript.Name = "btnSaveScript";
            this.btnSaveScript.Size = new System.Drawing.Size(68, 22);
            this.btnSaveScript.Text = "Save Script";
            this.btnSaveScript.Click += new System.EventHandler(this.btnSaveScript_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 25);
            // 
            // btnAddTab
            // 
            this.btnAddTab.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnAddTab.Enabled = false;
            this.btnAddTab.Image = ((System.Drawing.Image)(resources.GetObject("btnAddTab.Image")));
            this.btnAddTab.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnAddTab.Name = "btnAddTab";
            this.btnAddTab.Size = new System.Drawing.Size(67, 22);
            this.btnAddTab.Text = "New script";
            this.btnAddTab.Click += new System.EventHandler(this.btnAddTab_Click);
            // 
            // btnAbout
            // 
            this.btnAbout.Alignment = System.Windows.Forms.ToolStripItemAlignment.Right;
            this.btnAbout.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnAbout.Image = ((System.Drawing.Image)(resources.GetObject("btnAbout.Image")));
            this.btnAbout.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnAbout.Name = "btnAbout";
            this.btnAbout.Size = new System.Drawing.Size(44, 22);
            this.btnAbout.Text = "About";
            this.btnAbout.Click += new System.EventHandler(this.btnAbout_Click);
            // 
            // tabControl1
            // 
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.ItemSize = new System.Drawing.Size(80, 18);
            this.tabControl1.Location = new System.Drawing.Point(0, 25);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(819, 575);
            this.tabControl1.TabIndex = 5;
            this.tabControl1.Resize += new System.EventHandler(this.tabControl1_Resize);
            this.tabControl1.SelectedIndexChanged += new System.EventHandler(this.tabControl1_SelectedIndexChanged);
            // 
            // statusStrip1
            // 
            this.statusStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Visible;
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel});
            this.statusStrip1.Location = new System.Drawing.Point(0, 578);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(819, 22);
            this.statusStrip1.TabIndex = 6;
            this.statusStrip1.Text = "statusStrip";
            // 
            // toolStripStatusLabel
            // 
            this.toolStripStatusLabel.Name = "toolStripStatusLabel";
            this.toolStripStatusLabel.Size = new System.Drawing.Size(118, 17);
            this.toolStripStatusLabel.Text = "toolStripStatusLabel1";
            // 
            // btnReload
            // 
            this.btnReload.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.btnReload.Enabled = false;
            this.btnReload.Image = ((System.Drawing.Image)(resources.GetObject("btnReload.Image")));
            this.btnReload.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnReload.Name = "btnReload";
            this.btnReload.Size = new System.Drawing.Size(85, 22);
            this.btnReload.Text = "Reload Scripts";
            this.btnReload.Click += new System.EventHandler(this.btnReload_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(6, 25);
            // 
            // frmMainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(819, 600);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.toolStrip1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.Name = "frmMainForm";
            this.Text = "frmMainForm";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmMainForm_FormClosing);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.frmMainForm_KeyDown);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripButton btnRunScript;
        private System.Windows.Forms.ToolStripButton btnRunSelection;
        private System.Windows.Forms.ToolStripButton btnSaveScript;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripButton btnAddTab;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel;
        private System.Windows.Forms.ToolStripButton btnAbout;
        private System.Windows.Forms.ToolStripButton btnReload;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
    }
}