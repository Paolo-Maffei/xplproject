unit uxPLWebListener;
{==============================================================================
  UnitName      = uxPLWebListener
  UnitDesc      = xPL Listener with WebServer capabilities
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
}

{$mode objfpc}{$H+}

interface

uses uxPLListener,Classes, SysUtils,
     ExtCtrls, IdGlobal,
     IdHTTPServer, IdContext,IdCustomHTTPServer;

type        { TxPLWebListener }
      TxPLWebCommandGet = procedure(var aPageContent : widestring; aParam, aValue : string) of object;

      TxPLWebListener = class(TxPLListener)
      protected
         fOnCommandGet : TxPLWebCommandGet;
      private
         fWebServer : TIdHTTPServer;
         fHtmlDir   : string;
         procedure InitWebServer;
         procedure DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
      public
         constructor create(aOwner : TComponent; aVendor, aDevice, aAppName, aAppVersion, aDefaultPort : string);
         destructor destroy; override;
         procedure CallConfigDone; override;
         property HtmlDir : string read fHtmlDir;
         property OnCommandGet : TxPLWebCommandGet read fOnCommandGet write fOnCommandGet;

      end;

         // HTML flow handling utilities
         function StringListToHtml(aSList : TStrings) : widestring;
         procedure HtmlReplaceVar(aVarName,aValue : string; var aPage : widestring);

implementation
uses IdStack,uxplcfgitem, cRandom, uxPLSchema, uIPutils,cStrings, StrUtils, RegExpr;

function StringListToHtml(aSList : TStrings) : widestring;
begin
     result := StrReplace(#13#10,'<br>',aSList.Text,false);
end;
procedure HtmlReplaceVar(aVarName,aValue : string; var aPage : widestring);
begin
     aPage := StrReplace('{%' + aVarName + '%}', aValue, aPage, false);
end;
{ TxPLWebListener ==============================================================}
resourcestring
   K_CONFIG_LIB_SERVER_ROOT = 'webroot';
   K_CONFIG_LIB_SERVER_PORT = 'webport';

procedure TxPLWebListener.InitWebServer;
begin
     with fWebServer.Bindings.Add do begin
          IP:=Setting.ListenOnAddress;
          Port:=StrToIntDef(Config.ItemName[K_CONFIG_LIB_SERVER_PORT].Value,8080);
     end;

     with fWebServer.Bindings.Add do begin
          IP:='127.0.0.1';
          Port:=StrToIntDef(Config.ItemName[K_CONFIG_LIB_SERVER_PORT].Value,8080);
     end;

     fWebServer.AutoStartSession := True;
     fWebServer.ServerSoftware := AppName;
     fWebServer.SessionTimeOut := 600000;
     fWebServer.SessionState := True;
     fWebServer.active:=true;
     fWebServer.OnCommandGet:=@DoCommandGet;
     fHtmlDir := Config.ItemName[K_CONFIG_LIB_SERVER_ROOT].Value;
end;

procedure TxPLWebListener.DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

function LoadAFile(aFileName : string) : widestring;
var sl : tstringlist;
begin
     sl := tstringlist.create;
     if not FileExists(aFileName) then result := ''
        else begin
             sl.LoadFromFile(aFileName);
             result := sl.Text;
        end;
     sl.Destroy;
end;

procedure SearchIncludes(var aText : widestring);
var i : widestring;
    bFound : boolean;
begin
   with TRegExpr.Create do try
      Expression := '<!--\s*\#\s*include\s+(file|virtual)\s*=\s*(["])([^"<>\|\~]+/)*([^"<>/\|\~]+)\2\s*-->';
      bFound := Exec(aText);
      while bFound do begin
         i := LoadAFile(htmlDir + Match[3] + Match[4]);
         Delete(aText,MatchPos[0],MatchLen[0]);
         Insert(i,aText,MatchPos[0]);
         bFound := Exec(aText);
      end;
      finally free;
   end;
end;

procedure ReplaceVariables(var aText : widestring);
begin
   HtmlReplaceVar('xPLAppName'     ,AppName,aText);
   HtmlReplaceVar('xPLAppVersion'  ,AppVersion,aText);
   HtmlReplaceVar('xPLHubStatus'   ,'Hub '           + IfThen(JoinedxPLNetWork,'','not') + ' found',aText);
   HtmlReplaceVar('xPLConfigStatus','Configuration ' + IfThen(AwaitingConfiguration,'pending','done'),aText);
end;


var LFilename: string;
    LPathname: string;
    s  : widestring;
    aParam,aValue : string;
begin
   LFilename := ARequestInfo.Document;
   if LFilename = '/' then LFilename := '/' + self.Address.Device + '/index.html';           // If no filename specified, we search one based on our own app name
   LPathname := HtmlDir + LFilename;
   if FileExists(LPathName) then begin
      if ExtractFileExt(LFileName)='.html' then begin
         aParam := '';
         aValue := '';
         if ARequestInfo.Params.Count>0 then begin
            aParam := ARequestInfo.Params.Names[0];
            aValue := ARequestInfo.Params.Values[aParam];
         end;
         s := LoadAFile(LPathName);
         if length(s)>0 then begin
            if Assigned(fOnCommandGet) then begin
               SearchIncludes(s);
               ReplaceVariables(s);
               fOnCommandGet(s,aParam,aValue);
               AResponseInfo.ContentText := s;
            end
         end
      end
      else
          AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
   end else begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := 'The requested URL ' + LPathName  + ' was not found on this server.';
   end;
end;

procedure TxPLWebListener.CallConfigDone;
begin
  inherited CallConfigDone;
  InitWebServer;
end;

constructor TxPLWebListener.create(aOwner: TComponent; aVendor, aDevice,aAppName, aAppVersion, aDefaultPort: string);
begin
   inherited Create(aOwner,aVendor,aDevice,aAppName,aAppVersion);
   fWebServer := TIdHttpServer.Create(self);
   Config.AddItem(K_CONFIG_LIB_SERVER_PORT,aDefaultPort,xpl_ctConfig, 1, 'Port used for local web server', '^(6553[0-5]|655[0-2]\d|65[0-4]\d\d|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3}|0)$');
   Config.AddItem(K_CONFIG_LIB_SERVER_ROOT,ExtractFilePath(ParamStr(0)) + 'html',xpl_ctConfig, 1, 'Web server root directory', '^[A-Za-z]:\\([^"*/:?|<>\\.\x00-\x20]([^"*/:?|<>\\\x00-\x1F]*[^"*/:?|<>\\.\x00-\x20])?\\)*$');
end;

destructor TxPLWebListener.destroy;
begin
  fWebServer.Destroy;
  inherited destroy;
end;

end.

