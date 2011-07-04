unit u_xpl_heart_beater;

{ Il y a un bug dans la version fpc 2.5.1 de fpTimer. Ce bug génère un 'hang' général
  de l'application dès que l'on active ou désactive un fptimer. il faut employer une
  version antérieure pour fonctionner correctement pour contourner le problème -
  Récupérer celle qui se trouve ici :
  http://svn.freepascal.org/cgi-bin/viewvc.cgi/trunk/packages/fcl-base/src/fptimer.pp?revision=13012
  et forcer son utilisation en ajoutant le chemin de recherche :
  C:\pp\packages\fcl-base\src\fptimer.pp dans les paths du projet
  }

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     {$ifdef fpc}
     , fpTimer
     {$else}
     , ExtCtrls
     {$endif}
     , u_xpl_config
     ;

type TxPLRateFrequency = (rfDiscovering, rfNoHubLowFreq, rfRandom, rfConfig, rfNone);

     // TxPLHeartBeater =======================================================
     TxPLHeartBeater = class( {$ifdef fpc}TfpTimer {$else}TTimer {$endif})
     private
        fRate : TxPLRateFrequency;
        FNoHubTimerCount : integer;

        procedure Set_Rate(const AValue: TxPLRateFrequency);
        procedure Tick(sender : TObject);
     public
        constructor create(AOwner: TComponent); override;
     published
        property Rate : TxPLRateFrequency read fRate write Set_Rate;
     end;

implementation // =============================================================
uses u_xpl_custom_listener;

// Hub and listener constants =================================================
const NOHUB_HBEAT     : Integer = 3;                                           // seconds between HBEATs until hub is detected
      NOHUB_LOWERFREQ : Integer = 30;                                          // lower frequency probing for hub
      NOHUB_TIMEOUT   : Integer = 120;                                         // after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ

constructor TxPLHeartBeater.create(AOwner: TComponent);
begin
   Assert(aOwner is TxPLCustomListener);
   inherited;
   OnTimer          := @Tick;
   fNoHubTimerCount := 0;
   Rate := rfNone;
end;

procedure TxPLHeartBeater.Tick(sender: TObject);
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

procedure TxPLHeartBeater.Set_Rate(const AValue: TxPLRateFrequency);
   procedure Set_Interval(aValue: integer);
   begin
       if Interval<>aValue then begin
          Enabled  := False;
          Interval := aValue;
          Enabled  := True;
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
end.

