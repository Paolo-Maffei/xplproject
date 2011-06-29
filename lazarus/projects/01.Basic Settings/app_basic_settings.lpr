program app_basic_settings;

uses {$IFDEF UNIX}
        {$IFDEF UseCThreads}
           cthreads,
        {$ENDIF}
     {$ENDIF}
     Forms
     , runtimetypeinfocontrols
     , frm_basic_settings
     , u_xpl_application
     , u_xpl_gui_resource
     , Interfaces
     ;

{$IFDEF WINDOWS}
   {$R app_basic_settings.rc}
{$ENDIF}

begin
   Application.Title:='xPL Basic Settings';
   Application.Initialize;

   xPLApplication := TxPLApplication.Create(Application);
   xPLGUIResource := TxPLGUIResource.Create;

   Application.CreateForm(TfrmBasicSettings, frmBasicSettings);
   Application.Run;

   xPLGUIResource.Free;
end.

