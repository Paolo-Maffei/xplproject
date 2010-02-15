unit uxPLWebListener;
{==============================================================================
  UnitName      = uxPLWebListener
  UnitDesc      = xPL Listener with WebServer capabilities
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
  0.93 : Modifications made for modif 0.92 for uxPLConfig
         Configuration handling modified to allow restart of web server after config modification
         without the need to restart the app
  0.94 : Changed to create ReplaceTag and ReplaceArrayedTag
}

{$mode objfpc}{$H+}

interface

uses uxPLListener,Classes, SysUtils, ExtCtrls, IdGlobal, uxPLMsgBody, uxPLMessage,
     IdHTTPServer, IdContext,IdCustomHTTPServer;

type
      TWebCommandGet = procedure(var aPageContent : widestring; aParam, aValue : string) of object;
      TWebCallReplaceTag= function(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean of object;
      TWebCallReplaceArrayedTag= function(const aDevice : string; const aVariable : string; ReturnList : TStringList) : boolean of object;

      { TxPLWebListener }

      TxPLWebListener = class(TxPLListener)
      protected
         //fOnCommandGet : TxPLWebCommandGet;
      private
         fWebServer : TIdHTTPServer;
         fHtmlDir   : string;
         fDiscovered : TStringList;
         procedure InitWebServer;
         procedure DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
         procedure HBeatApp(const axPLMsg : TxPLMessage);
      public
         constructor create(aOwner : TComponent; aVendor, aDevice, aAppName, aAppVersion, aDefaultPort : string);
         destructor destroy; override;
         procedure CallConfigDone; override;
         procedure FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string); override;
         property HtmlDir : string read fHtmlDir;
         OnCommandGet : TWebCommandGet; // read fOnCommandGet write fOnCommandGet;
         OnReplaceTag : TWebCallReplaceTag;
         OnReplaceArrayedTag : TWebCallReplaceArrayedTag;
      end;

         // HTML flow handling utilities
         function StringListToHtml(aSList : TStrings) : widestring;
         //procedure HtmlReplaceVar(aVarNames : array of string;aValues : array of string; var aPage : widestring);

implementation  { ==============================================================}
uses IdStack, cRandom,  uIPutils,cStrings, StrUtils, RegExpr, uxPLConst,
     uxPLMsgHeader;

{ Utility functions ============================================================}

