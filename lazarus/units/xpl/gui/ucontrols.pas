unit uControls;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, ExtCtrls, StdCtrls, ComCtrls, u_xpl_sender;

type { TxPLActionPanel }

     TxPLActionPanel = class(TPanel)
     private
        fImage  : TImage;
        fName   : TLabel;
        fStatus : TLabel;
        fAct1 : TButton;
        fAct2 : TButton;
        fxPLMessage : string;

        procedure ActClick(aSender : TObject);
     public
        xPLSender : TxPLSender;
        constructor create(aOwner : TComponent); override;

     published
        property xPLMessage : string      read fxPLMessage write fxPLMessage;

     end;

     { TxPLTimePanel }

     TxPLTimePanel = class(TPanel)
     private
        fTrack: TTrackBar;
        fAct1 : TButton;
        fAct2 : TButton;
        fPanel : TPanel;
        fName   : TLabel;
        procedure ActClick(aSender : TObject);
        function GetTime: TDateTime;
        procedure SetTime(const AValue: TDateTime);
        procedure TrackChange(aSender : TObject);
     public
        constructor create(aOwner : TComponent); override;
     property
        time : TDateTime read GetTime write SetTime;
     end;

     procedure Register;


implementation { TActionPanel }
uses Controls,StrUtils;

procedure TxPLActionPanel.ActClick(aSender: TObject);
var s : string;
begin
     s := AnsiReplaceText(xPLMessage,'%action%',TButton(aSender).Caption);
     xPLSender.SendMessage(s);
end;

constructor TxPLActionPanel.create(aOwner: TComponent);
begin
  inherited create(aOwner);
  BevelOuter := bvLowered;
  Caption := '';
  Width := 200;

  fImage  := TImage.Create(self);
  fImage.Parent := Self;
  fImage.Height := 48;
  fImage.Width  := 48;
  fImage.Align  := alLeft;

  fName  := TLabel.Create(self);
  fName.Parent := self;
  fName.Left := 50;
  fName.Top := 10;
  fName.Caption := 'Name';
  fName.Font.Bold := true;

  fStatus:= TLabel.Create(self);
  fStatus.Parent := self;
  fStatus.Left:=50;
  fStatus.Top := 30;
  fStatus.Caption:='Status';

  fAct1 := TButton.Create(self);
  fAct1.Parent := self;
  fAct1.Align := alRight;
  fAct1.Width := 48;
  fAct1.Caption:='Off';
  fAct1.OnClick:= @ActClick;

  fAct2 := TButton.Create(self);
  fAct2.Parent := self;
  fAct2.Align := alRight;
  fAct2.Width := 48;
  fAct2.Caption:='On';
  fAct2.OnClick := @ActClick;
end;

{ TxPLTimePanel }

constructor TxPLTimePanel.create(aOwner: TComponent);
begin
  inherited create(aOwner);
  BevelOuter := bvLowered;

  fAct1 := TButton.Create(self);
  fAct1.Parent := self;
  fAct1.Align := alLeft;
  fAct1.Width := 20;
  fAct1.Caption:='<';
  fAct1.OnClick:= @ActClick;

  fAct2 := TButton.Create(self);
  fAct2.Parent := self;
  fAct2.Align := alRight;
  fAct2.Width := fAct1.Width;
  fAct2.Caption:='>';
  fAct2.OnClick := @ActClick;

  fPanel := TPanel.Create(self);
  fPanel.Parent := self;
  fPanel.Align := alClient;

  fTrack := TTrackBar.Create(self);
  fTrack.Parent := fPanel;
  fTrack.Align  := alTop;
  fTrack.Frequency := 3600;
  fTrack.PageSize  := fTrack.Frequency;
  fTrack.Max       := 86400;
  fTrack.Position  := 0;
  fTrack.TickMarks := tmTopLeft;
  fTrack.OnChange  := @TrackChange;

  fName  := TLabel.Create(self);
  fName.Parent := fPanel;
  fName.Align := alBottom;
  fName.Caption := 'Name';
  fName.Alignment := taCenter;
end;

procedure TxPLTimePanel.ActClick(aSender: TObject);
var i : integer;
begin
   if aSender = fAct1 then i:=-1 else i:=+1;
   fTrack.Position := fTrack.position + (i*60);
   TrackChange(asender);
end;

function TxPLTimePanel.GetTime: TDateTime;
begin result := StrToTime(fName.Caption); end;

procedure TxPLTimePanel.SetTime(const AValue: TDateTime);
var Hour, Minute, Second, MilliSecond : word;
begin
   DecodeTime(aValue,Hour,Minute,Second,Millisecond);
   fTrack.position := Hour * 3600 + Minute * 60;
   TrackChange(nil);
end;

procedure TxPLTimePanel.TrackChange(aSender: TObject);
var h, m : integer;
    reste : integer;
begin
   h := fTrack.Position div 3600;
   if h > 23 then h := 23;
   reste := fTrack.position - (h * 3600);
   m := reste div 60;
   if m > 59 then m := 59;
   fName.Caption :=  FormatDateTime('hh:nn',EncodeTime(h,m,0,0));
end;

procedure Register;
begin
  RegisterComponents('xPL Components',[TxPLActionPanel, TxPLTimePanel]);
end;


end.

