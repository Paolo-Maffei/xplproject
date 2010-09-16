unit uxPLPluginFile;
{==============================================================================
  UnitName      = uxPLPluginFile
  UnitDesc      = XML Vendor File Management Unit
  UnitCopyright = GPL by Clinique / xPL Project
                The pluginlist contains details on how to access to every
                vendor file (TxPLPluginFile).
                The PluginFile allows to access contained described devices.
 ==============================================================================
 Version 0.9  : usage of uxPLConst
         0.91 : Renamed class TxPLPluginFile to TxPLVendorFile
 }
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, uxPLConst, uxPLMessage;

type

     { TxPLDevice }

     TxPLDevice = class(TComponent)
     private
       fNode    : TDomNode;
       FDescription: string;
       FInfoURL: string;
       FVersion: string;
       fID     : string;                                                        // vendor-device
       fVendor : tsVendor;
       fName   : tsDevice;
       fPlatforme : string;
       fBetaVersion : string;
       fDownloadURL : string;
       fType : string;

       function    GetElementList(const aEltName : string): TStringList;
       function    GetElement(const aElement : string;  const aEltName : string): TDomNode;

     public
       constructor Create(aNode : TDOMNode); overload;
       property    Description : string read FDescription;
       property    Version     : string read FVersion;
       property    InfoURL     : string read FInfoURL;
       property    Node        : TDomNode read fNode;
       property    Platforme   : string read fPlatforme;
       property    BetaVersion : string read fBetaVersion;
       property    DownloadURL : string read fDownloadUrl;
       property    AppType     : string read fType;
       function    CommandAsMessage(const aCommand : string) : TxPLMessage;
       function    Command(const aCommand : string) : TDomNode;
       function    Commands : TStringList;
       function    ConfigItems : TStringList;
       function    ConfigItem(const aConfigItem : string) : TDomNode;
       function    MenuItems : TStringList;
       function    MenuItem(const aMenuItem : string) : string;
       property    Id        : string read fID;                                 // Vendor-Device
       property    VendorTag : tsVendor read fVendor;
       property    Name      : tsDevice read fName;
     end;

implementation //========================================================================
uses XMLRead, RegExpr, u_xml_xpldeterminator;

resourcestring // XML Vendor file entry and field variable names ========================
   K_VF_Command     = 'command';
   K_VF_ConfigItem  = 'configItem';
   K_VF_menuItem    = 'menuItem';
   K_VF_Description = 'description';
   K_VF_Info_url    = 'info_url';
   K_VF_NAME        = 'name';
   K_VF_Device      = 'device';
   K_VF_Id          = 'id';
   K_VF_Vendor      = 'vendor';
   K_VF_Version     = 'version';
   K_VF_Platform    = 'platform';
   K_VF_Beta        = 'beta_version';
   K_VF_Download    = 'download_url';
   K_VF_TYPE        = 'type';

{ TxPLDevice }
constructor TxPLDevice.Create(aNode : TDomNode);

function SafeReadNode(aValue : string) : string;
var DevNode : TDOMNode;
begin
   result := '';
   DevNode := fNode.Attributes.GetNamedItem(aValue);
   if DevNode<>nil then result := DevNode.NodeValue;
end;

begin
   fNode := aNode;

   fVersion     := SafeReadNode(K_VF_Version);
   fDescription := SafeReadNode(K_VF_Description);
   fInfoURL     := SafeReadNode(K_VF_Info_url);
   fPlatforme   := SafeReadNode(K_VF_Platform);
   fBetaVersion := SafeReadNode(K_VF_Beta);
   fDownloadURL := SafeReadNode(K_VF_Download);
   fType        := SafeReadNode(K_VF_TYPE);
   fID        := SafeReadNode(K_VF_ID);

   with TRegExpr.Create do begin
        Expression := K_REGEXPR_DEVICE_ID;
        Exec(fID);
        fVendor := Match[1];
        fName   := Match[2];
        Destroy;
   end;
end;

function TxPLDevice.CommandAsMessage(const aCommand: string): TxPLMessage;
var aNode : TDOMNode;
begin
   result := nil;
   aNode  := Command(aCommand);
   if not Assigned(aNode) then exit;

   Result := TxPLMessage.Create;
   Result.ReadFromXML(TXMLActionsType(aNode));       // check later this hazardous type casting it may surely crash here
end;

function TxPLDevice.GetElementList(const aEltName : string ): TStringList;
var Child : TDomNode;
begin
   result := TStringList.Create;
   Child := fNode.FirstChild;
   while Assigned(Child) do begin
         if Child.NodeName = aEltName then
            Result.Add(Child.Attributes.GetNamedItem(K_VF_NAME).NodeValue);

         Child := Child.NextSibling;
   end;
end;

function TxPLDevice.GetElement(const aElement : string;  const aEltName : string): TDomNode;
var Child : TDomNode;
    CommandName : string;
begin
   result:= nil;

   Child := fNode.FirstChild;
   while Assigned(Child) do begin
         if Child.NodeName = aEltName then begin
            CommandName := Child.Attributes.GetNamedItem(K_VF_NAME).NodeValue;
            if (CommandName = aElement) then result := Child;
         end;
         Child := Child.NextSibling;
   end;
end;

function TxPLDevice.Command(const aCommand : string): TDomNode;
begin Result := GetElement(aCommand,K_VF_Command); end;

function TxPLDevice.Commands : TStringList;
begin Result := GetElementList(K_VF_Command); end;

function TxPLDevice.menuItems : TStringList;
begin Result := GetElementList(K_VF_menuItem); end;

function TxPLDevice.menuItem(const aMenuItem: string): string;
var aNode : TDomNode;
begin
   Result:= '';
   aNode := GetElement(aMenuItem,K_VF_menuItem);
   if not Assigned(aNode) then exit;

   aNode := aNode.FindNode('xplMsg');
   if not Assigned(aNode) then exit;

   result := aNode.FirstChild.NodeValue;
end;

function TxPLDevice.ConfigItem(const aConfigItem: string): TDomNode;
begin Result := GetElement(aConfigItem,K_VF_Command); end;

function TxPLDevice.ConfigItems: TStringList;
begin Result := GetElementList(K_VF_ConfigItem); end;



end.

