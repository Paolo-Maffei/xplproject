unit u_xml_xpldeterminator;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, u_xml;

type

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
    procedure Set_Expression(const AValue: AnsiString);
  public
     property expression: AnsiString read Get_Expression write Set_Expression;
  end;

  TXMLParamsType = specialize TXMLElementList<TXMLParamType>;

  TXMLxplActionParamsType = specialize TXMLElementList<TXMLxplActionParamType>;

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
    function Get_Msg_Source: AnsiString;
    function Get_Msg_Target: AnsiString;
    function Get_Msg_Type: AnsiString;
    function Get_xplActionParams: TXMLxplActionParamsType;
    procedure Set_Display_Name(const AValue: AnsiString);
    procedure Set_ExecuteOrder(const AValue: AnsiString);
    procedure Set_Msg_Schema(const AValue: AnsiString);
    procedure Set_Msg_Source(const AValue: AnsiString);
    procedure Set_Msg_Target(const AValue: AnsiString);
    procedure Set_Msg_Type(const AValue: AnsiString);

  public
     property ExecuteOrder: AnsiString read Get_ExecuteOrder write Set_ExecuteOrder;
     property Display_Name: AnsiString read Get_DisplayName write Set_Display_Name;
     property Msg_Type : AnsiString read Get_Msg_Type write Set_Msg_Type;
     property Msg_Target : AnsiString read Get_Msg_Target write Set_Msg_Target;
     property Msg_Source : AnsiString read Get_Msg_Source write Set_Msg_Source;
     property Msg_Schema : AnsiString read Get_Msg_Schema write Set_Msg_Schema;
     property xplActions: TXMLxplActionParamsType read Get_xplActionParams;
  end;

  TXMLConditionsType = specialize TXMLElementList<TXMLxplconditionType>;
  TXMLActionsType = specialize TXMLElementList<TXMLxplActionType>;

  TXMLinput = class(TDOMElement)
  private
    function Get_Match: AnsiString;
    function Get_xplconditions: TXMLConditionsType;
  public
    property match : AnsiString read Get_Match;
    property xplconditions: TXMLConditionsType read Get_xplconditions;
  end;

  TXMLoutput = class(TDOMElement)
  private
    function Get_xplActions: TXMLActionsType;
  public
    property xplactions: TXMLActionsType read Get_xplActions;
  end;

  TXMLdeterminatorType = class(TDOMElement)
  private
    function Get_description: AnsiString;
    function Get_groupname: AnsiString;
    function Get_EnabledAsBoolean: boolean;
    function Get_EnabledAsString: string;
    function Get_IsGroup: boolean;
    function Get_Name: AnsiString;
    function Get_output: TXMLoutput;
  protected
    function Get_input: TXMLinput;
  public
    property name_ : AnsiString read Get_Name;
    property description : AnsiString read Get_description;
    property groupname : AnsiString read Get_groupname;
    property isgroup : boolean read Get_IsGroup;
    property enabledAsBoolean : boolean read Get_EnabledAsBoolean;
    property enabledAsString : string read Get_EnabledAsString;
    property input : TXMLinput read Get_input;
    property output : TXMLoutput read Get_output;
  end;

  TXMLxpldeterminatorsFile = specialize TXMLElementList<TXMLdeterminatorType>;

implementation //=========================================================================

// TXMLparamType ======================================================================
function TXMLparamType.Get_name: AnsiString;
begin Result := GetAttribute(K_XML_STR_Name); end;

function TXMLparamType.Get_operator: AnsiString;
begin Result := GetAttribute(K_XML_STR_Operator); end;

function TXMLparamType.Get_Value: AnsiString;
begin Result := GetAttribute(K_XML_STR_Value); end;

// TXMLxplconditionType =======================================================================
function TXMLxplconditionType.Get_DisplayName: AnsiString;
begin Result := GetAttribute(K_XML_STR_Display_name); end;

function TXMLxplconditionType.Get_MsgType: AnsiString;
begin Result := GetAttribute(K_XML_STR_Msg_type); end;

function TXMLxplconditionType.Get_SchemaClass: AnsiString;
begin Result := GetAttribute(K_XML_STR_Schema_class); end;

function TXMLxplconditionType.Get_SchemaType: AnsiString;
begin Result := GetAttribute(K_XML_STR_Schema_type); end;

function TXMLxplconditionType.Get_SourceDevice: AnsiString;
begin Result := GetAttribute(K_XML_STR_Source_devic); end;

