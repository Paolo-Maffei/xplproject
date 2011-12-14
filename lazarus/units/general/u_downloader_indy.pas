unit u_Downloader_Indy;

{$ifdef fpc}
{$mode delphi}
{$endif}

interface

uses Classes,
     IdHTTP,
     IdComponent,
     IdHeaderList;

type TDownloadAbordEvent = procedure(aSender : TObject; anError : integer) of object;

     { TDownloader }

     TDownloader = class
     private
        IdHTTP: TIdHTTP;
        XMLStream : TMemoryStream;
        fSourceURL : string;
        fDestFolder : string;
        fFileName : string;
        FOnWork: TWorkEvent;
        FOnWorkBegin: TWorkBeginEvent;
        FOnWorkEnd: TWorkEndEvent;
        FOnAbort  : TDownloadAbordEvent;

        procedure HeadersAvailable(Sender: TObject; AHeaders: TIdHeaderList; var VContinue: Boolean);
        procedure WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
        procedure Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
        procedure WorkEnd({%h-}ASender: TObject; AWorkMode: TWorkMode);
        procedure SetProxy(const aProxyInf : string);
     public
        constructor Create;
        destructor  Destroy; override;
        procedure   Start(const aSource, aDestination : string);

        property  OnWork: TWorkEvent read FOnWork write FOnWork;
        property  OnWorkBegin: TWorkBeginEvent read FOnWorkBegin write FOnWorkBegin;
        property  OnWorkEnd: TWorkEndEvent read FOnWorkEnd write FOnWorkEnd;
        property  OnWorkAbort : TDownloadAbordEvent read fOnAbort write fOnAbort;
        property  Source : string read fSourceURL;
     end;

     function HTTPDownload(const aSource, aDestination, aProxyInf : string) : boolean;

implementation // =============================================================
uses RegExpr
     , StrUtils
     , SysUtils
     ;

function HTTPDownload(const aSource, aDestination, aProxyInf : string) : boolean;
begin
   Result := True;
   with TDownloader.Create do try
      try
        SetProxy(aProxyInf);
        Start(aSource,aDestination);
      except
        Result := False;
      end;
   finally
      Free;
   end;
end;

constructor TDownloader.Create;
begin
   IdHTTP := TIdHTTP.Create(nil);
   IdHTTP.HandleRedirects := true;
   IdHTTP.OnHeadersAvailable := HeadersAvailable;
   IdHTTP.OnWorkBegin        := WorkBegin;
   IdHTTP.OnWorkEnd          := WorkEnd;
   IdHTTP.OnWork             := Work;
   XMLStream                 := TMemoryStream.Create;
end;

procedure TDownloader.HeadersAvailable(Sender: TObject; AHeaders: TIdHeaderList; var VContinue: Boolean);
begin
   vContinue := (fFileName<>'');                                                // either we have a filename provided by the program
   if not vContinue then with TRegExpr.Create do begin                          // either we try to find it in the http header
      Expression := 'filename=(.*?);';
      vContinue  := Exec(aHeaders.Text);
      if vContinue then fFileName := Match[1];                                  // If the filename is present in the http header
      Free;
   end;
   if not vContinue and Assigned(fOnAbort) then fOnAbort(self, 404);
end;

procedure TDownloader.Start(const aSource, aDestination : string);
begin
   fSourceURL   := aSource;
   fDestFolder  := ExtractFilePath(aDestination);
   fFileName    := ExtractFileName(aDestination);
   try
      IdHTTP.Get(fSourceURL,XMLStream);
   except
      On E : EIdHTTPProtocolException do if Assigned(fOnAbort) then fOnAbort(self, E.ErrorCode);
   end;
end;

procedure TDownloader.WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
   if Assigned(fOnWorkBegin) then fOnWorkBegin(aSender, aWorkMode, aWorkCountMax);
end;

procedure TDownloader.Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
   if Assigned(fOnWork) then fOnWork(aSender, aWorkMode, aWorkCount);
end;

procedure TDownloader.WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
   XMLStream.Seek(0,soFromBeginning);
   if XMLStream.Size<>0 then begin;
      DeleteFile(fDestFolder + fFileName);                                               // Be sure the file doesn't already exist with this name
      with TFileStream.Create(fDestFolder + fFileName, fmCreate) do begin
        CopyFrom(XMLStream,XMLStream.Size);
        Free;
      end;
   end else if Assigned(fOnAbort) then fOnAbort(self, 400);
   XMLStream.Clear;
   if Assigned(fOnWorkEnd) then fOnWorkEnd(self, aWorkMode);
end;

procedure TDownloader.SetProxy(const aProxyInf: string);
var sl : TStringList;
begin
   if length(aProxyInf)<>0 then begin
      sl := TStringList.Create;
      sl.Delimiter := ':';
      sl.DelimitedText:=aProxyInf;
      IdHTTP.ProxyParams.ProxyServer :=sl[0];
      IdHTTP.ProxyParams.ProxyPort   := StrToInt(sl[1]);
	  sl.Free;
   end;
end;

destructor TDownloader.Destroy;
begin
   IdHTTP.Free;
   XMLStream.Free;
   inherited Destroy;
end;


end.
