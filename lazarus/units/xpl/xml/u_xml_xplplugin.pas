unit u_xml_xplplugin;

{$mode objfpc}{$H+}

interface

uses Classes,
     SysUtils,
     u_xml,
     DOM;

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

     { TXMLSchemaType }

     TXMLSchemaType = class(TDOMElement)
     private
       function Get_command: AnsiString;
       function Get_Comment: AnsiString;
       function Get_Listen: AnsiString;
       function Get_Name: AnsiString;
       function Get_Status: AnsiString;
       function Get_trigger: AnsiString;
       procedure Set_Command(const AValue: AnsiString); inline;
       procedure Set_Comment(const AValue: AnsiString); inline;
       procedure Set_Listen (const AValue: AnsiString); inline;
       procedure Set_Status (const AValue: AnsiString); inline;
       procedure Set_Trigger(const AValue: AnsiString); inline;
     published
        property name : AnsiString read Get_Name;
        property command : AnsiString read Get_command write Set_Command;
        property status : AnsiString  read Get_Status  write Set_Status;
        property listen : AnsiString  read Get_Listen  write Set_Listen;
        property trigger : AnsiString read Get_trigger write Set_Trigger;
        property comment : AnsiString read Get_Comment write Set_Comment;
     end;
     TXMLSchemasType = specialize TXMLElementList<TXMLSchemaType>;

     { TXMLMenuItemType }

     TXMLMenuItemType = class(T_clinique_DOMElement)
     private
       function Get_Name: AnsiString;
       function Get_xplmsg: AnsiString;
       procedure Set_xplmsg(const AValue: AnsiString);
     published
        property name : AnsiString read Get_Name;
        property xplmsg : AnsiString read Get_xplmsg write Set_xplmsg;
     end;
     TXMLMenuItemsType = specialize TXMLElementList<TXMLMenuItemType>;

     { TXMLConfigItemType }

     TXMLConfigItemType = class(TDOMElement)
     private
       function Get_Description: AnsiString;
       function Get_Format: AnsiString;
       function Get_Name: AnsiString;
       procedure Set_Description(const AValue: AnsiString);
       procedure Set_Format(const AValue: AnsiString);
     published
        property name : AnsiString read Get_Name;
        property description : AnsiString read Get_Description write Set_Description;
        property format : AnsiString read Get_Format write Set_Format;
     end;
     TXMLConfigItemsType = specialize TXMLElementList<TXMLConfigItemType>;

     { TXMLDeviceType }

     TXMLDeviceType = class(TDOMElement)
     private
        function Get_Beta_Version: AnsiString;
        function Get_Commands: TXMLCommandsType;
        function Get_ConfigItems: TXMLConfigItemsType;
        function Get_Description: AnsiString;
        function Get_Device: AnsiString;
        function Get_Download_URL: AnsiString;
        function Get_Id: AnsiString;
        function Get_Info_URL: AnsiString;
        function Get_MenuItems: TXMLMenuItemsType;
        function Get_Platform_: AnsiString;
        function Get_Schemas: TXMLSchemasType;
        function Get_Triggers: TXMLTriggersType;
        function Get_Type_: AnsiString;
        function Get_Vendor: AnsiString;
        function Get_Version: AnsiString;
        procedure Set_Beta_Version(const AValue: AnsiString);
        procedure Set_Description(const AValue: AnsiString);
        procedure Set_Device(const AValue: AnsiString);
        procedure Set_Download_URL(const AValue: AnsiString);
        procedure Set_Info_URL(const AValue: AnsiString);
        procedure Set_Platform_(const AValue: AnsiString);
        procedure Set_Type_(const AValue: AnsiString);
        procedure Set_Version(const AValue: AnsiString);
     public
        property id           : AnsiString read Get_Id;                               // formed v-d in the xml file
        property vendor       : AnsiString read Get_Vendor;                           // return only V
        property device       : AnsiString read Get_Device       write Set_Device;    // return only D
        property Version      : AnsiString read Get_Version      write Set_Version;
        property Description  : AnsiString read Get_Description  write Set_Description;
        property info_url     : AnsiString read Get_Info_URL     write Set_Info_URL;
        property platform_    : AnsiString read Get_Platform_    write Set_Platform_;
        property beta_version : AnsiString read Get_Beta_Version write Set_Beta_Version;
        property download_url : AnsiString read Get_Download_URL write Set_Download_URL;
        property type_        : AnsiString read Get_Type_        write Set_Type_;
        property Commands     : TXMLCommandsType    read Get_Commands;
        property ConfigItems  : TXMLConfigItemsType read Get_ConfigItems;
        property Schemas      : TXMLSchemasType     read Get_Schemas;
        property Triggers     : TXMLTriggersType    read Get_Triggers;
        property MenuItems    : TXMLMenuItemsType   read Get_MenuItems;
     end;

     TXMLDevicesType = specialize TXMLElementList<TXMLDeviceType>;

     { TXMLxplpluginType }

     TXMLxplpluginType = class(TXMLDevicesType)
     protected
        fFileName : AnsiString;
        fDoc      : TXMLDocument;
     private
        function Get_Info_Url: AnsiString;
        function Get_Plugin_Url: AnsiString;
        function Get_Version: AnsiString;
	function Get_Vendor : AnsiString;
