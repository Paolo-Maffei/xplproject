unit dirmon_listener;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils,
  u_xpl_listener,
  u_xpl_config,
  u_xpl_actionlist,
  u_xpl_message;

type

{ TxPLdirmonListener }

     TxPLdirmonListener = class(TxPLListener)
     private
        DirectoryList : TStringlist;
        procedure PollDirectories;
        procedure SignalChanged(const aModif : string; const aDirectory : string; const aFileName : string);
     public
        constructor Create(const aOwner : TComponent); reintroduce;
        destructor  Destroy; override;
        procedure   OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass); override;
        procedure   UpdateConfig; override;
        procedure   Preprocess(const aMessage : TxPLMessage);
        procedure   Process(const aMessage : TxPLMessage);
        procedure   DoxPLPrereqMet; override;
     published
        property fDirectoryList : TStringList read DirectoryList;
     end;

implementation
uses u_xpl_common
     , u_xpl_header
     , u_xpl_schema
     , u_xpl_body
     , StrUtils
     , uxPLConst
     , u_xpl_custom_message
     , LResources
     ;

type
      TFileRecord = class
      public
         Size : Int64;
         Time : integer;
         TS   : TDateTime;
      end;

// ===========================================================================================
procedure TxPLdirmonListener.SignalChanged(const aModif : string; const aDirectory: string; const aFileName: string);
begin
   SendMessage(trig,'*','control.basic',['current','device','file'],[aModif,aDirectory,aFileName]);
end;

{ TxPLdirmonListener }

constructor TxPLdirmonListener.Create(const aOwner: TComponent);
begin
   inherited Create(aOwner,'dirmon','clinique','4.0.0');
   include(fComponentStyle,csSubComponent);
   FilterSet.AddValues(['xpl-cmnd.*.*.*.control.basic']);
   FilterSet.AddValues(['xpl-stat.*.*.*.timer.basic']);

   DirectoryList := TStringList.Create;
   DirectoryList.Duplicates:=dupIgnore;
   DirectoryList.Sorted := true;

   PrereqList.Add('timer');
end;

destructor TxPLdirmonListener.Destroy;
begin
   DirectoryList.Free;
   SaveConfig;
   inherited;
end;

procedure TxPLdirmonListener.OnFindClass(Reader: TReader; const AClassName: string; var ComponentClass: TComponentClass);
begin
   if CompareText(AClassName, 'TxPLdirmonListener') = 0 then ComponentClass := TxpldirmonListener
   else inherited;
end;

procedure TxPLdirmonListener.UpdateConfig;
var found : boolean;
begin
  inherited UpdateConfig;
  if Config.IsValid then begin
      OnxPLReceived := @Process;
  end
  else OnxPLReceived := nil;
end;

procedure TxPLdirmonListener.Preprocess(const aMessage: TxPLMessage);
begin
end;

procedure TxPLdirmonListener.Process(const aMessage: TxPLMessage);
var aAction, aDirectory : string;
    i : integer;
    fl : TStringList;
begin
   if not PrereqMet then exit;

    if (aMessage.MessageType = stat) and                                        // Received a timer status message
       (aMessage.Schema.Equals(Schema_TimerBasic)) and
       (aMessage.Body.GetValueByKey('device') = Adresse.RawxPL) and
       (aMessage.Body.GetValueByKey('current') = 'started') then PollDirectories;

    if aMessage.MessageType = cmnd then begin                                   // Received a configuration message
       if aMessage.Schema = Schema_ControlBasic then begin
          aDirectory := aMessage.Body.GetValueByKey('device');                             // Name of the directory or file
          aAction    := aMessage.Body.GetValueByKey('current');                            // Allowed : start / stop
          Log(etInfo,'Directory monitoring on %s to %s',[aDirectory,aAction]);
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

procedure TxPLdirmonListener.DoxPLPrereqMet;
begin
  inherited DoxPLPrereqMet;

//  var config : TXmlConfig;
//    i,maxi,j,maxj : integer;
//    filelist : TStringList;
//    fr : tfilerecord;
////    aMsg : TxPLMessage;
//begin                                                                                     // send hb request to locate clinique-timer
   if not Config.IsValid then exit;
   SendMessage(cmnd,DeviceAddress('timer'),Schema_TimerBasic,['action','device','frequence'],['start',Adresse.RawxPL,'60']);

   //config := xPLClient.Config.XmlFile;
   //maxi := Config.GetValue('dirmon/count',0)-1;
   //for i:=0 to maxi do begin
   //    directorylist.Add(Config.GetValue('dirmon/dir_' + intToStr(i) + '/name',''));
   //    xPLClient.LogInfo('Restoring monitoring on %s',[directorylist[i]]);
   //    FileList:=TStringList.Create;
   //    FileList.Sorted:=true;
   //    FileList.Duplicates:=dupIgnore;
   //    directorylist.objects[i] := filelist;
   //    maxj := Config.GetValue('dirmon/dir_' + intToStr(i) + '/count',0)-1;
   //    for j:=0 to maxj do begin
   //       fr := TFileRecord.Create;
   //       FileList.Add(Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/name',''));
   //       FileList.Objects[j] := fr;
   //       fr.Size:=Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/size',0);
   //       fr.Time:=Config.GetValue('dirmon/dir_'+intToStr(i)+'/file_'+intToStr(j)+'/ts',0);
   //    end;
   //end;
end;

procedure TxPLdirmonListener.PollDirectories;
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

end.

