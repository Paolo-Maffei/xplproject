unit frame_Filter;

{$mode objfpc}
{$r *.lfm}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, StdCtrls, ExtCtrls,
  RTTICtrls, KGrids, u_xpl_filter_Message;

type

  { TTFilterFrame }

  TTFilterFrame = class(TFrame)
    edtBody: TTIMemo;
    edtSchema: TTIEdit;
    edtSource: TTIEdit;
    edtTarget: TTIEdit;
    Label10: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    cbMsgType: TTIComboBox;
    procedure edtBodyEditingDone(Sender: TObject);
  private
    fFilter : TxPLFilterMessage;
    procedure Set_Filter(const AValue: TxPLFilterMessage);
  public
    constructor Create(TheOwner: TComponent); override;

  published
    property TheFilter : TxPLFilterMessage read fFilter write Set_Filter;
  end; 

implementation //==============================================================
uses u_xpl_header
     , typinfo
     ;

// TTFilterFrame =============================================================
procedure TTFilterFrame.edtBodyEditingDone(Sender: TObject);
begin
  fFilter.Body.Strings := TStringList(edtBody.Lines);
end;

procedure TTFilterFrame.Set_Filter(const AValue: TxPLFilterMessage);
begin
   fFilter := aValue;
   cbMsgType.Link.TIObject := AValue;
   edtSource.Link.TIObject := AValue.Source;
   edtTarget.Link.TIObject := AValue.Target;
   edtSchema.Link.TIObject := AValue.Schema;
   edtBody.Link.TIObject   := AValue.Body;
   cbMsgType.Link.TIObject := AValue;
end;

constructor TTFilterFrame.Create(TheOwner: TComponent);

begin
   inherited Create(TheOwner);
   edtSource.Link.TIPropertyName := 'rawxpl';
   cbMsgType.Link.TIPropertyName := 'MessageType';
   edtTarget.Link.TIPropertyName := 'rawxpl';
   edtSchema.Link.TIPropertyName := 'rawxpl';
   edtBody.Link.TIPropertyName   := 'Strings';
end;

initialization //==============================================================

end.
