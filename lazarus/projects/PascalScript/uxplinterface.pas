unit uxplinterface;

{$mode objfpc}{$H+}

interface
uses uxPLWebListener,  uxPLMsgHeader, uxPLGlobals, Classes, XMLCfg, uxPLMessage;

type
    { TxPLInterface }

    TxPLInterface = class(TxPLWebListener)
       fGlobalList : TStringList;   // ==> this should be modified to use TxPLGlobalList
       xPLMessage  : TxPLMessage;
    public
       constructor create(aOwner : TComponent; aVendor, aDevice, aAppName, aAppVersion, aDefaultPort : string);
       destructor destroy; override;

       procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
       procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;

       OnxPLGlobalChanged : TxPLGlobalChangedEvent;

       procedure SendMsg(aMsgType : integer; aTarget,aSchema,aBody : string);
       // Message management functions
       function  MessageType : integer;
       function  MessageSender : string;
       function  MessageSchema : string;
       function  Msg_Class : string;
       function  Msg_Sender_Device: string;
       function  MessageValues : integer;
       function  MessageKey (i : integer) : string;
       function  MessageValue(i : integer) : string;
       function  MessageValueFromKey(s : string) : string;
       // Globals management functions
       function  GlobalValue(aString : string) : string;
       function  GlobalFormer(aString : string) : string;
       function  GlobalCreated(aString : string) : TDateTime;
       function  GlobalModified(aString : string) : TDateTime;
       function  Exists(aString : string; bDelete : boolean) : boolean;
       procedure Value(aString, aValue : string);
       // Logs management functions
       procedure Log(aString : string);
    property
       Globals : tstringlist read fGlobalList;
      // property OnxPLGlobalChanged : TxPLGlobalChangedEvent  read FOnxPLGlobalChanged      write FOnxPLGlobalChanged;
    end;

implementation { TxPLInterface ================================================}
uses
  SysUtils,StrUtils;

constructor TxPLInterface.create(aOwner: TComponent; aVendor, aDevice, aAppName, aAppVersion, aDefaultPort : string);
begin
  inherited create(aOwner, aVendor, aDevice, aAppName, aAppVersion,aDefaultPort );
  fGlobalList := TStringList.Create;
  fGlobalList.Duplicates:=dupIgnore;
  fGlobalList.Sorted := true;
  xPLMessage := TxPLMessage.Create;
end;

destructor TxPLInterface.destroy;
begin
  fGlobalList.Destroy;
  xPLMessage.Destroy;
  inherited destroy;
end;

procedure TxPLInterface.WriteToXML(const aCfgfile: TXmlConfig;  const aRootPath: string);
var i : integer;
begin
    for i:=0 to fGlobalList.Count-1 do
        TxPLGlobalValue(fGlobalList.Objects[i]).WriteToXML(aCfgfile, aRootPath + '/Global_' + intToStr(i));
    aCfgfile.SetValue(aRootPath + '/GlobalCount', fGlobalList.Count);
end;

procedure TxPLInterface.ReadFromXML(const aCfgfile: TXmlConfig;   const aRootPath: string);
var i,newGlobal : integer;
    aGlobal  : TxPLGlobalValue;
begin
   i := StrToInt(aCfgfile.GetValue(aRootPath +'/GlobalCount', '0')) - 1;
   while i>=0 do begin
       aGlobal := TxPLGlobalValue.Create;
       aGlobal.ReadFromXML(aCfgfile, aRootPath + '/Global_' + intToStr(i));
       newGlobal := fGlobalList.Add(aGlobal.fName);
       fGlobalList.Objects[newGlobal] := aGlobal;
      dec(i);
   end;
end;

procedure TxPLInterface.SendMsg(aMsgType : integer; aTarget,aSchema,aBody : string);
begin
   SendMessage(
      TxPLMessageType(aMsgType),
      IfThen(aTarget='','*',aTarget),
      aBody+#10+'{'+#10+aSchema+#10+'}'+#10);
end;

function TxPLInterface.MessageType: integer;
begin result := ord(xPLMessage.MessageType); end;

function TxPLInterface.MessageSender: string;
begin result := xPLMessage.Source.Tag; end;

function TxPLInterface.MessageSchema: string;
begin result := xPLMessage.Schema.Tag; end;

function TxPLInterface.Msg_Class: string;
begin result := xPLMessage.Body.Schema.ClasseAsString; end;

function TxPLInterface.Msg_Sender_Device: string;
begin result := xPLMessage.Header.Source.Device; end;

function TxPLInterface.MessageValues: integer;
begin result := xPLMessage.Body.ItemCount; end;

function TxPLInterface.MessageKey(i: integer): string;
begin
  if i<xPLMessage.Body.ItemCount then result := xPLMessage.Body.Keys[i]
                                  else result := '';
end;

function TxPLInterface.MessageValue(i: integer): string;
begin
  if i<xPLMessage.Body.ItemCount then result := xPLMessage.Body.Values[i]
                                  else result := '';
end;

function TxPLInterface.MessageValueFromKey(s: string): string;
begin
  result := xPLMessage.Body.GetValueByKey(s,'rien trouve');
end;

// Globals manipulation functions ==============================================
function TxPLInterface.Exists(aString: string; bDelete: boolean): boolean;
var i : integer;
begin
   i := fGlobalList.IndexOf(aString);
   result := (i<>-1);
   if result and bDelete then fGlobalList.Delete(i);
end;

function TxPLInterface.GlobalValue(aString: string): string;
var i : integer;
begin
   result := '';
   i := fGlobalList.IndexOf(aString);
   if i<>-1 then result := TxPLGlobalValue(fGlobalList.Objects[i]).Value;
end;

function TxPLInterface.GlobalFormer(aString: string): string;
var i : integer;
begin
   result := '';
   i := fGlobalList.IndexOf(aString);
   if i<>-1 then result := TxPLGlobalValue(fGlobalList.Objects[i]).fFormer;
end;

function TxPLInterface.GlobalCreated(aString: string): TDateTime;
var i : integer;
begin
   result := 0;
   i := fGlobalList.IndexOf(aString);
   if i<>-1 then result := TxPLGlobalValue(fGlobalList.Objects[i]).fCreateTS;
end;

function TxPLInterface.GlobalModified(aString: string): TDateTime;
var i : integer;
begin
   result := 0;
   i := fGlobalList.IndexOf(aString);
   if i<>-1 then result := TxPLGlobalValue(fGlobalList.Objects[i]).fModifyTS;
end;

procedure TxPLInterface.Value(aString, aValue: string);
var i : integer;
    gv : TxPLGlobalValue;
begin
   i := fGlobalList.IndexOf(aString);

   if i=-1 then begin
       i := fGlobalList.Add(aString);
       fGlobalList.Objects[i] := TxPLGlobalValue.Create(aString);
   end;

   gv := TxPLGlobalValue(fGlobalList.Objects[i]);
   if gv.SetValue(aValue) and
      Assigned(OnxPLGlobalChanged) then OnxPLGlobalChanged(gv.fName ,gv.fFormer, gv.Value);
end;

// Globals manipulation functions ==============================================
procedure TxPLInterface.Log(aString: string);
begin LogInfo(aString); end;

end.

