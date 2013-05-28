unit uIP;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , IdIPAddress
     , fgl
     ;

type // TIPAddress ============================================================
     TIPAddress = class(TObject)
        fIdIPAddress : TIdIPAddress;
        fNetMask : string;
        fBroadCast : string;
        fAddrClass : string;
        fPrefix : integer;
     private
        function GetAddress: string;
     public
        constructor Create(const aIP : string);
        destructor Destroy; override;
     published
        property Address : string read GetAddress;
        property BroadCast : string read fBroadCast write fBroadCast;
        property NetMask : string read fNetMask write fNetMask;
        property Prefix : integer read fPrefix write fPrefix;
     end;

     // TIPAddresses ==========================================================
     TSpecIPAddresses = specialize TFPGObjectList<TIPAddress>;
     TIPAddresses = class(TSpecIPAddresses)
     private
        procedure BuildList;
     public
        constructor Create;
        function GetByIP(const aIP : string) : TIPAddress;
     end;

     function LocalIPAddresses : TIPAddresses;


// ============================================================================
implementation
uses Process
     , StrUtils
     , RegExpr
     ;

var fLocalAddresses : TIPAddresses;

// ============================================================================
function LocalIPAddresses: TIPAddresses;
begin
   if not Assigned(fLocalAddresses) then begin
      fLocalAddresses := TIPAddresses.Create;
   end;
   Result := fLocalAddresses;
end;

// ============================================================================
function MakeBroadCast(const aAddress : string) : string;                      // transforms a.b.c.d in a.b.c.255
begin                                                                          // approximative, but works on small cases like in home automation
   result := LeftStr(aAddress,LastDelimiter('.',aAddress)) + '255';
end;

// TIPAddress =================================================================
constructor TIPAddress.Create(const aIP : string);
begin
   inherited Create;
   fIdIPAddress := TIdIPAddress.MakeAddressObject(aIP);
end;

destructor TIPAddress.Destroy;
begin
   fIdIPAddress.Free;
   inherited;
end;

function TIPAddress.GetAddress: string;
begin
   Result := fIdIPAddress.IPAsString;
end;

// TIPAddresses ===============================================================
constructor TIPAddresses.Create;
begin
   inherited Create;
   FreeObjects := True;
   BuildList;
end;

function TIPAddresses.GetByIP(const aIP: string): TIPAddress;
var o : TIPAddress;
begin
   Result := nil;
   for o in Self do
       if o.Address = aIP then Result := o;
end;

procedure TIPAddresses.BuildList;
{$ifndef mswindows}
var proc : TProcess;
    slOutput : TStringList;
    re : TRegExpr;
    s : string;
    address : TIPAddress;
{$endif}
begin
{$ifdef mswindows}
   TIdStack.IncUsage;
   aStringList.Assign(GStack.LocalAddresses);
{$else}
   proc := TProcess.Create(nil);
   try
      slOutput := TStringList.Create;
      try
         proc.Executable := 'ifconfig';
         proc.Options := proc.Options + [poWaitOnExit, poUsePipes, poNoConsole,poStderrToOutput];
         proc.Execute;
         slOutput.LoadFromStream(proc.Output);
         re := TRegExpr.Create;
         re.Expression := ' (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})';
         for s in slOutput do
             if re.Exec(s) then begin
                address := TIPAddress.Create(re.Match[2]);
                address.NetMask := re.Match[6];
                address.BroadCast := re.Match[4];
                Add(address);
             end;
      finally
         slOutput.Free;
         re.Free;
      end;
   finally
      proc.Free;
   end;
{$endif}
end;


// ============================================================================
finalization
   if Assigned(fLocalAddresses)
      then LocalIPAddresses.Free;

end.

