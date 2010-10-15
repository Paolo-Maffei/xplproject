unit u_xml_xplplugin;

{$mode objfpc}{$H+}

interface

uses u_xml,
    DOM;

type
     TXMLOptionType = class(T_clinique_DOMElement)
     private
       function Get_Label_: AnsiString;
       function Get_Value: AnsiString;
       procedure Set_Label_(const AValue: AnsiString);
       procedure Set_Value(const AValue: AnsiString);
     published
        property value : AnsiString read Get_Value write Set_Value;
        property label_ : AnsiString read Get_Label_ write Set_Label_;
     end;
     TXMLOptionsType = specialize TXMLElementList<TXMLOptionType>;

     { TXMLElementType }

     TXMLElementType = class(T_clinique_DOMElement)
     private
       function Get_Conditional_Visibility: AnsiString;
       function Get_Control_Type: AnsiString;
       function Get_Default_: AnsiString;
       function Get_Label_: AnsiString;
       function Get_max_val: AnsiString;
       function Get_min_val: AnsiString;
       function Get_Name: AnsiString;
       function Get_Options: TXMLOptionsType;
       function Get_regexp: AnsiString;
       procedure Set_Conditional_Visibility(const AValue: AnsiString);
       procedure set_Control_Type(const AValue: AnsiString);
       procedure Set_default_(const AValue: AnsiString);
       procedure Set_Label_(const AValue: AnsiString);
       procedure Set_max_val(const AValue: AnsiString);
       procedure Set_min_val(const AValue: AnsiString);
       procedure Set_Name(const AValue: AnsiString);
       procedure Set_regexp(const AValue: AnsiString);
     published
        property name : AnsiString read Get_Name write Set_Name;
        property label_ : AnsiString read Get_Label_ write Set_Label_;
        property control_type : AnsiString read Get_Control_Type write Set_Control_Type;
        property min_val : AnsiString read Get_min_val write Set_min_val;
        property max_val : AnsiString read Get_max_val write Set_max_val;
        property regexp  : AnsiString read Get_regexp write Set_regexp;
        property default_ : AnsiString read Get_Default_ write Set_default_;
        property conditional_visibility : AnsiString read Get_Conditional_Visibility write Set_Conditional_Visibility;
        property Options : TXMLOptionsType read Get_Options;
     end;
     TXMLElementsType = specialize TXMLElementList<TXMLElementType>;


     { TXMLCommandType }

     TXMLCommandType = class(TDOMElement)
     private
       function Get_Description: AnsiString;
       function Get_Elements: TXMLElementsType;
       function Get_msg_schema: AnsiString;
       function Get_msg_type: AnsiString;
       function Get_Name: AnsiString;
       procedure Set_Description(const AValue: AnsiString);
       procedure Set_msg_type(const AValue: AnsiString);
       procedure Set_Name(const AValue: AnsiString);
       procedure Set_Schema(const AValue: AnsiString);
     published
        property msg_type : AnsiString read Get_msg_type write Set_msg_type;
        property name : AnsiString read Get_Name write Set_Name;
        property description : AnsiString read Get_Description write Set_Description;
        property msg_schema : AnsiString read Get_msg_schema write Set_Schema;
        property elements : TXMLElementsType read Get_Elements;
     end;
     TXMLCommandsType = specialize TXMLElementList<TXMLCommandType>;

     //TXMLTriggerType = TXMLCommandType;                                                    // Did not kept these types as they are redundant
     //TXMLTriggersType = specialize TXMLElementList<TXMLTriggerType>;                       // with Command

     { TXMLSchemaType }

     TXMLSchemaType = class(TDOMElement)
     private
       function Get_command: AnsiString;
       function Get_Comment: AnsiString;
       function Get_Listen: AnsiString;
       function Get_Name: AnsiString;
       function Get_Status: AnsiString;
       function Get_trigger: AnsiString;
       procedure Set_Command(const AValue: AnsiString);
       procedure Set_Comment(const AValue: AnsiString);
       procedure Set_Listen (const AValue: AnsiString);
       procedure Set_Name(const AValue: AnsiString);
       procedure Set_Status (const AValue: AnsiString);
       procedure Set_Trigger(const AValue: AnsiString);
     published
        property name    : AnsiString read Get_Name write Set_Name;
        property command : AnsiString read Get_command write Set_Command;
        property status  : AnsiString read Get_Status  write Set_Status;
        property listen  : AnsiString read Get_Listen  write Set_Listen;
        property trigger : AnsiString read Get_trigger write Set_Trigger;
        property comment : AnsiString read Get_Comment write Set_Comment;
     end;
     TXMLSchemasType = specialize TXMLElementList<TXMLSchemaType>;

     { TXMLMenuItemType }

     TXMLMenuItemType = class(T_clinique_DOMElement)
     private
       function Get_Name: AnsiString;
       function Get_xplmsg: AnsiString;
       procedure Set_Name(const AValue: AnsiString);
       procedure Set_xplmsg(const AValue: AnsiString);
     published
        property name : AnsiString read Get_Name write Set_Name;
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
        function Get_Triggers: TXMLCommandsType;
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
        property Triggers     : TXMLCommandsType    read Get_Triggers;
        property MenuItems    : TXMLMenuItemsType   read Get_MenuItems;
     end;

     TXMLDevicesType = specialize TXMLElementList<TXMLDeviceType>;

     { TXMLxplpluginType }

     TXMLxplpluginType = class(TXMLDevicesType)
     protected
        fFileName : AnsiString;
        fDoc      : TXMLDocument;
        fValid    : Boolean;
     private
        function Get_Info_Url: AnsiString;
        function Get_Plugin_Url: AnsiString;
        function Get_Version: AnsiString;
	function Get_Vendor : AnsiString;
        procedure Set_Info_URL(const AValue: AnsiString);
        procedure Set_Plugin_URL(const AValue: AnsiString);
        procedure Set_Version(const AValue: AnsiString);
     public
        constructor Create(const ANode: TDOMNode); overload;
        constructor Create(const aFileName : string); overload;
        destructor  Destroy; override;
        procedure   Save;
        function    AddElement(const aName : string) : TXMLDeviceType;
     published
        property Version: AnsiString read Get_Version write Set_Version;
	property Vendor : AnsiString read Get_Vendor;
        property Plugin_URL : AnsiString read Get_Plugin_Url write Set_Plugin_URL;
        property Info_URL : AnsiString read Get_Info_Url write Set_Info_URL;
        property Valid : boolean read FValid;
     end;

