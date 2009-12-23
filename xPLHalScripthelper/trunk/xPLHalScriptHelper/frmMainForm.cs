using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.ServiceModel;
using System.Net;

namespace xPLHalScriptHelper {
    public partial class frmMainForm : Form {
        ServiceHost serviceHost;
        WCFDebugService svc;
        CloseLabel closelabel = new CloseLabel();

        bool SETTING_ALWAYS_INIT_RUNSPACE = true;
        bool SETTING_NEW_TAB_GETS_FOCUS = true;

        public frmMainForm() {
            InitializeComponent();
            GeometryFromString(Properties.Settings.Default.WindowGeometry, this);

            AddCloseButton();

            StartService();
        }

        private void AddCloseButton() {
            //quick fix for the lack of a decent close button
            closelabel.Location = new Point(tabControl1.Width + tabControl1.Left - closelabel.Width - 5, tabControl1.Top);
            closelabel.Click += new EventHandler(closelabel_Click);
            closelabel.Visible = false;
            Controls.Add(closelabel);
            closelabel.BringToFront();
        }

        void StartService() {
            svc = new WCFDebugService();
            svc.AddScript += new WCFDebugService.ScriptAddedEventHandler(svc_AddScript);
            serviceHost = new ServiceHost(svc);

            serviceHost.Open();

            toolStripStatusLabel.Text = "xPLHal Debugger is waiting for xPLHal to send some scripts. Please be sure you enabled the global variable...";
        }

        void svc_AddScript(DebugScriptInfo info) {
            //check if script exists & such here...
            //to do
            AddTabPage(info);

            toolStripStatusLabel.Text = "";
        }

        void AddTabPage(DebugScriptInfo info) {
            TabPage newPage = new TabPage();

            ScriptTabPage control = new ScriptTabPage(info);
            newPage.Controls.Add(control);
            newPage.Text = control.Session.ScriptInfo.ScriptName;

            tabControl1.TabPages.Add(newPage);
            btnRunScript.Enabled = true;
            btnRunSelection.Enabled = true;
            btnAddTab.Enabled = true;
            btnSaveScript.Enabled = true;
            btnReload.Enabled = true;

            if (SETTING_NEW_TAB_GETS_FOCUS)
                tabControl1.SelectedIndex = tabControl1.TabCount - 1;

            closelabel.Visible = true;
        }


        ScriptTabPage GetCurrentScriptTabPage() {
            if (tabControl1.SelectedTab != null)
                return ((ScriptTabPage)tabControl1.SelectedTab.Controls[0]);
            else
                return null;
        }

        /// <summary>
        /// Tries to find a previous transmitted IP address in other 'tabpages'
        /// </summary>
        /// <returns></returns>
        IPAddress TryToFindHalIPAddress() {
            foreach (TabPage page in tabControl1.TabPages) {
                if (((ScriptTabPage)page.Controls[0]).Session.ScriptInfo.HalIPAddress != null) {
                    return ((ScriptTabPage)page.Controls[0]).Session.ScriptInfo.HalIPAddress;
                }
            }

            return null;
        }


        #region Control events
        private void btnRunScript_Click(object sender, EventArgs e) {
            GetCurrentScriptTabPage().Run();
        }

        private void btnRunSelection_Click(object sender, EventArgs e) {
            GetCurrentScriptTabPage().RunSelection();
        }

        private void btnAddTab_Click(object sender, EventArgs e) {
            DebugScriptInfo dsi = new DebugScriptInfo();
            dsi.HalIPAddress = TryToFindHalIPAddress();

            AddTabPage(dsi);
        }

        private void btnSaveScript_Click(object sender, EventArgs e) {
            if ((GetCurrentScriptTabPage().SaveScript()))
                MessageBox.Show("Save of script successful.");
            else
                MessageBox.Show("Save of script failed.");
        }

        private void tabControl1_SelectedIndexChanged(object sender, EventArgs e) {
            //check capabilities of new tabpage
            if (GetCurrentScriptTabPage() != null) {
                btnRunScript.Enabled = !GetCurrentScriptTabPage().Session.IsNewScript;
                btnRunSelection.Enabled = !GetCurrentScriptTabPage().Session.IsNewScript;
            }
        }

