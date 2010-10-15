unit app_main;

{$i compiler.inc}

interface

uses
  Classes, SysUtils,
  CustApp,
  uxPLMessage,
  uxPLWebListener;

type

{ TMyApplication }

TMyApplication = class(TCustomApplication)
     protected
        DirectoryList : TStringlist;
        procedure DoRun; override;
        procedure PollDirectories;
        procedure SignalChanged(const aModif : string; const aDirectory : string; const aFileName : string);
        procedure SaveConfig;
     public
        constructor Create(TheOwner: TComponent); override;
        procedure OnReceived(const axPLMsg : TxPLMessage);
        procedure OnPrereqMet;
        destructor Destroy; override;
        function  ReplaceArrayedTag(const aDevice : string; const aValue : string; const aVariable : string; ReturnList : TStringList) : boolean;
     end;

var  xPLApplication : TMyApplication;
     xPLClient      : TxPLWebListener;

implementation //======================================================================================
uses uxPLConst, FileUtil, StrUtils, XmlCfg;

//=====================================================================================================
const
     K_XPL_APP_VERSION_NUMBER = '0.9';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'dirmon';
     K_DEFAULT_PORT   = '8340';

type
      TFileRecord = class
      public
         Size : Int64;
         Time : integer;
         TS   : TDateTime;
      end;

procedure TMyApplication.DoRun;
var ErrorMsg: String;
begin
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h','help') then begin
    Terminate;
    Exit;
  end;

  while true do begin
        CheckSynchronize;
  end;
  Terminate;
end;

procedure TMyApplication.PollDirectories;
var i,j : integer;
    Folder : string;
    searchresult : TSearchRec;
    filelist : TStringList;
    fr : TFileRecord;
    ts : TDateTime;
    bChanged : boolean;
    filename : string;
begin
   TS := now;
   bChanged := false;
   for i:=0 to DirectoryList.Count-1 do begin
       Folder := DirectoryList[i];
       filelist := TStringList(DirectoryList.Objects[i]);
       if Folder[length(folder)] <> DirectorySeparator
          then begin
                  filename := ExtractFileName(folder);
                  folder := AnsiLeftStr(folder,length(folder)-length(filename));
          end else filename := '*.*';

       ChDir(Folder);
       if FindFirst(filename,faAnyFile,searchResult)=0 then with SearchResult do begin
          Repeat
             if Attr<>faDirectory then begin
                j := filelist.IndexOf(searchResult.Name);
                if  j < 0 then begin // The file wasn't present
                   j := filelist.Add(searchresult.name);
                   fr := TFileRecord.Create;
                   fr.Size:= searchresult.Size;
                   fr.Time:= searchresult.Time;
                   filelist.Objects[j] := fr;
                   SignalChanged('created',Folder,SearchResult.Name);
                   bChanged := true;
                end else begin                                       // Then file is present
                   fr := TFileRecord(filelist.Objects[j]);
                   if (fr.Size<>searchresult.size) or (fr.time<>searchresult.time) then begin
                      fr.Size := searchresult.size;
                      fr.time := searchresult.time;
                     SignalChanged('modified',Folder,SearchResult.Name);
                     bChanged := True;
                   end;
                end;
                fr.ts := ts;
             end;
          until FindNext(SearchResult)<>0;
          for j:=filelist.Count-1 downto 0 do begin
              fr := TFileRecord(filelist.Objects[j]);
              if fr.TS<>ts then begin
                 SignalChanged('deleted',Folder,filelist[j]);
                 filelist.Delete(j);
                 bChanged := true;
              end;
          end;
       end;
   end;
   if bChanged then SaveConfig;
end;

procedure TMyApplication.SignalChanged(const aModif : string; const aDirectory: string; const aFileName: string);
//var aMsg : TxPLMessage;
begin
//   aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_TRIG,'control.basic','*');
//   with aMsg do begin
//        Body.AddKeyValuePair('current',aModif);
   //     Body.AddKeyValuePair('device',aDirectory);
   //     Body.AddKeyValuePair('file',aFileName);
   //     xPLClient.Send(aMsg);
   //     Destroy;
   //end;
   xPLClient.SendMessage(K_MSG_TYPE_TRIG,K_MSG_TARGET_ANY,'control.basic',['current','device','file'],[aModif,aDirectory,aFileName]);
end;

procedure TMyApplication.SaveConfig;
var config : TXmlConfig;
    i,j : integer;
    filelist : TStringList;
    fr : tfilerecord;
