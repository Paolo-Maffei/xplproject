unit frm_DownloadFile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, u_Downloader_Indy, IdComponent;

type

  { TfrmDownloadFile }

  { TDownloader }

  TfrmDownloadFile = class(TForm)
    btnSelectDir: TButton;
    ckAutoClose: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    lblError: TLabel;
    lblFrom: TLabel;
    lblTo: TLabel;
    ProgressBar: TProgressBar;
    SelectDirDialog: TSelectDirectoryDialog;
    btnClose: TToolButton;
    ToolBar: TToolBar;
    btnStart: TToolButton;
    ToolButton2: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure IdHTTP1Abort(aSender: TObject; anError : integer);
  private
    Notify,AutoStart : boolean;
    downloader  : TDownloader;
  public

  end; 

  function ShowFrmDownloadFile(const aSource, aDestination : string; const bAutoStart, bAutoClose, bNotify : boolean) : string;

implementation // =============================================================
uses StrUtils,
     u_xpl_gui_resource;

var frmDownloadFile: TfrmDownloadFile;

function ShowFrmDownloadFile(const aSource, aDestination: string; const bAutoStart, bAutoClose, bNotify: boolean) : string;
begin
   if not Assigned(frmDownloadFile) then Application.CreateForm(tFrmDownloadFile, frmDownloadFile);

   frmDownloadFile.lblFrom.Caption := aSource;
   frmDownloadFile.lblTo.Caption := IfThen(aDestination<>'',aDestination,GetTempDir);
   frmDownloadFile.ckAutoClose.Checked:=bAutoClose;
   frmDownloadFile.Notify:=bNotify;
   frmDownloadFile.AutoStart := bAutoStart;
   frmDownloadFile.ShowModal;
   result := frmDownloadFile.lblError.Caption;
end;

{ TfrmDownloadFile }
procedure TfrmDownloadFile.FormShow(Sender: TObject);
begin
   ProgressBar.Visible := False;
   btnClose.Enabled := not ckAutoClose.Checked;
   btnStart.Enabled := true;
   Toolbar.Images   := xPLGUIResource.Images;
   lblError.Caption := '';
   if AutoStart then btnStartClick(nil);
end;

procedure TfrmDownloadFile.btnStartClick(Sender: TObject);
begin
   btnStart.Enabled:=false;
   Downloader.Start(lblFrom.Caption,lblTo.Caption);
end;

procedure TfrmDownloadFile.FormCreate(Sender: TObject);
begin
   Downloader := TDownloader.Create;
   Downloader.OnWork:=@IdHTTP1Work;
   Downloader.OnWorkBegin := @IdHTTP1WorkBegin;
   Downloader.OnWorkEnd   := @IdHTTP1WorkEnd;
   Downloader.OnWorkAbort     := @IdHTTP1Abort;
end;

procedure TfrmDownloadFile.FormDestroy(Sender: TObject);
begin
   Downloader.Free;
end;

procedure TfrmDownloadFile.IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
   ProgressBar.Visible  := True;
   ProgressBar.Max      := aWorkCountMax;
   btnSelectDir.Enabled := false;
   btnStart.Enabled     := False;
end;

procedure TfrmDownloadFile.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
   ProgressBar.Position := aWorkCount;
   Application.ProcessMessages;
end;

procedure TfrmDownloadFile.IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode );
begin
   if Notify then Application.MessageBox('File download completed','Information',0);
   if CkAutoClose.Checked then btnCloseClick(self);
   btnSelectDir.Enabled := true;
   btnStart.Enabled := true;
end;

procedure TfrmDownloadFile.IdHTTP1Abort(aSender : TObject; anError : integer);
begin
   ckAutoClose.Checked := false;
   btnClose.Enabled := true;
   lblError.Caption := Format('HTTP Error : %d',[anError]);
end;

procedure TfrmDownloadFile.btnSelectDirClick(Sender: TObject);
begin
   SelectDirDialog.InitialDir:=lblTo.Caption;
   if SelectDirDialog.Execute then lblTo.Caption := SelectDirDialog.FileName + DirectorySeparator;
end;

procedure TfrmDownloadFile.btnCloseClick(Sender: TObject);
begin
   Close;
end;

{ TDownloader }

initialization
  {$I frm_downloadfile.lrs}

end.

