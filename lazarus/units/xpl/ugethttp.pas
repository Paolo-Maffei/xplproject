unit uGetHTTP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

  procedure WGetHTTPFile(aSourceURI, aTargetFile : string);
  function GetHTTPFile(aSourceURI, aTargetFile : string) : boolean;

implementation
uses LCLType,IdURI,httpprothandler;

procedure WGetHTTPFile(aSourceURI, aTargetFile : string);
var GURL : TIdURI;
begin
    GURL := TIdURI.Create;
    GURL.URI := aSourceURI;

    if THTTPProtHandler.CanHandleURL(GURL) then
       with THTTPProtHandler.Create(aTargetFile) do
          try
            GetFile(GURL);
          finally
            Destroy;
          end;

    GURL.Destroy;
end;

function GetHTTPFile(aSourceURI, aTargetFile : string) : boolean;
var GURL : TIdURI;
begin
    result := true;
    GURL := TIdURI.Create;
    GURL.URI := aSourceURI;

    if THTTPProtHandler.CanHandleURL(GURL) then
       with THTTPProtHandler.Create(aTargetFile) do begin
          try
            GetFile(GURL);
          except
            on E : Exception do result := false ;
          end;
          Destroy;
    end;
    GURL.Destroy;
end;

end.

