unit u_xml_xpldeterminator;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM;

type

  { TXMLparamType }

  TXMLparamType = class(TDOMElement)
  private
    function Get_name: AnsiString;
    function Get_operator: AnsiString;
    function Get_Value: AnsiString;
  public
     property name: AnsiString read Get_name;
     property operator_ : AnsiString read Get_operator;
     property value : AnsiString read Get_Value;
  end;

  { TXMLxplActionParamType }

  TXMLxplActionParamType = class(TDOMElement)
  private
    function Get_Expression: AnsiString;
  public
     property expression: AnsiString read Get_Expression;
  end;

  { TXMLParamsType }

  TXMLParamsType = class(TDOMElementList)
  protected
    function Get_ParamType(Index: Integer): TXMLparamType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property ParamType[Index: Integer]: TXMLparamType read Get_ParamType; default;
  end;

  { TXMLxplActionParamsType }

  TXMLxplActionParamsType = class(TDOMElementList)
  protected
    function Get_xplActionParamType(Index: Integer): TXMLxplActionParamType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property xplActionParamType[Index: Integer]: TXMLxplActionparamType read Get_xplActionParamType; default;
  end;

  { TXMLxplconditionType }

  TXMLxplconditionType = class(TDOMElement)
  private
    function Get_DisplayName: AnsiString;
    function Get_MsgType: AnsiString;
    function Get_Params: TXMLParamsType;
    function Get_SchemaClass: AnsiString;
    function Get_SchemaType: AnsiString;
    function Get_SourceDevice: AnsiString;
    function Get_SourceInstance: AnsiString;
    function Get_SourceVendor: AnsiString;
    function Get_TargetDevice: AnsiString;
    function Get_TargetInstance: AnsiString;
    function Get_TargetVendor: AnsiString;
  public
     property displayname : AnsiString read Get_DisplayName;
     property msg_type    : AnsiString read Get_MsgType;
     property SourceVendor: AnsiString read Get_SourceVendor;
     property SourceDevice: AnsiString read Get_SourceDevice;
     property SourceInstance: AnsiString read Get_SourceInstance;
     property TargetVendor: AnsiString read Get_TargetVendor;
     property TargetDevice: AnsiString read Get_TargetDevice;
     property TargetInstance: AnsiString read Get_TargetInstance;
     property Schema_Class: AnsiString read Get_SchemaClass;
     property Schema_Type: AnsiString read Get_SchemaType;
     property Params: TXMLParamsType read Get_Params;
  end;

  { TXMLxplActionType }

  TXMLxplActionType = class(TDOMElement)
  private
    function Get_DisplayName: AnsiString;
    function Get_ExecuteOrder: AnsiString;
    function Get_Msg_Schema: AnsiString;
    function Get_Msg_Target: AnsiString;
    function Get_Msg_Type: AnsiString;
    function Get_xplActionParams: TXMLxplActionParamsType;

  public
     property ExecuteOrder: AnsiString read Get_ExecuteOrder;
     property Display_Name: AnsiString read Get_DisplayName;
     property Msg_Type : AnsiString read Get_Msg_Type;
     property Msg_Target : AnsiString read Get_Msg_Target;
     property Msg_Schema : AnsiString read Get_Msg_Schema;
     property xplActions: TXMLxplActionParamsType read Get_xplActionParams;
  end;

  { TXMLConditionsType }

  TXMLConditionsType = class(TDOMElementList)
  protected
    function Get_ConditionType(Index: Integer): TXMLxplconditionType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property ConditionType[Index: Integer]: TXMLxplconditionType read Get_ConditionType; default;
  end;

  { TXMLActionsType }

  TXMLActionsType = class(TDOMElementList)
  protected
    function Get_ActionType(Index: Integer): TXMLxplActionType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property ActionType[Index: Integer]: TXMLxplActionType read Get_ActionType; default;
  end;

  { TXMLinput }

  TXMLinput = class(TDOMElement)
  private
    function Get_Match: AnsiString;
    function Get_xplconditions: TXMLConditionsType;
  public
    property match : AnsiString read Get_Match;
    property xplconditions: TXMLConditionsType read Get_xplconditions;
  end;

  { TXMLoutput }

  TXMLoutput = class(TDOMElement)
  private
    function Get_xplActions: TXMLActionsType;
  public
    property xplactions: TXMLActionsType read Get_xplActions;
  end;

  { TXMLdeterminatorType }

  TXMLdeterminatorType = class(TDOMElement)
  private
    function Get_description: AnsiString;
    function Get_groupname: AnsiString;
    function Get_Enabled: ansistring;
    function Get_IsGroup: ansistring;
    function Get_Name: AnsiString;
    function Get_output: TXMLoutput;
  protected
    function Get_input: TXMLinput;
  public
    property name_ : AnsiString read Get_Name;
    property description : AnsiString read Get_description;
    property groupname : AnsiString read Get_groupname;
    property isgroup : ansistring read Get_IsGroup;
    property enabled : ansistring read Get_Enabled;
    property input : TXMLinput read Get_input;
    property output : TXMLoutput read Get_output;
  end;

  TXMLxpldeterminatorType = class(TDOMElementList)
  protected
    function Get_determinator(Index: Integer): TXMLdeterminatorType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property determinator[Index: Integer]: TXMLdeterminatorType read Get_determinator; default;
  end;

