unit u_xpl_common;

{$ifdef fpc}
   {$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , IdDateTimeStamp
     ;

const K_MSG_TYPE_HEAD = 'xpl-';

type TStrParamEvent = procedure(const aString : string) of object;

     TxPLMessageType = (cmnd, stat, trig);

     IxPLCommon = Interface(IInterface)
        procedure  Assign(aSchema : TPersistent);
        function   IsValid : boolean;
        procedure  ResetValues;
     end;

     IxPLRaw = Interface(IInterface)
        procedure Set_RawxPL (const aValue : string);
        function  Get_RawxPL : string;
        property RawxPL : string read Get_RawxPL write Set_RawxPL; // stored false; (*suppressed to validate delphi compatibility*)
     end;

     TxPLRawSet = class(TInterfacedPersistent, IxPLCommon, IxPLRaw)
     private
        function Get_RawxPL: string;  virtual; abstract;
        procedure Set_RawxPL(const AValue: string); virtual; abstract;
     protected
        fRawxPL : TStringList;
     public
        constructor Create;
        destructor  Destroy; override;

        procedure   ResetValues; virtual; abstract;

        procedure   Assign(aRawSet : TPersistent); override;
        function    Equals(const aRawSet : TxPLRawSet) : boolean;
        function    IsValid : boolean;

        function  Get_Element(AIndex: integer): string;
        procedure Set_Element(AIndex: integer; const AValue: string); dynamic;
     published
        property RawxPL : string read Get_RawxPL write Set_RawxPL stored false;
     end;

     { TxPLDateTimeStamp }

     TxPLDateTimeStamp = class(TIdDateTimeStamp)
     private
       function GetAsRawxPL: string;
     published
        property RawxPL : string read GetAsRawxPL;
     end;

     function StreamToString(Stream : TStream) : String;
     function compareContents(msOne,msTwo:TMemoryStream):boolean ;

     function IsValidxPLIdent(const Ident: string): boolean;
     function xPLMatches(const aFilter: string; const aMessageElt: string): boolean;
     function xPLLevelToEventType(const aLevel : string) : TEventType;
     function EventTypeToxPLLevel(const aType : TEventType) : string;

     function MsgTypeToStr(const aMsgType : TxPLMessageType) : string;
     function StrToMsgType(const aString : string) : TxPLMessageType;

     function XPLDt2DateTime(const aDateTime : string) : TDateTime;
     function DateTime2XPLDt(const aDateTime : TDateTime) : string;

const K_DEFAULT_ONLINESTORE    = 'http://glh33.free.fr/?dl_name=clinique.xml';   // File where app versions are registered

var   LocalAddresses : TStringList;

implementation  //=============================================================
uses StrUtils
     , TypInfo
     , IdStack
     , DateUtils
     ;

// ============================================================================
const    K_LOG_INF = 'inf';
         K_LOG_WRN = 'wrn';
         K_LOG_ERR = 'err';

// ============================================================================
const K_LEN : Array [0..2] of integer = (8,8,16);                              // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
                                                                               // Compatible for both schema (8,8) and address (8,8,16)
// ============================================================================
function MsgTypeToStr(const aMsgType : TxPLMessageType) : string; inline;      // Takes cmnd, stat or trig and outputs xpl-cmnd...
begin
   result := K_MSG_TYPE_HEAD + GetEnumName(TypeInfo(TxPLMessageType),Ord(aMsgType));
end;

function StrToMsgType(const aString : string) : TxPLMessageType; inline;
var s : string;
begin
   s := AnsiRightStr(aString, length(aString) - 4);                             // Removes 'xpl-'
   result := TxPLMessageType(GetEnumValue(TypeInfo(TxPLMessageType), s));
end;

// ============================================================================
function compareContents(msOne,msTwo:TMemoryStream):boolean ;
var i:Integer;
    p1,p2:LongInt;
    buffer1,buffer2:Char;
begin
   result := false;
   if msOne.size <> msTwo.size then exit
   else try
        p1 := msOne.position; //temp storage for position
        msOne.position := 0; //start at the beginning
        p2 := msOne.position; //temp storage for position
        msTwo.position := 0; //start at the beginning
        for i := 0 to msOne.size-1 do
            begin
                 if (msOne.read(buffer1,sizeOf(buffer1)) <> (msTwo.read(buffer2,sizeOf(buffer2)))) then
                 exit;
                 if buffer1 <> buffer2 then exit;
            end;
            result := true;
        finally
               msOne.position := p1;
               msTwo.position := p2;
        end;
end;

// ============================================================================
// http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document :
// All structural elements of an xPL message, i.e. all header fields, schema
// class and type names, and the names of name/value pairs, must contain only
// the following characters: a-z, 0-9 and "-" (lower case letters, numbers and
// the hyphen/dash character -- ASCII 45).
function IsValidxPLIdent(const Ident: string): boolean;
var i, len: integer;
begin
   result := false;
   len := length(Ident);
   if len <> 0 then begin
      result := Ident[1] in ['a'..'z', '0'..'9'];
      i := 1;
      while (result) and (i < len) do begin
         inc(i);
         result := result and (Ident[i] in ['a'..'z', '0'..'9', '-']);
      end ;
   end ;
end ;

// ============================================================================
function xPLMatches(const aFilter: string; const aMessageElt: string): boolean;
var iFltElement : integer;
    sFlt, sMsg  : TStringList;
    //sFlt, sMsg : stringArray;                                                // Old method requires cStrings and cUtils
    //HeaderElementDelimiter : Set of Char = ['.'];

begin
   result := true;
//   sFlt := StrSplitChar(aFilter ,HeaderElementDelimiter);
//   sMsg := StrSplitChar(aMessageElt,HeaderElementDelimiter);

   sFlt := TStringList.Create;
   sFlt.Delimiter     :='.';
   sFlt.DelimitedText := aFilter;

   sMsg := TStringList.Create;
   sMsg.Delimiter     := sFlt.Delimiter;
   sMsg.DelimitedText := aMessageElt;                                          // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType

   Assert(sMsg.Count = sFlt.Count);
   //For iFltElement := 0 to High(sFlt) do
   For iFltElement := 0 to Pred(sFlt.Count) do
       if (sFlt[iFltElement]<>'*') then result := result and (sFlt[iFltElement]=sMsg[iFltElement]);

   sFlt.Free;
   sMsg.Free;
end;

function xPLLevelToEventType(const aLevel: string): TEventType;
begin
   Case AnsiIndexStr(aLevel,[K_LOG_INF,K_LOG_WRN,K_LOG_ERR]) of
        0 : result  := etInfo;
        1 : result  := etWarning;
        2 : result  := etError;
        else result := etInfo;
   end;
end;

function EventTypeToxPLLevel(const aType: TEventType): string;
begin
   Case aType of
        etInfo    : result := K_LOG_INF;
        etWarning : result := K_LOG_WRN;
        etError   : result := K_LOG_ERR;
        else result := K_LOG_INF;
   end;
end;

//==============================================================================
function StreamToString(Stream : TStream) : String;
var ms : TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result,PChar(ms.memory),ms.Size);
  finally
    ms.free;
  end;
