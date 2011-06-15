unit u_Downloader_Synapse;

{$mode objfpc}

interface

uses Classes,
     HTTPSend,
     blcksock;

type THttpFile=class(THttpSend)
     private
     public
      function Download(const aURL,aFileName:string):boolean;
     end;

implementation
uses uRegExpr,
     SysUtils;

function THttpFile.Download(const aURL,aFileName: string): boolean;
begin
  result := HTTPMethod('GET', aURL);
  if result then
     with TFileStream.Create(aFileName,fmCreate or fmOpenWrite) do
     try
       Seek(0, soFromBeginning);
       CopyFrom(Document, 0);
     finally
       Free;
     end;

end;

end.


