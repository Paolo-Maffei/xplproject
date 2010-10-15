unit app_main;

{$i compiler.inc}

interface

uses
  Classes, SysUtils,
  CustApp,
  uxPLMessage,
  uxPLListener;

type

{ TMyApplication }

  TMyApplication = class(TCustomApplication)
     protected
        procedure DoRun; override;
        procedure SignalStatus(const aTarget : string; const aURI: string; const aStatus: string);
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnReceived(const axPLMsg : TxPLMessage);
        destructor Destroy; override;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLListener;

implementation //======================================================================================
uses uxPLConst, FileUtil, uGetHTTP;

//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.9';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'netget';
//     K_DEFAULT_PORT   = '8340';

procedure TMyApplication.DoRun;
var ErrorMsg: String;
begin
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    Terminate;
    Exit;
  end;

  while true do begin
        CheckSynchronize;
  end;
  Terminate;
end;

procedure TMyApplication.SignalStatus(const aTarget : string; const aURI: string; const aStatus: string);
begin
   with xPLClient.PrepareMessage(K_MSG_TYPE_TRIG,'netget.basic',aTarget) do begin
        Body.AddKeyValuePair('uri',aURI);
        Body.AddKeyValuePair('current',aStatus);
        Send;
        Destroy;
   end;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER,false);
  xPLClient.OnxPLReceived   := @OnReceived;
  xPLClient.Listen;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
var aProtocol, aURI, aDestDir, aFileName, strOut : string;
begin
   if axPLMsg.MessageType = K_MSG_TYPE_CMND then begin                                   // Received a configuration message
      if axPLMsg.Schema.Tag = 'netget.basic' then begin
         aProtocol    := axPLMsg.Body.GetValueByKey('protocol');
         aURI         := axPLMsg.Body.GetValueByKey('uri');
         aDestDir     := axPLMsg.Body.GetValueByKey('destdir');
         aFileName    := axPLMsg.Body.GetValueByKey('destfn');
         if aProtocol = 'http' then begin
            strOut := '';
            GetHTTPFile(aURI,aDestDir + aFileName,xPLClient.Settings.HTTPProxSrvr,xPLClient.Settings.HTTPProxPort,strOut);
            if strOut = '' then SignalStatus(axPLMsg.Source.Tag,auri,'done');
         end;
      end;
   end;
end;

destructor TMyApplication.Destroy;
begin
   xPLClient.Destroy;
   inherited Destroy;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

