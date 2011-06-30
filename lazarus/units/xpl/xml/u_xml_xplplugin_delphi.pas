
{**************************************************************************************************************}
{                                                                                                              }
{                                               XML Data Binding                                               }
{                                                                                                              }
{         Generated on: 31/12/2010 09:57:57                                                                    }
{       Generated from: C:\ProgramData\xPL\Plugins\plugins.xml                                                 }
{   Settings stored in: C:\Users\gaell-aug.SIFRAUGURE\Documents\RAD Studio\Projects\ClinxPL\prj2\plugins.xdb   }
{                                                                                                              }
{**************************************************************************************************************}

unit u_xml_xplplugin_delphi;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLPluginsType = interface;
  IXMLPluginType = interface;
  IXMLPluginTypeList = interface;
  IXMLLocationsType = interface;
  IXMLLocationType = interface;

{ IXMLPluginsType }

  IXMLPluginsType = interface(IXMLNode)
    ['{49D773A5-926B-4BC6-A0A5-4DCB251C55DD}']
    { Property Accessors }
    function Get_Version: UnicodeString;
    function Get_Plugin: IXMLPluginTypeList;
    function Get_Locations: IXMLLocationsType;
    procedure Set_Version(Value: UnicodeString);
    { Methods & Properties }
    property Version: UnicodeString read Get_Version write Set_Version;
    property Plugin: IXMLPluginTypeList read Get_Plugin;
    property Locations: IXMLLocationsType read Get_Locations;
  end;

{ IXMLPluginType }

  IXMLPluginType = interface(IXMLNode)
    ['{700E58EC-3AA9-449C-8FB2-9162BB99F681}']
    { Property Accessors }
    function Get_Name: UnicodeString;
    function Get_Type_: UnicodeString;
    function Get_Description: UnicodeString;
    function Get_Url: UnicodeString;
    procedure Set_Name(Value: UnicodeString);
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Description(Value: UnicodeString);
    procedure Set_Url(Value: UnicodeString);
    { Methods & Properties }
    property Name: UnicodeString read Get_Name write Set_Name;
    property Type_: UnicodeString read Get_Type_ write Set_Type_;
    property Description: UnicodeString read Get_Description write Set_Description;
    property Url: UnicodeString read Get_Url write Set_Url;
  end;

{ IXMLPluginTypeList }

  IXMLPluginTypeList = interface(IXMLNodeCollection)
    ['{6F13BE62-09AA-4F94-9485-AC2034E9AD0E}']
    { Methods & Properties }
    function Add: IXMLPluginType;
    function Insert(const Index: Integer): IXMLPluginType;

    function Get_Item(Index: Integer): IXMLPluginType;
    property Items[Index: Integer]: IXMLPluginType read Get_Item; default;
  end;

{ IXMLLocationsType }

  IXMLLocationsType = interface(IXMLNodeCollection)
    ['{1762C3E7-7E9A-470E-90C8-37CB409548E4}']
    { Property Accessors }
    function Get_Location(Index: Integer): IXMLLocationType;
    { Methods & Properties }
    function Add: IXMLLocationType;
    function Insert(const Index: Integer): IXMLLocationType;
    property Location[Index: Integer]: IXMLLocationType read Get_Location; default;
  end;

{ IXMLLocationType }

  IXMLLocationType = interface(IXMLNode)
    ['{619E1EB6-E245-4FAD-A6EB-B38C2D3C6762}']
    { Property Accessors }
    function Get_Url: UnicodeString;
    procedure Set_Url(Value: UnicodeString);
    { Methods & Properties }
    property Url: UnicodeString read Get_Url write Set_Url;
  end;

{ Forward Decls }

  TXMLPluginsType = class;
  TXMLPluginType = class;
  TXMLPluginTypeList = class;
  TXMLLocationsType = class;
  TXMLLocationType = class;

{ TXMLPluginsType }

  TXMLPluginsType = class(TXMLNode, IXMLPluginsType)
  private
    FPlugin: IXMLPluginTypeList;
  protected
    { IXMLPluginsType }
    function Get_Version: UnicodeString;
    function Get_Plugin: IXMLPluginTypeList;
    function Get_Locations: IXMLLocationsType;
    procedure Set_Version(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLPluginType }

  TXMLPluginType = class(TXMLNode, IXMLPluginType)
  protected
    { IXMLPluginType }
    function Get_Name: UnicodeString;
    function Get_Type_: UnicodeString;
    function Get_Description: UnicodeString;
    function Get_Url: UnicodeString;
    procedure Set_Name(Value: UnicodeString);
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Description(Value: UnicodeString);
    procedure Set_Url(Value: UnicodeString);
  end;

{ TXMLPluginTypeList }

  TXMLPluginTypeList = class(TXMLNodeCollection, IXMLPluginTypeList)
  protected
    { IXMLPluginTypeList }
    function Add: IXMLPluginType;
    function Insert(const Index: Integer): IXMLPluginType;

    function Get_Item(Index: Integer): IXMLPluginType;
  end;