begin
   config := xPLClient.Config.XmlFile;
   Config.SetValue('dirmon/count',DirectoryList.Count);
   for i:=0 to DirectoryList.Count-1 do begin
      FileList := TStringList(DirectoryList.Objects[i]);
      Config.DeletePath('dirmon/dir_' + intToStr(i));
      Config.SetValue('dirmon/dir_' + intToStr(i) + '/name', directorylist[i]);
      Config.SetValue('dirmon/dir_' + intToStr(i) + '/count', FileList.Count);
      for j:=0 to FileList.Count-1 do begin
          fr := TFileRecord(filelist.Objects[j]);
          Config.SetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/name',filelist[j]);
          Config.SetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/size',fr.size);
          Config.SetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/ts',fr.time);
      end;
   end;
   Config.Flush;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  DirectoryList := TStringList.Create;
  DirectoryList.Duplicates:=dupIgnore;
  DirectoryList.Sorted := true;
  StopOnException:=True;
  xPLClient := TxPLWebListener.Create(K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_VERSION_NUMBER, K_DEFAULT_PORT);
  with xPLClient do begin
       PassMyOwnMessages:=true;
       OnxPLReceived   := @OnReceived;
       OnxPLPrereqMet  := @OnPrereqMet;
       OnReplaceArrayedTag := @ReplaceArrayedTag;
       PrereqList.Add('timer=0');
  end;
  xPLClient.Listen;
end;

procedure TMyApplication.OnReceived(const axPLMsg: TxPLMessage);

var aAction, aDirectory : string;
    i : integer;
    fl : TStringList;
begin
   if not xPLClient.PrereqMet then exit;

    if (axPLMsg.MessageType = K_MSG_TYPE_STAT) and                                        // Received a timer status message
       (axPLMsg.Schema.Tag = K_SCHEMA_TIMER_BASIC) and
       (axPLMsg.Body.GetValueByKey('device') = xPLClient.Address.Tag) and
       (axPLMsg.Body.GetValueByKey('current') = 'started') then PollDirectories;

    if axPLMsg.MessageType = K_MSG_TYPE_CMND then begin                                   // Received a configuration message
       if axPLMsg.Schema.Tag = K_SCHEMA_CONTROL_BASIC then begin
          aDirectory := axPLMsg.Body.GetValueByKey('device');                             // Name of the directory or file
          aAction    := axPLMsg.Body.GetValueByKey('current');                            // Allowed : start / stop
          xPLClient.LogInfo('Directory monitoring on %s to %s',[aDirectory,aAction]);
          if aAction = 'start' then begin
             i := DirectoryList.Add(aDirectory);
             fl := TStringList.Create;
             fl.Duplicates:=dupIgnore;
             fl.Sorted:=true;
             DirectoryList.Objects[i] := fl;
          end;
          if aAction = 'stop' then begin
             i := DirectoryList.IndexOf(aDirectory);
             fl := TStringList(DirectoryList.Objects[i]);
             fl.Destroy;
             if i<>-1 then DirectoryList.Delete(i);
          end;
       end;
    end;
end;

destructor TMyApplication.Destroy;
begin
   DirectoryList.Destroy;
   xPLClient.Destroy;
   inherited Destroy;
end;

function TMyApplication.ReplaceArrayedTag(const aDevice: string; const aValue: string; const aVariable: string; ReturnList: TStringList): boolean;
var i : integer;
begin
   if aDevice<>K_DEFAULT_DEVICE then exit;
   ReturnList.Clear;

   if aVariable = 'name' then for i:=0 to DirectoryList.Count-1 do ReturnList.Add(DirectoryList[i]);
   result := (ReturnList.Count >0);
end;

procedure TMyApplication.OnPrereqMet;                                // As soon as I'm connected to the xPL Network
var config : TXmlConfig;
    i,maxi,j,maxj : integer;
    filelist : TStringList;
    fr : tfilerecord;
//    aMsg : TxPLMessage;
begin                                                                                     // send hb request to locate clinique-timer
   if xPLClient.Config.ConfigNeeded then exit;
//   aMsg := xPLClient.PrepareMessage(K_MSG_TYPE_CMND,'control.basic',xPLClient.PrereqList.Values['timer']);
//   with aMsg do begin
//      Body.AddKeyValuePair('current','start');
//      Body.AddKeyValuePair('device',xPLClient.Address.Tag);
//      Body.AddKeyValuePair('frequence','60');
//      xPLClient.Send(aMsg);
//      Destroy;
//   end;
   xPLClient.SendMessage(K_MSG_TYPE_CMND,xPLClient.PrereqList.Values['timer'],'control.basic',['current','device','frequence'],['start',xPLClient.Address.Tag,'60']);

   config := xPLClient.Config.XmlFile;
   maxi := Config.GetValue('dirmon/count',0)-1;
   for i:=0 to maxi do begin
       directorylist.Add(Config.GetValue('dirmon/dir_' + intToStr(i) + '/name',''));
       xPLClient.LogInfo('Restoring monitoring on %s',[directorylist[i]]);
       FileList:=TStringList.Create;
       FileList.Sorted:=true;
       FileList.Duplicates:=dupIgnore;
       directorylist.objects[i] := filelist;
       maxj := Config.GetValue('dirmon/dir_' + intToStr(i) + '/count',0)-1;
       for j:=0 to maxj do begin
          fr := TFileRecord.Create;
          FileList.Add(Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/name',''));
          FileList.Objects[j] := fr;
          fr.Size:=Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/size',0);
          fr.Time:=Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/ts',0);
       end;
   end;
end;

initialization
   xPLApplication:=TMyApplication.Create(nil);
end.

