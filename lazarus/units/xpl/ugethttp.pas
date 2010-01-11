unit uGetHTTP;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

  procedure WGetHTTPFile(aSourceURI, aTargetFile : string);

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

end.

