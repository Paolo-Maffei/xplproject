using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace xPLHalScriptHelper {
    // NOTE: If you change the interface name "IWCFDebugService" here, you must also update the reference to "IWCFDebugService" in App.config.
    [ServiceContract]
    [ServiceKnownType(typeof(Dictionary<string, object[]>))]
    public interface IWCFDebugService {
        [OperationContract]
        void SetDebugScriptInfo(ref DebugScriptInfo info);
        //void SetxPLInterface(xPLInterface intf);
    }


    
}
