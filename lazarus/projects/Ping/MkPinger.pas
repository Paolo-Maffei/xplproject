{******************************************************************************}
{  Pinger class                                                                }
{          M.Kochiashvili                May, 2003                             }
{                                                                              }
{  Modified                                                                    }
{          G L'hopital                   July, 2009                            }
{******************************************************************************}
unit MkPinger;

interface

uses SysUtils, Classes, Math, Contnrs, IdComponent, IdIcmpClient;

type
  TPingerStat = record
    DateTime  : TDateTime;
    Host      : string[30];
    PkSend    : integer;
    PkReceive : integer;
    PkLossPrc : integer;
    RttMin    :	double;
    RttAvg    : double;
    RttMax    : double;
    Status    : TReplyStatusTypes;
    end;

type
  TOnFinishPing = procedure(ASender: TComponent; const AStatistics : TPingerStat) of object;

  { TMkPinger }

  TMkPinger = class( TIdIcmpClient)
  private
    FPingsToHost: integer;
    FStatistics : TPingerStat;
    FOnFinish : TOnFinishPing;
    FOnEachReply : TOnReplyEvent;
    FFirstPacket : boolean;
    FPinging: boolean;
    function getStatusAsString: string;
    procedure SetPingsToHost(const Value: integer);
    procedure ClearStatistics;
    procedure ICMPReply(ASender: TComponent; const RStatus: TReplyStatus);
    procedure SetPinging(const Value: boolean);
  public
    OldStatus : string;
    constructor Create(AOwner: TComponent); //override;
    property PingsToHost : integer read FPingsToHost write SetPingsToHost default 5;
    procedure PingHost;
    property Statistics : TPingerStat read FStatistics;
    property Pinging : boolean read FPinging write SetPinging;
    property OnFinish : TOnFinishPing read FOnFinish write FOnFinish;
    property OnEachReply : TOnReplyEvent read FOnEachReply write FOnEachReply;
    property StatusAsString : string read getStatusAsString;

  end;

  { TMkPingerList }

  TMkPingerList = class( TComponentList)
  private
    FActive: boolean;
    FOnFinish: TNotifyEvent;
    FPingsToHost: integer;
    FTimeout: integer;
    FPinging: boolean;
    function GetItems(Index: Integer): TMkPinger;
    procedure SetItems(Index: Integer; const Value: TMkPinger);
    procedure SetActive(const Value: boolean);
    procedure ItPingFinished(ASender: TComponent; const AStatistics : TPingerStat);
    procedure SetPinging(const AValue: boolean);
    procedure SetPingsToHost(const Value: integer);
    procedure SetTimeout(const Value: integer);
  public
    constructor Create; overload;
    property Active : boolean read FActive write SetActive;
    function AddNewPing :TMkPinger;
    function DeletePing(const aItem: string) : boolean;
    function ItemByName(const aItem : string) : TMkPinger;
    property PingsToHost : integer read FPingsToHost write SetPingsToHost default 5;
    property Timeout : integer read FTimeout write SetTimeout;
    property PingItems[Index: Integer]: TMkPinger read GetItems write SetItems; default;
    procedure Process;
    property Pinging : boolean read FPinging write SetPinging;
    property OnFinish : TNotifyEvent read FOnFinish write FOnFinish;
    end;

implementation

{ TMkPinger }

procedure TMkPinger.ClearStatistics;
begin
  FillChar( FStatistics, SizeOf( TPingerStat), 0);
end;

constructor TMkPinger.Create(AOwner: TComponent);
begin
  inherited;
  FPingsToHost := 5;
  FFirstPacket := true;
  FPinging := false;
  ClearStatistics;
  OnReply := @ICMPReply;
end;

procedure TMkPinger.ICMPReply(ASender: TComponent; const RStatus: TReplyStatus);
var RTT : integer;
begin
  if FFirstPacket then begin
    FFirstPacket := false;
    exit;
    end;
  if Assigned( FOnEachReply) then FOnEachReply( ASender, ReplyStatus);
  FStatistics.Host := ReplyStatus.FromIpAddress;
  FStatistics.Status := ReplyStatus.ReplyStatusType;
  case ReplyStatus.ReplyStatusType of
    rsError,
    rsTimeOut,
    rsErrorUnreachable,
    rsErrorTTLExceeded : begin
      with FStatistics do begin
        RttMin := 0;
        RttMax := 0;
        RttAvg := 0;
        end;
      end;
    rsEcho : begin
      with FStatistics do begin
        inc( PkReceive);
        if ReplyStatus.MsRoundTripTime > ReceiveTimeout * 10 then
             RTT := ReceiveTimeout
        else RTT := ReplyStatus.MsRoundTripTime;
        RttMin := Min( RttMin, RTT);
        RttMax := Max( RttMax, RTT);
        RttAvg := RttAvg + RTT;
        end;
      end;
    end;
end;

procedure TMkPinger.PingHost;
var Cou : integer;
begin
  Pinging := true;
  ClearStatistics;
  FFirstPacket := true;
  with FStatistics do begin
    DateTime := Now;
    RttMin := 1.0E15;
    PkSend := FPingsToHost;
    for Cou := 0 to FPingsToHost do begin
      try
        Ping;
      except
        if Assigned( FOnFinish) then FOnFinish( Self, FStatistics);
        Pinging := false;
        end;
      end;
    if PkSend > 0 then PkLossPrc := round(( (PkSend - PkReceive) / PkSend) * 100)
    else               PkLossPrc := 0;
    if PkReceive > 0 then RttAvg := RttAvg / PkReceive
    else                  RttAvg := 0;
    end;
  if Assigned( FOnFinish) then FOnFinish( Self, FStatistics);
  Pinging := false;
end;

procedure TMkPinger.SetPinging(const Value: boolean);
begin
  FPinging := Value;
end;

procedure TMkPinger.SetPingsToHost(const Value: integer);
begin
  FPingsToHost := Value;
end;

function TMkPinger.getStatusAsString: string;
begin
   if FStatistics.Status = rsEcho then result := 'on'
                                  else result := 'off';
   If FStatistics.Host = '' then result := 'unknown';
end;

{ TMkPingerList }

function TMkPingerList.AddNewPing: TMkPinger;
begin
  Result := TMkPinger.Create( NIL);
  Result.OnFinish := @ItPingFinished;
  Result.ReceiveTimeout := FTimeout;
  Result.PingsToHost := FPingsToHost;
  Add( Result);
end;

function TMkPingerList.DeletePing(const aItem: string) : boolean;
var i : integer;
 pinger : TMkPinger;
begin
     pinger := ItemByName(aItem);
     result := (pinger<>nil);
     if result then begin
        pinger.Destroy;
     end;
end;

function TMkPingerList.ItemByName(const aItem: string): TMkPinger;
var i : integer;
begin
     result := nil;
     i := Self.count -1;
     while (i>=0) and (result = nil) do begin
           if Self.PingItems[i].Host = aItem then result:=self.PingItems[i];
           dec(i);
     end;
end;

constructor TMkPingerList.Create;
begin
  inherited Create( True);
  FPingsToHost := 2;
  FTimeout := 5000;
end;

function TMkPingerList.GetItems(Index: Integer): TMkPinger;
begin
  Result := Items[ Index] as TMkPinger;
end;

procedure TMkPingerList.ItPingFinished(ASender: TComponent; const AStatistics: TPingerStat);
var TotActive : boolean; Cou : integer;
begin
  if Count <= 0 then exit;
  TotActive := false;
  for Cou := 0 to Count - 1 do TotActive := TotActive OR PingItems[ Cou].Pinging;
  if NOT TotActive then begin
    Active := false;
    if Assigned( FOnFinish) then FOnFinish( Self);
    end;
end;

procedure TMkPingerList.SetPinging(const AValue: boolean);
begin
  if FPinging=aValue then exit;

  FPinging := aValue;
end;

procedure TMkPingerList.Process;
var Cou : integer;
begin
  if Count = 0 then begin
    if Assigned( FOnFinish) then FOnFinish( Self);
    exit;
    end;
  Active := true;
  for Cou := 0 to Count-1 do begin
      Pinging := True;
      PingItems[Cou].PingHost;
      Pinging := False;
  end;
  if Assigned( FOnFinish) then FOnFinish( Self);
end;

procedure TMkPingerList.SetActive(const Value: boolean);
begin
  if FActive = Value then exit;
  FActive := Value;
//  if FActive then Process;
end;

procedure TMkPingerList.SetItems(Index: Integer; const Value: TMkPinger);
begin
  Items[ Index] := Value;
end;

procedure TMkPingerList.SetPingsToHost(const Value: integer);
var Cou : integer;
begin
  if FPingsToHost = Value then exit;
  FPingsToHost := Value;
  for Cou := 0 to Count-1 do PingItems[Cou].PingsToHost := FPingsToHost;
end;

procedure TMkPingerList.SetTimeout(const Value: integer);
var Cou : integer;
begin
  if FTimeout = Value then exit;
  FTimeout := Value;
  for Cou := 0 to Count-1 do PingItems[Cou].ReceiveTimeout := FTimeout;
end;

end.
