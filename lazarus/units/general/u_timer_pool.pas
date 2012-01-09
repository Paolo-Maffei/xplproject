unit u_timer_pool;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , fpc_delphi_compat
     ;

type // TTimerPool ============================================================
     TTimerPool = class(TList)
     public
        destructor Destroy; override;
        function Add(const aInterval : integer; const aHandler : TNotifyEvent) : TxPLTimer; reintroduce;
     end;

implementation

// TTimerPool =================================================================

destructor TTimerPool.Destroy;
begin
   while self.Count<>0 do TxPLTimer(Self.Items[0]).Free;                       // Free all instances left
   inherited Destroy;
end;

function TTimerPool.Add(const aInterval: integer; const aHandler: TNotifyEvent): TxPLTimer;
begin
   result := TxPLTimer.Create(nil);
   result.Interval := aInterval;
   result.OnTimer := aHandler;
end;

end.

