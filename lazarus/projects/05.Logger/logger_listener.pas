unit Logger_listener;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , fgl
     , u_xpl_message
     , u_xpl_custom_listener
     ;

type TMessageList = specialize TFPGObjectList<TxPLMessage>;

     // TLoggerListener =======================================================
     TLoggerListener = class(TxPLCustomListener)
     private
        fListen : boolean;
        fLogStart : TDateTime;
        fMessageList : TMessageList;
        fLogAtStartUp : boolean;
        fMessageLimit : integer;

        procedure OnPreprocessMessage(const aMessage : TxPLMessage);
        procedure Set_Listen(const AValue: boolean);
     public

        OnMessage   : TxPLReceivedEvent;

        constructor Create; reintroduce;
        destructor  Destroy; override;

     public
        property Listening    : boolean read fListen write Set_Listen;
        property LogStart     : TDateTime read fLogStart;
        property MessageList  : TMessageList read fMessageList;
        property LogAtStartup : boolean read fLogAtStartup write fLogAtStartup;
        property MessageLimit : integer read fmessageLimit write fMessageLimit;
     end;

implementation // ==============================================================
uses u_xpl_messages
     ;

// TLoggerListener =============================================================
constructor TLoggerListener.Create;
begin
   inherited Create(nil);
   fMessageList := TMessageList.Create;
   fMessageList.FreeObjects:=true;
   OnPreProcessMsg := @OnPreprocessMessage;
   if fMessageLimit = 0 then fMessageLimit := 1000;
end;

destructor TLoggerListener.Destroy;
begin
   MessageList.Free;
   inherited;
end;

procedure TLoggerListener.OnPreprocessMessage(const aMessage: TxPLMessage);
begin
   if fListen then begin
      MessageList.Add(MessageBroker(aMessage.RawxPL));
      if Assigned(OnMessage) then OnMessage(MessageList.Last);
      if MessageList.Count>fMessageLimit
         then MessageList.Delete(0);
  end;
end;

procedure TLoggerListener.Set_Listen(const AValue: boolean);
begin
   if fListen<>AValue then begin
      fListen:=AValue;
      if fListen then fLogStart := now;
   end;
end;

end.
