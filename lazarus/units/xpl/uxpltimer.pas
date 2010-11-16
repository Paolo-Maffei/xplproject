unit uxPLTimer;
{==============================================================================
  UnitName      = uxPLTimer
  UnitDesc      = xPL timer management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.90 : Initial version
 0.91 : Removed call to TTimer object replaced by TfpTimer (console mode
        compatibility requirement
 0.92 : Modification to stick to timer.basic schema as described in xpl website
 0.93 : Removed inheritance from TComponent
        Removed XMLCfg usage, use u_xml instead
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uxPLListener, uxPLMessage, ComCtrls, fpTimer, u_xml_config, DOM;

type
  TxPLTimer = class(TComponent)
  private
    function GetMode: string;
    function GetStatus: string;
    procedure SetMode(const AValue: string);
    procedure SetStatus(const AValue: string);
  protected
    fName          : string;
    fStopReason    : string;
    fxPLMessage    : TxPLMessage;
    fMode          : integer;                        //1 : up, 2 : down, 3 : recurrent
    fStatus        : integer;                        //0 : stopped, 1 : started ; 2 : halted
  public
     Target    : string;
     StartTime : TDateTime;
     Remaining : cardinal;
     Frequence : cardinal;
     EstimatedEnd : TDateTime;

     constructor Create(const aMsg : TxPLMessage);
     function    Edit  : boolean;

     procedure WriteToXML (const aCfgfile : TDOMElement); dynamic;
     procedure ReadFromXML(const aCfgfile : TDOMElement); dynamic;
     function SendStatus : boolean;
     function Pause : boolean;
     function ResumeOrStart : boolean;
     function Stop : boolean;
     function Stopped : boolean;
     function Range : string;
     procedure Tick;         // This procedure should be called every second by owner
     procedure Init(const aDevice : string; const aSource : string; const aRange : string; const aDuration : string; const aFrequence : string);
  published

     property StopReason : string read fStopReason;
     property TimerName  : string read fName write fName;
     property Mode       : string read GetMode write SetMode;
//     property Range      : string read GetRange write SetRange;
     property Status     : string read GetStatus write SetStatus;
  end;

  { TxPLTimerList =============================================================}
  TxPLTimerList = class(TStringList)
  private
     aMessage  : TxPLMessage;
     fGrid : TListView;
     fSysTimer : TfpTimer;
     function GetTimer(Index : integer): TxPLTimer;
  public
     constructor Create(const aClient : TxPLListener; const aGrid : TListView);
     destructor  Destroy;

     procedure WriteToXML (const aCfgfile : TXMLLocalsType);
     procedure ReadFromXML(const aCfgfile : TXMLLocalsType);
     procedure Check(Sender: TObject);
     procedure ToGrid    (const anItem : integer);

     function Add(const S: string): Integer; override;
     function Add(const aTimer : TxPLTimer) : integer;
     procedure Delete(Index: Integer); override;

     function  Pause     (const sTimer : string) : boolean;
     function  Stop      (const sTimer : string) : boolean; overload;
     function  SendStatus(const sTimer : string) : boolean; overload;

     function ResumeOrStartATimer(const sTimer: string) : boolean;
     procedure Init(const aDevice : string; const aSource : string; const aRange : string; const aDuration : string; const aFrequence : string);
  public
     property xPLMessage : TxPLMessage read aMessage;
     property Timers[Index : integer] : TxPLTimer read GetTimer;
  end;




implementation //===============================================================
uses frm_xplTimer,
     Controls,
     DateUtils,
     StrUtils,
     uxPLConst,
     frm_main,
     u_xml,
     app_main;

{==============================================================================}
function DateTimeDiff(Start, Stop : TDateTime) : int64;
    var TimeStamp : TTimeStamp;
    begin
       TimeStamp := DateTimeToTimeStamp(Stop - Start);
       Dec(TimeStamp.Date, TTimeStamp(DateTimeToTimeStamp(0)).Date);
       Result := (TimeStamp.Date*24*60*60)+(TimeStamp.Time div 1000) + 1;
    end;

function TxPLTimer.GetMode: string;
begin
  case fMode of
       1 : result := 'ascending';
       2 : result := 'descending';
       3 : result := 'recurrent';
  end;
end;

procedure TxPLTimer.SetMode(const AValue: string);
begin
  fMode := AnsiIndexStr(aValue, ['ascending','descending','recurrent']) + 1;
end;

function TxPLTimer.Range: string;
begin
  if Target = '*' then result := 'global' else result := 'local';
end;

function TxPLTimer.GetStatus: string;
begin
  case fStatus of
       0 : result := 'stopped';
       1 : result := 'started';
       2 : result := 'halted';
  end;
end;

procedure TxPLTimer.SetStatus(const AValue: string);
begin
   fStatus := AnsiIndexStr(aValue, ['stopped','started','halted']);
end;

{TxPLTimer ====================================================================}
constructor TxPLTimer.Create(const aMsg : TxPLMessage);
begin
     fxPLMessage := aMsg;
     Target := '*';
     fMode  := 1;
end;

function TxPLTimer.Edit: boolean;
var aForm : TfrmxPLTimer;
begin
   aForm := TfrmxPLTimer.Create(self);
   result := (aForm.ShowModal = mrOk);
   aForm.Destroy;
end;

procedure TxPLTimer.WriteToXML(const aCfgfile: TDOMElement);
begin
   aCfgFile.SetAttribute(K_XML_STR_Name , fName);
   aCfgFile.SetAttribute('target'   , Target);
   aCfgFile.SetAttribute('starttime', DateTimeToStr(StartTime));
   aCfgFile.SetAttribute('remaining', IntToStr(Remaining));
   aCfgFile.SetAttribute('status'   , Status);
   aCfgFile.SetAttribute('mode'     , Mode);
   aCfgFile.SetAttribute('frequence', IntToStr(Frequence));
   aCfgFile.SetAttribute('estimatedend', IfThen(EstimatedEnd = 0,'0',DateTimeToStr(EstimatedEnd)));
end;

procedure TxPLTimer.ReadFromXML(const aCfgfile: TDOMElement);
var sEstimatedEnd : string;
begin
   fName     := aCfgFile.GetAttribute(K_XML_STR_Name);
   Target    := aCfgFile.GetAttribute('target');
   StartTime := StrToDateTime( aCfgFile.GetAttribute('starttime'));
   Status    := aCfgFile.GetAttribute('status');   // default : started
   Mode      := aCfgFile.GetAttribute('mode'); // default : ascending
   Remaining := StrToInt(aCfgFile.GetAttribute('remaining')); // default : 0
   Frequence := StrToInt(aCfgFile.GetAttribute('frequence')); // default : 0
   sEstimatedEnd := aCfgFile.GetAttribute('estimatedend');

   if sEstimatedEnd = '0' then begin                                            // This timer goes up from start
      EstimatedEnd := 0;
      Remaining := DateTimeDiff(StartTime, Now);                                // Recalculate elapsed time
   end else begin
      EstimatedEnd := StrToDateTime(sEstimatedEnd);                             // this timer goes down from start until duration
      if EstimatedEnd < Now then
          Remaining := 1                                                        // this will stop it on next tick
      else
          Remaining := DateTimeDiff(Now,EstimatedEnd);
   end;
end;

procedure TxPLTimer.Init(const aDevice : string; const aSource: string; const aRange: string; const aDuration: string; const aFrequence: string);
begin
   fName := aDevice;
   StartTime := now();
   Target := IfThen(aRange = 'local', aSource, '*');
   Remaining := StrToIntDef(aDuration,0);
   Frequence := StrToIntDef(aFrequence,0);

   Case Remaining of
       0 : begin                        // O sec remaining, it is a UP or RECURRENT timer
           EstimatedEnd := 0;
           if Frequence = 0
              then fMode := 1
              else fMode := 3;
           end;
       else begin                       // x secs remaining, it is a DOWN timer
            fMode := 2;
            EstimatedEnd := IncSecond(StartTime, Remaining);
       end;
     end;
     ResumeOrStart;
end;

function TxPLTimer.SendStatus : boolean;
begin
   result := (Status <> 'stopped');
   if not result then exit;

   with fxPLMessage do begin
       MessageType := K_MSG_TYPE_STAT;    // as xpl-mtStat this message will be a broadcast, target assumed by message object
       Body.ResetValues;
       Body.AddKeyValuePairs(['device','current','elapsed'],[fName,Status,IntToStr(DateTimeDiff(StartTime, Now))]);
//       Format_SensorBasic(fName,'generic',Status);
       Target.Tag := self.Target;
       Schema.Tag := K_SCHEMA_TIMER_BASIC;
//       Body.AddKeyValuePair('elapsed',IntToStr(DateTimeDiff(StartTime, Now)));
       xPLClient.Send(fxPLMessage);
   end;
end;

function TxPLTimer.ResumeOrStart : boolean;
begin
   result := (Status <> 'started');
   if not result then exit;

   Status := 'started';

   with fxPLMessage do begin
      MessageType := K_MSG_TYPE_TRIG;
      Target.Tag := self.Target;
      Body.ResetValues;
      Body.AddKeyValuePairs(['device','current'],[fName,Status]);
//      Format_SensorBasic(fName,'generic',Status);
      Schema.Tag := K_SCHEMA_TIMER_BASIC;
      xPLClient.Send(fxPLMessage);
   end;

end;

function TxPLTimer.Stop : boolean;
begin
   result := (Status <> 'stopped');
   if result then begin
      Status := 'stopped';
      EstimatedEnd := Now;
      if Remaining > 0 then
         fStopReason := 'stopped'
      else
         fStopReason := 'went off';
      Remaining := 0;

      with fxPLMessage do begin
         MessageType := K_MSG_TYPE_TRIG;
         Target.Tag := self.Target;
         Body.ResetValues;
         Body.AddKeyValuePairs(['device','current','elapsed'],[fName,fStopReason,IntToStr(DateTimeDiff(StartTime, Now))]);
//         Format_SensorBasic(fName,'generic',StopReason);
//         Body.AddKeyValuePair('elapsed',IntToStr(DateTimeDiff(StartTime, Now)));
         Schema.Tag := K_SCHEMA_TIMER_BASIC;
         xPLClient.Send(fxPLMessage);
      end;
   end;
end;

function TxPLTimer.Stopped: boolean;
begin result :=  (status = 'stopped'); end;

function TxPLTimer.Pause : boolean;
begin
   result := (Status = 'started');
   if not result then exit;

   Status := 'halted';                                                          // Mark it as halted

   with fxPLMessage do begin
      MessageType := K_MSG_TYPE_TRIG;
      Target.Tag := self.Target;
      Body.ResetValues;
      Body.AddKeyValuePairs(['device','current','elapsed'],[fName,Status,IntToStr(DateTimeDiff(StartTime, Now))]);
//      Format_SensorBasic(fName,'generic',Status);
//      Body.AddKeyValuePair('elapsed',IntToStr(DateTimeDiff(StartTime, Now)));
      Schema.Tag := K_SCHEMA_TIMER_BASIC;
      xPLClient.Send(fxPLMessage);
   end; 
end;

procedure TxPLTimer.Tick;
begin
   case AnsiIndexStr(status, ['started','halted']) of
        0 : begin
               Case fMode of
                    1 : Inc(Remaining);
                    2 : Dec(Remaining);
                    3 : begin
                           Inc(Remaining);
                           if Remaining mod Frequence = 0 then SendStatus;
                        end;
                    end;
                 if (Remaining=0) then Stop;
            end;
        1 : if EstimatedEnd <> 0 then
               EstimatedEnd := IncSecond(now, Remaining);
   end;
end;

{ TxPLTimerList ===============================================================}
function TxPLTimerList.ResumeOrStartATimer(const sTimer: string) : boolean;
var i : integer;
begin
   result := false;

   i := IndexOf(sTimer);
   if i=-1 then exit;

   result := TxPLTimer(Objects[i]).ResumeOrStart;
end;

function TxPLTimerList.Stop(const sTimer : string) : boolean;
var i : integer;
begin
   result := false;

   i := IndexOf(sTimer);
   if i=-1 then exit;

   result := TxPLTimer(Objects[i]).Stop;

   TxPLTimer(Objects[i]).Destroy;
   Delete(i);
end;

function TxPLTimerList.Pause(const sTimer: string) : boolean;
var i : integer;
begin
   result := false;

   i := IndexOf(sTimer);
   if i=-1 then exit;

   result := TxPLTimer(Objects[i]).Pause;
end;

function TxPLTimerList.SendStatus(const sTimer : string) : boolean;
var i : integer;
begin
   result := false;

   i := IndexOf(sTimer);
   if i=-1 then exit;

   result := TxPLTimer(Objects[i]).SendStatus;
end;

procedure TxPLTimerList.Init(const aDevice : string; const aSource : string; const aRange : string; const aDuration : string; const aFrequence : string);
var current : integer;
begin
     current := IndexOf(aDevice);
     if current=-1 then begin
        current := Add(aDevice);
        Objects[current] := TxPLTimer.Create(aMessage);
     end;

     TxPLTimer(Objects[current]).Init(aDevice,aSource,aRange, aDuration, aFrequence);
end;

function TxPLTimerList.Add(const S: string): Integer;
begin
  Result:=inherited Add(S);
  fSysTimer.Enabled := (Count>0);
end;

function TxPLTimerList.Add(const aTimer: TxPLTimer): integer;
begin
  Result:= Add(aTimer.fName);
  aTimer.fxPLMessage := aMessage;
  Objects[result] := aTimer;
end;

procedure TxPLTimerList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  fSysTimer.Enabled := (Count>0);
  fGrid.Items[index].Delete ;
end;

procedure TxPLTimerList.WriteToXML(const aCfgfile: TXMLLocalsType);
var i : integer;
    elmt : TDOMElement;
begin
    for i:=0 to Count-1 do begin
        elmt := aCfgFile.AddElement(TxPLTimer(Objects[i]).TimerName);
        TxPLTimer(Objects[i]).WriteToXML(elmt);
    end;
end;

procedure TxPLTimerList.ReadFromXML(const aCfgfile : TXMLLocalsType);
var i : integer;
    aTimer  : TxPLTimer;
begin
   self.Clear;
   for i:=0 to aCfgFile.Count-1 do begin
      aTimer := TxPLTimer.Create(aMessage);
      aTimer.ReadFromXML(aCfgFile[i]);
      Add(aTimer);
   end;
end;

procedure TxPLTimerList.Check(Sender: TObject);
var i : integer;
begin
   i := Count-1;
   repeat
       TxPLTimer(Objects[i]).Tick;
       if TxPLTimer(Objects[i]).Stopped then Delete(i)
                                        else ToGrid(i);
       dec(i);
   until ((i<0) or (count=0));
end;

procedure TxPLTimerList.ToGrid(const anItem: integer);
var item : tListItem;
    aTimer : TxPLTimer;
    sEstimatedEnd : string;
begin
   if fGrid.items.Count<=anItem then begin
      item := fGrid.Items.Add ;
      item.SubItems.Add(''); // Source
      item.SubItems.Add(''); // Starttime
      item.SubItems.Add(''); // Remaining
      item.SubItems.Add(''); // Estimated End
      item.SubItems.Add(''); // Status
      item.SubItems.Add(''); // Range
   end
   else item := fGrid.Items[anItem];
   aTimer := TxPLTimer(Objects[anItem]);

   sEstimatedEnd := IfThen(aTimer.EstimatedEnd <> 0,DateTimeToStr(aTimer.EstimatedEnd));

   item.ImageIndex := aTimer.fMode;

   item.Caption := aTimer.fName;
   item.SubItems[0] := aTimer.Target;
   item.SubItems[1] := DateTimeToStr(aTimer.StartTime);
   item.SubItems[2] := IntToStr(aTimer.Remaining);
   item.SubItems[3] := sEstimatedEnd;
   item.SubItems[4] := aTimer.Status;
   item.Data := aTimer;
end;

function TxPLTimerList.GetTimer(Index : integer): TxPLTimer;
begin result := TxPLTimer(Objects[Index]); end;

constructor TxPLTimerList.Create(const aClient: TxPLListener; const aGrid : TListView);
begin
  inherited Create;
  fSysTimer := TfpTimer.Create(nil);
  fSysTimer.Interval := 1000;
  fSysTimer.Enabled  := False;
  fSysTimer.OnTimer  := @Check;
  aMessage := aClient.PrepareMessage(K_MSG_TYPE_TRIG,K_SCHEMA_TIMER_BASIC);
  fGrid := aGrid;
end;

destructor TxPLTimerList.Destroy;
begin
  aMessage.Destroy;
  fSysTimer.Destroy;
  inherited;
end;

end.

