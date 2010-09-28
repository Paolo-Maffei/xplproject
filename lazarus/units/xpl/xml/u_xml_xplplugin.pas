unit u_xml_xplplugin;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, u_xml, DOM;

type
     TXMLOptionType = class(TDOMElement)
     private
       function Get_Label_: AnsiString;
       function Get_Regexp: AnsiString;
       function Get_Value: AnsiString;
     published
        property value : AnsiString read Get_Value;
        property label_ : AnsiString read Get_Label_;
        property Regexp : AnsiString read Get_Regexp;
     end;
     TXMLOptionsType = specialize TXMLElementList<TXMLOptionType>;

     TXMLElementType = class(TDOMElement)
     private
       function Get_Conditional_Visibility: AnsiString;
       function Get_Control_Type: AnsiString;
       function Get_Default_: AnsiString;
       function Get_Label_: AnsiString;
       function Get_Name: AnsiString;
       function Get_Options: TXMLOptionsType;
     published
        property name : AnsiString read Get_Name;
        property label_ : AnsiString read Get_Label_;
        property control_type : AnsiString read Get_Control_Type;
        property default_ : AnsiString read Get_Default_;
        property conditional_visibility : AnsiString read Get_Conditional_Visibility;
        property Options : TXMLOptionsType read Get_Options;
     end;
     TXMLElementsType = specialize TXMLElementList<TXMLElementType>;

     TXMLCommandType = class(TDOMElement)
     private
       function Get_Description: AnsiString;
       function Get_Elements: TXMLElementsType;
       function Get_msg_schema: AnsiString;
       function Get_msg_type: AnsiString;
       function Get_Name: AnsiString;
     published
        property msg_type : AnsiString read Get_msg_type;
        property name : AnsiString read Get_Name;
        property description : AnsiString read Get_Description;
        property msg_schema : AnsiString read Get_msg_schema;
        property elements : TXMLElementsType read Get_Elements;
     end;
     TXMLCommandsType = specialize TXMLElementList<TXMLCommandType>;

     TXMLTriggerType = TXMLCommandType;
     TXMLTriggersType = specialize TXMLElementList<TXMLTriggerType>;

     TXMLSchemaType = class(TDOMElement)
     private
       function Get_command: AnsiString;
       function Get_Comment: AnsiString;
       function Get_Listen: AnsiString;
       function Get_Name: AnsiString;
       function Get_Status: AnsiString;
       function Get_trigger: AnsiString;
     published
        property name : AnsiString read Get_Name;
        property command : AnsiString read Get_command;
        property status : AnsiString read Get_Status;
        property listen : AnsiString read Get_Listen;
        property trigger : AnsiString read Get_trigger;
        property comment : AnsiString read Get_Comment;
     end;
     TXMLSchemasType = specialize TXMLElementList<TXMLSchemaType>;

     TXMLMenuItemType = class(T_clinique_DOMElement)
     private
       function Get_Name: AnsiString;
       function Get_xplmsg: AnsiString;
     published
        property name : AnsiString read Get_Name;
        property xplmsg : AnsiString read Get_xplmsg;
     end;
     TXMLMenuItemsType = specialize TXMLElementList<TXMLMenuItemType>;

     TXMLConfigItemType = class(TDOMElement)
     private
       function Get_Description: AnsiString;
       function Get_Format: AnsiString;
       function Get_Name: AnsiString;
     published
        property name : AnsiString read Get_Name;
        property description : AnsiString read Get_Description;
        property format : AnsiString read Get_Format;
     end;
     TXMLConfigItemsType = specialize TXMLElementList<TXMLConfigItemType>;

     TXMLDeviceType = class(TDOMElement)
     private
        function Get_Beta_Version: AnsiString;
        function Get_Commands: TXMLCommandsType;
        function Get_ConfigItems: TXMLConfigItemsType;
        function Get_Description: AnsiString;
        function Get_Download_URL: AnsiString;
        function Get_Id: AnsiString;
        function Get_Info_URL: AnsiString;
        function Get_MenuItems: TXMLMenuItemsType;
        function Get_Platform_: AnsiString;
        function Get_Schemas: TXMLSchemasType;
        function Get_Triggers: TXMLTriggersType;
        function Get_Type_: AnsiString;
        function Get_Version: AnsiString;
     public
        property id : AnsiString read Get_Id;
        property Version : AnsiString read Get_Version;
        property Description : AnsiString read Get_Description;
        property info_url : AnsiString read Get_Info_URL;
        property platform_ : AnsiString read Get_Platform_;
        property beta_version : AnsiString read Get_Beta_Version;
        property download_url : AnsiString read Get_Download_URL;
        property type_ : AnsiString read Get_Type_;
        property Commands: TXMLCommandsType read Get_Commands;
        property ConfigItems: TXMLConfigItemsType read Get_ConfigItems;
        property Schemas : TXMLSchemasType read Get_Schemas;
        property Triggers : TXMLTriggersType read Get_Triggers;
        property MenuItems : TXMLMenuItemsType read Get_MenuItems;
     end;

     TXMLDevicesType = specialize TXMLElementList<TXMLDeviceType>;

     TXMLxplpluginType = class(TXMLDevicesType)
     private
        function Get_Info_Url: AnsiString;
        function Get_Plugin_Url: AnsiString;
        function Get_Version: AnsiString;
	function Get_Vendor : AnsiString;
     public
        constructor Create(ANode: TDOMNode); overload;
     published
        property Version: AnsiString read Get_Version;
	property Vendor : AnsiString read Get_Vendor;
        property Plugin_URL : AnsiString read Get_Plugin_Url;
        property Info_URL : AnsiString read Get_Info_Url;
     end;

