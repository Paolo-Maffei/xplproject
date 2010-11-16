unit frm_setupinstance;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,frm_main,
  ComCtrls, Buttons, StdCtrls, v_msgbody_stringgrid, Grids,
  v_xplmsg_opendialog;

type

  { TfrmSetupInstance }

  TfrmSetupInstance = class(TForm)
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    HBDetail: TBodyMessageGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    OpenMessage: TxPLMsgOpenDialog;
    tbOk: TToolButton;
    tbOk1: TToolButton;
    tbOk2: TToolButton;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    xPLMsgSaveDlg: TxPLMsgSaveDialog;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HBDetailEditingDone(Sender: TObject);
    procedure HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
    procedure tbOk2Click(Sender: TObject);
    procedure tbOkClick(Sender: TObject);
  private
  public
    Configuration : TConfigurationRecord;
  end;

var
  frmSetupInstance: TfrmSetupInstance;

implementation // ==============================================================
uses frm_About,
     uxPLMessage,
     uxPLAddress,
     cStrings,
     uxPLConst,
     u_xml_xplplugin,
     uRegExpr,
     app_main;

procedure TfrmSetupInstance.FormShow(Sender: TObject);
var aMessage : TxPLMessage;
    j : integer;
    s : string;
begin
   Caption := 'Configuration of ' + TxPLAddress.ComposeAddress(Configuration.Vendor,Configuration.Device,Configuration.Instance);
   ToolBar3.Images := frmAbout.ilStandardActions;
   HBDetail.Clear;
   HBDetail.PossibleKeys.Clear;
   HBDetail.Visible := True;
   Label3.Visible := false;

   aMessage := TxPLMessage.create;
   aMessage.Body.RawxPL := Configuration.config_current ;
   HBDetail.Assign(aMessage.Body);

   aMessage.Body.RawxPL := Configuration.config_list ;
   for j:=0 to aMessage.Body.ItemCount-1 do begin
       s := aMessage.Body.Values[j];
       if CopyRight(s,1) =']' then
             HBDetail.PossibleKeys.Add( CopyLeft(s, PosChar('[',s)-1))
   end;

   if Assigned(Configuration.Plug_Config) then
      for j:=0 to Configuration.Plug_Config.Count-1 do HBDetail.PossibleKeys.Add(Configuration.Plug_Config [j].Name);

   aMessage.Destroy;
end;



procedure TfrmSetupInstance.BitBtn3Click(Sender: TObject);
var aMessage  : TxPLMessage;
begin
    if xPLMsgSaveDlg.Execute then begin
       aMessage := TxPLMessage.Create;
       HBDetail.CopyTo(aMessage.Body);
       aMessage.SaveToFile(xPLMsgSaveDlg.FileName);
       AMessage.Destroy;
    end;
end;

procedure TfrmSetupInstance.BitBtn2Click(Sender: TObject);
begin
    if not OpenMessage.Execute then exit;
    with TxPLMessage.Create do begin
      LoadFromFile(OpenMessage.FileName);
      HBDetail.Assign(Body);
      Destroy;
    end;
end;

procedure TfrmSetupInstance.HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
var confitem : TXMLConfigItemType;
begin
   if not Assigned(Configuration.Plug_Config) then exit;
   memo1.lines.Clear ;
   label2.Caption := HBDetail.GetKey(aRow);
   confitem := Configuration.Plug_Config.ItemName[label2.Caption];
   if assigned(confitem) then begin
      memo1.Lines.Add(confitem.description);
      label1.Caption := confitem.Format;
   end;
end;

procedure TfrmSetupInstance.tbOk2Click(Sender: TObject);
begin Close; end;

procedure TfrmSetupInstance.HBDetailEditingDone(Sender: TObject);
var f,s : string;
    confitem : TXMLConfigItemType;
    fValidator : TRegExpr;
begin
   if not Assigned(Configuration.Plug_Config) then exit;                                  // The plugin may be absent
   confitem := Configuration.Plug_Config.ItemName[HBDetail.GetKey(HBDetail.Row)];
   if confitem = nil then exit;                                                           // The plugin may be outdated
   f := confItem.Format;
   if length(f)>0 then begin
      fValidator  := TRegExpr.Create;
      fValidator.Expression := f;
      s:=HBDetail.GetValue(HBDetail.Row);
      label3.Visible := not fValidator.Exec(s);
      fValidator.Destroy;
   end;
end;


procedure TfrmSetupInstance.tbOkClick(Sender: TObject);
var i : integer;
    moduletag,newtag,s,key : string;
begin
     s := '';
     moduletag := TxPLAddress.ComposeAddress(Configuration.Vendor,Configuration.Device,Configuration.Instance);
     newtag    := moduletag;
     for i := 1 to HBDetail.Rowcount-1 do begin   // Browse all configuration items
           key := HBDetail.GetKey(i);
            s += HBDetail.GetKeyValuePair(i) + #10;
            if key='newconf' then begin             // Handle special case of module name
//               value := HBDetail.GetValue(i);
               newtag := TxPLAddress.ComposeAddress( Configuration.Vendor,Configuration.Device,HBDetail.GetValue(i));
            end;
     end;
     if length(s)>0 then
     xPLClient.SendMessage( K_MSG_TYPE_CMND, moduletag, 'config.response',#10'{'#10+ s + '}'#10);
     xPLClient.SendMessage( K_MSG_TYPE_CMND, newtag, 'config.current',#10'{'#10'command=request'#10'}'#10);
end;

initialization
  {$I frm_setupinstance.lrs}

end.

