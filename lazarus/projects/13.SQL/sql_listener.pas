unit sql_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils,
  u_xpl_custom_listener,
  u_xpl_config,
  u_xpl_actionlist,
  u_xpl_message,
  zDataset,
  zConnection;

type

{ TxPLSqlListener }

     TxPLSqlListener = class(TxPLCustomListener)
     private
        SQLConnection : TZConnection;
        SQLQuery      : TZQuery;
        procedure ConnectToDatabase(const aSchema : string);
        procedure OpenQuery(const aQuery : string);
        procedure ExecQuery(const aQuery : string);
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        procedure   UpdateConfig; override;
        procedure   Preprocess(const aMessage : TxPLMessage);
        procedure   Process(const aMessage : TxPLMessage);
     published
     end;

implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_body
     , StrUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;
const //======================================================================================
     rsHostname = 'hostname';
     rsUsername = 'username';
     rsPassword = 'password';
     rsDatabase = 'database';
     rsLoggAll  = 'logging';

// ===========================================================================================
procedure TxPLSqlListener.ConnectToDatabase(const aSchema : string);
begin
   SQLConnection.Connected := false;
   SQLConnection.Database  := aSchema;
   SQLConnection.Connected := true;
end;

procedure TxPLSqlListener.OpenQuery(const aQuery : string);
begin
   SQLQuery.SQL.Text := aQuery;
   SQLQuery.Open;
end;

procedure TxPLSqlListener.ExecQuery(const aQuery : string);
begin
   SQLQuery.SQL.Text := aQuery;
   SQLQuery.ExecSQL;
end;

{ TxPLSqlListener }

constructor TxPLSqlListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);
   FilterSet.AddValues(['xpl-cmnd.*.*.*.db.basic']);
   Config.DefineItem(rsHostname, TxPLConfigItemType.config, 1, 'localhost');
   Config.DefineItem(rsUsername, TxPLConfigItemType.config, 1, 'root');
   Config.DefineItem(rsPassword, TxPLConfigItemType.option, 1, '');
   Config.DefineItem(rsDatabase, TxPLConfigItemType.config, 1, '');
   Config.DefineItem(rsLoggAll,  TxPLConfigItemType.reconf, 1, 'y');
end;

procedure TxPLSqlListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLSqlListener') = 0 then ComponentClass := TxplSqlListener
   else inherited;
end;

procedure TxPLSqlListener.UpdateConfig;
var found : boolean;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     if not assigned(SQLConnection) then begin
        SQLConnection := TZConnection.Create(self);
        SQLQuery      := TZQuery.Create(self);
        SQLQuery.Connection := SQLConnection;
     end;
     SQLConnection.HostName  := Config.GetItemValue(rsHostName);
     SQLConnection.User      := Config.GetItemValue(rsUserName);
     SQLConnection.Password  := Config.GetItemValue(rsPassword);
     SQLConnection.Protocol  :='mysql-5';
     ConnectToDatabase('mysql');

     if Config.GetItemValue(rsLoggAll) = 'y' then OnPreProcessMsg := @Preprocess else OnPreProcessMsg := nil;

     OpenQuery('show databases');
     while not SQLQuery.EOF do begin                                          // look if the database exists
        found := (SqlQuery.Fields[0].AsString = Config.GetItemValue(rsDatabase));
        if found then break;
        SQLQuery.Next;
     end;
     SQLQuery.Close;

     if not found then begin                                                  // if not create it
        Log(etInfo,'Connected to database, creating schema');
        ExecQuery('create schema ' + Config.GetItemValue(rsDatabase) +';');
     end;

     ConnectToDatabase(Config.GetItemValue(rsDatabase));

     OpenQuery('show tables');
     while not SQLQuery.EOF do begin                                          // look if the database exists
        found := (SqlQuery.Fields[0].AsString = 'log_body');
        if found then break;
        SQLQuery.Next;
     end;
     SQLQuery.Close;

     if not found then begin
        Log(etInfo,'Creating message logging tables');

        ExecQuery('CREATE TABLE log_header(id int NOT NULL auto_increment,time TIMESTAMP,type char(8) default NULL, source varchar(34) default NULL,'
         + ' target varchar(34) default NULL, class varchar(15) default NULL, PRIMARY KEY (id),'
         + 'KEY class_idx (class), KEY type_idx (type));');

        ExecQuery('CREATE TABLE log_body(id int not null auto_increment, header_id int NOT NULL,name varchar(16) NOT NULL,value varchar(128) default NULL, KEY name_idx (name), KEY header_idx(header_id), PRIMARY KEY (id));');
      end;
      OnxPLReceived := @Process;
  end else OnxPLReceived := nil;
end;

procedure TxPLSqlListener.Preprocess(const aMessage: TxPLMessage);
var s : string;
    i,j  : integer;
begin
   s:= 'INSERT INTO log_header(type,source,target,class) VALUES ("%s","%s","%s","%s");';
   ExecQuery(Format(s,[MsgTypeToStr(aMessage.MessageType),aMessage.source.RawxPL,aMessage.Target.RawxPL,aMessage.schema.RawxPL]));

   OpenQuery('select max(id) from log_header');
   SQLQuery.Open;
   if SQLQuery.RecordCount=1 then begin
      i := SQLQuery.Fields[0].AsInteger;
      s := 'INSERT INTO log_body(header_id,name,value) values (%d,"%s","%s");';
      SQLQuery.Close;
      SQLQuery.SQL.Clear;
      for j:=0 to aMessage.Body.Keys.Count-1 do
          ExecQuery(Format(s,[i, aMessage.Body.Keys[j], aMessage.Body.Values[j]]));
   end else SQLQuery.Close;
end;

procedure TxPLSqlListener.Process(const aMessage: TxPLMessage);
var command : string;
    sql : string;
    i,j : integer;
    answer : TxPLMessage;
    savebody : TxPLBody;
begin
   command := aMessage.Body.GetValueByKey('command');
   sql     := aMessage.Body.GetValueByKey('sql');
   answer  := TxPLMessage.Create(self);
   answer.Assign(aMessage);
   answer.Reply;
   answer.Body.AddKeyValuePairs(['status'],['ok']);
   answer.Body.SetValueByKey('sql','');
   if command = 'lookup' then begin
      if sql<>'' then begin
         SQLQuery.SQL.Text := sql;
         if (AnsiContainsText(sql,'select ')) or (AnsiContainsText(sql,'show ')) then begin
            try
               sqlquery.Open;
               savebody := TxPLBody.Create(self);
               savebody.Assign(answer.Body);
               for i:=0 to sqlquery.RecordCount-1 do begin
                 for j:=0 to sqlquery.FieldCount-1 do
                      answer.Body.AddKeyValuePairs([sqlquery.Fields[j].FieldName],[sqlquery.Fields[j].AsString]);
                 answer.Body.CleanEmptyValues;
                 Send(answer);
                 answer.Body.Assign(savebody);
                 sqlquery.Next;
               end;
               savebody.Free;
            except
              answer.Body.SetValueByKey('status','fail');
              send(answer);
            end;

              end
              else begin
                try
                 sqlquery.ExecSQL;
                 send(answer);
                except
                   answer.Body.SetValueByKey('status','fail');
                   send(answer);
                end;
              end;
           end;
      end;
end;

end.

