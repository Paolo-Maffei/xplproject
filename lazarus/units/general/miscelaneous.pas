{*
 * Miscelaneous.pas
 *
 * Miscelaneous functions which are not placed in a proper unit yet.
 *
 * Copyright (c) 2006-2007 by the MODELbuilder developers team
 * Originally written by Darius Blaszijk, <dhkblaszyk@zeelandnet.nl>
 * Creation date: 13-May-2006
 * Website: www.modelbuilder.org
 *
 * This file is part of the MODELbuilder component library (MCL) 
 * and licensed under the LGPL, see COPYING.LGPL included in 
 * this distribution, for details about the copyright.
 *
 *}

unit Miscelaneous;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Process, Dialogs, LCLProc;

resourcestring
  rsBrowserExecutableNotProperlySet = 'Browser executable not properly set, '
    +'please correct setting.';
  rsError = 'Error';

type
  TVariableTypeSet = (vtVariable, vtConstant);

function IsNumeric(const Value: string): boolean;
procedure OpenURLinBrowser(BrowserExec, BrowserParameters, URL: string); overload;

implementation

function IsNumeric(const Value: string): boolean;
var
  dValue: extended;
  Code:   integer;
begin
  Val(Value, dValue, Code);
  Result := (Code = 0);
end;

procedure OpenURLinBrowser(BrowserExec, BrowserParameters, URL: string);
var
  TheProcess: TProcess;
  BrowserCommand: string;
begin
  if not FileExists(BrowserExec) then
  begin
    MessageDlg(rsError, rsBrowserExecutableNotProperlySet, mtError,[mbCancel],0);
    exit;
  end;

  TheProcess:=TProcess.Create(nil);
  try
    TheProcess.Options:= [poUsePipes, poNoConsole, poStdErrToOutput];
    TheProcess.ShowWindow := swoNone;
    BrowserCommand := Format(BrowserExec + ' ' + BrowserParameters,[URL]);
    TheProcess.CommandLine:=BrowserCommand;
    try
      TheProcess.Execute;
    finally
      TheProcess.Free;
    end;
  except
    on E: Exception do begin
      DebugLn('OpenURLinBrowser: OpenURL ERROR: ',E.Message);
    end;
  end;
end;

end.