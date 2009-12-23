using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.Runtime.Serialization;
using System.Net;

namespace xPLHalScriptHelper {
    [DataContract]
    //[ServiceKnownType(typeof(Dictionary<string, object[]>))]
    public class DebugScriptInfo {
        private string modifiedScript = "";
        private bool isScriptModified;
        private string source;
        //static XplMsg _XplMessage;

        //public XplMsg XplMessage {
        //    get {
        //        if (_XplMessage == null) {
        //            _XplMessage = new XplMsg(xPLMessageString);
        //        }

        //        return _XplMessage;
        //    }
        //}

        [DataMember]
        public string Source {
            get {
                return source;
            }
            set {
                source = value;
                //OnScriptModified(this, new EventArgs());
            }
        }

        [DataMember]
        public string SourceFile { get; set; }

        [DataMember]
        public string ScriptName { get; set; }

        [DataMember]
        public string xPLMessageString { get; set; }

        [DataMember]
        public string GlobalScriptSource { get; set; }

        [DataMember]
        public IPAddress HalIPAddress { get; set; }

        public string ModifiedScript {
            get { return modifiedScript; }
            set {
                modifiedScript = value;
                isScriptModified = !(ModifiedScript == Source);

                //if (isScriptModified)
                //    OnScriptModified(this, new EventArgs());
            }
        }

        //public event EventHandler ScriptModified;
        //public void OnScriptModified(object sender, EventArgs e) {
        //    if (ScriptModified != null)
        //        ScriptModified(sender, e);
        //}

        public bool IsScriptModified {
            get { return isScriptModified; }
        }

    }
}
