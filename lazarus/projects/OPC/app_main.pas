unit app_main;

{$i compiler.inc}

interface

uses
  Classes,
  CustApp,
  uxPLMessage,
  uxPLWebListener,
  uxPLConfig,
  IdContext,
  IdComponent,
  IdCustomHTTPServer,
  u_xpl_udp_socket,
  u_xpl_opc,
  SysUtils;

type TMyApplication = class(TCustomApplication)
     protected
        XHCPServer : TXHCPServer;
        procedure DoRun; override;
     public
         aNewRule : TStringList;
         aNewConfig : TStringList;
        constructor Create(TheOwner: TComponent); override;
        destructor Destroy; override;
        procedure TelnetServerConnect(AContext: TIdContext);
        procedure TelnetServerExecute(AContext: TIdContext);
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLOPC;

implementation //======================================================================================
uses cStrings, strUtils, uRegExTools, uxPLConst,  DateUtils, cDateTime, DeCAL;
//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.1';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'opc';

     K_CAPABILITIES_MANAGE_CONFIGURATION : boolean = true;
     K_CAPABILITIES_XAP_SUPPORT : boolean = false;
     K_CAPABILITIES_PRIMARY_LANGUAGE : string = 'A';
     K_CAPABILITIES_DETERMINATORS : boolean = true;
     K_CAPABILITIES_EVENTS : boolean = true;
     K_CAPABILITIES_SERVER_PLATFORM : string = {$IFDEF WINDOWS}'W'{$ELSE}'L'{$ENDIF};
     K_CAPABILITIES_STATE_TRACKING : boolean = true;
     K_XHCP_LOGIN                 = '%d %s Version %s XHCP %s';

procedure TMyApplication.DoRun;
var ErrorMsg: String;
begin
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    Terminate;
    Exit;
  end;

  while true do begin
        CheckSynchronize;
  end;
  Terminate;
end;


constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;

   xPLClient := TxPLOPC.Create(self,K_XPL_APP_VERSION_NUMBER);
   xPLClient.Listen;

   XHCPServer := TXHCPServer.Create(Self);
   XHCPServer.OnConnect := @TelnetServerConnect;
   XHCPServer.OnExecute := @TelnetServerExecute;

  aNewRule := nil;
end;

destructor TMyApplication.Destroy;
begin
  XHCPServer.Destroy;
  xPLClient.Destroy;
  inherited Destroy;
end;

procedure TMyApplication.TelnetServerConnect(AContext: TIdContext);
begin
  AContext.Connection.IOHandler.WriteLn(Format(K_XHCP_LOGIN,[200,xPLClient.Address.Tag,K_XPL_APP_VERSION_NUMBER,xPLClient.XHCP_Version]));
  xPLClient.LogInfo('connexion',[]);
end;

procedure TMyApplication.TelnetServerExecute(AContext: TIdContext);
procedure PushString(const aString : string);
begin
   AContext.Connection.IOHandler.WriteLn(aString);
   xPLClient.LogInfo(aString,[]);
end;

procedure PushListe(const aHeader : string; const aStringList : TStringList);
var i : integer;
begin
   PushString(aHeader);
   for i:=0 to aStringList.Count-1 do PushString(aStringList[i]);
   PushString('.');
end;

var received : string;
    command, parameter : string;
    param1, param2     : string;
    chaine : string;
    i : integer;
    listelocale : tstringlist;


