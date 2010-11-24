unit uxPLEvent;

{==============================================================================
  UnitName      = uxPLEvent
  UnitDesc      = xPL timer management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.90 : Initial version
 0.91 : Modification to stick to timer.basic schema as described in xpl website
 0.92 : Removed XMLCfg usage, use u_xml instead
 0.93 : Still a lot of things to clean up this code...
}

interface

uses Controls, ExtCtrls, Classes,  uxPLMessage, SunTime, FPTimer,
     uxPLAddress, ComCtrls, uxPLListener, MOON, DOM,
     u_xml_config, u_xml_xpldeterminator;

type

  { TxPLEvent }

  TxPLEvent = class(TComponent)
  protected
      fName          : string;
      fEventType     : string;
      fEnabled       : boolean;
      fNextExecution : TDateTime;
      fActionList    : TXMLActionsType;
      fCfgEntry      : TDOMElement;
  public
     constructor Create(const aCfgEntry : TDOMElement);
      constructor Create(const aName : string; const aEnabled : boolean; const aNext : TDateTime);
      function WriteToXML : boolean; virtual;
      procedure ReadFromXML; virtual; abstract;

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
      property ActionList : TXMLActionsType read fActionList;
  end;

  { TxPLEventList }

  TxPLEventList = class(TStringList)
  private
     aMessage  : TxPLMessage;
     fGrid : TListView;
     fSysTimer : TfpTimer;
     fCfgEntry : TXMLLocalsType;
     function GetEvent(Index : integer): TxPLEvent;
  public
     constructor Create(const aClient : TxPLListener; const aGrid : TListView);
     destructor  Destroy; override;

     procedure ReadFromXML(const aCfgfile : TXMLLocalsType);

     procedure Check(Sender: TObject);
     procedure ToGrid(const anItem : integer);

     function Add(const S: string; const anEvent : TxPLEvent): Integer; overload;
     procedure Edit(const S: string);
     procedure Delete(aEvent : TxPLEvent); overload;
     procedure Delete(Index: Integer); override;
     property CfgEntry : TXMLLocalsType read fCfgEntry;
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
//     function    Edit  : boolean;                    override;
     procedure   Check(bAndFire : boolean =true);    override;
     procedure   Fire;                               override;

     procedure ReadFromXML; override;
  end;

  { TxPLSeasonEvent }

  TxPLSeasonEvent = class(TxPLEvent)
  private
     fType : TSeason;
     function GetNextOccurence : TDateTime;
  public
     constructor Create(const type_ : TSeason);
//     function Edit : boolean; override;
     procedure Check(bAndFire : boolean =true);    override;
     procedure   Fire;                             override;
     procedure ReadFromXML; override;
  end;


  { TxPLSingleEvent }

  TxPLSingleEvent = class(TxPLEvent)
  protected
     fSingleEvent   : boolean;
     fDescription   : widestring;
  public
     constructor Create(const aCfgEntry : TDOMElement);
     constructor Create(const aName: string; const bEnabled : boolean; const dtNext : TDateTime);

     function WriteToXML  : boolean; override;
     procedure ReadFromXML; override;

     function    Edit  : boolean;                 override;
     procedure   Fire;                            override;

  published
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
     constructor Create(const aCfgEntry : TDOMElement);                 //(const aMsg : TxPLMessage);
     property RecurrenceAsString : string read Getrecurrence write SetRecurrence;
     property StartInDay     : TTime   read fStartInDay write fStartInDay;
     property StopInDay      : TTime   read fStopInDay write fStopInDay;
     property DayRecurrence  : integer read fDayRecurrence write fDayRecurrence;
     property Random         : integer read fRandom write fRandom;
     property Interval       : integer read fInterval write fInterval;
     property RecurrenceType : TxPLEventRecurrenceType read fRecurrenceType write fRecurrenceType;
     property WeekMap        : string read fWeekMap write fWeekMap;

     function  WriteToXML : boolean; override;
     procedure ReadFromXML; override;
     function  Edit : boolean;                  override;
     procedure Check(bAndFire : boolean =true); override;
  end;

implementation //========================================================================
uses SysUtils,
     uxPLConst,
     strUtils,
     app_main,
     DateUtils,
     frm_xPLSingleEvent,
     frm_xPLRecurEvent,
     cRandom,
     u_xml;

{ TxPLEvent =============================================================================}
constructor TxPLEvent.Create(const aName: string; const aEnabled: boolean; const aNext: TDateTime);
begin
   inherited Create(nil);
   fName          := aName;
   fEnabled       := aEnabled;
   fNextExecution := aNext;