procedure Set_Info_URL(const AValue: AnsiString);
procedure Set_Plugin_URL(const AValue: AnsiString);
procedure Set_Version(const AValue: AnsiString);
//        procedure Set_Version(const AValue: AnsiString);
     public
        constructor Create(const ANode: TDOMNode); overload;
        constructor Create(const aFileName : string); overload;
        destructor  Destroy; override;
        procedure   Save;
     published
        property Version: AnsiString read Get_Version write Set_Version;
	property Vendor : AnsiString read Get_Vendor;
        property Plugin_URL : AnsiString read Get_Plugin_Url write Set_Plugin_URL;
        property Info_URL : AnsiString read Get_Info_Url write Set_Info_URL;
     end;

implementation //=========================================================================
uses XMLRead,
     XMLWrite,
     StrUtils;
//========================================================================================
function TXMLDeviceType.Get_Beta_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Beta_version); end;

procedure TXMLDeviceType.Set_Beta_Version(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Beta_version, aValue); end;

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

function TXMLDeviceType.Get_Device: AnsiString;
begin Result := AnsiRightStr(Id,Length(Id)-AnsiPos('-',Id)); end;

function TXMLDeviceType.Get_Vendor: AnsiString;
begin Result := AnsiLeftStr(Id,AnsiPos('-',Id)-1); end;

procedure TXMLDeviceType.Set_Device(const AValue: AnsiString);                            // We protect modification of the vendor at this level
begin SetAttribute(K_XML_STR_Id, Vendor + '-' + aValue); end;

function TXMLDeviceType.Get_Info_URL: AnsiString;
begin Result := GetAttribute(K_XML_STR_Info_url); end;

function TXMLDeviceType.Get_MenuItems: TXMLMenuItemsType;
begin Result := TXMLMenuItemsType.Create(self, K_XML_STR_MenuItem); end;

function TXMLDeviceType.Get_Platform_: AnsiString;
begin Result := GetAttribute(K_XML_STR_Platform); end;

procedure TXMLDeviceType.Set_Platform_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Platform, aValue); end;

function TXMLDeviceType.Get_Schemas: TXMLSchemasType;
begin Result := TXMLSchemasType.Create(self, K_XML_STR_Schema); end;

function TXMLDeviceType.Get_Triggers: TXMLTriggersType;
begin Result := TXMLTriggersType.Create(self, K_XML_STR_Trigger); end;

function TXMLDeviceType.Get_Type_: AnsiString;
begin  Result := GetAttribute(K_XML_STR_Type); end;

procedure TXMLDeviceType.Set_Type_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Type, aValue); end;

function TXMLDeviceType.Get_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Version); end;

procedure TXMLDeviceType.Set_Version(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Version, aValue); end;

procedure TXMLDeviceType.Set_Description(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Description,aValue); end;

procedure TXMLDeviceType.Set_Download_URL(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Download_url,aValue); end;

procedure TXMLDeviceType.Set_Info_URL(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Info_url, aValue); end;

{ TXMLxplpluginType }
function TXMLxplpluginType.Get_Info_Url: AnsiString;
begin result := SafeReadNode(K_XML_STR_Info_url); end;

function TXMLxplpluginType.Get_Plugin_Url: AnsiString;
begin result := SafeReadNode(K_XML_STR_Plugin_url); end;

function TXMLxplpluginType.Get_Version: AnsiString;
begin result := SafeReadNode(K_XML_STR_Version); end;

function TXMLxplpluginType.Get_Vendor: AnsiString;
begin result := SafeReadNode(K_XML_STR_Vendor); end;

procedure TXMLxplpluginType.Set_Info_URL(const AValue: AnsiString);
begin SafeChangeNode(K_XML_STR_Info_url,aValue); end;

procedure TXMLxplpluginType.Set_Plugin_URL(const AValue: AnsiString);
begin SafeChangeNode(K_XML_STR_Plugin_url,aValue); end;

procedure TXMLxplpluginType.Set_Version(const AValue: AnsiString);
begin SafeChangeNode(K_XML_STR_Version,aValue); end;

constructor TXMLxplpluginType.Create(const ANode: TDOMNode);
begin inherited Create(aNode, K_XML_STR_Device); end;

constructor TXMLxplpluginType.Create(const aFileName: string);
var aNode : TDOMNode;
begin
   fFileName := aFileName;
   fDoc := TXMLDocument.Create;
   ReadXMLFile(fDoc,fFileName);
   aNode := fDoc.FirstChild;
   while (aNode.NodeName <> K_XML_STR_XplPlugin) and
         (aNode.NodeName<>K_XML_STR_XplhalmgrPlugin) do
         aNode := fDoc.FirstChild.NextSibling;
   Create(aNode);
end;

destructor TXMLxplpluginType.Destroy;
begin
   if Assigned(fDoc) then fDoc.Destroy;
   inherited;
end;

procedure TXMLxplpluginType.Save;
begin
   if fFileName = '' then exit;
   WriteXML(RootNode,fFileName);
end;

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

procedure TXMLConfigItemType.Set_Description(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Description,aValue); end;

procedure TXMLConfigItemType.Set_Format(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Format,aValue); end;

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

procedure TXMLSchemaType.Set_Command(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Command,aValue); end;

procedure TXMLSchemaType.Set_Comment(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Comment,aValue); end;

procedure TXMLSchemaType.Set_Listen(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Listen,aValue); end;

procedure TXMLSchemaType.Set_Status(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Status,aValue); end;

procedure TXMLSchemaType.Set_Trigger(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Trigger,aValue); end;

{ TXMLMenuItemType }

function TXMLMenuItemType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLMenuItemType.Get_xplmsg: AnsiString;
begin Result := SafeFindNode(K_XML_STR_XplMsg); end;

procedure TXMLMenuItemType.Set_xplmsg(const AValue: AnsiString);
begin SafeChangeNode(K_XML_STR_XplMsg,AValue); end;

end.

