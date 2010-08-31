unit u_xml_globals;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, DOM,u_xml;

type

{ TXMLglobalType }

     TXMLglobalType = class(TDOMElement)
     private
       function Get_Comment: AnsiString;
       function Get_CreateTS: TDateTime;
        function Get_Expires: Boolean;
        function Get_ExpireTS: TDateTime;
        function Get_Former: AnsiString;
        function Get_LastUpdate: TDateTime;
        function Get_Name: AnsiString;
        function Get_Value: AnsiString;
        procedure Set_Comment(const AValue: AnsiString);
        procedure Set_CreateTS(const AValue: TDateTime);
        procedure Set_Expires(const AValue: Boolean);
        procedure Set_ExpireTS(const AValue: TDateTime);
        procedure Set_Former(const AValue: AnsiString);
        procedure Set_LastUpdate(const AValue: TDateTime);
        procedure Set_Name(const AValue: AnsiString);
        procedure Set_Value(const AValue: AnsiString);
     public
        procedure Remove;
        property Name : AnsiString read Get_Name write Set_Name;
        property Value : AnsiString read Get_Value write Set_Value;
        property LastUpdate : TDateTime read Get_LastUpdate write Set_LastUpdate;
        property Expires : Boolean read Get_Expires write Set_Expires;
        property Former  : AnsiString read Get_Former write Set_Former;
        property Comment  : AnsiString read Get_Comment write Set_Comment;
        property CreateTS : TDateTime read Get_CreateTS write Set_CreateTS;
        property ExpireTS : TDateTime read Get_ExpireTS write Set_ExpireTS;
     end;

     TXMLGlobalsType = specialize TXMLElementList<TXMLGlobalType>;

implementation //=========================================================================
uses XMLRead, XMLWrite, uxPLConst, StrUtils, cDateTime, cStrings;

// TXMLGlobalType ========================================================================

function TXMLglobalType.Get_Comment: AnsiString;
begin Result := GetAttribute(K_XML_STR_COMMENT); end;

function TXMLglobalType.Get_CreateTS: TDateTime;
var s : string;
begin
   s := GetAttribute(K_XML_STR_CREATE);
   if s<>'' then result := StrToDateTime(s);
end;

function TXMLGlobalType.Get_Expires: Boolean;
begin Result := (GetAttribute(K_XML_STR_Expires)=K_STR_TRUE) end;

function TXMLglobalType.Get_ExpireTS: TDateTime;
var s : string;
begin
   s := GetAttribute(K_XML_STR_EXPIRE);
   if s<>'' then result := StrToDateTime(s);
end;

function TXMLglobalType.Get_Former: AnsiString;
begin Result := GetAttribute(K_XML_STR_FORMER);end;

function TXMLGlobalType.Get_LastUpdate: TDateTime;                                        // Input field is formed like that : 2010-08-17T15:08:28.9063908+02:00
var str : string;
begin
   Str := Attributes.GetNamedItem(K_XML_STR_Lastupdate).NodeValue;
   Str := AnsiLeftStr( Str, AnsiPos( '.', Str)-1);                                        // Cut before '.'
   Str := StrRemoveChar( Str, '-');                                                       // Remove '-' char
   Result := ISO8601StringAsDateTime(Str);
end;

function TXMLGlobalType.Get_Name: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Name).NodeValue; end;

function TXMLGlobalType.Get_Value: AnsiString;
begin Result := Attributes.GetNamedItem(K_XML_STR_Value).NodeValue; end;

procedure TXMLglobalType.Set_Comment(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_COMMENT,AValue); end;

procedure TXMLglobalType.Set_CreateTS(const AValue: TDateTime);
begin SetAttribute(K_XML_STR_CREATE, DateTimeToStr(aValue)); end;

procedure TXMLglobalType.Set_Expires(const AValue: Boolean);
begin SetAttribute(K_XML_STR_Expires,IfThen(aValue, K_STR_TRUE, K_STR_FALSE)); end;

procedure TXMLglobalType.Set_ExpireTS(const AValue: TDateTime);
begin SetAttribute(K_XML_STR_EXPIRE, DateTimeToStr(aValue)); end;

procedure TXMLglobalType.Set_Former(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_FORMER, aValue); end;

procedure TXMLglobalType.Set_LastUpdate(const AValue: TDateTime);                        // Restore 'a kind of' original formatting
begin
      SetAttribute(K_XML_STR_Lastupdate, FormatDateTime('yyyy-mm-dd',aValue) + 'T' +
                                         FormatDateTime('hh:mm:ss.00+00:00',aValue));
end;

procedure TXMLglobalType.Set_Name(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Name,AValue);  end;

procedure TXMLglobalType.Set_Value(const AValue: AnsiString);
begin SetAttribute(K_XML_STR_Value,AValue); end;

procedure TXMLglobalType.Remove;
begin
   ParentNode.RemoveChild(self);
end;

end.