end;

function DateTime2XPLDt(const aDateTime : TDateTime) : string;                   // Takes a standard delphi datetime
begin                                                                            //         and returns  20090729143000
   result := FormatDateTime('yyyymmddhhmmss',aDateTime);
end;

function XPLDt2DateTime(const aDateTime : string) : TDateTime;
var year, month, day, hour, minute, secs : integer;
begin
   year  := StrToInt(AnsiMidStr(aDateTime, 1, 4));
   month := StrToInt(AnsiMidStr(aDateTime, 5, 2));
   day   := StrToInt(AnsiMidStr(aDateTime, 7, 2));
   hour  := StrToInt(AnsiMidStr(aDateTime, 9, 2));
   minute:= StrToInt(AnsiMidStr(aDateTime, 11, 2));
   secs  := StrToInt(AnsiMidStr(aDateTime, 13, 2));

   result := EncodeDateTime( year, month, day, hour, minute, secs, 0);
end;

{ TxPLDateTimeStamp }

function TxPLDateTimeStamp.GetAsRawxPL: string;
begin
    Result := Format('%.4d%.2d%.2d%.2d%.2d%.2d',
           [year,monthofYear,dayofmonth,HourOf24Day,MinuteOfHour,SecondOfMinute]);
end;

// TxPLRawSet =================================================================
constructor TxPLRawSet.Create;
begin
   inherited Create;
   fRawxPL := TStringList.Create;
   fRawxPL.Delimiter:='.';
   ResetValues;
end;

destructor TxPLRawSet.Destroy;
begin
   fRawxPL.Free;
   inherited Destroy;
end;

procedure TxPLRawSet.Assign(aRawSet: TPersistent);
begin
  if aRawSet is TxPLRawSet
     then fRawxPL.Assign(TxPLRawSet(aRawSet).fRawxPL)
     else inherited;
end;

function TxPLRawSet.Equals(const aRawSet: TxPLRawSet): boolean;
begin
   result := fRawxPL.Equals(aRawSet.fRawxPL);
end;

function TxPLRawSet.IsValid: boolean;
var s : string;
begin
   Result := True;
   for s in fRawxPL do
       Result := Result and IsValidxPLIdent(s);
end;

function TxPLRawSet.Get_Element(AIndex: integer): string;
begin
   result := fRawxPL[aIndex];
end;

procedure TxPLRawSet.Set_Element(AIndex: integer; const AValue: string);
begin
  if ((length(aValue) <= K_LEN[aIndex]) and IsValidxPLIdent(aValue)) then
     fRawxPL[aIndex] := aValue;
end;

var i : integer;
initialization // =============================================================
   LocalAddresses := TStringList.Create;
   // Cette version utilise la librairie Synapse mais pose un problème pour les
   // Versions console des applications car les unités synamisc et synaip appellent
   // Windows
   //LocalAddresses.Delimiter := ',';
   //LocalAddresses.DelimitedText := GetLocalIPs;                                // This procedure also retrieves IPv6
   //i := LocalAddresses.Count-1;                                                // Addresses, then I have to clean
   //while (i>=0) do begin                                                       // the list to present only IPv4 addresses
   //   if not IsIP(LocalAddresses[i]) then LocalAddresses.Delete(i);
   //   dec(i);
   //end;

   // Cette version utilise la librairie Indy, à tester pour bon fonctionnement
   // entre version console et gui...
   TIdStack.IncUsage;
   for i:=0 to Pred(GStack.LocalAddresses.Count) do
      LocalAddresses.Add(GStack.LocalAddresses[i]);

finalization // ===============================================================
   LocalAddresses.Free;

end.