        private void btnAbout_Click(object sender, EventArgs e) {
            using (frmAbout frm = new frmAbout()) {
                frm.ShowDialog();
            }
        }

        void closelabel_Click(object sender, EventArgs e) {
            tabControl1.TabPages.Remove(tabControl1.SelectedTab);

            closelabel.Visible = (tabControl1.TabPages.Count > 0);
        }

        private void frmMainForm_KeyDown(object sender, KeyEventArgs e) {
            switch (e.KeyCode) {
                case Keys.F5: {
                        //run
                        if (e.Shift)
                            //when shift is pressed, run selection
                            btnRunSelection_Click(this, null);
                        else
                            btnRunScript_Click(this, null);

                        break;
                    }
            }
        }

        private void btnReload_Click(object sender, EventArgs e) {
            if (((bool)GetCurrentScriptTabPage().ReloadScripts()))
                MessageBox.Show("Reload of scripts successful.");
            else
                MessageBox.Show("Reload of scripts failed.");
        }

        #endregion

        #region Window Position Persistence
        public static void GeometryFromString(string thisWindowGeometry, Form formIn) {
            if (string.IsNullOrEmpty(thisWindowGeometry) == true) {
                return;
            }
            string[] numbers = thisWindowGeometry.Split('|');
            string windowString = numbers[4];
            if (windowString == "Normal") {
                Point windowPoint = new Point(int.Parse(numbers[0]),
                    int.Parse(numbers[1]));
                Size windowSize = new Size(int.Parse(numbers[2]),
                    int.Parse(numbers[3]));

                //bool locOkay = GeometryIsBizarreLocation(windowPoint, windowSize);
                //bool sizeOkay = GeometryIsBizarreSize(windowSize);
                bool locOkay = true;
                bool sizeOkay = true;

                if (locOkay == true && sizeOkay == true) {
                    formIn.Location = windowPoint;
                    formIn.Size = windowSize;
                    formIn.StartPosition = FormStartPosition.Manual;
                    formIn.WindowState = FormWindowState.Normal;
                } else if (sizeOkay == true) {
                    formIn.Size = windowSize;
                }
            } else if (windowString == "Maximized") {
                formIn.Location = new Point(100, 100);
                formIn.StartPosition = FormStartPosition.Manual;
                formIn.WindowState = FormWindowState.Maximized;
            }
        }
        private static bool GeometryIsBizarreLocation(Point loc, Size size) {
            bool locOkay;
            if (loc.X < 0 || loc.Y < 0) {
                locOkay = false;
            } else if (loc.X + size.Width > Screen.PrimaryScreen.WorkingArea.Width) {
                locOkay = false;
            } else if (loc.Y + size.Height > Screen.PrimaryScreen.WorkingArea.Height) {
                locOkay = false;
            } else {
                locOkay = true;
            }
            return locOkay;

            return true;
        }
        private static bool GeometryIsBizarreSize(Size size) {
            return (size.Height <= Screen.PrimaryScreen.WorkingArea.Height &&
                size.Width <= Screen.PrimaryScreen.WorkingArea.Width);
        }

        public static string GeometryToString(Form mainForm) {
            return mainForm.Location.X.ToString() + "|" +
                mainForm.Location.Y.ToString() + "|" +
                mainForm.Size.Width.ToString() + "|" +
                mainForm.Size.Height.ToString() + "|" +
                mainForm.WindowState.ToString();
        }

        private void frmMainForm_FormClosing(object sender, FormClosingEventArgs e) {
            // persist our geometry string.
            Properties.Settings.Default.WindowGeometry = GeometryToString(this);
            Properties.Settings.Default.Save();
        } 
        #endregion

        private void tabControl1_Resize(object sender, EventArgs e) {
            //move close label too
            closelabel.Location = new Point(tabControl1.Width + tabControl1.Left - closelabel.Width - 5, tabControl1.Top);
        }
    }
}
