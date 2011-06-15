unit frm_appsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, XMLPropStorage, StdCtrls, Buttons, ExtCtrls, Spin, RTTICtrls;

type

{ TfrmAppSettings }

TfrmAppSettings = class(TForm)
       ckStartAtLaunch: TCheckBox;
        ckIcons: TCheckBox;
        ckShowPreview: TCheckBox;
        Label2: TLabel;
        rgFilterBy: TRadioGroup;
        seMaxPool: TSpinEdit;
        TICheckBox1: TTICheckBox;
        ToolBar3: TToolBar;
        tbOk: TToolButton;
        XMLPropStorage: TXMLPropStorage;
        procedure FormCreate(Sender: TObject);
        procedure tbOkClick(Sender: TObject);
        procedure XMLPropStorageRestoreProperties(Sender: TObject);
     private

     end;

var frmAppSettings: TfrmAppSettings;

implementation //==============================================================
uses frm_logger
     , u_xpl_application
     ;

procedure TfrmAppSettings.tbOkClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmAppSettings.FormCreate(Sender: TObject);
begin                                                                          // Correction of bug FS#60 : don't let settings
   XMLPropStorage.FileName := xPLApplication.Folders.DeviceDir + 'settings.xml';
   XMLPropStorage.Restore;                                                      // go anywhere, force it to be in the xpl app directory
   frmLogger.ApplySettings(self);
end;

procedure TfrmAppSettings.XMLPropStorageRestoreProperties(Sender: TObject);    // Correction of bug FS#39
begin
   frmLogger.ApplySettings(self);
end;

initialization
  {$I frm_appsettings.lrs}

end.

