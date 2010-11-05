unit uxPLEvent;

{==============================================================================
  UnitName      = uxPLEvent
  UnitDesc      = xPL timer management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.90 : Initial version
 0.91 : Modification to stick to timer.basic schema as described in xpl website
}

interface

uses Controls, ExtCtrls, Classes, XMLCfg, uxPLMessage, SunTime,
     uxPLAddress, ComCtrls, uxPLListener, MOON;

type

  { TxPLEvent }

  TxPLEvent = class(TComponent)
  protected
      fName          : string;
      fEventType     : string;
      fEnabled       : boolean;
      fNextExecution : TDateTime;

  public
      constructor Create(const aName : string; const aEnabled : boolean; const aNext : TDateTime);
      function  WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string) : boolean; virtual;
      procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); virtual; abstract;

      function    Edit  : boolean;                 virtual; abstract;
      procedure   Check(bAndFire : boolean =true); virtual;
      procedure   Fire;                            virtual; abstract;
      function    Over  : boolean;
      function    EnabledAsString : string;
  published
      property Name : string read fName write fName;
      property Next : TDateTime read fNextExecution write fNextExecution;
      property Enabled : boolean read fEnabled      write fEnabled;
      property TypeAsString  : string read fEventType;
  end;

  { TxPLEventList }

  TxPLEventList = class(TStringList)
  private
     aMessage  : TxPLMessage;
     fGrid : TListView;
     fSysTimer : TTimer;
     function GetEvent(Index : integer): TxPLEvent;
  public
     constructor Create(const aClient : TxPLListener; const aGrid : TListView);
     destructor  Destroy; override;

     procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string);
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string);
     procedure Check(Sender: TObject);
     procedure ToGrid(const anItem : integer);

     function Add(const S: string; const anEvent : TxPLEvent): Integer; overload;
     procedure Delete(aEvent : TxPLEvent); overload;
     procedure Delete(Index: Integer); override;

     property Events[Index : integer] : TxPLEvent read GetEvent;
  end;

    TxPLSunEventType = (setDawn, setDusk, setNoon);
  TxPLSunEvent = class(TxPLEvent)
  private
     fSunEventType : TxPLSunEventType;
     fSunTime      : TSunTime;
     fMessage      : TxPLMessage;
     //fSubject      : ^TDateTime;
  public
     constructor Create(const aSource : TxPLAddress; const aSunTime : TSunTime; const aType : TxPLSunEventType);
     destructor  Destroy; override;
     function    Edit  : boolean;                    override;
     procedure   Check(bAndFire : boolean =true);    override;
     procedure   Fire;                               override;

     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); override;
  end;

  { TxPLSeasonEvent }

  TxPLSeasonEvent = class(TxPLEvent)
  private
     fType : TSeason;
     function GetNextOccurence : TDateTime;
  public
     constructor Create(const type_ : TSeason);
     function Edit : boolean; override;
     procedure Check(bAndFire : boolean =true);    override;
     procedure   Fire;                             override;
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); override;
  end;


  { TxPLSingleEvent }

  TxPLSingleEvent = class(TxPLEvent)
  protected

     fSingleEvent   : boolean;
     fxPLMessage    : TxPLMessage;
     fMessageToFire : string;
     fDescription   : widestring;


  public
     constructor Create(const aMsg : TxPLMessage);
     constructor Create(const aMsg : TxPLMessage; const aName: string; const bEnabled : boolean; const dtNext : TDateTime);

     function  WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string) : boolean; override;
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); override;

     function    Edit  : boolean;                 override;
     procedure   Fire;                            override;

  published
     property MessageToFire : string read fMessageToFire write fMessageToFire;
     property IsSingleEvent : boolean read fSingleEvent;

     property Description   : widestring read fDescription write fDescription;
  end;

    TxPLEventRecurrenceType = ( er_Daily, er_Weekly, er_Monthly);

  { TxPLEventList }

  { TxPLRecurEvent }
  TxPLRecurEvent = class(TxPLSingleEvent)
  protected
     fRecurrenceType : TxPLEventRecurrenceType;
     fStartInDay    : TTime;
     fStopInDay     : TTime;
     fRandom        : integer;           // In seconds
     fInterval      : integer;           // In seconds
     fDayRecurrence : integer;
     fWeekMap       : string;            // Something like : 111111

     function  GetRecurrence : string;
     procedure SetRecurrence (const aRecurr: string);

  public
     constructor Create(const aMsg : TxPLMessage);
     property RecurrenceAsString : string read Getrecurrence write SetRecurrence;
     property StartInDay     : TTime   read fStartInDay write fStartInDay;
     property StopInDay      : TTime   read fStopInDay write fStopInDay;
     property DayRecurrence  : integer read fDayRecurrence write fDayRecurrence;
     property Random         : integer read fRandom write fRandom;
     property Interval       : integer read fInterval write fInterval;
     property RecurrenceType : TxPLEventRecurrenceType read fRecurrenceType write fRecurrenceType;
     property WeekMap        : string read fWeekMap write fWeekMap;

     function WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string) : boolean; override;
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); override;
     function    Edit : boolean;                  override;
     procedure   Check(bAndFire : boolean =true); override;
  end;

