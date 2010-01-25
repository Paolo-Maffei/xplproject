unit frm_main;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls,  uxPLMessage,  StdCtrls, uPSUtils,
  Buttons, uxPLConfig, uPSComponent, uPSCompiler, uPSRuntime, SynHighlighterPas,
  SynEdit,  uxPLInterface, XMLPropStorage;

type
  TxPLMessageArrived = function (aMessage: String) : Longint of object;         // Function called when an xPLMessage arrives
  TStopScript  = function                    : Longint of object;         // Function called when stopping from outsite
  TGlobalChanged  = function(aValue : string; aOld : string; aNew : string) : Longint of object;         // Function called when a global value changed

{ TfrmMain }
  TfrmMain = class(TForm)
    About: TAction;
    acStop: TAction;
    acCheck: TAction;
    acRun: TAction;
    acGLModify: TAction;
    acGLDelete: TAction;
    ActionList1: TActionList;
    InstalledApps: TAction;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mmoMessages: TMemo;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PopupMenu1: TPopupMenu;
    PSScript: TPSScript;
    Quit: TAction;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
//    TreeListView1: TTreeListView;
    XMLPropStorage1: TXMLPropStorage;
    procedure AboutExecute(Sender: TObject);
    procedure acCheckExecute(Sender: TObject);
//    procedure acGLDeleteExecute(Sender: TObject);
//    procedure acGLModifyExecute(Sender: TObject);
    procedure acRunExecute(Sender: TObject);
    procedure acStopExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure InstalledAppsExecute(Sender: TObject);
    procedure PSScriptAfterExecute(Sender: TPSScript);
    procedure PSScriptCompile(Sender: TPSScript);
    procedure PSScriptCompImport(Sender: TObject; x: TPSPascalCompiler);
    procedure PSScriptExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
    procedure PSScriptExecute(Sender: TPSScript);
    procedure PSScriptLine(Sender: TObject);
    function PSScriptNeedFile(Sender: TObject; const OrginFileName: tbtstring; var FileName, Output: tbtstring): Boolean;
    procedure PSScriptVerifyProc(Sender: TPSScript; Proc: TPSInternalProcedure; const Decl: tbtstring; var Error: Boolean);
    procedure QuitExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure OnJoined(const aJoined : boolean);
    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnMessageReceived(const axPLMessage: TxPLMessage);
    procedure OnGlobalChanged(aValue : string; aOld : string; aNew : string);
//    procedure RefreshGlobalDisplay(const aName : string);
    procedure SetButtons;
    function  Compile : boolean;
    procedure CommandGet(var aPageContent : widestring; aParam, aValue : string);
  public
     bJoined, bConfigured,bAutoStartWanted : boolean;
     xPLClient : TxPLInterface;
     MessageArrived   : TxPLMessageArrived;
     GlobalChanged : TGlobalChanged;
     StopScript : TStopScript;
     CurrentSource : TStringList;
     FunctionList  : TStringList;
     FunctionsToLaunch : TStringList;


    procedure Output_AppendLine(aString : string);
    procedure Output_Clear;
  end;


var frmMain: TfrmMain;

implementation {===============================================================}
uses Frm_About, frm_xPLAppslauncher, cstrings, regexpr,
     LCLType, StrUtils, DateUtils, uxPLMsgHeader, XMLCfg,uxPLCfgItem,
     uPSR_std, uPSC_std, uPSR_forms, uPSC_forms, upsr_dateutils, upsc_dateutils,
     uPSC_classes, uPSR_classes, uPSI_uxplinterface;

{==============================================================================}
resourcestring
     K_XPL_APP_VERSION_NUMBER = '0.7';
     K_XPL_APP_NAME = 'xPL Pascal Script';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'psscript';
     K_DEFAULT_PORT = '8335';

