unit u_xml_plugins;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , superobject
     , u_xpl_common
     , u_xpl_header
     ;

type TChoiceType = class(TCollectionItem)
     public
        value : string;
        label_ : String ;
        procedure Set_O(o : ISuperObject);
     end;

     TChoicesType = class(TCollection)
     public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TChoiceType;

        property Items[Index : integer] : TChoiceType read Get_Items; default;
     end;

{ TElementType }

     TElementType = class(TCollectionItem)
        fChoices : TChoicesType;
     private
        fSO : ISuperObject;
        function GetChoices: TChoicesType;
     public
        name : string;
        label_ : String ;
        control_type : String;
        min_val : integer;
        max_val : integer;
        regexp  : String ;
        default_ : String ;
        conditional_visibility : String;
        property Choices : TChoicesType read GetChoices;
        procedure Set_O(o : ISuperObject);
        destructor Destroy; override;
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

      private
         fSO : ISuperObject;
         function GetElements: TElementsType;
         function GetMsgType: TxPLMessageType;
      public
         msg_type : string;
         name : string;
         description : string;
         msg_schema : string;
         procedure Set_O(o : ISuperObject);
         destructor Destroy; override;
         property Elements : TElementsType read GetElements;
      published
         property MsgType : TxPLMessageType read GetMsgType;
      end;

      { TConfigItemType }

      TConfigItemType = class(TCollectionItem)
      public
         name : string;
         description : string;
         format : string;
         procedure Set_O(o : ISuperObject);
      end;

      TTriggersType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TCommandType;

        property Items[Index : integer] : TCommandType read Get_Items; default;
     end;


      { TCommandsType }

      TCommandsType = class(TCollection)
      private
        fDV : string;
      public
        constructor Create(const so: ISuperObject; const aDV : string);
        function  Get_Items(Index : integer) : TCommandType;

        property Items[Index : integer] : TCommandType read Get_Items; default;
        property DV : string read fDV;
     end;

      { TConfigItemsType }

      TConfigItemsType = class(TCollection)
      public
        Constructor Create(const so : ISuperObject);
        function  Get_Items(Index : integer) : TConfigItemType;

        property Items[Index : integer] : TConfigItemType read Get_Items; default;
      end;


      { TDeviceType }

      TDeviceType = class(TCollectionItem)
      private
        fSO : iSuperObject;
        fCommands : TCommandsType;
        fConfigItems : TConfigItemsType;
        fTriggers : TTriggersType;
        function GetCommands: TCommandsType;
        function GetConfigItems: TConfigItemsType;
        function GetTriggers: TTriggersType;
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
        destructor Destroy; override;
      published
        property Device : string read Get_Device;
        property Vendor : string read Get_Vendor;
        property Commands : TCommandsType read GetCommands;
        property Triggers : TTriggersType read GetTriggers;
        property ConfigItems : TConfigItemsType read GetConfigItems;
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
         fSO : ISuperObject;
         fVendor : string;
         fFileName : string;
         fPresent : boolean;
         fDevices : TDevicesType;
         function GetDevices: TDevicesType;
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
         destructor Destroy; override;
      published
         property Vendor : string read fVendor write Set_Vendor;
         property Present: boolean read fPresent;
         property FileName : string read fFileName;
         property Devices : TDevicesType read GetDevices;
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


      TSchemaType = class(TCollectionItem)
      public
         name : string;
      end;

      // TSchemaCollection ====================================================
      TSchemaCollection = class(TCollection)
      protected
         fPluginDir : string;
      public
         Constructor Create(const so : ISuperObject; const aPluginDir : string);
         function Get_Items(Index : integer) : TSchemaType;
         property Items[Index : integer] : TSchemaType read Get_Items; default;
      end;

implementation //==============================================================
uses StrUtils
     , typInfo
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

constructor TChoicesType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TChoiceType);
  o := so['option'];
  if not assigned(o) then exit;
  if o.IsType(stArray) then begin
     arr := o.AsArray;
     for i := 0 to arr.Length-1 do with TChoiceType(Add) do Set_O(arr[i]);
  end else
      if o.IsType(stObject) then with TChoiceType(Add) do Set_O(o);
end;

function TChoicesType.Get_Items(Index: integer): TChoiceType;
begin
   Result := TChoiceType(inherited Items[index]);
end;

procedure TChoiceType.Set_O(o: ISuperObject);
begin
  value := AnsiString(o['value'].AsString);
  if Assigned(o['label']) then label_ := AnsiString(o['label'].AsString);
end;

{ TElementType }

