unit u_xpl_opc;

{$mode objfpc}{$H+}
{$M+}

interface

uses Classes,
     uxPLMessage,
     DeCAL,
     u_xpl_udp_socket,
     uxPLGlobals,
     uxPLDeterminators,
     uxPLListener,
     SysUtils;

type


{ TxPLOPC }

     TxPLOPC = class(TxPLListener)
     private
        fGlobalList : TxPLGlobalList;
        fDeterminatorList : TxPLDeterminatorList;
        fDataDirectory : string;
        //fDeviceList : DMap;
         Iter : DIterator;
        function Get_XHCP_VERSION: string;
     public
        constructor create(const aOwner: TComponent; const aAppVersion: string);
        destructor  destroy; override;
        procedure   HandleMessage(const aMessage : TxPLMessage);
     published
        property XHCP_Version : string read Get_XHCP_VERSION;
        property Determinators: TxPLDeterminatorList read fDeterminatorList;
        property Globals      : TxPLGlobalList       read fGlobalList;
        //property Devices      : DMap       read fDeviceList;
        procedure LISTDEVICES(const aListe : TStringList; const aRequested : string);
        procedure GETDEVCONFIG(const aListe : TStringList; const aRequested : string);
        procedure GETDEVCONFIGVALUE(const aListe : TStringList; const aDevice : string; const aConfItem : string);
     end;

implementation // =======================================================================
uses uxPLConst, uxPLMsgBody,uxPLSettings,cStrings,
     DateUtils, StrUtils;
const
     K_XHCP_VERSION = '0.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'opc';

{ TxPLOPC ===============================================================================}

function TxPLOPC.Get_XHCP_VERSION: string;
begin result := K_XHCP_VERSION; end;

constructor TxPLOPC.create(const aOwner: TComponent; const aAppVersion: string);
begin
   inherited Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,aAppVersion,False);
   PassMyOwnMessages := True;

  fDataDirectory := Settings.SharedConfigDir + K_DEFAULT_DEVICE + '/';
  TxPLSettings.EnsureDirectoryExists(fDataDirectory);

   fGlobalList := TxPLGlobalList.Create(fDataDirectory);
   fDeterminatorList := TxPLDeterminatorList.Create(Settings);
//   fDeviceList := DMap.Create;
//   fDevices := DMap.Create;

   OnxPLReceived := @HandleMessage;
end;

destructor TxPLOPC.destroy;
begin
   fDeterminatorList.Destroy;
   fGlobalList.Destroy;
//   fDevices.destroy;
//   fDeviceList.Destroy;
   inherited destroy;
end;

procedure TxPLOPC.HandleMessage(const aMessage: TxPLMessage);
//var devrec : TDeviceRecord;

procedure RecordSender;
begin
//   if AnsiIndexStr(aMessage.Schema.Tag,[K_SCHEMA_CONFIG_END,K_SCHEMA_HBEAT_END]) >= 0 then exit; // We won't record a quitting application
//   fDeviceList.PutPair([aMessage.Header.Source.Tag,TDeviceRecord.Create]);
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.vdi'            );
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.configmissing'  );
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.configsource'   );
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.current'        );
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.configlistsent' );
end;

function HandleHeartBeat : boolean;
var i : integer;
begin
   result := False;
   if not AnsiMatchStr(aMessage.Schema.Tag,[K_SCHEMA_HBEAT_APP,K_SCHEMA_CONFIG_APP]) then exit;
   i := StrToInt(aMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL));
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.expires'        ,DateTimeToStr(IncMinute(Now,2*i + 1)));
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.interval'       ,aMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL));
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.suspended'      ,'N');
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.configtype'     ,'N');
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.configdone'     ,'Y');
   fGlobalList.AddGlobal('device.'+aMessage.Header.Source.Tag + '.waitingconfig'  ,'N');
   Result := True;
end;

function HandleConfigNeeded : boolean;
var global : TxPLGlobalValue;
begin
   Result := False;
   if aMessage.Schema.Tag <> K_SCHEMA_CONFIG_APP then exit;

   Iter := fGlobalList.locate(['device.'+aMessage.Header.Source.Tag + '.configtype']);
   Global := GetObject(Iter) as TxPLGlobalValue;
   Global.SetValue('Y');

   Iter := fGlobalList.locate(['device.'+aMessage.Header.Source.Tag + '.configdone']);
   Global := GetObject(Iter) as TxPLGlobalValue;
   Global.SetValue('N');

   Iter := fGlobalList.locate(['device.'+aMessage.Header.Source.Tag + '.waitingconfig']);
   Global := GetObject(Iter) as TxPLGlobalValue;
   Global.SetValue('Y');

   SendConfigRequestMsg(aMessage.Header.Source.Tag);                                                 // First time I hear of it, I request its configuration
   Result := True;
end;

function HandleConfigMessage : boolean;
var i : integer;
    s,t : string;
//    tsl : tstringlist;
begin
   result := False;
   if not ((aMessage.Schema.Tag = K_SCHEMA_CONFIG_CURRENT) or (aMessage.Schema.Tag = K_SCHEMA_CONFIG_LIST) ) then exit;
//   tsl := tstringlist.create;
//   tsl.Add(aMessage.RawxPL);
   case AnsiIndexStr(aMessage.Schema.Tag, [K_SCHEMA_CONFIG_CURRENT,K_SCHEMA_CONFIG_LIST]) of

        0 : //fGlobalList.AddGlobal('config.'+aMessage.Header.Source.Tag + '.current',aMessage.Body.RawxPL);
