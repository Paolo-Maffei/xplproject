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
      MAX_KEY_LEN   = 16;                                                      // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
      MAX_VALUE_LEN = 1400;                                                    // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document


Type TInstanceInitStyle = (iisRandom, iisHostName, iisMacAddress);

     IntArray = array of integer;
     StrArray = array of string;

     TStrParamEvent = procedure(const aString : string) of object;
     TNoParamEvent  = procedure of object;

     TxPLMessageType = (cmnd, stat, trig, any);

     IxPLCommon = Interface(IInterface)
        procedure  Assign(aSchema : TPersistent);
        function   IsValid : boolean;
        procedure  ResetValues;
     end;

     IxPLRaw = Interface(IInterface)
        procedure Set_RawxPL (const aValue : string);
        function  Get_RawxPL : string;
        property RawxPL : string read Get_RawxPL write Set_RawxPL;
     end;

     { TxPLDateTimeStamp }

     TxPLDateTimeStamp = class(TIdDateTimeStamp)
     private
       function GetDateTime: TDateTime; reintroduce;
       function GetAsRawxPL: string;
     published
        property RawxPL : string read GetAsRawxPL;
        property DateTime : TDateTime read GetDateTime;
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

     procedure StreamObjectToFile(const aFileName : string; const aObject : TComponent);
     procedure ReadObjectFromFile(const aFileName : string; const aObject : TComponent);

     function GetVendorNameEvent : string;
     function GetApplicationEvent : string;

const K_DEFAULT_ONLINESTORE    = 'http://glh33.free.fr/?dl_name=clinique.xml'; // File where app versions are registered
      XPL_UDP_BASE_PORT     : Integer = 3865;                                  // Port used by devices to send messages
      XPL_MAX_MSG_SIZE      : Integer = 1500;                                  // Maximum size of a xpl message
      XPL_MIN_PORT = 50000;                                                    // First port used to try to open the listening port
      XPL_MAX_PORT = 50512;                                                    // Max port used to try to open the listening port
      K_MSG_HEADER_FORMAT = '%s'#10'{'#10'hop=%u'#10'source=%s'#10'target=%s'#10'}'#10'%s'#10;

implementation  //=============================================================
uses StrUtils
     , TypInfo
     , DateUtils
     ;

// ============================================================================
const    K_LOG_INF = 'inf';
         K_LOG_WRN = 'wrn';
         K_LOG_ERR = 'err';

// ============================================================================
//const K_LEN : Array [0..2] of integer = (8,8,16);                            // xPL Rule : http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document
                                                                               // Compatible for both schema (8,8) and address (8,8,16)
// ============================================================================

function MsgTypeToStr(const aMsgType : TxPLMessageType) : string; inline;      // Takes cmnd, stat or trig and outputs xpl-cmnd...
begin
   if aMsgType = any
      then result := '*'
      else result := K_MSG_TYPE_HEAD + GetEnumName(TypeInfo(TxPLMessageType),Ord(aMsgType));
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
   buffer1:= #0;
   buffer2:= buffer1;
   if msOne.size = msTwo.size then begin
      p1 := msOne.position; //temp storage for position
      p2 := msOne.position; //temp storage for position
      try
        msOne.position := 0; //start at the beginning
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
begin
   result := true;

   sFlt := TStringList.Create;
   sFlt.Delimiter     :='.';
   sFlt.DelimitedText := aFilter;

   sMsg := TStringList.Create;
   sMsg.Delimiter     := sFlt.Delimiter;
   sMsg.DelimitedText := aMessageElt;                                          // a string like :  aMsgType.aVendor.aDevice.aInstance.aClass.aType

   Assert(sMsg.Count = sFlt.Count);
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

procedure StreamObjectToFile(const aFileName: string; const aObject: TComponent);
var fStream: TFileStream;
    mStream: TMemoryStream;
begin
   mStream := TMemoryStream.Create;
   fStream := TFileStream.Create(aFileName, fmCreate);
   try
      mStream.WriteComponent(aObject);
      mStream.position := 0;
      ObjectBinaryToText(mStream, fStream);
   finally
     mStream.Free;
     fStream.Free;
   end;
end;

procedure ReadObjectFromFile(const aFileName: string; const aObject: TComponent);
var fStream: TFileStream;
    mStream: TMemoryStream;
begin
    fStream := TFileStream.Create(aFileName, fmOpenRead);
    if fStream.Size > 0 then begin
          mStream := TMemoryStream.Create;
          ObjectTextToBinary(fStream,mStream);
          mStream.Position := 0;
          mStream.ReadComponent(aObject);
          mStream.Free;
    end;
    fStream.Free;
end;

function GetVendorNameEvent: string;
begin
   result := '';
end;

function GetApplicationEvent : string;
begin
   result := 'xPL';
end;

function XPLDt2DateTime(const aDateTime : string) : TDateTime;
var year, month, day, hour, minute, secs : integer;
begin
   result := 0;
   if length(aDateTime) < 14 then exit;

   year  := StrToInt(AnsiMidStr(aDateTime, 1, 4));
   month := StrToInt(AnsiMidStr(aDateTime, 5, 2));
   day   := StrToInt(AnsiMidStr(aDateTime, 7, 2));
   hour  := StrToInt(AnsiMidStr(aDateTime, 9, 2));
   minute:= StrToInt(AnsiMidStr(aDateTime, 11, 2));
   secs  := StrToInt(AnsiMidStr(aDateTime, 13, 2));

   result := EncodeDateTime( year, month, day, hour, minute, secs, 0);
end;

{ TxPLDateTimeStamp }

function TxPLDateTimeStamp.GetDateTime: TDateTime;
begin
   result := XPLDt2DateTime(RawxPL);
end;

function TxPLDateTimeStamp.GetAsRawxPL: string;
begin
    Result := Format('%.4d%.2d%.2d%.2d%.2d%.2d',
           [year,monthofYear,dayofmonth,HourOf24Day,MinuteOfHour,SecondOfMinute]);
end;

end.
