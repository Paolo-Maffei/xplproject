unit u_xml;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DOM;

const
  //Schema_Collection Strings
  K_XML_STR_Name            = 'name';
  K_XML_STR_XplSchema       = 'xplSchema';
  K_XML_STR_XplSchemaCol    = 'xplSchemaCollection';
  // XPL Plugin Strings
  K_XML_STR_Beta_version    = 'beta_version';
  K_XML_STR_COMMAND         = 'command';
  K_XML_STR_COMMENT         = 'comment';
  K_XML_STR_ConditionalV    = 'conditional-visibility';
  K_XML_STR_ConfigItem      = 'configItem';
  K_XML_STR_Control_type    = 'control_type';
  K_XML_STR_Default         = 'default';
  K_XML_STR_Description     = 'description';
  K_XML_STR_Device          = 'device';
  K_XML_STR_Download_url    = 'download_url';
  K_XML_STR_Element         = 'element';
  K_XML_STR_Format          = 'format';
  K_XML_STR_CONFIGTYPE      = 'configtype';
  K_XML_STR_MAXVALUE        = 'maxvalues';
  K_XML_STR_Id              = 'id';
  K_XML_STR_Info_url        = 'info_url';
  K_XML_STR_LABEL           = 'label';
  K_XML_STR_MIN_VAL         = 'min_val';
  K_XML_STR_MAX_VAL         = 'max_val';
  K_XML_STR_LISTEN          = 'listen';
  K_XML_STR_MENUITEM        = 'menuItem';
  K_XML_STR_MSG_SCHEMA      = 'msg_schema';
  K_XML_STR_MSG_TYPE        = 'msg_type';
  K_XML_STR_Option          = 'option';
  K_XML_STR_Platform        = 'platform';
  K_XML_STR_PLUGIN_URL      = 'plugin_url';
  K_XML_STR_Regexp          = 'regexp';
  K_XML_STR_Schema          = 'schema';
  K_XML_STR_STATUS          = 'status';
  K_XML_STR_Trigger         = 'trigger';
  K_XML_STR_Type            = 'type';
  K_XML_STR_VALUE           = 'value';
  K_XML_STR_Vendor          = 'vendor';
  K_XML_STR_Version         = 'version';
  K_XML_STR_XplMsg          = 'xplMsg';
  K_XML_STR_XplPlugin       = 'xpl-plugin';
  K_XML_STR_XplhalmgrPlugin = 'xplhalmgr-plugin';
  // Globals Strings
  K_XML_STR_Expires         = 'expires';
  K_XML_STR_CREATE          = 'createts';
  K_XML_STR_FORMER          = 'former';
  K_XML_STR_EXPIRE          = 'expirets';
  K_XML_STR_Global          = 'global';
  K_XML_STR_Lastupdate      = 'lastupdate';
  // Event Strings
  K_XML_STR_Dow             = 'dow';
  K_XML_STR_Endtime         = 'endtime';
  K_XML_STR_Event           = 'event';
  K_XML_STR_Eventdatetim    = 'eventdatetime';
  K_XML_STR_Eventruntime    = 'eventruntime';
  K_XML_STR_Init            = 'init';
  K_XML_STR_Interval        = 'interval';
  K_XML_STR_Param           = 'param';
  K_XML_STR_Randomtime      = 'randomtime';
  K_XML_STR_Recurring       = 'recurring';
  K_XML_STR_Runsub          = 'runsub';
  K_XML_STR_Starttime       = 'starttime';
  K_XML_STR_TAG             = 'tag';
  // Timer Strings
  K_XML_STR_ESTIMATED_END_TIME = 'estimatedend';
  K_XML_STR_FREQUENCY = 'frequency';
  K_XML_STR_MODE      = 'mode';
  K_XML_STR_REMAINING = 'remaining';
  // Determinator Strings
  K_XML_STR_Determinator    = 'determinator';
  K_XML_STR_Display_name    = 'display_name';
  K_XML_STR_Enabled         = 'enabled';
  K_XML_STR_ExecuteOrder    = 'executeOrder';
  K_XML_STR_Expression      = 'expression';
  K_XML_STR_GroupName       = 'groupName';
  K_XML_STR_Input           = 'input';
  K_XML_STR_IsGroup         = 'IsGroup';
  K_XML_STR_Match           = 'match';
  K_XML_STR_Msg_target      = 'msg_target';
  K_XML_STR_MSG_SOURCE      = 'msg_source';
  K_XML_STR_Operator        = 'operator';
  K_XML_STR_Output          = 'output';
  K_XML_STR_Schema_class    = 'schema_class';
  K_XML_STR_Schema_type     = 'schema_type';
  K_XML_STR_Source_devic    = 'source_device';
  K_XML_STR_Source_insta    = 'source_instance';
  K_XML_STR_Source_vendo    = 'source_vendor';
  K_XML_STR_Target_devic    = 'target_device';
  K_XML_STR_Target_insta    = 'target_instance';
  K_XML_STR_Target_vendo    = 'target_vendor';
  K_XML_STR_XplAction       = 'xplAction';
  K_XML_STR_XplActionPar    = 'xplActionParam';
  K_XML_STR_XplCondition    = 'xplCondition';
  // Cache Manager Strings
  K_XML_STR_Cacheentry      = 'cacheentry';
  K_XML_STR_Cacheobjectn    = 'cacheobjectname';
  K_XML_STR_Cacheprefix     = 'cacheprefix';
  K_XML_STR_StatusTag       = 'statustag';
  K_XML_STR_DeviceType      = 'devicetype';
  K_XML_STR_Fieldmap        = 'fieldmap';
  K_XML_STR_Filter          = 'filter';
  K_XML_STR_Xpltagname      = 'xpltagname';
  // Plugins Strings
  K_XML_STR_Location        = 'location';
  K_XML_STR_Plugin          = 'plugin';
  K_XML_STR_Url             = 'url';
  // XPL Configuration Strings
  K_XML_STR_Key             = 'key';
  K_XML_STR_XplConfigura    = 'xplConfiguration';
