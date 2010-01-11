unit uxPLSingleEvent;

{$mode objfpc}{$H+}

interface

uses
    Classes, XMLCfg, uxPLMessage;

type

  { TxPLSingleEvent }

  TxPLSingleEvent = class(TComponent)
  protected
     fName          : string;
     fEventType     : string;
     fNextExecution : TDateTime;
     fEnabled       : boolean;
     fSingleEvent   : boolean;
     fxPLMessage    : TxPLMessage;
     fMessageToFire : string;
     fDescription   : widestring;
  public
        constructor Create(const aMsg : TxPLMessage);
        constructor Create(const aMsg : TxPLMessage; const aName: string; const bEnabled : boolean; const dtNext : TDateTime);
        function    Edit  : boolean;     dynamic;
        function    Over  : boolean;
        procedure   Check(bAndFire : boolean =true); dynamic;
        procedure   Fire;    dynamic;

        procedure WriteToXML (const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
        procedure ReadFromXML(const aCfgfile : TXmlConfig; const aRootPath : string); dynamic;
        function EnabledAsString : string;
  published
        property Name : string read fName write fName;
        property MessageToFire : string read fMessageToFire write fMessageToFire;
        property Next : TDateTime read fNextExecution write fNextExecution;
        property Enabled : boolean read fEnabled      write fEnabled;

        property IsSingleEvent : boolean read fSingleEvent;
        property TypeAsString  : string read fEventType;
        property Description   : widestring read fDescription write fDescription;
  end;

implementation //===============================================================
uses SysUtils, frm_xPLRecurEvent, frm_xPLSingleEvent, Controls, uxplmsgheader;

constructor TxPLSingleEvent.Create(const aMsg : TxPLMessage);
begin
     Create(aMsg, '', true, now);
end;

constructor TxPLSingleEvent.Create(const aMsg : TxPLMessage; const aName: string; const bEnabled : boolean; const dtNext : TDateTime);
begin
     fName          := aName;
     fEnabled       := bEnabled;
     fNextExecution := dtNext;
     fSingleEvent   := True;
     fEventType     := 'Single';
     fxPLMessage    := aMsg;
     fDescription   := '';
end;

function TxPLSingleEvent.Edit: boolean;
var aForm : TfrmxPLSingleEvent;
begin
     aForm := TfrmxPLSingleEvent.Create(self);
     result := (aForm.ShowModal = mrOk);
     aForm.Destroy;
end;

function TxPLSingleEvent.Over: boolean;
begin
     result := (next <= now());
end;

function TxPLSingleEvent.EnabledAsString: string;
begin
  if Enabled then result := 'Yes' else result := 'No';
end;

procedure TxPLSingleEvent.Check(bAndFire : boolean =true);
begin
   if (Over and Enabled) then begin
      Enabled := false;
      if bAndFire then Fire;
   end;
//     if (enabled and Over) then Fire;
end;

procedure TxPLSingleEvent.Fire;
var aMessage : TxPLMessage;
begin
     if MessageToFire='' then with fxPLMessage do begin
         MessageType := xpl_mtTrig;
         Target.Tag  := '*';
         Body.Format_SensorBasic(fName,'generic','fired');
         Body.Schema.Tag := 'timer.basic';
         Send;
     end else begin
         aMessage:=TxPLMessage.Create(MessageToFire);
         aMessage.Source.Assign(fxPLMessage.Source);
         aMessage.Send;
         aMessage.Destroy ;
     end;
end;

procedure TxPLSingleEvent.WriteToXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   aCfgFile.SetValue(aRootPath + '/Name'     , Name);
   aCfgFile.SetValue(aRootPath + '/Next'     , DateTimeToStr(Next));
   aCfgFile.SetValue(aRootPath + '/Enabled'  , Enabled);
   aCfgFile.SetValue(aRootPath + '/IsSingle' , IsSingleEvent);
   aCfgFile.SetValue(aRootPath + '/MsgToFire' , fMessageToFire);
   aCfgFile.SetValue(aRootPath + '/Description' , fDescription);
end;

procedure TxPLSingleEvent.ReadFromXML(const aCfgfile: TXmlConfig; const aRootPath: string);
begin
   Name         := aCfgFile.GetValue(aRootPath + '/Name', '');
   Next         := StrToDateTime(aCfgFile.GetValue(aRootPath + '/Next', ''));
   Enabled      := aCfgFile.GetValue(aRootPath + '/Enabled', false);
   fSingleEvent := aCfgFile.GetValue(aRootPath + '/IsSingle', true);
   fMessageToFire := aCfgFile.GetValue(aRootPath + '/MsgToFire', '');
   fDescription := aCfgFile.GetValue(aRootPath + '/Description', '');
   Check(false);      // This is done to recalc the event when loaded without firing it
end;


end.