var xpldeterminatorFile : TXMLxpldeterminatorType;

implementation //=========================================================================
uses XMLRead;
var Document : TXMLDocument;
//========================================================================================

// TXMLparamType ======================================================================
function TXMLparamType.Get_name: AnsiString;
begin Result := Attributes.GetNamedItem('name').NodeValue; end;

function TXMLparamType.Get_operator: AnsiString;
begin Result := Attributes.GetNamedItem('operator').NodeValue; end;

function TXMLparamType.Get_Value: AnsiString;
begin Result := Attributes.GetNamedItem('value').NodeValue; end;

// TXMLxplconditionType =======================================================================
function TXMLxplconditionType.Get_DisplayName: AnsiString;
begin Result := Attributes.GetNamedItem('display_name').NodeValue; end;

function TXMLxplconditionType.Get_MsgType: AnsiString;
begin Result := Attributes.GetNamedItem('msg_type').NodeValue; end;

function TXMLxplconditionType.Get_SchemaClass: AnsiString;
begin Result := Attributes.GetNamedItem('schema_class').NodeValue; end;

function TXMLxplconditionType.Get_SchemaType: AnsiString;
begin Result := Attributes.GetNamedItem('schema_type').NodeValue; end;

function TXMLxplconditionType.Get_SourceDevice: AnsiString;
begin Result := Attributes.GetNamedItem('source_device').NodeValue; end;

function TXMLxplconditionType.Get_SourceInstance: AnsiString;
begin Result := Attributes.GetNamedItem('source_instance').NodeValue; end;

function TXMLxplconditionType.Get_SourceVendor: AnsiString;
begin Result := Attributes.GetNamedItem('source_vendor').NodeValue; end;

function TXMLxplconditionType.Get_TargetDevice: AnsiString;
begin Result := Attributes.GetNamedItem('target_device').NodeValue; end;

function TXMLxplconditionType.Get_TargetInstance: AnsiString;
begin Result := Attributes.GetNamedItem('target_instance').NodeValue; end;

function TXMLxplconditionType.Get_TargetVendor: AnsiString;
begin Result := Attributes.GetNamedItem('target_vendor').NodeValue; end;

function TXMLxplconditionType.Get_Params: TXMLParamsType;
begin Result := TXMLParamsType.Create(self); end;

{ TXMLinput }


// TXMLdeterminatorType ===================================================================


// TXMLxpldeterminatorType =================================================================
function TXMLxpldeterminatorType.Get_determinator(Index: Integer ): TXMLdeterminatorType;
begin Result := TXMLdeterminatorType(Item[Index]); end;

