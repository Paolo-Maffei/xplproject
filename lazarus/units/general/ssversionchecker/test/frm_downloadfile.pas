unit frm_DownloadFile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, IdHTTP, IdHeaderList, IdComponent, IdAntiFreeze;

type

  { TfrmDownloadFile }

  TfrmDownloadFile = class(TForm)
    btnSelectDir: TButton;
    ckAutoClose: TCheckBox;
    IdAntiFreeze1: TIdAntiFreeze;
    IdHTTP1: TIdHTTP;
    ilStandardActions: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    lblFrom: TLabel;
    lblTo: TLabel;
    ProgressBar: TProgressBar;
    SelectDirDialog: TSelectDirectoryDialog;
    btnClose: TToolButton;
    ToolBar3: TToolBar;
    btnStart: TToolButton;
    ToolButton2: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure IdHTTP1HeadersAvailable(Sender: TObject; AHeaders: TIdHeaderList; var VContinue: Boolean);
    procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    XMLStream   : TFileStream;
    AutoStart   : boolean;
    Notify      : boolean;
    Destination : string;
    bFirstActivation : boolean;
  public

  end; 

var
  frmDownloadFile: TfrmDownloadFile;

  procedure ShowFrmDownloadFile(const aSource, aDestination : string; const bAutoStart, bAutoClose, bNotify : boolean);

implementation
uses uRegExpr, StrUtils;

procedure ShowFrmDownloadFile(const aSource, aDestination: string; const bAutoStart, bAutoClose, bNotify: boolean);
begin
   frmDownloadFile.lblFrom.Caption := aSource;
   frmDownloadFile.lblTo.Caption := IfThen(aDestination = '', GetTempDir, aDestination);
   frmDownloadFile.AutoStart:=bAutoStart;
   frmDownloadFile.ckAutoClose.Checked:=bAutoClose;
   frmDownloadFile.Notify:=bNotify;
   frmDownloadFile.ShowModal;
end;

{ TfrmDownloadFile }
procedure TfrmDownloadFile.FormShow(Sender: TObject);
begin
   ProgressBar.Visible := False;
   btnStart.Visible := not AutoStart;
   btnClose.Enabled := not ckAutoClose.Checked;
   bFirstActivation := true;
end;

procedure TfrmDownloadFile.btnStartClick(Sender: TObject);
begin
   Destination := lblTo.Caption;
   XMLStream := TFileStream.Create( FileUtil.GetTempFileName(lblTo.Caption,'') , fmCreate);
   IdHTTP1.Get(lblFrom.Caption,XMLStream);
end;

procedure TfrmDownloadFile.FormActivate(Sender: TObject);
begin
   if (bFirstActivation and AutoStart) then btnStartClick(self);
   bFirstActivation := False;
end;

procedure TfrmDownloadFile.IdHTTP1HeadersAvailable(Sender: TObject; AHeaders: TIdHeaderList; var VContinue: Boolean);
begin
   with TRegExpr.Create do begin
        Expression := 'filename=(.*?);';
        vContinue  := Exec(aHeaders.Text);
        if vContinue then begin
           Destination += Match[1];
           DeleteFile(Destination);                        // Be sure the file doesn't already exist with this name
        end;
        Destroy;
   end;
end;

procedure TfrmDownloadFile.IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
   ProgressBar.Visible  := True;
   ProgressBar.Max      := aWorkCountMax;
   btnSelectDir.Enabled := false;
   btnStart.Enabled := False;
end;

procedure TfrmDownloadFile.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
   ProgressBar.Position := aWorkCount;
   Application.ProcessMessages;
end;

procedure TfrmDownloadFile.IdHTTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode );
begin
   btnSelectDir.Enabled := true;
   btnStart.Enabled := true;
   if Notify then Application.MessageBox('Download completed','File Download',0);
   if CkAutoClose.Checked then btnCloseClick(self);
end;

procedure TfrmDownloadFile.btnSelectDirClick(Sender: TObject);
begin
   SelectDirDialog.InitialDir:=Destination;
   if SelectDirDialog.Execute then lblTo.Caption := SelectDirDialog.FileName + DirectorySeparator;
end;

procedure TfrmDownloadFile.btnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmDownloadFile.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var fn : string;
    f : file;
begin
   if Assigned(XMLStream) then begin
      fn := XMLStream.Filename;
      XMLStream.Free;
      AssignFile(f, fn);
      Rename(f,Destination);
   end;
end;


initialization
  {$I frm_downloadfile.lrs}

end.

