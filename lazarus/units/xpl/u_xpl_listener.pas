unit u_xpl_listener;
{==============================================================================
  UnitName      = uxPLListener
  UnitDesc      = xPL Listener object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 1.00 : Added Prerequisite modules handling
 1.01 : *** TODO : applications has up to 6 seconds to answer an HBeatRequest,
        *** the module should take this in account to decide that prereq are not met
}

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils,
     u_configuration_record,
     u_xPL_Message,
     u_xPL_Config,
     u_xPL_Body,
     u_xpl_custom_listener;

type TxPLPrereqMet = procedure of object;

     { TxPLListener }

     TxPLListener = class(TxPLCustomListener)
      protected
        fDiscovered : TConfigurationRecordList;
      private

        fPrereqList : TStringList;
        function Is_PrereqMet: boolean;
      public
        OnxPLPrereqMet     : TxPLPrereqMet    ;                                 // Called when needed modules has been seen on the xPL network

        constructor Create(const aOwner : TComponent); dynamic; overload;
        destructor destroy; override;
        procedure Set_ConnectionStatus(const aValue : TConnectionStatus); override;
        property PrereqList : TStringList read fPrereqList;
        property PrereqMet  : boolean     read Is_PrereqMet;

        function  DoHBeatApp    (const aMessage : TxPLMessage) : boolean; override;
        function  DeviceAddress (const aDevice : string) : string;
        procedure DoxPLPrereqMet ; dynamic;
        procedure OnDie(Sender : TObject); dynamic;
     end;

implementation { ==============================================================}
uses u_xpl_header
     , u_xpl_schema
     , u_xpl_common
     , u_xpl_messages
     , LResources
     ;

const K_MSG_PREREQ_MET      = 'All required modules found';
      K_MSG_PREREQ_PROBING  = 'Probing for presence of required modules : %s';

// TxPLListener ===============================================================
constructor TxPLListener.Create(const aOwner : TComponent);
begin
   inherited;

   fPrereqList := TStringList.Create;
   fDiscovered := TConfigurationRecordList.Create;
   FilterSet.AddValues([ 'xpl-stat.*.*.*.hbeat.app',
                         'xpl-stat.*.*.*.hbeat.end',
                         'xpl-stat.*.*.*.config.app' ]);
end;

destructor TxPLListener.destroy;
begin
   fPrereqList.Free;
   fDiscovered.Free;
   inherited;
end;

procedure TxPLListener.DoxPLPrereqMet;
begin
   Log(etInfo,K_MSG_PREREQ_MET);
   if Assigned(OnxPLPrereqMet) then OnxPLPrereqMet;
end;

procedure TxPLListener.Set_ConnectionStatus(const aValue : TConnectionStatus);
begin
   if aValue = connectionStatus then exit;
   inherited;
   if (ConnectionStatus = connected) and (not PrereqMet) and (Config.IsValid) then begin
      Log(etInfo,K_MSG_PREREQ_PROBING,[PrereqList.CommaText]);
      SendHBeatRequestMsg;
   end;
end;

function TxPLListener.Is_PrereqMet : boolean;
begin
   result := (PrereqList.Count = 0);
end;

procedure TxPLListener.OnDie(Sender: TObject);
var Config_Elmt : TConfigurationRecord;
begin
   Config_Elmt := TConfigurationRecord(Sender);
   fDiscovered.Remove(Config_Elmt.Address.Device);
end;

{------------------------------------------------------------------------
 DoHBeatApp :
   Transfers the message to the application only if the message completes
   required tests : has to be of xpl-stat type and the
   schema has to be hbeat.app
   IN  : the message to test and transmit
   OUT : result indicates wether the message has been transmitted or not
 ------------------------------------------------------------------------}
function TxPLListener.DoHBeatApp(const aMessage: TxPLMessage): boolean;
var i : integer;
begin
   result := false;
   with aMessage do begin
      if IsLifeSign then begin

        i := fDiscovered.IndexOf(Source.Device);

         if (i=-1)
            then fDiscovered.Add(Source.Device, TConfigurationRecord.Create(self,THeartBeatMsg(aMessage),@OnDie))
            else fDiscovered.Data[i].HBeatReceived(THeartBeatMsg(aMessage));

         if Schema.Equals(Schema_HBeatApp) then begin

           if not PrereqMet then begin
              i := PrereqList.IndexOf(Source.Device);
              if i<>-1 then begin
                 PrereqList.Delete(i);
                 if PrereqMet then DoxPLPrereqMet;
              end;
           end;

           if Assigned(OnxPLHBeatApp) and not Source.Equals(Adresse) then begin
              OnxPLHBeatApp( aMessage);
              result := true;
           end;
        end;

      end;
   end;
end;

function TxPLListener.DeviceAddress(const aDevice: string): string;
var i : integer;
begin
   if fDiscovered.Find(aDevice,i) then Result := fDiscovered.Data[i].Address.RawxPL
                                  else Result := '';
end;


end.


