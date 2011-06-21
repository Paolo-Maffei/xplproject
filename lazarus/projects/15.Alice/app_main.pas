unit app_main;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

interface

uses Classes
     , CustApp
     , u_xpl_custom_message
     , u_xpl_message
     , u_xpl_config
     , u_xpl_custom_listener
     , uBotLoader
     , uUtils
     ;

type

{ TMyAliceApp }

TMyAliceApp = class(TCustomApplication)
     protected
        kEntry : string;
        bAlreadySetup : boolean;
        RefMessage : TxPLCustomMessage;
        _LoaderThread:TBotLoaderThread;
        _SentenceSplitter:TStringTokenizer;

        procedure DoRun; override;
        procedure Entry(aEntry : string);
        Procedure AddUserInput(s:string);
        Procedure AddBotReply(s:string);
        Procedure ChatLog(who, what : string);
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnCmndReceived(const aMsg : TxPLMessage);
        destructor Destroy; override;
        procedure OnConfigDone(const fConfig : TxPLCustomConfig);
     end;

var  MyAliceApp : TMyAliceApp;
     xPLClient  : TxPLCustomListener;

implementation //===============================================================
uses u_xpl_common
     , u_xpl_header
     , SysUtils
     , UAIMLLoader
     , UElementFactory
     , UElements
     , UPatternMatcher
     , UTemplateProcessor
     , UVariables
     , LibXMLParser
     , Keyboard
     ;

procedure TMyAliceApp.DoRun;
var  k : TKeyEvent;
     s : string;
begin
   K := PollKeyEvent;
   if K<>0 then begin
      K := GetKeyEvent;
      K := TranslateKeyEvent(K);
      S := KeyEventToString(K);
      if s = #13 then begin
         Entry(kEntry);
         writeln('');
      end else begin
        write(s);
        kEntry := kEntry + s;
      end;
   end;
   CheckSynchronize(50);
end;

procedure TMyAliceApp.Entry(aEntry: string);
var
  reply:string;
  Match:TMatch;
  i:integer;
begin
  if aEntry = 'quit' then terminate
  else begin
     AddUserInput(aEntry);
     Memory.setVar('input',aEntry);
     aEntry:=Trim(ConvertWS(Preprocessor.process(' '+aEntry+' '),true));

     _SentenceSplitter.SetDelimiter(SentenceSplitterChars); {update, if we're still loading}
     _SentenceSplitter.Tokenize(aEntry);

     for i:=0 to _SentenceSplitter._count-1 do begin
         aEntry:=Trim(_SentenceSplitter._tokens[i]);
         Match:=PatternMatcher.MatchInput(aEntry);
         reply:=TemplateProcessor.Process(match);
         match.free;
     end;

     AddBotReply(reply);
       //AddLogMessage('Nodes traversed: '+inttostr(PatternMatcher._matchfault));
       //Add('');
     reply:=PreProcessor.process(reply);
     _SentenceSplitter.SetDelimiter(SentenceSplitterChars);
     _SentenceSplitter.Tokenize(reply);

     Memory.setVar('that',_SentenceSplitter.GetLast);
     kEntry := '';
  end;
end;

procedure TMyAliceApp.AddUserInput(s: string);
var aName:string;
begin
   aName:=Memory.getVar('name');
   if aName='' then aName:='user';
   chatlog(aName,s);
end;

procedure TMyAliceApp.ChatLog(who,what : string);
begin
   writeln(Who + '> ' + what);
end;

procedure TMyAliceApp.AddBotReply(s: string);
begin
   if s='' then exit;
//   RichEdit1.SelStart:=Length(RichEdit1.TExt);
//   Add(s);
   Chatlog(Memory.GetProp('name'),s);
   with RefMessage do begin
        Body.ResetValues ;
        MessageType := Cmnd;
        Schema.RawxPL := 'tts.basic';
        Body.AddKeyValuePairs(['speech'],[s]);                   // date and time of prevision creation at weather.com
        xPLClient.Send(RefMessage);
        writeln(s);
   end;
end;

constructor TMyAliceApp.Create(TheOwner: TComponent);
begin
   inherited Create(TheOwner);
   InitKeyboard;
   bAlreadySetup := false;

   xPLClient := TxPLCustomListener.Create(nil);

   xPLClient.OnxPLConfigDone := @OnConfigDone;
   xPLClient.OnxPLReceived   := @OnCmndReceived;

   xPLClient.Config.FilterSet.AddValues(['xpl-cmnd.*.*.*.tts.basic']);
   xPLClient.Listen;
   kEntry := '';
end;

procedure TMyAliceApp.OnConfigDone(const fConfig: TxPLCustomConfig);
begin
   if not bAlreadySetup then begin
      bAlreadySetup := true;
      RefMessage    := xPLClient.PrepareMessage(cmnd,'tts.basic');

      xPLClient.Log(etInfo,'Starting PASCALice v1.5');

      PatternMatcher:=TPatternMatcher.Create;
      TemplateProcessor:=TTemplateProcessor.Create;
      Memory:=Tmemory.create;
      AIMLLoader:=TAIMLLoader.create;
      BotLoader:=TBotLoader.Create;
      Preprocessor:=TSimpleSubstituter.create;

      _LoaderThread:=TBotLoaderThread.Create(true);
      _LoaderThread.Resume;
      _SentenceSplitter:=TStringTokenizer.Create(SentenceSplitterChars);
      xPLClient.Log(etInfo,'q to quit');
   end;
end;

procedure TMyAliceApp.OnCmndReceived(const aMsg: TxPLMessage);
begin
   entry(aMsg.Body.GetValueByKey('speech'));
end;

destructor TMyAliceApp.Destroy;
begin
   if Assigned(PatternMatcher) then PatternMatcher.Free;
   if Assigned(TemplateProcessor) then TemplateProcessor.Free;
   if Assigned(Memory) then Memory.Free;
   if Assigned(AIMLLoader) then AIMLLoader.Free;
   if Assigned(BotLoader) then BotLoader.Free;
   if Assigned(ElementFactory) then ElementFactory.Free;
   if Assigned(preprocessor) then preprocessor.Free;
   if assigned(RefMessage) then RefMessage.Destroy;
   DoneKeyboard;
   xPLClient.Destroy;
   inherited Destroy;
end;

initialization
   MyAliceApp:=TMyAliceApp.Create(nil);
end.