function TXMLxplconditionType.Get_SourceInstance: AnsiString;
begin Result := GetAttribute(K_XML_STR_Source_insta); end;

function TXMLxplconditionType.Get_SourceVendor: AnsiString;
begin Result := GetAttribute(K_XML_STR_Source_vendo); end;

function TXMLxplconditionType.Get_TargetDevice: AnsiString;
begin Result := GetAttribute(K_XML_STR_Target_devic); end;

function TXMLxplconditionType.Get_TargetInstance: AnsiString;
begin Result := GetAttribute(K_XML_STR_Target_insta); end;

function TXMLxplconditionType.Get_TargetVendor: AnsiString;
begin Result := GetAttribute(K_XML_STR_Target_vendo); end;

function TXMLxplconditionType.Get_Params: TXMLParamsType;
begin Result := TXMLParamsType.Create(self, K_XML_STR_Param); end;

{ TXMLinput }
function TXMLinput.Get_Match: AnsiString;
begin Result := GetAttribute(K_XML_STR_Match); end;

function TXMLinput.Get_xplconditions: TXMLConditionsType;
begin Result := TXMLConditionsType.Create(self, K_XML_STR_XplCondition); end;

{ TXMLoutput }
function TXMLoutput.Get_xplActions: TXMLActionsType;
begin Result := TXMLActionsType.Create(self, K_XML_STR_XplAction); end;

{ TXMLdeterminatorType }
function TXMLdeterminatorType.Get_Description: AnsiString;
begin Result := GetAttribute(K_XML_STR_Description); end;

function TXMLdeterminatorType.Get_groupname: AnsiString;
begin Result := GetAttribute(K_XML_STR_GroupName); end;

function TXMLdeterminatorType.Get_EnabledAsString : String;
begin Result := GetAttribute(K_XML_STR_Enabled); end;

function TXMLdeterminatorType.Get_EnabledAsBoolean: boolean;
begin Result := (EnabledAsString = 'Y'); end;

function TXMLdeterminatorType.Get_IsGroup: boolean;
begin Result := (GetAttribute(K_XML_STR_IsGroup) = 'Y'); end;

function TXMLdeterminatorType.Get_Name: AnsiString;
begin Result := GetAttribute(K_XML_STR_Name); end;

function TXMLdeterminatorType.Get_output: TXMLoutput;
begin Result := TXMLoutput(FindNode(K_XML_STR_Output)); end;

function TXMLdeterminatorType.Get_input: TXMLinput;
begin Result := TXMLInput(FindNode(K_XML_STR_Input)); end;

{ TXMLxplActionParamType }
function TXMLxplActionParamType.Get_Expression: AnsiString;
begin Result := GetAttribute(K_XML_STR_EXPRESSION); end;

procedure TXMLxplActionParamType.Set_Expression(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_EXPRESSION, aValue); end;

{ TXMLxplActionType }
function TXMLxplActionType.Get_DisplayName: AnsiString;
begin Result := GetAttribute(K_XML_STR_Display_name); end;

function TXMLxplActionType.Get_ExecuteOrder: AnsiString;
begin Result := GetAttribute(K_XML_STR_ExecuteOrder); end;

function TXMLxplActionType.Get_Msg_Schema: AnsiString;
begin Result := GetAttribute(K_XML_STR_Msg_schema); end;

function TXMLxplActionType.Get_Msg_Source: AnsiString;
begin Result := GetAttribute(K_XML_STR_Msg_Source); end;

function TXMLxplActionType.Get_Msg_Target: AnsiString;
begin Result := GetAttribute(K_XML_STR_Msg_target); end;

function TXMLxplActionType.Get_Msg_Type: AnsiString;
begin Result := GetAttribute(K_XML_STR_Msg_type); end;

function TXMLxplActionType.Get_xplActionParams: TXMLxplActionParamsType;
begin Result := TXMLxplActionParamsType.Create(self, K_XML_STR_XplActionPar); end;

procedure TXMLxplActionType.Set_Display_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Display_name,aValue); end;

procedure TXMLxplActionType.Set_ExecuteOrder(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_ExecuteOrder,aValue); end;

procedure TXMLxplActionType.Set_Msg_Schema(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_MSG_SCHEMA,aValue); end;

procedure TXMLxplActionType.Set_Msg_Source(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Msg_Source,aValue); end;

procedure TXMLxplActionType.Set_Msg_Target(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Msg_target,aValue); end;

procedure TXMLxplActionType.Set_Msg_Type(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Msg_type,aValue); end;

end.


