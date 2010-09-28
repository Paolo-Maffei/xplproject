unit uxPLAddress;
{==============================================================================
  UnitName      = uxPLAddress
  UnitDesc      = xPL Schema management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Added descendants source and target addresses
        Added XMLWrite and Read methods
 0.95 : XML Read Write method modified to be consistent with other vendors
 0.96 : Some filter related functions added
 0.97 : String constants removed to use uxPLConst
 0.98 : Simplification of the class (cut inheritance of TxPLBaseClass)
 0.99 : Added HostNmInstance
 1.00 : Suppressed uRegExpTools
 1.01 : IsValid function moved to be class functions
}
{$mode objfpc}{$H+}
interface

uses uxPLConst;

type

    { TxPLAddress }

    TxPLAddress = class
       fVendor   : string;
       fDevice   : string;
       fInstance : string;

       function  GetTag: string;                        dynamic;
       procedure SetTag   (const aValue: string);       dynamic;
       procedure SetAddressElement(const aIndex : integer; const aValue : string); dynamic;
    public
       constructor Create;
       constructor Create(const axPLAddress : TxPLAddress);
       constructor Create(const aVendor : tsVendor; const aDevice : tsDevice; aInstance : tsInstance = '' );

       procedure ResetValues;                           dynamic;
       procedure Assign(anAddress : TxPLAddress);

       property Vendor   : string index 0 read fVendor   write SetAddressElement;
       property Device   : string index 1 read fDevice   write SetAddressElement;
       property Instance : string index 2 read fInstance write SetAddressElement;

       property Tag      : string read GetTag    write SetTag;

       function  FilterTag : string;
       function  Equals(anAddress : TxPLAddress) : boolean;

       class function ComposeAddress       (const aVendor : tsVendor; const aDevice : tsDevice; const aInstance : tsInstance) : tsAddress;
       class function ComposeAddressFilter (const aVendor : tsVendor; const aDevice : tsDevice; const aInstance : tsInstance) : string;
       class procedure SplitVD              (const aVD : string; out aVendor : string; out aDevice : string);
       class function RandomInstance : tsInstance;
       class function HostNmInstance : tsInstance;
       class function IsValid(const aAddress : string) : boolean;
    end;

    { TxPLTargetAddress }

    TxPLTargetAddress = class(TxPLAddress)
       fIsGeneric : boolean;

       procedure SetTag(const AValue: string); override;
       function  GetTag: string;               override;
       procedure SetAddressElement(const aIndex : integer; const aValue : string); override;
    public
       constructor Create;

       property  IsGeneric : boolean  read fIsGeneric write fIsGeneric;
       procedure ResetValues;         override;
       class function IsValid(const aAddress : string) : boolean;
    end;

implementation { ==============================================================}
uses cRandom, SysUtils, StrUtils, cStrings, pwHostName, uRegExpr;

{ General Helper function =====================================================}
class function TxPLAddress.ComposeAddress(const aVendor : tsVendor; const aDevice : tsDevice; const aInstance : tsInstance) : tsAddress;
begin
   If ((aVendor=K_ADDR_ANY_TARGET) or (aDevice=K_ADDR_ANY_TARGET) or (aInstance=K_ADDR_ANY_TARGET))
      then result := K_ADDR_ANY_TARGET                                   // an address is either generic
      else result := Format(K_FMT_ADDRESS,[aVendor,aDevice,aInstance]);  // either formatted with 3 valid strings
end;

class function TxPLAddress.ComposeAddressFilter(const aVendor : tsVendor; const aDevice : tsDevice; const aInstance : tsInstance) : string;
begin
   result := Format(K_FMT_FILTER,[aVendor,aDevice,aInstance]);
end;

class procedure TxPLAddress.SplitVD(const aVD: string; out aVendor: string; out aDevice: string);
begin StrSplitAtChar(aVD,'-',aVendor,aDevice,false); end;

class function TxPLAddress.RandomInstance : tsInstance;
begin result := AnsiLowerCase(RandomAlphaStr(sizeof(tsInstance))); end;

class function TxPLAddress.HostNmInstance : tsInstance;
begin result := AnsiLowerCase(InetSelfName); end;

class function TxPLAddress.IsValid(const aAddress : string) : boolean;
begin
   with TRegExpr.Create do try
        Expression := K_REGEXPR_ADDRESS;
        result := Exec(aAddress);
   finally
      destroy;
   end;
end;

{ TxPLAddress Object ==========================================================}
constructor TxPLAddress.Create;
begin
   ResetValues;
end;

constructor TxPLAddress.Create(const aVendor : tsVendor; const aDevice : tsDevice; aInstance : tsInstance = '' );
begin
   Create;

   Vendor := aVendor;
   Device := aDevice;
   Instance := aInstance;
end;

constructor TxPLAddress.Create(const axPLAddress : TxPLAddress);
begin
   Create;
   Assign(axPLAddress);
end;

procedure TxPLAddress.ResetValues;
begin
   fVendor   := '';
   fDevice   := '';
   fInstance := '';
end;

procedure TxPLAddress.Assign(anAddress: TxPLAddress);
begin
   fVendor   := anAddress.Vendor;
   fDevice   := anAddress.Device;
   fInstance := anAddress.Instance;
end;

function TxPLAddress.GetTag: string;
begin
   Result := Format(K_FMT_ADDRESS,[fVendor,fDevice,fInstance]);
end;

procedure TxPLAddress.SetTag(const aValue: string);
begin
   with TRegExpr.Create do try
        Expression := K_REGEXPR_ADDRESS;
        if Exec(aValue) then begin
           fVendor   := Match[1];
           fDevice   := Match[2];
           fInstance := Match[3];
        end;
   finally destroy
   end;
end;

function TxPLAddress.FilterTag : string;
begin
   Result := ComposeAddressFilter(Vendor,Device,Instance);
end;

function TxPLAddress.Equals(anAddress: TxPLAddress): boolean;
begin
  result := (fVendor   = anAddress.Vendor) and
            (fDevice   = anAddress.Device) and
            (fInstance = anAddress.Instance);
end;

procedure TxPLAddress.SetAddressElement(const aIndex : integer; const aValue : string);
begin
   case aIndex of
        0 : fVendor   := aValue;
        1 : fDevice   := aValue;
        2 : fInstance := aValue;
   end;
end;

{ TxPLTargetAddress Object =======================================================}
procedure TxPLTargetAddress.ResetValues;
begin
   inherited ResetValues;
   fIsGeneric := true;
end;

procedure TxPLTargetAddress.SetAddressElement(const aIndex : integer; const aValue : string);
begin
   if aValue = K_ADDR_ANY_TARGET then fIsGeneric := True
                                 else inherited;
end;

function TxPLTargetAddress.GetTag: string;
begin
   Result := IfThen( fIsGeneric, K_ADDR_ANY_TARGET, inherited GetTag);
end;

constructor TxPLTargetAddress.Create;
begin
  inherited;
  fIsGeneric := True;
end;

procedure TxPLTargetAddress.SetTag(const AValue: string);
begin
   fIsGeneric := (aValue=K_ADDR_ANY_TARGET);
   If not fIsGeneric then inherited;
end;

class function TxPLTargetAddress.IsValid(const aAddress : string) : boolean;
begin
   with TRegExpr.Create do try
        Expression := K_REGEXPR_TARGET;
        result := Exec(aAddress);
   finally destroy;
   end;
end;

end.