type

   { T_clinique_DOMElementList }

   T_clinique_DOMElement = class(TDOMElement)
   public
      function SafeReadNode(const aValue : String) : string;
      function SafeFindNode(const aValue : String) : string;
      procedure SafeChangeNode(const aNodeName: String; const aValue : string);
      procedure SafeAddNode(const aNodeName: String; const aValue : string);
   end;

   T_clinique_DOMElementList = class(TDOMElementList)
   public
      function SafeReadNode(const aValue : String) : string;
      procedure SafeChangeNode(const aNodeName: String; const aValue : string);
//      procedure SafeWriteNode(const aName: String; const aValue : string);
   end;

     { TXMLElementList }

     generic TXMLElementList<_T> = class(T_clinique_DOMElementList)
     private
       fKeyName : string;
       function GetDocument: TXMLDocument;
       function Get_ElementByName(aName : string): _T;
     protected
        fRootNode : TDOMNode;
        fKeyWord  : string;                                         // Name of the attribute used as a key in the list
        function Get_Element (Index: Integer): _T;
     public
        constructor Create(const aDocument : TXMLDocument; const aLabel : string; const aKeyName : string); overload;
        constructor Create(const aNode : TDOMNode; const aLabel : string; const aKeyName : string);         overload;
        function    AddElement(const aName : string) : _T;
//        function    Exists(const aName : string) : boolean;
        procedure   RemoveElement(const aName : string);
        procedure EmptyList;
        property Element[Index: Integer]: _T read Get_Element; default;
        property ElementByName[aName : string] : _T read Get_ElementByName;
        property RootNode : TDOMNode read fRootNode;
        property Document : TXMLDocument read GetDocument;
     end;

implementation

function T_clinique_DOMElement.SafeReadNode(const aValue: String): string;
var DevNode : TDOMNode;
begin
   result := '';
   DevNode := Attributes.GetNamedItem(aValue);
   if DevNode<>nil then result := DevNode.NodeValue;
