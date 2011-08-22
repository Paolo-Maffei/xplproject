unit u_xml_plugins;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , superobject
     ;

type

{ TElementType }

TElementType = class(TCollectionItem)
     public
        name : string;
        label_ : String ;
        control_type : String;
        min_val : integer;
        max_val : integer;
        regexp  : String ;
        default_ : String ;
        conditional_visibility : String;

        procedure Set_O(o : ISuperObject);
     end;

      { TElementsType }

      TElementsType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TElementType;

        property Items[Index : integer] : TElementType read Get_Items; default;
     end;


{ TPluginType }

      { TCommandType }

      TCommandType = class(TCollectionItem)
        fElements : TElementsType;
      public
         msg_type : string;
         name : string;
         description : string;
         msg_schema : string;
         procedure Set_O(o : ISuperObject);

         property Elements : TElementsType read fElements;
      end;

      { TCommandsType }

      TCommandsType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TCommandType;

        property Items[Index : integer] : TCommandType read Get_Items; default;
     end;


      { TDeviceType }

      TDeviceType = class(TCollectionItem)
      private
        fCommands : TCommandsType;

        function Get_Device: string;
        function Get_Vendor: string;
      public
        id_          : string;
        Version      : string;
        Description  : string;
        info_url     : string;
        platform_    : string;
        beta_version : string;
        download_url : string;
        type_        : string;
        procedure Set_O(o : ISuperObject);
      published
        property Device : string read Get_Device;
        property Vendor : string read Get_Vendor;
        property Commands : TCommandsType read fCommands;
      end;

      { TDevicesType }

      TDevicesType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TDeviceType;

        property Items[Index : integer] : TDeviceType read Get_Items; default;
     end;

      TPluginType = class(TCollectionItem)
      private
         fVendor : string;
         fFileName : string;
         fPresent : boolean;
         fDevices : TDevicesType;
         procedure Set_Vendor(const AValue: string);
      public
         Name : string;
         Type_ : string;
         Description : string;
         URL : string;
         Info_URL : string;
         Plugin_URL : string;
         Version : string;

         function Update : boolean;
      published
         property Vendor : string read fVendor write Set_Vendor;
         property Present: boolean read fPresent;
         property FileName : string read fFileName;
         property Devices : TDevicesType read fDevices;
      end;

      TLocationType = class(TCollectionItem)
      public
         Url : string;
      end;

      TLocationsType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TLocationType;

        property Items[Index : integer] : TLocationType read Get_Items; default;
     end;

      TPluginsType = class(TCollection)
      protected
         fPluginDir : string;
      public
         Constructor Create(const so : ISuperObject; const aPluginDir : string);
         function  Get_Items(Index : integer) : TPluginType;

         property Items[Index : integer] : TPluginType read Get_Items; default;
      end;

implementation //=========================================================================
uses StrUtils
     , uxPLConst
     , u_downloader_Indy
     , superxmlparser
     , u_xPL_Application
     ;

{ TElementsType }

constructor TElementsType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TElementType);
  o := so['element'];
  if not assigned(o) then exit;
  if o.IsType(stArray) then begin
     arr := o.AsArray;
     for i := 0 to arr.Length-1 do with TElementType(Add) do Set_O(arr[i]);
  end else
      if o.IsType(stObject) then with TElementType(Add) do Set_O(o);
end;

function TElementsType.Get_Items(Index: integer): TElementType;
begin
   Result := TElementType(inherited Items[index]);
end;

{ TElementType }

procedure TElementType.Set_O(o: ISuperObject);
begin
  name := o['name'].AsString;
end;

{ TCommandType }

procedure TCommandType.Set_O(o: ISuperObject);
var b : ISuperObject;
begin
   name := o['name'].AsString;
   b := o['msg_type']; if assigned(b) then msg_type := b.AsString;
   b := o['description']; if assigned(b) then description := b.AsString;
   b := o['msg_schema'];  if assigned(b) then msg_schema := b.AsString;
   fElements := TElementsType.Create(o);
end;

{ TCommandsType }

constructor TCommandsType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TCommandType);
  o := so['command'];
  if not assigned(o) then exit;
  if o.IsType(stArray) then begin
     arr := o.AsArray;
     for i := 0 to arr.Length-1 do with TCommandType(Add) do Set_O(arr[i]);
  end else
      if o.IsType(stObject) then with TCommandType(Add) do Set_O(o);
end;

function TCommandsType.Get_Items(Index: integer): TCommandType;
begin
  Result := TCommandType(inherited Items[index]);
end;

{ TDeviceType }

function TDeviceType.Get_Device: string;
begin
   Result := AnsiRightStr(Id_,Length(Id_)-AnsiPos('-',Id_));
end;

function TDeviceType.Get_Vendor: string;
begin
  Result := AnsiLeftStr(Id_,Pred(AnsiPos('-',Id_)));
end;

