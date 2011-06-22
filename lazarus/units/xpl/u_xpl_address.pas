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
     , u_xpl_config
     ;

type // TxPLAddress ===========================================================
     TxPLAddress = class(TxPLRawSet)
     private
        function Get_VD: string;
        procedure Set_RawxPL(const aValue: string); virtual;
        function  Get_RawxPL : string; virtual;
        procedure Set_VD(const AValue: string);
     public
        constructor Create(const axPLAddress : TxPLAddress); overload;
        constructor Create(const aVendor : string = ''; const aDevice : string = ''; const aInstance : string = '' ); overload;
        procedure   ResetValues;  override;

        function    AsFilter : string; dynamic;

        procedure Set_Element(AIndex: integer; const AValue: string); override;

        class function RandomInstance : string;
        class function HostNmInstance : string;

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
       function  MatchesGroup(const aGroupSet: TxPLConfigItem): boolean;

    published
       property  IsGeneric : boolean  read Get_IsGeneric write Set_IsGeneric stored false;
       property  IsGroup   : boolean  read Get_IsGroup   write Set_IsGroup   stored false;
    end;

    // Operator overloading has been put apart for Delphi compatibility issues
    // Operator := (t1 : string) t2 : TxPLAddress;

const K_ADDR_ANY_TARGET = '*';

implementation // =============================================================
uses IdStack
     , JCLStrings
     , SysUtils
     , StrUtils
     ;

// ============================================================================
const K_LEN : Array [0..2] of integer = (8,8,16);                              // Length of V D I components by xPL Rule
      K_FMT_FILTER      = '%s.%s.%s';
      K_DEF_GROUP       = 'xpl-group';

// General Helper function ====================================================
class function TxPLAddress.RandomInstance : string;
var n: integer;
    const ss: string = 'abcdefghjkmnpqrstuvwxyz'; {list all the charcaters you want to use}
begin
   Result :='';
   for n:=1 to K_LEN[1] do                                                     // Longueur volontairement limitée à 8 chars
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

// ============================================================================
//operator:=(t1: string)t2: TxPLAddress;
//begin
//   t2 := TxPLAddress.Create;
//   t2.RawxPL := t1;
//end;

// TxPLAddress Object =========================================================
constructor TxPLAddress.Create(const aVendor : string = ''; const aDevice : string = ''; const aInstance : string = '' );
begin
   inherited Create;
   Vendor   := aVendor;
   Device   := aDevice;
   Instance := aInstance;
end;

constructor TxPLAddress.Create(const axPLAddress : TxPLAddress);
begin
   inherited Create;
   Assign(axPLAddress);
end;

procedure TxPLAddress.ResetValues;
begin
   fRawxPL.DelimitedText := '..';
end;

function TxPLAddress.Get_VD: string;
begin
   result := Format('%s-%s',[Vendor,Device]);
end;

procedure TxPLAddress.Set_RawxPL(const aValue: string);
begin
   fRawxPL.DelimitedText := StringReplace(aValue,'-','.',[]);
end;

function TxPLAddress.Get_RawxPL: string;
begin
   result := StringReplace(fRawxPL.DelimitedText,'.','-',[]);                  // will replace only the first '.' - this is what I want
end;

function TxPLAddress.AsFilter : string;
begin
   Result := Format(K_FMT_FILTER,[ IfThen( Vendor  <>'', Vendor  , K_ADDR_ANY_TARGET),
                                   IfThen( Device  <>'', Device  , K_ADDR_ANY_TARGET),
                                   IfThen( Instance<>'', Instance, K_ADDR_ANY_TARGET)]);
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

function TxPLTargetAddress.MatchesGroup(const aGroupSet: TxPLConfigItem): boolean;
var i : integer;
begin
   result := IsGroup;
   if result then
      for i := 1 to aGroupSet.ValueCount do
          result := result or (aGroupSet.ValueAtId(i) = RawxPL);
end;

initialization // =============================================================
   Randomize;
   Classes.RegisterClass(TxPLAddress);
   Classes.RegisterClass(TxPLTargetAddress);

end.

