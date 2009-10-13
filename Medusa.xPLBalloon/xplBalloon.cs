/*
xPLBalloon
Shows contents of xPL messages as popups in the taskbar notification area.

Author: Tom Van den Panhuyzen   tomvdp at gmail(dot)com
http://blog.boxedbits.com/xpl

Credits to  John O'Byrne  & "Crusty  Applesniffer" for  their work  on the popup
windows.

V1.0 20/04/2008: original release
V1.1 03/05/2008: support for osd.basic, added finetuning via appfilter
V1.2 01/08/2008: recompiled with xpllib V4.4
*/

using System;
using System.Collections.Generic;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using xpllib;
using CustomUIControls;
using System.Diagnostics;

namespace xPLBalloon
{
    public partial class frmxPLBalloon : Form
    {
        const string VENDORID = "medusa";
        const string DEVICEID = "balloon";

        private int mShowSecs = 5;
        private int mFadeInMSecs = 300;
        private int mFadeOutMSecs = 300;
        private int mUseFading = 1;
        private Hashtable mFilterApps = new Hashtable(10);

        private XplListener xL;
        private ToastCollection m_ColToast = new ToastCollection();
        private bool bExitApp;

        public frmxPLBalloon()
        {
            InitializeComponent();
            this.Hide();
            bExitApp = false;
            initializeXPL();
        }

        void initializeXPL()
        {
            xL = new XplListener(VENDORID, DEVICEID);

            //definition of the configuration items
            xL.ConfigItems.Define("showsecs", mShowSecs.ToString());
            xL.ConfigItems.Define("fadeinmsecs", mFadeInMSecs.ToString());
            xL.ConfigItems.Define("fadeoutmsecs", mFadeOutMSecs.ToString());
            xL.ConfigItems.Define("usefading", mUseFading.ToString());
            xL.ConfigItems.Define("appfilter", 16);   //multi-valued

            //default filter value
            xL.Filters.Add(new XplListener.XplFilter(XplMessageTypes.Any, "*", "*", "*", "log", "basic"));

            //possibly show also msgs not intended for us
            xL.Filters.MatchTarget = false;

            //prepare to receive events
            xL.XplConfigDone += new XplListener.XplConfigDoneEventHandler(xL_XplConfigDone);
            xL.XplJoinedxPLNetwork += new XplListener.XplJoinedxPLNetworkEventHandler(xL_XplJoinedxPLNetwork);
            xL.XplReConfigDone += new XplListener.XplReConfigDoneEventHandler(xL_XplReConfigDone);
            xL.XplMessageReceived += new XplListener.XplMessageReceivedEventHandler(xL_XplMessageReceived);

            //connect to the xpl network
            xL.Listen();
        }

        void xL_XplJoinedxPLNetwork()
        {
            ShowMsg("xPLBalloon","Joined the xPL network",0);
        }

        void stopXPL()
        {
            xL.Dispose();
        }

