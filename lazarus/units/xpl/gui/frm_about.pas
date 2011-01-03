unit frm_about;
{==============================================================================
  UnitName      = frm_about
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.1 : switched from xPLClient belonging to frm_main to app_main
 1.2 : Added License and Readme buttons
}
{$mode objfpc}{$H+}

interface

uses Forms,
     Classes,
     Buttons,
     Controls,
     ExtCtrls,
     StdCtrls,
     LResources;

type

{ TfrmAbout }

TfrmAbout = class(TForm)
        btnOk: TButton;
        btnReadme: TButton;
        btnLicense: TButton;
        imLazarusLogo: TImage;
        ilStandardActions: TImageList;
        Label1: TLabel;
        lblAppName: TLabel;
        lblVersion: TLabel;
        mmoCredits: TMemo;
        procedure btnLicenseClick(Sender: TObject);
        procedure btnReadmeClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
     end;

var  frmAbout: TfrmAbout;

implementation // ==============================================================
uses app_main,
     SysUtils,
     lclversion;

// =============================================================================
const
     K_FILE_LICENSE = 'license.txt';
     K_FILE_README  = 'readme.txt';
     K_VERSION_STR  = 'Version %s';
     K_CREDITS_STR  = '%s Compiled with Lazarus version %s';

// =============================================================================
procedure TfrmAbout.FormCreate(Sender: TObject);
begin
   mmoCredits.Text    := Format(K_CREDITS_STR,[mmoCredits.Text,lcl_version]);
   btnReadme.Visible  := FileExists(K_FILE_README);
   btnLicense.Visible := FileExists(K_FILE_LICENSE);
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
   lblAppName.Caption := xPLClient.AppName;
   lblVersion.Caption := Format(K_VERSION_STR,[xPLClient.AppVersion]);
end;

procedure TfrmAbout.btnReadmeClick(Sender: TObject);
begin
   mmoCredits.Lines.LoadFromFile(K_FILE_README);
end;

procedure TfrmAbout.btnLicenseClick(Sender: TObject);
begin
   mmoCredits.Lines.LoadFromFile(K_FILE_LICENSE);
end;

initialization // ==============================================================
{$I frm_about.lrs}

end.
