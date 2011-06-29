program fpcunitproject1;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, SynHighlighterXML, TestCase1,
  u_xpl_schema;

{$IFDEF WINDOWS}{$R fpcunitproject1.rc}{$ENDIF}


begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

