unit uxPLRFXMessages;

interface

Uses uxPLRFXConst, u_xPL_Message, Classes;

type
  TxPLRFXMessages = class     // contains a list of xPL Messages
  private
    FItems : TList;
    function GetxPLMessage(Index : Integer) : TxPLMessage;
  public
    property Items[Index : Integer] : TxPLMessage read GetxPLMessage; default;
    function Add(RawxPL : String) : Integer;
    constructor Create;
    destructor Destroy;
    function Count : Integer;
    procedure Clear;
  end;

implementation

Uses SysUtils;

/////////////////////////
// TxPLRFXMessages

constructor TxPLRFXMessages.Create;
begin
  FItems := TList.Create;
end;

destructor TxPLRFXMessages.Destroy;
begin

end;

function TxPLRFXMessages.GetxPLMessage(Index: Integer) : TxPLMessage;
begin
  Result := TxPLMessage(FItems[Index]);
end;

function TxPLRFXMessages.Add(RawxPL: string) : Integer;
begin
  Result := FItems.Add(TxPLMessage.Create(nil,RawxPL));
end;

function TxPLRFXMessages.Count : Integer;
begin
  Result := FItems.Count;
end;

procedure TxPLRFXMessages.Clear;
var
  i : Integer;
begin
  for i := 0 to FItems.Count-1 do
    TxPLMessage(FItems[i]).Free;   // Free all xPL Messages
  FItems.Clear;                    // Empty the list
end;


end.
