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

uses Classes
     , u_xpl_common
     , u_xpl_rawset
     ;

type // TxPLSchema ============================================================
     TxPLSchema = class(TxPLRawSet)
     public
        Constructor Create(const aClasse : string = ''; const aType : string = ''); reintroduce;

        function IsHBeat    : boolean;
        function IsConfig   : boolean;
        function IsFragment : boolean;
     published
        property Classe : string index 0 read Get_Element write Set_Element;
        property Type_  : string index 1 read Get_Element write Set_Element;
     end;

var  // Some widely used schema ===============================================
     Schema_ConfigApp,
     Schema_ConfigCurr,
     Schema_ConfigList,
     Schema_ConfigResp,
     Schema_HBeatApp,
     Schema_HBeatEnd,
     Schema_ControlBasic,
     Schema_TimerBasic,
     Schema_LogBasic,
     Schema_OsdBasic,
     Schema_HBeatReq,
     Schema_FragBasic,
     Schema_FragReq : TxPLSchema;

implementation // =============================================================
uses SysUtils
     , u_xpl_address
     ;

// TxPLSchema Object ==========================================================
constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
   inherited Create;
   SetLength(fMaxSizes,2);
   fMaxSizes[0] := 8;
   fMaxSizes[1] := 8;
   ResetValues;
   if aClasse<>'' then Classe := aClasse;
   if aType<>''   then Type_  := aType;
end;

function TxPLSchema.IsHBeat: boolean;
begin
   Result := (Classe = 'config');
end;

function TxPLSchema.IsConfig: boolean;
begin
   Result := (Classe = 'hbeat');
end;

function TxPLSchema.IsFragment: boolean;
begin
   Result := Equals(Schema_FragBasic);
end;

// ============================================================================
initialization
   Classes.RegisterClass(TxPLSchema);

   Schema_ConfigApp    := TxPLSchema.Create('config','app');
   Schema_HBeatApp     := TxPLSchema.Create('hbeat','app');
   Schema_HBeatEnd     := TxPLSchema.Create('hbeat','end');
   Schema_HBeatReq     := TxPLSchema.Create('hbeat','request');
   Schema_ConfigCurr   := TxPLSchema.Create('config','current');
   Schema_ConfigList   := TxPLSchema.Create('config','list');
   Schema_ConfigResp   := TxPLSchema.Create('config','response');
   Schema_ControlBasic := TxPLSchema.Create('control','basic');
   Schema_TimerBasic   := TxPLSchema.Create('timer','basic');
   Schema_OsdBasic     := TxPLSchema.Create('osd','basic');
   Schema_LogBasic     := TxPLSchema.Create('log','basic');
   Schema_FragBasic    := TxPLSchema.Create('fragment','basic');
   Schema_FragReq      := TxPLSchema.Create('fragment','request');

end.

