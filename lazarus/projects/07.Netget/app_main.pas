unit app_main;

{$APPTYPE CONSOLE}
{$DEFINE CONSOLE_APP}
{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     CustApp,
     u_xPL_Message,
     u_xPL_Custom_Listener;

type

{ TMyApplication }

TMyNetGetApp = class(TCustomApplication)
     protected
        procedure DoRun; override;
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnCmndReceived(const aMsg : TxPLMessage);
        procedure  Log(const aString : string); overload;
        destructor Destroy; override;
        procedure HTTPGet(aMsg : TxPLMessage);
        procedure HTTPDownload(aMsg : TxPLMessage);
        procedure HTTPSDownload(aMsg : TxPLMessage);
     end;

var  MyNetGetApp : TMyNetGetApp;
     xPLClient    : TxPLCustomListener;

implementation //===============================================================
uses uxPLConst,
     FileUtil,
     uGetHTTP,
     uRegExpr,
     StrUtils,
     IdHTTP,
     u_xpl_common,
     u_xpl_header,
     IdSSLOpenSSL;

procedure TMyNetGetApp.DoRun;
begin
   CheckSynchronize(1000);
end;

constructor TMyNetGetApp.Create(TheOwner: TComponent);
begin
   inherited Create(TheOwner);
   xPLClient := TxPLCustomListener.Create(nil);
   xPLClient.OnxPLReceived := @OnCmndReceived;
   Title := xPLClient.AppName;
   xPLClient.Listen;
end;

procedure TMyNetGetApp.HTTPGet(aMsg : TxPLMessage);
var aURI, aRegExpr : string;
    HTTPConn : TIdHTTP;
    Parameters : TStringList;
    Page     : TMemoryStream;
    i : integer;
begin
   Page := TMemoryStream.Create;
   Parameters := TStringList.Create;

   HTTPConn := TIdHTTP.Create;
{   if xPLClient.Settings.UseProxy then begin
      HTTPConn.ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
      HTTPConn.ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
   end;}

   for i:=0 to aMsg.Body.Keys.Count-1 do begin
       if aMsg.Body.Keys[i] = 'regexpr' then aRegExpr := aMsg.Body.Values[i] else
       if aMsg.Body.Keys[i] = 'uri'     then aURI     := aMsg.Body.Values[i] else
          Parameters.Add(aMsg.Body.Keys[i] + '=' + aMsg.Body.Values[i]);
   end;

   HTTPConn.Post(aUri,Parameters,Page);
   with TRegExpr.Create do begin
        aMsg.MessageType := trig;
        aMsg.Target.Assign(aMsg.Source);
        Expression := aRegExpr;
        if Exec(StreamToString(Page)) then begin
           aMsg.Body.AddKeyValuePairs(['current','result'],['success',Match[1]]);
        end else
           aMsg.Body.AddKeyValuePairs(['current'],['failed']);
        xPLClient.Send(aMsg);
        Destroy;
   end;

   Parameters.Destroy;
   HTTPConn.Destroy;
   Page.Destroy;
end;

procedure TMyNetGetApp.HTTPDownload(aMsg : TxPLMessage);
var aURI, aDestDir, aFileName, strOut : string;
begin
   aURI      := aMsg.Body.GetValueByKey('uri');
   aDestDir  := aMsg.Body.GetValueByKey('destdir');
   aFileName := aMsg.Body.GetValueByKey('destfn');
   strOut    := '';
   with xPLClient do begin
//      GetHTTPFile(aURI,aDestDir + aFileName,ifthen(settings.useproxy,Settings.HTTPProxSrvr,''),Settings.HTTPProxPort,strOut);
      GetHTTPFile(aURI,aDestDir + aFileName,'','0',strOut);
      aMsg.Body.AddKeyValuePairs(['current'],[IfThen(strOut = '','done','error')]);
      aMsg.MessageType := trig;
      aMsg.Target.Assign(aMsg.Source);
      xPLClient.Send(aMsg);
   end;
end;

procedure TMyNetGetApp.HTTPSDownload(aMsg : TxPLMessage);
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
(*        if xPLClient.Settings.UseProxy then begin
           ProxyParams.ProxyServer:=xPLClient.Settings.HTTPProxSrvr;
           ProxyParams.ProxyPort:=StrToInt(xPLClient.Settings.HTTPProxPort);
        end;*)
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
      xPLClient.SendMessage( trig,aMsg.Source.RawxPL,'netget.basic', ['uri','current'],[aURI,strOut]);
   end;
end;

procedure TMyNetGetApp.OnCmndReceived(const aMsg: TxPLMessage);
var aProtocol,aURI : string;
begin
   if (aMsg.MessageType = cmnd) and (AnsiCompareText(aMsg.Schema.RawxPL,'netget.basic') = 0) then begin
      aProtocol := aMsg.Body.GetValueByKey('protocol');
      aURI      := aMsg.Body.GetValueByKey('uri');
      xPLClient.Log(etInfo,'Retrieving %s',[aURI]);
      Case AnsiIndexStr(aProtocol,['get','http','https']) of
           0 : HTTPGet(aMsg);
           1 : HTTPDownload(aMsg);
           2 : HTTPSDownload(aMsg);
      end;
   end;
end;

procedure TMyNetGetApp.Log(const aString: string);
begin
   writeln(aString);
end;

destructor TMyNetGetApp.Destroy;
begin
   xPLClient.Destroy;
   inherited Destroy;
end;

initialization
   MyNetGetApp:=TMyNetGetApp.Create(nil);
end.
