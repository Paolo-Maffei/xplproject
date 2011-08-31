program app_basic_settings;

uses {$IFDEF UNIX}
        {$IFDEF UseCThreads}
           cthreads,
        {$ENDIF}
     {$ENDIF}
     Forms, uniqueinstance_package, multiloglaz, pl_rx, runtimetypeinfocontrols
     , frm_basic_settings
     , u_xpl_application
     , u_xpl_gui_resource
     , Interfaces;

{$IFDEF WINDOWS}
   {$R app_basic_settings.rc}
{$ENDIF}

{$R *.res}

begin
   Application.Initialize;

   xPLApplication := TxPLApplication.Create(Application);
   xPLGUIResource := TxPLGUIResource.Create;

   Application.CreateForm(TfrmBasicSettings, frmBasicSettings);
   Application.Run;

   xPLGUIResource.Free;
end.

