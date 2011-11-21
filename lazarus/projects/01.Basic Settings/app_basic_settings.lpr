program app_basic_settings;

uses {$IFDEF UNIX}
        {$IFDEF UseCThreads}
           cthreads,
        {$ENDIF}
     {$ENDIF}
     Forms, pl_rx, runtimetypeinfocontrols
     , frm_basic_settings
     , u_xpl_application
     , Interfaces;

{$R *.res}

begin
   Application.Initialize;

   xPLApplication := TxPLApplication.Create(Application);
   Application.CreateForm(TfrmBasicSettings, frmBasicSettings);
   Application.Run;
end.

