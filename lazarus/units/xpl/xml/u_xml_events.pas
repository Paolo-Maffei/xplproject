unit u_xml_events;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, u_xml;

type

{ TXMLTimerType }
     TXMLTimerMode = (tmUp, tmDown, tmRecurrent);

     TXMLTimerType = class(TDOMElement)
     private
        function Get_Estimated_End_Time: TDateTime;
        function Get_Frequency: cardinal;
        function Get_Mode: TXMLTimerMode;
        function Get_Range: string;
        function Get_Remaining: cardinal;
        function Get_start_time: TDateTime;
        function Get_Status: string;
        function Get_Tag: AnsiString;
        function Get_Target: string;
        procedure Set_Estimated_End_Time(const AValue: TDateTime);
        procedure Set_Frequency(const AValue: cardinal);
        procedure Set_Mode(const AValue: TXMLTimerMode);
        procedure Set_Remaining(const AValue: cardinal);
        procedure Set_start_time(const AValue: TDateTime);
        procedure Set_Status(const AValue: string);
        procedure Set_Tag(const AValue: AnsiString);
        procedure Set_Target(const AValue: string);
     public
        property Target : string read Get_Target write Set_Target;
        property start_time : TDateTime read Get_start_time write Set_start_time;
        property Remaining : cardinal read Get_Remaining write Set_Remaining;
        property Status    : string read Get_Status      write Set_Status;
        property Mode      : TXMLTimerMode read Get_Mode write Set_Mode;
        function ModeAsString : string;
        property Frequency : cardinal read Get_Frequency write Set_Frequency;
        property Estimated_End_Time : TDateTime read Get_Estimated_End_Time write Set_Estimated_End_Time;
        property Range     : string read Get_Range;
        property Name : AnsiString read Get_Tag write Set_Tag;
     end;

     TXMLTimersType = specialize TXMLElementList<TXMLTimerType>;

{ TXMLEventType }

TXMLEventType = class(TDOMElement)
private
  function Get_dow: AnsiString;
  function Get_End_Time: AnsiString;
  function Get_EventDateTime: ansistring;
  function Get_EventRunTime: ansistring;
  function Get_Init: ansistring;
  function Get_interval: ansistring;
  function Get_Param: ansistring;
  function Get_randomtime: ansistring;
  function Get_recurring: boolean;
  function Get_runsub: ansistring;
  function Get_Start_Time: AnsiString;
  function Get_Tag: AnsiString;
     protected
     public
        property tag : AnsiString read Get_Tag;
        property start_time : AnsiString read Get_Start_Time;
        property end_time : AnsiString read Get_End_Time;
        property dow : AnsiString read Get_dow;
        property randomtime : ansistring read Get_randomtime;
        property recurring : boolean read Get_recurring;
        property interval : ansistring read Get_interval;
        property runsub : ansistring read Get_runsub;
        property param : ansistring read Get_Param;
        property eventdatetime : ansistring read Get_EventDateTime;
        property eventruntime : ansistring read Get_EventRunTime;
        property init : ansistring read Get_Init;
     end;
     TXMLEventsType = specialize TXMLElementList<TXMLEventType>;

var Eventsfile : TXMLeventsType;

implementation //=========================================================================
uses XMLRead, XMLWrite,uxPLConst;
var document : TXMLDocument;
//========================================================================================
function TXMLEventType.Get_dow: AnsiString;
begin Result := GetAttribute(K_XML_STR_Dow); end;

function TXMLEventType.Get_End_Time: AnsiString;
begin Result := GetAttribute(K_XML_STR_Endtime); end;

function TXMLEventType.Get_EventDateTime: ansistring;
begin Result := GetAttribute(K_XML_STR_Eventdatetim); end;

function TXMLEventType.Get_EventRunTime: ansistring;
begin Result := GetAttribute(K_XML_STR_Eventruntime); end;

function TXMLEventType.Get_Init: ansistring;
begin Result := GetAttribute(K_XML_STR_Init); end;

