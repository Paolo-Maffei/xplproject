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

{$i xpl.inc}
{$M+}

interface

uses Classes
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

var  // Core xPL Schema ======================================================
     Schema_ConfigApp,
     Schema_ConfigCurr,
     Schema_DDBasic,
     Schema_DDRequest,
     Schema_ConfigList,
     Schema_ConfigResp,
     Schema_HBeatApp,
     Schema_HBeatEnd,
     Schema_HBeatReq,
     Schema_FragBasic,
     Schema_FragReq : TxPLSchema;

implementation // =============================================================
uses SysUtils
     , u_xpl_common
     ;

// TxPLSchema Object ==========================================================
constructor TxPLSchema.Create(const aClasse : string = ''; const aType : string = '');
begin
   inherited Create;
   fMaxSizes := IntArray.Create(8,8);
   ResetValues;
   if aClasse<>'' then Classe := aClasse;
   if aType<>''   then Type_  := aType;
end;

function TxPLSchema.IsHBeat: boolean;
begin
   Result := (Classe = 'hbeat');
end;

function TxPLSchema.IsConfig: boolean;
begin
   Result := (Classe = 'config');
end;

function TxPLSchema.IsFragment: boolean;
begin
   Result := (Classe = 'fragment');
end;

initialization // =============================================================
   Classes.RegisterClass(TxPLSchema);

   Schema_ConfigApp  := TxPLSchema.Create('config','app');
   Schema_HBeatApp   := TxPLSchema.Create('hbeat','app');
   Schema_HBeatEnd   := TxPLSchema.Create('hbeat','end');
   Schema_HBeatReq   := TxPLSchema.Create('hbeat','request');
   Schema_ConfigCurr := TxPLSchema.Create('config','current');
   Schema_ConfigList := TxPLSchema.Create('config','list');
   Schema_ConfigResp := TxPLSchema.Create('config','response');
   Schema_FragBasic  := TxPLSchema.Create('fragment','basic');
   Schema_FragReq    := TxPLSchema.Create('fragment','request');
   Schema_DDBasic    := TxPLSchema.Create('dawndusk','basic');
   Schema_DDRequest  := TxPLSchema.Create('dawndusk','request');

finalization // ===============================================================
   Schema_ConfigApp.Free;
   Schema_ConfigCurr.Free;
   Schema_ConfigList.Free;
   Schema_ConfigResp.Free;
   Schema_HBeatApp.Free;
   Schema_HBeatEnd.Free;
   Schema_HBeatReq.Free;
   Schema_FragBasic.Free;
   Schema_FragReq.Free;
   Schema_DDBasic.Free;
   Schema_DDRequest.Free;

end.