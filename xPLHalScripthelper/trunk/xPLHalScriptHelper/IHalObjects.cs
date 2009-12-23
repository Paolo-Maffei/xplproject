using System;
using System.Collections.Generic;

namespace xPLHalScriptHelper {
    interface IHalObjects {

        bool AddRecurringEvent(Sys.RecurringEventInfo eventdata);

        bool AddSingleEvent(Sys.SingleEventInfo eventdata);

        object ClearErrorLog();

        object DeleteDeviceConfig(string vdi);

        object DeleteEvent(string tag);

        object DeleteGlobal(string globalname);

        object DeleteRule(string ruleguid);

        object DeleteScript(string scriptname);

        object GetDeviceConfig(string vdi);

        object GetDeviceConfigValue(string vdi, string configitem);

        object GetErrorLog();

        object GetEvent(string tag);

        object GetGlobal(string globalname);

        //object GetReplicationInfo();

        object GetRule(string ruleguid);

        object GetScript(string scriptname);

        object GetSetting(string setting);

        object ListDevices(string options);

        object ListEvents();

        System.Collections.Generic.Dictionary<string, string> ListGlobals();

        //object ListOptions(string setting);

        object ListRuleGroups();

        object ListRules();

        object ListRules(string groupname);

        object ListScripts();

        object ListScripts(string path);

        //object ListSettings();

        object ListSingleEvents();

        object ListSubs();

        //object ListSubs(string path);

        object PutScript(string scriptname, string script);

        object RunRule(string ruleguid);

        object RunSub(string scriptname, string parameters);

        object SendXplMessage(string msgtype, string schema, string body);

        object SendXplMessage(string msgtype, string target, string schema, string body);

        object SetGlobal(string key, string value);

        object SetRule(string ruleguid, string xml);

        //object SetSetting(string settingname, string settingvalue);
    }
}
