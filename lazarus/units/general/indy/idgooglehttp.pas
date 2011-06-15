unit IdGoogleHTTP;

{$mode objfpc}

interface

uses Classes
     , SysUtils
     , IdHTTP
     , IdSSLOpenSSL
     ;

Type

{ TIdGoogleHTTP }

     TIdGoogleHTTP = class(TIdHTTP)
     private
        IdSSLIOHandlerSocket1: TIdSSLIOHandlerSocketOpenSSL;
     public
        constructor Create(AOwner: TComponent); overload;
     end;

implementation

{ TIdGoogleHTTP }

constructor TIdGoogleHTTP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  IdSSLIOHandlerSocket1 := TIdSSLIOHandlerSocketOpenSSL.create(aOwner);
  with IdSSLIOHandlerSocket1 do begin
    SSLOptions.Method := sslvSSLv3;
    SSLOptions.Mode :=  sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 2;
  end;

  IOHandler := IdSSLIOHandlerSocket1;
  ReadTimeout := 0;
  AllowCookies := True;
  ProxyParams.BasicAuthentication := False;
  ProxyParams.ProxyPort := 0;
  Request.ContentLength := -1;
  Request.ContentRangeEnd := 0;
  Request.ContentRangeStart := 0;
  Request.ContentType := 'application/x-www-form-urlencoded';
  request.host := 'https://www.google.com';
  Request.Accept := 'text/html, */*';
  Request.CustomHeaders.Add('GData-Version: 2.0');
  Request.UserAgent := 'Mozilla/3.0 (compatible; Indy Library)';
  HTTPOptions := [hoForceEncodeParams];

end;

end.

