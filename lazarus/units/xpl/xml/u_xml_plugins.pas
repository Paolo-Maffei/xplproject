unit u_xml_plugins;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , superobject
     ;

type  TPluginType = class(TCollectionItem)
      public
         Name : string;
         Vendor : string;
         Type_ : string;
         Description : string;
         URL : string;
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
      public
         Constructor Create(const so : ISuperObject);
         function  Get_Items(Index : integer) : TPluginType;

         property Items[Index : integer] : TPluginType read Get_Items; default;
      end;

implementation //=========================================================================
uses StrUtils
     ;

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

constructor TPluginsType.Create(const so : ISuperObject);
var i : integer;
    arr : TSuperArray;
begin
  inherited Create(TPluginType);
  arr := so['plugin'].AsArray;
  for i := 0 to arr.Length-1 do
      with TPluginType(Add) do begin
          name := arr[i]['name'].AsString;
          type_ := arr[i]['type'].AsString;
          description := arr[i]['description'].AsString;
          url := arr[i]['url'].AsString;
          vendor := AnsiLowerCase(ExtractWord(1,Name,[' ']));
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

