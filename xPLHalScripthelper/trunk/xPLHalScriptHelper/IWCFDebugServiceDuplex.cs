using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace xPLHalDebugger {
    // DUPLEX CODE //
    [ServiceContract(SessionMode = SessionMode.Required,
                    CallbackContract = typeof(IWCFDebugServiceDuplexCallback))]
    public interface IWCFDebugServiceDuplex {
        //[OperationContract(IsOneWay = true)]
        [OperationContract]
        void SetDebugScriptInfo(DebugScriptInfo info);
    }


    public interface IWCFDebugServiceDuplexCallback {
        [OperationContract(IsOneWay = true)]
        void SetGlobal(string key, string value);

        [OperationContract]
        string GetGlobal(string key);

        [OperationContract]
        void AddGlobal(string key, string value);
        
        [OperationContract]
        bool DeleteGlobal(string key);

        [OperationContract]
        void SetMode(string mode);

        [OperationContract]
        string GetMode();

        [OperationContract]
        string GetPeriod();

        [OperationContract]
        void AddSingleEvent(DateTime when, string scriptname, string[] parameters, string tag);

        [OperationContract]
        void AddRecurringEvent(DateTime start, DateTime end, int interval, string days, string scriptname, string[] parameters, string tag);

        [OperationContract]
        bool DeleteTimedEvent(string tag);
    }
}
