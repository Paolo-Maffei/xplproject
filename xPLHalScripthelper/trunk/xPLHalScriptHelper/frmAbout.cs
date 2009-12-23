using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace xPLHalScriptHelper {
    public partial class frmAbout : Form {
        public frmAbout() {
            InitializeComponent();
            lblVersion.Text = "v" + Application.ProductVersion.ToString();
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e) {
            string mailto = string.Format(
                    "mailto:{0}?Subject={1}",
                    "alex@nntw.nl", "About xPLHal Debugger....");

            System.Diagnostics.Process.Start(mailto);
        }
    }
}
