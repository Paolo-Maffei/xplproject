unit frm_xplactionlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, u_xml_xpldeterminator,DOM;

type

  { TfrmActionList }

  TfrmActionList = class(TForm)
    lbMessages: TListBox;
    tbLaunch: TToolButton;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    tbAdd: TToolButton;
    tbDel: TToolButton;
    tbEdit: TToolButton;
    UpDown1: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
  private
    { private declarations }
    function GetSelected : integer;
  public
    { public declarations }
    event   : TDOMElement;
    actions : TXMLActionsType;
  end; 

var
  frmActionList: TfrmActionList;

implementation
uses Frm_About,
     u_xml,
     uxPLMessage,
     uxPLConst,
     u_xpl_message_gui;
{ TfrmActionList }

procedure TfrmActionList.FormShow(Sender: TObject);
var i,j : integer;
begin
     actions := TXMLActionsType.Create(event,'action',K_XML_STR_Display_name);
     actions.AddElement('test');
     actions.AddElement('chose');

   ToolBar3.Images := frmAbout.ilStandardActions;
   for i := 0 To Actions.Count-1 do begin
      j := lbMessages.Items.Add(Actions[i].Display_Name);
      lbMessages.Items.Objects[i] := Actions[i];
   end;
end;

procedure TfrmActionList.FormCreate(Sender: TObject);
begin
end;

procedure TfrmActionList.tbAddClick(Sender: TObject);
var s : string;
    i    : integer;
begin
     s := 'new message';
     repeat
           s += '1';
           i := lbMessages.Items.IndexOf(s);
     until i= -1;
     i := lbMessages.Items.Add(s);
     lbMessages.Items.Objects[i] := actions.AddElement(s);

end;

procedure TfrmActionList.tbDelClick(Sender: TObject);
var i : integer;
begin
     i := GetSelected;
     if i=-1 then exit;

     lbMessages.Items.Delete(i);
end;

procedure TfrmActionList.tbEditClick(Sender: TObject);
var i : integer;
    aMsg : TxPLMessage;
begin
     i:=GetSelected;
     if i=-1 then exit;
     aMsg :=  TxPLMessage.Create;
     aMsg.Source.Tag := 'me-me.me';
     aMsg.Target.IsGeneric:=true;
     aMsg.MessageType:=K_MSG_TYPE_CMND;
     aMsg.Schema.Tag := 'class.type';
     aMsg.ReadFromXML( TXMLxplActionType(lbMessages.Items.Objects[i]) );
     TxPLMessageGUI(aMsg).ShowForEdit([boSave, boSend]);
end;

procedure TfrmActionList.tbLaunchClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmActionList.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var i,target : integer;
    s : string;
begin
     i := GetSelected;
     s := lbMessages.Items[i];
     target := -1;
     case Button of
          BtPrev : if i<=lbMessages.Items.Count-2 then target := i+1;
          BtNext : if i>=1                        then target := i-1;
     end;
     if target<>-1 then begin
        lbMessages.Items[i] := lbMessages.Items[target];
        lbMessages.Items[target] := s;
        lbMessages.Selected[target] := True;
     end;

end;

function TfrmActionList.GetSelected: integer;
begin
     result := -1;
     if lbMessages.SelCount = 0 then exit;
     result := 0;
     repeat
           if lbMessages.Selected[result] then exit;
           inc(result);
     until result = lbMessages.Items.Count;
     result := -1;
end;

initialization
  {$I frm_xplactionlist.lrs}

end.

