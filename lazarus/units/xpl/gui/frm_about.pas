unit frm_about;
{==============================================================================
  UnitName      = frm_about
  UnitDesc      = Standard xPL / Lazarus About box - shared by all projects
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.1 : switched from xPLClient belonging to frm_main to app_main
 1.2 : Added License and Readme buttons
 1.3 : Added Credits button, url label, build date version
 1.4 : Added DEBUG info label
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

type

{ TfrmAbout }

TfrmAbout = class(TForm)
        acCredits: TAction;
        acLicense: TAction;
        acReadme: TAction;
        ActionList: TActionList;
        Image1: TImage;
        Image2: TImage;
        imgAppLogo: TImage;
        lblVendor: TLabel;
        lblBuildDate: TLabel;
        lblAppName: TLabel;
        mmoCredits: TMemo;
        mmoReadme: TMemo;
        acClose: TAction;
        mmoLicense: TMemo;
        PageControl1: TPageControl;
        ScrollBox1: TScrollBox;
        tsReadme: TTabSheet;
        tsLicense: TTabSheet;
        tsCredits: TTabSheet;
        tbLaunch: TToolButton;
        ToolBar: TToolBar;
        //procedure acCheckUpdateExecute(Sender: TObject);
        procedure acCloseExecute(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);

        //procedure UpdateAvailable(Sender : TObject);
        //procedure NoUpdateAvailable(Sender : TObject);
     end;

     procedure ShowFrmAbout;

implementation // ==============================================================
uses SysUtils
     , Graphics
     , lclversion
     , Windows
     , frm_DownloadFile
     , u_xpl_application
     , u_xpl_gui_resource
     , Dialogs
     ;

var  frmAbout: TfrmAbout;
// =============================================================================
const
     K_FILE_LICENSE = 'license.txt';
     K_FILE_README  = 'readme.txt';
     K_FILE_CREDITS = 'credits.txt';
     K_CREDITS_STR  = 'Compiled with Lazarus version %s';
     K_UPDATE_AVAIL = 'A new version is available : %s'#10' at %s'#10' Do you want to download it ?';
     K_UPDATE_STATUS = 'Update info';
     K_NO_UPDATE = 'Your application is up to date';

// =============================================================================
procedure ShowFrmAbout;
begin
   if not Assigned(frmAbout) then
      Application.CreateForm(TfrmAbout, frmAbout);
   frmAbout.ShowModal;
end;

// =============================================================================
procedure TfrmAbout.FormCreate(Sender: TObject);
begin
   tsReadme.Visible   := FileExists(K_FILE_README);
   tsLicense.Visible  := FileExists(K_FILE_LICENSE);
   tsCredits.Visible  := FileExists(K_FILE_CREDITS);
   Toolbar.Images     := xPLGUIResource.Images;
   lblAppName.Caption := xPLApplication.FullTitle;
   imgAppLogo.Picture.Assign(Application.Icon);
   image1.Picture.LoadFromLazarusResource('Indy');
   image2.Picture.LoadFromLazarusResource('splash_logo');
end;


procedure TfrmAbout.FormShow(Sender: TObject);
begin
   if tsCredits.Visible then mmoCredits.Lines.LoadFromFile(K_FILE_CREDITS);
   if tsReadme.Visible  then mmoReadme.Lines.LoadFromFile(K_FILE_README);
                             mmoReadme.Lines.Add(Format(K_CREDITS_STR,[lcl_version]));
   if tsLicense.Visible then mmoLicense.Lines.LoadFromFile(K_FILE_LICENSE);

(*   if not Assigned(xPLApplication.VChecker.OnUpdateFound) then begin
     xPLApplication.VChecker.OnUpdateFound   := @UpdateAvailable;
     xPLApplication.VChecker.OnNoUpdateFound := @NoUpdateAvailable;
   end;*)
end;

(*procedure TfrmAbout.UpdateAvailable(Sender: TObject);
var s : string;
begin
   s := Format(K_UPDATE_AVAIL,[xPLApplication.vChecker.ServerVersion,xPLApplication.VChecker.DownloadURL]);
   if Application.MessageBox(PChar(s),K_UPDATE_STATUS, MB_YESNO + MB_ICONQUESTION) = IDYES then
      ShowFrmDownloadFile( xPLApplication.vChecker.DownloadURL, '', false, false, true);
end;*)

(*procedure TfrmAbout.NoUpdateAvailable(Sender: TObject);
begin
   Application.MessageBox(K_NO_UPDATE,K_UPDATE_STATUS,0);
end;*)

procedure TfrmAbout.acCloseExecute(Sender: TObject);
begin
   Close;
end;

(*procedure TfrmAbout.acCheckUpdateExecute(Sender: TObject);
begin
   xPLApplication.CheckVersion;
end;*)

initialization // ==============================================================
{$I frm_about.lrs}

end.