end;

constructor TxPLEvent.Create(const aCfgEntry: TDOMElement);
begin
   Create('', true, now);
   fCfgEntry   := aCfgEntry;
   fActionList := TXMLActionsType.Create(fCfgEntry,'action',K_XML_STR_Display_name);
end;

function TxPLEvent.WriteToXML : boolean;
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
   fSysTimer := TfpTimer.Create(nil);
   fSysTimer.Interval := 1000;
   fSysTimer.Enabled  := False;
   fSysTimer.OnTimer  := @Check;
   aMessage := TxPLMessage.Create;
   aMessage.MessageType:= K_MSG_TYPE_CMND;
   aMessage.Schema.RawxPL := K_SCHEMA_TIMER_BASIC;
   aMessage.Target.IsGeneric:=true;
   fGrid := aGrid;
end;

destructor TxPLEventList.Destroy;
begin
   //aMessage.Destroy;
   inherited;
end;

(*procedure TxPLEventList.WriteToXML;
var i : integer;
    elmt : TDOMElement;
begin
   //for i:=0 to Count-1 do begin
   //     elmt := fCfgEntry.AddElement(TxPLEvent(Objects[i]).Name);
   //     TxPLEvent(Objects[i]).WriteToXML; //(elmt);
   //end;
end;*)

procedure TxPLEventList.ReadFromXML(const aCfgfile : TXMLLocalsType);
var i : integer;
    anEvent : TxPLSingleEvent;
    aRecur  : TxPLRecurEvent;
begin
   fCfgEntry := aCfgFile;
   self.Clear;
   for i:=0 to fCfgEntry.Count-1 do begin
      anEvent := TxPLSingleEvent.Create(fCfgEntry[i]); //(aMessage);
      anEvent.ReadFromXML; //(aCfgFile[i]);
      if anEvent.IsSingleEvent then
         if anEvent.Over then
            anEvent.Destroy
         else
            Objects[Add(anEvent.Name)] := anEvent
      else begin
         anEvent.Destroy;
         aRecur := TXPLRecurEvent.Create(fCfgEntry[i]); //(aMessage);
         aRecur.ReadFromXML; //(aCfgfile[i]);
         Objects[Add(aRecur.Name)] := aRecur;
      end;
   end;
   fSysTimer.Enabled := (Count>0);
end;

procedure TxPLEventList.ToGrid(const anItem : integer);
var item    : tListItem;
    anEvent : TxPLEvent;
begin
   if fGrid.items.Count<=anItem then begin
      item := fGrid.Items.Add ;
      item.SubItems.Add(''); // Name
      item.SubItems.Add(''); // Type
      item.SubItems.Add(''); // Next Runing time
   end
      else item := fGrid.Items[anItem];

    anEvent := TxPLEvent(Objects[anItem]);
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

procedure TxPLEventList.Edit(const S: string);
var   i: integer;
      sEvent : TxPLEvent;
begin
  i := IndexOf(s);
  if i=-1 then exit;
  sEvent := TxPLEvent(Objects[i]);
  sEvent.Edit;
end;

procedure TxPLEventList.Delete(aEvent: TxPLEvent);
var itemnum : integer;
begin
   itemnum := IndexOf(aEvent.name);
   if itemnum=-1 then exit;
   Delete(itemnum);
end;

procedure TxPLEventList.Delete(Index: Integer);
var node : TDomNode;
begin
   node := Events[Index].fCfgEntry;
   if node<>nil then Self.fCfgEntry.RootNode.DetachChild(node);
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
constructor TxPLSingleEvent.Create(const aName: string; const bEnabled : boolean; const dtNext : TDateTime);
begin
   inherited Create(aName, bEnabled, dtNext);
   fSingleEvent   := True;
   fEventType     := 'Single';

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

//function TxPLSeasonEvent.Edit: boolean;
//begin
//  result := false;
//end;

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

procedure TxPLSeasonEvent.ReadFromXML;
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

constructor TxPLSingleEvent.Create(const aCfgEntry: TDOMElement); //(const aMsg : TxPLMessage);
begin
   Create('', true, now);
   fCfgEntry   := aCfgEntry;
   fActionList := TXMLActionsType.Create(fCfgEntry,'action',K_XML_STR_Display_name);
end;

function TxPLSingleEvent.Edit: boolean;
var aForm : TfrmxPLSingleEvent;
begin
     aForm := TfrmxPLSingleEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     if result then WriteToXML;
     aForm.Destroy;
