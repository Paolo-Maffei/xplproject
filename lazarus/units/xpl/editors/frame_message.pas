unit frame_message;

{$mode objfpc}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LSControls, LResources, Forms, Controls,
  StdCtrls, ExtCtrls, ComCtrls, u_xpl_custom_message;

type // TTMessageFrame ========================================================
     TTMessageFrame = class(TFrame)
       cbMsgType: TLSComboBox;
        cbSchema: TLSComboBox;
        cbTarget: TLSComboBox;
        edtBody: TLSMemo;
        edtSource: TLSEdit;
        Image1: TImage;
        Image2: TImage;
        sbMessage: TStatusBar;
        procedure cbMsgTypeEditingDone(Sender: TObject);
        procedure cbSchemaEditingDone(Sender: TObject);
        procedure cbTargetEditingDone(Sender: TObject);
        procedure edtBodyEditingDone(Sender: TObject);
        procedure edtSourceEditingDone(Sender: TObject);
     private
        fMessage : TxPLCustomMessage;
        procedure Set_Message(const AValue: TxPLCustomMessage);
        procedure Set_ReadOnly(const AValue: boolean);
        procedure UpdateDisplay;
     public
        constructor Create(TheOwner: TComponent); override;
        destructor Destroy; override;
        procedure SetTargets(const aValue : TStringList);
     published
        property TheMessage : TxPLCustomMessage read fMessage write Set_Message;
        property ReadOnly : boolean write Set_ReadOnly;
     end;

implementation //==============================================================
uses Graphics
     , u_xpl_header
     , u_xpl_schema
     , u_xpl_application
     , u_xpl_gui_resource
     , uxPLConst
     ;

// TTMessageFrame =============================================================
constructor TTMessageFrame.Create(TheOwner: TComponent);
var i : integer;
begin
   inherited;

   fMessage := TxPLCustomMessage.Create(nil);

   for i := 0 to xPLApplication.VendorFile.Schemas.Count-1 do                  // Fill known schema list
       cbSchema.Items.Add(xPLApplication.VendorFile.Schemas[i].name);

   edtSource.Pattern := K_REGEXPR_ADDRESS;
   edtSource.ValidationType := vtExit;
   edtSource.FocusColor := clMoneyGreen;
   edtSource.ValidationColor := clGradientActiveCaption;

   cbTarget.Pattern := K_REGEXPR_TARGET;
   cbTarget.ValidationType := vtExit;
   cbTarget.FocusColor := clMoneyGreen;
   cbTarget.ValidationColor := clGradientActiveCaption;

   cbSchema.Pattern := K_REGEXPR_SCHEMA;
   cbSchema.ValidationType := vtExit;
   cbSchema.FocusColor := clMoneyGreen;
   cbSchema.ValidationColor := clGradientActiveCaption;

   edtBody.Pattern := K_RE_BODY_LINE;
   edtBody.ValidationType := vtExit;
//   edtBody.FocusColor := clMoneyGreen;
//   edtBody.ValidationColor := clGradientActiveCaption;

   cbMsgType.FocusColor := clMoneyGreen;
   cbMsgType.ValidationColor := clGradientActiveCaption;
end;

destructor TTMessageFrame.Destroy;
begin
   fMessage.Free;
   inherited Destroy;
end;

procedure TTMessageFrame.edtSourceEditingDone(Sender: TObject);
begin
   fMessage.source.RawxPL := edtSource.Caption;
   UpdateDisplay;
end;


procedure TTMessageFrame.cbTargetEditingDone(Sender: TObject);
begin
   fMessage.target.RawxPL := cbTarget.Text;
   UpdateDisplay;
end;

procedure TTMessageFrame.edtBodyEditingDone(Sender: TObject);
begin
   fMessage.Body.Strings := edtBody.Lines;
   UpdateDisplay;
end;

procedure TTMessageFrame.cbMsgTypeEditingDone(Sender: TObject);
begin
   fMessage.MsgTypeAsStr := cbMsgType.Text;
   UpdateDisplay;
end;

procedure TTMessageFrame.cbSchemaEditingDone(Sender: TObject);
begin
   fMessage.schema.RawxPL := cbSchema.Text;
   UpdateDisplay;
end;

procedure TTMessageFrame.UpdateDisplay;
begin
   try
      Image2.Picture.LoadFromLazarusResource(fMessage.MsgTypeAsStr);
      Image1.Visible := (lazarusResources.Find(fMessage.schema.Classe)<>nil);  // The ressource may not be present for the searched class of messages
      If Image1.Visible then Image1.Picture.LoadFromLazarusResource(fMessage.schema.Classe);
      SbMessage.Panels[3].Text  := IntToStr(fMessage.Size);
   except
   end;
end;

procedure TTMessageFrame.Set_Message(const AValue: TxPLCustomMessage);
begin
   fMessage.Assign(aValue);
   cbMsgType.Text := fMessage.MsgTypeAsStr;
   SbMessage.Panels[1].Text := IntToStr(fMessage.hop);
   SbMessage.Panels[5].Text := DateTimeToStr(fMessage.TimeStamp);
   edtSource.Caption := fMessage.Source.RawxPL;
   cbTarget.Caption := fMessage.Target.RawxPL;
   cbSchema.Text := fMessage.schema.RawxPL;
   edtBody.Lines.Assign(fMessage.Body.Strings);

   UpdateDisplay;
end;

procedure TTMessageFrame.Set_ReadOnly(const AValue: boolean);
begin
   edtBody.ReadOnly   := AValue;
   edtSource.ReadOnly := AValue;
   cbMsgType.ReadOnly := AValue;
   cbMsgType.Enabled  := not AValue;
end;

procedure TTMessageFrame.SetTargets(const aValue: TStringList);
begin
   cbTarget.Items.Assign(aValue);
end;

end.