end;

function T_clinique_DOMElement.SafeFindNode(const aValue: String): string;
var DevNode : TDOMNode;
begin
   result := '';
   DevNode := FindNode(aValue);
   if DevNode = nil then exit;

   DevNode := DevNode.FirstChild;
   if DevNode<>nil then result := DevNode.NodeValue;
end;

procedure T_clinique_DOMElement.SafeChangeNode(const aNodeName: String; const aValue : string);
var OldNode, NewNode : TDOMNode;
begin
   OldNode := FindNode(aNodeName);
   if OldNode = nil then exit;
   DetachChild(OldNode);
   NewNode := OwnerDocument.CreateElement(aNodeName);
   NewNode.AppendChild(OwnerDocument.CreateTextNode(aValue));
   AppendChild(NewNode);
end;

procedure T_clinique_DOMElement.SafeAddNode(const aNodeName: String; const aValue: string);
var NewNode : TDOMNode;
begin
   NewNode := OwnerDocument.CreateElement(aNodeName);
   NewNode.AppendChild(OwnerDocument.CreateTextNode(aValue));
   AppendChild(NewNode);
end;

{ T_clinique_DOMElementList }

function T_clinique_DOMElementList.SafeReadNode(const aValue: String): string;
var DevNode : TDOMNode;
begin
   result := '';
   DevNode := FNode.Attributes.GetNamedItem(aValue);
   if DevNode<>nil then result := DevNode.NodeValue;
end;

procedure T_clinique_DOMElementList.SafeChangeNode(const aNodeName: String; const aValue: string);
begin
     TDOMElement(FNode).SetAttribute(aNodeName,aValue);
end;

{ TXMLElementList }

function TXMLElementList.AddElement(const aName : string) : _T;
var child : TDOMNode;

begin
   result := ElementByName[aName];
   if TObject(result) = nil then begin
      child := Document.CreateElement(fKeyword);
      fRootNode.AppendChild(child);
      TDOMElement(Child).SetAttribute(fKeyName, aName);
      fList.Add(child);
      result := _T(child);
   end;
end;

{function TXMLElementList.Exists(const aName: string): boolean;
var i : integer;
begin
   result := true;
   i := count;
   for i :=  0 to Count-1 do
       if _T(Item[i]).GetAttribute(fKeyName) = aName then exit;
   result := false;
end;}

procedure TXMLElementList.RemoveElement(const aName: string);
var child : TDOMNode;
begin
   child := fRootNode.FirstChild;
   repeat
      if TDOMElement(Child).GetAttribute(fKeyName) = aName then begin
         fRootNode.RemoveChild(child);
         child := nil;
      end else child := child.NextSibling;
   until (child = nil);
end;

procedure TXMLElementList.EmptyList;
begin
  while fRootNode.HasChildNodes do
        fRootNode.RemoveChild(RootNode.FirstChild);
end;

function TXMLElementList.GetDocument: TXMLDocument;
begin
   result := TXMLDocument(RootNode.OwnerDocument);
end;

function TXMLElementList.Get_ElementByName(aName : string): _T;
var i : integer;
begin
   result := nil;
   i := count;
   for i :=  0 to Count-1 do
       if _T(Item[i]).GetAttribute(fKeyName) = aName then result := _T(Item[i]);
end;

function TXMLElementList.Get_Element(Index: Integer): _T;
begin
   Result := _T(Item[Index]);
end;

constructor TXMLElementList.Create(const aDocument : TXMLDocument; const aLabel : string; const aKeyName : string);
begin
   Create(aDocument.FirstChild,aLabel,aKeyName);
end;

constructor TXMLElementList.Create(const aNode : TDOMNode; const aLabel : string; const aKeyName : string);
begin
   fRootNode := aNode;
   fKeyWord  := aLabel;
   fKeyName  := aKeyName;
   inherited Create(fRootNode,fKeyWord);
end;


end.
