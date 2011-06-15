unit FileName;
interface
uses
  SysUtils, PropEdits, Controls, Classes, u_xpl_globals;

Type
  TFileNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  { TGlobalVariableProperty }

  TGlobalVariableProperty = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  { TxPLMessageProperty }

  TxPLMessageProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  procedure Register;

implementation
uses
  Dialogs
  , Forms
  , u_xpl_actionlist
  , u_xpl_message_gui;

  { TxPLMessageProperty }

  function TxPLMessageProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog] ;
end;


  { TGlobalVariableProperty }
  procedure TGlobalVariableProperty.GetValues(Proc: TGetStrProc);
var I: Longint;
    action : TxPLAction_SetGlobal;
begin
  action := TxPLAction_SetGlobal(GetComponent(0));
  for i:=0 to action.GlobalList.Count-1 do Proc(action.GlobalList[i]);
end;

  function TGlobalVariableProperty.GetAttributes: TPropertyAttributes;
begin
 Result := [paValueList, paSortList];
end;

  function TFileNameProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paDialog]
  end {GetAttributes};

  procedure TFileNameProperty.Edit;
  begin
    with TOpenDialog.Create(Application) do
    try
      Title := GetName; { name of property as OpenDialog caption }
      Filename := GetValue;
      Filter := 'All Files (*.*)|*.*';
      HelpContext := 0;
      Options := Options + [ofShowHelp, ofPathMustExist, ofFileMustExist];
      if Execute then SetValue(Filename);
    finally
      Free
    end
  end {Edit};

procedure TxPLMessageProperty.Edit;
var //action : TxPLAction_Send;
    message : TxPLMessageGUI;
begin
//   action  := TxPLAction_Send(GetComponent(0));
   message := TxPLMessageGUI.Create(nil,getvalue);
   message.ShowForEdit([boLoad,boSave,boCopy,boOk],true,false);
   SetValue(message.RawxPL);
//   action.Message:=message.RawXPL;
 //  message.Free;
end;

  procedure Register;
  begin
    RegisterPropertyEditor(TypeInfo(TFileName),TxPLAction_Execute, 'FileName', TFileNameProperty);
    RegisterPropertyEditor(TypeInfo(TGlobalVariableName),TxPLAction_SetGlobal,'GlobalName',TGlobalVariableProperty);
    RegisterPropertyEditor(TypeInfo(TFileName),TxPLAction_Send,'Msg', TxPLMessageProperty);
  end;
end.