{ General window functions ====================================================}
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.InstalledAppsExecute(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TfrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var functionname : string;
    lefty, righty : string;
begin
   if FunctionsToLaunch.Count=0 then exit;

   functionname := FunctionsToLaunch[0];
   strsplitatchar(functionname,' ',lefty,functionname);
   strsplitatchar(functionname,'(',functionname,righty);
   strsplitatchar(functionname,';',functionname,righty);
   strsplitatchar(functionname,':',functionname,righty);
   functionname := Trim(functionname,[' ']);
   ConvertUpper(functionname);

   Output_AppendLine('Launching function : ' + functionname);                                          // Function can't directly be launched
                                                                                                       // from the OnGet http either we have
   PSScript.ExecuteFunction([],functionname);                                                          // an EThread exception on call of CheckSynchronize by a non main thread
   functionsToLaunch.Delete(0);
end;


procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   CanClose := (Application.MessageBox('Do you want to quit ?','Confirm',MB_YESNO) = IDYES);
   if CanClose and (PSScript.Running) then AcStopExecute(self);
end;

{ Script operations management ================================================}
procedure TfrmMain.acCheckExecute(Sender: TObject);
begin Compile; end;

{procedure TfrmMain.acGLModifyExecute(Sender: TObject);                          // Change the value of a global
var s,v : string;
    li : TListItem;
begin
   li := lvGlobals.Selected;
   if not assigned(li) then exit;

     s := li.Caption;
     if xPLClient.Exists(s,false) then begin
        v := xPLClient.GlobalValue(s);
        if InputQuery('Global Value','Change value of ' + s,v) then
           xPLClient.Value(s,v);
     end;
end;

procedure TfrmMain.acGLDeleteExecute(Sender: TObject);                          // Delete a global
var s : string;
    li : TListItem;
begin
   li := lvGlobals.Selected;
   if not assigned(li) then exit;

     s := li.Caption;
     xPLClient.Exists(s,true);
     RefreshGlobalDisplay('');
end;}

procedure TfrmMain.acStopExecute(Sender: TObject);
begin
   if not PSScript.Running then exit;
   StopScript;
   PSScript.Stop;
   FunctionsToLaunch.Clear;
   CurrentSource.Clear;
   FunctionList.Clear;
end;

function TfrmMain.Compile : boolean;
var i: Longint;
begin
  result := false;
  Output_Clear;
  if FileExists(PSScript.MainFileName) then begin
     Output_AppendLine('Loading ' + PSScript.MainFileName);
     PSScript.Script.LoadFromFile(PSScript.MainFileName);
     CurrentSource.AddStrings(PSScript.Script);
     Output_AppendLine('Compiling...');
     result :=  PSScript.Compile;

     for i := 0 to PSScript.CompilerMessageCount -1 do
      Output_AppendLine(PSScript.CompilerMessages[i].MessageToString);
  end else
     Output_AppendLine('File not found : ' + PSScript.MainFileName);

  if result then Output_AppendLine('Syntax check ok');
end;

procedure TfrmMain.CommandGet(var aPageContent: widestring; aParam,aValue: string);
const sBeginTemplate = '<!-- Result template>';
      sEndTemplate   = '<Result template-->';
var //s : widestring;
  Pattern : string;
  sOut,globale    : string;
  Where,long: integer;
  i       : integer;
begin
   if aParam = 'Procedure_Name' then FunctionsToLaunch.Add(aValue);

   Pattern := StrBetween(aPageContent,sBeginTemplate,sEndTemplate);
   if length(Pattern)=0 then exit;

   with xPLClient do begin

     if Pos('{%global_',Pattern)>0 then begin
        i := Globals.Count -1;
        long := length(aPageContent);
        Where  := AnsiPos(sEndTemplate, aPageContent) + length(sEndTemplate);
        while(i>=0) do begin
           globale := Globals[i];
           if (aValue=globale) or (aValue='') then begin
              sOut := StrReplace('{%global_name%}', globale, Pattern,false);
              sOut := StrReplace('{%global_value%}', GlobalValue(globale), sOut,false);
              sOut := StrReplace('{%global_previous%}', GlobalFormer(globale), sOut,false);
              sOut := StrReplace('{%global_modified%}', DateTimeToStr(GlobalModified(globale)), sOut,false);
              sOut := StrReplace('{%global_created%}', DateTimeToStr(GlobalCreated(globale)), sOut,false);
              Insert(sOut,aPageContent,Where);
              Where += length(sOut);
           end;
           dec(i);
        end;
     end;
     if Pos('{%function_',Pattern)>0 then begin
        i := FunctionList.Count -1;
        long := length(aPageContent);
        Where  := AnsiPos(sEndTemplate, aPageContent) + length(sEndTemplate);
        while(i>=0) do begin
           globale := FunctionList[i];
           if (aValue=globale) or (aValue='') then begin
              sOut := StrReplace('{%function_name%}', globale, Pattern,false);
              Insert(sOut,aPageContent,Where);
              Where += length(sOut);
           end;
           dec(i);
        end;
     end;
     if Pos('{%script_',Pattern)>0 then begin
        i := mmoMessages.Lines.Count -1;
        long := length(aPageContent);
        Where  := AnsiPos(sEndTemplate, aPageContent) + length(sEndTemplate);
        while(i>=0) do begin
           globale := mmoMessages.Lines[i];
           if (aValue=globale) or (aValue='') then begin
              sOut := StrReplace('{%script_result%}', globale, Pattern,false);
              Insert(sOut,aPageContent,Where);
              Where += length(sOut);
           end;
           dec(i);
        end;
     end;
  end;
end;

procedure TfrmMain.acRunExecute(Sender: TObject);
var bFound : boolean;
begin
   if not Compile then exit;

   MessageArrived   := TxPLMessageArrived (PSScript.GetProcMethod('XPLMESSAGEARRIVED'));
   StopScript       := TStopScript        (PSScript.GetProcMethod('STOPSCRIPT'));
   GlobalChanged    := TGlobalChanged     (PSScript.GetProcMethod('GLOBALCHANGED'));
   FunctionList.Clear;
  with TRegExpr.Create do try
        //Expression := '(function\s+[\w\s.]+((:\s*\w+\s*;)|(\([\w\s,.='':;$/*()]*?\)\s*:\s*\w+\s*;)))|(procedure\s+[\w\s.]+((;)|(\([\w\s,.='':;$/*()]*?\)\s*;)))';
        Expression := '(function\s+[\w\s.]+(:\s*\w+\s*;))|(procedure\s+[\w\s.]+((;)))';
        bFound := Exec(CurrentSource.Text);
        while bFound do begin
              FunctionList.Add(Match[0]);
              bFound := ExecNext;
        end;
        finally free;
   end;
   Output_AppendLine('Executing...');

   if not PSScript.Execute then
      Output_AppendLine(PSScript.ExecErrorToString +' at '+Inttostr(PSScript.ExecErrorProcNo)+'.'+Inttostr(PSScript.ExecErrorByteCodePosition))
   else Output_AppendLine('Succesfully executed');
end;

{ General xPL functions =======================================================}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.Caption := K_XPL_APP_NAME;
  bJoined := false;
  bConfigured := false;
  bAutoStartWanted := false;
  CurrentSource    := TStringList.Create;
  FunctionList     := TStringList.Create;
  FunctionsToLaunch:= TStringList.Create;

  xPLClient := TxPLInterface.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_NAME,K_XPL_APP_VERSION_NUMBER,K_DEFAULT_PORT);
  xPLClient.Config.AddItem('autostart',xpl_ctConfig,'0'); //,  1, 'Launch script at startup (1 or 0)', '^[01]{1}$');
  xPLClient.Config.AddItem('scriptfile',xpl_ctConfig,'0');//,  1, 'Name of the main script file', '^([a-zA-Z]\:|\\\\[^\/\\:*?"<>|]+\\[^\/\\:*?"<>|]+)(\\[^\/\\:*?"<>|]+)+(\.[^\/\\:*?"<>|]+)$');
  xPLClient.Config.AddItem('autosense',xpl_ctConfig,'0',16); //,'Autosense schema to globals','([0-9a-z/-]{1,8})\.([0-9a-z/-]{1,8})\,([0-9a-z/-]{1,8})\,([0-9a-z/-]{1,8})');

  xPLClient.Config.AddValue('autosense','sensor.basic,device,current');
  OnJoined(False);

  with xPLClient do begin
       OnxPLJoinedNet := @OnJoined;
       OnxPLConfigDone:= @OnConfigDone;
       OnxPLReceived  := @OnMessageReceived;
       OnxPLGlobalChanged:= @OnGlobalChanged;
       OnCommandGet       := @CommandGet;
  end;
  xPLClient.Listen;