//var xplpluginfile : TXMLxplpluginType;

implementation //=========================================================================
uses XMLRead;
//========================================================================================
function TXMLDeviceType.Get_Beta_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Beta_version); end;

function TXMLDeviceType.Get_Commands: TXMLCommandsType;
begin Result := TXMLCommandsType.Create(self, K_XML_STR_Command); end;

function TXMLDeviceType.Get_ConfigItems: TXMLConfigItemsType;
begin Result := TXMLConfigItemsType.Create(self, K_XML_STR_ConfigItem); end;

function TXMLDeviceType.Get_Description: AnsiString;
begin Result := GetAttribute(K_XML_STR_Description); end;

function TXMLDeviceType.Get_Download_URL: AnsiString;
begin Result := GetAttribute(K_XML_STR_Download_url); end;

function TXMLDeviceType.Get_Id: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Id).NodeValue; end;

function TXMLDeviceType.Get_Info_URL: AnsiString;
begin Result := GetAttribute(K_XML_STR_Info_url); end;

function TXMLDeviceType.Get_MenuItems: TXMLMenuItemsType;
begin Result := TXMLMenuItemsType.Create(self, K_XML_STR_MenuItem); end;

function TXMLDeviceType.Get_Platform_: AnsiString;
begin Result := GetAttribute(K_XML_STR_Platform); end;

function TXMLDeviceType.Get_Schemas: TXMLSchemasType;
begin Result := TXMLSchemasType.Create(self, K_XML_STR_Schema); end;

function TXMLDeviceType.Get_Triggers: TXMLTriggersType;
begin Result := TXMLTriggersType.Create(self, K_XML_STR_Trigger); end;

function TXMLDeviceType.Get_Type_: AnsiString;
begin  Result := GetAttribute(K_XML_STR_Type); end;

function TXMLDeviceType.Get_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Version); end;

{ TXMLxplpluginType }
function TXMLxplpluginType.Get_Info_Url: AnsiString;
begin result := SafeReadNode(K_XML_STR_Info_url); end;

function TXMLxplpluginType.Get_Plugin_Url: AnsiString;
begin result := SafeReadNode(K_XML_STR_Plugin_url); end;

function TXMLxplpluginType.Get_Version: AnsiString;
begin result := SafeReadNode(K_XML_STR_Version); end;

function TXMLxplpluginType.Get_Vendor: AnsiString;
begin result := SafeReadNode(K_XML_STR_Vendor); end;

constructor TXMLxplpluginType.Create(ANode: TDOMNode);
begin inherited Create(aNode, K_XML_STR_Device); end;

{ TXMLCommandType }

function TXMLCommandType.Get_Description: AnsiString;
begin result := GetAttribute(K_XML_STR_Description); end;

function TXMLCommandType.Get_Elements: TXMLElementsType;
begin Result := TXMLElementsType.Create(self, K_XML_STR_Element); end;

function TXMLCommandType.Get_msg_schema: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Msg_schema).NodeValue; end;

function TXMLCommandType.Get_msg_type: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Msg_type).NodeValue; end;

function TXMLCommandType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

{ TXMLElementType }

function TXMLElementType.Get_Conditional_Visibility: AnsiString;
begin result := GetAttribute(K_XML_STR_ConditionalV); end;

function TXMLElementType.Get_Control_Type: AnsiString;
begin result := GetAttribute(K_XML_STR_Control_type); end;

function TXMLElementType.Get_Default_: AnsiString;
begin result := GetAttribute(K_XML_STR_Default); end;

function TXMLElementType.Get_Label_: AnsiString;
begin result := GetAttribute(K_XML_STR_Label); end;

function TXMLElementType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLElementType.Get_Options: TXMLOptionsType;
begin Result := TXMLOptionsType.Create(self, K_XML_STR_Option); end;

{ TXMLOptionType }

function TXMLOptionType.Get_Label_: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Label).NodeValue; end;

function TXMLOptionType.Get_Regexp: AnsiString;
begin Result := FindNode(K_XML_STR_Regexp).FirstChild.NodeValue; end;

function TXMLOptionType.Get_Value: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Value).NodeValue; end;

{ TXMLConfigItemType }

function TXMLConfigItemType.Get_Description: AnsiString;
begin result := GetAttribute(K_XML_STR_Description); end;

function TXMLConfigItemType.Get_Format: AnsiString;
begin result := GetAttribute(K_XML_STR_Format); end;

function TXMLConfigItemType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

{ TXMLSchemaType }

function TXMLSchemaType.Get_command: AnsiString;
begin result := GetAttribute(K_XML_STR_Command); end;

function TXMLSchemaType.Get_Comment: AnsiString;
begin result := GetAttribute(K_XML_STR_Comment); end;

function TXMLSchemaType.Get_Listen: AnsiString;
begin result := GetAttribute(K_XML_STR_Listen); end;

function TXMLSchemaType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLSchemaType.Get_Status: AnsiString;
begin result := GetAttribute(K_XML_STR_Status); end;

function TXMLSchemaType.Get_trigger: AnsiString;
begin result := GetAttribute(K_XML_STR_Trigger); end;

{ TXMLMenuItemType }

function TXMLMenuItemType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLMenuItemType.Get_xplmsg: AnsiString;
begin Result := SafeFindNode(K_XML_STR_XplMsg); end;



{initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\ProgramData\xPL\Plugins\clinique.xml');

   aNode := Document.FirstChild;
   while aNode.NodeName <> K_XML_STR_XplPlugin do begin
         aNode := Document.FirstChild.NextSibling;
   end;
   xplpluginfile := TXMLxplpluginType.Create(aNode);

finalization
   xplpluginfile.destroy;
   document.destroy;}

end.

