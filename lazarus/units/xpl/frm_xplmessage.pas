unit frm_xPLMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  StdCtrls, ExtCtrls, EditBtn, Grids, Menus, ActnList, ComCtrls, Buttons, uxPLMessage,
  KHexEditor, XMLPropStorage, v_xplmsg_opendialog;

type

  { TfrmxPLMessage }
  TfrmxPLMessage = class(TForm)
    acLoad: TAction;
    DoSend: TAction;
    ActionList2: TActionList;
    edtName: TEdit;
    edtSource: TEdit;
    edtFilter: TEdit;
    ImageList1: TImageList;
    KHexEditor1: TKHexEditor;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    mmoMessage: TMemo;
    MsgCopy: TAction;
    MsgSave: TAction;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    XMLPropStorage1: TXMLPropStorage;
    SaveMessage: TxPLMsgSaveDialog;
    OpenMessage: TxPLMsgOpenDialog;

    procedure acLoadExecute(Sender: TObject);
    procedure DoSendExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure mmoMessageExit(Sender: TObject);
    procedure MsgCopyExecute(Sender: TObject);
    procedure MsgSaveExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    Stream     : TStringStream;
    xPLMessage : TxPLMessage;
    procedure DisplayMessage;
  public
    buttonOptions : TButtonOptions;
  end;

implementation // TFrmxPLMessage ===============================================================
uses clipbrd, LCLType, uxplmsgheader, cStrings, cUtils;
{ TfrmxPLMessage }

procedure TfrmxPLMessage.FormCreate(Sender: TObject);
begin
  Stream     := TStringStream.Create('');
end;

procedure TfrmxPLMessage.DoSendExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
  xPLMessage.Send;
end;

procedure TfrmxPLMessage.acLoadExecute(Sender: TObject);
begin
  if not OpenMessage.Execute then exit;

  xPLMessage.LoadFromFile(OpenMessage.FileName);
  DisplayMessage;

end;

procedure TfrmxPLMessage.FormDestroy(Sender: TObject);
begin
  Stream.Destroy;
end;

procedure TFrmxPLMessage.DisplayMessage;
var j : integer;
    arrStr : StringArray;
begin
   mmoMessage.Lines.Clear;
   arrStr := StrSplit(xPLMessage.RawXPL,#10);

   for j:=0 to high(arrStr) do
       if arrStr[j]<>'' then mmoMessage.Lines.Add(arrStr[j]);

   Stream.Position := 0;
   Stream.WriteString(xPLMessage.RawXPL);
   Stream.Position := 0;
   KHexEditor1.LoadFromStream(Stream);

   edtFilter.Text := xPLMessage.FilterTag;
   edtSource.Text := xPLMessage.Source.Tag;
   edtName.Text   := xPLMessage.Name;
end;

procedure TfrmxPLMessage.FormShow(Sender: TObject);
begin
   xPLMessage := TxPLMessage(Owner);
   acLoad.Visible  := (boLoad in buttonOptions);
   MsgSave.Visible := (boSave in buttonOptions);
   MsgCopy.Visible := (boCopy in buttonOptions);
   DoSend.Visible  := (boSend in buttonOptions);
   DisplayMessage;
end;

procedure TfrmxPLMessage.mmoMessageExit(Sender: TObject);
var s : string;
    j : integer;
begin
   if not mmoMessage.Modified then exit;

   s:= '';

   for j:=0 to mmoMessage.Lines.Count-1 do
       s += (mmoMessage.Lines[j] + #10);

   xPLMessage.RawxPL := s;
   DisplayMessage;
end;

procedure TfrmxPLMessage.MsgCopyExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := TxPLMessage(Owner).RawxPL;
end;

procedure TfrmxPLMessage.MsgSaveExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   if SaveMessage.Execute then xPLMessage.SaveToFile(SaveMessage.FileName);
end;

procedure TfrmxPLMessage.PageControl1Change(Sender: TObject);
begin
   mmoMessageExit(sender);
end;

initialization
  {$I frm_xplmessage.lrs}

end.


