/*
'* xPL CM11
'*
'* Written by Tom Van den Panhuyzen
'* Version 1.00 - 5/feb/2005
'* Version 1.01 - 20/mar/2005  (modified timeout settings)
'* Version 1.02 - 02/oct/2005  (recompiled with xpllib V4.1)
'* Version 1.03 - 16/dec/2005  (PREDIM1/2 now use the level attribute)
'* Version 1.04 - 11/feb/2007  (no more timeout when sending commands to the CM11 while a message arrives at powerline)
'*
'* For more information on the serial communications library (CommBase), see:
'* "Serial Comm: Use P/Invoke to Develop a .NET Base Class Library
'* for Serial Device Communications" John Hind, MSDN Magazine, Oct 2002
'*
'*/

/*
 Copyright 2007 Tom Van den Panhuyzen
 
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
using System.Diagnostics;
using System.Threading;
using System.IO;
using JH.CommBase;

namespace Medusa.XPLCM11
{
	#region event definitions

	/// <summary>
	/// Summary description for X10Comm.
	/// </summary>
	public delegate void SendX10ResultEventHandler(object sender, X10EventArgs e);
	public delegate void ReceivedX10EventHandler(object sender, X10EventArgs e);

	public class X10EventArgs:EventArgs
	{
		private readonly string mDevices;
		private readonly byte mX10Command;
		private readonly byte mBrightness;
		private readonly byte mData1;
		private readonly byte mData2;
		private readonly int mResultCode;

		public X10EventArgs(string Devices, byte X10Command, byte Brightness, byte data1, byte data2):this(Devices,X10Command,Brightness,data1,data2,0) { }

		public X10EventArgs(string Devices, byte X10Command, byte Brightness, byte data1, byte data2, int ResultCode)
		{
			mDevices = Devices;
			mX10Command = X10Command;
			mBrightness = Brightness;
			mData1 = data1;
			mData2 = data2;
			mResultCode = ResultCode;
		}

		public string Devices { get { return mDevices; }}
		public byte X10Command { get { return mX10Command; }}
		public byte Brightness { get { return mBrightness; }}
		public byte Data1 { get { return mData1; }}
		public byte Data2 { get { return mData2; }}
		public int ResultCode { get { return mResultCode; }}
	}
	#endregion


	public sealed class X10Comm:IDisposable
	{
		
		public event SendX10ResultEventHandler SendX10Result;
		public event ReceivedX10EventHandler ReceivedX10;

#if DEBUG
		private static BooleanSwitch timingPerformance;
		private static BooleanSwitch traceX10Comm;
#endif

		private static ArrayList arX10ToSend;
		private static EventLog mEventLog;

		#region internal representation of an X10 message

		private class X10Message
		{
			private string mDevices0;
			private char mHouseCode;
			private byte[] mDevices;
			private byte mX10Command;
			private byte mBrightness;
			private byte mBrightness100;
			private byte mData1;
			private byte mData2;
			private int mInRetryCount;
			private bool mInCollision;

			private byte[] codes = {6,14,2,10,1,9,5,13,7,15,3,11,0,8,4,12};

			public X10Message(string Devices, byte X10Command):this(Devices,X10Command,0,0,0)
			{ }

			public X10Message(string Devices, byte X10Command, byte Brightness):this(Devices,X10Command,Brightness,0,0)
			{ }

			public X10Message(string Devices, byte X10Command, byte Brightness, byte data1, byte data2)
			{
				mDevices0 = Devices;
				mHouseCode = Convert.ToChar(Devices.Substring(0,1).ToUpper());

				string[] tmp = Devices.Substring(1).ToUpper().Split(',');
				mDevices = new byte[tmp.Length];
				for (int i=0; i<tmp.Length; i++)
					mDevices[i] = Convert.ToByte(tmp[i]);

				mX10Command = X10Command;
				mBrightness = (byte) Math.Floor((int)Brightness * 0.22);
				mBrightness100 = Brightness;
				mData1 = data1;
				mData2 = data2;
				mInRetryCount = 0;
				mInCollision = false;
			}

			public char HouseCode { get { return mHouseCode; }}
			public string Devices0 { get { return mDevices0; }}
			public byte[] Devices { get { return mDevices; }}
			public byte X10Command { get { return mX10Command; }}
			public byte Brightness { get { return mBrightness; }}
			public byte Brightness100 {get { return mBrightness100; }}
			public byte Data1 { get { return mData1; }}
			public byte Data2 { get { return mData2; }}
			public bool IsExtended() { return (mX10Command == 7);}
			public int InRetryCount { get { return mInRetryCount; } set { mInRetryCount = value; }}
			public bool InCollision { get { return mInCollision; } set { mInCollision = value; }}
			public byte Code2Byte(byte Code) { return codes[Code-1]; }
			public byte Code2Byte(char Code) { return codes[((byte) Code) - 65]; }
			public override string ToString() { return "Devices:" + mDevices0 + " Command:" + X10Command.ToString()+ " Brightness (scale 22):" + mBrightness.ToString() + " Data1:" +  Data1.ToString() + " Data2:" + Data2.ToString(); }
		}
		#endregion

		private static volatile X10Comm instance;

		private static object syncRoot = new object();
		private static object syncIncoming = new object();
		private static object syncEventOut = new object();
		private static object syncReceiveState = new object();
		private static object syncEventLog = new object();

		private static bool InReceiveMode = false;
		private static bool InSendMode = false;

		private static int theCheckSum;
		private static bool mRunning = false;

		//the actual communication with the serial port happens in class CM11
		private static CM11 cm11;
		private static int mComPort = 1;

		private static ManualResetEvent evtDoneReceiving = new ManualResetEvent(true);
		private static AutoResetEvent evtChecksumReceived = new AutoResetEvent(false);
		private static AutoResetEvent evtIFReadyReceived = new AutoResetEvent(false);

		private const int TIME_WAIT_CHECKSUM = 1000;  //was 2000
		private const int TIME_WAIT_IFREADY = 5000;  //was 2000
		private const int TIME_COLLISION_TIMEOUT = 0; //was 3500
		private const int TIME_ERROR_TIMEOUT = 4500;
		private const int NR_MAX_CHECKSUM_CHECKS = 3;
		private const int NR_MAX_COMMAND_RETRIES = 5;
		private static bool collisionFlag = false;

		private enum ComResult {OK, TimeOut, TooManyRetries, Collision}

		private enum ReceiveStatus { Idle, Checksum, InterfaceReady, Buffer }
		private static ReceiveStatus receiveStatus = ReceiveStatus.Idle;


		#region constructor, dispose
		private X10Comm()
		{
#if DEBUG
			//trace timings to a logfile
			timingPerformance = new BooleanSwitch("X10Timings","Turn timings on or off.");
			traceX10Comm = new BooleanSwitch("X10Comm","Turn X10 communication tracing on or off.");
			FileStream txtTraceLog = new FileStream(Environment.CurrentDirectory + @"\X10TimerTraceLog.txt", FileMode.OpenOrCreate);
			TextWriterTraceListener traceListener = new TextWriterTraceListener(txtTraceLog);
			Trace.Listeners.Clear();
			Trace.Listeners.Add(traceListener);
			Trace.AutoFlush = true;

			//test the tracelog
			if (timingPerformance.Enabled)
				Trace.WriteLine(DateTime.Now.ToString() + ": Time tracing is ON");
			else
				Trace.WriteLine(DateTime.Now.ToString() + ": Time tracing is OFF");

			if (traceX10Comm.Enabled)
				Trace.WriteLine(DateTime.Now.ToString() + ": Comm tracing is ON");
			else
				Trace.WriteLine(DateTime.Now.ToString() + ": Comm tracing is OFF");

#endif

			//X10 commands that are to be sent to the CM11 are stored in an ArrayList
			arX10ToSend = new ArrayList(10);

			//CM11 talks to the serial port
			cm11 = new CM11();
		}

		/// <summary>
		/// Use this property to get an instance of the X10Comm class.  This to ensure only one exists at the same time.
		/// </summary>
		public static X10Comm Instance
		{
			get
			{
				if (instance == null)
				{
					lock (syncRoot)
					{
						if (instance == null)
							instance = new X10Comm();
					}
				}
				return instance;
			}
		}

		public void Dispose()
		{
			try
			{
				lock(arX10ToSend.SyncRoot)
					arX10ToSend.Clear();
				cm11.Close();
			}
			catch { }
			cm11.Dispose();
		}
		#endregion

		public int ComPort { get { return mComPort; } set { mComPort = value; }}
		public EventLog Eventlog { set { mEventLog = value; }}

		public bool Open()
		{	
			bool ok = cm11.Open();
			Thread.Sleep(1500);
			return (ok || cm11.Online);
		}

		public void AsyncSendX10(string Devices, byte X10Command)		
		{
			AsyncSendX10(Devices, X10Command, 0, 0, 0);
		}

		public void AsyncSendX10(string Devices, byte X10Command, byte Brightness)		
		{
			AsyncSendX10(Devices, X10Command, Brightness, 0, 0);
		}

		public void AsyncSendX10(string Devices, byte X10Command, byte data1, byte data2)		
		{
			AsyncSendX10(Devices, X10Command, 0, data1, data2);
		}

		private void AsyncSendX10(string Devices, byte X10Command, byte Brightness, byte data1, byte data2)		
		{
			X10Message x10c = new X10Message(Devices, X10Command, Brightness, data1, data2);
			lock(arX10ToSend.SyncRoot)
			{
				arX10ToSend.Add(x10c);
			}
			RunSendX10();
		}

		private void RunSendX10()
		{
			bool alreadyRunning = false;
			lock(syncIncoming)  //just in case multiple threads would call into here
			{
				alreadyRunning = mRunning;
				mRunning = true;
			}
			
			if (alreadyRunning) return;

			ThreadStart tsDelegate = new ThreadStart(SendX10);
			Thread newThread = new Thread(tsDelegate);
			newThread.Name = "SendX10";
			newThread.Start();
		}

		#region Sending Thread

		private void SendX10()
		{
			X10Message x10m;
			bool mustWait;
			byte[] standard = new byte[2];
			byte[] extended = new byte[5];
			ComResult r = ComResult.OK;
#if DEBUG
			long ticks=0;
#endif

			while (true)
			{
				//get the first element
				lock(arX10ToSend.SyncRoot)
				{
					if (arX10ToSend.Count==0) break;
					
					x10m = (X10Message) arX10ToSend[0];
				}

				//give the CM11 a chance to send something if a collision was detected
				if (x10m.InCollision)
					Thread.Sleep(TIME_COLLISION_TIMEOUT);
					//or an error happened (probably a collision during waiting for checksum)
				else if (x10m.InRetryCount>0)
					Thread.Sleep(TIME_ERROR_TIMEOUT);

				//send msg to com port
				mustWait = true;
				while (mustWait)
				{
					//wait for receiving thread if it is receiving things
					evtDoneReceiving.WaitOne();
				
					mustWait = false;
					lock(syncReceiveState)
						if (InReceiveMode)
							mustWait = true;
						else
							InSendMode = true;

					if (!mustWait)
					{
						bool err = false;
						string errtxt = string.Empty;
						try
						{
#if DEBUG
							if (timingPerformance.Enabled)
								ticks = DateTime.Now.Ticks;
#endif
							//first send the addresses
							for(int i=0; i<x10m.Devices.Length; i++)
							{
								standard[0] = 4;
								standard[1] = (byte)((byte) (x10m.Code2Byte(x10m.HouseCode) << 4) | (x10m.Code2Byte(x10m.Devices[i])));

								//send address & wait for checksum & check it
								r = SendBytes(standard);

								if (r == ComResult.TooManyRetries)
									throw new Exception("Too many wrong checksums received after sending address " + x10m.HouseCode + x10m.Devices[i].ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());
								else if (r == ComResult.TimeOut)
									throw new Exception("Timeout waiting for checksum during sending of address " + x10m.HouseCode + x10m.Devices[i].ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());

#if DEBUG
								if (timingPerformance.Enabled)
								{
									Trace.WriteLine("Address " + i.ToString() + " sent in (ms): " + ((DateTime.Now.Ticks - ticks)/10000).ToString());
									ticks = DateTime.Now.Ticks;
								}
#endif

								//send ok & wait
								r = SendOKByte();
								if (r == ComResult.TimeOut)
									throw new Exception("Timeout waiting for interface ready byte during sending of address " + x10m.HouseCode + x10m.Devices[i].ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());
								else if (r == ComResult.Collision)
									throw new Exception("Collision during sending of address " + x10m.HouseCode + x10m.Devices[i].ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());

#if DEBUG
								if (timingPerformance.Enabled)
								{
									Trace.WriteLine("OK byte (after address) sent in (ms): " + ((DateTime.Now.Ticks - ticks)/10000).ToString());
									ticks = DateTime.Now.Ticks;
								}
#endif

							}


							if (x10m.X10Command == 7) //extended
							{
								extended[0] = 7;
								extended[1] = (byte) ((byte) (x10m.Code2Byte(x10m.HouseCode) << 4) | 7);
								extended[2] = x10m.Code2Byte(x10m.Devices[0]);  //??? which unit to use ?
								extended[3] = x10m.Data1;
								extended[4] = x10m.Data2;
								r = SendBytes(extended);

							}
							else  //standard function
							{
								standard[0] = (byte)((byte) (x10m.Brightness << 3) | (byte) 4 | (byte) 2);
								standard[1] = (byte)((byte) (x10m.Code2Byte(x10m.HouseCode) << 4) | x10m.X10Command);

								//send function & wait for checksum & check it
								r = SendBytes(standard);
							}

							if (r == ComResult.TooManyRetries)
								throw new Exception("Too many wrong checksums received after sending function. Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());
							else if (r == ComResult.TimeOut)
								throw new Exception("Timeout waiting for checksum during sending of function " + x10m.X10Command.ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());

#if DEBUG
							if (timingPerformance.Enabled)
							{
								Trace.WriteLine("Function sent in (ms): " + ((DateTime.Now.Ticks - ticks)/10000).ToString());
								ticks = DateTime.Now.Ticks;
							}
#endif

							//send ok & wait
							r = SendOKByte();
							if (r == ComResult.TimeOut)
								throw new Exception("Timeout waiting for interface ready byte during sending of function " + x10m.X10Command.ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());
							else if (r == ComResult.Collision)
								throw new Exception("Collision during sending of function " + x10m.X10Command.ToString() + ". Complete X10 command was: " + x10m.ToString() + " Retries:" + x10m.InRetryCount.ToString());

#if DEBUG
							if (timingPerformance.Enabled)
							{
								Trace.WriteLine("OK byte (after function) sent in (ms): " + ((DateTime.Now.Ticks - ticks)/10000).ToString());
								ticks = DateTime.Now.Ticks;
							}
#endif
						}
						catch(Exception Ex)
						{
							err = true;
							errtxt = Ex.Message + " [" + Ex.Source + "]";
#if DEBUG
							if (timingPerformance.Enabled || traceX10Comm.Enabled)
							{
								Trace.WriteLine(errtxt);
								Trace.WriteLine("Error: " + ((DateTime.Now.Ticks - ticks)/10000).ToString());
							}

#endif
						}

						//done
						lock(syncReceiveState)
							InSendMode = false;

						//if it was not ok and it was not a collision then increment retry-counter
						if (err)
							if (r != ComResult.Collision)
							{
								x10m.InRetryCount += 1;
								x10m.InCollision = false;
							}
							else
								x10m.InCollision = true;
								
					
						//remove from list and raise event if too many retries or if no error
						if (!err)
						{
							RaiseSendX10Result(new X10EventArgs(x10m.Devices0, x10m.X10Command, x10m.Brightness100, x10m.Data1, x10m.Data2, 0));
							try
							{
								lock(arX10ToSend.SyncRoot)
									arX10ToSend.RemoveAt(0);  //fails if we are being disposed (that's ok)
							}
							catch { }
						}
						else if (x10m.InRetryCount>NR_MAX_COMMAND_RETRIES)
						{
							RaiseSendX10Result(new X10EventArgs(x10m.Devices0, x10m.X10Command, x10m.Brightness100, x10m.Data1, x10m.Data2, 1));
							LogError(errtxt);
							lock(arX10ToSend.SyncRoot)
								arX10ToSend.RemoveAt(0);
						}

					}
				}
			}

			lock(syncIncoming)
				mRunning = false;
		}


		private ComResult SendBytes(byte[] bytes)
		{
			int mychecksum;
			bool timeout = false;

			//send bytes & wait for checksum & check it
			bool checkOK = false;
			int checks = 0;
			theCheckSum = 0;  //reset the checksum (updated by receiving thread)
			while (!checkOK && checks<NR_MAX_CHECKSUM_CHECKS && !timeout)
			{
				//Console.WriteLine("Send2Bytes(" + byte1.ToString("X") + "," + byte2.ToString("X") + ")");
				mychecksum = 0;
				receiveStatus = ReceiveStatus.Checksum;
				for (int i=0; i<bytes.Length; i++)
				{
					cm11.SendByte(bytes[i]);
					mychecksum += bytes[i];
				}
				mychecksum = mychecksum & 255;

				if (evtChecksumReceived.WaitOne(TIME_WAIT_CHECKSUM, true))
				{
					if (mychecksum == theCheckSum)
						checkOK = true;
					else
						checks++;
				}
				else
					timeout = true;
			}

			ComResult r;
			if (timeout)
				r=ComResult.TimeOut;
			else if(!checkOK)
				r=ComResult.TooManyRetries;
			else
				r=ComResult.OK;

			return r;
		}

		private ComResult SendOKByte()
		{
			bool timeout = false;

			//send byte 0 & wait
			receiveStatus = ReceiveStatus.InterfaceReady;
			cm11.SendByte(0);

			if (!evtIFReadyReceived.WaitOne(TIME_WAIT_IFREADY, true))
				timeout = true;

			//collisions (CM11 starts upload of buffer) may happen when waiting for InterfaceReady
			if (collisionFlag)
			{
				collisionFlag = false;
				return ComResult.Collision;
			}

			return (timeout?ComResult.TimeOut:ComResult.OK);
		}

		private void RaiseSendX10Result(X10EventArgs e)
		{
			//do not confuse our consumer by calling out to it using multiple threads at the same time
			lock(syncEventOut)
				if (SendX10Result != null)
					try
					{
						SendX10Result(this, e);
					}
					catch { }
		}

		#endregion

		#region CommBase (Receiving Thread)

		private class CM11:CommBase
		{
			protected override CommBaseSettings CommSettings()
			{
				CommBaseSettings cb = new CommBaseSettings();
				cb.SetStandard("COM" + mComPort.ToString() + ":", 4800, CommBase.Handshake.none);
				//cb.checkAllSends = true;
			
				return cb;
			}

			public void SendByte(byte b)
			{

#if DEBUG
				if (traceX10Comm.Enabled)
					Trace.WriteLine(DateTime.Now.ToString("hh:mm:ss.ffff") + " SendByte(" + b.ToString("X") + ")");
#endif

				Send(b);
			}

			static byte[] buffer = new byte[10];
			static int bufsize = 0;
			static int bufcurrent = 0;

			protected override void OnRxChar(byte ch)
			{
				lock(syncReceiveState)
					if (!InSendMode)  //received something outside a send -> CM11 takes initiative
					{
						evtDoneReceiving.Reset();  //stop the sending thread loop
						InReceiveMode = true;
					}

#if DEBUG
				if (traceX10Comm.Enabled)
					Trace.WriteLine(DateTime.Now.ToString("hh:mm:ss.ffff") + " OnRxChar(" + ch.ToString("X") + ") InSendMode=" + InSendMode.ToString() + ", InReceiveMode=" + InReceiveMode.ToString() + ", receiveStatus=" + receiveStatus.ToString());
#endif

				/* if InSendMode then we are waiting for a Checksum or an Interface Ready */
				/* if InReceiveMode then we are not waiting for anything or filling the buffer */

				/* experiments have shown that the CM11 may interrupt a send and start uploading a buffer at any time */
				/* so even if it should send 0x55 (Interface Ready) because we sent it an address, it may still send */
				/* 0x5a (poll buffer) hence interrupting the sending of the command */
				/* let's hope it doesn't try a poll buffer when it should send a checksum (how to differentiate between */
				/* checksum 0x5a and poll buffer 0x5a otherwise ?) */

				switch(receiveStatus)
				{
					case ReceiveStatus.Idle:
						if (ch == 165) //request to set the clock  (should only happen during startup)
						{
							SendByte(155); //send first byte of timer header
							Thread.Sleep(10); //wait a fraction of time
						}
						else if (ch == 90)  //buffer ready to be sent
						{
							SendByte(195);  //say it's ok to send
							bufsize = 0;
							receiveStatus = ReceiveStatus.Buffer;
						}
						else  //hmmm...?
							LogError("Funny character received from CM11: 0x" + ch.ToString("X"));
						break;

					case ReceiveStatus.Checksum:
						theCheckSum = ch;
						receiveStatus = ReceiveStatus.Idle;
						//release the waiting thread
						evtChecksumReceived.Set();
						break;

					case ReceiveStatus.InterfaceReady:
						if (ch == 85)  //ok
						{
							receiveStatus = ReceiveStatus.Idle;
							//release the waiting thread
							evtIFReadyReceived.Set();
						}
						else if (ch == 90)  //buffer ready to be sent
						{
							/* switch to receive mode */
							/* the sending thread will timeout and retry the command */
							lock(syncReceiveState)
							{
								collisionFlag = true;  //this flag will be tested in the other thread to check a possible collision
								evtDoneReceiving.Reset();  //stop the sending thread loop
								InReceiveMode = true;
								evtIFReadyReceived.Set();  //continue thread that waits for IF (collisionFlag = true -> no timeout but exception treated)
							}
							bufsize = 0;
							receiveStatus = ReceiveStatus.Buffer;
							SendByte(195);  //say it's ok to send
						}
						else
							LogError("Funny character received from CM11 instead of 0x55: 0x" + ch.ToString("X"));
						break;

					case ReceiveStatus.Buffer:
						if (bufsize == 0)  //nothing received yet
							if (ch>10 && ch!=90)
							{
								LogError("CM11 reports a buffer >10! It reports: " + ch.ToString());
								receiveStatus = ReceiveStatus.Idle;
							}
							else if (ch == 90)  //buffer ready to be sent, interface gets impatient...
							{
								SendByte(195);  //say it's ok to send, again
							}
							else
							{
								bufsize = ch;
								bufcurrent = 0;
							}
						else
						{
							buffer[bufcurrent] = ch;
							bufcurrent++;
							if (bufcurrent==bufsize)
							{
								TreatBuffer();
								receiveStatus = ReceiveStatus.Idle;
							}
							
						}
						break;
				}

				lock(syncReceiveState)
					if (InReceiveMode)
					{
						if (receiveStatus != ReceiveStatus.Buffer)
						{
							InReceiveMode = false;
							evtDoneReceiving.Set();  //tell the sending thread it can continue
						}
					}

			}

			private int[] reversecodes = {13,5,3,11,15,7,1,9,14,6,4,12,16,8,2,10};
			
			//if the buffer provides a function -> generate an event, otherwise wait for next buffer
			private bool havefunc = false;
			private byte func;
			private char house;
			private string addresses = string.Empty;
			private byte bright = 0;
			private byte d1 = 0;
			private byte d2 = 0;

			private void TreatBuffer()
			{
				for (int i=1; i<bufsize; i++)
				{
					if (((buffer[0]>>(i-1)) & 1)==1)  //function
					{
						havefunc = true;
						func = (byte) (buffer[i] & 15);
						house = (char) (reversecodes[(buffer[i] & 240) >> 4] + 64);

						if (func == 4 || func == 5)  //dim or bright  -> next is brightness
						{
							i++;
							bright = (byte) (buffer[i]/2.1);
						}
					}
					else
						addresses += reversecodes[(buffer[i] & 15)].ToString() + ",";

					//enough info to raise an event ?
					if (havefunc)
					{
						instance.RaiseReceivedX10(new X10EventArgs(house.ToString() + addresses.TrimEnd(new char[] {','}), func, bright, d1, d2));
						//reset values
						havefunc = false;
						addresses = string.Empty;
						bright = 0;
					}
				}
			}
		}

		private void RaiseReceivedX10(X10EventArgs e)
		{
			//do not confuse our consumer by calling out to it using multiple threads at the same time
			lock(syncEventOut)
				if (ReceivedX10 != null)
					try
					{
						ReceivedX10(this, e);
					}
					catch { }
		}

		#endregion CommBase

		private static void LogError(string message)
		{
			lock(syncEventLog)
			{
				if (mEventLog != null)
					mEventLog.WriteEntry(message,EventLogEntryType.Error);
			}
			Console.WriteLine(message);
		}
	}
}