implementation //========================================================================
uses SysUtils, uxPLConst,  strUtils, frm_xPLRecurEvent, app_main,
     frm_xPLSingleEvent,  DateUtils, cRandom;

{ TxPLEvent =============================================================================}
constructor TxPLEvent.Create(const aName: string; const aEnabled: boolean; const aNext: TDateTime);
begin
   inherited Create(nil);
   fName          := aName;
   fEnabled       := aEnabled;
   fNextExecution := aNext;
end;

function TxPLEvent.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string): boolean;
begin result :=  false; end;

procedure TxPLEvent.Check(bAndFire: boolean);
begin
   if not (Over and Enabled) then exit;

   Enabled := false;
   if bAndFire then Fire;
end;

function TxPLEvent.Over: boolean;
begin result := (next <= now()); end;

function TxPLEvent.EnabledAsString: string;
begin Result := Ifthen(Enabled,'Yes','No'); end;

function TxPLEventList.GetEvent(Index : integer): TxPLEvent;
begin result := TxPLEvent(Objects[Index]); end;

{ TxPLEventList ========================================================================}
constructor TxPLEventList.Create(const aClient : TxPLListener; const aGrid : TListView);
begin
   inherited Create;
   fSysTimer := TTimer.Create(nil);
   fSysTimer.Interval := 1000;
   fSysTimer.Enabled  := False;
   fSysTimer.OnTimer  := @Check;
//   aMessage := aClient.PrepareMessage(K_MSG_TYPE_CMND,'control.basic');
   aMessage := TxPLMessage.Create;
   aMessage.MessageType:= K_MSG_TYPE_CMND;
   aMessage.Schema.Tag := K_SCHEMA_TIMER_BASIC;
   aMessage.Target.IsGeneric:=true;
   fGrid := aGrid;
end;

destructor TxPLEventList.Destroy;
begin
   aMessage.Destroy;
   inherited;
end;

procedure TxPLEventList.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string);
var i, evCount : integer;
begin
   evCount := 0;
   for i:=0 to Count -1 do
      if Events[i].WriteToXML(aCfgFile, aRootPath + '/Event_' + intToStr(evCount)) then inc(evCount);
   aCfgfile.SetValue(aRootPath + '/EventCount', intToStr(evCount));
end;

procedure TxPLEventList.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
var i : integer;
    anEvent : TxPLSingleEvent;
    aRecur  : TxPLRecurEvent;
begin
   self.Clear;

   i := StrToInt(aCfgfile.GetValue(aRootPath + '/EventCount','0')) -1;
   while i>=0 do begin
      anEvent := TxPLSingleEvent.Create(aMessage);
      anEvent.ReadFromXML(aCfgfile, aRootPath + '/Event_' + intToStr(i));
      if anEvent.IsSingleEvent then
         if anEvent.Over then
            anEvent.Destroy
         else
            Objects[Add(anEvent.Name)] := anEvent
      else begin
         anEvent.Destroy;
         aRecur := TXPLRecurEvent.Create(aMessage);
         aRecur.ReadFromXML(aCfgfile, aRootPath + '/Event_' + intToStr(i));
         Objects[Add(aRecur.Name)] := aRecur;
      end;
      dec(i);
   end;
end;

procedure TxPLEventList.ToGrid(const anItem : integer);
var item    : tListItem;
    anEvent : TxPLSingleEvent;
begin
   if fGrid.items.Count<=anItem then begin
      item := fGrid.Items.Add ;
      item.SubItems.Add(''); // Name
      item.SubItems.Add(''); // Type
      item.SubItems.Add(''); // Next Runing time
   end
      else item := fGrid.Items[anItem];

    anEvent := TxPLSingleEvent(Objects[anItem]);
    item.Caption := anEvent.Name;
    item.SubItems[0] := anEvent.TypeAsString;
    item.SubItems[1] := DateTimeToStr(anEvent.Next);
    item.SubItems[2] := anEvent.EnabledAsString;
    item.Data := anEvent;
