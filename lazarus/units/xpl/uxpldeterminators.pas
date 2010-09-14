unit uxpldeterminators;

{$mode objfpc}{$H+}

interface

uses Classes,u_xml_xpldeterminator, uxplsettings;

Type
    { TxPLDeterminatorList }

    TxPLDeterminatorList = class(TStringList)
    private
       fBaseDir : string;
       function Get_Determinator(index : integer): TXMLxpldeterminatorsFile;
       function ReferenceAFile(const aFName : string) : integer;
    public
       constructor Create(const axPLSettings : TxPLSettings);
       destructor  Destroy; override;
       property  Elements[index : integer] : TXMLxpldeterminatorsFile read Get_Determinator; default;
       function TextContent(const aSGUID: string) : AnsiString;
       function Add(const aSGUID :string; const aStringList : TStringList) : string; overload;
       function Delete(const aSGUID :string) : boolean; overload;
       procedure ListRules(const aGUID : string; aOut : TStringList);
       procedure ListGroups(aOut : TStringList);
    end;


implementation // ==================================================================================
uses uxPLConst, SysUtils, cStrings, DOM, XMLRead, XMLWrite, u_xml;
{ TxPLDeterminatorList }

function TxPLDeterminatorList.Get_Determinator(index: integer ): TXMLxpldeterminatorsFile;
begin
   result := TXMLxpldeterminatorsFile( Objects[index]);
end;

constructor TxPLDeterminatorList.Create(const axPLSettings : TxPLSettings);
var
  searchResult : TSearchRec;
  fName,fExt : string;

begin
  inherited Create;
  fBaseDir := axPLSettings.SharedConfigDir + 'determinator\';
  TxPLSettings.EnsureDirectoryExists(fBaseDir);

  Duplicates:=dupIgnore;
  Sorted := true;
  SetCurrentDir(fBaseDir);

  if FindFirst('*' + K_FEXT_XML, faAnyFile, searchResult) = 0 then begin

    repeat
          StrSplitAtChar(SearchResult.Name,'.',fName,fExt);                                         // Get filename without extension
          ReferenceAFile(fName);
    until FindNext(searchResult) <> 0;

    FindClose(searchResult);
  end;
end;

destructor TxPLDeterminatorList.Destroy;
var i : integer;
    aDoc : TXMLDocument;
begin
  for i:=0 to count-1 do begin
      aDoc := TXMLxplDeterminatorsFile(Objects[i]).Document;
      WriteXMLFile(aDoc,fBaseDir + Strings[i] + K_FEXT_XML);
      aDoc.Free;
  end;
  inherited Destroy;
end;

function TxPLDeterminatorList.TextContent(const aSGUID: string): AnsiString;
var ts : tstringlist;
    i  : integer;
begin
   i := IndexOf(aSGUID);
   if i=-1 then exit;

   ts := TStringList.Create;
   ts.LoadFromFile(fBaseDir + aSGUID + K_FEXT_XML);
   result := ts.text;
   ts.Destroy;
end;

function TxPLDeterminatorList.Add(const aSGUID: string; const aStringList: TStringList): string;
var i : integer;
    guid : TGUID;

begin
     i := IndexOf(aSGUID);
     if i=-1 then begin                         // It is a new determinator
        sysutils.CreateGUID(guid);
        result := StrRemoveChar(GuidToString(guid),['{','-','}']);
     end else begin                             // We replace an existing determinator
        result := aSGUID;
        Delete(aSGUID);
     end;
     aStringList.Text:=StrReplace('&#xD;','',aStringList.Text);           // For an unknown reason xPLHal manager gives me this shit
     aStringList.Text:=StrReplace('&#xA;','',aStringList.Text);
     aStringList.SaveToFile(fBaseDir + result + K_FEXT_XML);
     ReferenceAFile(Result);
end;

function TxPLDeterminatorList.Delete(const aSGUID: string): boolean;
var i : integer;
    aDeterminator : TXMLxpldeterminatorsfile;
begin
   i := IndexOf(aSGUID);
   result := i<>-1;
   if not result then exit;

   aDeterminator := TXMLxpldeterminatorsFile(Objects[i]);
   aDeterminator.Destroy;
   DeleteFile(fBaseDir + Strings[i] + K_FEXT_XML);
   Delete(i);
end;

procedure TxPLDeterminatorList.ListRules(const aGUID : string; aOut : TStringList);
const sFormatRule = '%s'#9'%s'#9'%s';
var i : integer;
begin
   for i:=0 to Count-1 do
      if not Elements[i][0].IsGroup then begin
       if (Elements[i][0].groupname = aGUID) or (aGUID='{ALL}') then
             aOut.Add(Format(sFormatRule,[Strings[i],Elements[i][0].Name_,Elements[i][0].EnabledAsString]));

      end;
end;

procedure TxPLDeterminatorList.ListGroups(aOut : TStringList);
const sFormatGroup = '%s'#9'%s';
var i : integer;
begin
   for i:=0 to Count-1 do
       if Elements[i][0].IsGroup then aOut.Add(Format(sFormatGroup,[Strings[i],Elements[i][0].Name_,'']));
end;

function TxPLDeterminatorList.ReferenceAFile(const aFName: string) : integer;
var aDocument : TXMLDocument;
begin
   result := Add(afName);
   aDocument := TXMLDocument.Create;                                                         // I must create one document for every file
   ReadXMLFile(aDocument, fBaseDir + aFNAME + K_FEXT_XML);
   Objects[result] := TXMLxpldeterminatorsFile.Create(aDocument,K_XML_STR_Determinator);
end;

end.

