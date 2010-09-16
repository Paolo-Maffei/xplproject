unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  ComCtrls, Menus, ActnList, ExtCtrls, StdCtrls, Grids, EditBtn,
  Buttons;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    StatusBar1: TStatusBar;

    procedure AboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
  private
  public
  end;

var  frmMain: TfrmMain;

implementation //======================================================================================
uses frm_about,
     frm_xpllogviewer,
     frm_xplappslauncher,
     app_main;

//=====================================================================================================
procedure TfrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
begin frmLogViewer.ShowModal; end;

procedure TfrmMain.MenuItem4Click(Sender: TObject);
begin frmAppLauncher.ShowModal; end;

procedure TfrmMain.MenuItem6Click(Sender: TObject);
begin
   Close;
   xPLApplication.Terminate;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.Caption := xPLApplication.xPLClient.AppName;
  Memo1.Lines.Add('Started');
end;

initialization
  {$I frm_main.lrs}

end.

