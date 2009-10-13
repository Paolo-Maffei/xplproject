/*

XPLLogger V1.2
Copyright (C) 2004  Tom Van den Panhuyzen

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

tomvdp at gmail(dot)com
http://blog.boxedbits.com/xpl

*/

using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.ServiceProcess;
using System.Xml;
using System.Xml.Xsl;
using xpllib;

namespace Medusa.XPLLogger
{
	public class XPLLogger:ServiceBase
	{
		const string VENDORID = "medusa";
		const string DEVICEID = "logger";
		const int DEFAULTLOGSIZE = 200;  //default nr of msgs to keep in log

		//write to log in chunks (msgs come often in pairs, so avoid opening,writing,closing for each msg)
		const int MSGCACHESIZE = 10;
		private XplMsg[] MsgCache;
		private DateTime[] MsgCacheIn;
		private int MsgCacheIdx;

		private XplListener xL;

		private string mPath = String.Empty;
		private string mXML = String.Empty;
		private string mXSL = String.Empty;
		private string mOut = String.Empty;
		private int mLogSize;
        private Hashtable mFilterApps = new Hashtable(10);

		private void InitializeComponent()
		{
			this.ServiceName = "XPLLogger";
			this.CanShutdown = true;
			this.CanPauseAndContinue = false;
		}

		public XPLLogger()
		{
			InitializeComponent();

			if (!(System.Diagnostics.EventLog.SourceExists(this.ServiceName)))
			{
				System.Diagnostics.EventLog.CreateEventSource(this.ServiceName, "Application");
			}
		}

		static void Main()
		{
			System.ServiceProcess.ServiceBase.Run(new XPLLogger());
		}

		protected override void Dispose( bool disposing ) 
		{
			if (xL != null)
				xL.Dispose();

			base.Dispose( disposing );
		}


