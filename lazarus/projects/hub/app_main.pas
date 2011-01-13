unit app_main;

{$i compiler.inc}

interface

uses Classes,
     CustApp,
     u_xpl_hub;

type

{ TMyApplication }

TMyApplication = class(TCustomApplication)
     protected
        procedure DoRun; override;
     public
        constructor Create(TheOwner: TComponent); override;
        destructor  Destroy; override;
        procedure   Log(const aString : string);
     end;

var  xPLApplication : TMyApplication;
     xPLHub      : TxPLHub;

//==============================================================================
const
     K_XPL_APP_VERSION_NUMBER = '3.0';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'hub';

implementation //===============================================================
uses SysUtils,
     DateUtils,
     uxPLConst;

{ TxPLHub }

// =============================================================================
procedure TMyApplication.DoRun;
begin
     CheckSynchronize;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Writeln(K_DEFAULT_DEVICE + ' ' + K_XPL_APP_VERSION_NUMBER + ' by ' + K_DEFAULT_VENDOR);
  xPLHub := TxPLHub.Create;
  xPLHub.OnLog := @Log;
  xPLHub.Start;
end;

destructor TMyApplication.Destroy;
begin
   xPLHub.Free;
   inherited Destroy;
end;

procedure TMyApplication.Log(const aString: string);
begin
  writeln(aString);
end;


initialization
   xPLApplication:=TMyApplication.Create(nil);

end.

