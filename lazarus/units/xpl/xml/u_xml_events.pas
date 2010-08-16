unit u_xml_events;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM, u_xml;

type

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
  function Get_recurring: ansistring;
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
        property recurring : ansistring read Get_recurring;
        property interval : ansistring read Get_interval;
        property runsub : ansistring read Get_runsub;
        property param : ansistring read Get_Param;
        property eventdatetime : ansistring read Get_EventDateTime;
        property eventruntime : ansistring read Get_EventRunTime;
        property init : ansistring read Get_Init;
     end;
     TXMLEventsType = specialize TXMLElementList<TXMLEventType>;

var eventsfile : TXMLeventsType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
//========================================================================================
function TXMLEventType.Get_dow: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Dow).NodeValue; end;

function TXMLEventType.Get_End_Time: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Endtime).NodeValue; end;

function TXMLEventType.Get_EventDateTime: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Eventdatetim).NodeValue; end;

function TXMLEventType.Get_EventRunTime: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Eventruntime).NodeValue; end;

function TXMLEventType.Get_Init: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Init).NodeValue; end;

function TXMLEventType.Get_interval: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Interval).NodeValue; end;

function TXMLEventType.Get_Param: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Param).NodeValue; end;

function TXMLEventType.Get_randomtime: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Randomtime).NodeValue; end;

function TXMLEventType.Get_recurring: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Recurring).NodeValue; end;

function TXMLEventType.Get_runsub: ansistring;
begin Result := Attributes.GetNamedItem(K_XML_STR_Runsub).NodeValue; end;

function TXMLEventType.Get_Start_Time: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Starttime).NodeValue; end;

function TXMLEventType.Get_Tag: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Tag).NodeValue; end;

// Unit initialization ===================================================================
initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\xplhal_events.xml');
   eventsfile := TXMLeventsType.Create(Document.FirstChild, K_XML_STR_Event);

finalization
   eventsfile.destroy;
   document.destroy;

end.

