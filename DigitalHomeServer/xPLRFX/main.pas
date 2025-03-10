(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazSerial, Forms, Controls, Graphics, Dialogs,
  StdCtrls, uxPLRFX, uxPLRFXMessages, u_xpl_custom_listener, u_xpl_config,
  u_xpl_message, u_xpl_common, u_xpl_custom_message, u_xpl_messages,
  u_xpl_application;

type

  { TMainForm }

  TMainForm = class(TForm)
    AboutButton: TButton;
    ConnectButton: TButton;
    Comport: TLazSerial;
    ComportEdit: TEdit;
    CloseButton: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    StatusLabel: TLabel;
    ReadMemo: TMemo;
    ReceiveMemo: TMemo;
    procedure AboutButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure ComportRxData(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
    FTempStr : String;
    CurPos : Integer;
    xPLRFX : TxPLRFX;
    xPLMessages : TxPLRFXMessages;
  public
    { public declarations }
  end;


  { TxPLexecListener }

       TxPLexecListener = class(TxPLCustomListener)
       private
          program_list : TxPLConfigItem;
       public
          constructor Create(const aOwner : TComponent); reintroduce;
          //procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
          procedure   UpdateConfig; override;
          procedure   RawProcess(const aMessage : TxPLMessage);
          procedure   Process(const aMessage : TxPLMessage);
       published
       end;


var
  MainForm: TMainForm;

implementation

{$R *.lfm}

Uses uxPLRFXConst
     , u_xpl_header
     , u_xpl_body
     , uxPLConst
     , About
     ;

{ TxPLListener }

const // ======================================================================
      rsStatus = 'status';
      rsReturn = 'return';
      rsStarted = 'started';
      rsXpl_execStar = '%s: started program %s';
      rsProgram = 'program';
      rsArg = 'arg';
      rsFinished = 'finished';
      rsFailed = 'failed';
      rsXplexecFaile = '%s: failed to start %s: %s';
      rsIgnoredUnabl = '%s : unable to find security declaration of %s';

     // ============================================================================
{ TxPLexecListener }

constructor TxPLexecListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner);
   include(fComponentStyle,csSubComponent);
   FilterSet.AddValues(['*.*.*.*.*.*']);
   Config.DefineItem(rsProgram, TxPLConfigItemType.option, 16);

   OnPreProcessMsg := @RawProcess;
end;

procedure TxPLexecListener.UpdateConfig;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
     OnxPLReceived := @Process;
     program_list  := Config.ConfigItems.FindItemName(rsProgram);
  end
  else OnxPLReceived := nil;
end;

procedure TxPLexecListener.Process(const aMessage: TxPLMessage);
var
  Buffer : BytesArray;
  Count : Integer;
  Len : Integer;
begin
  if aMessage.MessageType = cmnd then
    begin
      try
        MainForm.xPLRFX.xPL2RFX(aMessage,Buffer);
        Count := Buffer[0]+1;
        MainForm.ComPort.WriteBuffer(Buffer,Count);
        uxPLRFXConst.Log('||||||||||||||||||||||||||||||||||||||||||||||||||||||');
        uxPLRFXConst.Log('Received xPL Message : '+aMessage.RawXPL);
        uxPLRFXConst.Log('RFX Data : '+BytesArrayToStr(Buffer));
        MainForm.ReceiveMemo.Lines.Add('Received xPL Message : ');
        MainForm.ReceiveMemo.Lines.Add(aMessage.RawxPL);
        MainForm.ReceiveMemo.Lines.Add('RFX Data : '+Copy(BytesArrayToStr(Buffer),1,Buffer[0]*2));
        MainForm.ReceiveMemo.Lines.Add('=========================================================');
      except
        ;
      end;
    end;
end;

procedure TxPLexecListener.RawProcess(const aMessage: TxPLMessage);
begin

end;


{ TMainForm }

var
  InputString : String;
  ExpectedBytes : Integer = 0;
  ReceivedBytes : Integer;

procedure TMainForm.ComportRxData(Sender: TObject);
var
  Str, TempStr : String;
  LogString : String;
  Data : BytesArray;
  i,j : Integer;
  b : Byte;
begin
  // We received a string of data
  Str := Comport.ReadData;
  // Convert to hex string
  for i := 1 to Length(Str) do
    begin
      // If ExpectedBytes = 0 then first character contains expected bytes
      if ExpectedBytes = 0 then
        ExpectedBytes := Ord(Str[i]);
      InputString := InputString + InttoHex(Ord(Str[i]),2);
      ReceivedBytes := ReceivedBytes + 1;
      if ReceivedBytes >= ExpectedBytes+1 then
        begin
          // Feed it to the xPLRFX parser
          try
            xPLMessages.Clear;
            TempStr := Copy(InputString,1,(ReceivedBytes)*2);
            LogString := xPLRFX.RFX2xPL(HexToBytes(TempStr),xPLMessages);
            ReadMemo.Lines.Add('Received '+ LogString);
            ReadMemo.Lines.Add('RFX Data : '+TempStr);
            Log('===========================================================');
            Log('Received'+LogString);
            Log('RFXData : '+TempStr);
            // See if we have xPL Messages
            for j := 0 to xPLMessages.Count-1 do
              begin
                TxPLExecListener(xPLApplication).Send(xPLMessages[j]);
                ReadMemo.Lines.Add('xPL Message '+IntToStr(j));
                ReadMemo.Lines.Add(xPLMessages[j].RawXPL);
                Log('Sent '+xPLMessages[j].RawxPL);
              end;
            ReadMemo.Lines.Add('=========================================================');
          except
            // Code is unknown or not implemented, leave it like this
            ;
          end;

          // Cut of the part which is already translated
          InputString := Copy(InputString,(ReceivedBytes+1)*2,Length(InputString));
          ReceivedBytes := 0;
          ExpectedBytes := 0;
        end;
      end;
end;

procedure TMainForm.CloseButtonClick(Sender: TObject);
begin
  Comport.Close;
  StatusLabel.Caption := 'Disconnected';
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.ConnectButtonClick(Sender: TObject);
var
  Buffer : array[0..14] of byte;
  i : Integer;
begin
  // Open the serial port
  Comport.Device := ComportEdit.Text;
  try
    // Open the com port
    Comport.Open;
    // Initialize the RFXtrx433
    StatusLabel.Caption := 'Initializing...';
    Application.ProcessMessages;;
    Buffer[0] := $0D;
    for i := 1 to 13 do
      Buffer[i] := $00;
    Comport.WriteBuffer(Buffer,14);
    Sleep(1000);
    Comport.ReadData;
    Buffer[3] := $01;
    Buffer[4] := $02;
    Comport.WriteBuffer(Buffer,14);
    StatusLabel.Caption := 'Connected';
  except
    ShowMessage('Could not open serial port');
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Open the logfile
  OpenLog;
  // Create the gateway object
  xPLRFX := TxPLRFX.Create;
  xPLMessages := TxPLRFXMessages.Create;
  // Instantiate xPL listener
  InstanceInitStyle := iisRandom;
  xPLApplication := TxPLExecListener.Create(Application);
  TxPLExecListener(xPLApplication).Listen;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  CloseLog;
  xPLRFX.Free;
  xPLMessages.Free;
end;

end.

