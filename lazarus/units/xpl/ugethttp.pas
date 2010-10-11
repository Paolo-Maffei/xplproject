unit uGetHTTP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

  //procedure WGetHTTPFile(aSourceURI, aTargetFile,ProxySrvr,ProxyPort : string);
  function GetHTTPFile(aSourceURI, aTargetFile,ProxySrvr,ProxyPort : string; out StrOut : string) : boolean;

implementation
uses LCLType,IdURI,uhttpprothandler;

{procedure WGetHTTPFile(aSourceURI, aTargetFile,ProxySrvr,ProxyPort : string);
var GURL : TIdURI;
begin
    GURL := TIdURI.Create;
    GURL.URI := aSourceURI;

    if THTTPProtHandler.CanHandleURL(GURL) then
       with THTTPProtHandler.Create(aTargetFile,ProxySrvr,ProxyPort) do
          try
            GetFile(GURL);
          finally
            Destroy;
          end;

    GURL.Destroy;
end;}

function GetHTTPFile(aSourceURI, aTargetFile,ProxySrvr,ProxyPort : string; out StrOut : string) : boolean;
var GURL : TIdURI;
begin
    GURL := TIdURI.Create;
    GURL.URI := aSourceURI;

    if THTTPProtHandler.CanHandleURL(GURL) then
       with THTTPProtHandler.Create(aTargetFile,ProxySrvr,ProxyPort) do begin
          StrOut :=  GetFile(GURL);
          result := (StrOut = '');
          Destroy;
    end;
    GURL.Destroy;
end;

end.

