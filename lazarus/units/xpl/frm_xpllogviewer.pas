unit frm_xpllogviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, ComCtrls, Buttons, StdCtrls;

type TfrmLogViewer = class(TForm)
        ActionList1: TActionList;
        ImageList1: TImageList;
        Memo1: TMemo;
        Quit: TAction;
        SpeedButton1: TSpeedButton;
        ToolBar2: TToolBar;
        procedure FormShow(Sender: TObject);
        procedure QuitExecute(Sender: TObject);
     end;

var  frmLogViewer: TfrmLogViewer;

implementation { TfrmLogViewer ================================================}
uses frm_main;

procedure TfrmLogViewer.QuitExecute(Sender: TObject);
begin Close; end;

procedure TfrmLogViewer.FormShow(Sender: TObject);
begin
//  frmMain.xPLClient.EventLog.Flush;

//  pos := frmMain.xPLClient.EventLog.Stream.Position ;
//  frmMain.xPLClient.EventLog.Stream.Seek (0,soFromBeginning);

//  Memo1.Lines.LoadFromStream(frmMain.xPLClient.EventLog.Stream);
  Memo1.Lines.LoadFromFile(frmMain.xPLClient.LogFileName);
//  frmMain.xPLClient.EventLog.Stream.Seek (pos,soFromBeginning);
end;

initialization
  {$I frm_xpllogviewer.lrs}

end.

