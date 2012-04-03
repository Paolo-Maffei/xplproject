unit u_timer_pool;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , fpc_delphi_compat
     ;

type // TTimerPool ============================================================
     TTimerPool = class(TComponent)
     protected
        fList : TList;
     public
        constructor Create(aOwner : TComponent); override;
        destructor  Destroy; override;
//        destructor Destroy; override;
        function Add(const aInterval : integer; const aHandler : TNotifyEvent) : TxPLTimer; reintroduce;
        procedure Del(aTimer : TxPLTimer);
     end;

implementation

// TTimerPool =================================================================


//destructor TTimerPool.Destroy;
//begin
//   while Count<>0 do TxPLTimer(Self.Items[0]).Free;                       // Free all instances left
//   inherited Destroy;
//end;

constructor TTimerPool.Create(aOwner: TComponent);
begin
   inherited Create(aOwner);
   fList := TList.Create;
end;

destructor TTimerPool.Destroy;
begin
   fList.Free;
   inherited Destroy;
end;

function TTimerPool.Add(const aInterval: integer; const aHandler: TNotifyEvent): TxPLTimer;
begin
   result := TxPLTimer.Create(self);
   result.Interval := aInterval;
   result.OnTimer := aHandler;
   fList.Add(result);
end;

procedure TTimerPool.Del(aTimer: TxPLTimer);
begin
   fList.Remove(aTimer);
   FreeAndNil(aTimer);
end;

end.

