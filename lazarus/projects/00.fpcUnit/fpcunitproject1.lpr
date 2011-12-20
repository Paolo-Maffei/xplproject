program fpcunitproject1;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uniqueinstance_package, multiloglaz, GuiTestRunner,
  SynHighlighterXML, pl_indycomp, TestCase1, u_xpl_schema;

{$IFDEF WINDOWS}{$R fpcunitproject1.rc}{$ENDIF}


{ $ R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

