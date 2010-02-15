unit uxPLRecurEvent;

{$mode objfpc}{$H+}

interface

uses Classes, uxPLListener, uxPLMessage, XMLCfg, ComCtrls, uxPLSingleEvent, Controls, ExtCtrls;

type
  TxPLEventRecurrenceType = ( er_Daily, er_Weekly, er_Monthly);

  { TxPLEventList }

  TxPLEventList = class(TStringList)
  private
     aMessage  : TxPLMessage;
     fGrid : TListView;
     fSysTimer : TTimer;
  public
     constructor Create(const aClient : TxPLListener; const aGrid : TListView);
     destructor  Destroy; override;

     procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string);
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string);
     procedure Check(Sender: TObject);
     procedure ToGrid(const anItem : integer);

     function Add(const S: string): Integer; override;
     procedure Delete(Index: Integer); override;
  end;

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
     function    Edit : boolean;      override;
     procedure   Check(bAndFire : boolean =true); override;
     procedure   Fire;         override;
     property RecurrenceAsString : string read Getrecurrence write SetRecurrence;
     property StartInDay     : TTime   read fStartInDay write fStartInDay;
     property StopInDay      : TTime   read fStopInDay write fStopInDay;
     property DayRecurrence  : integer read fDayRecurrence write fDayRecurrence;
     property Random         : integer read fRandom write fRandom;
     property Interval       : integer read fInterval write fInterval;
     property RecurrenceType : TxPLEventRecurrenceType read fRecurrenceType write fRecurrenceType;
     property WeekMap : string read fWeekMap write fWeekMap;

     procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); override;
     procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); override;
  end;


implementation //===============================================================
uses SysUtils, DateUtils, frm_xPLRecurEvent, cRandom, uxPLMsgHeader, uxPLConst;

{ TxPLRecurEvent }

constructor TxPLRecurEvent.Create(const aMsg : TxPLMessage);
begin
     inherited Create(aMsg);
     fRecurrenceType := er_Daily;
     fStartInDay := now;
     fStopInDay  := IncMinute(fStartInDay,60);
     fRandom     := 0;
     fInterval   := 60;
     fDayRecurrence := 1;
     fSingleEvent:= false;           // this is a recurrent event
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
        Next := 0;                                               // FS#27 Reset next run time to force recompute
        Check(false);                                            // FS#29 False added to avoid launch of the event when creating it
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

procedure TxPLRecurEvent.Fire;
begin
   inherited;
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


procedure TxPLRecurEvent.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
  inherited WriteToXML(aCfgfile, aRootPath);
  aCfgFile.SetValue(aRootPath + '/Recurrence'    , RecurrenceAsString);
  aCfgFile.SetValue(aRootPath + '/StartInDay'    , DateTimeToStr(fStartInDay));
  aCfgFile.SetValue(aRootPath + '/StopInDay'     , DateTimeToStr(fStopInDay));
  aCfgFile.SetValue(aRootPath + '/Random'        , fRandom);
  aCfgFile.SetValue(aRootPath + '/Interval'      , fInterval);
  aCfgFile.SetValue(aRootPath + '/DayRecurrence' , fDayRecurrence);
  aCfgFile.SetValue(aRootPath + '/WeekMap'       , fWeekMap);
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

{ TxPLEventList ===============================================================}

constructor TxPLEventList.Create(const aClient : TxPLListener; const aGrid : TListView);
begin
  inherited Create;
  fSysTimer := TTimer.Create(nil);
  fSysTimer.Interval := 1000;
  fSysTimer.Enabled  := False;
  fSysTimer.OnTimer  := @Check;
  aMessage := aClient.PrepareMessage(xpl_mtCmnd,'control.basic');
  fGrid := aGrid;
end;

destructor TxPLEventList.Destroy;
begin
  aMessage.Destroy;
  inherited;
end;

procedure TxPLEventList.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string);
var i : integer;
    anEvent : TxPLSingleEvent;
    aRecur  : TxPLRecurEvent;
begin
   for i:=0 to Count -1 do begin
      anEvent := TxPLSingleEvent(Objects[i]);
      if anEvent.IsSingleEvent then
         anEvent.WriteToXML(aCfgfile, aRootPath + '/Event_' + intToStr(i)) else
      begin
         aRecur := TxPLRecurEvent(anEvent);
         aRecur.WriteToXML(aCfgfile, aRootPath + '/Event_' + intToStr(i));
      end;
   end;
   if Count>0 then aCfgfile.SetValue(aRootPath + '/EventCount', intToStr(i+1));
end;

procedure TxPLEventList.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
var i : integer;
    anEvent : TxPLSingleEvent;
    aRecur  : TxPLRecurEvent;
begin
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

function TxPLEventList.Add(const S: string): Integer;
begin
  Result:=inherited Add(S);
  fSysTimer.Enabled := (Count>0);
end;

procedure TxPLEventList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  fSysTimer.Enabled := (Count>0);
  fGrid.Items[index].Delete ;
end;

procedure TxPLEventList.Check(Sender: TObject);
var i : integer;
    anEvent : TxPLSingleEvent;
    aRecur  : TxPLRecurEvent;
begin
   i := Count-1;
   repeat
       anEvent := TxPLSingleEvent(objects[i]);
       if anEvent.IsSingleEvent then begin
          anEvent.Check;
          if anEvent.Over then Delete(i) else ToGrid(i);
       end else begin
          aRecur := TxPLRecurEvent(objects[i]);
          aRecur.Check;
          ToGrid(i);
       end;
       dec(i);
   until ((i<0) or (count=0));
end;


end.

