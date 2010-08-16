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

  TXMLxplActionParamType = class(TDOMElement)
  private
    function Get_Expression: AnsiString;
  public
     property expression: AnsiString read Get_Expression;
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

  TXMLxpldeterminatorsType = specialize TXMLElementList<TXMLdeterminatorType>;

var xpldeterminatorFile : TXMLxpldeterminatorsType;

implementation //=========================================================================
uses XMLRead;
var Document : TXMLDocument;
//========================================================================================

// TXMLparamType ======================================================================
function TXMLparamType.Get_name: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLparamType.Get_operator: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Operator).NodeValue; end;

function TXMLparamType.Get_Value: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Value).NodeValue; end;

// TXMLxplconditionType =======================================================================
function TXMLxplconditionType.Get_DisplayName: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Display_name).NodeValue; end;

function TXMLxplconditionType.Get_MsgType: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Msg_type).NodeValue; end;

function TXMLxplconditionType.Get_SchemaClass: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Schema_class).NodeValue; end;

function TXMLxplconditionType.Get_SchemaType: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Schema_type).NodeValue; end;

function TXMLxplconditionType.Get_SourceDevice: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Source_devic).NodeValue; end;

function TXMLxplconditionType.Get_SourceInstance: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Source_insta).NodeValue; end;

function TXMLxplconditionType.Get_SourceVendor: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Source_vendo).NodeValue; end;

function TXMLxplconditionType.Get_TargetDevice: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Target_devic).NodeValue; end;

function TXMLxplconditionType.Get_TargetInstance: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Target_insta).NodeValue; end;

function TXMLxplconditionType.Get_TargetVendor: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Target_vendo).NodeValue; end;

function TXMLxplconditionType.Get_Params: TXMLParamsType;
begin Result := TXMLParamsType.Create(self, K_XML_STR_Param); end;

{ TXMLinput }
function TXMLinput.Get_Match: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Match).NodeValue; end;

function TXMLinput.Get_xplconditions: TXMLConditionsType;
begin Result := TXMLConditionsType.Create(self, K_XML_STR_XplCondition); end;

{ TXMLoutput }
function TXMLoutput.Get_xplActions: TXMLActionsType;
begin Result := TXMLActionsType.Create(self, K_XML_STR_XplAction); end;

{ TXMLdeterminatorType }
function TXMLdeterminatorType.Get_Description: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Description).NodeValue; end;

function TXMLdeterminatorType.Get_groupname: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_GroupName).NodeValue; end;

function TXMLdeterminatorType.Get_Enabled: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Enabled).NodeValue; end;

function TXMLdeterminatorType.Get_IsGroup: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_IsGroup).NodeValue; end;

function TXMLdeterminatorType.Get_Name: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLdeterminatorType.Get_output: TXMLoutput;
begin Result := TXMLoutput(FindNode(K_XML_STR_Output)); end;

function TXMLdeterminatorType.Get_input: TXMLinput;
begin Result := TXMLInput(FindNode(K_XML_STR_Input)); end;

{ TXMLxplActionParamType }
function TXMLxplActionParamType.Get_Expression: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Expression).NodeValue; end;

{ TXMLxplActionType }
function TXMLxplActionType.Get_DisplayName: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Display_name).NodeValue; end;

function TXMLxplActionType.Get_ExecuteOrder: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_ExecuteOrder).NodeValue; end;

function TXMLxplActionType.Get_Msg_Schema: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Msg_schema).NodeValue; end;

function TXMLxplActionType.Get_Msg_Target: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Msg_target).NodeValue; end;

function TXMLxplActionType.Get_Msg_Type: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Msg_type).NodeValue; end;

function TXMLxplActionType.Get_xplActionParams: TXMLxplActionParamsType;
begin Result := TXMLxplActionParamsType.Create(self, K_XML_STR_XplActionPar); end;

initialization
   Document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\determinator\36aaa3adcf324675b6104c2590866a57.xml');
   xpldeterminatorFile := TXMLxpldeterminatorsType.Create(Document.FirstChild,K_XML_STR_Determinator);

finalization
   xpldeterminatorFile.destroy;
   Document.destroy;

end.