end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
begin
   bJoined := aJoined;
   StatusBar1.Panels[0].Text := 'Hub ' + IfThen( xPLClient.JoinedxPLNetwork, '','not') + ' found';
   StatusBar1.Panels[1].Text := 'Configuration ' + IfThen (bConfigured, 'done','pending');
end;

procedure TfrmMain.OnConfigDone(const fConfig: TxPLConfig);
var config : TXmlConfig;
begin
   bConfigured := true;
   config := fConfig.XmlFile;

   xPLClient.ReadFromXML(Config,'GlobalList');
   if fConfig.ItemName['autostart'].Value='1' then bAutoStartWanted := true;
   PSScript.MainFileName := fConfig.ItemName['scriptfile'].Value;
   SetButtons;
end;

procedure TfrmMain.OnMessageReceived(const axPLMessage: TxPLMessage);
var i,j, iDevice,iValue : integer;
    s, schema, ident, value : string;
begin
   if not PSScript.Running then exit;
   //*** Device Status Extraction part
   i := xPLClient.Config.ItemByName('autosense');
   for j:= 0 to xPLClient.Config.Item[i].ValueCount -1 do begin
       s := xPLClient.Config.Item[i].Values[j];
       if StrSplitAtChar(s,',',schema,s) then begin
          if StrSplitAtChar(s,',',ident,value) then begin

             if axPLMessage.Schema.Tag=schema then begin
                iDevice := axPLMessage.Body.Keys.IndexOf(ident);
                iValue  := axPLMessage.Body.Keys.IndexOf(value);
                if (iDevice<>-1) and (iValue<>-1) then
                   xPLClient.Value(  axPLMessage.Source.Tag + '.' +
                        axPLMessage.Body.Values[iDevice],
                        axPLMessage.Body.Values[iValue]);
                end;
          end;
       end;
   end;
   //***
   xPLClient.xPLMessage.RawXPL := axPLMessage.RawXPL ;
   MessageArrived(axPLMessage.RawXPL);
