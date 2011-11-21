unit u_xpl_xhcp;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, IdTelnetServer
     , IdTelnet;

type
     TXHCPDataAvailEvent = procedure (const ansType : integer; const Buffer: TStringList) of object;

       { TXHCPServer ============================================================}
     TXHCPServer = class(TIdTelnetServer)                                       // Connexion used to listen XHCP messages
        public
           constructor Create(const aOwner : TComponent);
     end;

     { TXHCPClient }

     TXHCPClient = class(TIdTelnet)
     private
        fOnAnswerAvailable : TXHCPDataAvailEvent;
        BigBuff : TStringList;
        ResponsePending : boolean;
     protected
        procedure DataAvailable(Sender: TIdTelnet; const Buffer: String);
     public
        constructor Create(const aOwner : TComponent);
        destructor  Destroy; override;
        procedure   Connect; override;
        procedure   Send(const aString : string);

        property OnAnswerAvailable : TXHCPDataAvailEvent read fOnAnswerAvailable write fOnAnswerAvailable;
     end;

implementation

uses u_xpl_common
     , StrUtils;

// TXHCPServer ===============================================================
constructor TXHCPServer.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   DefaultPort  := XPL_UDP_BASE_PORT;
   LoginMessage := '';
   Active       := True;
end;

{ TXHCPClient }

constructor TXHCPClient.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);

   Port  := XPL_UDP_BASE_PORT;
   OnDataAvailable := @DataAvailable;
   ResponsePending := false;
   BigBuff := TStringList.Create;
   BigBuff.Delimiter:=#13;
   BigBuff.StrictDelimiter:=true;
end;

destructor TXHCPClient.Destroy;
begin
   BigBuff.Free;
   inherited Destroy;
end;

procedure TXHCPClient.DataAvailable(Sender: TIdTelnet; const Buffer: String);
var newbuff : string;
    response_code : string;
    response_start: integer;
    iresponse : integer = -1;
begin
   NewBuff := AnsiReplaceStr(Buffer,#10,'');
   if not ResponsePending then begin
      BigBuff.DelimitedText := NewBuff;
      ResponsePending := (AnsiPos('follows',BigBuff[0]) <> 0);
   end else
      BigBuff.DelimitedText := BigBuff.DelimitedText + #13 + NewBuff;

   if BigBuff[BigBuff.Count-1] = ''  then BigBuff.Delete(BigBuff.Count-1);
   if BigBuff[BigBuff.Count-1] = '.' then ResponsePending := false;

   if not ResponsePending then begin
     iResponse := StrToIntDef(AnsiLeftStr(BigBuff[0],3),-1);
     BigBuff[0] := AnsiRightStr(BigBuff[0], length(BigBuff[0])-4);
     if AnsiPos('follows',BigBuff[0])<>0 then BigBuff.Delete(0);
     if BigBuff[BigBuff.Count-1]='.' then BigBuff.Delete(BigBuff.Count-1);
     OnAnswerAvailable(iResponse, bigbuff);
   end;
end;

procedure TXHCPClient.Connect;
begin
   if Connected then Disconnect;
   inherited Connect;
end;

procedure TXHCPClient.Send(const aString: string);
var ch : char;
begin
   for ch in aString do SendCh(ch);
   SendCh(#13);
end;

end.

