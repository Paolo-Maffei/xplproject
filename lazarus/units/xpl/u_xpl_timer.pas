unit u_xpl_timer;

{==============================================================================
  UnitName      = uxPLTimer
  UnitDesc      = xPL timer management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.90 : Initial version
 0.91 : Removed call to TTimer object replaced by TfpTimer (console mode
        compatibility requirement
 0.92 : Modification to stick to timer.basic schema as described in xpl website
}

{$mode objfpc}{$H+}{$M+}

interface

uses Classes,
  fpTimer,
  u_xpl_header,
  u_xpl_schema,
  u_xpl_common,
  u_xpl_message,
  u_xpl_collection,
  u_xpl_custom_message,
  u_xpl_address;

type
  TTimerMode   = (ascending, descending, recurrent);
  TTimerStatus = (stopped, started, halted, expired);

  { TxPLTimer }

  TxPLTimer = class(TxPLCollectionItem)
  private
    fMode:      TTimerMode;
    fStatus:    TTimerStatus;
    fFrequency: integer;
    fRemaining: integer;
    fTrigMsg:   TxPLCustomMessage;
    fStart_Time, fEnd_Time: TDateTime;
    fSysTimer:  TFPTimer;
    procedure Set_Mode(const AValue: TTimerMode);
//    procedure SetDisplayName(const aValue: string); override;
  protected
//    function Get_TimerName: string;
//    procedure Set_TimerName(const aValue: string);
    procedure Set_Status(const aStatus: TTimerStatus);
  public
    constructor Create(aOwner: TCollection); override;
    procedure   InitComponent(const aMsg : TxPLMessage);
//    destructor Destroy;

    function StatusAsStr: string;
    procedure SendStatus(const aMsgType: TxPLMessageType = stat);
    function Target: string;
    procedure Tick(Sender: TObject);                                           // This procedure should be called every second by owner
  published
//    property TimerName: string Read Get_TimerName Write Set_TimerName;
    property Status: TTimerStatus Read fStatus Write Set_Status;
    property Mode: TTimerMode Read fMode Write Set_Mode;
    property Start_Time: TDateTime Read fStart_Time write fStart_Time;
    property End_Time: TDateTime Read fEnd_Time write fEnd_Time;
    property Remaining: integer Read fRemaining Write fRemaining;
    property Frequence: integer Read fFrequency Write fFrequency;
  end;

  { TxPLTimerItems }
  TxPLTimers = specialize TxPLCollection<TxPLTimer> ;

  //TxPLTimers = class(TCollection)
  //private
  //  fOwner: TPersistent;
  //  function GetItems(index: integer): TxPLTimer;
  //  procedure SetItems(index: integer; Value: TxPLTimer);
  //protected
  //  function GetOwner: TPersistent; override;
  //public
  //  constructor Create(aOwner: TPersistent);
  //
  //  function Add: TxPLTimer;
  //  function FindItemName(const aName: string): TxPLTimer;
  //  function GetItemId(const aName: string): integer;
  //  property Items[Index: integer]: TxPLTimer Read GetItems Write SetItems; default;
  //end;

var
  Schema_TimerBasic, Schema_TimerRequest: TxPLSchema;

implementation // =============================================================

uses SysUtils
     , DateUtils
     , TypInfo
     , u_xpl_sender
     , u_xpl_body
     , u_xpl_application
     , timer_listener
     , Math
     ;

{==============================================================================}
function DateTimeDiff(Start, Stop: TDateTime): int64;
var
  TimeStamp: TTimeStamp;
begin
  TimeStamp := DateTimeToTimeStamp(Stop - Start);
  Dec(TimeStamp.Date, TTimeStamp(DateTimeToTimeStamp(0)).Date);
  Result := (TimeStamp.Date * 24 * 60 * 60) + (TimeStamp.Time div 1000) + 1;
end;

 // TxPLTimer object ===========================================================
constructor TxPLTimer.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);

  fSysTimer := TfpTimer.Create(xPLApplication);
  fSysTimer.Interval := 1000;
  fSysTimer.Enabled := False;
  fSysTimer.OnTimer := @Tick;

  fTrigMsg := TxPLCustomMessage.Create(xPLApplication);
  fTrigMsg.Target.IsGeneric := True;
  fTrigMsg.Schema.Assign(Schema_TimerBasic);

  fRemaining := 0;
  fFrequency := 0;
