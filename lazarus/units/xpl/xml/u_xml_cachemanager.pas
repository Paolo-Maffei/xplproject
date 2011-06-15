unit u_xml_cachemanager;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, u_xml;

type

  TXMLFieldmapType = class(TDOMElement)
  protected
     function Get_Xpltagname: AnsiString;
     function Get_Cacheobjectname: AnsiString;
  published
     property Xpltagname: AnsiString read Get_Xpltagname;
     property Cacheobjectname: AnsiString read Get_Cacheobjectname;
  end;

  TXMLFieldsType = specialize TXMLElementList<TXMLFieldmapType>;

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

  TXMLCacheManagerType = specialize TXMLElementList<TXMLCacheEntryType>;

  Function InitCacheManager(const aDirectory : string) : TXMLCacheManagerType;

//var CacheManagerFile : TXMLCacheManagerType;

implementation //=========================================================================
uses XMLRead;
const StandardFN = 'CacheManager.standard.xml';
      CustomFn   = 'CacheManager.custom.xml';

var Document : TXMLDocument;

function InitCacheManager(const aDirectory: string): TXMLCacheManagerType;
var doc2 : TXMLDocument;
    node : tdomnode;
begin
   Document := TXMLDocument.Create;
   ReadXMLFile(document,aDirectory + StandardFN);                         // read standard cache manager
   ReadXMLFile(doc2,aDirectory + CustomFn);                               // read custom cache manager

   node := document.FirstChild.FirstChild;
   document.firstchild.AppendChild(node);                                 // appends custom cm to standard cm

   Result := TXMLCacheManagerType.Create(Document.FirstChild, K_XML_STR_Cacheentry);
   doc2.Free;
end;

//========================================================================================

// TXMLFieldmapType ======================================================================
function TXMLFieldmapType.Get_Xpltagname: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Xpltagname).NodeValue; end;

function TXMLFieldmapType.Get_Cacheobjectname: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Cacheobjectn).NodeValue; end;

// TXMLCacheEntryType ===================================================================
function TXMLCacheEntryType.Get_Cacheprefix: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Cacheprefix).NodeValue; end;

function TXMLCacheEntryType.Get_Filter: AnsiString;
begin Result := FindNode(K_XML_STR_Filter).FirstChild.NodeValue; end;

function TXMLCacheEntryType.Get_Fields: TXMLFieldsType;
begin Result := TXMLFieldsType.Create(self, K_XML_STR_Fieldmap); end;

end.

