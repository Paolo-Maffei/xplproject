unit frm_main;

{$mode objfpc}{$H+}                             

interface
                                         
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls,    StdCtrls, uPSUtils,
  Buttons, uPSComponent, SynHighlighterPas, IdCustomHTTPServer,
  SynEdit, RTTICtrls, u_xpl_config, frm_template, PS_Listener, u_xpl_globals;

type


{ TfrmMain }
  TfrmMain = class(TFrmTemplate)
    acStop: TAction;
    acCheck: TAction;
    acRun: TAction;
    acGLModify: TAction;
    acGLDelete: TAction;
    ActionList1: TActionList;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mmoMessages: TMemo;
    MenuItem8: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure acCheckExecute(Sender: TObject);
//    procedure acGLDeleteExecute(Sender: TObject);
//    procedure acGLModifyExecute(Sender: TObject);
    procedure acRunExecute(Sender: TObject);
    procedure acStopExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure PSScriptAfterExecute(Sender: TPSScript);
    procedure PSScriptLine(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure OnConfigDone(const fConfig : TxPLCustomConfig);
    procedure OnGlobalChanged(const aValue : string; const aNew : string; const aOld : string);
//    procedure RefreshGlobalDisplay(const aName : string);
    procedure SetButtons;
//    function  Compile : boolean;
  public
     xPLClient : TxPLPSListener;

//     CurrentSource : TStringList;
     FunctionList  : TStringList;
     FunctionsToLaunch : TStringList;
//     fxPLCacheManager : TxPLCacheManagerFile;
    procedure LogUpdate(const aString: string);
    procedure Output_AppendLine(aString : string);

//    procedure Output_Clear;
  end;


var frmMain: TfrmMain;

implementation {===============================================================}
uses cstrings
     , uxPLConst
     , LCLType
     , DateUtils
     , u_xpl_application
     , uRegExpr;

{ General window functions ====================================================}
procedure TfrmMain.LogUpdate(const astring: string);
begin
  mmoMessages.Lines.Add(aString);
end;

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
//   PSScript.ExecuteFunction([],functionname);                                                          // an EThread exception on call of CheckSynchronize by a non main thread
   functionsToLaunch.Delete(0);
end;

{ Script operations management ================================================}
procedure TfrmMain.acCheckExecute(Sender: TObject);
begin
//  Compile;
end;

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
(*   if not PSScript.Running then exit;
   StopScript;
   PSScript.Stop;
   FunctionsToLaunch.Clear;
//   CurrentSource.Clear;
   FunctionList.Clear;*)
end;


procedure TfrmMain.acRunExecute(Sender: TObject);
var bFound : boolean;
begin
//   if not Compile then exit;

(*   MessageArrived   := TxPLMessageArrived (PSScript.GetProcMethod('XPLMESSAGEARRIVED'));
   StopScript       := TStopScript        (PSScript.GetProcMethod('STOPSCRIPT'));
   GlobalChanged    := TxPLGlobalChangedEvent (PSScript.GetProcMethod('GLOBALCHANGED'));*)
(*   FunctionList.Clear;
  with TRegExpr.Create do try
        //Expression := '(function\s+[\w\s.]+((:\s*\w+\s*;)|(\([\w\s,.='':;$/*()]*?\)\s*:\s*\w+\s*;)))|(procedure\s+[\w\s.]+((;)|(\([\w\s,.='':;$/*()]*?\)\s*;)))';
        Expression := '(function\s+[\w\s.]+(:\s*\w+\s*;))|(procedure\s+[\w\s.]+((;)))';
        bFound := Exec(CurrentSource.Text);
        while bFound do begin
              FunctionList.Add(Match[0]);
              bFound := ExecNext;
        end;
        finally free;
   end;*)
   Output_AppendLine('Executing...');

(*   if not PSScript.Execute then
      Output_AppendLine(PSScript.ExecErrorToString +' at '+Inttostr(PSScript.ExecErrorProcNo)+'.'+Inttostr(PSScript.ExecErrorByteCodePosition))
   else Output_AppendLine('Succesfully executed');*)
end;

{ General xPL functions =======================================================}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   inherited;
//  CurrentSource    := TStringList.Create;
  FunctionList     := TStringList.Create;
  FunctionsToLaunch:= TStringList.Create;

  xPLClient := TxPLPSListener(xPLApplication);
  xPLClient.PSScript.OnAfterExecute := @PSScriptAfterExecute;
  xPLClient.PSScript.OnLine         := @PSScriptLine;

  Self.Caption := xPLClient.AppName;
  with xPLClient do begin
       OnLogEvent        := @LogUpdate;
       OnxPLGlobalChanged := @OnGlobalChanged;
       OnxPLConfigDone    := @OnConfigDone;
  end;
  xPLClient.Listen;
end;

procedure TfrmMain.OnConfigDone(const fConfig : TxPLCustomConfig);
begin
   SetButtons;
end;


procedure TfrmMain.OnGlobalChanged(const aValue : string; const aNew : string; const aOld : string);
begin
   GlobalChanged(aValue,aOld,aNew);
end;

{ Specific to project operations ==============================================}

procedure TfrmMain.SetButtons;
begin
(*   acCheck.Enabled := FileExists(PSScript.MainFileName);
   acRun.Enabled :=  (acCheck.Enabled) and not PSScript.Running;
   acStop.Enabled := acCheck.Enabled and not acRun.Enabled;*)
end;

procedure TfrmMain.PSScriptAfterExecute(Sender: TPSScript);
begin
   SetButtons;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
//     if Assigned(fxPLCacheManager) then fxPLCacheManager.destroy;
//     CurrentSource.Destroy;
     FunctionList.Destroy;
     FunctionsToLaunch.Destroy;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
begin
(*   if bAutoStartWanted then begin
      bAutoStartWanted := False;
      acRunExecute(self);
   end;      *)
end;

procedure TfrmMain.PSScriptLine(Sender: TObject);                                    // To avoid application freezes on loops
begin
  SetButtons;
  Application.ProcessMessages;
end;

procedure TfrmMain.Output_AppendLine(aString: string);
begin
  xPLClient.Log(aString);
end;

initialization
  {$I frm_main.lrs}

end.

(*
function TfrmMain.ReplaceArrayedTag(const aDevice: string; const aValue : string; const aVariable: string; ReturnList: TStringList): boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   with xPLClient do begin
   if aVariable = 'function_name'        then for i:=0 to FunctionList.Count-1 do ReturnList.Add(FunctionList[i])
   else if aVariable = 'global_name'     then for i:=0 to Globals.Count-1      do begin if ((aValue='') or (aValue=Globals[i])) then ReturnList.Add(Globals[i]) end
   else if aVariable = 'global_value'    then for i:=0 to Globals.Count-1      do begin if ((aValue='') or (aValue=Globals[i])) then ReturnList.Add(GlobalValue(Globals[i])) end
   else if aVariable = 'global_previous' then for i:=0 to Globals.Count-1      do begin if ((aValue='') or (aValue=Globals[i])) then ReturnList.Add(GlobalFormer(Globals[i])) end
   else if aVariable = 'global_modified' then for i:=0 to Globals.Count-1      do begin if ((aValue='') or (aValue=Globals[i])) then ReturnList.Add(DateTimeToStr(GlobalModified(Globals[i]))) end
   else if aVariable = 'global_created'  then for i:=0 to Globals.Count-1      do begin if ((aValue='') or (aValue=Globals[i])) then ReturnList.Add(DateTimeToStr(GlobalCreated(Globals[i]))) end
   end;
   result := (ReturnList.Count >0);
end;

*)