end;

function TxPLEventList.Add(const S: string; const anEvent : TxPLEvent): Integer;
begin
   if IndexOf(s)=-1 then begin
      Result:=inherited Add(S);
      Objects[Result] := anEvent;
   end else Result := -1;
   fSysTimer.Enabled := (Count>0);
end;

procedure TxPLEventList.Delete(aEvent: TxPLEvent);
var itemnum : integer;
begin
   itemnum := IndexOf(aEvent.name);
   if itemnum=-1 then exit;

   Delete(itemnum);
end;

procedure TxPLEventList.Delete(Index: Integer);
begin
   inherited Delete(Index);
   fSysTimer.Enabled := (Count>0);
   fGrid.Items[index].Delete ;
end;


procedure TxPLEventList.Check(Sender: TObject);
var i : integer;
    aGenericEvent : TxPLEvent;
begin
   i := Count-1;
   repeat
      aGenericEvent := Events[i];
      aGenericEvent.Check;
      if aGenericEvent.Over then Delete(i) else ToGrid(i);
      dec(i);
   until ((i<0) or (count=0));
end;

{ TxPLSingleEvent ========================================================================}
constructor TxPLSingleEvent.Create(const aMsg : TxPLMessage; const aName: string; const bEnabled : boolean; const dtNext : TDateTime);
begin
   inherited Create(aName, bEnabled, dtNext);
   fSingleEvent   := True;
   fEventType     := 'Single';
   fxPLMessage    := aMsg;
   fDescription   := '';
end;

constructor TxPLSeasonEvent.Create(const type_ : TSeason);
var sName : string;
begin
   fType := type_;
   case fType of
        Winter : sName := 'winter';
        Autumn : sName := 'autumn';
        Spring : sName := 'spring';
        Summer : sName := 'summer';
   end;

   inherited Create(sName, true, GetNextOccurence);
   fEventType     := 'season';
end;

function TxPLSeasonEvent.Edit: boolean;
begin
  result := false;
end;

procedure TxPLSeasonEvent.Check(bAndFire: boolean);
begin
   inherited Check(bAndFire);
   if not fEnabled then begin                      // I've just been fired
      fEnabled := true;
      fNextExecution := GetNextOccurence;
   end;
end;

procedure TxPLSeasonEvent.Fire;
begin
   xPLClient.SendMessage(K_MSG_TYPE_TRIG, K_MSG_TARGET_ANY, K_SCHEMA_TIMER_BASIC,['season'],[Name]);
end;

procedure TxPLSeasonEvent.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin { DO NOTHING } end;

function TxPLSeasonEvent.GetNextOccurence : TDateTime;
var myYear, myMonth, myDay : Word;
begin
   DecodeDate(now, myYear, myMonth, myDay);
   result := StartSeason(myYear, fType);
   if result < now then begin
      inc(myYear);
      result := StartSeason(myYear, fType);
   end;
end;

constructor TxPLSingleEvent.Create(const aMsg : TxPLMessage);
begin
   Create(aMsg, '', true, now);
end;

function TxPLSingleEvent.Edit: boolean;
var aForm : TfrmxPLSingleEvent;
begin
     aForm := TfrmxPLSingleEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     aForm.Destroy;
end;

procedure TxPLSingleEvent.Fire;
var aMessage : TxPLMessage;
begin
     if MessageToFire='' then with fxPLMessage do begin
         MessageType := K_MSG_TYPE_TRIG;
         Target.IsGeneric := True;
         Body.ResetValues;
         Body.AddKeyValuePairs(['device','current'],[fName,'fired']);
//         Format_SensorBasic(fName,'generic','fired');
         Schema.Tag := K_SCHEMA_TIMER_BASIC;
         xPLClient.Send(fxPLMessage);
     end else begin
         aMessage:=TxPLMessage.Create(MessageToFire);
         aMessage.Source.Assign(fxPLMessage.Source);
         xPLClient.Send(aMessage);
         aMessage.Destroy ;
     end;
end;

function TxPLSingleEvent.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string) : boolean;
begin
   aCfgFile.SetValue(aRootPath + '/Name'     , Name);
   aCfgFile.SetValue(aRootPath + '/Next'     , DateTimeToStr(Next));
   aCfgFile.SetValue(aRootPath + '/Enabled'  , Enabled);
   aCfgFile.SetValue(aRootPath + '/IsSingle' , IsSingleEvent);
   aCfgFile.SetValue(aRootPath + '/MsgToFire' , fMessageToFire);
   aCfgFile.SetValue(aRootPath + '/Description' , fDescription);

   result := true;
