
using System.Net.Sockets;
using System.Net;
using System.Text;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Runtime.InteropServices;
using xPLHalScriptHelper;

public class Sys : IHalObjects, IDisposable {
    /// <exclude/>
    public static class globals {
        public static int MinMajor;
        public static int MinBuild;
        public static int MinMinor;
        public static int ServerMajorVersion;
        public static bool ServerOutOfDate;
        public static string XplHalSource = "vendor-device.instance";
        internal static string Unexpected(string line) {
            return "Got unexpected results: " + line;
        }
    }

    protected Socket s;
    protected string WelcomeBanner;

    string SETTINGS_XPLHALSERVER = "localhost";     //default to localhost, but set when a client connects
    string LastErrorCode;

    /// <summary>
    /// </summary>
    /// <param name="HalIPAddress"></param>
    /// <exclude/>
    public Sys(IPAddress HalIPAddress) {
        SETTINGS_XPLHALSERVER = HalIPAddress.ToString();
    }

    #region Socket Comm II
    /// <summary>
    /// </summary>
    /// <returns></returns>
    Socket GetCommSocket() {
        Socket socket = ConnectToXplHal2();
        if (socket != null)
            return socket;
        else
            return null;
    }

    Socket ConnectToXplHal2() {
        try {
            Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            socket.Blocking = true;
            IPAddress[] IPResults = Dns.GetHostEntry(SETTINGS_XPLHALSERVER).AddressList;
            foreach (IPAddress IPresult in IPResults) {
                if ((IPresult.AddressFamily == AddressFamily.InterNetwork)) {
                    socket.Connect(new IPEndPoint(IPresult, 3865));
                    WelcomeBanner = GetLine(socket);
                    WelcomeBanner = WelcomeBanner.Replace("\r\n", "");

                    return socket;
                }
            }
        } catch (Exception ex) {
            throw new Exception("Error connecting to xPLHal server. Please make sure the server is operational and that you have a working network connection to the server.", ex);
        }
        return null;
    }

    /// <summary>
    /// Reads a line from the (open) socket
    /// </summary>
    /// <returns></returns>
    protected string GetLine(Socket socket) {
        byte[] buff = new byte[2048];
        int bytes_read;
        string inbuff = "";
        while (1 == 1) {
            try {
                bytes_read = socket.Receive(buff, SocketFlags.Peek);
                if (bytes_read > 0) {
                    if (Encoding.ASCII.GetString(buff).IndexOf("\r\n") > 0) {
                        bytes_read = socket.Receive(buff, Encoding.ASCII.GetString(buff).IndexOf("\r\n") + 2, SocketFlags.None);
                    } else {
                        bytes_read = socket.Receive(buff, bytes_read, SocketFlags.None);
                    }
                    inbuff = (inbuff + Encoding.ASCII.GetString(buff).Substring(0, bytes_read));
                } else {
                    inbuff = (inbuff + "\r\n");
                }
                if (inbuff.IndexOf("\r\n") >= 0 || inbuff == "" || inbuff.Length > 2048)
                    break;
            } catch (Exception ex) {
                inbuff = "\r\n";
            }
        }
        return inbuff;
    }

    /// <summary>
    /// Send a string to xPLHal
    /// </summary>
    /// <param name="line"></param>
    protected void xplHalSend(Socket socket, string line, bool terminate) {
        if (socket == null) return;

        try {
            if (terminate)
                line += "\r\n";
            socket.Send(Encoding.ASCII.GetBytes(line));
        } catch (Exception ex) {
            throw new Exception("Error sending data to the xPLHal server. Please make sure the server is operational and that you have a working network connection to the server.", ex);
        }
    }

    protected void xplHalSend(Socket socket, string line) {
        xplHalSend(socket, line, true);
    }

    /// <summary>
    /// Disconnect from server and close socket.
    /// </summary>
    protected void Disconnect(Socket socket) {
        if (socket != null) {
            try {
                socket.Send(Encoding.ASCII.GetBytes("quit" + "\r\n"));
                socket.Shutdown(System.Net.Sockets.SocketShutdown.Both);
                socket.Close();
            } catch (Exception ex) { }
        }
    } 
    #endregion

    /// <summary>
    /// Connects to the xPLHal server
    /// </summary>
    /// <returns></returns>
    protected bool ConnectToXplHal() {
        if (!(s == null)) {
            return true;
        }
        try {
            s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            s.Blocking = true;
            IPAddress[] IPResults = Dns.GetHostEntry(SETTINGS_XPLHALSERVER).AddressList;
            foreach (IPAddress IPresult in IPResults) {
                if ((IPresult.AddressFamily == AddressFamily.InterNetwork)) {
                    s.Connect(new IPEndPoint(IPresult, 3865));
                    WelcomeBanner = GetLine();
                    WelcomeBanner = WelcomeBanner.Replace("\r\n", "");
                    return true;
                }
            }

            //We could do this later. Or not.
            //VersionCheck();

            WelcomeBanner = "";
            return false;
        } catch (Exception ex) {
            s = null;
            LastErrorCode = null;
            WelcomeBanner = "";
            throw new Exception("Error connecting to xPLHal server. Please make sure the server is operational and that you have a working network connection to the server.", ex);
        }
    }

    /// <summary>
    /// Reads a line from the (open) socket
    /// </summary>
    /// <returns></returns>
    protected string GetLine() {
        byte[] buff = new byte[2048];
        int bytes_read;
        string inbuff = "";
        while (1 == 1) {
            try {
                bytes_read = s.Receive(buff, SocketFlags.Peek);
                if (bytes_read > 0) {
                    if (Encoding.ASCII.GetString(buff).IndexOf("\r\n") > 0) {
                        bytes_read = s.Receive(buff, Encoding.ASCII.GetString(buff).IndexOf("\r\n") + 2, SocketFlags.None);
                    } else {
                        bytes_read = s.Receive(buff, bytes_read, SocketFlags.None);
                    }
                    inbuff = (inbuff + Encoding.ASCII.GetString(buff).Substring(0, bytes_read));
                } else {
                    inbuff = (inbuff + "\r\n");
                }
                if (inbuff.IndexOf("\r\n") >= 0 || inbuff == "" || inbuff.Length > 2048)
                    break;
            } catch (Exception ex) {
                inbuff = "\r\n";
            }
        }
        return inbuff;
    }

    /// <summary>
    /// Disconnect from server and close socket.
    /// </summary>
    protected void Disconnect() {
        if (!(s == null)) {
            try {
                s.Send(Encoding.ASCII.GetBytes("quit" + "\r\n"));
                s.Shutdown(System.Net.Sockets.SocketShutdown.Both);
                s.Close();
            } catch (Exception ex) { }
            s = null;
        }
    }

    /// <summary>
    /// Send data and always terminate with CRLF
    /// </summary>
    /// <param name="line"></param>
    protected void xplHalSend(string line) {
        xplHalSend(line, true);
    }

    /// <summary>
    /// Send a string to xPLHal
    /// </summary>
    /// <param name="line"></param>
    protected void xplHalSend(string line, bool terminate) {
        if (s == null)
            ConnectToXplHal();

        try {
            if (terminate)
                line += "\r\n";
            s.Send(Encoding.ASCII.GetBytes(line));
        } catch (Exception ex) {
            throw new Exception("Error sending data to the xPLHal server. Please make sure the server is operational and that you have a working network connection to the server.", ex);
        }
    }
    

