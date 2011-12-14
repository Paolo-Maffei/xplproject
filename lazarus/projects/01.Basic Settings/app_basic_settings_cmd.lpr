program app_basic_settings_cmd;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  , SysUtils
  , u_xpl_console_app
  , u_xpl_application
  , app_basic_settings_common
  , StrUtils
  ;

type

  TMyApplication = class(TxPLConsoleApp)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var Application: TMyApplication;

procedure TMyApplication.DoRun;
var ListenOn, BroadCast, ListenTo : string;

   function GetWithDefault(const aRequest, aDefault : string) : string;
   begin
      writeln(Format(aRequest + ' [%s] : ',[aDefault]));
      readln(result);
      if result = '' then result := aDefault;
      if result = 'q' then Abort;
   end;

begin
   with xPLApplication.Settings do begin
        ListenOn := GetWithDefault('Listen for xPL messages on (ALL/ip) ',IfThen(ListenOnAll, K_ALL_IPS_JOCKER, ListenOnAddress));
        BroadCast := IfThen(ListenOn = K_ALL_IPS_JOCKER,K_IP_GENERAL_BROADCAST,MakeBroadCast(ListenOn));
        BroadCast:= GetWithDefault('Broadcast address used to send xPL Messages', BroadCast);
        ListenTo := GetWithDefault('Listen messages coming from (ANY/LOCAL) ',IfThen(ListenToAny,'ANY','LOCAL'));
        if GetWithDefault('Save settings','y') = 'y' then begin
           BroadCastAddress := BroadCast;
           ListenOnAll := (ListenOn = K_ALL_IPS_JOCKER);
           if not ListenOnAll then ListenOnAddress := ListenOn;
           if ListenTo = 'ANY' then ListenToAny := true else ListenToLocal := True;
           writeln(COMMENT_LINE);
           Terminate;
        end;
   end;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

{$R *.res}

begin
  Application:=TMyApplication.Create(nil);
  xPLApplication := TxPLApplication.Create(Application);
  Application.Run;
  FreeAndNil(Application);
end.
