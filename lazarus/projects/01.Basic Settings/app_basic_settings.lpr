program app_basic_settings;

uses cthreads
     //, heaptrc                                                               // Debugging : find memory leaks
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
