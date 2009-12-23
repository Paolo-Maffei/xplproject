using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Windows.Forms;
using System.Threading;

namespace xPLHalScriptHelper {
    // NOTE: If you change the class name "WCFDebugService" here, you must also update the reference to "WCFDebugService" in App.config.
    //[ServiceContract]
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single)]
    public class WCFDebugService : IWCFDebugService {

        public delegate void ScriptAddedEventHandler(DebugScriptInfo info);
        public event ScriptAddedEventHandler AddScript;
        public void OnScriptAdded(DebugScriptInfo info) {
            if (AddScript != null)
                AddScript(info);
        }

        public void SetDebugScriptInfo(ref DebugScriptInfo info) {
            OnScriptAdded(info);
        }
    }
}