    /// <summary>
    /// Send a simple command
    /// </summary>
    /// <param name="command"></param>
    /// <param name="parameter"></param>
    /// <param name="ok_codes"></param>
    /// <param name="not_found_codes"></param>
    /// <param name="error_codes"></param>
    /// <returns></returns>
    protected object SendSimpleListCommand(string command, string parameter, string list_follows_code, string not_found_code) {
        string line;
        List<string> list = new List<string>();

        try {
            if (parameter.Length > 0)
                command += " " + parameter;

            xplHalSend(command);
            line = GetLine();
            if (line.StartsWith(list_follows_code)) {
                //get lines...
                while (1 == 1) {
                    line = GetLine();
                    if (line.EndsWith(".\r\n")) {
                        list.Add(line.Remove(line.Length - 3));
                        break;
                    } else
                        list.Add(line.Remove(line.Length - 2));
                }

                return list;
            } else if (line.StartsWith(not_found_code)) {
                LastErrorCode = line;
                return false;
            } else {
                LastErrorCode = line;
                throw new Exception("Unexpected result received from server.");
            }
        } finally {
            Disconnect();
        }

    }

    protected object SendSimpleCommand(string command, string parameter, string ok_code, string not_found_code) {
        return SendSimpleCommand(command, parameter, ok_code, not_found_code, null);
    }

    protected object SendSimpleCommand(string command, string parameter, string ok_code, string not_found_code, string error_codes) {
        string line;
        try {
            if (parameter.Length > 0)
                command += " " + parameter;

            xplHalSend(command);
            line = GetLine();

            if (line.StartsWith(ok_code)) {
                LastErrorCode = null;
                return true;
            }

            if (line.StartsWith(not_found_code)) {
                LastErrorCode = line;
                return false;
            }

            if (line.StartsWith(error_codes)) {
                LastErrorCode = line;
                return false;
            }

            throw new Exception("Unexpected result received from server.");
        } catch (Exception ex) {

        } finally {
            Disconnect();
        }
        return false;
    }

    protected object SendSimpleGetCommand(string command, string parameter, string ok_code, string not_found_code) {
        string line;
        try {
            if (parameter.Length > 0)
                command += " " + parameter;

            xplHalSend(command);
            line = GetLine();

            if (line.StartsWith(ok_code)) {
                LastErrorCode = null;

                line = GetLine();
                return line.Substring(0, line.Length - 2);
            }

            if (line.StartsWith(not_found_code)) {
                LastErrorCode = line;
                return false;
            }

            throw new Exception("Unexpected result received from server.");
        } catch (Exception ex) {

        } finally {
            Disconnect();
        }
        return false;
    }

    //=== XPLHAL XHCP COMMANDS ===//


    //somehow, PS cannot access public structs
    //it can, if one declares it as a public property..
    /// <exclude/>
    public SingleEventInfo SingleEventData;

    /// <exclude/>
    public RecurringEventInfo RecurringEventData;

    /// <summary>
    /// Structure containing the data of a single event.
    /// </summary>
    /// 
    /// <remarks>
    /// You may have some additional information about this class.
    /// </remarks>
    /// <example>See for an example the <see cref="AddSingleEvent">AddSingleEvent</see> method.</example>
    [StructLayout(LayoutKind.Sequential)]
    public struct SingleEventInfo {
        /// <summary>
        /// The date and time of the event.
        /// </summary>
        public DateTime Date;

        /// <summary>
        /// Tag describing the event.
        /// </summary>
        public string Tag;

        /// <summary>
        /// Subroutine name to run.
        /// This must be in the form of [scriptname]$[subroutine]
        /// <c>e.g. Powershell\global$LetTheSubShine</c>
        /// </summary>
        public string SubName;
        
        /// <summary>
        /// Subroutine parameters.
        /// May be omitted. 
        /// Specify multiple values with commas ([,])
        /// </summary>
        public string Parms;

        /// <summary>
        /// The randomness in minutes.
        /// </summary>
        /// <value>A string containing the text "MyProperty String".</value>
        public int Random;
    }

    /// <summary>
    /// Structure containing the data of a recurring event.
    /// </summary>
    /// <example>See for an example the <see cref="AddSingleEvent">AddRecurringEvent</see> method.</example>
    [StructLayout(LayoutKind.Sequential)]
    public struct RecurringEventInfo {
        /// <summary>
        /// The start time of the event.
        /// </summary>
        public DateTime StartTime;

        // <summary>
        /// The end time of the event
        /// </summary>
        public DateTime EndTime;

        /// <summary>
        /// Tag describing the event.
        /// </summary>
        public string Tag;

        /// <summary>
        /// Subroutine name to run.
        /// This must be in the form of [scriptname]$[subroutine]
        /// <c>e.g. Powershell\global$LetTheSubShine</c>
        /// </summary>
        public string SubName;

        /// <summary>
        /// Subroutine parameters.
        /// May be omitted. 
        /// Specify multiple values with commas ([,])
        /// </summary>
        public string Parms;

        /// <summary>
        /// The randomness in minutes.
        /// </summary>
        /// <value>A string containing the text "MyProperty String".</value>
        public int Random;

        /// <summary>
        /// The days it must run. Sunday is the first position in the string.
        /// </summary>
        public string DOW;

        /// <summary>
        /// The interval.
        /// </summary>
        public int Interval;
    }

    /// <summary>
    /// Structure containing information about an individual device
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct XPLDeviceConfig {
        /// <summary>
        /// The config item name, e.g. interval, filter, group.
        /// </summary>
        public string Name;

        /// <summary>
        /// The type of item, e.g. config, reconf, option.
        /// </summary>
        public string Type;

        /// <summary>
        /// The number of values that can be stored, e.g. many devices support multiple groups and/or filters.
        /// </summary>
        public int Number;
    }

    ///// <summary>
    ///// Structure containing a settings record for xPLHal.
    ///// </summary>
    //[StructLayout(LayoutKind.Sequential)]
    //public struct XplHalSetting {
    //    public string Value;
    //    public string Name;
    //    public string Description;
    //}

    /// <summary>
    /// Structure for a generic event.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct XplEvent {
        /// <summary>
        /// Tag describing the event.
        /// </summary>
        public string Tag;

        /// <summary>
        /// Subroutine name to run.
        /// This must be in the form of [scriptname]$[subroutine]
        /// <c>e.g. Powershell\global$LetTheSubShine</c>
        /// </summary>
        public string SubName;

        /// <summary>
        /// Subroutine parameters.
        /// May be omitted. 
        /// Specify multiple values with commas ([,])</summary>
        public string Parms;
        //public DateTime StartTime;
        //public DateTime EndTime;

        /// <summary>
        /// The start time of the event.
        /// </summary>
        public string StartTime;

        /// <summary>
        /// The end time of the event.
        /// </summary>
        public string EndTime;

        /// <summary>
        /// The days it must run. Sunday is the first position in the string.
        /// </summary>
        public string DOW;

