program app_basic_settings;

uses cthreads
     {$ifdef DEBUG}
     , heaptrc
     {$endif}
     , Forms
     , runtimetypeinfocontrols
     , pl_excontrols
     , pl_rx
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
