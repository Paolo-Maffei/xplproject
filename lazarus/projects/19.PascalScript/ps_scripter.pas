unit ps_scripter;

{$mode objfpc}

interface

uses Classes
     , SysUtils
     , uPSComponent
     , uPSCompiler
     , uPSRuntime
     , uPSUtils
     ;

type { TPS_Scripter ==========================================================}
     TPS_Scripter = class(TPSScript)
     public
        constructor Create(AOwner: TComponent); override;

        procedure PSScriptCompImport(Sender: TObject; x: TPSPascalCompiler);
        procedure PSScriptExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
        function  PSScriptNeedFile(Sender: TObject; const OrginFileName: tbtstring; var FileName, Output: tbtstring): Boolean;
     end;

implementation // =============================================================

uses uPSR_std, uPSC_std
     , upsr_dateutils, upsc_dateutils
     , uPSC_classes, uPSR_classes
     , uPSI_PS_listener
     ;

{ TPS_Scripter }
constructor TPS_Scripter.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   OnNeedFile   := @PSScriptNeedFile;
   OnCompImport := @PSScriptCompImport;
   OnExecImport := @PSScriptExecImport;
end;

procedure TPS_Scripter.PSScriptCompImport(Sender: TObject; x: TPSPascalCompiler);
begin
   SIRegister_Std(x);
   SIRegister_Classes(x, true);
   SIRegister_TxPLPSListener(x);
   RegisterDateTimeLibrary_C(x);
   SIRegister_PS_listener(x);
end;

procedure TPS_Scripter.PSScriptExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
begin
   RIRegister_Std(x);
   RIRegister_Classes(x, True);
   RIRegister_TxPLPSListener(x);
   RegisterDateTimeLibrary_R(se);
   RIRegister_PS_listener(x);
end;

function TPS_Scripter.PSScriptNeedFile(Sender: TObject; const OrginFileName: tbtstring; var FileName, Output: tbtstring): Boolean;
var path: string;
    f: TFileStream;
begin
   Path := ExtractFilePath(MainFileName) + FileName;
   try
      F := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
   except
//      inherited Log(etInfo,K_ERR_MSG_FNF,[Path]);
      Result := false;
      exit;
   end;
   try
      SetLength(Output, f.Size);
      f.Read(Output[1], Length(Output));
   finally
      f.Free;
   end;
   Result := True;
end;

end.

