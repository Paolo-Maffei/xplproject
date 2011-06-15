unit xplnotifier;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls,  Graphics, ExtCtrls, Forms, Controls;

type

   { TxPLNotifierForm }

  TxPLNotifierForm = class(TCustomForm)
  private
    lblTitle,
    lblText: TLabel;
    backImg,
    icone,
    btnClose : TImage;
    panel : TPanel;
    procedure HideForm(Sender: TObject);
  public

    constructor Create(AOwner: TComponent); override;
  end;

{ TxPLPopupNotifier }

  TxPLPopupNotifier = class(TComponent)
     private
        fLevel : TEventType;
        function GetText: string;
        function GetTitle: string;
        function Get_Level: TEventType;
        procedure SetText(const AValue: string);
        procedure SetTitle(const AValue: string);
        procedure Set_Level(const AValue: TEventType);

     public
       vNotifierForm: TxPLNotifierForm;
        constructor Create(AOwner : TComponent); override;
        destructor Destroy; override;
        procedure Hide;
        procedure Show;
        property level : TEventType read Get_Level write Set_Level;
     published
       property Text: string read GetText write SetText;
       property Title: string read GetTitle write SetTitle;
     end;

implementation
uses typinfo
     ;

const INT_NOTIFIER_SCREEN_SPACING = 10;

{ TxPLPopupNotifier }

function TxPLPopupNotifier.Get_Level: TEventType;
begin
   result := fLevel;
end;

function TxPLPopupNotifier.GetText: string;
begin
   Result := vNotifierForm.lblText.Caption;
end;

function TxPLPopupNotifier.GetTitle: string;
begin
   Result := vNotifierForm.lblTitle.Caption;
end;

procedure TxPLPopupNotifier.SetText(const AValue: string);
begin
   vNotifierForm.lblText.Caption := aValue;
end;

procedure TxPLPopupNotifier.SetTitle(const AValue: string);
begin
   vNotifierForm.lblTitle.Caption := aValue;
end;

procedure TxPLPopupNotifier.Set_Level(const AValue: TEventType);
begin
   TxPLNotifierForm(vNotifierForm).Icone.Picture.LoadFromLazarusResource(
      GetEnumName(TypeInfo(TEventType),Ord(aValue)));
end;

constructor TxPLPopupNotifier.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   vNotifierForm := TxPLNotifierForm.Create(self);
   vNotifierForm.Visible := false;
end;

destructor TxPLPopupNotifier.Destroy;
begin
   vNotifierForm.Hide;

  // The following line needs to be removed if we have
  // vNotifierForm := TNotifierForm.Create(Application);
   vNotifierForm.Free;

   inherited Destroy;
end;

procedure TxPLPopupNotifier.Hide;
begin
   vNotifierForm.Hide;
end;

procedure TxPLPopupNotifier.Show;
begin
   vNotifierForm.Show;
end;

{ TxPLNotifierForm }

constructor TxPLNotifierForm.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   height := 120;
   width  := 250;

   panel := TPanel.Create(self);
   panel.parent := self;
   panel.Align  := alClient;
   panel.BevelInner := bvlowered;

   backImg := TImage.Create(self);
   backImg.Parent := panel;
   backImg.Align  := alClient;
   backImg.AutoSize := True;
   backimg.height := height;
   backimg.width  := width;
   backImg.Canvas.GradientFill(backImg.clientrect,clSkyBlue,clWhite,gdVertical);

   icone := TImage.Create(self);
   icone.Picture.LoadFromLazarusResource('etInfo');
   icone.Left:=6;
   icone.Top:=22;
   icone.Parent:=panel;
   icone.AutoSize:=true;

   BorderStyle := bsNone;

   btnClose := TImage.Create(self);
   btnClose.Picture.LoadFromLazarusResource('exit');
   btnClose.Parent:=panel;
   btnClose.AutoSize:=true;
   btnClose.Left:= width - btnClose.Picture.Width-6;
   btnClose.Top:= 6;
   btnClose.OnClick:=@HideForm;

   // Check for small screens. An extra spacing is necessary
   // in the Windows Mobile 5 emulator
   if Screen.Width - INT_NOTIFIER_SCREEN_SPACING < Width then
      Width := Screen.Width - INT_NOTIFIER_SCREEN_SPACING;

   lblTitle := TLabel.Create(Self);
   lblTitle.Parent := panel;
   lblTitle.AutoSize := True;
   lblTitle.Transparent := True;
   lblTitle.Font.Style := [FsBold];
   lblTitle.Caption := '';
   lblTitle.Left := 48;
   lblTitle.Top := 16;

   lblText := TLabel.Create(Self);
   lblText.Parent := panel;
   lblText.AutoSize := False;
   lblText.Transparent := True;
   lblText.Caption := '';
   lblText.WordWrap := True;
   lblText.Left := lblTitle.Left;
   lblText.Top  := 48;
   lblText.Width:= Width - lblText.Left;
   lblText.Height:= Height- lblTexT.Top;
end;

{*******************************************************************
*  TxPLNotifierForm.HideForm ()
*
*  Utilized for events that hide the form, such as clicking on it
*******************************************************************}
procedure TxPLNotifierForm.HideForm(Sender: TObject);
begin
   Hide;
end;

end.

