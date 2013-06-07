 // This unit is common to Configurator and Logger apps, listener object

unit u_Configuration_Record;

{$i xpl.inc}

interface

uses Classes,
     SysUtils,
     fgl,
     fpc_delphi_compat,
     u_xml_plugins,
     u_xpl_address,
     u_xpl_config,
     u_xpl_messages,
     u_xpl_application,
     u_xpl_custom_message;

type { TConfigurationRecord ==================================================}
    TConfigurationRecord = class(TPersistent)
    protected
        fTimer      : TxPLTimer;
    private
        fPlug_Detail: TDeviceType;
        fAddress    : TxPLAddress;
        fInterval   : Integer;
        fLastHBeat  : TDateTime;
        fConfig     : TxPLCustomConfig;
        fDieAt      : TDateTime;
        fWaitingConf: boolean;
        fOnDied     : TNotifyEvent;
        function Get_CfgCurrAvail: boolean;
        function Get_CfgListAvail: boolean;
        function Get_XMLCfgAvail: boolean;
        procedure OnTimer({%h-}sender : TObject);
     public
        constructor Create(const aOwner : TxPLApplication; const aAddress: TxPLAddress; const aDieProc : TNotifyEvent);
        constructor Create(const aOwner : TxPLApplication; const aHBeatMsg : THeartBeatMsg; const aDieProc : TNotifyEvent);overload;
        destructor  Destroy; override;

        procedure HBeatReceived(const aHBeatMsg : THeartBeatMsg);
     published
        property CfgListAvail : boolean          read Get_CfgListAvail;
        property CfgCurrAvail : boolean          read Get_CfgCurrAvail;
        property XMLCfgAvail  : boolean          read Get_XMLCfgAvail;
        property LastHBeat    : TDateTime        read fLastHBeat    write fLastHBeat;
        property DieAt        : TDateTime        read fDieAt        write fDieAt;
        property Address      : TxPLAddress      read fAddress;
        property Config       : TxPLCustomConfig read fConfig;
        property Plug_Detail  : TDeviceType      read fPlug_Detail;
        property WaitingConf  : boolean          read fWaitingConf  write fWaitingConf;
        property OnDied       : TNotifyEvent     read fOnDied       write fOnDied;
        property Interval     : integer          read fInterval;
     end;

     TConfigurationRecordList = specialize TFPGMap<string,TConfigurationRecord>;

implementation // =============================================================

uses DateUtils,
     uxPLConst,
     u_xpl_schema
     ;

{ TConfigurationRecord }
constructor TConfigurationRecord.Create(const aOwner: TxPLApplication; const aAddress: TxPLAddress; const aDieProc : TNotifyEvent);
begin
   inherited Create;
   fAddress     := TxPLAddress.Create(aAddress);
   fConfig      := TxPLCustomConfig.Create(nil);
   fPlug_Detail := aOwner.VendorFile.FindDevice(aAddress);
   fInterval    := -1;

   fOnDied := aDieProc;
   if fOnDied<>nil then begin
      fTimer := xPLApplication.TimerPool.Add(60 * 1000, {$ifdef fpc}@{$endif}OnTimer);
      fTimer.Enabled  := true;
   end;
end;

constructor TConfigurationRecord.Create(const aOwner : TxPLApplication; const aHBeatMsg : THeartBeatMsg; const aDieProc : TNotifyEvent);
begin
   Create(aOwner,aHBeatMsg.Source,aDieProc);
   HBeatReceived(aHBeatMsg);
end;

procedure TConfigurationRecord.HBeatReceived(const aHBeatMsg : THeartBeatMsg);
begin
   fLastHBeat := now;
   fInterval := aHBeatMsg.Interval;
   if not aHBeatMsg.Schema.Equals(Schema_HBeatEnd)
      then fDieAt := IncMinute( fLastHBeat, 2 * Int64(Succ(Interval)))         // Defined by specifications as dead-line limit)
      else begin
        fDieAt := now;
        OnTimer(self);
      end;
   fWaitingConf := aHBeatMsg.Schema.Equals(Schema_ConfigApp);
end;

destructor TConfigurationRecord.Destroy;
begin
   fAddress.Free;
   fConfig.Free;
   inherited;
end;

function TConfigurationRecord.Get_CfgCurrAvail: boolean;
begin
   result := Config.IsValid;
end;

function TConfigurationRecord.Get_CfgListAvail: boolean;
begin
   result := Config.IsValid;
end;

function TConfigurationRecord.Get_XMLCfgAvail: boolean;
begin
   result := plug_detail <> nil;
end;

procedure TConfigurationRecord.OnTimer(sender: TObject);
begin
   if Assigned(OnDied) and (DieAt < now) then OnDied(self)
end;

end.
