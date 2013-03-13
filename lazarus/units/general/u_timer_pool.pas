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
        function Add(const aInterval : integer; const aHandler : TNotifyEvent) : TxPLTimer; reintroduce;
        procedure Del(const aTimer : TxPLTimer);
     end;

implementation

// TTimerPool =================================================================
constructor TTimerPool.Create(aOwner: TComponent);
begin
   inherited Create(aOwner);
   fList := TList.Create;
end;

destructor TTimerPool.Destroy;
begin
   fList.Free;                                                                 // Will free all left timers
   inherited;
end;

function TTimerPool.Add(const aInterval: integer; const aHandler: TNotifyEvent): TxPLTimer;
begin
   result := TxPLTimer.Create(self);
   result.Interval := aInterval;
   result.OnTimer := aHandler;
   fList.Add(result);
end;

procedure TTimerPool.Del(const aTimer: TxPLTimer);
begin
   aTimer.Enabled := false;
   fList.Remove(aTimer);
   aTimer.Free;
end;

end.