end;

procedure TxPLTimer.InitComponent(const aMsg : TxPLMessage);
begin
   DisplayName  :=  aMsg.Body.GetValueByKey('device');
   fRemaining := StrToIntDef(aMsg.Body.GetValueByKey('duration'),0);
   fFrequency := StrToIntDef(aMsg.Body.GetValueByKey('frequence'),0);

   if fRemaining = 0 then                                                      // 0 sec remaining, it is a UP or RECURRENT timer
      if fFrequency = 0 then
         fMode := ascending
      else
          fMode := recurrent
     else                                                                      // x sec remaining, it is a down timer
         fMode := descending;

   fStart_Time := now;

   if fMode = descending then fEnd_Time := IncSecond(fStart_Time, fRemaining)
                         else fEnd_Time := fStart_Time;

   Status := started;
end;

//destructor TxPLTimer.Destroy;
//begin
////  FSysTimer.Free;
////  fTrigMsg.Free;
//  inherited;
//end;

function TxPLTimeR.StatusAsStr: string;
begin
  Result := GetEnumName(TypeInfo(TTimerStatus), Ord(Status));
end;

procedure TxPLTimer.Set_Mode(const AValue: TTimerMode);
begin
  if fMode = AValue then exit;
  fMode := AValue;
  if (fMode = Recurrent) and (fFrequency < 1) then fFrequency := 1;
end;

procedure TxPLTimer.Set_Status(const aStatus: TTimerStatus);
begin
  if Status <> aStatus then begin
    fStatus := aStatus;

    case fStatus of
      expired:
      begin
        fSysTimer.Enabled := False;
        fEnd_Time := Now;
        if fRemaining <> 0 then fStatus  := stopped;
        fRemaining := 0;
      end;
      started: fSysTimer.Enabled := True;
      stopped:
      begin
        fSysTimer.Enabled := False;
      end;
    end;

    SendStatus(trig);
  end;
  if fStatus = expired then FreeAndNil(self);
end;

procedure TxPLTimer.SendStatus(const aMsgType: TxPLMessageType = stat);
var elapsed : integer;
begin
  if not (csLoading in xPLApplication.ComponentState) then begin
     fTrigMsg.MessageType := aMsgType;
     fTrigMsg.Body.ResetValues;
     fTrigMsg.Body.AddKeyValuePairs(['device', 'current'], [DisplayName, StatusAsStr]);
     elapsed := Max(DateTimeDiff(Start_Time, now) - 1,0);
     if elapsed <> 0 then
        fTrigMsg.Body.AddKeyValuePairs(['elapsed'], [IntToStr(elapsed)]);
     TxPLSender(xPLApplication).Send(fTrigMsg);
  end;
end;

function TxPLTimer.Target: string;
begin
   Result := fTrigMsg.Target.RawxPL;
end;

procedure TxPLTimer.Tick(Sender: TObject);
begin
  if ((Status = halted) and (End_Time <> 0))
     then fEnd_Time := IncSecond(now, fRemaining)
  else if (Status = started) then
    case Mode of
      ascending: Inc(fremaining);
      descending: begin
                       Dec(fremaining);
                       if fRemaining < 1 then
                       Status := expired;
                  end;
      recurrent:  if Status = started then begin
                     Inc(fremaining);
                     if (fRemaining mod fFrequency = 0) then SendStatus(stat);
                  end;
    end;
end;

initialization
  Schema_TimerBasic   := TxPLSchema.Create('timer','basic');
  Schema_TimerRequest := TxPLSchema.Create('timer','request');

end.

