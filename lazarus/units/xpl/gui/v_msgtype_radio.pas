unit v_msgtype_radio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls;

type
  { TxPLMsgTypeRadio }

TxPLMsgTypeRadio = class(TRadioGroup)
     private
        FShowAny : boolean;

        //function GetIsValid: boolean;
        //function GetMessageType : string;
        //procedure SetMessageType(const AValue: string);
        procedure SetShowAny(const AValue: boolean);
     public
        constructor create(aOwner : TComponent); override;
        //property ItemIndex : tsMsgType read GetMessageType write SetMessageType;
        //property IsValid   : boolean         read GetIsValid;
     published
        property bShowAny : boolean read FShowAny write SetShowAny;
     end;

     procedure Register;

implementation
uses u_xpl_common;

procedure Register;
begin
  RegisterComponents('xPL Components',[TxPLMsgTypeRadio]);
end;

{ TxPLMsgTypeRadio }

(*function TxPLMsgTypeRadio.GetMessageType: tsMsgType;
begin
  Result := MsgTypeToString(TxPLMessageType(ItemIndex)); //K_MSG_TYPE_DESCRIPTORS[inherited ItemIndex];
end;*)

//function TxPLMsgTypeRadio.GetIsValid: boolean;
//begin
//  result := true;
//end;

(*procedure TxPLMsgTypeRadio.SetMessageType(const AValue: tsMsgType);
begin
  inherited ItemIndex := Ord(tsMsgType);
end;*)

procedure TxPLMsgTypeRadio.SetShowAny(const AValue: boolean);
var mt : TxPLMessageType;
begin
  FShowAny := aValue;
  Items.Clear ;
  for mt:=Low(TxPLMessageType) to High(TxPLMessageType) do
      Items.Add(MsgTypeToStr(mt));
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

