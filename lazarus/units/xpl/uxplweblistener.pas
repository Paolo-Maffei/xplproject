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

uses uxPLListener,Classes, SysUtils, IdGlobal, uxPLMsgBody, uxPLMessage,
     IdHTTPServer, IdContext,IdCustomHTTPServer;

type
      //TWebCommandGet = procedure(var aPageContent : widestring; aParam, aValue : string) of object;
      TWebCommandGet = procedure(var aPageContent : widestring; ARequestInfo: TIdHTTPRequestInfo) of object;
      TWebCallReplaceTag       = function(const aDevice : string; const aParam : string; aValue : string; const aVariable : string; out ReplaceString : string) : boolean of object;
      TWebCallReplaceArrayedTag= function(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean of object;

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

      public
         constructor create(aVendor, aDevice, aAppVersion, aDefaultPort : string);
         destructor destroy; override;
         procedure CallConfigDone; override;
         procedure FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string); override;
         procedure HBeatApp(const axPLMsg : TxPLMessage);
         OnCommandGet : TWebCommandGet; // read fOnCommandGet write fOnCommandGet;
         OnReplaceTag : TWebCallReplaceTag;
         OnReplaceArrayedTag : TWebCallReplaceArrayedTag;

         property HtmlDir : string read fHtmlDir;
      end;

         // HTML flow handling utilities
         function StringListToHtml(aSList : TStrings) : widestring;
         //procedure HtmlReplaceVar(aVarNames : array of string;aValues : array of string; var aPage : widestring);

implementation  { ==============================================================}
uses IdStack, cRandom,  uIPutils,cStrings, StrUtils, RegExpr, uxPLConst,
     uxPLMsgHeader,  cUtils;

{ Utility functions ============================================================}