function TElementType.GetChoices: TChoicesType;
begin
  if Assigned(fSO['choices']) and (not Assigned(fChoices))
     then fChoices := TChoicesType.Create(fSO['choices']);
  Result := fChoices;
end;

procedure TElementType.Set_O(o: ISuperObject);
begin
  fSO := o;
  fChoices := nil;
  name := AnsiString(fSO['name'].AsString);
  if Assigned(fSO['default']) then default_ := AnsiString(fSO['default'].AsString);
end;

destructor TElementType.Destroy;
begin
   if Assigned(fChoices)
      then fChoices.Free;
   inherited Destroy;
end;

{ TCommandType }

function TCommandType.GetElements: TElementsType;
begin
   if not Assigned(fElements)
      then  fElements := TElementsType.Create(fSO);
   Result := fElements;
end;

function TCommandType.GetMsgType: TxPLMessageType;
begin
   result := TxPLMessageType(GetEnumValue(TypeInfo(TxPLMessageType), msg_type));
end;

procedure TCommandType.Set_O(o: ISuperObject);
var b : ISuperObject;
begin
   fSO := o;
   fElements := nil;
   name := AnsiString(o['name'].AsString);
   b := fSO['msg_type'];    if assigned(b) then msg_type    := AnsiString(b.AsString);
   b := fSO['description']; if assigned(b) then description := AnsiString(b.AsString);
   b := fSO['msg_schema'];  if assigned(b) then msg_schema  := AnsiString(b.AsString);
end;

destructor TCommandType.Destroy;
begin
   if Assigned(fElements)
      then fElements.Free;
   inherited Destroy;
end;

procedure TConfigItemType.Set_O(o: ISuperObject);
var b : ISuperObject;
begin
   name := AnsiString(o['name'].AsString);
   b := o['format']; if assigned(b) then format := AnsiString(b.AsString);
   b := o['description']; if assigned(b) then description := AnsiString(b.AsString);
end;

{ TCommandsType }

constructor TCommandsType.Create(const so: ISuperObject; const aDV : string);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TCommandType);
  fDV := aDV;
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

constructor TTriggersType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TCommandType);
  o := so['trigger'];
  if not assigned(o) then exit;
  if o.IsType(stArray) then begin
     arr := o.AsArray;
     for i := 0 to arr.Length-1 do with TCommandType(Add) do Set_O(arr[i]);
  end else
      if o.IsType(stObject) then with TCommandType(Add) do Set_O(o);
end;

function TTriggersType.Get_Items(Index: integer): TCommandType;
begin
  Result := TCommandType(inherited Items[index]);
end;

{ TConfigItemsType }

constructor TConfigItemsType.Create(const so: ISuperObject);
var arr : TSuperArray;
    i : integer;
    o : isuperobject;
begin
  inherited Create(TCommandType);
  o := so['configItem'];
  if not assigned(o) then exit;
  if o.IsType(stArray) then begin
     arr := o.AsArray;
     for i := 0 to arr.Length-1 do with TConfigItemType(Add) do Set_O(arr[i]);
  end else
      if o.IsType(stObject) then with TConfigItemType(Add) do Set_O(o);
end;

function TConfigItemsType.Get_Items(Index: integer): TConfigItemType;
begin
  Result := TConfigItemType(inherited Items[index]);
end;

{ TDeviceType }

function TDeviceType.Get_Device: string;
begin
   Result := AnsiRightStr(Id_,Length(Id_)-AnsiPos('-',Id_));
end;

function TDeviceType.GetCommands: TCommandsType;
begin
   if not Assigned(fCommands) then
      fCommands := TCommandsType.Create(fSO,ID_);
   Result := fCommands;
end;

function TDeviceType.GetConfigItems: TConfigItemsType;
begin
   if not Assigned(fConfigItems) then
      fConfigItems := TConfigItemsType.Create(fSO);
   Result := fConfigItems;
end;

function TDeviceType.GetTriggers: TTriggersType;
begin
   if not Assigned(fTriggers) then
      fTriggers := TTriggersType.Create(fSO);
   Result := fTriggers;
end;

function TDeviceType.Get_Vendor: string;
begin
  Result := AnsiLeftStr(Id_,Pred(AnsiPos('-',Id_)));
end;