end;

procedure TfrmMain.OnGlobalChanged( aValue: string; aOld: string;  aNew: string);
begin
   GlobalChanged(aValue,aOld,aNew);
end;

{ Specific to project operations ==============================================}

procedure MyWriteln(const s: string);
begin
  frmMain.Output_AppendLine(FormatDateTime('dd/mm hh:nn',now) + ' - ' + s);
end;

procedure TfrmMain.SetButtons;
begin
   acCheck.Enabled := FileExists(PSScript.MainFileName);
   acRun.Enabled :=  (acCheck.Enabled) and not PSScript.Running;
   acStop.Enabled := acCheck.Enabled and not acRun.Enabled;
end;

procedure TfrmMain.PSScriptAfterExecute(Sender: TPSScript);
begin
   SetButtons;
end;

procedure TfrmMain.PSScriptCompile(Sender: TPSScript);
begin
  Sender.AddFunction(@MyWriteln, 'procedure Writeln(s: string);');
  Sender.AddRegisteredVariable('xpl', 'TxPLInterface');
end;

procedure TfrmMain.PSScriptCompImport(Sender: TObject; x: TPSPascalCompiler);
begin
  SIRegister_Std(x);
  SIRegister_Classes(x, true);
  SIRegister_Forms(x);
  SIRegister_TxPLInterface(x);
  SIRegister_uxplinterface(x);
  RegisterDateTimeLibrary_C(x);
end;

procedure TfrmMain.PSScriptExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
begin
    RIRegister_Std(x);
    RIRegister_Classes(x, True);
    RIRegister_Forms(x);
    RIRegister_TxPLInterface(x);
    RIRegister_uxplinterface(x);
    RegisterDateTimeLibrary_R(se);
end;

procedure TfrmMain.PSScriptExecute(Sender: TPSScript);
begin
   SetButtons;
   PSScript.SetVarToInstance('xpl', xPLClient);
end;

function TfrmMain.PSScriptNeedFile(Sender: TObject; const OrginFileName: tbtstring; var FileName, Output: tbtstring): Boolean;
var
  path: string;
  f: TFileStream;
begin
  Path := ExtractFilePath(PSScript.MainFileName) + FileName;
  try
    F := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
  except
    Output_AppendLine('File not found : ' + Path);
    Result := false;
    exit;
  end;
  try
    SetLength(Output, f.Size);
    f.Read(Output[1], Length(Output));
    CurrentSource.Add(Output);
  finally
  f.Free;
  end;
  Result := True;
end;

procedure TfrmMain.PSScriptVerifyProc(Sender: TPSScript; Proc: TPSInternalProcedure; const Decl: tbtstring; var Error: Boolean);
begin
     Error := False;
{  if Proc.Name = 'GLOBALCHANGED' then begin
    if not ExportCheck(Sender.Comp, Proc, [btS32,btString, btString, btString], [pmIn,pmIn,pmIn]) then begin
      Sender.Comp.MakeError('', ecCustomError, 'Function header for GlobalChanged does not match.');
      Error := True;
    end
    else begin
      Error := False;
    end;
  end else begin
  if Proc.Name = 'XPLMESSAGEARRIVED' then begin
    if not ExportCheck(Sender.Comp, Proc, [btS32,btString], [pmIn]) then begin
      Sender.Comp.MakeError('', ecCustomError, 'Function header for xPLMessageArrived does not match.');
      Error := True;
    end
    else begin
      Error := False;
    end;
  end else begin
  if Proc.Name = 'STOPSCRIPT' then begin
    if not ExportCheck(Sender.Comp, Proc, [btS32], []) then begin
      Sender.Comp.MakeError('', ecCustomError, 'Function header for StopScript does not match.');
      Error := True;
    end
    else begin
      Error := False;
    end;
  end
     else Error := False;
  end;
  end;}
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
     xPLClient.WriteToXML(xPLClient.Config.XmlFile,'GlobalList');
     if Assigned(xPLClient) then xPLClient.destroy;
     CurrentSource.Destroy;
     FunctionList.Destroy;
     FunctionsToLaunch.Destroy;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
begin
   if bAutoStartWanted then begin
      bAutoStartWanted := False;
      acRunExecute(self);
   end;      
end;

procedure TfrmMain.PSScriptLine(Sender: TObject);                                    // To avoid application freezes on loops
begin
  SetButtons;
  Application.ProcessMessages;
end;

procedure TfrmMain.Output_AppendLine(aString: string);
begin mmoMessages.Lines.Add(aString); end;

procedure TfrmMain.Output_Clear;
begin mmoMessages.Lines.Clear; end;

initialization
  {$I frm_main.lrs}

end.