        private void xL_XplMessageReceived(object sender, XplListener.XplEventArgs e)
        {
            try
            {
                //maybe it should be ignored
                if ((mFilterApps.Count > 0)
                    && (mFilterApps.ContainsKey(e.XplMsg.SourceVendor + "." + e.XplMsg.SourceDevice)))
                {
                    string lvls = (string)mFilterApps[e.XplMsg.SourceVendor + "." + e.XplMsg.SourceDevice];
                    bool foundKey = false;
                    bool foundMatch = false;
                    foreach (XplMsg.KeyValuePair kv in e.XplMsg.KeyValues)
                    {
                        if(lvls.IndexOf(kv.Key + "=") >=0)
                        {
                            foundKey = true;
                            if (lvls.IndexOf(kv.Key + "=" + kv.Value.ToLower()) >= 0)
                            {
                                foundMatch = true;
                                break;
                            }
                        }
                    }

                    if (foundKey && !foundMatch)
                        return;
                }


                string title = "";
                string txt = "";
                int level = 0;
                int delay = mShowSecs;
                string othertxt = "";
                bool isOsdBasic = ((e.XplMsg.Type.ToLower() == "osd") && (e.XplMsg.Class.ToLower() == "basic"));

                foreach (XplMsg.KeyValuePair kv in e.XplMsg.KeyValues)
                    {

                    switch (kv.Key.ToLower())
                    {
                        case "title":
                            title = kv.Value;
                            break;

                        case "type":
                            switch (kv.Value.ToLower())
                            {
                                case "err": level = 2;
                                    break;
                                case "wrn": level = 1;
                                    break;
                                case "inf": level = 0;
                                    break;
                                default:
                                    othertxt += kv.Key + "=" + kv.Value + "\n";
                                    level = 0;
                                    break;
                            }
                            break;

                        case "text":
                            txt += kv.Value + "\n";
                            break;

                        case "delay":
                            if (!Int32.TryParse(kv.Value, out delay))
                                delay = mShowSecs;
                            break;

                        case "command":
                            if (!isOsdBasic)
                                othertxt += kv.Key + "=" + kv.Value + "\n";
                            break;

                        case "row":
                            if (!isOsdBasic)
                                othertxt += kv.Key + "=" + kv.Value + "\n";
                            break;

                        case "column":
                            if (!isOsdBasic)
                                othertxt += kv.Key + "=" + kv.Value + "\n";
                            break;

                        default:
                            othertxt += kv.Key + "=" + kv.Value + "\n";
                            break;
                    }
                }

                if (title.Length == 0)
                    title = "xPL message (" + e.XplMsg.Class + "." + e.XplMsg.Type + ")";


                if (othertxt.Length > 0)
                    if (txt.Length > 0)
                        txt += "\n" + othertxt;
                    else
                        txt = othertxt;

                ShowMsg(title, txt, level, delay);
            }
            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message);
                eventLog.WriteEntry("Unable to show balloon: " + ex.Message, EventLogEntryType.Error);
            }
        }
        
        #region Popup Message aka Notifier

        public void ShowMsg(string title, string msg, int level)
        {
            this.ShowMsg(title, msg, level, mShowSecs);
        }

        public void ShowMsg(string title, string msg, int level, int delay)
        {
            this.Invoke(new NotifierHandler(NotifierSub), new object[] { title, msg, level, delay});
        }

        delegate void NotifierHandler(string title, string msg, int level, int delay);

        public void NotifierSub(string title, string msg, int level, int delay)
        {
            TaskbarNotifier notifier = InitTaskBarNotifier(new TaskbarNotifier());
            switch (level)
            {
                case 1: notifier.SetBackgroundBitmap(new Bitmap(GetType(), "skinw.bmp"), Color.FromArgb(255, 0, 255));
                    break;
                case 2: notifier.SetBackgroundBitmap(new Bitmap(GetType(), "skine.bmp"), Color.FromArgb(255, 0, 255));
                    break;
                default: notifier.SetBackgroundBitmap(new Bitmap(GetType(), "skini.bmp"), Color.FromArgb(255, 0, 255));
                    break;
            }

            notifier.AppearBySliding = (mUseFading==0);
            notifier.Show(title, msg, mFadeInMSecs, delay * 1000, mFadeOutMSecs);
        }

        private TaskbarNotifier InitTaskBarNotifier(TaskbarNotifier notifier)
        {
            notifier.Base = m_ColToast;
            notifier.SetCloseBitmap(new Bitmap(GetType(), "close.bmp"), Color.FromArgb(255, 0, 255), new Point(230, 8));
            notifier.TitleRectangle = new Rectangle(45, 9, 200, 25);
            notifier.ContentRectangle = new Rectangle(45, 40, 220, 68);
            notifier.ContentTextAlignement = ContentAlignment.TopLeft;
            notifier.CloseClickable = true;
            notifier.TitleClickable = false;
            notifier.ContentClickable = false;
            notifier.EnableSelectionRectangle = false;
            notifier.KeepVisibleOnMousOver = true;
            notifier.ReShowOnMouseOver = true;
            notifier.Padding = 0;
            return notifier;
        }
        #endregion

        private void xL_XplConfigDone(XplListener.XplLoadStateEventArgs e)
        {
            CheckConfig();
        }

        private void xL_XplReConfigDone(XplListener.XplLoadStateEventArgs e)
        {
            CheckConfig();
        }

        private void CheckConfig()
        {
            try
            {
                mShowSecs=Math.Abs(Int32.Parse(xL.ConfigItems["showsecs"].Value));
                mFadeInMSecs=Math.Abs(Int32.Parse(xL.ConfigItems["fadeinmsecs"].Value));
                mFadeOutMSecs=Math.Abs(Int32.Parse(xL.ConfigItems["fadeoutmsecs"].Value));
                mUseFading=Math.Abs(Int32.Parse(xL.ConfigItems["usefading"].Value));

                if (mUseFading>1)
                    mUseFading=1;

                //the apps/devices to show specific levels for
                mFilterApps.Clear();
                for (int i = 0; i < xL.ConfigItems["appfilter"].ValueCount; i++)
                {
                    string a = xL.ConfigItems["appfilter"].Values[i];
                    int j = a.IndexOf(':', 1);
                    if (j > 1)
                        mFilterApps.Add(a.Substring(0, j).ToLower(), a.Substring(j + 1));
                }

            }
            catch (Exception ex)
            {
                //popup the error
                ShowMsg("Configuration Error", ex.Message, 2);
            }
        }

        private void frmxPLBalloon_FormClosing(object sender, FormClosingEventArgs e)
        {
            bool bReallyExit = (bExitApp || (e.CloseReason == CloseReason.WindowsShutDown));
            if (bReallyExit) stopXPL();
            e.Cancel = !bReallyExit;
        }

        private void exitMenuItem_Click(object sender, EventArgs e)
        {
            bExitApp = true;
            Application.Exit();
        }
    }
}