{ TXMLLocationsType }

  TXMLLocationsType = class(TXMLNodeCollection, IXMLLocationsType)
  protected
    { IXMLLocationsType }
    function Get_Location(Index: Integer): IXMLLocationType;
    function Add: IXMLLocationType;
    function Insert(const Index: Integer): IXMLLocationType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLLocationType }

  TXMLLocationType = class(TXMLNode, IXMLLocationType)
  protected
    { IXMLLocationType }
    function Get_Url: UnicodeString;
    procedure Set_Url(Value: UnicodeString);
  end;

{ Global Functions }

function Getplugins(Doc: IXMLDocument): IXMLPluginsType;
function Loadplugins(const FileName: string): IXMLPluginsType;
function Newplugins: IXMLPluginsType;

const
  TargetNamespace = '';

implementation

{ Global Functions }

function Getplugins(Doc: IXMLDocument): IXMLPluginsType;
begin
  Result := Doc.GetDocBinding('plugins', TXMLPluginsType, TargetNamespace) as IXMLPluginsType;
end;

function Loadplugins(const FileName: string): IXMLPluginsType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('plugins', TXMLPluginsType, TargetNamespace) as IXMLPluginsType;
end;

function Newplugins: IXMLPluginsType;
begin
  Result := NewXMLDocument.GetDocBinding('plugins', TXMLPluginsType, TargetNamespace) as IXMLPluginsType;
end;

{ TXMLPluginsType }

procedure TXMLPluginsType.AfterConstruction;
begin
  RegisterChildNode('plugin', TXMLPluginType);
  RegisterChildNode('locations', TXMLLocationsType);
  FPlugin := CreateCollection(TXMLPluginTypeList, IXMLPluginType, 'plugin') as IXMLPluginTypeList;
  inherited;
end;

function TXMLPluginsType.Get_Version: UnicodeString;
begin
  Result := AttributeNodes['version'].Text;
end;

procedure TXMLPluginsType.Set_Version(Value: UnicodeString);
begin
  SetAttribute('version', Value);
end;

function TXMLPluginsType.Get_Plugin: IXMLPluginTypeList;
begin
  Result := FPlugin;
end;

function TXMLPluginsType.Get_Locations: IXMLLocationsType;
begin
  Result := ChildNodes['locations'] as IXMLLocationsType;
end;

{ TXMLPluginType }

function TXMLPluginType.Get_Name: UnicodeString;
begin
  Result := AttributeNodes['name'].Text;
end;

procedure TXMLPluginType.Set_Name(Value: UnicodeString);
begin
  SetAttribute('name', Value);
end;

function TXMLPluginType.Get_Type_: UnicodeString;
begin
  Result := AttributeNodes['type'].Text;
end;

procedure TXMLPluginType.Set_Type_(Value: UnicodeString);
begin
  SetAttribute('type', Value);
end;

function TXMLPluginType.Get_Description: UnicodeString;
begin
  Result := AttributeNodes['description'].Text;
end;

procedure TXMLPluginType.Set_Description(Value: UnicodeString);
begin
  SetAttribute('description', Value);
end;

function TXMLPluginType.Get_Url: UnicodeString;
begin
  Result := AttributeNodes['url'].Text;
end;

procedure TXMLPluginType.Set_Url(Value: UnicodeString);
begin
  SetAttribute('url', Value);
end;

{ TXMLPluginTypeList }

function TXMLPluginTypeList.Add: IXMLPluginType;
begin
  Result := AddItem(-1) as IXMLPluginType;
end;

function TXMLPluginTypeList.Insert(const Index: Integer): IXMLPluginType;
begin
  Result := AddItem(Index) as IXMLPluginType;
end;

function TXMLPluginTypeList.Get_Item(Index: Integer): IXMLPluginType;
begin
  Result := List[Index] as IXMLPluginType;
end;

{ TXMLLocationsType }

procedure TXMLLocationsType.AfterConstruction;
begin
  RegisterChildNode('location', TXMLLocationType);
  ItemTag := 'location';
  ItemInterface := IXMLLocationType;
  inherited;
end;

function TXMLLocationsType.Get_Location(Index: Integer): IXMLLocationType;
begin
  Result := List[Index] as IXMLLocationType;
end;

function TXMLLocationsType.Add: IXMLLocationType;
begin
  Result := AddItem(-1) as IXMLLocationType;
end;

function TXMLLocationsType.Insert(const Index: Integer): IXMLLocationType;
begin
  Result := AddItem(Index) as IXMLLocationType;
end;

{ TXMLLocationType }

function TXMLLocationType.Get_Url: UnicodeString;
begin
  Result := AttributeNodes['url'].Text;
end;

procedure TXMLLocationType.Set_Url(Value: UnicodeString);
begin
  SetAttribute('url', Value);
end;

end.
