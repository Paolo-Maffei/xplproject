unit PS_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_listener
     , u_xpl_custom_listener
     , u_xpl_message
     , u_xpl_cache_manager
     , u_xpl_globals
     , ps_scripter
     , uPSComponent
     , uPSUtils
     ;

type TxPLMessageArrived = procedure (aMessage: String) of object;         // Function called when an xPLMessage arrives
     TStopScript        = function       : Longint of object;             // Function called when stopping from outsite


{ TxPLPSListener }

     TxPLPSListener = class(TxPLListener)
     protected
     private
        fGlobalList : TxPLGlobals;
        fCacheManager : TxPLCacheManager;
        function AutoProc(const aMessage : TxPLMessage; V,D,I,MT : string) : boolean;
     public
        PSScript: TPS_Scripter;
        MessageArrived : TxPLMessageArrived;
        StopScript     : TStopScript;
        xPLMessage  : TxPLMessage;

        constructor Create(const aOwner : TComponent); overload;
        destructor  Destroy; override;
        procedure   Joined;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);

        // Message Send functions
        procedure SendMsg(aMsgType : string; aTarget,aSchema,aBody : string);
        // Message management functions
        function  MessageType : string;
        function  MessageSender : string;
        function  MessageSchema : string;
        function  Msg_Class : string;
        function  Msg_Sender_Device: string;
        function  MessageValues : integer;
        function  MessageKey (i : integer) : string;
        function  MessageValue(i : integer) : string;
        function  MessageValueFromKey(s : string) : string;
        // Globals management functions
        function  GlobalValue(aString : string) : string;
        function  GlobalFormer(aString : string) : string;
        function  GlobalCreated(aString : string) : TDateTime;
        function  GlobalModified(aString : string) : TDateTime;
        function  Exists(aString : string; bDelete : boolean) : boolean;
        procedure Value(aString, aValue : string);
        // Logs management functions
        procedure Log(aString : string);
        // PS Script event handling
        function  Compile : boolean;
        procedure PSScriptCompile(Sender: TPSScript);
        procedure PSScriptExecute(Sender: TPSScript);
//        procedure PSScriptVerifyProc(Sender: TPSScript; Proc: TPSInternalProcedure; const Decl: tbtstring; var Error: Boolean);
        procedure OnDie(Sender : TObject); override;
//        procedure GlobalChangeTrigger(const aValue : string; const aNew : string; const aOld : string) ;
     published
        property GlobalList : TxPLGlobals read fGlobalList write fGlobalList;
     end;


implementation // =============================================================
uses u_xpl_common
     , u_xpl_header
     , StrUtils
     , u_Configuration_Record
     , u_xpl_config
     , u_xpl_schema
     , u_xpl_body
     , DateUtils
     , uxPLConst
     , u_xpl_custom_message
     ;

const //=======================================================================
     rsScriptFile = 'scriptfile';

// ============================================================================
procedure MyWriteln(const s: string);
begin
   writeln(s);
end;

// TxPLPSListener =============================================================
constructor TxPLPSListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   OnxPLJoinedNet := @Joined;

   fGlobalList := TxPLGlobals.Create(self);

   fCacheManager := TxPLCacheManager.Create(Folders.DeviceDir); //, fGlobalList);
   xPLMessage  := TxPLMessage.Create(self);

   PSScript := TPS_Scripter.Create(self);
   PSScript.OnCompile    := @PSScriptCompile;
   PSScript.OnExecute    := @PSScriptExecute;

   Config.DefineItem(rsScriptFile, TxPLConfigItemType.config,1,'');
end;

destructor TxPLPSListener.Destroy;
begin
   try
      // fCacheManager.Free; do not free it, it generates a run-time error
      PSScript.ExecuteFunction([],'STOPSCRIPT');
   except
   end;
   inherited Destroy;
end;

procedure TxPLPSListener.Joined;
begin
   if Config.IsValid and (ConnectionStatus = connected) then Compile;
end;

procedure TxPLPSListener.UpdateConfig;
begin
   inherited;
   Joined;