constructor TXMLxpldeterminatorType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'determinator'); end;

// Unit initialization ===================================================================


{ TXMLParamsType }
function TXMLParamsType.Get_ParamType(Index: Integer): TXMLparamType;
begin Result := TXMLparamType(Item[Index]); end;

constructor TXMLParamsType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'param'); end;

{ TXMLConditionsType }

function TXMLConditionsType.Get_ConditionType(Index: Integer): TXMLxplconditionType;
begin Result := TXMLxplconditionType(Item[Index]); end;

constructor TXMLConditionsType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'xplCondition'); end;

{ TXMLActionsType }

function TXMLActionsType.Get_ActionType(Index: Integer): TXMLxplActionType;
begin Result := TXMLxplActionType(Item[Index]); end;

constructor TXMLActionsType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'xplAction'); end;


{ TXMLinput }

function TXMLinput.Get_Match: AnsiString;
begin Result := Attributes.GetNamedItem('match').NodeValue; end;

function TXMLinput.Get_xplconditions: TXMLConditionsType;
begin Result := TXMLConditionsType.Create(self); end;

{ TXMLoutput }

function TXMLoutput.Get_xplActions: TXMLActionsType;
begin Result := TXMLActionsType.Create(self); end;

{ TXMLdeterminatorType }

function TXMLdeterminatorType.Get_Description: AnsiString;
begin Result := Attributes.GetNamedItem('description').NodeValue; end;

function TXMLdeterminatorType.Get_groupname: AnsiString;
begin Result := Attributes.GetNamedItem('groupName').NodeValue; end;

function TXMLdeterminatorType.Get_Enabled: ansistring;
begin Result := Attributes.GetNamedItem('enabled').NodeValue; end;

function TXMLdeterminatorType.Get_IsGroup: ansistring;
begin Result := Attributes.GetNamedItem('IsGroup').NodeValue; end;

function TXMLdeterminatorType.Get_Name: AnsiString;
begin Result := Attributes.GetNamedItem('name').NodeValue; end;

function TXMLdeterminatorType.Get_output: TXMLoutput;
begin Result := TXMLoutput(FindNode('output')); end;

function TXMLdeterminatorType.Get_input: TXMLinput;
begin Result := TXMLInput(FindNode('input')); end;

{ TXMLxplActionParamType }

function TXMLxplActionParamType.Get_Expression: AnsiString;
begin Result := Attributes.GetNamedItem('expression').NodeValue; end;

{ TXMLxplActionParamsType }

function TXMLxplActionParamsType.Get_xplActionParamType(Index: Integer): TXMLxplActionParamType;
begin Result := TXMLxplActionParamType(Item[Index]); end;

constructor TXMLxplActionParamsType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'xplActionParam'); end;

{ TXMLxplActionType }

function TXMLxplActionType.Get_DisplayName: AnsiString;
begin Result := Attributes.GetNamedItem('display_name').NodeValue; end;

function TXMLxplActionType.Get_ExecuteOrder: AnsiString;
begin Result := Attributes.GetNamedItem('executeOrder').NodeValue; end;

function TXMLxplActionType.Get_Msg_Schema: AnsiString;
begin Result := Attributes.GetNamedItem('msg_schema').NodeValue; end;

function TXMLxplActionType.Get_Msg_Target: AnsiString;
begin Result := Attributes.GetNamedItem('msg_target').NodeValue; end;

function TXMLxplActionType.Get_Msg_Type: AnsiString;
begin Result := Attributes.GetNamedItem('msg_type').NodeValue; end;

function TXMLxplActionType.Get_xplActionParams: TXMLxplActionParamsType;
begin Result := TXMLxplActionParamsType.Create(self); end;



initialization
   Document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\determinator\36aaa3adcf324675b6104c2590866a57.xml');
   xpldeterminatorFile := TXMLxpldeterminatorType.Create(Document.FirstChild);

finalization
   xpldeterminatorFile.destroy;
   Document.destroy;

end.


