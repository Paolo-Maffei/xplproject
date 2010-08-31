unit u_xpl_opc;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, uxPLMessage, DeCAL, cStrings,
     uxPLGlobals,uxPLDeterminators,uxPLDevices,uxPLListener;

type


{ TxPLOPC }

     TxPLOPC = class(TxPLListener)
     private
        fGlobalList : TxPLGlobalList;
        fDeterminatorList : TxPLDeterminatorList;
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
uses uxPLConst, uxPLMsgBody,
     DateUtils, StrUtils;
const
     K_XHCP_VERSION = '1.5';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'opc';

{ TxPLOPC ===============================================================================}

function TxPLOPC.Get_XHCP_VERSION: string;
begin result := K_XHCP_VERSION; end;

constructor TxPLOPC.create(const aOwner: TComponent; const aAppVersion: string);
begin
   inherited Create(aOwner,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,aAppVersion,False);
   PassMyOwnMessages := True;

   fGlobalList := TxPLGlobalList.Create(Settings);
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
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.vdi'            ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.vdi',aMessage.Header.Source.Tag)]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.configmissing'  ,TxPLGlobalValue.Create('device.'+aMessage.Header.Source.Tag + '.configmissing')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.configsource'   ,TxPLGlobalValue.Create('device.'+aMessage.Header.Source.Tag + '.configsource')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.current'        ,TxPLGlobalValue.Create('device.'+aMessage.Header.Source.Tag + '.current')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.configlistsent' ,TxPLGlobalValue.Create('device.'+aMessage.Header.Source.Tag + '.configlistsent')]);
end;

function HandleHeartBeat : boolean;
var i : integer;
begin
   result := False;
   if aMessage.Schema.Tag <> K_SCHEMA_HBEAT_APP then exit;
   i := StrToInt(aMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL));
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.expires'        ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.expires',DateTimeToStr(IncMinute(Now,2*i + 1)))]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.interval'       ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.interval',aMessage.Body.GetValueByKey(K_HBEAT_ME_INTERVAL))]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.suspended'      ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.suspended','N')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.configtype'     ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.configtype','N')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.configdone'     ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.configdone','Y')]);
   fGlobalList.putPair(['device.'+aMessage.Header.Source.Tag + '.waitingconfig'  ,TxPLGlobalValue.CreateEx('device.'+aMessage.Header.Source.Tag + '.waitingconfig','N')]);
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
begin
   result := False;
   if not ((aMessage.Schema.Tag = K_SCHEMA_CONFIG_CURRENT) or (aMessage.Schema.Tag = K_SCHEMA_CONFIG_LIST) ) then exit;
   case AnsiIndexStr(aMessage.Schema.Tag, [K_SCHEMA_CONFIG_CURRENT,K_SCHEMA_CONFIG_LIST]) of
        0 : begin
          for i:=0 to aMessage.Body.Keys.Count-1 do begin
              s := 'config.'+aMessage.Header.Source.Tag + '.current.' + aMessage.Body.Keys[i];
              fGlobalList.putPair([s,TxPLGlobalValue.CreateEx(s,aMessage.Body.Values[i])]);
          end;
        end;
        1 : begin
          for i:=0 to aMessage.Body.Keys.Count-1 do begin
              s := 'config.'+aMessage.Header.Source.Tag + '.options.' + aMessage.Body.Values[i];
              fGlobalList.putPair([s,TxPLGlobalValue.Create(s)]);
              t := s + '.type';
              fGlobalList.putPair([t,TxPLGlobalValue.CreateEx(t, aMessage.Body.Keys[i])]);
              t := s + '.count';
              fGlobalList.putPair([t,TxPLGlobalValue.CreateEx(t, StrBetWeenChar(aMessage.Body.Values[i],'[',']'))]);
          end;
        end;
   end;
   result := true;
end;

begin
   LogInfo('Received MSG from %s',[aMessage.Header.Source.Tag]);
   Iter := fGlobalList.locate([aMessage.Header.Source.Tag + '.vdi']);
   If atEnd(Iter) then begin
      RecordSender;
      Iter := fGlobalList.locate([aMessage.Header.Source.Tag]);
   end;
//   devrec = GetObject(iter) as TDeviceRecord;
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
begin
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

