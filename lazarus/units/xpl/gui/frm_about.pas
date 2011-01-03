unit frm_about;
{==============================================================================
  UnitName      = frm_about
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.1 : switched from xPLClient belonging to frm_main to app_main
 1.2 : Added License and Readme buttons
 1.3 : Added Credits button, url label, build date version
}
{$mode objfpc}{$H+}

interface

uses Forms,
     Classes,
     Buttons,
     Controls,
     ExtCtrls,
     StdCtrls,
     LResources,
     ComCtrls,
     ActnList;

type TfrmAbout = class(TForm)
        acCredits: TAction;
        acLicense: TAction;
        acReadme: TAction;
        ActionList: TActionList;
        imLazarusLogo: TImage;
        ilStandardActions: TImageList;
        lblBuildDate: TLabel;
        lblAppName: TLabel;
        lblVersion: TLabel;
        mmoCredits: TMemo;
        OfficialURLLabel: TLabel;
        acClose: TAction;
        tbLaunch: TToolButton;
        ToolBar3: TToolBar;
        ToolButton1: TToolButton;
        ToolButton2: TToolButton;
        ToolButton3: TToolButton;
        ToolButton4: TToolButton;
        ToolButton5: TToolButton;
        ToolButton6: TToolButton;
        procedure acCloseExecute(Sender: TObject);
        procedure acCreditsExecute(Sender: TObject);
        procedure acLicenseExecute(Sender: TObject);
        procedure acReadmeExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure OfficialURLLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure OfficialURLLabelMouseEnter(Sender: TObject);
        procedure OfficialURLLabelMouseLeave(Sender: TObject);
     end;

var  frmAbout: TfrmAbout;

implementation // ==============================================================
uses app_main,
     SysUtils,
     FPCAdds,
     OpenURLUtil,
     Graphics,
     lclversion;

// =============================================================================
const
     K_FILE_LICENSE = 'license.txt';
     K_FILE_README  = 'readme.txt';
     K_FILE_CREDITS = 'credits.txt';
     K_VERSION_STR  = 'Version %s';
     K_BUILDAT_STR  = 'Date : %s';
     K_CREDITS_STR  = 'Compiled with Lazarus version %s';

// =============================================================================
function GetLocalizedBuildDate(): string;                                       // This code piece comes from Lazarus AboutFrm source
  var                                                                           // The compiler generated date string is always of the form y/m/d.
    BuildDate: string;                                                          // This function gives it a string respresentation according to the
    SlashPos1, SlashPos2: integer;                                              // shortdateformat
    Date: TDateTime;
  begin
    BuildDate := {$I %date%};
    SlashPos1 := Pos('/',BuildDate);
    SlashPos2 := SlashPos1 +
      Pos('/', Copy(BuildDate, SlashPos1+1, Length(BuildDate)-SlashPos1));
    Date := EncodeDate(StrToWord(Copy(BuildDate,1,SlashPos1-1)),
      StrToWord(Copy(BuildDate,SlashPos1+1,SlashPos2-SlashPos1-1)),
      StrToWord(Copy(BuildDate,SlashPos2+1,Length(BuildDate)-SlashPos2)));
    Result := FormatDateTime('yyyy-mm-dd', Date);
  end;

// =============================================================================
procedure TfrmAbout.FormCreate(Sender: TObject);
begin
   acReadme.Enabled  := FileExists(K_FILE_README);
   acLicense.Enabled := FileExists(K_FILE_LICENSE);
   acCredits.Enabled := FileExists(K_FILE_CREDITS);
   lblBuildDate.Caption := Format(K_BUILDAT_STR,[GetLocalizedBuildDate]);
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
   lblAppName.Caption := xPLClient.AppName;
   lblVersion.Caption := Format(K_VERSION_STR,[xPLClient.AppVersion]);
   if acCredits.Enabled then acCreditsExecute(self);
end;

procedure TfrmAbout. OfficialURLLabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   OpenURL(TLabel(Sender).Caption);
end;

procedure TfrmAbout. OfficialURLLabelMouseEnter(Sender: TObject);
begin
   TLabel(Sender).Font.Style := [fsUnderLine];
   TLabel(Sender).Font.Color := clRed;
   TLabel(Sender).Cursor := crHandPoint;
end;

procedure TfrmAbout. OfficialURLLabelMouseLeave(Sender: TObject);
begin
   TLabel(Sender).Font.Style := [];
   TLabel(Sender).Font.Color := clBlue;
   TLabel(Sender).Cursor := crDefault;
end;

procedure TfrmAbout.acCloseExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmAbout.acCreditsExecute(Sender: TObject);
begin
   mmoCredits.Lines.LoadFromFile(K_FILE_CREDITS);
   mmoCredits.Lines.Add(Format(K_CREDITS_STR,[lcl_version]));
end;

procedure TfrmAbout.acLicenseExecute(Sender: TObject);
begin
   mmoCredits.Lines.LoadFromFile(K_FILE_LICENSE);
end;

procedure TfrmAbout.acReadmeExecute(Sender: TObject);
begin
   mmoCredits.Lines.LoadFromFile(K_FILE_README);
end;

initialization // ==============================================================
{$I frm_about.lrs}

end.
