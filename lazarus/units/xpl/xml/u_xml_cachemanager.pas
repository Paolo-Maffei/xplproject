unit u_xml_cachemanager;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM;

type

  TXMLFieldmapType = class(TDOMElement)
  protected
     function Get_Xpltagname: AnsiString;
     function Get_Cacheobjectname: AnsiString;
  published
     property Xpltagname: AnsiString read Get_Xpltagname;
     property Cacheobjectname: AnsiString read Get_Cacheobjectname;
  end;

  TXMLFieldsType = class(TDOMElementList)
  protected
    function Get_Fieldmap(Index: Integer): TXMLFieldmapType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property Fieldmap[Index: Integer]: TXMLFieldmapType read Get_Fieldmap; default;
  end;

  TXMLCacheEntryType = class(TDOMElement)
  protected
    function Get_Cacheprefix: AnsiString;
    function Get_Filter: AnsiString;
    function Get_Fields: TXMLFieldsType;
  public
    property Cacheprefix: AnsiString read Get_Cacheprefix;
    property Filter: AnsiString read Get_Filter;
    property Fields: TXMLFieldsType read Get_Fields;
  end;

  TXMLCachemanagerType = class(TDOMElementList)
  protected
    function Get_CacheEntry(Index: Integer): TXMLCacheEntryType;
  public
    constructor Create(ANode: TDOMNode); overload;
    property CacheEntry[Index: Integer]: TXMLCacheEntryType read Get_CacheEntry; default;
  end;

var CacheManagerFile : TXMLCacheManagerType;

implementation //=========================================================================
uses XMLRead;
var Document : TXMLDocument;
//========================================================================================

// TXMLFieldmapType ======================================================================

function TXMLFieldmapType.Get_Xpltagname: AnsiString;
begin Result := Attributes.GetNamedItem('xpltagname').NodeValue; end;

function TXMLFieldmapType.Get_Cacheobjectname: AnsiString;
begin Result := Attributes.GetNamedItem('cacheobjectname').NodeValue; end;

// TXMLFieldsType =======================================================================
function TXMLFieldsType.Get_Fieldmap(Index: Integer): TXMLFieldmapType;
begin Result := TXMLFieldmapType(Item[Index]); end;

constructor TXMLFieldsType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'fieldmap'); end;

// TXMLCacheEntryType ===================================================================
function TXMLCacheEntryType.Get_Cacheprefix: AnsiString;
begin Result := Attributes.GetNamedItem('cacheprefix').NodeValue; end;

function TXMLCacheEntryType.Get_Filter: AnsiString;
begin Result := FindNode('filter').FirstChild.NodeValue; end;

function TXMLCacheEntryType.Get_Fields: TXMLFieldsType;
begin Result := TXMLFieldsType.Create(self); end;

// TXMLCachemanagerType =================================================================
function TXMLCachemanagerType.Get_CacheEntry(Index: Integer ): TXMLCacheEntryType;
begin Result := TXMLCacheEntryType(Item[Index]); end;

constructor TXMLCachemanagerType.Create(ANode: TDOMNode);
begin inherited Create(aNode,'cacheentry'); end;

// Unit initialization ===================================================================
initialization
   Document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\ProgramData\xPL\Config\CacheManager.standard.xml');
   CacheManagerFile := TXMLCacheManagerType.Create(Document.FirstChild);

finalization
   CacheManagerFile.destroy;
   Document.destroy;

end.

