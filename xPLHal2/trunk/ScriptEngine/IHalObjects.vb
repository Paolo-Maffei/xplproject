Imports System

Interface IHalObjects
    Function AddRecurringEvent(ByVal eventdata As HalObjects.RecurringEventInfo) As Boolean
    Function AddSingleEvent(ByVal eventdata As HalObjects.SingleEventInfo) As Boolean
    Function ClearErrorLog() As Object
    Function DeleteDeviceConfig(ByVal vdi As String) As Object
    Function DeleteEvent(ByVal tag As String) As Object
    Function DeleteGlobal(ByVal globalname As String) As Object
    Function DeleteRule(ByVal ruleguid As String) As Object
    Function DeleteScript(ByVal scriptname As String) As Object
    Function GetDeviceConfig(ByVal vdi As String) As Object
    Function GetDeviceConfigValue(ByVal vdi As String, ByVal configitem As String) As Object
    Function GetErrorLog() As Object
    Function GetEvent(ByVal tag As String) As Object
    Function GetGlobal(ByVal globalname As String) As Object
    Function GetReplicationInfo() As Object
    Function GetRule(ByVal ruleguid As String) As Object
    Function GetScript(ByVal scriptname As String) As Object
    Function GetSetting(ByVal setting As String) As Object
    Function ListDevices(ByVal options As String) As Object

    Function ListEvents() As Object
    Function ListGlobals() As System.Collections.Generic.Dictionary(Of String, String)
    Function ListOptions(ByVal setting As String) As Object
    Function ListRuleGroups() As Object

    Function ListRules() As Object
    Function ListRules(ByVal groupname As String) As Object

    Function ListScripts() As Object
    Function ListScripts(ByVal path As String) As Object

    Function ListSettings() As Object
    Function ListSingleEvents() As Object

    Function ListSubs() As Object
    Function ListSubs(ByVal path As String) As Object

    Function PutScript(ByVal scriptname As String, ByVal script As String) As Object
    'Function ReloadScripts() As Boolean
    Function RunRule(ByVal ruleguid As String) As Object

    Function RunSub(ByVal scriptname As String, ByVal parameters As String) As Object

    Function SendXplMsg(ByVal t As String, ByVal target As String, ByVal body As String) As Object
    Function SendXplMsg(ByVal t As String, ByVal target As String, ByVal schema As String, ByVal body As String) As Object
    Function SetGlobal(ByVal key As String, ByVal value As String) As Object
    Function SetRule(ByVal ruleguid As String, ByVal xml As String) As Object
    Function SetSetting(ByVal settingname As String, ByVal settingvalue As String) As Object
End Interface