end;

procedure TxPLPSListener.PSScriptCompile(Sender: TPSScript);
begin
   Sender.AddFunction(@MyWriteln, 'procedure Writeln(s: string);');
   Sender.AddRegisteredVariable('xpl', 'TxPLPSListener');
end;

procedure TxPLPSListener.PSScriptExecute(Sender: TPSScript);
begin
   PSScript.SetVarToInstance('xpl', self);
end;

function TxPLPSListener.AutoProc(const aMessage : TxPLMessage; V,D,I,MT : string) : boolean;
var procname : string;
    aMethod : TxPLMessageArrived;
begin
   ProcName := V;
   if D<>'' then ProcName := ProcName + '_' + D;
   if I<>'' then ProcName := ProcName + '_' + I;
   if MT<>'' then ProcName := ProcName + '_' + MT;
   ProcName := AnsiReplaceStr('xpl-','',ProcName);
   aMethod  := TxPLMessageArrived(PSScript.GetProcMethod(ProcName));
   result := Assigned(aMethod);
   if result then begin
      if aMessage<>nil then aMethod(aMessage.RawxPL)
                       else aMethod('');
   end;
end;

procedure TxPLPSListener.OnDie(Sender: TObject);
var Device : TConfigurationRecord;
begin
   Device := TConfigurationRecord(Sender);
   AutoProc(nil,Device.Address.Vendor,Device.Address.Device,Device.Address.Instance,'Expired');
   writeln('Module ' + Device.Address.RawxPL + ' died');
   inherited;
end;

procedure TxPLPSListener.Process(const aMessage: TxPLMessage);
begin
   xPLMessage.Assign(aMessage);                                                // Copy it to preserve it
   fCacheManager.Process(aMessage);                                            // See if the message shall be cached in globals

   with aMessage do begin                                                      //*** AUTO DISPATCH SYSTEM
      if not (Schema.Equals(Schema_HBeatApp)  and AutoProc(aMessage,Source.Vendor,Source.Device,Source.Instance,'Heartbeat')) then
      if not (Schema.Equals(Schema_ConfigApp) and AutoProc(nil,Source.Vendor,Source.Device,Source.Instance,'Config')) then
      if not AutoProc(aMessage,Source.Vendor,Source.Device,Source.Instance,MsgTypeToStr(MessageType)) then
      if not AutoProc(aMessage,Source.Vendor,Source.Device,Source.Instance,'') then
      if not AutoProc(aMessage,Source.Vendor,Source.Device,'','') then
      if not AutoProc(aMessage,Source.Vendor,'','','') then
      if Assigned(MessageArrived) then MessageArrived(xPLMessage.RawXPL);      // Handle the message in the script's dedicated procedure
   end;
end;

