unit sql_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses Classes
     , SysUtils
     , zConnection
     , u_xpl_db_listener
     , u_xpl_config
     , u_xpl_message
     ;

type

{ TxPLSqlListener }

     TxPLSqlListener = class(TxPLDBListener)
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        procedure   UpdateConfig; override;
        procedure   Preprocess(const aMessage : TxPLMessage);
        procedure   Process(const aMessage : TxPLMessage);
     published
     end;

implementation // =============================================================
uses u_xpl_common
     , u_xpl_header
     , u_xpl_body
     , StrUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;
const //=======================================================================
     rsLoggAll  = 'logging';

// TxPLSqlListener ============================================================

constructor TxPLSqlListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   Config.FilterSet.Add('xpl-cmnd.*.*.*.db.basic');
   Config.DefineItem(rsLoggAll,  TxPLConfigItemType.reconf, 1, 'y');
   fTestTableName := 'log_body';
   fSchemaCreation.Add( 'CREATE TABLE log_header(id int NOT NULL auto_increment,time TIMESTAMP,type char(8) default NULL, source varchar(34) default NULL,'
                        + ' target varchar(34) default NULL, class varchar(15) default NULL, PRIMARY KEY (id),'
                        + 'KEY class_idx (class), KEY type_idx (type));');
   fSchemaCreation.Add( 'CREATE TABLE log_body(id int not null auto_increment, header_id int NOT NULL,name varchar(16) NOT NULL,value varchar(128) default NULL, KEY name_idx (name), KEY header_idx(header_id), PRIMARY KEY (id));');
end;

procedure TxPLSqlListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     if Config.GetItemValue(rsLoggAll) = 'y' then OnPreProcessMsg := @Preprocess else OnPreProcessMsg := nil;
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
   Query.Open;
   if Query.RecordCount=1 then begin
      i := Query.Fields[0].AsInteger;
      s := 'INSERT INTO log_body(header_id,name,value) values (%d,"%s","%s");';
      Query.Close;
      Query.SQL.Clear;
      for j:=0 to aMessage.Body.Keys.Count-1 do
          ExecQuery(Format(s,[i, aMessage.Body.Keys[j], aMessage.Body.Values[j]]));
   end else Query.Close;
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
         Query.SQL.Text := sql;
         if (AnsiContainsText(sql,'select ')) or (AnsiContainsText(sql,'show ')) then begin
            try
               Query.Open;
               savebody := TxPLBody.Create(self);
               savebody.Assign(answer.Body);
               for i:=0 to Query.RecordCount-1 do begin
                 for j:=0 to Query.FieldCount-1 do
                      answer.Body.AddKeyValuePairs([Query.Fields[j].FieldName],[Query.Fields[j].AsString]);
                 answer.Body.CleanEmptyValues;
                 Send(answer);
                 answer.Body.Assign(savebody);
                 Query.Next;
               end;
               savebody.Free;
            except
              answer.Body.SetValueByKey('status','fail');
              answer.Body.CleanEmptyValues;
              send(answer);
            end;

              end
              else begin
                try
                 Query.ExecSQL;
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