implementation //=========================================================================
uses uXMLRead,
     XMLWrite,
     SysUtils,
     StrUtils;
//========================================================================================
function TXMLDeviceType.Get_Platform_: AnsiString;
begin Result := GetAttribute(K_XML_STR_Platform);     end;

function TXMLDeviceType.Get_Type_: AnsiString;
begin Result := GetAttribute(K_XML_STR_Type);         end;

function TXMLDeviceType.Get_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Version);      end;

function TXMLDeviceType.Get_Beta_Version: AnsiString;
begin Result := GetAttribute(K_XML_STR_Beta_version); end;

function TXMLDeviceType.Get_Description: AnsiString;
begin Result := GetAttribute(K_XML_STR_Description);  end;

function TXMLDeviceType.Get_Download_URL: AnsiString;
begin Result := GetAttribute(K_XML_STR_Download_url); end;

function TXMLDeviceType.Get_Info_URL: AnsiString;
begin Result := GetAttribute(K_XML_STR_Info_url);     end;

function TXMLDeviceType.Get_Id: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Id).NodeValue; end;

function TXMLDeviceType.Get_Device: AnsiString;
begin Result := AnsiRightStr(Id,Length(Id)-AnsiPos('-',Id)); end;

function TXMLDeviceType.Get_Vendor: AnsiString;
begin Result := AnsiLeftStr(Id,AnsiPos('-',Id)-1); end;

