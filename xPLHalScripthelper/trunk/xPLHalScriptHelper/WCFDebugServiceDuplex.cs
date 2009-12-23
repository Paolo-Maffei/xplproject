using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace xPLHalDebugger {
    [ServiceBehavior(
        InstanceContextMode = InstanceContextMode.Single, 
        ConcurrencyMode = ConcurrencyMode.Multiple, 
        IncludeExceptionDetailInFaults = true)]
    //[ServiceBehavior(InstanceContextMode = InstanceContextMode.PerSession)]
    [CallbackBehaviorAttribute(
        IncludeExceptionDetailInFaults=true)]
    public class WCFDebugServiceDuplex : IWCFDebugServiceDuplex {
        public Sys sys = new Sys();
        static protected IWCFDebugServiceDuplexCallback callback;

        public delegate void ScriptAddedEventHandler(DebugScriptInfo info);
        public event ScriptAddedEventHandler AddScript;
        public void OnScriptAdded(DebugScriptInfo info) {
            if (AddScript != null)
                AddScript(info);
        }

        public void SetDebugScriptInfo(DebugScriptInfo info) {
            OnScriptAdded(info);
            callback = OperationContext.Current.GetCallbackChannel<IWCFDebugServiceDuplexCallback>();

            //Callback.SetGlobal("some global value");

            //for dev: set timeout to something more useful
            //it actually does not matter; once this connection is 
            //gone, the tabpage more or less is useless.
            ((IContextChannel)OperationContext.Current.Channel).OperationTimeout = new TimeSpan(0, 0, 2) ;
        }

        //use this method only in a local method
        static IWCFDebugServiceDuplexCallback Callback {
            get {
                return OperationContext.Current.GetCallbackChannel<IWCFDebugServiceDuplexCallback>();
            }
        }

        /// <summary>
        /// Provides methods to get/set xPLHAL vars...
        /// </summary>
        public class Sys {
            public string SetGlobal(string key, string value) {
                try {
                    callback.SetGlobal(key, value);
                    return string.Empty;
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string GetGlobal(string key) {
                try {
                    return callback.GetGlobal(key);
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string AddGlobal(string key, string value) {
                try {
                    callback.AddGlobal(key, value);
                    return "";
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }
            
            public object DeleteGlobal(string key) {
                try {
                    return callback.DeleteGlobal(key);
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string SetMode(string mode) {
                try {
                    callback.SetMode(mode);
                    return "";
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string GetMode() {
                try {
                    return callback.GetMode();
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string GetPeriod() {
                try {
                    return callback.GetPeriod();
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string AddSingleEvent(DateTime when, string scriptname, string[] parameters, string tag) {
                try {
                    AddSingleEvent(when, scriptname, parameters, tag);
                    return "";
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public string AddRecurringEvent(DateTime start, DateTime end, int interval, string days, string scriptname, string[] parameters, string tag) {
                try {
                    AddRecurringEvent(start, end, interval, days, scriptname, parameters, tag);
                    return "";
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }

            public object DeleteTimedEvent(string tag) {
                try {
                    return callback.DeleteTimedEvent(tag);
                } catch (Exception ex) {
                    return "Communication with xPLHal lost!\r\n\r\nInner exception:\r\n" + ex.Message;
                }
            }
        }
    }
}
