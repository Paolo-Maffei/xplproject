unit frm_xpllogviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ActnList, StdCtrls, Buttons;

type

  { TfrmLogViewer }

  TfrmLogViewer = class(TForm)
    Empty: TAction;
    Quit: TAction;
    ActionList1: TActionList;
    Memo1: TMemo;
    SpeedButton1: TSpeedButton;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    procedure EmptyExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
  private
  public
  end;

var frmLogViewer: TfrmLogViewer;

implementation
uses app_main,
     frm_about;

procedure TfrmLogViewer.QuitExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmLogViewer.FormShow(Sender: TObject);
begin
   Memo1.Clear;
   Caption := xPLClient.LogFileName;
   Memo1.Lines.LoadFromFile(Caption);
end;

procedure TfrmLogViewer.EmptyExecute(Sender: TObject);
begin
   Memo1.Lines.Clear;
   xPLClient.ResetLog;
end;

initialization
  {$I frm_xpllogviewer.lrs}

end.

