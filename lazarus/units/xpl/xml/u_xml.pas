unit u_xml;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DOM;

const
  //Schema_Collection Strings
  K_XML_STR_Name = 'name';
  K_XML_STR_XplSchema = 'xplSchema';
  K_XML_STR_XplSchemaCol = 'xplSchemaCollection';
  // XPL Plugin Strings
  K_XML_STR_Beta_version = 'beta_version';
  K_XML_STR_Command = 'command';
  K_XML_STR_Comment = 'comment';
  K_XML_STR_ConditionalV = 'conditional-visibility';
  K_XML_STR_ConfigItem = 'configItem';
  K_XML_STR_Control_type = 'control_type';
  K_XML_STR_Default = 'default';
  K_XML_STR_Description = 'description';
  K_XML_STR_Device = 'device';
  K_XML_STR_Download_url = 'download_url';
  K_XML_STR_Element = 'element';
  K_XML_STR_Format = 'format';
  K_XML_STR_Id = 'id';
  K_XML_STR_Info_url = 'info_url';
  K_XML_STR_Label = 'label';
  K_XML_STR_Listen = 'listen';
  K_XML_STR_MenuItem = 'menuItem';
  K_XML_STR_Msg_schema = 'msg_schema';
  K_XML_STR_Msg_type = 'msg_type';
  K_XML_STR_Option = 'option';
  K_XML_STR_Platform = 'platform';
  K_XML_STR_Plugin_url = 'plugin_url';
  K_XML_STR_Regexp = 'regexp';
  K_XML_STR_Choices = 'choices';
  K_XML_STR_Schema = 'schema';
  K_XML_STR_Status = 'status';
  K_XML_STR_Trigger = 'trigger';
  K_XML_STR_Type = 'type';
  K_XML_STR_Value = 'value';
  K_XML_STR_Vendor = 'vendor';
  K_XML_STR_Version = 'version';
  K_XML_STR_XplMsg = 'xplMsg';
  K_XML_STR_XplPlugin = 'xpl-plugin';
  // Globals Strings
  K_XML_STR_Expires = 'expires';
  K_XML_STR_Global = 'global';
  K_XML_STR_Lastupdate = 'lastupdate';
  // Event Strings
  K_XML_STR_Dow = 'dow';
  K_XML_STR_Endtime = 'endtime';
  K_XML_STR_Event = 'event';
  K_XML_STR_Eventdatetim = 'eventdatetime';
  K_XML_STR_Eventruntime = 'eventruntime';
  K_XML_STR_Init = 'init';
  K_XML_STR_Interval = 'interval';
  K_XML_STR_Param = 'param';
  K_XML_STR_Randomtime = 'randomtime';
  K_XML_STR_Recurring = 'recurring';
  K_XML_STR_Runsub = 'runsub';
  K_XML_STR_Starttime = 'starttime';
  K_XML_STR_Tag = 'tag';
  // Determinator Strings
  K_XML_STR_Determinator = 'determinator';
  K_XML_STR_Display_name = 'display_name';
  K_XML_STR_Enabled = 'enabled';
  K_XML_STR_ExecuteOrder = 'executeOrder';
  K_XML_STR_Expression = 'expression';
  K_XML_STR_GroupName = 'groupName';
  K_XML_STR_Input = 'input';
  K_XML_STR_IsGroup = 'IsGroup';
  K_XML_STR_Match = 'match';
  K_XML_STR_MSG_TARGET = 'msg_target';
  K_XML_STR_MSG_SOURCE = 'msg_source';
  K_XML_STR_Operator = 'operator';
  K_XML_STR_Output = 'output';
  K_XML_STR_Schema_class = 'schema_class';
  K_XML_STR_Schema_type = 'schema_type';
  K_XML_STR_Source_devic = 'source_device';
  K_XML_STR_Source_insta = 'source_instance';
  K_XML_STR_Source_vendo = 'source_vendor';
  K_XML_STR_Target_devic = 'target_device';
  K_XML_STR_Target_insta = 'target_instance';
  K_XML_STR_Target_vendo = 'target_vendor';
  K_XML_STR_XplAction = 'xplAction';
  K_XML_STR_XplActionPar = 'xplActionParam';
  K_XML_STR_XplCondition = 'xplCondition';
  // Cache Manager Strings
  K_XML_STR_Cacheentry = 'cacheentry';
  K_XML_STR_Cacheobjectn = 'cacheobjectname';
  K_XML_STR_Cacheprefix = 'cacheprefix';
  K_XML_STR_Fieldmap = 'fieldmap';
  K_XML_STR_Filter = 'filter';
  K_XML_STR_Xpltagname = 'xpltagname';
  // Plugins Strings
  K_XML_STR_Location = 'location';
  K_XML_STR_Plugin = 'plugin';
  K_XML_STR_Url = 'url';
  // XPL Configuration Strings
  K_XML_STR_Key = 'key';
  K_XML_STR_XplConfigura = 'xplConfiguration';

  K_XML_STR_FORMER  = 'former';
  K_XML_STR_CREATE  = 'createts';
  K_XML_STR_EXPIRE  = 'expirets';

type

     { TXMLElementList }

     generic TXMLElementList<_T> = class(TDOMElementList)
     private
       function GetDocument: TXMLDocument;
     protected
//        fDocument : TXMLDocument;
        fRootNode : TDOMNode;
        fKeyWord  : string;
        function Get_Element (Index: Integer): _T;
     public
        constructor Create(const aDocument : TXMLDocument; const aLabel : string); overload;
        constructor Create(const aNode : TDOMNode; const aLabel : string);         overload;
        function    AddElement(const aName : string) : _T;
        property Element[Index: Integer]: _T read Get_Element; default;
        property RootNode : TDOMNode read fRootNode;
        property Document : TXMLDocument read GetDocument;
     end;

implementation

function TXMLElementList.GetDocument: TXMLDocument;
begin result := TXMLDocument(RootNode.OwnerDocument); end;

function TXMLElementList.Get_Element(Index: Integer): _T;
begin
   Result := _T(Item[Index]);
end;

constructor TXMLElementList.Create(const aDocument : TXMLDocument; const aLabel : string);
begin
//   fDocument := aDocument;
//   fRootNode := aDocument.FirstChild;
//   fKeyWord  := aLabel;
//   inherited Create(fRootNode,fKeyWord);
   Create(aDocument.FirstChild,aLabel);
end;

constructor TXMLElementList.Create(const aNode : TDOMNode; const aLabel : string);
begin
   fRootNode := aNode;
   fKeyWord  := aLabel;

   inherited Create(fRootNode,fKeyWord);
end;

function TXMLElementList.AddElement(const aName : string) : _T;
var child : TDOMNode;
begin
   child := Document.CreateElement(fKeyword);
   fRootNode.AppendChild(child);
   TDOMElement(Child).SetAttribute(K_XML_STR_NAME, aName);
   fList.Add(child);
   result := _T(child);
end;

end.

