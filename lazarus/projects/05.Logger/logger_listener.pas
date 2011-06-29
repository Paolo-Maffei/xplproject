unit Logger_listener;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , u_xpl_message
     , u_xpl_actionlist
     , u_xpl_custom_listener
     ;

type TMessageList = TList;

     { TLoggerListener }

     TLoggerListener = class(TxPLCustomListener)
     private
        fListen : boolean;
        fLogStart : TDateTime;

        function Get_MessageCount: integer;

        procedure OnPreprocessMessage(const aMessage : TxPLMessage);
        procedure Set_Listen(const AValue: boolean);
     public
        fLogAtStartUp : boolean;
        fMessageLimit : integer;

        MessageList :  TMessageList;
        fooMessage : TxPLMessage;
        OnMessage   : TxPLReceivedEvent;

        constructor Create; reintroduce;
        destructor  Destroy; override;

        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;

        procedure   Set_ConnectionStatus(const aValue : TConnectionStatus); override;
        function    Message(const i : integer) : TxPLMessage;

     published
        property MessageCount : integer read Get_MessageCount stored false;
        property Listening    : boolean read fListen write Set_Listen stored false;
        property LogStart     : TDateTime read fLogStart stored false;

     end;

implementation // ==============================================================
uses uRegExpr
     ;

{ TLoggerListener =============================================================}
constructor TLoggerListener.Create;
begin
   inherited Create(nil);
   MessageList := TMessageList.Create;
   OnPreProcessMsg := @OnPreprocessMessage;
   if fMessageLimit = 0 then fMessageLimit := 1000;
end;

destructor TLoggerListener.Destroy;
begin
   MessageList.Free;
   inherited;
end;

function TLoggerListener.Get_MessageCount: integer;
begin
   result := MessageList.Count;
end;

procedure TLoggerListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, ClassName) = 0 then ComponentClass := TLoggerListener
   else inherited;
end;

procedure TLoggerListener.OnPreprocessMessage(const aMessage: TxPLMessage);
begin
   if fListen then begin
      fooMessage := TxPLMessage.Create(self);
      fooMessage.Assign(aMessage);
      MessageList.Add(fooMessage);
      if MessageList.Count>fMessageLimit then MessageList.Delete(0);
      if Assigned(OnMessage) then OnMessage(fooMessage);
  end;
end;

procedure TLoggerListener.Set_Listen(const AValue: boolean);
begin
   if fListen=AValue then exit;
   fListen:=AValue;
   if fListen then fLogStart := now;
end;

procedure TLoggerListener.Set_ConnectionStatus(const aValue: TConnectionStatus);
begin
   inherited Set_ConnectionStatus(aValue);
end;

function TLoggerListener.Message(const i: integer): TxPLMessage;
begin
   result := TxPLMessage(MessageList[i]);
end;

end.

