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
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnReceived(const axPLMsg : TxPLMessage);
        destructor Destroy; override;
        procedure HTTPGet(aMsg : TxPLMessage);
        procedure HTTPDownload(aMsg : TxPLMessage);
        procedure HTTPSDownload(aMsg : TxPLMessage);
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLListener;

implementation //===============================================================
uses uxPLConst,
     FileUtil,
     uGetHTTP,
     uRegExpr,
     StrUtils,
     IdHTTP,
     IdSSLOpenSSL;

//==============================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.9';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'netget';

//==============================================================================
function StreamToString(Stream : TStream) : String;
var ms : TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result,PChar(ms.memory),ms.Size);
  finally
    ms.free;
  end;
end;

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

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  xPLClient := TxPLListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER,false);
  xPLClient.OnxPLReceived   := @OnReceived;
  xPLClient.Listen;
end;

procedure TMyApplication.HTTPGet(aMsg : TxPLMessage);
var aURI, aRegExpr : string;
    HTTPConn : TIdHTTP;
    Parameters : TStringList;
    Page     : TMemoryStream;
    i : integer;
begin
   Page := TMemoryStream.Create;
   Parameters := TStringList.Create;

   HTTPConn := TIdHTTP.Create;
   if xPLClient.Settings.UseProxy then begin
      HTTPConn.ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
      HTTPConn.ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
   end;

   for i:=0 to aMsg.Body.Keys.Count-1 do begin
       if aMsg.Body.Keys[i] = 'regexpr' then aRegExpr := aMsg.Body.Values[i] else
       if aMsg.Body.Keys[i] = 'uri'     then aURI     := aMsg.Body.Values[i] else
          Parameters.Add(aMsg.Body.Keys[i] + '=' + aMsg.Body.Values[i]);
   end;

   HTTPConn.Post(aUri,Parameters,Page);
   with TRegExpr.Create do begin
        aMsg.MessageType := K_MSG_TYPE_TRIG;
        aMsg.Target.Tag  := aMsg.Source.Tag;
        Expression := aRegExpr;
        if Exec(StreamToString(Page)) then begin
           aMsg.Body.AddKeyValuePair('current','success');
           aMsg.Body.AddKeyValuePair('result',Match[1]);
        end else
           aMsg.Body.AddKeyValuePair('current','failed');
        xPLClient.Send(aMsg);
        Destroy;
   end;

   Parameters.Destroy;
   HTTPConn.Destroy;
   Page.Destroy;
end;

procedure TMyApplication.HTTPDownload(aMsg : TxPLMessage);
var aURI, aDestDir, aFileName, strOut : string;
begin
   aURI      := aMsg.Body.GetValueByKey('uri');
   aDestDir  := aMsg.Body.GetValueByKey('destdir');
   aFileName := aMsg.Body.GetValueByKey('destfn');
   strOut    := '';
   with xPLClient do begin
      GetHTTPFile(aURI,aDestDir + aFileName,ifthen(settings.useproxy,Settings.HTTPProxSrvr,''),Settings.HTTPProxPort,strOut);
      aMsg.Body.AddKeyValuePair('current',IfThen(strOut = '','done','error'));
      aMsg.MessageType := K_MSG_TYPE_TRIG;
      aMsg.Target.Assign(aMsg.Source);
      xPLClient.Send(aMsg);
   end;
end;

procedure TMyApplication.HTTPSDownload(aMsg : TxPLMessage);
var TmpFileStream : TFileStream;
    aURI, aDestDir, aFileName, strOut : string;
    IdHTTP : TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL : TIdSSLIOHandlerSocketOpenSSL;
begin
   aURI      := aMsg.Body.GetValueByKey('uri');
   aDestDir  := aMsg.Body.GetValueByKey('destdir');
   aFileName := aMsg.Body.GetValueByKey('destfn');

   IdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
   IdHTTP := TIdHTTP.Create;

   with IdHTTP do begin
        if xPLClient.Settings.UseProxy then begin
           ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
           ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
        end;
        IOHandler := IdSSLIOHandlerSocketOpenSSL;
        HandleRedirects := True;
   end;

   try
      TmpFileStream := TFileStream.Create(aDestDir + aFileName, fmCreate);
      strOut := 'done';
      try
         IdHTTP.Get(aURI, TmpFileStream);
      except
         strOut := 'error';
      end;
   finally
      FreeAndNil(TmpFileStream);
      //if strOut = 'error' then Delete(aDestDir + aFileName);
      IdHTTP.Destroy;
      IdSSLIOHandlerSocketOpenSSL.Destroy;
      xPLClient.SendMessage( K_MSG_TYPE_TRIG,aMsg.Source.Tag,K_SCHEMA_NETGET_BASIC, ['uri','current'],[aURI,strOut]);
   end;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);
var aProtocol,aURI : string;
begin
   if (axPLMsg.MessageType = K_MSG_TYPE_CMND) and (axPLMsg.Schema.Tag = 'netget.basic') then begin
      aProtocol := axPLMsg.Body.GetValueByKey('protocol');
      aURI      := axPLMsg.Body.GetValueByKey('uri');
      xPLClient.LogInfo('Retrieving %s',[aURI]);
      Case AnsiIndexStr(aProtocol,['get','http','https']) of
           0 : HTTPGet(axPLMsg);
           1 : HTTPDownload(axPLMsg);
           2 : HTTPSDownload(axPLMsg);
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

