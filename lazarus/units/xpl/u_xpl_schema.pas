unit u_xPL_Schema;
{==============================================================================
  UnitDesc      = xPL Schema object management
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.00 : Removed usage of symbolic constants
 1.01 : Added default value initialisation
        Renamed Tag property to RawxPL
 3.00 : Descendent from TPersistent
}

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes,
     u_xpl_common;

type TxPLSchema = class(TxPLRawSet)
     private
        procedure Set_RawxPL (const aValue : string);
        function  Get_RawxPL : string;

     public
        Constructor Create(const aClasse : string = ''; const aType : string = ''); reintroduce;
        procedure   ResetValues; override;

        function    AsFilter : string; dynamic;

     published
        property Classe : string index 0 read Get_Element write Set_Element;
        property Type_  : string index 1 read Get_Element write Set_Element;
        property RawxPL : string read Get_RawxPL write Set_RawxPL stored false;
     end;

     Operator := (t1 : string) t2 : TxPLSchema;

var  Schema_ConfigApp,
     Schema_ConfigCurr,
     Schema_ConfigList,
     Schema_ConfigResp,
     Schema_HBeatApp,
     Schema_HBeatEnd,
     Schema_ControlBasic,
     Schema_TimerBasic,
     Schema_HBeatReq : TxPLSchema;

const K_SCHEMA_CLASS_HBEAT    = 'hbeat';
      K_SCHEMA_CLASS_CONFIG   = 'config';
      K_SCHEMA_SENSOR_BASIC   = 'sensor.basic';
      K_SCHEMA_SENSOR_REQUEST = 'sensor.request';
      K_SCHEMA_OSD_BASIC      = 'osd.basic';
      K_SCHEMA_LOG_BASIC      = 'log.basic';
      K_SCHEMA_TTS_BASIC      = 'tts.basic';
      K_SCHEMA_MEDIA_BASIC    = 'media.basic';
      K_SCHEMA_NETGET_BASIC   = 'netget.basic';
      K_SCHEMA_X10_BASIC      = 'x10.basic';

implementation // =============================================================
uses SysUtils
     , u_xpl_address
     , StrUtils
     ;

const // ======================================================================
     K_FMT_FILTER = '%s.%s';

// ============================================================================
operator:=(t1: string)t2: TxPLSchema;
begin
   t2 := TxPLSchema.Create;
   t2.RawxPL := t1;
end;

// TxPLSchema Object ==========================================================
constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
   inherited Create;
   Classe := aClasse;
   Type_  := aType;
end;

procedure TxPLSchema.ResetValues;
begin
   fRawxPL.DelimitedText:='.';
end;

function TxPLSchema.Get_RawxPL: string;
begin
   result := fRawxPL.DelimitedText;
end;

procedure TxPLSchema.Set_RawxPL(const aValue: string);
begin
   fRawxPL.DelimitedText:=aValue;
end;

function TxPLSchema.AsFilter : string;
begin
   Result := Format(K_FMT_FILTER,[ IfThen( Classe <>'', Classe , K_ADDR_ANY_TARGET),
                                   IfThen( Type_  <>'', Type_  , K_ADDR_ANY_TARGET)]);
end;

// ============================================================================
initialization
   Classes.RegisterClass(TxPLSchema);

   Schema_ConfigApp    := 'config.app';
   Schema_HBeatApp     := 'hbeat.app';
   Schema_HBeatEnd     := 'hbeat.end';
   Schema_HBeatReq     := 'hbeat.request';
   Schema_ConfigCurr   := 'config.current';
   Schema_ConfigList   := 'config.list';
   Schema_ConfigResp   := 'config.response';
   Schema_ControlBasic := 'control.basic';
   Schema_TimerBasic   := 'timer.basic';
end.

