/*
'* xPL CM11
'*
'* Written by Tom Van den Panhuyzen
'* Version 1.00 - 5/feb/2005
'* Version 1.01 - 20/mar/2005  (modified timeout settings)
'* Version 1.02 - 02/oct/2005  (recompiled with xpllib V4.1)
'* Version 1.03 - 16/dec/2005  (PREDIM1/2 now use the level attribute)
'* Version 1.04 - 11/feb/2007  (no more timeout when sending commands to the CM11 while a message arrives at powerline)
'* Version 1.05 - 01/aug/2008  (recompiled with xpllib V4.4, COM-port reconfigurable)
'*
'* For more information on the serial communications library (CommBase), see:
'* "Serial Comm: Use P/Invoke to Develop a .NET Base Class Library
'* for Serial Device Communications" John Hind, MSDN Magazine, Oct 2002
'*
'*/

/*
 Copyright 2007, 2008 Tom Van den Panhuyzen
 tomvdp at gmail(dot)com
 http://blog.boxedbits.com/xpl
 
 This file is part of Medusa.XPLCM11.

    Medusa.XPLCM11 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    Medusa.XPLCM11 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using xpllib;

namespace Medusa.XPLCM11
{
	public class XPLCM11 : System.ServiceProcess.ServiceBase
	{
		const string VENDORID = "medusa";
		const string DEVICEID = "xplcm11";

		private enum X10_COMMANDS
		{
			ALL_UNITS_OFF = 0,
			ALL_LIGHTS_ON = 1,
			ON = 2,
			OFF = 3,
			DIM = 4,
			BRIGHT = 5,
			ALL_LIGHTS_OFF = 6,
			EXTENDED = 7,
			HAIL_REQ = 8,
			HAIL_ACK = 9,
			PRESET_DIM1 = 10,
			PRESET_DIM2 = 11,
			EXTENDED_DATA = 12,
			STATUS_ON = 13,
			STATUS_OFF = 14,
			STATUS_REQUEST = 15
		}

		private XplListener xL;
		private X10Comm x10;
        private int mComPort;

		public XPLCM11()
		{
			this.ServiceName = "XPLCM11";
			if (!(System.Diagnostics.EventLog.SourceExists(this.ServiceName)))
			{
				System.Diagnostics.EventLog.CreateEventSource(this.ServiceName, "Application");
			}		
		}

		static void Main()
		{
			System.ServiceProcess.ServiceBase.Run(new XPLCM11());
		}

		protected override void Dispose(bool disposing)
		{
			if (xL != null)
				xL.Dispose();

			if (x10 != null)
				x10.Dispose();

			base.Dispose( disposing );
		}

		protected override void OnStart(string[] args)
		{
			x10 = X10Comm.Instance;

			xL = new XplListener(VENDORID, DEVICEID, EventLog);

            xL.ConfigItems.Define("comport", "1");
            xL.Filters.Add(new XplListener.XplFilter(xpllib.XplMessageTypes.Command, "*", "*", "*", "x10", "*"));

			//receive Configuration Done notification
			xL.XplConfigDone += new xpllib.XplListener.XplConfigDoneEventHandler(xL_XplConfigDone);
            xL.XplReConfigDone += new xpllib.XplListener.XplReConfigDoneEventHandler(xL_XplReConfigDone);

            //listen
            xL.XplMessageReceived += new xpllib.XplListener.XplMessageReceivedEventHandler(xL_XplMessageReceived);
			xL.Listen();
		}
 
		private void InitCM11()
		{
			try
			{
				x10.Eventlog = EventLog;
                mComPort = Int32.Parse(xL.ConfigItems["comport"].Value);
                x10.ComPort = mComPort;
				x10.Open();
				x10.ReceivedX10 += new ReceivedX10EventHandler(x10_ReceivedX10);
				x10.SendX10Result += new SendX10ResultEventHandler(x10_SendX10Result);
			}
			catch (Exception Ex)
			{
				EventLog.WriteEntry(Ex.Message);
			}
		}

		protected override void OnStop()
		{
			try
			{
				x10.Dispose();
				x10 = null;
				xL.Dispose();
				xL = null;
			}
			catch (Exception ex)
			{
				EventLog.WriteEntry("Unexpected error: " + ex.Message, EventLogEntryType.Error);
			}
		}

		private void x10_ReceivedX10(object sender, X10EventArgs e)
		{
			X10Event2XPLMsg(e, false);
		}

		private void x10_SendX10Result(object sender, X10EventArgs e)
		{
			if (e.ResultCode == 0)  //OK
			{
				X10Event2XPLMsg(e, true);
			}
			else //error
			{
                XplMsg x = xL.GetPreparedXplMessage(XplMsg.xPLMsgType.trig, true);
                x.Class = "log";
                x.Type = "basic";
                x.AddKeyValuePair("type", "err");
                x.AddKeyValuePair("code", "x10");
                x.AddKeyValuePair("text", "error " + e.Devices + " " + X10Enum2String(e.X10Command));
                x.Send();
//				string xplMsg = "type=err" + '\n' + "code=x10" + '\n' + "text=error " + e.Devices + " " + X10Enum2String(e.X10Command) + '\n';
//				xL.SendMessage("xpl-cmnd", "*", "log.basic", xplMsg);
			}
		}

		private void X10Event2XPLMsg(X10EventArgs e, bool confirmation)
		{
			//string xplMsg = string.Empty;
            XplMsg x = xL.GetPreparedXplMessage(XplMsg.xPLMsgType.trig, true);
            x.Class="x10";

			if (e.Devices.Length==1)  //housecode, no devices
			{
				//xplMsg = "command=" + X10Enum2String(e.X10Command) + '\n' + "house=" + e.Devices + '\n';
                x.AddKeyValuePair("command", X10Enum2String(e.X10Command));
                x.AddKeyValuePair("house", e.Devices);

                if (e.X10Command == (byte)X10_COMMANDS.BRIGHT || e.X10Command == (byte)X10_COMMANDS.DIM || e.X10Command == (byte)X10_COMMANDS.PRESET_DIM1 || e.X10Command == (byte)X10_COMMANDS.PRESET_DIM2)
                    //xplMsg += "level=" + e.Brightness.ToString() + '\n';
                    x.AddKeyValuePair("level", e.Brightness.ToString());
                else if (e.X10Command == (byte)X10_COMMANDS.EXTENDED)
                {
                    //xplMsg += "data1=" + e.Data1.ToString() + '\n' + "data2=" + e.Data2.ToString() + '\n';
                    x.AddKeyValuePair("data1", e.Data1.ToString());
                    x.AddKeyValuePair("data2", e.Data2.ToString());
                }
                if (confirmation)
                    //xL.SendMessage("xpl-trig", "*", "x10.confirm", xplMsg);
                    x.Type = "confirm";
                else
                    //xL.SendMessage("xpl-trig", "*", "x10.basic", xplMsg);
                    x.Type = "basic";

                x.Send();
			}
			else //devices, send an xpl msg per device
			{
				string[] ardev = e.Devices.Split(',');
				for (int i=0; i<ardev.Length; i++)
				{
					//xplMsg = "command=" + X10Enum2String(e.X10Command) + '\n' + "device=" + (i>0?ardev[0].Substring(0,1):"") + ardev[i] + '\n';
                    x.AddKeyValuePair("command", X10Enum2String(e.X10Command));
                    x.AddKeyValuePair("device", (i > 0 ? ardev[0].Substring(0, 1) : "") + ardev[i]);

					if (e.X10Command == (byte) X10_COMMANDS.BRIGHT || e.X10Command == (byte) X10_COMMANDS.DIM || e.X10Command == (byte) X10_COMMANDS.PRESET_DIM1 || e.X10Command == (byte) X10_COMMANDS.PRESET_DIM2)
						//xplMsg += "level=" + e.Brightness.ToString() + '\n';
                        x.AddKeyValuePair("level", e.Brightness.ToString());

                    else if (e.X10Command == (byte)X10_COMMANDS.EXTENDED)
                    {
                        //xplMsg += "data1=" + e.Data1.ToString() + '\n' + "data2=" + e.Data2.ToString() + '\n';
                        x.AddKeyValuePair("data1", e.Data1.ToString());
                        x.AddKeyValuePair("data2", e.Data2.ToString());
                    }
					if (confirmation)
                        //xL.SendMessage("xpl-trig", "*", "x10.confirm", xplMsg);
                        x.Type = "confirm";
                    else
                        //xL.SendMessage("xpl-trig", "*", "x10.basic", xplMsg);
                        x.Type = "basic";

                    x.Send();
                }
			}
		}

		private string X10Enum2String(byte cmd)
		{
			string command;
			switch ((X10_COMMANDS) cmd)
			{
				case X10_COMMANDS.ALL_LIGHTS_OFF: command = "ALL_LIGHTS_OFF"; break;
				case X10_COMMANDS.ALL_LIGHTS_ON: command = "ALL_LIGHTS_ON"; break;
				case X10_COMMANDS.ON: command = "ON"; break;
				case X10_COMMANDS.OFF: command = "OFF"; break;
				case X10_COMMANDS.DIM: command = "DIM"; break;
				case X10_COMMANDS.BRIGHT: command = "BRIGHT"; break;
				case X10_COMMANDS.ALL_UNITS_OFF: command = "ALL_UNITS_OFF"; break;
				case X10_COMMANDS.EXTENDED: command = "EXTENDED"; break;
				case X10_COMMANDS.HAIL_REQ: command = "HAIL_REQ"; break;
				case X10_COMMANDS.HAIL_ACK: command = "HAIL_ACK"; break;
				case X10_COMMANDS.PRESET_DIM1: command = "PREDIM1"; break;
				case X10_COMMANDS.PRESET_DIM2: command = "PREDIM2"; break;
				case X10_COMMANDS.EXTENDED_DATA: command = "EXTENDED_DATA"; break;
				case X10_COMMANDS.STATUS_ON: command = "STATUS_ON"; break;
				case X10_COMMANDS.STATUS_OFF: command = "STATUS_OFF"; break;
				case X10_COMMANDS.STATUS_REQUEST: command = "STATUS"; break;
				default: command = "unknown"; break;
			}
			return command;
		}

        private void xL_XplConfigDone(XplListener.XplLoadStateEventArgs e)
		{
			//xpl config done -> start CM11
			InitCM11();				
		}

        private void xL_XplReConfigDone(XplListener.XplLoadStateEventArgs e)
        {
            try
            {
                if (mComPort != Int32.Parse(xL.ConfigItems["comport"].Value))
                {
                    //the COM port changed
                    if (x10!=null) x10.Dispose();
                    x10 = X10Comm.Instance;
                    InitCM11();
                }
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("Illegal COM-port value.\n" + ex.Message);
            }
        }

		private void xL_XplMessageReceived(object sender, xpllib.XplListener.XplEventArgs e)
		{
			try
			{
				X10_COMMANDS command=0;
				string scmd = e.XplMsg.GetKeyValue("command").ToUpper();
            
				switch(scmd)
				{
					case "ALL_LIGHTS_OFF": command = X10_COMMANDS.ALL_LIGHTS_OFF; break;
					case "ALL_LIGHTS_ON": command = X10_COMMANDS.ALL_LIGHTS_ON; break;
					case "ON": command = X10_COMMANDS.ON; break;
					case "OFF": command = X10_COMMANDS.OFF; break;
					case "DIM": command = X10_COMMANDS.DIM; break;
					case "BRIGHT": command = X10_COMMANDS.BRIGHT; break;
					case "ALL_UNITS_OFF": command = X10_COMMANDS.ALL_UNITS_OFF; break;
					case "EXTENDED": command = X10_COMMANDS.EXTENDED; break;
					case "HAIL_REQ": command = X10_COMMANDS.HAIL_REQ; break;
					case "HAIL_ACK": command = X10_COMMANDS.HAIL_ACK; break;
					case "PREDIM1": command = X10_COMMANDS.PRESET_DIM1; break;
					case "PREDIM2": command = X10_COMMANDS.PRESET_DIM2; break;
					case "EXTENDED_DATA": command = X10_COMMANDS.EXTENDED_DATA; break;
					case "STATUS_ON": command = X10_COMMANDS.STATUS_ON; break;
					case "STATUS_OFF": command = X10_COMMANDS.STATUS_OFF; break;
					case "STATUS": command = X10_COMMANDS.STATUS_REQUEST; break;
					default: throw new Exception("Unknown x10 command received: " + scmd);
				}

                string alldevices = e.XplMsg.GetKeyValue("device");
				if (alldevices.Length<2)
					throw new Exception("Invalid device(s): " + alldevices);

				string[] ardev = alldevices.ToUpper().Split(',');
				int i=0;

				//verify device addresses
				while (i<ardev.Length)
				{
					if (ardev[i].Length<2 || ardev[i].Length>3)
						throw new Exception("Invalid device: " + ardev[i]);

					if (Convert.ToChar(ardev[i].Substring(0,1))<'A' || Convert.ToChar(ardev[i].Substring(0,1))>'P')
						throw new Exception("Housecode out of range: " + ardev[i]);

					try
					{
						int devicenr = Int32.Parse(ardev[i].Substring(1));
						if (devicenr<1 || devicenr>16)
							throw new Exception();
					}
					catch
					{
						throw new Exception("Devicecode out of range: " + ardev[i]);
					}
					i++;
				}

				//verify other attributes if applicable
				byte level = 0;
				byte data1 = 0;
				byte data2 = 0;
				if (command == X10_COMMANDS.BRIGHT || command == X10_COMMANDS.DIM || command == X10_COMMANDS.PRESET_DIM1 || command == X10_COMMANDS.PRESET_DIM2)
					try
					{
                        level = Byte.Parse(e.XplMsg.GetKeyValue("level"));
						if (level<0 || level>100)
							throw new Exception();
					}
					catch
					{
                        throw new Exception("Level out of range: " + e.XplMsg.GetKeyValue("level"));
					}

				if (command == X10_COMMANDS.EXTENDED)
					try
					{
                        data1 = Byte.Parse(e.XplMsg.GetKeyValue("data1"));
                        data2 = Byte.Parse(e.XplMsg.GetKeyValue("data2"));
						if (data1<0 || data1>255 || data2<0 || data2>255)
							throw new Exception();
					}
					catch
					{
                        throw new Exception("Extended data out of range: data1=" + e.XplMsg.GetKeyValue("data1") + " data2=" + e.XplMsg.GetKeyValue("data2"));
					}

				i=0;
				while (i<ardev.Length)
				{
					//group devices of the same housecode
					string devices = ardev[i];
					int j = i + 1;
					while (j<ardev.Length && ardev[j].Substring(0,1)==devices.Substring(0,1))
					{
						devices += "," + ardev[j].Substring(1);
						j++;
					}
					i=j;

					if (command == X10_COMMANDS.BRIGHT || command == X10_COMMANDS.DIM || command == X10_COMMANDS.PRESET_DIM1 || command == X10_COMMANDS.PRESET_DIM2)
						x10.AsyncSendX10(devices, (byte) command, level);
					else if (command == X10_COMMANDS.EXTENDED)
						x10.AsyncSendX10(devices, (byte) command, data1, data2);
					else
						x10.AsyncSendX10(devices, (byte) command);
				}
			}
			catch (Exception Ex)
			{
				EventLog.WriteEntry("Error parsing xpl command: " + Ex.Message, EventLogEntryType.Error);
			}
		}
	}
}
