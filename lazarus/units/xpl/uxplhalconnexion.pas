unit uxPLHalConnexion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdTelnet, u_xPL_Address;

type
    TxPLHalConfigured = procedure of object;
    { TxPLHalConnexion }

    TxPLHalConnexion = class(TIdTelnet)
    protected
       bWaitingAnswer : integer;
       sLastQuestion  : string;
       procedure DataAvailable(Sender: TIdTelnet; const Buffer: String);
    private
       fHalVersion   : string;
       fXHCPVersion  : string;
       fAddress     : TxPLAddress;
       fGlobals     : TStringList;
       fOnInitialized : TxPLHalConfigured;
       // Capabilities
       bConfigurationManager : char;
       bXAPSupport           : char;
       sDefaultScripting     : char;
       bxPLDeterminators     : char;
       bEvents               : char;
       sPlatform             : char;
       bStateTracking        : char;
    public
       constructor Create;
       destructor  Destroy; override;
       procedure   Connect; override;
       procedure   Send(aString : string);
       property    Address : TxPLAddress read fAddress;
       property    OnInitialized : TxPLHalConfigured read fOnInitialized write fOnInitialized;
    end;



implementation { TxPLHalConnexion }
uses StrUtils;

procedure TxPLHalConnexion.DataAvailable(Sender: TIdTelnet; const Buffer: String);
function AnalyseReponse(const input : string; out comment : string) : integer;
var code : string;
begin
   Result := -1;
   code := AnsiLeftStr(input,3);
   if StrIsInteger(code) then begin
      Result  := StrToInt( code );
      Comment := SysUtils.Trim(AnsiRightStr(input, length(input)-3));
   end
end;
procedure Handle_200_Response(aString : string);                                // 200 xpl-xplhal2.lapfr0005 Version 2.2.3508.37921 XHCP 1.5.0
var sArray : StringArray;
begin
     sArray := StrSplit(aString,' ');
     fAddress.Tag := sArray[0];
     fHalVersion := sArray[2];
     fXHCPVersion := sArray[4];
end;

procedure Handle_236_Response(aString : string);                                // 236 1-P11W0
begin
       bConfigurationManager := aString[1];
       bXAPSupport           := aString[2];
       sDefaultScripting     := aString[3];
       bxPLDeterminators     := aString[4];
       bEvents               := aString[5];
       sPlatform             := aString[6];
       bStateTracking        := aString[7];
end;

var sChaine : string;
    Start, Stop : Integer;
    sList : TStringList;
    ResponseCode : integer;
    Comment : string;

begin
   sList := TStringList.Create;
   Start := 1;
   Stop := Pos(asciiCR, Buffer);
   if Stop = 0 then Stop := Length(Buffer) + 1;
   while Start <= Length(Buffer) do begin
         sChaine := Copy(Buffer, Start, Stop - Start);
         Start := Stop + 1;
         if Start>Length(Buffer) then Break;
         if Buffer[Start] = asciiLF then Start := Start + 1;
         Stop := Start;
         while (Buffer[Stop] <>asciiCR) and (Stop <= Length(Buffer)) do
               Stop := Stop + 1;
         sList.Add(sChaine);
   end;
   ResponseCode := AnalyseReponse(sList[0],Comment);
//   if ResponseCode = bWaitingAnswer then begin
      Case ResponseCode of
        200 : begin // Welcome banner received
            Handle_200_Response(Comment);
            bWaitingAnswer := 236;
            Send('capabilities');
        end;
        236 : begin // Capabilities received
            Handle_236_Response(Comment);
            bWaitingAnswer := 231;
            Send('listglobals');
        end;
        231: begin // Globals list received
                  fGlobals.Clear;
                  start := 1;
                  while Start<sList.Count-1 do begin  // We skip then ending '.'
                        sChaine :=sList[start] ;
                        fGlobals.Add(sList[start]);
                        inc(start);
                  end;
                  if assigned(fOnInitialized) then OnInitialized;
             end;
      end; //end
//   else Send(''); // Relaunch last question
end;

constructor TxPLHalConnexion.Create;
begin
  inherited Create;
  fAddress := TxPLAddress.Create;
  fGlobals := TStringList.Create;
end;

destructor TxPLHalConnexion.Destroy;
begin
  if Connected then Disconnect;
  fAddress.destroy;
  fGlobals.destroy;
  inherited Destroy;
end;

procedure TxPLHalConnexion.Connect;
begin
  Port := 3865;
  ThreadedEvent := True;
  OnDataAvailable := @DataAvailable;
  bWaitingAnswer := 200;
  inherited Connect;
end;

procedure TxPLHalConnexion.Send(aString: string);
var i : integer;
begin
  //if aString<>'' then
  sLastQuestion := UpperCase(aString);
  for i := 1 to length(sLastQuestion) do SendCh(sLastQuestion[i]);
  SendCh(#13);
end;

end.

