using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace xPLHalScriptHelper {
    public partial class ScriptTabPage : UserControl {
        public ScriptSession Session { get; set; }

        public ScriptTabPage(DebugScriptInfo info) {
            InitializeComponent();
            this.Dock = DockStyle.Fill;

            Session = new ScriptSession(info);
            textBox1.Text = Session.ScriptInfo.Source;

            //set tabpage text
            if (Parent != null)
                Parent.Text = Session.ScriptInfo.ScriptName;
        }

        private void textBox1_TextChanged(object sender, EventArgs e) {
            Session.ScriptInfo.ModifiedScript = textBox1.Text;
        }

        public void Run() {
            textBox2.Text = Session.RunScript(Session.ScriptInfo.ModifiedScript);
        }

        public void RunSelection() {
            textBox2.Text = Session.RunScript(textBox1.SelectedText);
        }

        internal bool SaveScript() {
            Parent.Text = Session.ScriptInfo.ScriptName;

            return Session.SaveScript();
        }

        internal object ReloadScripts() {
            return Session.ReloadScripts();
        }
    }
}
