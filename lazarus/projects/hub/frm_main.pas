unit frm_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, StdCtrls;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
  end;

var
  FrmMain: TFrmMain;


implementation //===============================================================
uses app_main,
     StrUtils,
     DateUtils;

{==============================================================================}
//const

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   xPLHub := TxPLHub.Create;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   xPLHub.Destroy;
end;

procedure TFrmMain.FormShow(Sender: TObject);
var b : boolean;
begin
  b := xPLHub.Start;
  Memo1.Lines.Add(Application.Title + ' ' + K_XPL_APP_VERSION_NUMBER + ' by ' + K_DEFAULT_VENDOR);
  Memo1.Lines.Add(IfThen(b,'Hub started and listening','Error starting hub, please check that xPL settings are set and port 3865 is free'));
  if b then begin
     Memo1.Lines.Add('Binded on :');
     Memo1.Lines.AddStrings(xPLHub.Bindings);
  end;
end;

initialization
  {$I frm_main.lrs}

end.

