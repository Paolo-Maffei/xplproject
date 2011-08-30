unit frm_messages;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Grids, ComCtrls, u_xpl_custom_message;

type

  { TfrmMessages }

  TfrmMessages = class(TForm)
    dgMessages: TStringGrid;
    procedure dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure Display(aMessage : string);
  end; 

var
  frmMessages: TfrmMessages;

implementation
uses u_xpl_message
     , u_xpl_messages
     , u_xpl_gui_resource
     , ExtCtrls
     ;

{ TfrmMessages }

procedure TfrmMessages.FormCreate(Sender: TObject);
begin
   dgMessages.Columns[0].Width := 130;
   dgMessages.Columns[1].Width := 50;
   dgMessages.Columns[2].Width := 150;
   dgMessages.Columns[3].Width := 300;
end;

procedure TfrmMessages.dgMessagesDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var aMsg : TxPLMessage;
    img : TImage;
    s : string;
begin
   if aCol = 0 then begin
      aMsg := TxPLMessage(dgMessages.Objects[0,aRow]);
      if assigned(aMsg) then
         try
            img := TImage.Create(self);
            if aMsg is TLogBasic then
               Case TLogBasic(aMsg).Type_ of
                    etInfo    : img.Picture.LoadFromLazarusResource('greenbadge');
                    etWarning : img.Picture.LoadFromLazarusResource('orangebadge');
                    etError   : img.Picture.LoadFromLazarusResource('redbadge');
               end
            else if aMsg is TOsdBasic then
                 img.Picture.LoadFromLazarusResource('menu_information');
            dgMessages.Canvas.Draw(aRect.Left+2,aRect.Top+2,img.Picture.Graphic);
         finally
            img.free;
         end;
   end;
end;

procedure TfrmMessages.Display(aMessage: string);
var aMsg : TxPLMessage;
begin
   aMsg := MessageBroker(aMessage);
   dgMessages.RowCount := dgMessages.RowCount+1;
   dgMessages.Objects[0,dgMessages.Rowcount-1] := aMsg;
   dgMessages.Cells[1,dgMessages.RowCount-1] := DateTimeToStr(now);
   dgMessages.Cells[2,dgMessages.RowCount-1] := aMsg.schema.Classe;
   dgMessages.Cells[3,dgMessages.RowCount-1] := aMsg.source.RawxPL;
   dgMessages.Cells[4,dgMessages.RowCount-1] := '';
   if aMsg is TLogBasic then
     dgMessages.Cells[4,dgMessages.RowCount-1] := TLogBasic(aMsg).text;
   if aMsg is TOSDBasic then
     dgMessages.Cells[4,dgMessages.RowCount-1] := TOSDBasic(aMsg).text;
end;

initialization
  {$I frm_messages.lrs}

end.

