unit uxPLCacheManagerFile;
{==============================================================================
  UnitName      = uxPLCacheManagerFile
  UnitDesc      = XML CacheManager File Management Unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 Version 0.9  : first version
 }
{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, XMLRead, uxPLSettings, uxPLConst, uxPLAddress;

type { TxPLCacheManagerFile }

     TxPLCacheManagerFile = class(TXMLDocument)
     private
        aDocument    : TXMLDocument;
        fFilterEntry : TStringList;

        procedure  GetElements;
     public
        constructor create(const aSettings : TxPLSettings);
        destructor  destroy; override;
        function    Count : integer;
        function    Filter(const i : integer) : string;
        function    CachedCount(const i : integer) : integer;
        function    CachedItem (const i : integer; const j : integer) : tsBodyElmtName;
        function    CachedName (const i : integer; const j : integer) : string;
        function    ComposeCachedName(const i : integer; aName : string; aSource : TxPLAddress): string;
     end;

implementation //========================================================================
uses IdHTTP, RegExpr, cStrings, StrUtils;

// This var is global outside class because in the constructor of TxPLCacheManagerFile,
// we call ReadXMLFile on self, wich reinits the object - ugly but by design of XMLRead
// no clean workaround found - workaround could be to change ancestor VendorSeedFile to
// a different object than TXMLDocument, having XMLDocument as a property

function TxPLCacheManagerFile.Count: integer;
begin result := fFilterEntry.Count; end;

function TxPLCacheManagerFile.Filter(const i : integer): string;
begin result := fFilterEntry.Names[i]; end;

function TxPLCacheManagerFile.ComposeCachedName(const i : integer; aName : string; aSource : TxPLAddress): string;
var variablepart : string;
    compose : string;
    cptElt : integer;
begin
     result := fFilterEntry.ValueFromIndex[i];
     variablepart := StrBetweenChar(result,'{','}');
     compose := '';
     if length(variablepart)>0 then begin
        for cptElt:=1 to length(variablepart) do
            if variablepart[cptElt] = 'V' then
               compose += aSource.Vendor + '.'
            else if variablepart[cptElt] = 'D' then
                compose += aSource.Device + '.'
            else if variablepart[cptElt] = 'I' then
                compose += aSource.Instance + '.';
        compose := TrimRight(compose,['.']);         // remove last '.'
        result := AnsiReplaceStr(result, '{' + variablepart + '}', compose);
     end;
     result := result + '.' + aName;
end;

function TxPLCacheManagerFile.CachedCount(const i: integer): integer;
begin result := TStringList(fFilterEntry.Objects[i]).Count; end;

function TxPLCacheManagerFile.CachedItem(const i: integer; const j : integer): tsBodyElmtName;
begin result := TStringList(fFilterEntry.Objects[i]).Names[j]; end;

function TxPLCacheManagerFile.CachedName(const i: integer; const j : integer): string;
begin result := TStringList(fFilterEntry.Objects[i]).ValueFromIndex[j]; end;

constructor TxPLCacheManagerFile.create(const aSettings: TxPLSettings);
begin
   inherited Create;
   fFilterEntry := TStringList.Create;
   aDocument := TXMLDocument.Create;
   ReadXMLFile(aDocument,aSettings.ConfigDirectory + 'CacheManager.standard.xml');
   GetElements;
   ReadXMLFile(aDocument,aSettings.ConfigDirectory + 'CacheManager.custom.xml');
   GetElements;
end;

destructor TxPLCacheManagerFile.destroy;
begin
   aDocument.Destroy;
   fFilterEntry.Destroy;
   inherited;
end;

procedure TxPLCacheManagerFile.GetElements;
var Entry, Filtre, Fields, Champs : TDomNode;
    liste : TStringList;
    i : integer;
    s : string;
begin
   Entry := aDocument.DocumentElement.FirstChild;
   while Assigned(Entry) do begin
      Filtre := Entry.FindNode('filter');
      if Assigned(Filtre) then begin
         i := fFilterEntry.Add(Filtre.FirstChild.NodeValue + '=' + Entry.Attributes.GetNamedItem('cacheprefix').NodeValue);
         s := filtre.NodeName;
         Fields := Entry.FindNode('fields');
         if Assigned(Fields) then begin
            Champs := Fields.FirstChild;
            liste := TStringList.Create;
            while Assigned(Champs) do begin
                  liste.Add( Champs.Attributes.GetNamedItem('xpltagname').NodeValue + '=' + Champs.Attributes.GetNamedItem('cacheobjectname').NodeValue);
                  Champs := Champs.NextSibling;
            end;
            fFilterEntry.Objects[i] := liste;
         end;
      end;
      Entry := Entry.NextSibling;
   end;
end;


end.