        /// <summary>
        /// Next upcoming run date and time.
        /// </summary>
        public string RunTime;
    }


    //[StructLayout(LayoutKind.Sequential)]
    //public struct XplSetting {
    //    public string SubID;
    //    public string Name;
    //    public string Desc;
    //    public string CurrentValue;
    //    public string CurrentValueDesc;
    //}


    /// <summary>
    /// Structure containing information about a single event.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct XplSingleEvent {
        /// <summary>
        /// Tag describing the event.
        /// </summary>
        public string Tag;

        /// <summary>
        /// Subroutine name to run.
        /// This must be in the form of [scriptname]$[subroutine]
        /// <c>e.g. Powershell\global$LetTheSubShine</c>
        /// </summary>
        public string SubName;

        /// <summary>
        /// Subroutine parameters.
        /// May be omitted. 
        /// Specify multiple values with commas ([,])
        /// </summary>
        public string Parms;

        /// <summary>
        /// The date and time this event should run.
        /// </summary>
        public DateTime Date;
    }


    /// <summary>
    /// Structure containing information an xPLHal device.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct XPLDevice {
        /// <summary>
        /// Virtual Device Identification. The device name, in short, in the form vendor-device.instance
        /// </summary>
        public string Vdi;

        /// <summary>
        /// Expiration time
        /// </summary>
        public string Expires;

        /// <summary>
        /// The heartbeat interval
        /// </summary>
        public string Interval;

        /// <summary>
        /// Indicates whether the item is configurable.
        /// </summary>
        public bool Configtype;

        /// <summary>
        /// Indicates whether the device is fully configured or not.
        /// </summary>
        public bool Configdone;

        /// <summary>
        /// Indicates whether the device is waiting for configuration.
        /// </summary>
        public bool Waitingconfig;

        /// <summary>
        /// Indicates whether the device is suspended.
        /// </summary>
        public bool Suspended;
    }

    /// <summary>
    /// Structure containing information about a single rulegroup.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct RuleGroup {
        /// <summary>
        /// The unique Group Guid.
        /// </summary>
        public string GroupGuid;

        /// <summary>
        /// The more readble name of the group.
        /// </summary>
        public string GroupName;
    }

    /// <summary>
    /// Structure containing information about a single rule.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct Rule {
        /// <summary>
        /// The unique Rule Guid.
        /// </summary>
        public string RuleGuid;

        /// <summary>
        /// The more readble name of the rule.
        /// </summary>
        public string RuleName;

        /// <summary>
        /// Indicates whether the rule is enabled.
        /// </summary>
        public bool Enabled;
    }

    /// <summary>
    /// Structure containing information about a single subroutine.
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct SubRoutine {
        /// <summary>
        /// The name of the script.
        /// </summary>
        public string ScriptName;

        /// <summary>
        /// The name of the subroutine in the script file.
        /// </summary>
        public string FunctionName;

        /// <summary>
        /// The optional parameters of the subroutine.
        /// </summary>
        public string Parameters;
    }


    /// <summary>
    /// Add a single event to xPLHal.
    /// </summary>
    /// <param name="eventdata">A <see cref="SingleEventInfo">SingleEventInfo</see> structure containing the data.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## AddSingleEvent
    /// ## Create a single event
    /// 
    /// $eventdata = New-Object $Sys.SingleEventData
    /// $eventdata.Tag = "Test Single Event"
    /// $eventdata.SubName = "global$TurnOnKitchenLight"
    /// $eventdata.Parms = ""
    /// $eventdata.Date = [datetime]::Parse("2010/02/01 10:00:00")
    /// $eventdata.Random = 0
    /// if ($Sys.AddSingleEvent($eventdata) -eq $false) {
    ///    Write-Output "Failed adding event. Check the logs."
    /// } else {
    ///    Write-Output "Event successfully added."
    /// }
    /// </code>
    /// </example>
    public bool AddSingleEvent(SingleEventInfo eventdata) {
        string line;

        try {
            xplHalSend("ADDSINGLEEVENT");
            line = GetLine();
            if (line.StartsWith("319")) {
                xplHalSend("tag=" + eventdata.Tag);
                xplHalSend("subname=" + eventdata.SubName);
                xplHalSend("parms=" + eventdata.Parms);
                xplHalSend("date=" + eventdata.Date.ToString("dd/MM/yyyy HH:mm:ss"));
                xplHalSend("rand=" + eventdata.Random.ToString());
            } else {
                return false;
            }

            xplHalSend(".");
            line = GetLine();
            if (line.StartsWith("219")) {
                return true;
            } else {
                return false;
            }
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Add a recurring event to xPLHal.
    /// </summary>
    /// <param name="eventdata">A <see cref="SingleEventInfo">RecurringEventInfo</see> structure containing the data.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## AddRecurringEvent
    /// ## Create a recurring event
    /// 
    /// $eventdata = New-Object $Sys.RecurringEventData
    /// $eventdata.Tag = "Recurring Test Event"
    /// $eventdata.SubName = "global$TurnOnKitchenLight"
    /// $eventdata.Parms = ""
    /// $eventdata.StartTime = [datetime]::Parse("10:00:00")
    /// $eventdata.EndTime = [datetime]::Parse("12:00:00")
    /// $eventdata.Random = 0
    /// $eventdata.DOW = "1111111"
    /// $eventdata.Interval = 0
    /// if ($Sys.AddRecurringEvent($eventdata) -eq $false) {
    /// 	Write-Output "Failed adding event. Check the logs."
    /// } else {
    /// 	Write-Output "Event successfully added."
    /// }
    /// </code>
    /// </example>
    public bool AddRecurringEvent(RecurringEventInfo eventdata) {
        string line;

        try {
            xplHalSend("ADDEVENT");
            line = GetLine();
            if (line.StartsWith("319")) {
                xplHalSend("tag=" + eventdata.Tag);
                xplHalSend("subname=" + eventdata.SubName);
                xplHalSend("parms=" + eventdata.Parms);
                xplHalSend("starttime=" + eventdata.StartTime.ToString("HH:mm:ss"));
                xplHalSend("endtime=" + eventdata.EndTime.ToString("HH:mm:ss"));
                xplHalSend("interval=" + eventdata.Interval.ToString());
                xplHalSend("rand=" + eventdata.Random.ToString());
                xplHalSend("dow=" + eventdata.DOW);
            } else {
                return false;
            }

            xplHalSend(".");
            line = GetLine();
            if (line.StartsWith("219")) {
                return true;
            } else {
                return false;
            }
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Clears the XPLHal Error Log.
    /// </summary>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ClearErrorLog
    /// 
    /// if ($Sys.ClearErrorLog() -eq $false) {
    /// 	Write-Output "Clearing of the logfile failed."
    /// } else {
    /// 	Write-Output "Event successfully cleared."
    /// }
    /// </code>
    /// </example>
    public object ClearErrorLog() {
        return SendSimpleCommand("CLEARERRLOG", "", XH225, null, null);
    }

    /// <summary>
    /// Deletes the stored configuration for a specified device. 
    /// </summary>
    /// <param name="vdi">Virtual Device Indentification of the device.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## DeleteDeviceConfig
    /// ## you should not use this command. for now.
    /// ## it is broken in xplHAL2
    /// 
    /// #$Sys.DeleteDeviceConfig(ByVal vdi As String)
    /// </code>
    /// </example>
    public object DeleteDeviceConfig(string vdi) {
        return SendSimpleCommand("DELRULE", vdi, XH235, XH416, null);
    }

    /// <summary>
    /// Deletes an event. 
    /// </summary>
    /// <param name="tag"></param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## DeleteEvent
    /// 
    /// if ($Sys.DeleteEvent("") -eq $false) {
    /// 	Write-Output "Event does not exist."
    /// } else {
    /// 	Write-Output "Event successfully deleted."
    /// }
    /// </code>
    /// </example>
    public object DeleteEvent(string tag) {
        return SendSimpleCommand("DELEVENT", tag, XH223, XH422, null);
    }

    /// <summary>
    /// Deletes a global variable. 
    /// </summary>
    /// <param name="globalname"></param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## DeleteGlobal
    /// 
    /// if ($Sys.DeleteGlobal("some global") -eq $false) {
    /// 	#(this check does actually not work yet due to XHCP specs.)
    /// 	Write-Output "Global value does not exist."
    /// } else {
    /// 	Write-Output "Global value successfully deleted."
    /// }
    /// </code>
    /// </example>
    public object DeleteGlobal(string globalname) {
        return SendSimpleCommand("DELGLOBAL", globalname, XH233, null, null);
    }

    /// <summary>
    /// Deletes the specified determinator. 
    /// </summary>
    /// <param name="ruleguid"></param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## DeleteRule
    /// 
    /// if ($Sys.DeleteRule("d3c1cac16b42424988b090a480952d04") -eq $false) {
    /// 	Write-Output "Rule does not exist."
    /// } else {
    /// 	Write-Output "Rule successfully deleted."
    /// }
    /// </code>
    /// </example>
    public object DeleteRule(string ruleguid) {
        return SendSimpleCommand("DELRULE", ruleguid, XH214, XH410, null);
    }

    /// <summary>
    /// Deletes a script from the xplHal scripting namespace.
    /// </summary>
    /// <param name="scriptname"></param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## DeleteScript
    /// ## Deletes script from DISK. You need to reload manually.
    /// 
    /// if ($Sys.DeleteScript("Powershell\NewScript.ps1") -eq $false) {
    /// 	Write-Output "Script does not exist."
    /// } else {
    /// 	Write-Output "Script successfully deleted."
    /// }
    /// </code>
    /// </example>
    public object DeleteScript(string scriptname) {
        return SendSimpleCommand("DELSCRIPT", scriptname, XH214, XH410, null);
    }

    //
    //GETCONFIGXML => obsolete
    //

    /// <summary>
    /// Retrieves the list of configuration items for a particular device.
    /// </summary>
    /// <param name="vdi">Virtual Device Indentification of the device.</param>
    /// <returns>
    /// <list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If device exists</term>
    /// <description><code>List&lt;<see cref="XPLDeviceConfig">XPLDeviceConfig</see>&gt;</code> of all the configuration items of a device.</description>
    /// </item><item>
    /// <term>If the device does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the device does not exist.</description>
    /// </item></list></returns>    
    /// <example>
    /// <code>
    /// ##
    /// ## GetDeviceConfig
    /// 
    /// $list = $Sys.GetDeviceConfig("nntw-hkardon.genie")
    /// if ($list.GetType().Name -eq "string") {
    /// 	Write-Output "Returns: $list"
    /// } else {
    /// 	Write-Output "Available config items:"
    /// 		foreach ($item in $list) {
    /// 		  Write-Output $item.Name + " (" + $item.Type + ")"
    /// 		}
    /// }
    /// </code>
    /// </example>
    public object GetDeviceConfig(string vdi) {
        string line;
        List<XPLDeviceConfig> devlist = new List<XPLDeviceConfig>();

        try {
            xplHalSend("GETDEVCONFIG " + vdi);
            line = GetLine();

            if (line.StartsWith("217")) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        XPLDeviceConfig x = new XPLDeviceConfig();
                        x.Name = list[0];
                        x.Type = list[1];
                        //xplhal always returns an empty string here...
                        //x.Number = Convert.ToInt16(list[2]);
                        devlist.Add(x);
                    } else
                        break;
                }

                return devlist;
            } else if (line.StartsWith("416")) {
                return "No config available for specified XPL device.";
            } else if (line.StartsWith("417")) {
                return "No such device.";
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Retrieves the value(s) currently in the xPLHal configuration database for a particular config item. 
    /// </summary>
    /// <param name="vdi">Virtual Device Indentification of the device.</param>
    /// <param name="configitem">The specific config item of the device.</param>
    /// <returns></returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetDeviceConfigValue
    /// 
    /// $list = $Sys.GetDeviceConfigValue("nntw-dblogger.genie", "tcpserverport")
    /// Write-Output "value: $list"
    /// </code>
    /// </example>
    public object GetDeviceConfigValue(string vdi, string configitem) {
        return SendSimpleListCommand("GETDEVCONFIGVALUE", vdi + " " + configitem, XH234, null);
    }

    /// <summary>
    /// Returns the XplHal Error Log as a multi-line response. 
    /// </summary>
    /// <returns>The error log.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetErrorLog
    /// ## (not implemented yet in xplHAL2)
    /// #$Sys.GetErrorLog()
    /// </code>
    /// </example>
    public object GetErrorLog() {
        return SendSimpleListCommand("GETERRLOG", "", XH207, null);
    }

    /// <summary>
    /// Retrieves information about a specific event. 
    /// </summary>
    /// <param name="tag"></param>
    /// <returns><list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If device exists</term>
    /// <description>A list of <code>KeyValuePair&lt;string, string&gt;</code> containing the event data.</description>
    /// </item><item>
    /// <term>If the device does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the device does not exist.</description>
    /// </item></list></returns>    
    /// <example>
    /// <code>
    /// ##
    /// ##  GetEvent
    /// 
    /// $event = $sys.getevent("test")
    /// Write-Output $event
    /// </code>
    /// </example>
    public object GetEvent(string tag) {
        string line;
        Dictionary<string, string> list = new Dictionary<string, string>();

        try {
            xplHalSend("GETEVENT " + tag);
            line = GetLine();

            if (line.StartsWith(XH222)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        list.Add(line.Substring(0, line.IndexOf("=")), line.Substring(line.IndexOf("=") + 1, (line.Length - line.IndexOf("=") - 3)));
                    } else
                        break;
                }

                return list;
            } else if (line.StartsWith(XH422)) {
                return false;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Returns the value of a global variable.
    /// </summary>
    /// <param name="globalname">The key of the value to retrieve.</param>
    /// <returns>
    /// <list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If global exists</term>
    /// <description>The value as a string containing the value.</description>
    /// </item><item>
    /// <term>If the global does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the key does not exist in the GOC.</description>
    /// </item></list></returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetGlobal
    /// $value = $Sys.GetGlobal("xplhal.mode")
    /// if ($value -eq $false) {
    ///   Write-Output "global value does not exist"
    /// } else {
    ///   Write-Output "value: $value"
    /// }
    /// </code>
    /// </example>
    public object GetGlobal(string globalname) {
        return SendSimpleGetCommand("GETGLOBAL", globalname, XH291, XH491);
    }

    /// <summary>
    /// Returns the contents of a determinator.
    /// </summary>
    /// <param name="ruleguid">The GUID of the rule.</param>
    /// <returns>
    /// <list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If the determinator exists</term>
    /// <description>The XML data of the determinator.</description>
    /// </item><item>
    /// <term>If the determinator does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the key does not exist in the GOC.</description>
    /// </item></list>
    /// </returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetRule
    /// 
    /// #$sys.listrules()
    /// $rule = $Sys.GetRule("59639ae54255469dbfb9148558f91f36")
    /// if ($rule -eq $false) {
    ///   Write-Output "Rule does not exist."
    /// } else {
    ///   Write-Output "XML File contents:"
    ///   Write-Output $rule
    /// }
    /// </code>
    /// </example>
    public object GetRule(string ruleguid) {
        return SendSimpleListCommand("GETRULE", ruleguid, XH210, XH410);
    }

    /// <summary>
    /// Returns the contents of a script to the client. 
    /// </summary>
    /// <param name="scriptname">A complete filename. If you specify a path, it must be relative to the xPLHal scripts directory.</param>
    /// <returns>
    /// <list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If the script exists</term>
    /// <description>The script data of the script.</description>
    /// </item><item>
    /// <term>If the script does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the key does not exist in the GOC.</description>
    /// </item></list></returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetScript
    ///
    /// $script = $Sys.GetScript("Powershell\global.ps1")
    /// if ($script -eq $script) {
    ///   Write-Output "Script does not exist."
    /// } else {
    ///   Write-Output "Script file contents:"
    ///   Write-Output $script
    /// }
    /// </code>
    /// </example>
    public object GetScript(string scriptname) {
        return SendSimpleListCommand("GETSCRIPT", scriptname, XH210, XH410);
    }

    /// <summary>
    /// Retrieves the current value of a specified setting/construct.
    /// </summary>
    /// <param name="setting">Specifies the name of the setting to be retrieved.</param>
    /// <returns>
    /// <list type="table"><listheader>
    /// <term>When</term>
    /// <description>What</description>
    /// </listheader><item>
    /// <term>If the setting exists</term>
    /// <description>The value of the setting.</description>
    /// </item><item>
    /// <term>If the setting does not exist</term>
    /// <description><see cref="System.Boolean">System.Boolean</see> $false if the key does not exist in the GOC.</description>
    /// </item></list></returns>
    /// <example>
    /// <code>
    /// ##
    /// ## GetSetting
    ///
    /// $value = $Sys.GetSetting("period")
    /// if ($value -eq $false) {
    ///   Write-Output "Setting does not exist."
    /// } else {
    ///   Write-Output $value
    /// }
    /// </code>
    /// </example>
    public object GetSetting(string setting) {
        return SendSimpleGetCommand("GETSETTING", setting, XH208, XH405);
    }

    //public object GetSetting(string setting) {
    //    string line;
    //    List<XplHalSetting> setlist = new List<XplHalSetting>();

    //    try {
    //        xplHalSend("GETSETTING " + setting);
    //        line = GetLine();

    //        if (line.StartsWith(XH208)) {
    //            while (1 == 1) {
    //                line = GetLine();
    //                if (line != ".\r\n") {
    //                    string[] list = line.Split('\t');
    //                    XplHalSetting x = new XplHalSetting();
    //                    x.Value = list[0];
    //                    x.Name = list[1];
    //                    x.Description = list[2];
    //                    setlist.Add(x);
    //                } else
    //                    break;
    //            }

    //            return setlist;
    //        } else if (line.StartsWith(XH405)) {
    //            LastErrorCode = line;
    //            return false;
    //        } else
    //            throw new Exception("Unexpected result received from server.");
    //    } finally {
    //        Disconnect();
    //    }
    //}

    /// <summary>
    /// Returns a list of all known XPL devices on the network.
    /// </summary>
    /// <param name="option"><list type="bullet">
    /// <item><term>AWAITINGCONFIG</term><description>Lists only the devices that are awaiting configuration.</description></item>
    /// <item><term>CONFIGURED</term><description>Lists only the devices that have been configured.</description></item>
    /// <item><term>MISSINGCONFIG</term><description>Lists only the devices who have a missing configuration file.</description></item>
    /// </list></param>
    /// <returns>A <code>List&lt;<see cref="XPLDevice">XPLDevice</see>&gt;</code> containing the devices.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ListDevices
    ///
    /// $list = $Sys.ListDevices("MISSINGCONFIG")
    ///
    /// Write-Output $list
    /// </code>
    /// </example>
    public object ListDevices(string option) {
        //AWAITINGCONFIG   Lists only the devices that are awaiting configuration.
        //CONFIGURED       Lists only the devices that have been configured.
        //MISSINGCONFIG    Lists only the devices who have a missing configuration file

        return ListDevicesFiltered(option);
    }

    /// <summary>
    /// Returns a list of recurring events.
    /// </summary>
    /// <returns><code>List&lt;<see cref="XplEvent">XplEvent</see>&gt;</code> of the data of the recurring events.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ListDevices
    ///
    /// $list = $Sys.ListEvents()
    /// </code>
    /// </example>
    public object ListEvents() {
        string line;
        List<XplEvent> setlist = new List<XplEvent>();

        try {
            xplHalSend("LISTEVENTS");
            line = GetLine();

            if (line.StartsWith(XH218)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        XplEvent x = new XplEvent();
                        x.Tag = list[0];
                        x.SubName = list[1];
                        x.Parms = list[2];
                        x.StartTime = list[3];
                        x.EndTime = list[4];
                        x.DOW = list[5];
                        x.RunTime = list[6];
                        setlist.Add(x);
                    } else
                        break;
                }

                return setlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Returns all the global variables and their content.
    /// </summary>
    /// <returns>A List of <code>KeyValuePair&lt;string, string&gt;</code> of all objects in the GOC.</returns>
    /// <example>
    /// <code>
    /// #
    /// # ListGlobals
    /// 
    /// $list = $Sys.ListGlobals()
    /// 
    /// if ($list.containsKey("apple")) { 
    ///     echo "apple found" 
    /// }
    /// 
    /// if ($list.containsKey("xplhal.period")) { 
    ///     echo "period found"
    /// }
    /// </code>
    /// </example>
    public Dictionary<string, string> ListGlobals() {
        Dictionary<string, string> list = new Dictionary<string, string>();
        string line;
        try {
            xplHalSend("LISTGLOBALS");
            line = GetLine();
            if (line.StartsWith("231")) {
                while (1 == 1) {
                    line = GetLine();
                    if (line == ".\r\n")
                        break;

                    int idx = line.IndexOf("=");
                    list.Add(line.Substring(0, idx), line.Substring(idx + 1, line.Length - idx - 3));
                }

                return list;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    ///// <summary>
    ///// Lists all available options for a specified setting.
    ///// NOT IMPLEMENTED BY XPLHAL
    ///// </summary>
    ///// <param name="setting"></param>
    ///// <returns></returns>
    ///// <example>
    ///// <code>
    ///// </code>
    ///// </example>
    //public object ListOptions(string setting) {
    //    return SendSimpleListCommand("LISTOPTIONS", "", XH205, null);
    //}

    /// <summary>
    /// Retrieves a list of all defined determinator groups.
    /// </summary>
    /// <returns>A <code>List&lt;<see cref="RuleGroup">RuleGroup</see>&gt;</code> containing the available determinator groups.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $Sys.ListRuleGroups()
    /// </code>
    /// </example>
    public object ListRuleGroups() {
        string line;
        List<RuleGroup> devlist = new List<RuleGroup>();

        try {
            xplHalSend("LISTRULEGROUPS");
            line = GetLine();

            if (line.StartsWith(XH240)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        RuleGroup x = new RuleGroup();
                        x.GroupGuid = list[0];
                        x.GroupName = list[1];
                        devlist.Add(x);
                    } else
                        break;
                }

                return devlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    //
    
    /// <summary>
    /// Retrieves a list of all xPL Determinators.
    /// </summary>
    /// <remarks>This method is the same as calling <code>$Sys.ListRules("{ALL}")</code></remarks>
    /// <returns>A <code>List&lt;<see cref="Rule">Rule</see>&gt;</code> containing the available determinator data.</returns>
    /// <example>
    /// <code>
    /// $Sys.ListRules()
    /// </code>
    /// </example>
    public object ListRules() {
        return ListRules("{ALL}");
    }

    /// <summary>
    /// Retrieves a list of xPL Determinators in a specific group.
    /// </summary>
    /// <param name="groupname"><list type="bullet">
    /// <item>{ALL}</item><description>Lists all the determinators in all groups. Analogue to <see cref="ListRules()">ListRules()</see>.</description>
    /// <item>group name</item><description>Lists only the determinators in a specific group.</description></list></param>
    /// <returns>A <code>List&lt;<see cref="Rule">Rule</see>&gt;</code> containing the available determinator data.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $Sys.ListRules("group 66")
    /// </code>
    /// </example>
    public object ListRules(string groupname) {
        string line;
        List<Rule> devlist = new List<Rule>();

        try {
            if (groupname == "")
                xplHalSend("LISTRULES");
            else
                xplHalSend("LISTRULES " + groupname);
            line = GetLine();

            if (line.StartsWith(XH237)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        Rule x = new Rule();
                        x.RuleGuid = list[0];
                        x.RuleName = list[1];
                        x.Enabled = (list[2].ToUpper() == "Y");
                        devlist.Add(x);
                    } else
                        break;
                }

                return devlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Retrieves a list of scripts and subdirectories from the 
    /// xplHal scripting namespace. 
    /// </summary>
    /// <returns>A list of scripts available in the xPLHal scripting namespace.</returns>
    /// <example>
    /// <code>
    /// $Sys.ListScripts()
    /// </code>
    /// </example>
    public object ListScripts() {
        return ListScripts("");
    }

    /// <summary>
    /// Retrieves a list of scripts and subdirectories from the specified directory within the 
    /// xplHal scripting namespace. 
    /// </summary>
    /// <param name="path">Specifies the directory name from which the list of scripts should be returned.
    /// This path is relative to the xPLHal script directory.</param>
    /// <returns>A list of scripts available in the xPLHal scripting namespace.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $Sys.ListScripts("Powershell\")
    /// </code>
    /// </example>
    public object ListScripts(string path) {
        return SendSimpleListCommand("LISTSCRIPTS", path, XH212, null);
    }

    ///// <summary>
    ///// BROKEN, FIX LATER.
    ///// </summary>
    ///// <returns></returns>
    ///// <example>
    ///// <code>
    ///// </code>
    ///// </example>
    //public object ListSettings() {
    //    string line;
    //    List<XplSetting> setlist = new List<XplSetting>();

    //    try {
    //        xplHalSend("LISTSETTINGS");
    //        line = GetLine();

    //        if (line.StartsWith(XH204)) {
    //            while (1 == 1) {
    //                line = GetLine();
    //                if (line != ".\r\n") {
    //                    string[] list = line.Split('\t');
    //                    XplSetting x = new XplSetting();
    //                    x.SubID = list[0];
    //                    x.Name = list[1];
    //                    x.Desc = list[2];
    //                    x.CurrentValue = list[3];
    //                    x.CurrentValueDesc = list[4];
    //                    setlist.Add(x);
    //                } else
    //                    break;
    //            }
    //            return setlist;
    //        } else
    //            throw new Exception("Unexpected result received from server.");
    //    } finally {
    //        Disconnect();
    //    }
    //}

    /// <summary>
    /// Returns a list of all single events that have not yet been executed.
    /// Note that as soon as a single event is executed, it is deleted from the 
    /// database and will therefore no longer appear in the list of events returned by this command.
    /// </summary>
    /// <returns>A <code>List&lt;<see cref="XplSingleEvent">XplSingleEvent</see>&gt;</code> containing the available event data.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ListSubs
    /// 
    /// $Sys.ListSingleEvents()
    /// </code>
    /// </example>
    public object ListSingleEvents() {
        string line;
        List<XplSingleEvent> setlist = new List<XplSingleEvent>();

        try {
            xplHalSend("LISTSETTINGS");
            line = GetLine();

            if (line.StartsWith(XH204)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        XplSingleEvent x = new XplSingleEvent();
                        x.Tag = list[0];
                        x.SubName = list[1];
                        x.Date = DateTime.ParseExact(list[2], "", null);
                        setlist.Add(x);
                    } else
                        break;
                }

                return setlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }


    /// <summary>
    /// Returns a list of sub-routines and their parameters.
    /// </summary>
    /// <returns>A <code>List&lt;<see cref="SubRoutine">SubRoutine</see>&gt;</code> containing the subroutines.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ListSubs
    /// 
    /// $Sys.ListSubs("Powershell\")
    /// </code>
    /// </example>
    public object ListSubs() {
        string line;
        List<SubRoutine> setlist = new List<SubRoutine>();

        try {
            xplHalSend("LISTSUBSEX");
            line = GetLine();

            if (line.StartsWith(XH224)) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        SubRoutine x = new SubRoutine();
                        x.ScriptName = list[0];
                        x.FunctionName = list[1];
                        x.Parameters = list[2];
                        setlist.Add(x);
                    } else
                        break;
                }

                return setlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }
    
    //
    //MODE => NOT IMPLEMENTED YET
    //
    //PUTCONFIGXML => NOT IMPLEMENTED YET
    //
    //PUTDEVCONFIG => NOT IMPLEMENTED YET
    //

    /// <summary>
    /// Uploads a script to the servers script repository.
    /// </summary>
    /// <param name="scriptname">The name of the script. May include a pathname relative to the xPLHal script directory.</param>
    /// <param name="script">The contents of the script.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## PutScript
    /// 
    /// $source = "..."
    /// $Sys.PutScipt("Powershell\SomeScriptName.ps1", $source)
    /// </code>
    /// </example>
    public object PutScript(string scriptname, string script) {
        string line;
        string response = "";

        if (scriptname.Trim().Length == 0)
            return "Filename cannot be empty.";
    
        try {
            xplHalSend("PUTSCRIPT " + scriptname);
            line = GetLine();
            if (line.StartsWith("311")) {
                string[] lines = script.Split(new string[] { "\r\n" }, StringSplitOptions.None);
                foreach (string sline in lines) {
                    xplHalSend(sline);
                }

                xplHalSend(".");
                line = GetLine();
                if (line.StartsWith("211")) {
                    return true;
                } else if (line.StartsWith("242")) {
                    //additional response. get it.
                    //(not implemented in xPLHal v2 at the moment)
                    while (1 == 1) {
                        line = GetLine();
                        response += line;
                        if (line.EndsWith(".\r\n"))
                            break;
                    }

                    return response;
                } else if (line.StartsWith("503")) {
                    return "Internal Error - Command not performed.";
                }
                return false;
            } else if (line.StartsWith("503")) {
                return "Command not implemented.";
            } else
                throw new Exception("Unexpected result received from server.");
        } catch (Exception ex) {
            throw new Exception("Unexpected result received from server.", ex);
        } finally {
            Disconnect();
        }
    }

    /// <summary>
    /// Causes xPLHal to reload it's scripts. 
    /// </summary>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## ReloadScripts
    /// 
    /// if ($Sys.ReloadScripts() -eq $false) {
    /// 	Write-Output "Reload failed."
    /// } else {
    /// 	Write-Output "Reload succeeded."
    /// }
    /// </code>
    /// </example>
    public bool ReloadScripts() {
        string line;
        try {
            xplHalSend("RELOAD");
            line = GetLine();
            if (line.StartsWith("201")) {
                return true;
            } else if (line.StartsWith("401")) {
                return false;
            } else {
                throw new Exception("Unexpected result received from server.");
            }
        } finally {
            Disconnect();
        }
    }

    ///// <summary>
    ///// 
    ///// </summary>
    ///// <returns></returns>
    ///// <example>
    ///// <code>
    ///// </code>
    ///// </example>
    //public object GetReplicationInfo() {
    //    return SendSimpleCommand("REPLINFO", "", XH231, null);
    //}

    /// <summary>
    /// Executes a Determinator, even if it is marked as disabled. 
    /// </summary>
    /// <param name="ruleguid">The GUID of the specific determinator.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $list = $Sys.ListRules()
    /// $somerule = $list[1].RuleGuid
    /// 
    /// $Sys.RunRule($somerule)
    /// </code>
    /// </example>
    public object RunRule(string ruleguid) {
        return SendSimpleCommand("RUNRULE", ruleguid, XH203, XH410);
    }
    
    /// <summary>
    /// Runs the specified sub-routine. 
    /// </summary>
    /// <param name="subname">Specifies the name of the sub-routine to be executed. This must be in the form of [scriptname]$[sub-routine name].</param>
    /// <param name="param">Optional parameters, separated by a comma.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## RunSub
    /// 
    /// $Sys.RunSub("global$TurnOnKitchenLight")
    /// $Sys.RunSub("global$SpeakSomeText", "Hello World!")
    /// </code>
    /// </example>
    public object RunSub(string subname, string param) {
        if (param.Length > 0)
            subname += " " + param;

        return SendSimpleCommand("RUNSUB", subname, XH203, XH403);
    }

    /// <summary>
    /// Provides the ability for xplHal to send a custom xAP message.
    /// </summary>
    /// <param name="message">The complete xAP message.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    public object SendXapMsg(string message) {
        xplHalSend("SENDXAPMSG");
        GetLine();
        xplHalSend(message);
        string line = GetLine();
        if (!line.StartsWith(XH213))
            return false;
        else
            return true;
    }

    /// <summary>
    /// Provides the ability for xPLHal to send a custom xPL message.
    /// </summary>
    /// <param name="msgtype">Either: <list type="bullet">
    /// <item><code>"xpl-cmnd"</code><description>A xPL command message</description></item>
    /// <item><code>"xpl-trig"</code><description>A xPL trigger message</description></item>
    /// <item><code>"xpl-stat"</code><description>A xPL status message</description></item>
    /// </list></param>
    /// <param name="target">The target of the message. Can be a * for a broadcast.</param>
    /// <param name="schema">The schema according to the xPL specifications.</param>
    /// <param name="body">The body of the xPL message.</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $Sys.SendXplMessage("xpl-cmnd", "*", "x10.basic", "command=on\r\ndevice=a8")
    /// <code>
    /// </code>
    /// </example>
    public object SendXplMessage(string msgtype, string target, string schema, string body) {
        string line;
        string msg = msgtype + "\n{\nhop=1\nsource="
                    + globals.XplHalSource + "\ntarget="
                    + target + "\n}\n" + schema + "\n{\n"
                    + body.Replace(@"\n", "\n") + "\n}\n";
        

        xplHalSend("SENDXPLMSG");
        line = GetLine();
        xplHalSend(msg);
        xplHalSend(".");
        line = GetLine();
        if (!line.StartsWith(XH213))
            return false;
        else
            return true;
    }

    /// <summary>
    /// Provides the ability for xplHal to send a custom xPL message and broadcast it.
    /// </summary>
    /// <param name="msgtype">Either: <list type="bullet">
    /// <item><code>"xpl-cmnd"</code><description>A xPL command message</description></item>
    /// <item><code>"xpl-trig"</code><description>A xPL trigger message</description></item>
    /// <item><code>"xpl-stat"</code><description>A xPL status message</description></item>
    /// </list></param>
    /// <param name="schema">The schema according to the xPL specifications.</param>
    /// <param name="body">The body of the xPL message. Separate multiple key/value combinations with a newline character ("\n").</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SendXplMessage
    /// 
    /// $Sys.SendXplMessage("xpl-cmnd", "x10.basic", "command=off\ndevice=a8")
    /// </code>
    /// </example>
    public object SendXplMessage(string msgtype, string schema, string body) {
        string line;
        string msg = msgtype + "\n{\nhop=1\nsource="
                    + globals.XplHalSource + "\ntarget=*"
                    + "\n}\n" + schema + "\n{\n"
                    + body.Replace(@"\n", "\n") + "\n}\n";

        xplHalSend("SENDXPLMSG");
        GetLine();
        xplHalSend(msg);
        xplHalSend(".");
        line = GetLine();
        if (!line.StartsWith(XH213))
            return false;
        else
            return true;
    }

    /// <summary>
    /// Sets the value of a global variable.
    /// </summary>
    /// <param name="key">Specifies the name of the global to be updated.</param>
    /// <param name="value">This is the new value of the variable.</param>
    /// <remarks>
    /// <list>
    /// <item>If the global does not exist it will be created.</item>
    /// <item>Global variables should not contain spaces.</item>
    /// </list>
    /// </remarks>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SetGlobal
    /// 
    /// $Sys.SetGlobal("somekey", "somevalue)
    /// </code>
    /// </example>
    public object SetGlobal(string key, string value) {
        return SendSimpleCommand("SETGLOBAL", key + " " + value, XH232, null);
    }

    /// <summary>
    /// Adds or updates an xPL Determinator or determinator group.
    /// </summary>
    /// <param name="ruleguid">The rule GUID identifying the specific determinator or group.</param>
    /// <param name="xml">The determinator as an XML document</param>
    /// <returns><see cref="System.Boolean">System.Boolean</see> $true if successful, $false if an error occurred.</returns>
    /// <example>
    /// <code>
    /// ##
    /// ## SetRule
    /// 
    /// $Sys.SetRule("", $some_xml_file)
    /// </code>
    /// </example>
    public object SetRule(string ruleguid, string xml) {
        xplHalSend("SETRULE " + ruleguid);
        string line = GetLine();
        if (!line.StartsWith(XH338))
            return false;

        xplHalSend(xml);
        line = GetLine();
        if (!line.StartsWith(XH238))
            return false;
        else
            return line;
    }

    /// <summary>
    /// Returns a list of devices with their states.
    /// </summary>
    /// <returns></returns>
    protected List<XPLDevice> ListDevicesFiltered(string filter) {
        string line;
        List<XPLDevice> devlist = new List<XPLDevice>();

        try {
            if (filter != "")
                xplHalSend("LISTDEVICES " + filter);
            else
                xplHalSend("LISTDEVICES");

            line = GetLine();

            if (line.StartsWith("216")) {
                while (1 == 1) {
                    line = GetLine();
                    if (line != ".\r\n") {
                        string[] list = line.Split('\t');
                        XPLDevice x = new XPLDevice();
                        x.Vdi = list[0];
                        x.Expires = list[1];
                        x.Interval = list[2];
                        x.Configtype = list[3] == "Y";
                        x.Configdone = list[4] == "Y";
                        x.Waitingconfig = list[5] == "Y";
                        x.Suspended = list[6] == "Y";
                        devlist.Add(x);
                    } else
                        break;
                }

                return devlist;
            } else
                throw new Exception("Unexpected result received from server.");
        } finally {
            Disconnect();
        }
    }

    ///// <summary>
    ///// 
    ///// </summary>
    ///// <param name="settingname"></param>
    ///// <param name="settingvalue"></param>
    ///// <returns></returns>
    ///// <example>
    ///// <code>
    ///// </code>
    ///// </example>
    //public object SetSetting(string settingname, string settingvalue) {
    //    xplHalSend("SETSETTING " + settingname + " " + settingvalue);
    //    string line = GetLine();
    //    if (!line.StartsWith(XH206))
    //        return false;
    //    else
    //        return true;
    //}

    //protected void SaveXML(string xmltext) {
    //    string line;
    //    ConnectToXplHal();
    //    xplHalSend("PUTCONFIGXML");
    //    line = GetLine();
    //    if (!line.StartsWith("315")) {
    //        //MsgBox(("Your updated xPLHal configuration could not be saved." + "\r\n" + "\r\n" + "The xPLHal server returned the following:" + "\r\n" + line))))), vbExclamation);
    //        return;
    //    }
    //    xplHalSend(xmltext.Trim());
    //    xplHalSend(".");
    //    line = GetLine();
    //    if (!line.StartsWith("215")) {
    //        globals.Unexpected(line);
    //    }
    //}

    protected void VersionCheck() {
        int i = WelcomeBanner.IndexOf("Version ");
        if ((i == -1)) {
            return;
        }
        int serverMajor;
        int serverMinor;
        int serverBuild;
        string line = WelcomeBanner.Substring((i + 8), (WelcomeBanner.Length - (i - 9)));
        string[] lines = line.Split('.');
        if (!(lines.Length >= 4)) {
            return;
        }
        serverMajor = int.Parse(lines[0]);
        serverMinor = int.Parse(lines[1]);
        serverBuild = int.Parse(lines[2]);
        bool OutOfDate = false;
        if (((serverMajor < globals.MinMajor)
                    || ((serverMajor == globals.MinMajor)
                    && (serverMinor < globals.MinMinor)))) {
            OutOfDate = true;
        } else if (((serverMajor == globals.MinMajor)
                    && ((serverMinor == globals.MinMinor)
                    && (serverBuild < globals.MinBuild)))) {
            OutOfDate = true;
        }
        globals.ServerMajorVersion = serverMajor;
        if (OutOfDate) {
            globals.ServerOutOfDate = true;
        } else {
            globals.ServerOutOfDate = false;
        }
    }



    //public void GetCapabilities() {
    //    string line;
    //    string DefaultScriptingChar;
    //    DefaultScriptingChar = "";
    //    xplHalSend("CAPABILITIES SCRIPTING" + "\r\n"));
    //    line = GetLine();
    //    if ((line.StartsWith("236") || line.StartsWith("241"))) {
    //        globals.Capabilities = line.Substring(4, (line.Length - 4));
    //        if ((globals.Capabilities.Length > 3)) {
    //            DefaultScriptingChar = globals.Capabilities.Substring(2, 1);
    //        }
    //    } else {
    //        globals.Capabilities = string.Empty;
    //    }
    //    //  Do we have scripting information?
    //    if (line.StartsWith("241")) {
    //        //  Read supported script languages
    //        line = GetLine();
    //        string[] Bits;
    //        ArrayList TheEngines = new ArrayList();
    //        globals.ScriptingEngine TheEngine;
    //        while (((line != ".")
    //                    && (line != ("." + "\r\n")))) {
    //            Bits = line.Split(((char)('\t')));
    //            if ((Bits.Length >= 5)) {
    //                TheEngine = new globals.ScriptingEngine();
    //                // With...
    //                Code = DefaultScriptingChar;
    //                Bits[2].Extension = Bits[4];
    //                Bits[1].Version = Bits[4];
    //                Bits[0].Name = Bits[4];
    //                TheEngine.Code = Bits[4];
    //                globals.DefaultScriptingEngine = TheEngine;
    //            }
    //            TheEngines.Add(TheEngine);
    //        }
    //        line = GetLine();
    //    }
    //    globals.ScriptingEngines = ((globals.ScriptingEngine[])(TheEngines.ToArray(typeof(globals.ScriptingEngine))));
    //}

    //protected string SetRule(string myRuleGuid, string ruletext) {
    //    //  This routine adds or updates a determinator on the xPLHal server
    //    ConnectToXplHal();
    //    string line;
    //    xplHalSend("SETRULE");
    //    if (myRuleGuid != "") {
    //        xplHalSend(" " + myRuleGuid);
    //    }
    //    xplHalSend("");
    //    line = GetLine();
    //    if (line.StartsWith("338")) {
    //        xplHalSend(ruletext + "\r\n" + ".");
    //        line = GetLine();
    //        if (!line.StartsWith("238")) {
    //            globals.Unexpected(line);
    //        }
    //    }
    //    return line;
    //}

    #region IDisposable Members

    /// <exclude/>
    public void Dispose() {
        Disconnect();
    }

    #endregion

    #region XHCP Codes
    const string XH201 = "201 Reload successful";
    const string XH202 = "202 ";
    const string XH203 = "203 OK";
    const string XH204 = "204 List of settings follow";
    const string XH205 = "205 List of options follow";
    const string XH206 = "206 Setting updated";
    const string XH207 = "207 Error log follows";
    const string XH208 = "208 Requested setting follows";
    const string XH209 = "209 Configuration document follows";
    const string XH210 = "210 Requested script or rule follows";
    const string XH211 = "211 Script saved successfully";
    const string XH212 = "212 List of scripts follows";
    const string XH213 = "213 XPL message transmitted";
    const string XH214 = "214 Script/rule successfully deleted";
    const string XH215 = "215 Configuration document saved";
    const string XH216 = "216 List of XPL devices follows";
    const string XH217 = "217 List of config items follows";
    const string XH218 = "218 List of events follows";
    const string XH219 = "219 Event added successfully";
    const string XH220 = "220 Configuration items received successfully";
    const string XH221 = "221 Closing transmission channel - goodbye.";
    const string XH222 = "222 Event information follows";
    const string XH223 = "223 Event deleted successfully";
    const string XH224 = "224 List of subs follows";
    const string XH225 = "225 Error log cleared";
    const string XH226 = "226 X10 device information updated";
    const string XH227 = "227 X10 device information follows";
    const string XH228 = "228 X10 device deleted";
    const string XH229 = "229 Requested sub follows";
    const string XH230 = "230 Replication mode active";
    const string XH231 = "231 List of global variables follows";
    const string XH232 = "232 Global value updated";
    const string XH233 = "233 Global deleted";
    const string XH234 = "234 Configuration item value(s) follow";
    const string XH235 = "235 Device configuration deleted";
    const string XH237 = "237 List of Determinator Rules follows";
    const string XH238 = "238 Rule added successfully";
    const string XH239 = "239 Statistics follow";
    const string XH240 = "240 List of determinator groups follows";
    const string XH291 = "291 Global value follows";
    const string XH292 = "292 List of x10 device states follows";
    const string XH311 = "311 Enter script, end with <CrLf>.<CrLf>";
    const string XH313 = "313 Send message to be transmitted, end with <CrLf>.<CrLf>";
    const string XH315 = "315 Enter configuration document, end with <CrLf>.<CrLf>";
    const string XH319 = "319 Enter event data, end with <CrLf>.<CrLf>";
    const string XH320 = "320 Enter configuration items, end with <CrLf>.<CrLf>";
    const string XH326 = "326 Enter X10 device information, end with <CrLf>.<CrLf>";
    const string XH338 = "338 Send rule, end with <CrLf>.<CrLf>";
    const string XH401 = "401 Reload failed";
    const string XH403 = "403 Script not executed";
    const string XH405 = "405 No such setting";
    const string XH410 = "410 No such script or rule";
    const string XH416 = "416 No config available for specified device";
    const string XH417 = "417 No such device";
    const string XH418 = "418 No vendor information available for specified device";
    const string XH422 = "422 No such event";
    const string XH429 = "429 No such sub-routine";
    const string XH491 = "491 No such global";
    const string XH500 = "500 Command not recognised";
    const string XH501 = "501 Syntax error";
    const string XH502 = "502 Access denied";
    const string XH503 = "503 Internal error - command not performed";
    const string XH530 = "530 A replication client is already active";
    const string XH600 = "600 Replication data follows";
    #endregion


}