begin
   received := sysutils.Trim(AContext.Connection.IOHandler.ReadLn);
   if received = 'quit' then begin
      exit;
   end;
   if aNewRule<>nil then begin                                  // We're waiting for a new rule definition
      if received = '.' then begin
         parameter := aNewRule[0];                              // get back the provided parameter
         aNewRule.Delete(0);                                    // erase it from the rule definition
         PushString('238 ' + xPLClient.Determinators.Add(parameter,aNewRule));
         aNewRule.Free;
         aNewRule:=nil;
      end else
          aNewRule.Add(received);
      exit;
   end;
   if aNewConfig<>nil then begin                                  // We're waiting for a new parameter set for a device configuration
      if received = '.' then begin

         PushString('220 Configuration items received successfully');
         aNewConfig.Free;
         aNewConfig:=nil;
      end else
          aNewConfig.Add(received);
      exit;
   end;

   StrSplitAtChar(received,' ',command,parameter);
   xPLClient.LogInfo('Received : %s %s',[command,parameter]);
   listelocale := TStringList.create;
   if Command = 'CAPABILITIES' then begin // CAPABILITIES - Server Capabilities
      chaine := IfThen(K_CAPABILITIES_MANAGE_CONFIGURATION,'1','0') + IfThen(K_CAPABILITIES_XAP_SUPPORT,'1','-') +
                       K_CAPABILITIES_PRIMARY_LANGUAGE +                     IfThen(K_CAPABILITIES_DETERMINATORS,'1','0') +
                       IfThen(K_CAPABILITIES_EVENTS,'1','0') +               K_CAPABILITIES_SERVER_PLATFORM +
                       IfThen(K_CAPABILITIES_STATE_TRACKING,'1','0');
             if parameter = 'SCRIPTING' then begin
                PushString('241 ' + chaine);
                PushString(Format('%s'#9'%s'#9'%s'#9'%s'#9'%s',[K_CAPABILITIES_PRIMARY_LANGUAGE,'PascalScript',K_XPL_APP_VERSION_NUMBER,K_FEXT_PAS,'http://www.remobjects.com/ps.aspx']));
                PushString('.');
             end else
                PushString('236 ' + chaine);
   end;
   if Command = 'GETERRLOG' then begin // GETERRLOG
            PushString('207 Error log follows');
               listelocale.loadfromfile(xplClient.LogFileName);
               for i:=0 to listelocale.Count-1 do PushString(listelocale[i]);
               listelocale.clear;
            PushString('.');
   end;
   if Command = 'CLEARERRLOG' then begin // CLEARERRLOG
            PushString('225 Error log cleared');
            xPLClient.ResetLog;
   end;
   if Command = 'LISTGLOBALS' then begin // LISTGLOBALS
            xPLClient.Globals.LISTGLOBALS(ListeLocale);
            PushListe('231 List of global variables follows',ListeLocale);
   end;
   if Command = 'GETRULE' then begin
      ListeLocale.Add(xPLClient.Determinators.TextContent(Parameter));
      if ListeLocale[0]<>'' then PushListe('210 Requested script/rule follows',ListeLocale)
                            else PushString('410 No such script/rule');
   end;
   if Command = 'SETGLOBAL' then begin // SETGLOBAL SETGLOBAL cache.group xpl-group.B
            StrSplitAtChar(parameter,' ',param1,param2);                               // Separate the value name and value
            xPLClient.Globals.SetValue(param1,param2);
            PushString('232 Global value updated');
   end;
   if Command = 'DELGLOBAL' then begin // DELGLOBAL cache.filter
            xPLClient.Globals.Delete(parameter);
            PushString('233 Global deleted');
   end;
   if Command = 'LISTSUBS' then begin
      AContext.Connection.IOHandler.WriteLn('224 List of subs follows');
      AContext.Connection.IOHandler.WriteLn('.');
   end;

   if Command = 'LISTOPTIONS' then begin
      AContext.Connection.IOHandler.WriteLn('205 List of options follow');
      AContext.Connection.IOHandler.WriteLn('.');
   end;
   if Command = 'LISTSCRIPTS' then begin
      AContext.Connection.IOHandler.WriteLn('212 List of scripts follows');
      AContext.Connection.IOHandler.WriteLn('Headers\');
      AContext.Connection.IOHandler.WriteLn('Messages\');
      AContext.Connection.IOHandler.WriteLn('User\');
      AContext.Connection.IOHandler.WriteLn('JOHNB_COMFORT_JUPITER.xpl');
      AContext.Connection.IOHandler.WriteLn('johnb_irman_mars.xpl');
      AContext.Connection.IOHandler.WriteLn('.');
   end;
   if Command = 'LISTEVENTS' then begin
      AContext.Connection.IOHandler.WriteLn('218 List of events follows');
      AContext.Connection.IOHandler.WriteLn('.');
   end;
   if Command = 'LISTSINGLEEVENTS' then begin
      AContext.Connection.IOHandler.WriteLn('218 List of events follows');
      AContext.Connection.IOHandler.WriteLn('.');
   end;
   if Command = 'LISTDEVICES' then begin           // johnb-dawndusk.lapfr0005	23/08/2010 14:36:49	5	N	Y	N	N
      xPLClient.LISTDEVICES(ListeLocale,Parameter);
      PushListe('216 List of XPL devices follows',ListeLocale);
   end;
   if Command = 'LISTALLDEVS' then begin
      AContext.Connection.IOHandler.WriteLn('216 List of XPL devices follows');
      AContext.Connection.IOHandler.WriteLn('.');
   end;
   if Command = 'SETRULE' then begin
      aNewRule := TStringList.Create;
      aNewRule.Add(parameter);                               // We store provided rule GUID in the first line
      PushString('338 Send rule, end with <CrLf>.<CrLf>');
   end;
   if Command = 'DELRULE' then begin
      if xPLClient.Determinators.IndexOf(parameter)<>-1 then begin
         xPLClient.Determinators.Delete(parameter);
         PushString('214 Script/determinator successfully deleted')
      end else PushString('410 No such script/determinator');
   end;
   if Command = 'LISTRULEGROUPS' then begin
      xPLClient.Determinators.ListGroups(ListeLocale);
      PushListe('240 List of determinator groups follows',ListeLocale);
   end;
   if Command = 'LISTRULES' then begin
      xPLClient.Determinators.ListRules(parameter,ListeLocale);
      PushListe('237 List of Determinator Rules follows',ListeLocale);
   end;
   if Command = 'GETDEVCONFIGVALUE' then begin
      StrSplitAtChar(parameter,' ',param1,param2);                               // Separate the value name and value
      xPLClient.GETDEVCONFIGVALUE(ListeLocale,param1,param2);
      PushListe('234 Configuration item value(s) follow',ListeLocale);
   end;
   if Command = 'PUTDEVCONFIG' then begin
      PushString('320 Enter configuration items, end with <CrLf>.<CrLf>');
      aNewConfig:=TStringList.Create;
   end;
   if Command = 'GETDEVCONFIG' then begin
      xPLClient.GETDEVCONFIG(ListeLocale,parameter);
      if ListeLocale.Count > 0 then
         PushListe('217 List of config items follows',ListeLocale)
      else
         PushString('417 No such device');
   end;
   listelocale.destroy;
end;


initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