//          tsl.SaveToFile(fDataDirectory + aMessage.Header.Source.Tag + '.current.xpl');
          aMessage.SaveToFile(fDataDirectory + aMessage.Header.Source.Tag + '.current.xpl');
//        begin
//          for i:=0 to aMessage.Body.Keys.Count-1 do begin
//              s := 'config.'+aMessage.Header.Source.Tag + '.current.' + aMessage.Body.Keys[i];
//              fGlobalList.AddGlobal(s,aMessage.Body.Values[i]);
//          end;
//        end;
        1 : aMessage.SaveToFile(fDataDirectory + aMessage.Header.Source.Tag + '.list.xpl');
        //;//fGlobalList.AddGlobal('config.'+aMessage.Header.Source.Tag + '.options',aMessage.Body.RawxPL);
//          tsl.SaveToFile(fDataDirectory + aMessage.Header.Source.Tag + '.options.xpl');
//        begin
//          for i:=0 to aMessage.Body.Keys.Count-1 do begin
//              s := StrBeforeChar(aMessage.Body.Values[i],'[');                                             // rip off any [xx] if present
//              s := 'config.'+aMessage.Header.Source.Tag + '.options.' + s;
//              fGlobalList.AddGlobal(s);
//              t := s + '.type';
//              fGlobalList.AddGlobal(t,aMessage.Body.Keys[i]);
//              t := s + '.count';
//              fGlobalList.AddGlobal(t,StrBetWeenChar(aMessage.Body.Values[i],'[',']'));
//          end;
//        end;
   end;
//   tsl.destroy;
   result := true;
end;

begin
   LogInfo('Received MSG from %s',[aMessage.Header.Source.Tag]);
   Iter := fGlobalList.locate([aMessage.Header.Source.Tag + '.vdi']);
   If atEnd(Iter) then begin
      RecordSender;
      Iter := fGlobalList.locate([aMessage.Header.Source.Tag]);
   end;
   if not HandleHeartBeat then
      if not HandleConfigNeeded then
         HandleConfigMessage;
end;

procedure TxPLOPC.LISTDEVICES(const aListe: TStringList; const aRequested : string);

begin
     fGlobalList.LISTDEVICES(aListe,aRequested);
end;

procedure TxPLOPC.GETDEVCONFIG(const aListe: TStringList; const aRequested: string);
var    Body1, Body2 : TxPLMsgBody;
       i,j : integer;
       chaine,retour : string;
       MsgCurrent, MsgList : TxPLMessage;
begin
   MsgCurrent := TxPLMessage.Create;
   MsgList    := TxPLMessage.Create;
   MsgCurrent.LoadFromFile(fDataDirectory + aRequested + '.current.xpl');
   MsgList.LoadFromFile(fDataDirectory + aRequested + '.list.xpl');
   for i := 0 to MsgCurrent.Body.ItemCount-1 do begin
      for j:= 0 to MsgList.Body.ItemCount-1 do begin
          if AnsiLeftStr(MsgList.Body.Values[j],Length(MsgCurrent.Body.Keys[i])) = MsgCurrent.Body.Keys[i] then begin
                         chaine := MsgList.Body.Keys[j];
                         retour := StrBetweenChar(MsgList.Body.Values[j],'[',']');
          end;
      end;
      aListe.Add(Format('%s'#9'%s'#9'%s',[MsgCurrent.Body.Keys[i],chaine,retour]));
   end;
   MsgList.Destroy;
   MsgCurrent.Destroy;
//   fGlobalList.GetDevConfig(aListe,aRequested);
{   Iter := Devices.locate([aRequested]);
   if not atEnd(Iter) then begin
      SetToValue(iter);
      with getObject(iter) as TDeviceRecord do begin
         Body1 := TxPLMsgBody.Create;
         Body2 := TxPLMsgBody.Create;
         Body1.RawxPL:=config_current;
         Body2.RawxPL:=config_list;
               for i := 0 to Body1.ItemCount-1 do begin
                   for j:=0 to Body2.ItemCount-1 do begin
                      if AnsiLeftStr(Body2.Values[j],Length(Body1.Keys[i])) = Body1.Keys[i] then begin
                         chaine := Body2.Keys[j];
                         retour := StrBetweenChar(Body2.Values[j],'[',']');
                      end;
                   end;
                   aListe.Add(Format('%s'#9'%s'#9'%s',[Body1.Keys[i],chaine,retour]));
               end;
         Body1.Destroy;
         Body2.Destroy;
      end;
   end;}
end;

procedure TxPLOPC.GETDEVCONFIGVALUE(const aListe : TStringList; const aDevice: string; const aConfItem: string);
var i : integer;
   Body1, Body2 : TxPLMsgBody;
   chaine : string;
begin
{   Iter := Devices.locate([aDevice]);
   if not atEnd(Iter) then begin
      SetToValue(iter);
      with getObject(iter) as TDeviceRecord do begin
         Body1 := TxPLMsgBody.Create;
         chaine := config_current;
         Body1.RawxPL:=config_current;
         for i:=0 to Body1.Keys.Count-1 do begin
             if ((Body1.Values[i]<>'') and (Body1.Keys[i]=aConfItem)) then aListe.Add(aConfItem + '=' + Body1.Values[i]);
         end;
         Body1.Destroy;
      end;
   end;}
end;

end.

