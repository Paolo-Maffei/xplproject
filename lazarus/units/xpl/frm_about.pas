unit frm_about;
{==============================================================================
  UnitName      = frm_about
  UnitVersion   = 1.0
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.1 : switched from xPLClient belonging to frm_main to app_main
}
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
     StdCtrls, ExtCtrls, Buttons;

type { TfrmAbout ==============================================================}

     TfrmAbout = class(TForm)
        btnOk: TButton;
        imLazarusLogo: TImage;
        ilStandardActions: TImageList;
        Label1: TLabel;
        lblAppName: TLabel;
        lblVersion: TLabel;
        mmoCredits: TMemo;
        procedure FormCreate(Sender: TObject);
     end;

var  frmAbout: TfrmAbout;

implementation // ==============================================================
uses app_main,
     lclversion;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
   lblAppName.Caption := xPLApplication.xPLClient.AppName;
   lblVersion.Caption := 'Version ' + xPLApplication.xPLClient.AppVersion;
   mmoCredits.Text    := mmoCredits.Text + 'Compiled with Lazarus version ' + lcl_version;
end;

initialization // ==============================================================
{$I frm_about.lrs}

end.
