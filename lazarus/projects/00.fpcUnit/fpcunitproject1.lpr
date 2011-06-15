program fpcunitproject1;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, SynHighlighterXML, TestCase1, LResources,
  u_xpl_schema;

{$IFDEF WINDOWS}{$R fpcunitproject1.rc}{$ENDIF}

begin
  {$I fpcunitproject1.lrs}
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