end;

procedure TxPLSingleEvent.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   Name         := aCfgFile.GetValue(aRootPath + '/Name', '');
   Next         := StrToDateTime(aCfgFile.GetValue(aRootPath + '/Next', ''));
   Enabled      := aCfgFile.GetValue(aRootPath + '/Enabled', false);
   fSingleEvent := aCfgFile.GetValue(aRootPath + '/IsSingle', true);
   fMessageToFire := aCfgFile.GetValue(aRootPath + '/MsgToFire', '');
   fDescription := aCfgFile.GetValue(aRootPath + '/Description', '');
   Check(false);                                                                          // This is done to recalc the event when loaded without firing it
end;

{ TxPLSunEvent ========================================================================}
procedure TxPLSunEvent.Check(bAndFire : boolean =true);
begin
   inherited Check(bAndFire);
   fEnabled := true;
   fSuntime.Date := now;
  if fSuntime.GetSunTime(ord(fSunEventType)) < now then fSuntime.date := now+1;
  fNextExecution:= fSuntime.GetSuntime(ord(fSunEventType));

{   case fSunEventType of
     setDawn : begin
                  if fSuntime.sunrise<now then fSuntime.date := now + 1;
                  fNextExecution := fSuntime.sunrise;
               end;
     setDusk : begin
                  if fSuntime.sunset<now then fSuntime.date := now + 1;
                  fNextExecution := fSuntime.sunset;
               end;
     setNoon : begin
                  if fSuntime.noon<now then fSuntime.date := now + 1;
                  fNextExecution := fSuntime.noon;
               end;

  end;}
end;

procedure TxPLSunEvent.Fire;
begin
   xPLClient.Send(fMessage);
end;

procedure TxPLSunEvent.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin { DO NOTHING } end;

constructor TxPLSunEvent.Create(const aSource : TxPLAddress; const aSunTime : TSunTime; const aType : TxPLSunEventType);
var aName : string;
    aNext : TDateTime;
begin
  fSunEventType := aType;
  fSuntime   := aSunTime;
  fSuntime.date := now;
  fEventType    := 'dawndusk';

  if fSuntime.GetSunTime(ord(fSunEventType)) < now then fSuntime.date := now+1;
  aNext := fSuntime.GetSuntime(ord(fSunEventType));

  case fSunEventType of
     setDawn : begin
                  aName := 'dawn';
//                  if fSuntime.sunrise<now then fSuntime.date := now + 1;
//                  aNext := fSuntime.sunrise;
               end;
     setDusk : begin
                  aName := 'dusk';
//                  if fSuntime.sunset<now then fSuntime.date := now + 1;
//                  aNext := fSuntime.sunset;
               end;
     setNoon : begin
                  aName := 'noon';
//                  if fSuntime.noon<now then fSuntime.date := now + 1;
//                  aNext := fSuntime.noon;
               end;
  end;
  fMessage := TxPLMessage.Create;
  fMessage.Source.Assign(aSource);
  fMessage.MessageType := K_MSG_TYPE_TRIG;
  fMessage.Target.Tag  := '*';
  fMessage.Schema.Tag  := K_SCHEMA_DAWNDUSK_BASIC;
  fMessage.Body.AddKeyValuePairs(['status','type'],[aName,fEventType]);
//  fMessage.Body.AddKeyValuePair('type',fEventType);
  inherited Create(aName,True,aNext);
end;

destructor TxPLSunEvent.Destroy;
begin
   fMessage.Destroy;
   inherited;
end;

function TxPLSunEvent.Edit: boolean;
begin result := false; end;                                                               // No edition possible on it

constructor TxPLRecurEvent.Create(const aMsg : TxPLMessage);
begin
     inherited Create(aMsg);
     fRecurrenceType := er_Daily;
     fStartInDay := now;
     fStopInDay  := IncMinute(fStartInDay,60);
     fRandom     := 0;
     fInterval   := 60;
     fDayRecurrence := 1;
     fSingleEvent:= false;                                                                // this is a recurrent event
     fEventType  := 'Recurrent';
     fWeekMap    := '1111111';
     Next := 0;
end;

function TxPLRecurEvent.Edit: boolean;
var aForm : TfrmxPLRecurEvent;
begin
     aForm := TfrmxPLRecurEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     if result then begin
        Next := 0;                                                                        // FS#27 Reset next run time to force recompute
        Check(false);                                                                     // FS#29 False added to avoid launch of the event when creating it
     end;
     aForm.Destroy;
