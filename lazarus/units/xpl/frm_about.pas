unit frm_about;
{==============================================================================
  UnitName      = frm_about
  UnitVersion   = 1.0
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================}
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
     StdCtrls, ExtCtrls, Buttons, XMLPropStorage;

type { TfrmAbout ==============================================================}

TfrmAbout = class(TForm)
  btnOk: TButton;
        imLazarusLogo: TImage;
        ilStandardActions: TImageList;
        Label1: TLabel;
        lblAppName: TLabel;
        lblVersion: TLabel;
        mmoCredits: TMemo;
        XMLPropStorage: TXMLPropStorage;
        procedure FormCreate(Sender: TObject);
     end;

var  frmAbout: TfrmAbout;

implementation // ==============================================================
uses frm_main, lclversion;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
   lblAppName.Caption := frmMain.xPLClient.AppName;
   lblVersion.Caption := 'Version ' + frmMain.xPLClient.AppVersion;
   mmoCredits.Text := mmoCredits.Text + 'Compiled with Lazarus version ' + lcl_version;
end;

initialization // ==============================================================
{$I frm_about.lrs}

end.