procedure TDeviceType.Set_O(o: ISuperObject);
var b : ISuperObject;
begin
   id_ := o['id'].AsString;
   b := o['version']; if assigned(b) then Version := b.AsString;
   b := o['description']; if assigned(b) then Description := b.AsString;
   b := o['info_url']; if assigned(b) then Info_URL := b.AsString;
   b := o['platform']; if assigned(b) then platform_ := b.AsString;
   b := o['beta_version']; if assigned(b) then beta_version := b.AsString;
   b := o['download_url']; if assigned(b) then download_url := b.AsString;
   b := o['type']; if assigned(b) then type_ := b.AsString;
   fCommands := TCommandsType.Create(o);
end;

{ TDevicesType }

constructor TDevicesType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TDeviceType);
  o := so['device'];
  if assigned(o) then

     if o.IsType(stArray) then begin
        arr := SO['device'].AsArray;
        for i:=0 to arr.Length-1 do
            with TDeviceType(Add) do Set_O(arr[i]);
        end
     else   with TDeviceType(Add) do Set_O(o);

end;

function TDevicesType.Get_Items(Index: integer): TDeviceType;
begin
  Result := TDeviceType(inherited Items[index]);
end;

{ TPluginType }

procedure TPluginType.Set_Vendor(const AValue: string);
var so,o : ISuperObject;
    s  : string;
begin
   if AnsiCompareText(fVendor,AValue) <> 0 then begin
      fVendor   := AnsiLowerCase(AValue);
      fFileName := TPluginsType(Collection).fPluginDir +
                   AnsiRightStr( URL,length(Url)-LastDelimiter('/',URL)
                    ) + K_FEXT_XML;
      fPresent  := Fileexists(fFileName);
      if fPresent then begin
         so := XMLParseFile(fFileName,true);
         if Assigned(so) then begin                                            // The file may be present but not XML valid
            s  := so.AsJSon;
            if length(s)>0 then begin
               fDevices := TDevicesType.Create(so);
               o := so['version'];
               if assigned(o) then Version := o.AsString;
               o := so['info_url'];
               if assigned(o) then Info_URL := o.AsString;
               o := so['plugin_url'];
               if assigned(o) then Plugin_URL := o.AsString;
            end;
         end;
      end;
   end;
end;

function TPluginType.Update: boolean;
var aUrl : string;
begin
   aUrl := Url;
   if not AnsiEndsStr(K_FEXT_XML, aUrl) then aUrl := aUrl + K_FEXT_XML;
   Result := HTTPDownload(aUrl, FileName, xPLApplication.Settings.ProxyServer);
end;

constructor TLocationsType.Create(const so : ISuperObject);
var i : integer;
    arr : TSuperArray;
begin
  inherited Create(TLocationType);

  arr := SO['locations']['location'].AsArray;
  for i:=0 to arr.Length-1 do
     with TLocationType(Add) do
         Url := arr[i]['url'].AsString;

end;

function TLocationsType.Get_Items(Index : integer) : TLocationType;
begin
   Result := TLocationType(inherited Items[index]);
end;

constructor TPluginsType.Create(const so : ISuperObject; const aPluginDir : string);
var i : integer;
    arr : TSuperArray;
begin
  inherited Create(TPluginType);
  fPluginDir := aPluginDir;
  arr := so['plugin'].AsArray;
  for i := 0 to arr.Length-1 do
      with TPluginType(Add) do begin
          name := arr[i]['name'].AsString;
          type_ := arr[i]['type'].AsString;
          description := arr[i]['description'].AsString;
          url := arr[i]['url'].AsString;
          vendor := AnsiLeftStr(Name,Pred(AnsiPos(' ',Name)));
      end;
end;

function TPluginsType.Get_Items(Index : integer) : TPluginType;
begin
   Result := TPluginType(inherited Items[index]);
end;

// TXMLLocationType ======================================================================
//function TXMLLocationType.Get_Url: AnsiString;
//begin Result := GetAttribute(K_XML_STR_Url);            end;

// TXMLPluginType ========================================================================
//function TXMLPluginType.Get_Vendor: AnsiString;
//begin Result := AnsiLowerCase(ExtractWord(1,Name,[' '])); end;
//
//function TXMLPluginType.Get_Description: AnsiString;
//begin Result := GetAttribute(K_XML_STR_Description);    end;
//
//function TXMLPluginType.Get_Url: AnsiString;
//begin Result := GetAttribute(K_XML_STR_Url);            end;
//
//function TXMLPluginType.Get_Type_: AnsiString;
//begin Result := GetAttribute(K_XML_STR_Type);           end;
//
//function TXMLPluginType.Get_Name: AnsiString;
//begin Result := GetAttribute(K_XML_STR_Name);           end;

// TXMLPluginsFile =======================================================================
//function TXMLPluginsFile.Get_Version: AnsiString;
//begin result := FNode.Attributes.GetNamedItem(K_XML_STR_Version).NodeValue; end;
//
//constructor TXMLPluginsFile.Create(ANode: TDOMNode);
//begin
//   inherited Create(aNode, K_XML_STR_Plugin);
//   fLocations := TXMLLocationsType.Create(aNode, K_XML_STR_Location);
//end;

end.