function TXMLDeviceType.Get_MenuItems: TXMLMenuItemsType;
begin result := TXMLMenuItemsType.Create(self, K_XML_STR_MenuItem,K_XML_STR_NAME); end;

function TXMLDeviceType.Get_Schemas: TXMLSchemasType;
begin result := TXMLSchemasType.Create(self, K_XML_STR_Schema,K_XML_STR_NAME); end;

function TXMLDeviceType.Get_Triggers: TXMLCommandsType;
begin result := TXMLCommandsType.Create(self, K_XML_STR_Trigger,K_XML_STR_NAME); end;

function TXMLDeviceType.Get_Commands: TXMLCommandsType;
begin result := TXMLCommandsType.Create(self, K_XML_STR_Command,K_XML_STR_NAME); end;

function TXMLDeviceType.Get_ConfigItems: TXMLConfigItemsType;
begin result := TXMLConfigItemsType.Create(self, K_XML_STR_ConfigItem,K_XML_STR_NAME); end;

procedure TXMLDeviceType.Set_Platform_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Platform, aValue); end;

procedure TXMLDeviceType.Set_Device(const AValue: AnsiString);                            // We protect modification of the vendor at this level
begin SetAttribute(K_XML_STR_Id, Vendor + '-' + aValue); end;

procedure TXMLDeviceType.Set_Beta_Version(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Beta_version, aValue); end;

procedure TXMLDeviceType.Set_Type_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Type, aValue); end;

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
begin inherited Create(aNode, K_XML_STR_Device, K_XML_STR_Id); end;

constructor TXMLxplpluginType.Create(const aFileName: string);
var aNode : TDOMNode;
begin
   fFileName := aFileName;
   fDoc := TXMLDocument.Create;
   fValid := True;
   try
      ReadXMLFile(fDoc,fFileName);
   except
      fValid := False;
   end;
   if fValid then begin
      aNode := fDoc.FirstChild;
      while (aNode.NodeName <> K_XML_STR_XplPlugin) and
            (aNode.NodeName<>K_XML_STR_XplhalmgrPlugin) do
            aNode := fDoc.FirstChild.NextSibling;
      Create(aNode);
   end;
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

function TXMLxplpluginType.AddElement(const aName: string): TXMLDeviceType;
begin
  Result:=inherited AddElement(Vendor + '-' + aName);
end;

{ TXMLCommandType }

function TXMLCommandType.Get_Description: AnsiString;
begin result := GetAttribute(K_XML_STR_Description); end;

function TXMLCommandType.Get_Elements: TXMLElementsType;
begin
   Result := TXMLElementsType.Create(self, K_XML_STR_Element,K_XML_STR_NAME );
end;

function TXMLCommandType.Get_msg_schema: AnsiString;
begin result := GetAttribute(K_XML_STR_Msg_schema); end;

function TXMLCommandType.Get_msg_type: AnsiString;
begin result := GetAttribute(K_XML_STR_Msg_type); end;

function TXMLCommandType.Get_Name: AnsiString;
begin result := GetAttribute(K_XML_STR_Name); end;

procedure TXMLCommandType.Set_Description(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Description,aValue); end;

procedure TXMLCommandType.Set_msg_type(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Msg_type, aValue);      end;

procedure TXMLCommandType.Set_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Name,aValue); end;

procedure TXMLCommandType.Set_Schema(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Msg_schema,aValue); end;

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
begin result := GetAttribute(K_XML_STR_Name); end;

function TXMLSchemaType.Get_Status: AnsiString;
begin result := GetAttribute(K_XML_STR_Status); end;

function TXMLSchemaType.Get_trigger: AnsiString;
begin result := GetAttribute(K_XML_STR_Trigger); end;

procedure TXMLSchemaType.Set_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Name,aValue); end;

