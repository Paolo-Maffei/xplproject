unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,  Menus, ActnList, DOM, uxPLSettings,
  Buttons, UBotloader, uUtils, uxPLListener, uxPLMessage, uxPLConfig;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    About: TAction;
    Button1: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    RichEdit1: TMemo;
    StatusBar1: TStatusBar;
    ActionList1: TActionList;
    ImageList: TImageList;
    MainMenu1: TMainMenu;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    Quit: TAction;
    procedure AboutExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure QuitExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    bAlreadySetup : boolean;
    RefMessage : TxPLMessage;
    Procedure Add(s:string);
    Procedure AddUserInput(s:string);
    Procedure AddBotReply(s:string);

    procedure OnConfigDone(const fConfig : TxPLConfig);
    procedure OnJoined(const aJoined : boolean);
    procedure OnTTSBasic(const axPLMsg : TxPLMessage; const aSpeech : string);
    _LoaderThread:TBotLoaderThread;
    _SentenceSplitter:TStringTokenizer;

  public
    xPLClient : TxPLListener;

    Procedure AddLogMessage(s:string);
    Procedure Log(s : string);
    Procedure ChatLog(who, what : string);
  end;

  Const
     K_XPL_APP_VERSION_NUMBER : string = '0.1';
     K_XPL_APP_VERSION_DATE   : string = '2009/xx/xx';
     K_XPL_APP_NAME = 'xPL Chat Bot';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'alxpl';

var  FrmMain: TFrmMain;

implementation //======================================================================================
uses frm_about, SysUtils, uxplmsgheader, uxPLConst,
  UAIMLLoader, UElementFactory ,   UElements,  UPatternMatcher,UTemplateProcessor,UVariables,LibXMLParser;
{ TFrmMain Object ====================================================================================}

procedure TFrmMain.Log(s : string);
begin
   AddLogMessage(s);
   xPLClient.LogInfo(s);
end;

procedure TFrmMain.ChatLog(who,what : string);
begin
     Log(Who + '> ' + what);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var i : integer;
  OnxPLJoinedNet: Pointer;
begin
  Self.Caption := K_XPL_APP_NAME;

  xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_NAME, K_XPL_APP_VERSION_NUMBER);
  xPLClient.OnxPLConfigDone := @OnConfigDone;
  xPLClient.OnxPLJoinedNet  := @OnJoined;
  xPLClient.OnxPLTTSBasic   := @OnTTSBasic;
  OnJoined(False);

  Log('Starting ' + K_XPL_APP_NAME + ' v' + K_XPL_APP_VERSION_NUMBER);
  Log('Waiting xPL configuration to continue');
  bAlreadySetup := false;
  xPLClient.Listen;
end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
var sHubStatus : string;
begin
  if aJoined then sHubStatus := 'Hub found' else sHubStatus := 'Hub not found';
  StatusBar1.Panels[0].Text := sHubStatus;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
    PatternMatcher.Free;
  TemplateProcessor.Free;

  Memory.Free;
  AIMLLoader.Free;
  BotLoader.Free;
  ElementFactory.Free;
//  log.Free;
  preprocessor.Free;

  xPLClient.destroy;
  if assigned(RefMessage) then RefMessage.Destroy;
end;

procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.Button1Click(Sender: TObject);
var
  reply:string;
  Match:TMatch;
  input:String;
  i:integer;
begin
  input:=Memo1.Text;
  AddUserInput(input);
  Memory.setVar('input',input);
  input:=Trim(ConvertWS(Preprocessor.process(' '+input+' '),true));

  _SentenceSplitter.SetDelimiter(SentenceSplitterChars); {update, if we're still loading}
  _SentenceSplitter.Tokenize(input);

  for i:=0 to _SentenceSplitter._count-1 do begin
    input:=Trim(_SentenceSplitter._tokens[i]);
    Match:=PatternMatcher.MatchInput(input);
    reply:=TemplateProcessor.Process(match);
    match.free;
  end;

  AddBotReply(reply);
  //AddLogMessage('Nodes traversed: '+inttostr(PatternMatcher._matchfault));
  Add('');
  reply:=PreProcessor.process(reply);
  _SentenceSplitter.SetDelimiter(SentenceSplitterChars);
  _SentenceSplitter.Tokenize(reply);

  Memory.setVar('that',_SentenceSplitter.GetLast);
  Memo1.Clear;
end;

procedure TFrmMain.QuitExecute(Sender: TObject);
begin Close; end;

procedure TFrmMain.Add(s: string);
begin
   RichEdit1.Lines.Add(s);
   RichEdit1.SelStart:=Length(RichEdit1.TExt);
end;

procedure TFrmMain.OnTTSBasic(const axPLMsg : TxPLMessage; const aSpeech : string);
begin
     Memo1.Text:= aSpeech;
     Button1Click(self);
end;

procedure TFrmMain.OnConfigDone(const fConfig: TxPLConfig);
begin
   if not bAlreadySetup then begin
      bAlreadySetup := true;
      RefMessage    := xPLClient.PrepareMessage(xpl_mtCmnd,'tts.basic');

      Log('xPL Configuration found');
      Log('Starting PASCALice v1.5');

      PatternMatcher:=TPatternMatcher.Create;
      TemplateProcessor:=TTemplateProcessor.Create;
      Memory:=Tmemory.create;
      AIMLLoader:=TAIMLLoader.create;
      BotLoader:=TBotLoader.Create;
      Preprocessor:=TSimpleSubstituter.create;

      _LoaderThread:=TBotLoaderThread.Create(true);
      //BotLoader.load('startup.xml');
      _LoaderThread.Resume;
      _SentenceSplitter:=TStringTokenizer.Create(SentenceSplitterChars);
   end;
end;

procedure TFrmMain.AddUserInput(s: string);
var aName:string;
begin
   //RichEdit1.SelStart:=Length(RichEdit1.TExt);
   //Add('> '+s);
   aName:=Memory.getVar('name');
   if aName='' then aName:='user';
   chatlog(aName,s);
end;

procedure TFrmMain.AddBotReply(s: string);
begin
   if s='' then exit;
   RichEdit1.SelStart:=Length(RichEdit1.TExt);
//   Add(s);
   Chatlog(Memory.GetProp('name'),s);
   with RefMessage do begin
        Body.ResetValues ;
        Header.MessageType := xpl_mtCmnd;
        Schema.Tag := 'tts.basic';
        Body.AddKeyValuePair('speech',s);                   // date and time of prevision creation at weather.com
        send;
   end;
end;

procedure TFrmMain.AddLogMessage(s: string);
begin
   RichEdit1.SelStart:=Length(RichEdit1.TExt);
   Add(s);
end;


initialization
  {$I frm_main.lrs}

end.