procedure TDeviceType.Set_O(o: ISuperObject);
var b : ISuperObject;
begin
   fSO := o;
   fCommands := nil;
   fConfigItems := nil;
   fTriggers := nil;
   id_ := AnsiString(fSO['id'].AsString);
   b := fSO['version']; if assigned(b) then Version := AnsiString(b.AsString);
   b := fSO['description']; if assigned(b) then Description := AnsiString(b.AsString);
   b := fSO['info_url']; if assigned(b) then Info_URL := AnsiString(b.AsString);
   b := fSO['platform']; if assigned(b) then platform_ := AnsiString(b.AsString);
   b := fSO['beta_version']; if assigned(b) then beta_version := AnsiString(b.AsString);
   b := fSO['download_url']; if assigned(b) then download_url :=AnsiString( b.AsString);
   b := fSO['type']; if assigned(b) then type_ := AnsiString(b.AsString);
end;

destructor TDeviceType.Destroy;
begin
   if Assigned(fCommands)
      then fCommands.Free;
   if Assigned(fConfigItems)
      then fConfigItems.Free;
   if Assigned(fTriggers)
      then fTriggers.Free;
   inherited Destroy;
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
var o : ISuperObject;
    s  : string;
begin
   if AnsiCompareText(fVendor,AValue) <> 0 then begin
      fVendor   := AnsiLowerCase(AValue);
      fFileName := TPluginsType(Collection).fPluginDir +
                   AnsiRightStr( URL,length(Url)-LastDelimiter('/',URL)
                    ) + K_FEXT_XML;
      fPresent  := Fileexists(fFileName);
      if fPresent then begin
         fSO := XMLParseFile(fFileName,true);
         if Assigned(so) then begin                                            // The file may be present but not XML valid
            s  := AnsiString(so.AsJSon);
            if length(s)>0 then begin
               o := fSO['version'];
               if assigned(o) then Version := AnsiString(o.AsString);
               o := fSO['info_url'];
               if assigned(o) then Info_URL := AnsiString(o.AsString);
               o := fSO['plugin_url'];
               if assigned(o) then Plugin_URL := AnsiString(o.AsString);
            end;
         end;
      end;
   end;
end;

function TPluginType.GetDevices: TDevicesType;
begin
   if not Assigned(fDevices) then
      fDevices := TDevicesType.Create(fSO);
   result := fDevices;
end;

function TPluginType.Update: boolean;
var aUrl : string;
begin
   aUrl := Url;
   if not AnsiEndsStr(K_FEXT_XML, aUrl) then aUrl := aUrl + K_FEXT_XML;
   Result := HTTPDownload(aUrl, FileName, xPLApplication.Settings.ProxyServer);
end;

destructor TPluginType.Destroy;
begin
   if Assigned(fDevices)
      then fDevices.Free;
   inherited Destroy;
end;


// TPluginsType ===============================================================
constructor TPluginsType.Create(const so : ISuperObject; const aPluginDir : string);
var i : integer;
    arr : TSuperArray;
begin
   inherited Create(TPluginType);
   fPluginDir := aPluginDir;
   arr := so['plugin'].AsArray;
   for i := 0 to arr.Length-1 do
       with TPluginType(Add) do begin
            name := AnsiString(arr[i]['name'].AsString);
            type_ := AnsiString(arr[i]['type'].AsString);
            description := AnsiString(arr[i]['description'].AsString);
            url := AnsiString(arr[i]['url'].AsString);
            vendor := AnsiLeftStr(Name,Pred(AnsiPos(' ',Name)));
       end;
end;

function TPluginsType.Get_Items(Index : integer) : TPluginType;
begin
   Result := TPluginType(inherited Items[index]);
end;

// TSchemaCollection ==========================================================
constructor TSchemaCollection.Create(const so : ISuperObject; const aPluginDir : string);
var i : integer;
    arr : TSuperArray;
begin
   inherited Create(TSchemaType);

   fPluginDir := aPluginDir;

   arr := so['xplSchema'].AsArray;
   for i := 0 to arr.Length-1 do
       with TSchemaType(Add) do
            name := AnsiString(arr[i]['name'].AsString);
end;

function TSchemaCollection.Get_Items(Index: integer): TSchemaType;
begin
   Result := TSchemaType(inherited Items[index]);
end;

// TLocationsType =============================================================
constructor TLocationsType.Create(const so : ISuperObject);
var i : integer;
    arr : TSuperArray;
begin
   inherited Create(TLocationType);

   arr := SO['locations']['location'].AsArray;
   for i:=0 to arr.Length-1 do
       with TLocationType(Add) do
            Url := AnsiString(arr[i]['url'].AsString);

end;

function TLocationsType.Get_Items(Index : integer) : TLocationType;
begin
   Result := TLocationType(inherited Items[index]);
end;


end.
