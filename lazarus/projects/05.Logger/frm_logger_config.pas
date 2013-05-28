unit frm_logger_config;

{$mode objfpc}{$H+}{$M+}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ActnList, StdCtrls, ExtCtrls, Spin, XMLPropStorage, Buttons, Grids,
   RTTICtrls, LSControls, dlg_template;

type

  { TFrmLoggerConfig }

  TFrmLoggerConfig = class(TDlgTemplate)
    ckFilter: TCheckBox;
    ckSimpleTree: TCheckBox;
    ckIcons: TCheckBox;
    ckShowPreview: TCheckBox;
    ckStartAtLaunch: TCheckBox;
    Label2: TLabel;
    mmoFilter: TMemo;
    PageControl1: TPageControl;
    rgFilterBy: TRadioGroup;
    seMaxPool: TSpinEdit;
    tsGUI: TTabSheet;
    tsFiltering: TTabSheet;
    TICheckBox1: TTICheckBox;
    procedure FormCreate(Sender: TObject);
    procedure XMLPropStorageRestoreProperties(Sender: TObject);
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
   FrmLoggerConfig.ShowModal;
end;

procedure TFrmLoggerConfig.FormCreate(Sender: TObject);
begin                                                                          // Correction of bug FS#60 : don't let settings
   inherited;
   frmLogger.ApplySettings(self);
end;

procedure TFrmLoggerConfig.XMLPropStorageRestoreProperties(Sender: TObject);
begin
   frmLogger.ApplySettings(self);
end;

end.
