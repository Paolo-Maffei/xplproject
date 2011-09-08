program xpl_event;

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
     Interfaces, // this includes the LCL widgetset
     Forms, aformula, uniqueinstance_package, multiloglaz,
     frm_event,
     u_xpl_application,
     event_listener,
     u_xpl_gui_resource;

{$IFDEF WINDOWS}{$R xpl_event.rc}{$ENDIF}

{$R *.res}

begin
  Application.Initialize;

  xPLApplication := TxPLeventListener.Create(nil);
  xPLGUIResource := TxPLGUIResource.Create;

  Application.CreateForm(TFrmevent,  frmevent);
  Application.Icon := Frmevent.Icon;
  Application.Run;

  xPLGUIResource.Free;
  xPLApplication.Free;
end.



