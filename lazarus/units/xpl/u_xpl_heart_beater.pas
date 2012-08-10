unit u_xpl_heart_beater;

{ Il y a un bug dans la version fpc 2.5.1 de fpTimer. Ce bug génère un 'hang' général
  de l'application dès que l'on active ou désactive un fptimer. il faut employer une
  version antérieure pour fonctionner correctement pour contourner le problème -
  Récupérer celle qui se trouve ici :
  http://svn.freepascal.org/cgi-bin/viewvc.cgi/trunk/packages/fcl-base/src/fptimer.pp?revision=13012
  et forcer son utilisation en ajoutant le chemin de recherche :
  C:\pp\packages\fcl-base\src\ dans les paths du projet
  }

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , fpc_delphi_compat
     , u_xpl_config
     ;

type TxPLRateFrequency = (rfDiscovering, rfNoHubLowFreq, rfRandom, rfConfig, rfNone);
     TConnectionStatus = (discovering, connected, csNone);

     // TxPLHeartBeater =======================================================

     { TxPLConnHandler }

     TxPLConnHandler = class(TComponent)
     private
        fTimer : TxPLTimer;
        fRate : TxPLRateFrequency;
        FNoHubTimerCount : integer;

        function GetConnectionStatus: TConnectionStatus;
        procedure SetConnectionStatus(const AValue: TConnectionStatus);
        procedure Set_Rate(const AValue: TxPLRateFrequency);
        procedure Tick({%H-}sender : TObject);
     public
        constructor Create(AOwner: TComponent); override;
        function StatusAsStr : string;
     published
        property Rate : TxPLRateFrequency write Set_Rate;
        property Status : TConnectionStatus read GetConnectionStatus write SetConnectionStatus;
     end;

implementation // =============================================================
uses TypInfo
     , u_xpl_custom_listener
     , u_xpl_application
     ;

const K_NETWORK_STATUS = 'xPL Network status : %s';

// Hub and listener constants =================================================
const NOHUB_HBEAT     : Integer = 3;                                           // seconds between HBEATs until hub is detected
      NOHUB_LOWERFREQ : Integer = 30;                                          // lower frequency probing for hub
      NOHUB_TIMEOUT   : Integer = 120;                                         // after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ

constructor TxPLConnHandler.create(AOwner: TComponent);
begin
   Assert(aOwner is TxPLCustomListener);
   inherited;
   fTimer := TxPLApplication(aOwner).TimerPool.Add(0,{$ifdef fpc}@{$endif}Tick);
   fNoHubTimerCount := 0;
   Rate := rfNone;
end;

function TxPLConnHandler.StatusAsStr: string;
begin
   Result := Format(K_NETWORK_STATUS, [GetEnumName(TypeInfo(TConnectionStatus), Ord(Status))]);
end;

procedure TxPLConnHandler.Tick(sender: TObject);
begin
   with TxPLCustomListener(Owner) do begin
      if ConnectionStatus <> connected then begin
         inc(fNoHubTimerCount,NOHUB_HBEAT);
         if fNoHubTimerCount > NOHUB_TIMEOUT then Rate := rfNoHubLowFreq;      // Still a high frequency ?
      end else begin
          fNoHubTimerCount := 0;
          Rate := rfConfig;                                                    // Always get back to preserved frequence
      end;
      SendHeartBeatMessage;
   end;
end;

procedure TxPLConnHandler.Set_Rate(const AValue: TxPLRateFrequency);
   procedure Set_Interval(aInterval : {$ifdef fpc}integer{$else}cardinal{$endif});
   begin
       if fTimer.Interval <> aInterval then begin
          fTimer.Enabled  := False;
          fTimer.Interval := aInterval;
          fTimer.Enabled  := True;
       end;
   end;
begin
   fRate:=AValue;
   case fRate of
        rfDiscovering  : begin
                         Set_Interval(NOHUB_HBEAT * 1000);                     // Force a tick right now in this case
                         Tick(self);                                           // to avoid waiting 3 secs before connection
                         end;
        rfNoHubLowFreq : Set_Interval(NOHUB_LOWERFREQ * 1000);                 // Choose a random value between 2 and 6 seconds
        rfRandom       : Set_Interval(Random(4000) + 2000);
        rfConfig       : Set_Interval(TxPLCustomListener(owner).Config.Interval*60*1000);
   end;
end;

function TxPLConnHandler.GetConnectionStatus: TConnectionStatus;
begin
   case fRate of
        rfDiscovering,rfNoHubLowFreq : result := Discovering;
        rfRandom,rfConfig : result := Connected;
   end;
end;

procedure TxPLConnHandler.SetConnectionStatus(const AValue: TConnectionStatus);
begin
   if Status<>aValue then begin
      if aValue = connected then
          Rate := rfConfig
       else
          Rate := rfDiscovering;
   end;
end;

end.