procedure TxPLPSListener.SendMsg(aMsgType : string; aTarget,aSchema,aBody : string);
begin
   SendMessage( StrToMsgType(aMsgType), IfThen(aTarget='','*',aTarget),
                aSchema, '{'+#10+aBody+#10+'}');
end;

function TxPLPSListener.MessageType: string;
begin
   result := MsgTypeToStr(xPLMessage.MessageType);
end;

function TxPLPSListener.MessageSender: string;
begin
  result := xPLMessage.Source.RawxPL;
end;

function TxPLPSListener.MessageSchema: string;
begin
  result := xPLMessage.Schema.RawxPL;
end;

function TxPLPSListener.Msg_Class: string;
begin
  result := xPLMessage.Schema.Classe;
end;

function TxPLPSListener.Msg_Sender_Device: string;
begin
  result := xPLMessage.Source.Device;
end;

function TxPLPSListener.MessageValues: integer;
begin
  result := xPLMessage.Body.ItemCount;
end;

function TxPLPSListener.MessageKey(i: integer): string;
begin
  if i<xPLMessage.Body.ItemCount then result := xPLMessage.Body.Keys[i]
                                 else result := '';
end;

function TxPLPSListener.MessageValue(i: integer): string;
begin
  if i<xPLMessage.Body.ItemCount then result := xPLMessage.Body.Values[i]
                                 else result := '';
end;

function TxPLPSListener.MessageValueFromKey(s: string): string;
begin
  result := xPLMessage.Body.GetValueByKey(s,'***not found***');
end;

// Globals manipulation functions ==============================================
function TxPLPSListener.Exists(aString: string; bDelete: boolean): boolean;
var g : TxPLGlobalValue;
begin
   g := fGlobalList.FindItemName(aString);
   result := (g<>nil);

   if result and bDelete then g.Free;
end;

function TxPLPSListener.GlobalValue(aString: string): string;
var g : TxPLGlobalValue;
begin
   result := '';
   g := fGlobalList.FindItemName(aString);
   if g<>nil then result := g.Value;
end;

function TxPLPSListener.GlobalFormer(aString: string): string;
var g : TxPLGlobalValue;
begin
   result := '';
   g := fGlobalList.FindItemName(aString);
   if g<>nil then result := g.Former;
end;

function TxPLPSListener.GlobalCreated(aString: string): TDateTime;
var g : TxPLGlobalValue;
begin
   result := 0;
   g := fGlobalList.FindItemName(aString);
   if g<>nil then result := g.CreateTS;
end;

function TxPLPSListener.GlobalModified(aString: string): TDateTime;
var g : TxPLGlobalValue;
begin
   result := 0;
   g := fGlobalList.FindItemName(aString);
   if g<>nil then result := g.ModifyTS;
end;

procedure TxPLPSListener.Value(aString, aValue: string);
var g : TxPLGlobalValue;
begin
   g := fGlobalList.FindItemName(aString);

   if g=nil then
      g := fGlobalList.Add(aString);

   g.Value := aValue;
end;

// Globals manipulation functions ==============================================
procedure TxPLPSListener.Log(aString: string);
begin
   inherited Log(etInfo, aString);
end;

function TxPLPSListener.Compile : boolean;
var i: Longint;
begin
   PSScript.MainFileName := Folders.DeviceDir + Config.GetItemValue(rsScriptFile);
   result := FileExists(PSScript.MainFilename);

   if result then begin
      inherited Log(etInfo,'Loading and compiling %s',[PSScript.MainFileName]);
      PSScript.Script.LoadFromFile(PSScript.MainFileName);
      PSScript.Script.Insert(0,'program psscript;');
      PSScript.Script.Add('begin');
      PSScript.Script.Add('end.');
      result := PSScript.Compile;
      for i := 0 to PSScript.CompilerMessageCount -1 do
          inherited Log(etInfo,PSScript.CompilerMessages[i].MessageToString);
      if result then begin
         inherited Log(etInfo,'Syntax successfully checked');
         OnPreProcessMsg:= @Process;
         MessageArrived := TxPLMessageArrived (PSScript.GetProcMethod('XPLMESSAGEARRIVED'));
         GlobalList.OnGlobalChange := TxPLGlobalChangedEvent (PSScript.GetProcMethod('GLOBALCHANGED'));
         inherited Log(etInfo,'Launching program...');
         PSScript.ExecuteFunction([],'STARTSCRIPT');
      end
   end
   else
      inherited Log(etWarning,K_WEB_ERR_404,[PSScript.MainFileName]);

(*   FunctionList.Clear;
  with TRegExpr.Create do try
        //Expression := '(function\s+[\w\s.]+((:\s*\w+\s*;)|(\([\w\s,.='':;$/*()]*?\)\s*:\s*\w+\s*;)))|(procedure\s+[\w\s.]+((;)|(\([\w\s,.='':;$/*()]*?\)\s*;)))';
        Expression := '(function\s+[\w\s.]+(:\s*\w+\s*;))|(procedure\s+[\w\s.]+((;)))';
        bFound := Exec(CurrentSource.Text);
        while bFound do begin
              FunctionList.Add(Match[0]);
              bFound := ExecNext;
        end;
        finally free;
   end;*)

   //FunctionList.Clear;
   //CurrentSource.AddStrings(PSScript.Script);
end;

// ============================================================================

end.

