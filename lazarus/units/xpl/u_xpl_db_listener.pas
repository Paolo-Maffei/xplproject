unit u_xpl_db_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , u_xpl_custom_listener
     , u_xpl_config
     , u_xpl_message
     , zDataset
     , zConnection
     ;

type

{ TxPLDBListener }

 TxPLDBListener = class(TxPLCustomListener)
     private
        SQLQuery      : TZQuery;
        procedure ConnectToDatabase(const aSchema : string);

     protected
        SQLConnection : TZConnection;
        fTestTableName : string;                                               // Table name that will validate presence of database schema
        fSchemaCreation: TStringList;

        procedure OpenQuery(const aQuery : string);
        procedure ExecQuery(const aQuery : string);
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;
        procedure   UpdateConfig; override;
     published
        property Query : TZQuery read SQLQuery stored false;
        property Connection : TZConnection read SQLConnection stored false;
     end;

implementation // =============================================================
uses db
     , u_xpl_header
     , u_xpl_body
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;

const //=======================================================================
      rsHostname = 'hostname';
      rsUsername = 'username';
      rsPassword = 'password';
      rsDatabase = 'database';

// ============================================================================
constructor TxPLDBListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   fSchemaCreation := TStringList.Create;
   Config.DefineItem(rsHostname, TxPLConfigItemType.config, 1, 'localhost');
   Config.DefineItem(rsUsername, TxPLConfigItemType.config, 1, 'root');
   Config.DefineItem(rsPassword, TxPLConfigItemType.config, 1, 'root');
   Config.DefineItem(rsDatabase, TxPLConfigItemType.config, 1, 'xpl');
end;

destructor TxPLDBListener.Destroy;
begin
   fSchemaCreation.Free;
   inherited Destroy;
end;

procedure TxPLDBListener.UpdateConfig;
var aSQL, aDB  : string;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     if not assigned(SQLConnection) then begin
        SQLConnection := TZConnection.Create(self);
        SQLQuery      := TZQuery.Create(self);
        SQLQuery.Connection := SQLConnection;
     end;
     SQLConnection.HostName := Config.GetItemValue(rsHostName);
     SQLConnection.User     := Config.GetItemValue(rsUserName);
     SQLConnection.Password := Config.GetItemValue(rsPassword);
     SQLConnection.Protocol := 'mysql-5';
     aDB                    := Config.GetItemValue(rsDatabase);
     ConnectToDatabase('mysql');

     OpenQuery('show databases');
     if not SQLQuery.Locate('database',aDB,[loCaseInsensitive]) then begin
        Log(etInfo,'Connected to database, creating schema : ' + aDB);
        ExecQuery('create schema ' + aDB +';');
     end;
     SQLQuery.Close;

     ConnectToDatabase(aDB);

     Assert(fTestTableName<>'');                                               // This value must be initialized in constructor
     OpenQuery('show tables');
     if not SQLQuery.Locate('tables_in_'+ aDB,fTestTableName,[loCaseInsensitive]) then begin
        Log(etInfo,'Creating tables');
        for aSQL in fSchemaCreation do
            ExecQuery(aSQL);
     end;
     SQLQuery.Close;

  end;
end;

procedure TxPLDBListener.ConnectToDatabase(const aSchema : string);
begin
   SQLConnection.Connected := false;
   SQLConnection.Database  := aSchema;
   try
      SQLConnection.Connected := true;
   except
      on E : Exception do Log(etError, 'Database library missing');
   end;
end;

procedure TxPLDBListener.OpenQuery(const aQuery : string);
begin
   SQLQuery.SQL.Text := aQuery;
   SQLQuery.Open;
end;

procedure TxPLDBListener.ExecQuery(const aQuery : string);
begin
   SQLQuery.SQL.Text := aQuery;
   SQLQuery.ExecSQL;
end;

end.

