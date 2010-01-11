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
}
{$mode objfpc}{$H+}
interface

uses DOM, uxPLBaseClass;

type

    { TxPLAddress }

    TxPLAddress = class(TxPLBaseClass)
    public
       property Vendor   : string Index 0 read GetString write SetString;
       property Device   : string Index 1 read GetString write SetString;
       property Instance : string Index 2 read GetString write SetString;
       property Tag : string read GetTag write SetTag;

       constructor Create;                                                   override;
       constructor Create(const axPLAddress : TxPLAddress);
       constructor Create(const aVendor, aDevice : string; aInstance : string = '' );

       procedure WriteToXML(const aParent : TDOMNode); overload;
       procedure ReadFromXML(const aParent : TDOMNode)                        virtual;
       function  FilterTag : string;

       class function ComposeAddress       (const aVendor : string; const aDevice : string; const aInstance : string) : string;
       class function ComposeAddressFilter (const aVendor : string; const aDevice : string; const aInstance : string) : string;
       class function RandomInstance : string;
    end;

    { TxPLTargetAddress }

    TxPLTargetAddress = class(TxPLAddress)
    protected
       fGeneric : boolean;

       procedure SetGeneric(const AValue: boolean);
       procedure SetString(const aIndex : integer; const aValue : string);
       procedure SetTag(const AValue: string);                                  virtual;
       function GetString(const AIndex: integer): string;                       override;
       function  GetTag: string;                                                override;

    public
       constructor Create;                                                      override;
       property  IsGeneric  : boolean read fGeneric write SetGeneric;
       property  Tag : string read GetTag write SetTag;
       function  IsValid    : boolean;                                          override;
       procedure ResetValues;
       procedure ReadFromXML(const aParent : TDOMNode);                         override;
    end;

const K_REGEXPR_VENDOR   = '([0-9a-z]{1,8})';
      K_REGEXPR_DEVICE   = K_REGEXPR_VENDOR;
      K_REGEXPR_INSTANCE = '([0-9a-z/-]{1,16})';
      K_REGEXPR_ADDRESS  = K_REGEXPR_VENDOR + '\-' + K_REGEXPR_DEVICE + '\.' + K_REGEXPR_INSTANCE;
      K_REGEXPR_TARGET   = K_REGEXPR_ADDRESS + '|(\*)' ;    //   /!\ alternative must be place after fixed part !!!      


implementation { ==============================================================}
uses cRandom, SysUtils;

{ General Helper function =====================================================}
class function TxPLAddress.ComposeAddress(const aVendor : string; const aDevice : string; const aInstance : string) : string;
begin
     If ((aVendor='*') or (aDevice='*') or (aInstance='*'))
         then result := '*'                                              // an address is either generic
         else result := Format('%s-%s.%s',[aVendor,aDevice,aInstance]);  // either formatted with 3 valid strings
end;

class function TxPLAddress.ComposeAddressFilter(const aVendor : string; const aDevice : string; const aInstance : string) : string;
begin
     result := Format('%s.%s.%s',[aVendor,aDevice,aInstance]);
end;

class function TxPLAddress.RandomInstance : string;
begin result := AnsiLowerCase(RandomAlphaStr(8)); end;

{ TxPLAddress Object ==========================================================}
constructor TxPLAddress.Create;
begin
     inherited Create;
     fClassName := 'xPLAddress';

     AppendItem('vendor',K_REGEXPR_VENDOR);
     AppendItem('device',K_REGEXPR_DEVICE);
     AppendItem('instance',K_REGEXPR_INSTANCE);

     fFormatString := '%0-%1.%2';
     fRegExpString := K_REGEXPR_ADDRESS;
end;

constructor TxPLAddress.Create(const aVendor, aDevice : string; aInstance : string = '' );
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

procedure TxPLAddress.WriteToXML(const aParent : TDOMNode);
begin
     TDOMElement(aParent).SetAttribute(fClassName,Tag);
end;

procedure TxPLAddress.ReadFromXML(const aParent: TDOMNode);
begin
     Tag := TDOMElement(aParent).GetAttribute(fClassName);
end;

function TxPLAddress.FilterTag : string;
begin
     Result := ComposeAddressFilter(Vendor,Device,Instance);
end;

{ TxPLTargetAddress Object =======================================================}
constructor TxPLTargetAddress.Create;
begin
     inherited Create;
     fClassName := 'xPLAddress-target';
     fRegExpString := K_REGEXPR_TARGET;
end;

procedure TxPLTargetAddress.SetGeneric(const AValue: boolean);
begin
     if aValue = fGeneric then exit;

     fGeneric := aValue;
end;

procedure TxPLTargetAddress.ResetValues;
begin
     inherited ResetValues;
     fGeneric := true;
end;

procedure TxPLTargetAddress.SetString(const aIndex : integer; const aValue : string);
begin
     if aValue = '*' then IsGeneric := True
                     else inherited SetString(aIndex, aValue);
end;

function TxPLTargetAddress.GetTag: string;
begin
     If fGeneric then result := '*' else result := inherited;
end;

procedure TxPLTargetAddress.SetTag(const AValue: string);
begin
     IsGeneric := (aValue='*');

     If not IsGeneric then inherited SetTag(aValue);
end;

function TxPLTargetAddress.GetString(const AIndex: integer): string;
begin
  if IsGeneric then Result:='*' else result := inherited;
end;

function TxPLTargetAddress.IsValid: boolean;
begin
     result := IsGeneric or (inherited isValid);
end;

procedure TxPLTargetAddress.ReadFromXML(const aParent: TDOMNode);
begin
     Tag := TDOMElement(aParent).GetAttribute(fClassName);
end;

end.

