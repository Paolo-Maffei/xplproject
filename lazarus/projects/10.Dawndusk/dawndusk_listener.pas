unit dawndusk_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_web_listener
     , u_xpl_config
     , u_xpl_actionlist
     , u_xpl_schema
     , fpTimer
     , u_xpl_message
     , SunTime
     ;

type

{ TxPLDawnDuskListener }
     TSunEventType = (dawn, dusk, noon);

     TxPLDawnDuskListener = class(TxPLWebListener)
     private
        fSunTime   : TSuntime;
        fOffSet    : integer;
        fWhatNext   : TSunEventType;
        fWhenNext   : TDateTime;
        fTimer     : TfpTimer;

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        //procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);
        procedure   OnTimer(aSender : TObject);
        procedure   OnJoined;
     published
        property    SunTime : TSunTime read fSunTime;
        property    WhatNext: TSunEventType read fWhatNext;
        property    WhenNext: TDateTime     read fWhenNext;
     end;

var  Schema_DDBasic : TxPLSchema;

implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_custom_listener
     , u_xpl_body
     , TypInfo
     , StrUtils
     , DateUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;
const //======================================================================================
     K_CONFIG_LATITUDE  = 'latitude';
     K_CONFIG_LONGITUDE = 'longitude';
     K_CONFIG_OFFSET    = 'offset';

// ===========================================================================================
{ TxPLDawnDuskListener }

constructor TxPLDawnDuskListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   FilterSet.AddValues(['xpl-cmnd.*.*.*.dawndusk.request']);
   Config.DefineItem(K_CONFIG_LATITUDE, TxPLConfigItemType.config,1,'49,4133379');
   Config.DefineItem(K_CONFIG_LONGITUDE,TxPLConfigItemType.config,1,'1,0344627');
   Config.DefineItem(K_CONFIG_OFFSET,TxPLConfigItemType.reconf,1,'-15');

   fSuntime := TSuntime.Create(self);
   fTimer   := TfpTimer.Create(self);
   fTimer.OnTimer := @OnTimer;
   OnxPLJoinedNet := @OnJoined;
end;

//procedure TxPLDawnDuskListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
//begin
//   if CompareText(AClassName, 'TxPLDawnDuskListener') = 0 then ComponentClass := TxplDawnDuskListener
//   else inherited;
//end;

procedure TxPLDawnDuskListener.UpdateConfig;
var found : boolean;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     fSuntime.Latitude.Value  := StrToFloat(Config.GetItemValue(K_CONFIG_LATITUDE));
     fSuntime.Longitude.Value := StrToFloat(Config.GetItemValue(K_CONFIG_LONGITUDE));
     fOffSet                  := StrToInt(Config.GetItemValue(K_CONFIG_OFFSET));
     fWhenNext := 0;

     OnxPLReceived := @Process;
  end else OnxPLReceived := nil;
end;

procedure TxPLDawnDuskListener.OnTimer(aSender: TObject);
var s : string;
begin
   if fWhenNext<>0 then begin                                                   // Already initialized (called by the timer itself) then I must emit a message
      s := GetEnumName(TypeInfo(TSunEventType),Ord(fWhatNext));
      SendMessage( trig,'*',Schema_DDBasic,
                             ['type','status','offset'],
                             ['dawndusk', s ,IntToStr(fOffSet)]);
   end;

   fSunTime.Date := now;
   if IncMinute(fSunTime.Sunrise,fOffset) > now then fWhatNext := Dawn else
      if IncMinute(fSunTime.Noon,fOffset) > now then fWhatNext := Noon else
         if IncMinute(fSunTime.Sunset,fOffSet) > now then fWhatNext := Dusk else begin
            fSunTime.Date := IncDay(fSunTime.Date);
            fWhatNext := Dawn;
         end;

   s := GetEnumName(TypeInfo(TSunEventType),Ord(fWhatNext));
   fTimer.Enabled := false;
   fWhenNext := IncMinute(fSunTime.GetSunTime(Ord(fWhatNext)),fOffSet);

   fTimer.Interval := MilliSecondsBetween(now,fWhenNext);
   Log(etInfo,'Next event is ' + s +' at ' + DateTimeToStr(fWhenNext) + ' in ' + FloatToStr((fTimer.Interval / 1000)) + ' sec');
   fTimer.Enabled := True;
end;

procedure TxPLDawnDuskListener.OnJoined;
begin
   if ConnectionStatus = connected then OnTimer(self);
end;

procedure TxPLDawnDuskListener.Process(const aMessage: TxPLMessage);
var previous : TSunEventType;
    level, delta, lag : longint;
    status,query : string;
begin
   if aMessage.Schema.RawxPL = 'dawndusk.request' then begin
      query := aMessage.Body.GetValueByKey('query','dawndusk');

      if query ='daynight' then
         Status := IfThen(fWhatNext = Dawn, 'night','day')
      else begin
           if fWhatNext = dusk then previous := noon;
           if fWhatNext = dawn then previous := dusk;
           if fWhatNext = noon then previous := dawn;
           Status := GetEnumName(TypeInfo(TSunEventType),Ord(Previous))
      end;

      level := 0;
      if fWhatNext<>Dawn then begin                                                // It is useless to compute level if we're at night :-)
         fSunTime.Date := Now;
         delta := MinutesBetween(Now,fSunTime.Noon);
         lag := MinutesBetween(fSunTime.Sunrise,fSunTime.Noon);
         level := Round(6/lag * (lag-delta));
      end;

      SendMessage( stat,'*',Schema_DDBasic,
                             [ 'type',  'status', 'level'],
                             [ query,   status,   IntToStr(level)]);
   end;
end;

initialization
   Schema_DDBasic := TxPLSchema.Create('dawndusk.basic');

end.

