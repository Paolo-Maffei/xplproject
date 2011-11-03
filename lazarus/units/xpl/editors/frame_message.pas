unit frame_message;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, StdCtrls, ExtCtrls,
  RTTICtrls
  , u_xpl_custom_message;

type

  { TTMessageFrame }

  TTMessageFrame = class(TFrame)
    ckGeneric: TTICheckBox;
    edtBody: TTIMemo;
    edtHop: TTISpinEdit;
    edtSchema: TTIEdit;
    edtSource: TTIEdit;
    edtTarget: TTIEdit;
    Image1: TImage;
    Image2: TImage;
    Label10: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    cbMsgType: TTIComboBox;
    lblTS: TTILabel;
    lblSize: TTILabel;
    procedure cbMsgTypeEditingDone(Sender: TObject);
    procedure edtBodyEditingDone(Sender: TObject);
    procedure edtSchemaEditingDone(Sender: TObject);
  private
    fMessage : TxPLCustomMessage;
    fReadOnly: boolean;
    procedure Set_Message(const AValue: TxPLCustomMessage);
    procedure Set_ReadOnly(const AValue: boolean);
  public
    constructor Create(TheOwner: TComponent); override;

  published
    property TheMessage : TxPLCustomMessage read fMessage write Set_Message;
    property ReadOnly   : boolean     read fReadOnly write Set_ReadOnly;
  end; 

implementation //==============================================================
uses u_xpl_header
     , u_xpl_common
     , typinfo
     ;

// TTMessageFrame =============================================================
procedure TTMessageFrame.cbMsgTypeEditingDone(Sender: TObject);
begin
  if Assigned(fMessage) then
  try
     Image2.Picture.LoadFromLazarusResource(MsgTypeToStr(fMessage.MessageType));
  except                                                                       // The ressource may not be present for the searched class of messages
  end;
end;

procedure TTMessageFrame.edtBodyEditingDone(Sender: TObject);
begin
  fMessage.Body.Strings := TStringList(edtBody.Lines);
end;

procedure TTMessageFrame.edtSchemaEditingDone(Sender: TObject);
begin
  Image1.Visible := (lazarusResources.Find(fMessage.Schema.Classe)<>nil);      // The ressource may not be present for the searched class of messages
  If Image1.Visible then Image1.Picture.LoadFromLazarusResource(fMessage.Schema.Classe);
end;

procedure TTMessageFrame.Set_Message(const AValue: TxPLCustomMessage);
begin
   fMessage := aValue;
   cbMsgType.Link.TIObject := AValue;
   edtSource.Link.TIObject := AValue.Source;
   edtTarget.Link.TIObject := AValue.Target;
   edtSchema.Link.TIObject := AValue.Schema;
   edtBody.Link.TIObject   := AValue.Body;
   cbMsgType.Link.TIObject := AValue;
   ckGeneric.Link.TIObject := AValue.Target;
   edtHop.Link.TIObject    := AValue;
   lblTS.Link.TIObject     := AValue;
   lblSize.Link.TIObject   := AValue;

   cbMsgTypeEditingDone(self);
   edtSchemaEditingDone(self);
end;

procedure TTMessageFrame.Set_ReadOnly(const AValue: boolean);
begin
  if fReadOnly=AValue then exit;
  fReadOnly:=AValue;

  edtBody.ReadOnly   := fReadOnly;
  edtSchema.ReadOnly := fReadOnly;
  edtTarget.ReadOnly := fReadOnly;
  edtSource.ReadOnly := fReadOnly;
  cbMsgType.ReadOnly := fReadOnly;
  cbMsgType.Enabled  := not fReadOnly;
  ckGeneric.Visible  := not fReadOnly;
  edtHop.ReadOnly    := fReadOnly;
end;

constructor TTMessageFrame.Create(TheOwner: TComponent);

begin
   inherited Create(TheOwner);
   edtSource.Link.TIPropertyName := 'rawxpl';
   cbMsgType.Link.TIPropertyName := 'MessageType';
   edtTarget.Link.TIPropertyName := 'rawxpl';
   edtSchema.Link.TIPropertyName := 'rawxpl';
   edtBody.Link.TIPropertyName   := 'Strings';
   cbMsgType.Link.TIPropertyName := 'MessageType';
   ckGeneric.Link.TIPropertyName := 'isgeneric';
   edtHop.Link.TIPropertyName    := 'hop';
   lblTS.Link.TIPropertyName     := 'timestamp';
   lblSize.Link.TIPropertyName   := 'size';
end;

initialization //==============================================================
  {$I frame_message.lrs}
  {$I ..\res\class\class.lrs}
  {$I ..\res\msgtype\msgtype.lrs}

end.

