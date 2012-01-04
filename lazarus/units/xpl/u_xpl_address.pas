unit u_xpl_address;
{==============================================================================
  UnitName      = uxPLAddress
  UnitDesc      = xPL Schema management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added descendants source and target addresses
 0.96 : Some filter related functions added
 0.99 : Added HostNmInstance
 1.02 : Added default value initialisation. Renamed Tag property to RawxPL
 1.03 : Host named instance can not handled the same way between linux and win : dropped
 3.00 : Inherits from TPersistent
}

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes
     , u_xpl_common
     , u_xpl_rawset
     ;

type // TxPLAddress ===========================================================
     TxPLAddress = class(TxPLRawSet)
     private
        function Get_VD: string;
        procedure Set_RawxPL(const aValue: string); virtual;
        function  Get_RawxPL : string; virtual;
        procedure Set_VD(const AValue: string);

        class function RandomInstance : string;
        class function HostNmInstance : string;
        class function MacAddInstance : string;

     public
        constructor Create(const axPLAddress : TxPLAddress); overload;
        constructor Create(const aVendor : string = ''; const aDevice : string = ''; const aInstance : string = '' ); overload;

        procedure   Set_Element(AIndex: integer; const AValue: string); override;

        class function InitInstanceByDefault : string;

     published
        property Vendor   : string index 0 read Get_Element write Set_Element;
        property Device   : string index 1 read Get_Element write Set_Element;
        property Instance : string index 2 read Get_Element write Set_Element;
        property VD       : string         read Get_VD      write Set_VD     stored false;
        property RawxPL   : string         read Get_RawxPL  write Set_RawxPL stored false;
     end;

    // TxPLTargetAddress ======================================================
    TxPLTargetAddress = class(TxPLAddress)
    private
       function  Get_IsGeneric : boolean;
       function  Get_IsGroup   : boolean;
       function  Get_RawxPL    : string;            override;

       procedure Set_IsGroup(const AValue: boolean);
       procedure Set_RawxPL(const AValue: string); override;
       procedure Set_IsGeneric(const AValue: boolean);
    public
       function  IsValid : boolean;
       function  MatchesGroup(const aGroupSet : TStringList): boolean;

    published
       property  IsGeneric : boolean  read Get_IsGeneric write Set_IsGeneric stored false;
       property  IsGroup   : boolean  read Get_IsGroup   write Set_IsGroup   stored false;
    end;

const K_ADDR_ANY_TARGET = '*';

implementation // =============================================================
uses IdStack
     , SysUtils
     , StrUtils
     , fpc_delphi_compat
     ;

// ============================================================================
const   K_DEF_GROUP       = 'xpl-group';

// General Helper function ====================================================
class function TxPLAddress.RandomInstance : string;
var n: integer;
const ss: string = 'abcdefghjkmnpqrstuvwxyz';                                  // list all the charcaters you want to use
begin
   Result :='';
   for n:=1 to 8 do                                                            // Longueur volontairement limitée à 8 chars
       Result := Result +ss[random(length(ss))+1];
end;

class function TxPLAddress.HostNmInstance : string;
begin
   TIdStack.IncUsage;
   try
       Result := AnsiLowerCase(GStack.HostName);
   finally
       TIdStack.DecUsage;
   end;                                                                        // Old method using pwhostname, replaced by Indy
end;

class function TxPLAddress.MacAddInstance : string;
begin
   result := GetMacAddress;                                                    // Another usefull method
end;

class function TxPLAddress.InitInstanceByDefault : string;
begin
   case InstanceInitStyle of
        iisRandom     : result := RandomInstance;
        iisHostName   : result := HostNmInstance;
        iisMacAddress : result := MacAddInstance;
   end;
end;

// TxPLAddress Object =========================================================
constructor TxPLAddress.Create(const aVendor : string = ''; const aDevice : string = ''; const aInstance : string = '' );
begin
   inherited Create;
   SetLength(fMaxSizes,3);
   fMaxSizes[0] := 8;
   fMaxSizes[1] := 8;
   fMaxSizes[2] := 16;
   ResetValues;
   if aVendor<>''   then Vendor   := aVendor;
   if aDevice<>''   then Device   := aDevice;
   if aInstance<>'' then Instance := aInstance;
end;

constructor TxPLAddress.Create(const axPLAddress : TxPLAddress);
begin
   Create('','','');
   Assign(axPLAddress);
end;

procedure TxPLAddress.Set_RawxPL(const aValue: string);
begin
   inherited Set_RawxPL(StringReplace(aValue,'-','.',[]));
end;

function TxPLAddress.Get_RawxPL: string;
begin
   Result := StringReplace(inherited Get_RawxPL,'.','-',[])                    // will replace only the first '.' - this is what I want
end;

// ============================================================================
// http://xplproject.org.uk/wiki/index.php?title=XPL_Specification_Document :
// The hyphen/dash character (ASCII 45) is not valid within a Vendor ID, or
// within the Device ID. For example, xpl-xplhal.myhouse is valid, whilst
// xpl-xpl-hal.myhouse is not. Vendor IDs containing a hyphen will not be
// issued - vendors should ensure that the hyphen character is not used within
// a Device ID.
procedure TxPLAddress.Set_Element(AIndex: integer; const AValue: string);
begin
   if not AnsiContainsText('-',aValue) then inherited Set_Element(AIndex, AValue);
end;

function TxPLAddress.Get_VD: string;
begin
   result := Format('%s-%s',[Vendor,Device]);
end;

procedure TxPLAddress.Set_VD(const AValue: string);
begin
   RawxPL := StringReplace(aValue,'-','.',[]) + '.' + Instance;
end;

// TxPLTargetAddress Object ===================================================
function TxPLTargetAddress.Get_IsGeneric: boolean;
begin
   result := not inherited isvalid;
end;

function TxPLTargetAddress.IsValid : boolean;
begin
   result := IsGeneric or inherited;
end;

procedure TxPLTargetAddress.Set_IsGeneric(const AValue: boolean);
begin
   if aValue then ResetValues;
end;

function TxPLTargetAddress.Get_RawxPL: string;
begin
   if IsGeneric then Result := K_ADDR_ANY_TARGET
                else Result := inherited;
end;

procedure TxPLTargetAddress.Set_RawxPL(const AValue: string);
begin
   if aValue = K_ADDR_ANY_TARGET then ResetValues
                                 else inherited;
end;

function TxPLTargetAddress.Get_IsGroup: boolean;
begin
   result := (VD = K_DEF_GROUP);
end;

procedure TxPLTargetAddress.Set_IsGroup(const AValue: boolean);
begin
   if aValue then VD := K_DEF_GROUP
             else ResetValues;
end;

function TxPLTargetAddress.MatchesGroup(const aGroupSet : TStringList): boolean;
var s : string;
begin
   result := IsGroup;
   if result then
      for s in aGroupSet do
          result := result or (s = RawxPL);
end;

initialization // =============================================================
   Randomize;
   Classes.RegisterClass(TxPLAddress);
   Classes.RegisterClass(TxPLTargetAddress);

end.

