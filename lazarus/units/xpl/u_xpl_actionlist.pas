unit u_xpl_actionlist;

{$mode objfpc} {$M+}{$H+}

interface

uses
  Classes
  , SysUtils
  , u_xpl_collection
  , u_xpl_globals
  ;

type

      { TxPLAction }
  TxPLAction = class(TComponent)
  public
    constructor Create(aOwner : TComponent); override;
  published
  end;

  TxPLAction_Wait = class(TxPLAction)
  private
    fSnooze : integer;
  published
    property Delay : integer read fSnooze write fSnooze default 10;
  end;

  { TxPLAction_Send }

  TxPLAction_Send = class(TxPLAction)
  private
    fMessage : string;
  public
  published
    property Msg : string read fMessage write fMessage;
  end;

  TxPLAction_Execute = class(TxPLAction)
  private
    fFileName : TFileName;
    fParams   : string;
  published
    property FileName : TFileName read fFileName write fFileName;
    property Parameters : string  read fParams   write fParams;
  end;

  { TxPLAction_SetGlobal }

  TxPLAction_SetGlobal = class(TxPLAction)
  private
    fGlobalName : TGlobalVariableName;
    fValue      : string;
  public
    GlobalList  : TStringList;
    constructor Create(aOwner : TComponent; aGlobalList : TxPLGlobals);
    destructor  Destroy; override;
  published
    property GlobalName : TGlobalVariableName read fGlobalName write fGlobalName;
    property Value      : string read fValue      write fValue;
  end;

  { TxPLActionList }

  TxPLActionList = class(TComponent)
  public
     procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
     function GetChildOwner:TComponent; override;
     procedure OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
  end;

  { TxPLActionCollectionItem }

  TxPLActionCollectionItem = class(TxPLCollectionItem)
       private
         fActions : TxPLActionList;
         procedure Set_Actions(const AValue: TxPLActionList);
       public
          constructor Create(aCollection: TCollection); override;
          destructor  Destroy; override;
          procedure DefineProperties(Filer: TFiler); override;
          procedure ReadActions(Reader: TReader);
          procedure WriteActions(Writer: TWriter);
       published
          property Actions : TxPLActionList read fActions write Set_Actions;
       end;

  { TxPLFormulas }
      TxPLActions = specialize TxPLCollection<TxPLActionCollectionItem>;

implementation
uses LResources
     , u_xpl_schema
     ;

{ TxPLAction_Send }

//constructor TxPLAction_Send.Create(aOwner: TComponent);
//begin
//  inherited Create(aOwner);
////  fMessage := TxPLMessage.Create(self);
////  fMessage.Schema.Assign(Schema_ControlBasic);
////  fMessage.Target.IsGeneric := true;
////  InsertComponent(fMessage);
//end;

//procedure TxPLAction_Send.Assign(aMessage: TPersistent);
//begin
//  if aMessage is TxPLAction_Send then begin
////     fMessage.Assign(TxPLAction_Send(aMessage));
//  end else inherited;
//end;

{ TxPLAction_SetGlobal }

constructor TxPLAction_SetGlobal.Create(aOwner : TComponent; aGlobalList : TxPLGlobals);
var ci : TCollectionItem;
begin
  inherited Create(aOwner);
  GlobalList := TStringList.Create;
  for ci in aGlobalList do
      GlobalList.Add(TxPLGlobalValue(ci).DisplayName);
end;

destructor TxPLAction_SetGlobal.Destroy;
begin
  GlobalList.Free;
  inherited Destroy;
end;

{ TxPLActionCollectionItem }

procedure TxPLActionCollectionItem.Set_Actions(const AValue: TxPLActionList);
begin
  fActions.Assign(AValue);
end;

constructor TxPLActionCollectionItem.Create(aCollection: TCollection);
begin
  inherited Create(aCollection);
  fActions := TxPLActionList.Create(nil);
end;

destructor TxPLActionCollectionItem.Destroy;
begin
  fActions.Free;
  inherited Destroy;
end;

procedure TxPLActionCollectionItem.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('ActionList',@ReadActions,@WriteActions,true);
end;

procedure TxPLActionCollectionItem.ReadActions(Reader: TReader);
var aStream : TStringStream;
begin
   with Reader do begin
        ReadListBegin;
        aStream := TStringStream.Create(ReadString);
        ReadComponentFromTextStream(aStream, TComponent(fActions), @fActions.OnFindClass );
        AStream.Free;
        ReadListEnd;
   end;
end;

procedure TxPLActionCollectionItem.WriteActions(Writer: TWriter);
var aStream : TStringStream;
begin
   with Writer do begin
        WriteListBegin;
        aStream:=TStringStream.Create('');
        WriteComponentAsTextToStream(aStream, fActions);
        WriteString(aStream.DataString);
        AStream.Free;
        WriteListEnd;
   end;
end;

{ TxPLAction }


{ TxPLActionList ===============================================================}

{ TxPLActionList }
procedure TxPLActionList.GetChildren(Proc: TGetChildProc; Root: TComponent);  // this is copied
var                                                                  // from
  I: Integer;                                                        // TCustomForm
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

procedure TxPLActionList.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
  if CompareText(AClassName, 'TxPLAction_Wait') = 0 then ComponentClass := TxPLAction_Wait
  else if CompareText(AClassName, 'TxPLAction_Send') = 0 then ComponentClass := TxPLAction_Send
  else if CompareText(aClassName, 'TxPLActionList') = 0 then ComponentClass := TxPLActionList
  else if CompareText(aClassName, 'TxPLAction_Execute') = 0 then ComponentClass := TxPLAction_Execute
  else if CompareText(aClassName, 'TxPLAction_SetGlobal') = 0 then ComponentClass := TxPLAction_SetGlobal;
end;

function TxPLActionList.GetChildOwner: TComponent;
begin
  inherited;
  Result:=Self;
  SetSubComponent(true);
end;

{ TxPLAction }

constructor TxPLAction.Create(aOwner: TComponent);
begin
   inherited;
   SetSubComponent(true);
end;

initialization
   RegisterClass(TxPLAction);
   RegisterClass(TxPLAction_Wait);
   RegisterClass(TxPLAction_Send);
   RegisterClass(TxPLAction_Execute);
   RegisterClass(TxPLAction_SetGlobal);
   RegisterClass(TxPLActionList);

end.

