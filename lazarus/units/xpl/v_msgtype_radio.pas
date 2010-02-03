unit v_msgtype_radio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, uxPLMsgHeader, uxPLConst;

type
  { TxPLMsgTypeRadio }

TxPLMsgTypeRadio = class(TRadioGroup)
     private
        FShowAny : boolean;

        function GetIsValid: boolean;
        function GetMessageType : TxPLMessageType;
        procedure SetMessageType(const AValue: TxPLMessageType);
        procedure SetShowAny(const AValue: boolean);
     public
        constructor create(aOwner : TComponent); override;
        property ItemIndex : TxPLMessageType read GetMessageType write SetMessageType;
        property IsValid   : boolean         read GetIsValid;
     published
        property bShowAny : boolean read FShowAny write SetShowAny;
     end;

     procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('xPL Components',[TxPLMsgTypeRadio]);
end;

{ TxPLMsgTypeRadio }

function TxPLMsgTypeRadio.GetMessageType: TxPLMessageType;
begin
  Result := TxPLMessageType(inherited ItemIndex);
end;

function TxPLMsgTypeRadio.GetIsValid: boolean;
begin
  //result := ((inherited ItemIndex >=0) and (inherited ItemIndex<=2))
  result := true;
end;

procedure TxPLMsgTypeRadio.SetMessageType(const AValue: TxPLMessageType);
begin
  inherited ItemIndex := Ord(aValue);
end;

procedure TxPLMsgTypeRadio.SetShowAny(const AValue: boolean);
begin
  //if aValue <> FShowAny then exit;
  FShowAny := aValue;
  Items.Clear ;
  Items.Add('Trigger');
  Items.Add('Status');
  Items.Add('Command');
  if FShowAny then Items.Add('Any');
  Columns := Items.Count ;
end;

constructor TxPLMsgTypeRadio.create(aOwner: TComponent);
begin
  inherited create(aOwner);

  Height := 37;
  Width  := 256;
end;

end.

