unit dawndusk_listener;

{$i xpl.inc}
{ $ M+}

interface

uses Classes
     , SysUtils
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_schema
     , u_xpl_message
     , u_xpl_messages
     , SunTime
     , fpc_delphi_compat
     ;

type // TxPLDawnDuskListener ==================================================
     TxPLDawnDuskListener = class(TxPLCustomListener)
     private
        fSunTime  : TSuntime;
        fOffSet   : integer;
        fWhatNext : TDawnDuskStatusType;
        fWhenNext : TDateTime;
        fTimer    : TxPLTimer;

     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);
        procedure   OnTimer({%H-}aSender : TObject);
        procedure   OnJoined;

     published
        property    SunTime : TSunTime read fSunTime;
        property    WhatNext: TDawnDuskStatusType read fWhatNext;
        property    WhenNext: TDateTime     read fWhenNext;
     end;

implementation // =============================================================
uses DateUtils
     , u_xpl_common
     , u_xpl_heart_beater
     , u_xpl_application
     , TypInfo
     ;
const //=======================================================================
     K_CONFIG_LATITUDE  = 'latitude';
     K_CONFIG_LONGITUDE = 'longitude';
     K_CONFIG_OFFSET    = 'offset';

// TxPLDawnDuskListener =======================================================
constructor TxPLDawnDuskListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.Add('xpl-cmnd.*.*.*.dawndusk.request');
   Config.DefineItem(K_CONFIG_LATITUDE, TxPLConfigItemType.config,1,'49');     // This could be decimal but I found a bug on Win2003 that
   Config.DefineItem(K_CONFIG_LONGITUDE,TxPLConfigItemType.config,1,'1');      // stops the app launching with error if a decimal value is here
   Config.DefineItem(K_CONFIG_OFFSET,TxPLConfigItemType.reconf,1,'-15');

   fSuntime := TSuntime.Create(self);
   OnxPLJoinedNet := @OnJoined;
end;

procedure TxPLDawnDuskListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     fSuntime.Latitude.Value  := StrToFloat(Config.GetItemValue(K_CONFIG_LATITUDE));
     fSuntime.Longitude.Value := StrToFloat(Config.GetItemValue(K_CONFIG_LONGITUDE));
     fOffSet                  := StrToInt  (Config.GetItemValue(K_CONFIG_OFFSET));
     fWhenNext := 0;

     OnxPLReceived := @Process;
  end else OnxPLReceived := nil;
end;

procedure TxPLDawnDuskListener.OnJoined;
begin
   if ConnectionStatus = connected then begin
      if not Assigned(fTimer) then
         fTimer := xPLApplication.TimerPool.Add(0,@OnTimer);
      OnTimer(self);
   end;
end;

procedure TxPLDawnDuskListener.OnTimer(aSender: TObject);
var //s : string;
    Status : TDawnDuskBasicTrig;
begin
   if fWhenNext<>0 then begin                                                  // Already initialized (called by the timer itself) then I must emit a message
//      s := GetEnumName(TypeInfo(TDawnDuskStatusType),Ord(fWhatNext));
      Status := TDawnDuskBasicTrig.Create(self);
      Status.Status := fWhatNext;
      Status.Body.SetValueByKey('offset',IntToStr(fOffSet));
      Self.Send(Status);
//      SendMessage( trig,'*',Schema_DDBasic,
//                             ['type','status','offset'],
//                             ['dawndusk', s ,IntToStr(fOffSet)]);
      Status.Free;
   end;

   fSunTime.Date := now;

   if IncMinute(fSunTime.Sunrise,fOffset) > now then fWhatNext := Dawn else
      if IncMinute(fSunTime.Noon,fOffset) > now then fWhatNext := Noon else
         if IncMinute(fSunTime.Sunset,fOffSet) > now then fWhatNext := Dusk else begin
            fSunTime.Date := IncDay(fSunTime.Date);
            fWhatNext := Dawn;
         end;

//   s := ;
   fTimer.Enabled := false;
   fWhenNext := IncMinute(fSunTime.GetSunTime(Ord(fWhatNext)),fOffSet);

   fTimer.Interval := MilliSecondsBetween(now,fWhenNext);
   Log(etInfo,'Next event is ' + GetEnumName(TypeInfo(TDawnDuskStatusType),Ord(fWhatNext)) +' at ' + DateTimeToStr(fWhenNext) + ' in ' + FloatToStr((fTimer.Interval / 1000)) + ' sec');
   fTimer.Enabled := True;
end;

procedure TxPLDawnDuskListener.Process(const aMessage: TxPLMessage);
var previous : TDawnDuskStatusType;
    level, delta, lag : longint;
    query : string;
    Answer : TDawnDuskBasicStat;
begin
   if aMessage is TDawnDuskReq then begin
      query := TDawnDuskReq(aMessage).Query;
      Answer := TDawnDuskBasicStat.Create(self);

      if query ='daynight' then
         if fWhatNext = Dawn then
            Answer.Status := night
         else
            Answer.Status := day
      else begin
           if fWhatNext = dusk then previous := noon;
           if fWhatNext = dawn then previous := dusk;
           if fWhatNext = noon then previous := dawn;
           Answer.Body.SetValueByKey('status',GetEnumName(TypeInfo(TDawnDuskStatusType),Ord(Previous)));
           Answer.Body.SetValueByKey('dawn',DateTime2XPLDt(fSuntime.GetSuntime(Ord(dawn))));
           Answer.Body.SetValueByKey('noon',DateTime2XPLDt(fSuntime.GetSuntime(Ord(noon))));
           Answer.Body.SetValueByKey('dusk',DateTime2XPLDt(fSuntime.GetSuntime(Ord(dusk))));
      end;

      level := 0;
      if fWhatNext<>Dawn then begin                                            // It is useless to compute level if we're at night :-)
         fSunTime.Date := Now;
         delta := MinutesBetween(Now,fSunTime.Noon);
         lag := MinutesBetween(fSunTime.Sunrise,fSunTime.Noon);
         level := Round(6/lag * (lag-delta));
      end;

      Answer.Body.AddKeyValuePairs(['level'],[IntToStr(level)]);
      Send(Answer);
      Answer.Free;
   end;
end;

end.
