unit frm_logger_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ActnList, StdCtrls, ExtCtrls, Spin, XMLPropStorage, RTTICtrls,
  dlg_config, frame_config;

type

  { TFrmLoggerConfig }

  TFrmLoggerConfig = class(TDlgConfig)
    ckIcons: TCheckBox;
    ckShowPreview: TCheckBox;
    ckStartAtLaunch: TCheckBox;
    Label2: TLabel;
    rgFilterBy: TRadioGroup;
    seMaxPool: TSpinEdit;
    TICheckBox1: TTICheckBox;
    XMLPropStorage: TXMLPropStorage;
    procedure FormCreate(Sender: TObject);
    procedure XMLPropStorageRestoreProperties(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

  procedure ShowDlgLoggerConfig;

  var FrmLoggerConfig: TFrmLoggerConfig;

implementation // =============================================================
uses u_xpl_application
     , u_xpl_custom_listener
     , frm_logger
     ;

// ============================================================================
procedure ShowDlgLoggerConfig;
begin
   if not Assigned(FrmLoggerConfig) then Application.CreateForm(TFrmLoggerConfig, FrmLoggerConfig);
   FrmLoggerConfig.frameConfig1.SetConfigCurrent(TxPLCustomListener(xPLApplication).Config.CurrentConfig);
   FrmLoggerConfig.ShowModal;
end;

procedure TFrmLoggerConfig.FormCreate(Sender: TObject);
begin                                                                          // Correction of bug FS#60 : don't let settings
   XMLPropStorage.FileName := xPLApplication.Folders.DeviceDir + 'settings.xml';
   XMLPropStorage.Restore;                                                      // go anywhere, force it to be in the xpl app directory
   frmLogger.ApplySettings(self);
end;

procedure TFrmLoggerConfig.XMLPropStorageRestoreProperties(Sender: TObject);
begin
   frmLogger.ApplySettings(self);
end;

initialization
  {$I frm_logger_config.lrs}

end.

