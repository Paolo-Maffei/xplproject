unit exec_listener;

{$mode objfpc}{$H+}{$M+}
{ Listner schema based on description made here : http://www.xplmonkey.com/xplexec.html }

interface

uses Classes
     , SysUtils
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_message
     , u_xpl_custom_message
     ;

type // TxPLexecListener ======================================================
     TxPLexecListener = class(TxPLCustomListener)
     private
        program_list : TStringList;
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure   UpdateConfig; override;
        procedure   Process(const aMessage : TxPLMessage);
     published
     end;

implementation // =============================================================
uses u_xpl_header
     , u_xpl_body
     , uxPLConst
     , Process
     , StrUtils
     , LResources
     ;

type // =======================================================================
     TExecThread = class(TThread)
     private
        fCmdLine : string;
        fOwner   : TxPLCustomListener;
        fAnswer  : TxPLCustomMessage;
     protected
        procedure Execute; override;
     public
        Constructor Create(const aOwner : TxPLCustomListener);
     published
        property CmdLine : string read fCmdLine write fCmdLine;
        property Answer  : TxPLCustomMessage read fAnswer;
     end;

const // ======================================================================
      rsStatus = 'status';
      rsReturn = 'return';
      rsStarted = 'started';
      rsXpl_execStar = '%s: started program %s';
      rsProgram = 'program';
      rsArg = 'arg';
      rsFinished = 'finished';
      rsFailed = 'failed';
      rsXplexecFaile = '%s: failed to start %s: %s';
      //rsIgnoredUnabl = '%s : unable to find security declaration of %s';

{ TExecThread ================================================================}
constructor TExecThread.Create(const aOwner : TxPLCustomListener);
begin
   FreeOnTerminate := True;
   inherited Create(true);
   fOwner  := aOwner;
   fAnswer := TxPLCustomMessage.Create(aOwner);
end;

procedure TExecThread.Execute;
var i : integer;
begin
   answer.Body.AddKeyValuePairs([rsStatus, rsReturn], [rsStarted, '']);
   fOwner.Send(answer);
   fOwner.SendLogBasic('inf', Format(rsXpl_execStar, [fOwner.Appname,answer.body.GetValueByKey(rsProgram)]));

   with TProcess.Create(fOwner) do begin
      CommandLine := CmdLine;
      for i := 0 to answer.Body.ItemCount-1 do
          if answer.Body.Keys[i]=rsArg then
                CommandLine := CommandLine + (' ' + Answer.Body.Values[i]);
      Options     := Options + [poWaitOnExit, poNewConsole];
      try
         Execute;
         answer.Body.SetValueByKey(rsReturn, IntToStr(ExitStatus));
         answer.Body.SetValueByKey(rsStatus, rsFinished);
      except
         On E : EProcess do begin
            answer.Body.SetValueByKey(rsStatus, rsFailed);
            answer.Body.SetValueByKey(rsReturn, E.Message);
            fOwner.SendLogBasic('inf', Format(rsXplexecFaile,[fOwner.AppName,answer.body.GetValueByKey('program'),E.Message]));
         end;
      end;

      Free;
   end;

   fOwner.Send(answer);
end;

// ============================================================================
{ TxPLexecListener }

constructor TxPLexecListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.Add('xpl-cmnd.*.*.*.exec.basic');
   Config.DefineItem(rsProgram, TxPLConfigItemType.option, 16);
end;

procedure TxPLexecListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     OnxPLReceived := @Process;
     program_list  := Config.CurrentConfig.GetMultiValued(rsProgram);
  end
  else OnxPLReceived := nil;
end;

procedure TxPLexecListener.Process(const aMessage: TxPLMessage);
var program_,declared : string;
    bfound : boolean;
    i : integer;
    response : TxPLMessage;
begin
   program_ := aMessage.Body.GetValueByKey(rsProgram);

   for i:= 0 to Pred(program_list.Count) do begin
       declared := program_list[i];
       if AnsiContainsText(declared,program_) then begin                       // The program name has been declared
          bfound := true;
          with TExecThread.Create(self) do begin
              CmdLine := declared;
              Answer.Assign(aMessage);
              Answer.Reply;
              Log(etInfo,rsXpl_execStar,[AppName,program_]);
              Resume;
          end;
          break;
       end;
       bfound := false;
   end;
   if not bfound then with TxPLMessage.Create(self) do begin
      Response := TxPLMessage.Create(self,aMessage.RawxPL);
      Response.Body.AddKeyValuePairs(['status','return'],['failed','access denied']);
      Response.Reply;
      Send(Response);
      SendLogBasic('inf',Format(rsXplexecFaile,[AppName,program_,'access denied']));
      Log(etInfo,Format(rsXplexecFaile,[AppName,program_,'access denied']));
      Response.Free;
   end;
end;

end.