end;

procedure TxPLSingleEvent.Fire;
var i : integer;
    aMessage : TxPLMessage;
begin
     if ActionList.Count=0 then
        xPLClient.SendMessage(K_MSG_TYPE_TRIG,'*',K_SCHEMA_TIMER_BASIC,['device','current'],[fName,'fired'])
     else
           for i := 0 to ActionList.Count-1 do begin
               aMessage := TxPLMessage.Create;
               aMessage.ReadFromXML(ActionList[i]);
               xPLClient.Send(aMessage);
               aMessage.Destroy;
           end;

end;

function TxPLSingleEvent.WriteToXML : boolean;
begin
   fCfgEntry.SetAttribute('name'     , Name);
   fCfgEntry.SetAttribute('next'     , DateTimeToStr(Next));
   fCfgEntry.SetAttribute('enabled'  , EnabledAsString);
   fCfgEntry.SetAttribute('issingle' , Ifthen(IsSingleEvent,'Yes','No'));
   fCfgEntry.SetAttribute('description' , fDescription);
   result := true;
end;

procedure TxPLSingleEvent.ReadFromXML;
begin
   Name         := fCfgEntry.GetAttribute('name');
   Next         := StrToDateTime(fCfgEntry.GetAttribute('next'));
   Enabled      := (fCfgEntry.GetAttribute('enabled')='Yes');
   fSingleEvent := (fCfgEntry.GetAttribute('issingle')='Yes');
   fDescription := fCfgEntry.GetAttribute('description');
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

procedure TxPLSunEvent.ReadFromXML;
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
     setDawn : aName := 'dawn';
     setDusk : aName := 'dusk';
     setNoon : aName := 'noon';
  end;
  fMessage := TxPLMessage.Create;
  fMessage.Source.Assign(aSource);
  fMessage.MessageType := K_MSG_TYPE_TRIG;
  fMessage.Schema.RawxPL  := K_SCHEMA_DAWNDUSK_BASIC;
  fMessage.Body.AddKeyValuePairs(['status','type'],[aName,fEventType]);
  inherited Create(aName,True,aNext);
end;

destructor TxPLSunEvent.Destroy;
begin
   fMessage.Destroy;
   inherited;
end;

//function TxPLSunEvent.Edit: boolean;
//begin result := false; end;                                                               // No edition possible on it

constructor TxPLRecurEvent.Create(const aCfgEntry : TDOMElement); //(const aMsg : TxPLMessage);
begin
     inherited; // Create;
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

     fCfgEntry   := aCfgEntry;
     fActionList := TXMLActionsType.Create(fCfgEntry,'action',K_XML_STR_Display_name);
end;

function TxPLRecurEvent.Edit: boolean;
var aForm : TfrmxPLRecurEvent;
begin
     aForm := TfrmxPLRecurEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     if result then begin
        WriteToXML;
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

function TxPLRecurEvent.WriteToXML : boolean;
begin
  inherited; // WriteToXML; //(aCfgfile);

  fCfgEntry.SetAttribute('recurrence'    , RecurrenceAsString);
  fCfgEntry.SetAttribute('startinday'    , DateTimeToStr(fStartInDay));
  fCfgEntry.SetAttribute('stopinday'     , DateTimeToStr(fStopInDay));
  fCfgEntry.SetAttribute('random'        , IntToStr(fRandom));
  fCfgEntry.SetAttribute('interval'      , IntToStr(fInterval));
  fCfgEntry.SetAttribute('dayrecurrence' , IntToStr(fDayRecurrence));
  fCfgEntry.SetAttribute('weekmap'       , fWeekMap);
  Result :=  true;
end;

procedure TxPLRecurEvent.ReadFromXML;
begin
  RecurrenceAsString := fCfgEntry.GetAttribute('recurrence');
  fStartInDay        := StrToDateTime(fCfgEntry.GetAttribute('startinday'));
  fStopInDay         := StrToDateTime(fCfgEntry.GetAttribute('stopinday'));
  fRandom            := StrToInt(fCfgEntry.GetAttribute('random'));
  fInterval          := StrToInt(fCfgEntry.GetAttribute('interval'));
  fDayRecurrence     := StrToInt(fCfgEntry.GetAttribute('dayrecurrence'));
  fWeekMap           := fCfgEntry.GetAttribute('weekmap');
  fCfgEntry          := fCfgEntry;
  inherited;
end;

end.