end;

procedure TxPLRecurEvent.Check(bAndFire : boolean =true);
function GetRandomDelta : integer;
begin
     if RandomBoolean then result := -1 * RandomInt64(fRandom)
                      else result := 1  * RandomInt64(fRandom);
end;
var aTime : TDateTime;
    dow, delta : integer;
begin
   if (not Enabled) or (Next > Now) then exit;

   case fRecurrenceType of
      er_Daily   : begin
         aTime := fStartInDay;                                                  // Compute target event time
         if aTime < Now then aTime := Now;

         aTime := IncSecond(aTime,fInterval + GetRandomDelta);

         if aTime > fStopInDay then begin                                       // If the target is not in the window then report it on next
            ReplaceDate(aTime,IncDay(aTime,fDayRecurrence));                    // possible day
            ReplaceTime(aTime,fStartInDay);
            aTime := IncSecond(aTime,fInterval + GetRandomDelta);               // Correction of bug FS#20
         end;
      end;
      er_Weekly  : begin
         aTime := Now;
         ReplaceTime(aTime,fStartInDay);
         aTime := IncSecond(aTime,GetRandomDelta);                              // Enhancement FS#23
         Delta := 0;
         if aTime < Now then begin                                              // if passed then shift it
            repeat                                                              // seek next appliable day;
               inc(delta);
               Dow := DayOfTheWeek(IncDay(aTime,delta));
               if Dow = 1 then delta := delta + (fDayRecurrence-1)*7;
            until fWeekMap[Dow] = '1';
            aTime := IncDay(aTime,delta);
         end else begin
             Dow := DayOfTheWeek(aTime);
             if fWeekMap[Dow] ='0' then begin                                   // if today is not appliable then shift it
                repeat                                                             // seek next appliable day;
                   inc(delta);
                   Dow := DayOfTheWeek(IncDay(aTime,delta));
                   if Dow = 1 then delta := delta + (fDayRecurrence-1)*7;
                until fWeekMap[Dow] = '1';
                aTime := IncDay(aTime,delta);
             end;
         end;
      end;
      er_Monthly : begin
      end;
   end;
   Next := aTime;
   if bAndFire then Fire;
end;

function TxPLRecurEvent.GetRecurrence : string;
begin
   case fRecurrenceType of
        er_Daily   : result := 'Daily';
        er_Weekly  : result := 'Weekly';
        er_Monthly : result := 'Monthly';
   end;
end;

procedure TxPLRecurEvent.SetRecurrence(const aRecurr: string);
begin
   fRecurrenceType := er_Daily;
   if aRecurr = 'Monthly' then fRecurrenceType := er_Monthly;
   if aRecurr = 'Weekly' then fRecurrenceType := er_Weekly;
end;


function TxPLRecurEvent.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string) : boolean;
begin
  inherited WriteToXML(aCfgfile, aRootPath);
  aCfgFile.SetValue(aRootPath + '/Recurrence'    , RecurrenceAsString);
  aCfgFile.SetValue(aRootPath + '/StartInDay'    , DateTimeToStr(fStartInDay));
  aCfgFile.SetValue(aRootPath + '/StopInDay'     , DateTimeToStr(fStopInDay));
  aCfgFile.SetValue(aRootPath + '/Random'        , fRandom);
  aCfgFile.SetValue(aRootPath + '/Interval'      , fInterval);
  aCfgFile.SetValue(aRootPath + '/DayRecurrence' , fDayRecurrence);
  aCfgFile.SetValue(aRootPath + '/WeekMap'       , fWeekMap);

  Result :=  true;
end;

procedure TxPLRecurEvent.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
  RecurrenceAsString := aCfgFile.GetValue(aRootPath + '/Recurrence', '');
  fStartInDay        := StrToDateTime(aCfgFile.GetValue(aRootPath + '/StartInDay', ''));
  fStopInDay         := StrToDateTime(aCfgFile.GetValue(aRootPath + '/StopInDay', ''));
  fRandom            := aCfgFile.GetValue(aRootPath + '/Random', 0);
  fInterval          := aCfgFile.GetValue(aRootPath + '/Interval', 0);
  fDayRecurrence     := aCfgFile.GetValue(aRootPath + '/DayRecurrence', 0);
  fWeekMap           := aCfgFile.GetValue(aRootPath + '/WeekMap','1111111');
  inherited ReadFromXML(aCfgfile, aRootPath);
end;

end.

