unit uIP;

{$i xPL.inc}

interface

uses Classes
     , SysUtils
     , IdIPAddress
     , fgl
     ;

type // TIPAddress ============================================================
     TIPAddress = class(TObject)
        fIntName : string;                                                     // interface name eth0, lo, wlan0...
        fHWAddr : string;                                                      // Hardware address
        fIdIPAddress : TIdIPAddress;
        fNetMask : string;                                                     // Netmask
        fBroadCast : string;                                                   // broadcast address
     private
        fPrefix: integer;
        function GetAddress: string;
        procedure SetAddress(const aValue: string);
     public
        constructor Create(const aIP : string); overload;
        destructor Destroy; override;
        function IsValid : boolean;
     published
        property Address : string read GetAddress write SetAddress;
        property BroadCast : string read fBroadCast write fBroadCast;
        property NetMask : string read fNetMask write fNetMask;
        property Prefix : integer read fPrefix write fPrefix;
        property IntName : string read fIntName write fIntName;
        property HWAddr : string read fHWAddr write fHWAddr;
     end;

     // TIPAddresses ==========================================================
     TSpecIPAddresses = specialize TFPGObjectList<TIPAddress>;
     TIPAddresses = class(TSpecIPAddresses)
     private
        procedure BuildList;
     public
        constructor Create;
        function GetByIP(const aIP : string) : TIPAddress;
        function GetByIntName(const aInterface : string) : TIPAddress;
     end;

     function LocalIPAddresses : TIPAddresses;


// ============================================================================
implementation
uses Process
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

function TIPAddress.IsValid: boolean;
begin
   Result := (length(Address) * length(BroadCast)) <> 0
end;

function TIPAddress.GetAddress: string;
begin
   Result := '';
   if Assigned(fIdIPAddress) then
      Result := fIdIPAddress.IPAsString;
end;

procedure TIPAddress.SetAddress(const aValue: string);
begin
   if not Assigned(fIdIPAddress) then
      fIdIPAddress := TIdIPAddress.MakeAddressObject(aValue);
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

function TIPAddresses.GetByIntName(const aInterface: string): TIPAddress;
var o : TIPAddress;
begin
   Result := nil;
   for o in Self do
       if o.IntName = aInterface then Result := o;
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
   TIdStack.IncUsage;                                                          // as of now, this has to be adapted under windows
   aStringList.Assign(GStack.LocalAddresses);
{$else}
   proc := TProcess.Create(nil);
   slOutput := TStringList.Create;
   re := TRegExpr.Create;
   proc.Executable := 'ifconfig';
   proc.Options := proc.Options + [poWaitOnExit, poUsePipes, poNoConsole,poStderrToOutput];

   try
      proc.Execute;                                                           // collect all network interfaces and hardware addresses
      slOutput.LoadFromStream(proc.Output);
      re.Expression := '(.*?) .*?HWaddr (.*?) ';
      for s in slOutput do
          if re.Exec(s) then begin
             address := TIPAddress.Create;
             address.HWAddr := re.Match[2];
             address.IntName:= re.Match[1];
             Add(address);
          end;

      for address in Self do begin
         proc.Parameters.Text:=Address.IntName;
         proc.Execute;
         slOutput.LoadFromStream(proc.Output);
         re.Expression := ' (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) (.*?):([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})';
         if re.Exec(slOutput.Text) then begin
            Address.Address :=re.Match[2];
            Address.NetMask := re.Match[6];
            Address.BroadCast := re.Match[4];
         end;
      end;
   finally
      re.Free;
      slOutput.Free;
      proc.Free;
   end;
{$endif}
end;


// ============================================================================
finalization
   if Assigned(fLocalAddresses)
      then LocalIPAddresses.Free;

end.