function TXMLEventType.Get_interval: ansistring;
begin Result := GetAttribute(K_XML_STR_Interval); end;

function TXMLEventType.Get_Param: ansistring;
begin Result := GetAttribute(K_XML_STR_Param); end;

function TXMLEventType.Get_randomtime: ansistring;
begin Result := GetAttribute(K_XML_STR_Randomtime); end;

function TXMLEventType.Get_recurring: boolean;
begin Result := GetAttribute(K_XML_STR_Recurring)=K_STR_TRUE; end;

function TXMLEventType.Get_runsub: ansistring;
begin Result := GetAttribute(K_XML_STR_Runsub); end;

function TXMLEventType.Get_Start_Time: AnsiString;
begin Result := GetAttribute(K_XML_STR_Starttime); end;

function TXMLEventType.Get_Tag: AnsiString;
begin Result := GetAttribute(K_XML_STR_Tag); end;

// Unit initialization ===================================================================

{ TXMLTimerType }

function TXMLTimerType.Get_Estimated_End_Time: TDateTime;
begin Result := StrToDateTime(GetAttribute(K_XML_STR_ESTIMATED_END_TIME)); end;

function TXMLTimerType.Get_Frequency: cardinal;
begin Result := StrToInt(GetAttribute(K_XML_STR_FREQUENCY)); end;

function TXMLTimerType.Get_Mode: TXMLTimerMode;
begin Result := TXMLTimerMode(GetAttribute(K_XML_STR_MODE)); end;

function TXMLTimerType.Get_Range: string;
begin if Target = '*' then result := 'global' else result := 'local'; end;

function TXMLTimerType.Get_Remaining: cardinal;
begin Result := StrToInt(GetAttribute(K_XML_STR_REMAINING)); end;

function TXMLTimerType.Get_start_time: TDateTime;
begin Result := StrToDateTime(GetAttribute(K_XML_STR_Starttime)); end;

function TXMLTimerType.Get_Status: string;
begin Result := GetAttribute(K_XML_STR_Status); end;

function TXMLTimerType.Get_Tag: AnsiString;
begin Result := GetAttribute(K_XML_STR_Tag); end;

function TXMLTimerType.Get_Target: string;
begin Result := GetAttribute(K_XML_STR_Msg_target); end;

procedure TXMLTimerType.Set_Estimated_End_Time(const AValue: TDateTime);
begin SetAttribute(K_XML_STR_ESTIMATED_END_TIME, DateTimeToStr(aValue)); end;

procedure TXMLTimerType.Set_Frequency(const AValue: cardinal);
begin SetAttribute(K_XML_STR_FREQUENCY, IntToStr(aValue)); end;

procedure TXMLTimerType.Set_Mode(const AValue: TXMLTimerMode);
begin SetAttribute(K_XML_STR_MODE, IntToStr(Ord(aValue))); end;

procedure TXMLTimerType.Set_Remaining(const AValue: cardinal);
begin SetAttribute(K_XML_STR_REMAINING, IntToStr(aValue)); end;

procedure TXMLTimerType.Set_start_time(const AValue: TDateTime);
begin SetAttribute(K_XML_STR_Starttime, DateTimeToStr(aValue)); end;

procedure TXMLTimerType.Set_Status(const AValue: string);
begin SetAttribute(K_XML_STR_Status, aValue); end;

procedure TXMLTimerType.Set_Tag(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_TAG, aValue); end;

procedure TXMLTimerType.Set_Target(const AValue: string);
begin SetAttribute(K_XML_STR_Msg_target, aValue); end;

function TXMLTimerType.ModeAsString: string;
begin
  case Mode of
       tmUp : result := 'ascending';
       tmDown : result := 'descending';
       tmRecurrent : result := 'recurrent';
  end;
end;


//initialization
//   document := TXMLDocument.Create;
//   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\xplhal_events.xml');
//   eventsfile := TXMLeventsType.Create(document, K_XML_STR_Global);
//
//finalization
//   WriteXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\xplhal_events.xml');
//   eventsfile.destroy;
//   document.destroy;

end.

