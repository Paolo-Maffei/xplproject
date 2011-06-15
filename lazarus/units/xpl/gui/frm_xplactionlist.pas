unit frm_xplactionlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, Menus, ActnList,  RTTICtrls, RTTIGrids,
  u_xpl_actionlist, opc_listener
  ;

type

  { TfrmActionList }

  TfrmActionList = class(TForm)
    acCancel: TAction;
    acOk: TAction;
    ActionList: TActionList;
    BitBtn1: TBitBtn;
    edtName: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    lbMessages: TListBox;
    mnSetGlobal: TMenuItem;
    mnuExecute: TMenuItem;
    mnuAddMsg: TMenuItem;
    mnuPause: TMenuItem;
    Panel2: TPanel;
    popAddAction: TPopupMenu;
    tbDel1: TToolButton;
    tbEdit1: TToolButton;
    tbFunctions: TToolButton;
    tbLaunch1: TToolButton;
    tbVariables: TToolButton;
    TIPropertyGrid2: TTIPropertyGrid;
    ToolBar: TToolBar;
    ToolBar4: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton8: TToolButton;
    UpDown1: TUpDown;
    procedure acCancelExecute(Sender: TObject);
    procedure acOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbMessagesClick(Sender: TObject);
    procedure mnSetGlobalClick(Sender: TObject);
    procedure mnuAddMsgClick(Sender: TObject);
    procedure mnuExecuteClick(Sender: TObject);
    procedure mnuPauseClick(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure tbLaunchClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
  private
    { private declarations }
    Listener : TOpcListener;
    fActionList : TxPLActionCollectionItem;
    function GetSelected : integer;

  public
    { public declarations }

  end;

  procedure ShowFrmActionList(const aListener : TOpcListener; const aActionList : TxPLActionCollectionItem);

implementation // ==============================================================
uses u_xpl_gui_resource
     , uxPLConst
     , JvScheduledEvents
     ;

var frmActionList: TfrmActionList;

// =============================================================================
procedure ShowFrmActionList(const aListener : TOpcListener; const aActionList : TxPLActionCollectionItem);
begin
   if not Assigned(frmActionList) then
      Application.CreateForm(TfrmActionList, frmActionList);
   FrmActionList.Listener := aListener;
   FrmActionList.fActionList := aActionList;
   FrmActionList.ShowModal;
end;


{ TfrmActionList =============================================================}
procedure TfrmActionList.FormShow(Sender: TObject);
var i,j : integer;
begin
   lbMessages.Items.Clear;
   ToolBar.Images := xPLGUIResource.Images;
   ToolBar.Images := xPLGUIResource.Images;
   for i:=0 to fActionList.Actions.ComponentCount-1 do begin
      j := lbMessages.Items.Add( TxPLAction(fActionList.Actions.Components[i]).Name);
      lbMessages.Items.Objects[j] := fActionList.Actions.Components[i];
   end;
   edtName.Text       := fActionList.DisplayName;

(*   TIPropertyGrid1.TIObject := fActions.Schedule; //TJVEventCollectionItem(fActions.Data);
   TIEdit1.Link.TIObject := TJVEventCollectionItem(fActions.Data);
   TIEdit1.Link.TIPropertyName:= 'Name';*)
end;

procedure TfrmActionList.lbMessagesClick(Sender: TObject);
var i : integer;
    s : string;
begin
   i := GetSelected;
   if i= -1 then exit;
   s := lbMessages.Items[i];
   TIPropertyGrid2.TIObject := fActionList.Actions.FindComponent(s);
end;

procedure TfrmActionList.mnSetGlobalClick(Sender: TObject);
var aAction : TxPLAction_SetGlobal;
begin
   aAction := TxPLAction_SetGlobal.Create(nil, Listener.Globals);
   aAction.Name:=aAction.ClassName+ IntToStr(fActionList.Actions.ComponentCount);
   fActionList.Actions.InsertComponent(aAction);
   lbMessages.Items.Add(aAction.Name);
end;

procedure TfrmActionList.mnuAddMsgClick(Sender: TObject);
var aAction : TxPLAction_Send;
begin
   aAction := TxPLAction_Send.Create(fActionList.Actions);
   aAction.Name:=aAction.ClassName+ IntToStr(fActionList.Actions.ComponentCount);

//   fActionList.Actions.InsertComponent(aAction);
   lbMessages.Items.Add(aAction.Name);
end;

procedure TfrmActionList.mnuExecuteClick(Sender: TObject);
var aAction : TxPLAction_Execute;
begin
   aAction := TxPLAction_Execute.Create(nil);
   aAction.Name := aAction.ClassName + IntToStr(fActionList.Actions.ComponentCount);
   fActionList.Actions.InsertComponent(aAction);
   lbMessages.Items.Add(aAction.Name);
end;

procedure TfrmActionList.mnuPauseClick(Sender: TObject);
var aAction : TxPLAction_Wait;
begin
   aAction := TxPLAction_Wait.Create(nil);
   aAction.Name:=aAction.ClassName+IntToStr(fActionList.Actions.ComponentCount);
   fActionList.Actions.InsertComponent(aAction);
//   aAction := fEvent.Actions.InsertComponent(a);
//   aAction.Category:=xAT_MsgSend;
//   aAction := TxPLActionSendMsg.Create(nil);
//   fEvent.Actions.InsertAction(aAction);
   lbMessages.Items.Add(aAction.Name);
end;

procedure TfrmActionList.acOkExecute(Sender: TObject);
begin
   fActionList.DisplayName := edtName.Text;
   Close;
   ModalResult := mrOk;
end;

procedure TfrmActionList.acCancelExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmActionList.FormCreate(Sender: TObject);
begin
   Toolbar.Images := xPLGUIResource.Images;
end;

procedure TfrmActionList.tbDelClick(Sender: TObject);
var i,j : integer;
    s : string;
begin
     i := GetSelected;
     if i=-1 then exit;

     s := lbMessages.Items[i];
//     j := fActions.GetItemId(s);

//     if j=-1 then exit;
//     fActions.Delete(j);
//     lbMessages.Items.Delete(i);
end;

procedure TfrmActionList.tbEditClick(Sender: TObject);
var i : integer;
//    aMsg : TxPLMessage;
begin
     i:=GetSelected;
     if i=-1 then exit;
(*     aMsg :=  TxPLMessage.Create;
     aMsg.ReadFromXML( TXMLxplActionType(lbMessages.Items.Objects[i]) );
     TxPLMessageGUI(aMsg).ShowForEdit([boLoad],true);
     aMsg.WriteToXML( TXMLxplActionType(lbMessages.Items.Objects[i]) );
     lbMessages.Items[i] := aMsg.Name;
     aMsg.Destroy;*)
end;

procedure TfrmActionList.tbLaunchClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmActionList.ToolButton1Click(Sender: TObject);
begin
   popAddAction.PopUp;
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

