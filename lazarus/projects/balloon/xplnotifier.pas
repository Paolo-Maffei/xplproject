unit xplnotifier;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, PopupNotifier, StdCtrls,  Graphics, ExtCtrls, Forms, Controls;

type

   { TxPLNotifierForm }

  TxPLNotifierForm = class(TCustomForm)
  private
    lblTitle: TLabel;
    lblText: TLabel;
    backImg,
    icone,
    btnClose : TImage;
    procedure HideForm(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TxPLPopupNotifier }

TxPLPopupNotifier = class(TPopupNotifier)
     private
        fLevel : string;
        function Get_Level: string;
        procedure Set_Level(const AValue: string);

     public

        constructor Create(AOwner : TComponent); override;
        property level : string read Get_Level write Set_Level;
     end;

implementation

const INT_NOTIFIER_SCREEN_SPACING = 10;

{ TxPLPopupNotifier }

function TxPLPopupNotifier.Get_Level: string;
begin
  result := fLevel;
end;

procedure TxPLPopupNotifier.Set_Level(const AValue: string);
begin
  TxPLNotifierForm(vNotifierForm).Icone.Picture.LoadFromLazarusResource(aValue);
end;

constructor TxPLPopupNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  vNotifierForm.Free;
  vNotifierForm := TNotifierForm(TxPLNotifierForm.Create(self));
end;

{ TxPLNotifierForm }

constructor TxPLNotifierForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  backImg := TImage.Create(self);
  backImg.Picture.LoadFromLazarusResource('background');
  backImg.Left:=0;
  backImg.Top:=0;
  backImg.Parent:=self;
  backImg.AutoSize:=true;
  backImg.SendToBack;

  icone := TImage.Create(self);
  icone.Picture.LoadFromLazarusResource('inf');
  icone.Left:=6;
  icone.Top:=22;
  icone.Parent:=self;
  icone.AutoSize:=true;

  BorderStyle := bsNone;
  Width := backImg.Picture.Width;
  Height := backImg.Picture.Height;

  btnClose := TImage.Create(self);
  btnClose.Picture.LoadFromLazarusResource('exit');
  btnClose.Parent:=self;
  btnClose.AutoSize:=true;
  btnClose.Left:= width - btnClose.Picture.Width-6;
  btnClose.Top:= 6;
  btnClose.OnClick:=@HideForm;

  // Check for small screens. An extra spacing is necessary
  // in the Windows Mobile 5 emulator
  if Screen.Width - INT_NOTIFIER_SCREEN_SPACING < Width then
    Width := Screen.Width - INT_NOTIFIER_SCREEN_SPACING;

  lblTitle := TLabel.Create(Self);
  lblTitle.Parent := Self;
  lblTitle.AutoSize := True;
  lblTitle.Transparent := True;
  lblTitle.Font.Style := [FsBold];
  lblTitle.Caption := '';
  lblTitle.Left := 48;
  lblTitle.Top := 16;

  lblText := TLabel.Create(Self);
  lblText.Parent := Self;
  lblText.AutoSize := False;
  lblText.Transparent := True;
  lblText.Caption := '';
  lblText.WordWrap := True;
  lblText.Left := lblTitle.Left;
  lblText.Top  := 48;
  lblText.Width:= Width - lblText.Left;
  lblText.Height:= Height- lblTexT.Top;

  OnClick := @HideForm;
end;

{*******************************************************************
*  TxPLNotifierForm.Destroy ()
*
*  Releases associated resources of the notifier form
*******************************************************************}
destructor TxPLNotifierForm.Destroy;

begin
  backImg.Free;
  lblTitle.Free;
  lblText.Free;
  icone.free;
  inherited Destroy;
end;

{*******************************************************************
*  TxPLNotifierForm.HideForm ()
*
*  Utilized for events that hide the form, such as clicking on it
*******************************************************************}
procedure TxPLNotifierForm.HideForm(Sender: TObject);
Var NoValue :TCloseAction;
begin
if Assigned(OnClose) then
   OnClose(Self,NoValue);
  Hide;
end;

end.