function StringListToHtml(aSList : TStrings) : widestring;
begin
     result := StrReplace(#13#10,'<br>',aSList.Text,false);
end;
{procedure HtmlReplaceVar(aVarNames : array of string;aValues : array of string; var aPage : widestring);
var i : integer;
begin
     for i:=low(aVarNames) to high(aVarNames) do
     aPage := AnsiReplaceStr(aPage,'{%' + aVarNames[i] + '%}', aValues[i]);
end;}
{ TxPLWebListener ==============================================================}
resourcestring
   K_CONFIG_LIB_SERVER_ROOT = 'webroot';

destructor TxPLWebListener.destroy;
begin
  if Assigned(fWebServer) then begin
     LogInfo('Stopping web server');
     fWebServer.Active := false;
     FreeAndNil(fWebServer);
  end;
  fDiscovered.Destroy;
  inherited destroy;
end;

procedure TxPLWebListener.InitWebServer;
begin
     if Assigned(fWebServer) then fWebServer.Destroy;

     fWebServer := TIdHttpServer.Create(self);

     with fWebServer.Bindings.Add do begin
          IP:=K_IP_LOCALHOST;
          Port:=StrToIntDef(Config.ItemName[K_HBEAT_ME_WEB_PORT].Value,K_IP_DEFAULT_WEB_PORT);
     end;

     if Setting.ListenOnAddress<>K_IP_LOCALHOST then with fWebServer.Bindings.Add do begin
          IP:=Setting.ListenOnAddress;
          Port:=StrToIntDef(Config.ItemName[K_HBEAT_ME_WEB_PORT].Value,K_IP_DEFAULT_WEB_PORT);
     end;

     LogInfo('Starting web server on port ' + IntToStr(fWebServer.Bindings[0].Port));

     with fWebServer do try
        AutoStartSession := True;
        ServerSoftware := AppName;
        SessionTimeOut := 600000;
        SessionState := True;
        Active:=true;
     except
        on E : Exception do LogError(E.ClassName+' error raised, with message : '+E.Message);
     end;

     fWebServer.OnCommandGet:=@DoCommandGet;
     fHtmlDir := Config.ItemName[K_CONFIG_LIB_SERVER_ROOT].Value;

     LogInfo('Webroot located in ' + fHtmlDir);
end;

procedure TxPLWebListener.DoCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var LFilename: string;
    LPathname: string;
    s  : widestring;
    aParam,aValue : string;
    RegExpr : TRegExpr;

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
   RegExpr.Expression := K_WEB_RE_INCLUDE;
   bFound := RegExpr.Exec(aText);
   while bFound do with RegExpr do begin
      i := LoadAFile(htmlDir + Match[3] + Match[4]);
      Delete(aText,MatchPos[0],MatchLen[0]);
      Insert(i,aText,MatchPos[0]);
      bFound := RegExpr.Exec(aText);
   end;
end;

procedure ReplaceVariables(var aText : widestring; aParam, aValue : string);

function ReplaceTag(const aDevice : string; const aVariable : string; out ReplaceString : string) : boolean;
begin
   if aDevice<>'xplweb' then exit;
   ReplaceString := '';
   if aVariable = 'appname'      then ReplaceString := AppName
   else if aVariable = 'appversion'   then ReplaceString := AppVersion
   else if aVariable = 'hubstatus'    then ReplaceString := Format(K_MSG_HUB_FOUND,[IfThen(JoinedxPLNetWork,'','not')])
   else if aVariable = 'configstatus' then ReplaceString := Format(K_MSG_CONFIGURED,[IfThen(AwaitingConfiguration,'pending','done')]);
   result := ReplaceString<>'';
end;

var bLoop   : boolean;
    sReplace: string;
    sDuplicate : widestring;
    tag,device,variable : string;
begin
   sDuplicate := aText;
   RegExpr.Expression := K_WEB_RE_VARIABLE;           //  {%appli_variable%}
   bLoop := RegExpr.Exec(sDuplicate);
   while bLoop do with RegExpr do begin
      tag := Match[0];
      device := AnsiLowerCase(Match[1]);
      variable := AnsiLowercase(Match[2]);
      if device='xplweb' then begin
         if ReplaceTag(device,variable,sReplace) then aText := AnsiReplaceStr(aText,tag, sReplace);
      end else
             if Assigned(OnReplaceTag) then
                if OnReplaceTag(device,aParam,aValue,variable,sReplace) then aText := AnsiReplaceStr(aText,tag, sReplace);

      bLoop := RegExpr.ExecNext;
   end;
end;

procedure LoopOnTemplate(var aPageContent : widestring);

function ReplaceArrayedTag(const aDevice : string; const aVariable : string; ReturnList : TStringList) : boolean;
var i : integer;
begin
   if aDevice<>'xplweb' then exit;
   ReturnList.Clear;
   if aVariable = 'webappurl'  then for i:=0 to fDiscovered.Count-1 do ReturnList.Add(fDiscovered.ValueFromIndex[i]);
   if aVariable = 'webappname' then for i:=0 to fDiscovered.Count-1 do ReturnList.Add(fDiscovered.Names[i]);
   if aVariable = 'log'        then ReturnList.AddStrings(fLogList); //for i:=0 to fLogList.Count-1 do ReturnList.Add(fLogList[i]);
   result := (ReturnList.Count >0);
end;
var
  Pattern : string;
  Where   : integer;
  i       : integer;
  ReturnList,PatternList : TStringList;
  bLoop : boolean;
  tag,device,variable : string;
  bFirstVariable : boolean;
begin
     Pattern := StrBetween(aPageContent,K_WEB_TEMPLATE_BEGIN,K_WEB_TEMPLATE_END);
     if length(Pattern) = 0 then exit;
     bFirstVariable := True;
     ReturnList := TStringList.Create;
     PatternList := TStringList.Create;

     RegExpr.Expression := K_WEB_RE_VARIABLE;           //  {%appli_variable%}
     bLoop := RegExpr.Exec(Pattern);
     while bLoop do with RegExpr do begin
        tag := Match[0];
        device := AnsiLowerCase(Match[1]);
        variable := AnsiLowercase(Match[2]);

        if Device = 'xplweb' then begin
           if ReplaceArrayedTag(device,variable,ReturnList) then
              for i:=0 to ReturnList.Count-1 do begin
                  if bFirstVariable then PatternList.Add(Pattern);
                  PatternList[i] := StringReplace(PatternList[i],tag,ReturnList[i],[rfIgnoreCase, rfReplaceAll ]);
              end;
        end else
        if Assigned(OnReplaceArrayedTag) then
           if OnReplaceArrayedTag(device,variable,ReturnList) then
           for i:=0 to ReturnList.Count-1 do begin
               if bFirstVariable then PatternList.Add(Pattern);
               PatternList[i] := StringReplace(PatternList[i],tag,ReturnList[i],[rfIgnoreCase, rfReplaceAll]);
           end;

      if PatternList.Count>0 then bFirstVariable := False;
      bLoop := ExecNext;
   end;

   Where  := AnsiPos(K_WEB_TEMPLATE_BEGIN, aPageContent);
   Delete(aPageContent,Where,length(K_WEB_TEMPLATE_END + K_WEB_TEMPLATE_BEGIN +Pattern));
   Insert(PatternList.Text,aPageContent,Where);
   PatternList.Destroy;
   ReturnList.Destroy;
end;

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
            RegExpr := TRegExpr.Create;
            SearchIncludes(s);
            if Assigned(OnCommandGet) then OnCommandGet(s,aParam,aValue);
            ReplaceVariables(s, aParam, aValue);
            LoopOnTemplate(s);
            AResponseInfo.ContentText := s;
            RegExpr.Destroy;
         end
      end
      else
          AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
   end else begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := 'The requested URL ' + LPathName  + ' was not found on this server.';
   end;
end;

procedure TxPLWebListener.HBeatApp(const axPLMsg: TxPLMessage);
var aPort : string;
    anApp : string;
    anIP  : string;
begin
   aPort := axPLMsg.Body.GetValueByKey(K_HBEAT_ME_WEB_PORT);
   if aPort = '' then exit;

   anApp := axPLMsg.Body.GetValueByKey(K_HBEAT_ME_APPNAME);
   anIP  := axPLMsg.Body.GetValueByKey(K_HBEAT_ME_REMOTEIP);
   if fDiscovered.IndexOfName(anApp)=-1 then
      fDiscovered.Add(anApp+'=http://'+anIP+':'+aPort);           // Compose a phrase like xPL Application=http://192.168.0.10:8336
end;

procedure TxPLWebListener.CallConfigDone;
begin
  inherited CallConfigDone;
  InitWebServer;
  SendMessage(xpl_mtCmnd,'*',K_SCHEMA_HBEAT_REQUEST+#10'{'#10'command=request'#10'}'#10); // Issue a general Hbeat request to enhance other web app discovery
end;

procedure TxPLWebListener.FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string);
begin
  inherited FinalizeHBeatMsg(aBody,aPort,aIP);
  if Config.ItemName[K_HBEAT_ME_WEB_PORT].Value<>'' then aBody.AddKeyValuePair(K_HBEAT_ME_WEB_PORT,Config.ItemName[K_HBEAT_ME_WEB_PORT].Value);
end;

constructor TxPLWebListener.create(aOwner: TComponent; aVendor, aDevice,aAppName, aAppVersion, aDefaultPort: string);
begin
   inherited Create(aOwner,aVendor,aDevice,aAppName,aAppVersion);
   fDiscovered := TStringList.Create;
   fDiscovered.Duplicates := dupIgnore;
   Config.AddItem(K_HBEAT_ME_WEB_PORT,xpl_ctConfig,aDefaultPort);
   Config.AddItem(K_CONFIG_LIB_SERVER_ROOT,xpl_ctConfig,ExtractFilePath(ParamStr(0)) + 'html');
   OnxPLHBeatApp := @HBeatApp;

end;

end.

