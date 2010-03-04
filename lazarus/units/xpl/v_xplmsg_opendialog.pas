unit v_xplmsg_opendialog;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Dialogs, ExtCtrls, uxPLMsgHeader;

type TxPLMsgOpenDialog = class(TOpenDialog)
     public
        constructor create(aOwner : TComponent); override;
     end;

     TxPLMsgSaveDialog = class(TSaveDialog)
     public
        constructor create(aOwner : TComponent); override;
     end;

     procedure Register;

implementation

ResourceString K_DEFAULT_FILTER = 'xPL Message File|*.xpl|xPL Config File|xpl_*.xml';

procedure Register;
begin
  RegisterComponents('xPL Components',[TxPLMsgOpenDialog, TxPLMsgSaveDialog]);
end;

constructor TxPLMsgOpenDialog.create(aOwner: TComponent);
begin
  inherited create(aOwner);

  Filter := K_DEFAULT_FILTER;
  DefaultExt := 'xpl';
  FilterIndex := 1;                                
end;

constructor TxPLMsgSaveDialog.create(aOwner: TComponent);
begin
  inherited create(aOwner);

  Filter := K_DEFAULT_FILTER;
  DefaultExt := 'xpl';
  FilterIndex := 1;
end;





end.
