unit u_xml_events;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM;

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

     TXMLeventsType = class(TDOMElementList)
     private
        function Get_Event(Index: Integer): TXMLEventType;
     public
        constructor Create(ANode: TDOMNode); overload;
        property Event[Index: Integer]: TXMLEventType read Get_Event ; default;
     end;

var eventsfile : TXMLeventsType;

implementation //=========================================================================
uses XMLRead;
var document : TXMLDocument;
//========================================================================================


{ TXMLEventType }


function TXMLEventType.Get_dow: AnsiString;
begin Result := Attributes.GetNamedItem('dow').NodeValue; end;

function TXMLEventType.Get_End_Time: AnsiString;
begin Result := Attributes.GetNamedItem('endtime').NodeValue; end;

function TXMLEventType.Get_EventDateTime: ansistring;
begin Result := Attributes.GetNamedItem('eventdatetime').NodeValue; end;

function TXMLEventType.Get_EventRunTime: ansistring;
begin Result := Attributes.GetNamedItem('eventruntime').NodeValue; end;

function TXMLEventType.Get_Init: ansistring;
begin Result := Attributes.GetNamedItem('init').NodeValue; end;

function TXMLEventType.Get_interval: ansistring;
begin Result := Attributes.GetNamedItem('interval').NodeValue; end;

function TXMLEventType.Get_Param: ansistring;
begin Result := Attributes.GetNamedItem('param').NodeValue; end;

function TXMLEventType.Get_randomtime: ansistring;
begin Result := Attributes.GetNamedItem('randomtime').NodeValue; end;

function TXMLEventType.Get_recurring: ansistring;
begin Result := Attributes.GetNamedItem('recurring').NodeValue; end;

function TXMLEventType.Get_runsub: ansistring;
begin Result := Attributes.GetNamedItem('runsub').NodeValue; end;

function TXMLEventType.Get_Start_Time: AnsiString;
begin Result := Attributes.GetNamedItem('starttime').NodeValue; end;

function TXMLEventType.Get_Tag: AnsiString;
begin Result := Attributes.GetNamedItem('tag').NodeValue; end;

{ TXMLeventsType }

function TXMLeventsType.Get_Event(Index: Integer): TXMLEventType;
begin
  Result := TXMLEventType(Item[Index]);
end;



constructor TXMLeventsType.Create(ANode: TDOMNode);
begin
   inherited Create(aNode,'event');
end;

// Unit initialization ===================================================================
initialization
   document := TXMLDocument.Create;
   ReadXMLFile(document,'C:\Program Files\xPL\xPLHal 2.0 for Windows\data\xplhal_events.xml');
   eventsfile := TXMLeventsType.Create(Document.FirstChild);

finalization
   eventsfile.destroy;
   document.destroy;

end.

