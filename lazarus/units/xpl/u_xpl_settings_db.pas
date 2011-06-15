unit u_xpl_settings_db;
{==============================================================================
  UnitDesc      = xPL Registry and Global Settings management unit
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : spinned off from uxPLSettings
 }
{$mode objfpc}{$H+}

interface

uses  Classes,
      ZConnection,
      ZDataset;

type

{ TxPLSettingsDB }

TxPLSettingsDB = class(TComponent)
      private
        fDatabase      : TZConnection;
        fFileName      : string;

     public
        constructor create(const aBasePath : string);
        destructor  destroy; override;


        property  Database   : TZConnection          read fDatabase;
        function ExecSQL(const aSQL : string) : boolean;
        procedure Log    (const aApp, aLog, aLevel : string);
        property  FileName : string read fFileName;
        function GetDataSet(const aSQL : string) : TZQuery;
     end;

implementation // ======================================================================
uses SysUtils,
     uxPLConst;

{======================================================================================}
constructor TxPLSettingsDB.Create(const aBasePath : string);
begin
   fDatabase := TZConnection.Create(self);
   fDatabase.Database:='C:\Users\gaell-aug.SIFRAUGURE\Desktop\TEST.FDB';
   fDatabase.User:='sysdba';
   fDatabase.Password:='masterkey';
   fDatabase.Protocol:='firebird-2.1';
   fDatabase.Connected:=true;
end;

destructor TxPLSettingsDB.destroy;
begin
   fDatabase.Destroy;
end;

function TxPLSettingsDB.ExecSQL(const aSQL : string) : boolean;
begin
   result := fDatabase.ExecuteDirect(aSQL);
end;

procedure TxPLSettingsDB.Log(const aApp, aLog, aLevel : string);
begin
   ExecSQL(Format ('insert into common_log(device_id,log_level,log) values(''%s'',''%s'',''%s'')', [aApp, aLevel, aLog]));
end;

function TxPLSettingsDB.GetDataSet(const aSQL: string): TZQuery;
begin
   result := TZQuery.Create(self);
   result.Connection := fDatabase;
   result.Sql.Add(aSQL);
   result.Active:=true;
end;

end.