function StringListToHtml(aSList : TStrings) : widestring;
begin
     result := StrReplace(#13#10,'<br>',aSList.Text,false);
end;
{ TxPLWebListener ==============================================================}
resourcestring
   K_CONFIG_LIB_SERVER_ROOT = 'webroot';

destructor TxPLWebListener.destroy;
begin
  if Assigned(fWebServer) then begin
     LogInfo(K_WEB_MSG_SRV_STOP,[]);
     fWebServer.Active := false;
     FreeAndNil(fWebServer);
  end;
  fDiscovered.Destroy;
  inherited destroy;
end;

procedure TxPLWebListener.InitWebServer;
begin
     if Assigned(fWebServer) then fWebServer.Destroy;

     fWebServer := TIdHttpServer.Create(nil);

     with fWebServer.Bindings.Add do begin
          IP:=K_IP_LOCALHOST;
          Port:=StrToIntDef(Config.ItemName[K_HBEAT_ME_WEB_PORT].Value,K_IP_DEFAULT_WEB_PORT);
     end;

     if Settings.ListenOnAddress<>K_IP_LOCALHOST then with fWebServer.Bindings.Add do begin
          IP:=Settings.ListenOnAddress;
          Port:=StrToIntDef(Config.ItemName[K_HBEAT_ME_WEB_PORT].Value,K_IP_DEFAULT_WEB_PORT);
     end;

     LogInfo(K_WEB_MSG_PORT,[fWebServer.Bindings[0].Port]);

     with fWebServer do try
        AutoStartSession := True;
        ServerSoftware := AppName;
        SessionTimeOut := 600000;
        SessionState := True;
        Active:=true;
     except
        on E : Exception do LogError(K_MSG_GENERIC_ERROR,[E.ClassName,E.Message]);
     end;

     fWebServer.OnCommandGet:=@DoCommandGet;
     fHtmlDir := Config.ItemName[K_CONFIG_LIB_SERVER_ROOT].Value;

     LogInfo(K_WEB_MSG_ROOT_DIR,[fHtmlDir]);
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
   else if aVariable = 'devicename' then ReplaceString := Device
   else if aVariable = 'appversion'   then ReplaceString := AppVersion
   else if aVariable = 'hubstatus'    then ReplaceString := Format(K_MSG_HUB_FOUND,[IfThen(JoinedxPLNetWork,'','not')])
   else if aVariable = 'configstatus' then ReplaceString := Format(K_MSG_CONFIGURED,[IfThen(Config.ConfigNeeded,'pending','done')]);
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
var i,j : integer;
    menuName, menuAction, variable, optionlist, entryzone : string;
    valuelist : stringArray;
    bLoop : boolean;
begin
   if aDevice<>'xplweb' then exit;

   ReturnList.Clear;
   if aVariable = 'webappurl'  then for i:=0 to fDiscovered.Count-1 do ReturnList.Add(fDiscovered.ValueFromIndex[i])
   else if aVariable = 'webappname' then for i:=0 to fDiscovered.Count-1 do ReturnList.Add(fDiscovered.Names[i])
   else if aVariable = 'log'        then ReturnList.LoadFromFile(self.LogFileName)
   else if aVariable = 'menuitem'   then begin
           if Assigned(Config.DeviceInVendorFile) then
              for i:=0 to Config.DeviceInVendorFile.MenuItems.Count-1 do begin
                  menuName   := Config.DeviceInVendorFile.MenuItems[i];
                  menuAction := Config.DeviceInVendorFile.MenuItem(menuName);
                  with TRegExpr.Create do begin
                       EntryZone  := '';
                       Expression :=K_MNU_ITEM_RE_PARAMETER;                              // Search for parameters
                       bLoop      := Exec(menuAction);
                       while bLoop do begin                                               // Loop on every parameter found
                             Variable := Match[1];
                             if AnsiPos(K_MNU_ITEM_OPTION_SEP,Variable) = 0 then
                                EntryZone += Format(K_MNU_ITEM_INPUT_TEXT,[Match[1],Match[0]])
                             else begin
                                valuelist  := StrSplit(Variable+K_MNU_ITEM_OPTION_SEP,K_MNU_ITEM_OPTION_SEP);
                                optionlist := '';
                                for j:=0 to high(valuelist)-1 do optionlist += Format(K_MNU_ITEM_OPTION_LIST,[valuelist[j],valuelist[j]]);
                                EntryZone += Format(K_MNU_ITEM_SELECT_LIST,[Match[0],optionlist]);
                             end;
                             bLoop := ExecNext;
                       end;
                       Destroy;
                  end;
                  EntryZone += Format(K_MNU_ITEM_MSG_AND_SUBMIT,[menuAction,menuName]);
                  returnlist.Add(Format(K_MNU_ITEM_ACTION_ZONE,[EntryZone]));
              end;
        end;
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
           if OnReplaceArrayedTag(device,aValue,variable,ReturnList) then
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

procedure HandleMenuItem;
var commande, aPar : string;
    i : integer;
begin
   commande := ARequestInfo.Params.Values['xplMsg'];
   for i := 0 to ARequestInfo.Params.Count-1 do begin
      aPar := ARequestInfo.Params.Names[i];
      if AnsiPos('%',aPar) <> 0 then commande := AnsiReplaceStr(commande,aPar,ARequestInfo.Params.Values[aPar]);
   end;

   SendMessage(K_MSG_TYPE_CMND,self.Address.Tag,commande, true);
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
         if ARequestInfo.Params.Values['xPLWeb_menuItem']<>'' then HandleMenuItem;
         s := LoadAFile(LPathName);
         if length(s)>0 then begin
            RegExpr := TRegExpr.Create;
            SearchIncludes(s);
            if Assigned(OnCommandGet) then OnCommandGet(s,ARequestInfo);
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
      AResponseInfo.ContentText := Format(K_WEB_ERR_404,[LPathName]);
   end;
end;

procedure TxPLWebListener.HBeatApp(const axPLMsg: TxPLMessage);
const DiscString = '%s=http://%s:%s';
var aPort : string;
    anApp : string;
begin
   aPort := axPLMsg.Body.GetValueByKey(K_HBEAT_ME_WEB_PORT);
   if aPort = '' then exit;

   anApp := axPLMsg.Body.GetValueByKey(K_HBEAT_ME_APPNAME);
   if fDiscovered.IndexOfName(anApp)=-1 then fDiscovered.Add(Format(DiscString,[anApp, axPLMsg.Body.GetValueByKey(K_HBEAT_ME_REMOTEIP), aPort]));
end;

procedure TxPLWebListener.CallConfigDone;
begin
   InitWebServer;
   SendMessage(K_MSG_TYPE_CMND,'*',K_SCHEMA_HBEAT_REQUEST+#10'{'#10'command=request'#10'}'#10); // Issue a general Hbeat request to enhance other web app discovery
   inherited CallConfigDone;
end;

procedure TxPLWebListener.FinalizeHBeatMsg(const aBody  : TxPLMsgBody; const aPort : string; const aIP : string);
begin
   inherited FinalizeHBeatMsg(aBody,aPort,aIP);
   if Config.ItemName[K_HBEAT_ME_WEB_PORT].Value<>'' then aBody.AddKeyValuePair(K_HBEAT_ME_WEB_PORT,Config.ItemName[K_HBEAT_ME_WEB_PORT].Value);
end;

constructor TxPLWebListener.create(aVendor, aDevice, aAppVersion, aDefaultPort: string);
begin
   inherited Create(aVendor,aDevice,aAppVersion);
   fDiscovered := TStringList.Create;
   fDiscovered.Duplicates := dupIgnore;
   Config.AddItem(K_HBEAT_ME_WEB_PORT,K_XPL_CT_CONFIG,aDefaultPort);
   Config.AddItem(K_CONFIG_LIB_SERVER_ROOT,K_XPL_CT_CONFIG,ExtractFilePath(ParamStr(0)) + 'html');
   OnxPLHBeatApp := @HBeatApp;
   LogInfo(K_MSG_LISTENER_STARTED,[AppName,aAppVersion]);
end;

end.

