unit u_xml_xplplugin_ex;
{==============================================================================
  UnitName      = u_xml_xplplugin_ex
  UnitDesc      = Extended classes to handle xml files
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 This unit was created to circumvent cross references between base xPL  objects
 and base XML file handling classes units contained in u_xml_xplplugin.
 It is designed to perform higher level of abstraction on the data
 v 0.5 : initial version
}

{$mode objfpc}{$H+}

interface

uses
  Classes,
  u_xml_xplplugin,
  uxplmsgbody,
  uxplschema;

type

   { TXMLCommandType }

   TXMLCommandTypeEx = class(TXMLCommandType)
   private
      function Get_Schema: TxPLSchema;
   published
      property Schema  : TxPLSchema read Get_Schema;
   end;

  TXMLSchemaTypeEx   = class(TXMLSchemaType)
     function Get_Schema: TxPLSchema;
  published
     property Schema  : TxPLSchema read Get_Schema;
  end;

  { TXMLMenuItemTypeEx }

  TXMLMenuItemTypeEx = class(TXMLMenuItemType)
     function Get_Body: TxPLMsgBody;
     function Get_Schema: TxPLSchema;
  public
     procedure Set_Schema(const aValue : string);
     procedure Set_Body  (const aValue : string);
  published
     property Schema : TxPLSchema read Get_Schema;
     property Body   : TxPLMsgBody read Get_Body;
  end;

implementation
uses uxPLMessage,
     uxPLConst,
     SysUtils;

{ TXMLMenuItemTypeEx }

function TXMLMenuItemTypeEx.Get_Body: TxPLMsgBody;
var aMsg : TxPLMessage;
begin
     aMsg := TxPLMessage.Create;
     aMsg.RawXPL:= Format(K_MSG_HEADER_FORMAT,[K_MSG_TYPE_CMND,0,K_MSG_HEADER_DUMMY,K_MSG_TARGET_ANY,xPLMsg]);
     result := TxPLMsgBody.Create;
     result.Assign(aMsg.Body);
     aMsg.Destroy;
end;

function TXMLMenuItemTypeEx.Get_Schema: TxPLSchema;
var aMsg : TxPLMessage;
begin
     aMsg := TxPLMessage.Create;
     aMsg.RawXPL:= Format(K_MSG_HEADER_FORMAT,[K_MSG_TYPE_CMND,0,K_MSG_HEADER_DUMMY,K_MSG_TARGET_ANY,xPLMsg]);
     result := TxPLSchema.Create;
     result.Assign(aMsg.Schema);
     aMsg.Destroy;
end;

procedure TXMLMenuItemTypeEx.Set_Body(const AValue: string);
var aSchema : TxPLSchema;
begin
   aSchema := Schema;
   xPLMsg := aSchema.Tag + #10 + aValue;
   aSchema.Destroy;
end;

procedure TXMLMenuItemTypeEx.Set_Schema(const AValue: string);
var aBody   : TxPLMsgBody;
begin
   aBody := Body;
   xPLMsg := aValue + #10 + aBody.RawxPL;
   aBody.Destroy;
end;


{ TXMLSchemaTypeEx }

function TXMLSchemaTypeEx.Get_Schema: TxPLSchema;
begin
   result := TxPLSchema.Create;
   result.Tag:= Name;
end;

{ TXMLCommandType }

function TXMLCommandTypeEx.Get_Schema: TxPLSchema;
begin
   result := TxPLSchema.Create;
   result.Tag:= msg_schema;
end;

end.