		protected override void OnStart(string[] args)
		{
			MsgCache = new XplMsg[MSGCACHESIZE];
			MsgCacheIn = new DateTime[MSGCACHESIZE];
			MsgCacheIdx = 0;
			xL = new XplListener(VENDORID, DEVICEID, EventLog);

            xL.ConfigItems.Define("loglen", DEFAULTLOGSIZE.ToString());
            xL.ConfigItems.Define("lpath", @"c:\temp\");
            xL.ConfigItems.Define("xml", "log.xml");
            xL.ConfigItems.Define("xsl", "log.xsl");
            xL.ConfigItems.Define("out", "log.htm");
            xL.ConfigItems.Define("appfilter", 16);   //multi-valued

			xL.Filters.Add(new XplListener.XplFilter(XplMessageTypes.Trigger, "*", "*", "*", "log", "basic"));

			//log also msgs not intended for us
			xL.Filters.MatchTarget = false;

			//receive Configuration Done notification
			xL.XplConfigDone += new xpllib.XplListener.XplConfigDoneEventHandler(xL_XplConfigDone);

			//receive reconfiguration done
			xL.XplReConfigDone += new xpllib.XplListener.XplReConfigDoneEventHandler(xL_XplReConfigDone);

			//start listening
			xL.XplMessageReceived += new xpllib.XplListener.XplMessageReceivedEventHandler(xL_XplMessageReceived);
			xL.Listen();

			if (!xL.AwaitingConfiguration)
				EventLog.WriteEntry(DEVICEID + " started logging to " + mPath + mXML, EventLogEntryType.Information);
			else
				EventLog.WriteEntry(DEVICEID + " started, awaiting configuration", EventLogEntryType.Information);

		}

		protected override void OnStop()
		{
			try
			{
				if (!xL.AwaitingConfiguration)
					//flush the cache
					WriteXPLasXML();
			}
			catch (Exception ex)
			{
				EventLog.WriteEntry("Unexpected error: " + ex.Message, EventLogEntryType.Error);
			}
			xL.Dispose();
		}

		protected override void OnShutdown()
		{
			try
			{
			if (!xL.AwaitingConfiguration)
				//flush the cache
				WriteXPLasXML();
			}
			catch (Exception ex)
			{
				EventLog.WriteEntry("Unexpected error: " + ex.Message, EventLogEntryType.Error);
			}

			base.OnShutdown ();
		}

		private void xL_XplMessageReceived(object sender, xpllib.XplListener.XplEventArgs e)
		{
			//do not log our own messages...
			if ((e.XplMsg.SourceVendor.ToLower()==VENDORID)
				&& (e.XplMsg.SourceDevice.ToLower()==DEVICEID)
				&& (e.XplMsg.SourceInstance.ToLower()==xL.InstanceName.ToLower())) return;
			
			//...neither message for ourselves unless the schema is LOG.BASIC
			if ((e.XplMsg.TargetVendor.ToLower()==VENDORID)
				&& (e.XplMsg.TargetDevice.ToLower()==DEVICEID)
				&& (e.XplMsg.TargetInstance.ToLower()==xL.InstanceName.ToLower())
				&& (e.XplMsg.Class.ToLower()!="log")
				&& (e.XplMsg.Type.ToLower()!="basic")) return;



            //maybe it should be ignored
            if ((mFilterApps.Count > 0)
                && (mFilterApps.ContainsKey(e.XplMsg.SourceVendor + "." + e.XplMsg.SourceDevice)))
            {
                string lvls = (string)mFilterApps[e.XplMsg.SourceVendor + "." + e.XplMsg.SourceDevice];
                bool foundKey = false;
                bool foundMatch = false;
                foreach (XplMsg.KeyValuePair kv in e.XplMsg.KeyValues)
                {
                    if (lvls.IndexOf(kv.Key + "=") >= 0)
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

			MsgCache[MsgCacheIdx] = e.XplMsg;
			MsgCacheIn[MsgCacheIdx] = DateTime.Now;
			MsgCacheIdx++;

			//flush if the cache is full or if we received an explicit log message
			if ((MsgCacheIdx==MSGCACHESIZE) || (e.XplMsg.Class.ToLower()=="log"))
			{
				WriteXPLasXML();
				MsgCacheIdx = 0;
			}
		}

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
			//correct common stupidities the user may have entered in the config screen
			if (!xL.ConfigItems["lpath"].Value.EndsWith(@"\")) xL.ConfigItems["lpath"].Value += @"\";
			if (xL.ConfigItems["xml"].Value.StartsWith(@"\")) xL.ConfigItems["xml"].Value = xL.ConfigItems["xml"].Value.Substring(1);
			if (xL.ConfigItems["xsl"].Value.StartsWith(@"\")) xL.ConfigItems["xsl"].Value = xL.ConfigItems["xsl"].Value.Substring(1);
			if (xL.ConfigItems["out"].Value.StartsWith(@"\")) xL.ConfigItems["htm"].Value = xL.ConfigItems["out"].Value.Substring(1);

			string oldXML = mPath + mXML;
			mPath = xL.ConfigItems["lpath"].Value;
			mXML = xL.ConfigItems["xml"].Value;
			mXSL = xL.ConfigItems["xsl"].Value;
			mOut = xL.ConfigItems["out"].Value;
			try
			{
				mLogSize = Math.Abs(Int32.Parse(xL.ConfigItems["loglen"].Value));
			}
			catch(Exception ex)
			{
				//log
				mLogSize = DEFAULTLOGSIZE;
				EventLog.WriteEntry("Invalid number in Configuration element 'loglen', value set to " + mLogSize.ToString() + "\nExact error was: " + ex.Message, EventLogEntryType.Warning);
			}

			if (oldXML!=mPath+mXML)
				EventLog.WriteEntry(DEVICEID + " now logging to " + mPath + mXML,EventLogEntryType.Information);

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

		//flush the cache to disk in XML format & possibly apply XSL
		private void WriteXPLasXML()
		{
			bool tmpFile = false;
			string tempXML = mPath + mXML + "tmp0.xml";

			if (File.Exists(mPath + mXML))
			{
				try
				{
					if (File.Exists(tempXML))
						File.Delete(tempXML);
					File.Move(mPath + mXML, tempXML);
					tmpFile = true;
				}
				catch(Exception ex)
				{
					//Log
					EventLog.WriteEntry("File IO error: " + ex.Message, EventLogEntryType.Error);
					//cannot continue
					return;
				}
			}
			else
				tmpFile=false;

			XmlTextWriter xw = new XmlTextWriter(mPath + mXML,null);
			try
			{
				xw.Formatting = Formatting.Indented;
				xw.WriteStartDocument();
				xw.WriteComment("File generated by " + VENDORID + "-" + DEVICEID);

				//add the following 2 lines if you want an inline style-sheet
				//if (mXSL.Length>0)
				//	xw.WriteProcessingInstruction("xml-stylesheet","type='text/xsl' href='" + mXSL + "'");
				
				xw.WriteStartElement("log");

				XplMsg m;
				//write cached msgs, FIFO
				for (int i=MsgCacheIdx-1; i>=0; i--)
				{
					m = MsgCache[i];
					xw.WriteStartElement("xplmsg");
					xw.WriteAttributeString("logdate", XmlConvert.ToString(MsgCacheIn[i],"dd-MM-yy HH:mm:ss"));

					xw.WriteStartElement("header");

					xw.WriteElementString("msgtype", m.MsgTypeString);

					xw.WriteStartElement("source");
					xw.WriteElementString("vendor", m.SourceVendor);
					xw.WriteElementString("device", m.SourceDevice);
					xw.WriteElementString("instance", m.SourceInstance);
					xw.WriteEndElement();  //source

					xw.WriteStartElement("target");
					xw.WriteElementString("vendor", m.TargetVendor);
					xw.WriteElementString("device", m.TargetDevice);
					xw.WriteElementString("instance", m.TargetInstance);
					xw.WriteEndElement();  //target

					xw.WriteEndElement();  //header

					xw.WriteStartElement("schema");
					xw.WriteElementString("class", m.Class);
					xw.WriteElementString("type", m.Type);

					xw.WriteStartElement("infopairs");

                    foreach (XplMsg.KeyValuePair kv in m.KeyValues)
                    {
						xw.WriteStartElement("info");
						xw.WriteAttributeString("name", kv.Key);
						xw.WriteAttributeString("value", kv.Value);
						xw.WriteEndElement();

                    }
					xw.WriteEndElement();  //infopairs
					xw.WriteEndElement();  //schema

					xw.WriteStartElement("raw");

					xw.WriteCData(m.RawXPL); 

					xw.WriteEndElement();  //raw

					xw.WriteEndElement();  //xplmsg
				}
			}

			catch(Exception ex)
			{
				//log
				EventLog.WriteEntry("XML Write file IO error: " + ex.Message, EventLogEntryType.Error);
				//try to restore the backup
				if (xw != null)
					xw.Close();
				try
				{
					if (File.Exists(mPath + mXML))
						File.Delete(mPath + mXML);
					File.Move(tempXML, mPath + mXML);
					EventLog.WriteEntry("Restored log to previous state", EventLogEntryType.Warning);
				}
				catch
				{
					EventLog.WriteEntry("Could not restore log to previous state", EventLogEntryType.Error);
				}
				//and quit
				return;
			}

			bool addendtag = true;
			if (tmpFile)
			{
			int n=0;

				//copy nodes from previous log
				XmlTextReader xr = new XmlTextReader(tempXML);
				xr.WhitespaceHandling=WhitespaceHandling.None;
				xr.MoveToContent();
				xr.Read();
				while ((n<mLogSize-MsgCacheIdx) && !xr.EOF)
				{
					n++;
					xw.WriteNode(xr,false);
					if (xr.EOF) addendtag = false;
				}
				xr.Close();
			}
			
			if (addendtag)  //funny: the nodes copied from xr also add an end tag ?!
				xw.WriteEndElement();  //log  

			xw.Close();

			if (mXSL.Length>0 && mOut.Length>0)
				ApplyXSL();

		}

		private	bool xsl_error_logged = false;
		private void ApplyXSL()
		{
			try
			{
				XslCompiledTransform xsltransform = new XslCompiledTransform();
				xsltransform.Load(mPath + mXSL);
				xsltransform.Transform(mPath + mXML, mPath + xL.ConfigItems["out"].Value);
			}
			catch (Exception ex)
			{
				if (!xsl_error_logged)
				{
					EventLog.WriteEntry("Error applying XSL: " + ex.Message, EventLogEntryType.Error);
					xsl_error_logged = true;  //log this only once  (likely to be logged for each entry otherwise)
				}
			}
		}
	}
}