procedure TXMLSchemaType.Set_Comment(const AValue: AnsiString);
begin if aValue<>'' then  SetAttribute(K_XML_STR_Comment,aValue ); end;

procedure TXMLSchemaType.Set_Command(const AValue: AnsiString);
begin if aValue<>'' then SetAttribute(K_XML_STR_Command,aValue  ); end;

procedure TXMLSchemaType.Set_Listen(const AValue: AnsiString);
begin if aValue<>'' then SetAttribute(K_XML_STR_Listen,aValue   ); end;

procedure TXMLSchemaType.Set_Status(const AValue: AnsiString);
begin if aValue<>'' then SetAttribute(K_XML_STR_Status,aValue   ); end;

procedure TXMLSchemaType.Set_Trigger(const AValue: AnsiString);
begin if aValue<>'' then SetAttribute(K_XML_STR_Trigger,aValue  ); end;

{ TXMLMenuItemType }

function TXMLMenuItemType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLMenuItemType.Get_xplmsg: AnsiString;
begin
   if FindNode(K_XML_STR_XplMsg) = nil then SafeAddNode(K_XML_STR_XplMsg,'message.schema'#10'{'#10'}'#10);
   Result := SafeFindNode(K_XML_STR_XplMsg);
end;

procedure TXMLMenuItemType.Set_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Name, aValue); end;

procedure TXMLMenuItemType.Set_xplmsg(const AValue: AnsiString);
begin SafeChangeNode(K_XML_STR_XplMsg,AValue); end;

{ TXMLOptionType }

function TXMLOptionType.Get_Label_: AnsiString;
begin result := GetAttribute(K_XML_STR_Label); end;

function TXMLOptionType.Get_Value: AnsiString;
begin result := GetAttribute(K_XML_STR_Value); end;

procedure TXMLOptionType.Set_Label_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Label, aValue);   end;

procedure TXMLOptionType.Set_Value(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Value, aValue);   end;

{ TXMLElementType }

function TXMLElementType.Get_Conditional_Visibility: AnsiString;
begin result := GetAttribute(K_XML_STR_ConditionalV); end;

function TXMLElementType.Get_Control_Type: AnsiString;
begin result := GetAttribute(K_XML_STR_Control_type); end;

function TXMLElementType.Get_Default_: AnsiString;
begin result := GetAttribute(K_XML_STR_Default); end;

function TXMLElementType.Get_Label_: AnsiString;
begin result := GetAttribute(K_XML_STR_Label); end;

function TXMLElementType.Get_max_val: AnsiString;
begin result := GetAttribute(K_XML_STR_MAX_VAL); end;

function TXMLElementType.Get_min_val: AnsiString;
begin result := GetAttribute(K_XML_STR_MIN_VAL); end;

function TXMLElementType.Get_Name: AnsiString;
begin result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLElementType.Get_Options: TXMLOptionsType;
begin Result := TXMLOptionsType.Create(self, K_XML_STR_Option,K_XML_STR_VALUE); end;

procedure TXMLElementType.Set_Conditional_Visibility(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_ConditionalV, aValue); end;

procedure TXMLElementType.set_control_type(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Control_type, aValue); end;

procedure TXMLElementType.Set_default_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Default, aValue); end;

procedure TXMLElementType.Set_Label_(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Label, aValue); end;

procedure TXMLElementType.Set_max_val(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_MAX_VAL, aValue); end;

procedure TXMLElementType.Set_min_val(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_MIN_VAL, aValue); end;

procedure TXMLElementType.Set_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Name, aValue); end;

function TXMLElementType.Get_regexp: AnsiString;
begin Result := SafeFindNode(K_XML_STR_REGEXP); end;

procedure TXMLElementType.Set_regexp(const AValue: AnsiString);
begin
   if FindNode(K_XML_STR_REGEXP) <> nil
      then SafeChangeNode(K_XML_STR_REGEXP,AValue)
      else SafeAddNode   (K_XML_STR_REGEXP,AValue);
end;

end.

