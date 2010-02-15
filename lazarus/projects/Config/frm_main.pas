unit frm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, Menus, ComCtrls, PairSplitter, Grids, StdCtrls, Buttons,
  uxPLMessage,  uxPLListener, ExtCtrls, uxPLPluginFile,
  v_msgbody_stringgrid, v_xplmsg_opendialog;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    About: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    HBDetail: TBodyMessageGrid;
    Label2: TLabel;
    Label3: TLabel;
    Load: TAction;
    Memo1: TMemo;
    MenuItem10: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Save: TAction;
    Send: TAction;
    Rescan: TAction;
    Label1: TLabel;
    ActionList1: TActionList;
    BtnRefresh: TBitBtn;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Quit: TAction;
    SaveDialog: TSaveDialog;
    sgModules: TStringGrid;
    sgStats: TStringGrid;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    xPLMsgSaveDlg: TxPLMsgSaveDialog;
    procedure AboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HBDetailEditingDone(Sender: TObject);
    procedure HBDetailEnter(Sender: TObject);
    procedure HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
    procedure MsgGridHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
    procedure QuitExecute(Sender: TObject);
    procedure RescanExecute(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure SendExecute(Sender: TObject);
    procedure sgModulesSelection(Sender: TObject; aCol, aRow: Integer);
  private
    CfgListList : TList;
    CfgCurrList : TList;
    CfgPlugin   : TList;
    procedure OnMessageReceived(const axPLMessage : TxPLMessage);
    procedure SendConfigResponse;
    procedure OnJoined(const aJoined : boolean);
//    procedure ClearConfigGrid;
  public
    iSelectedModule : integer;
    bConfirmExit : boolean;
    xPLClient : TxPLListener;
  end;

var
  FrmMain: TFrmMain;

  Const
     K_XPL_APP_VERSION : string = '0.9.5';
     K_XPL_APP_NAME = 'xPL Config';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'config';

implementation { TFrmLogger =====================================================}
uses frm_About, uxplMsgHeader, LCLType, uxPLConst,
     uxPLConfig, uxPLAddress, uxPLMsgBody;

procedure TFrmMain.FormCreate(Sender: TObject);
var i : integer;
begin
  Self.Caption := K_XPL_APP_NAME;
  xPLMsgSaveDlg.FilterIndex := 2;
  bConfirmExit := False;

  xPLClient := TxPLListener.Create(self,K_DEFAULT_VENDOR,K_DEFAULT_DEVICE,K_XPL_APP_NAME,K_XPL_APP_VERSION);
  xPLClient.OnxPLReceived  := @OnMessageReceived;
  xPLClient.OnxPLJoinedNet := @OnJoined;

  CfgListList := TList.Create;
  CfgCurrList := TList.Create;
  CfgPlugIn   := TList.Create;

  for i:=0 to sgModules.Columns.Count-1 do
      sgModules.Columns[i].Title.ImageIndex := -1;           // No sort order by default ==> no image

  HBDetail.Clear;
  xPLClient.Listen;
  RescanExecute(self);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  xPLClient.destroy;
  CfgListList.Destroy;
  CfgCurrList.Destroy;
  CfgPlugIn.Destroy;
end;

procedure TFrmMain.AboutExecute(Sender: TObject);
begin FrmAbout.ShowModal; end;

procedure TFrmMain.OnJoined(const aJoined: boolean);
var sHubStatus : string;
begin
  if aJoined then sHubStatus := 'Hub found' else sHubStatus := 'Hub not found';
  StatusBar1.Panels[0].Text := sHubStatus;
  xPLClient.AwaitingConfiguration:=False;
end;

procedure TFrmMain.MsgGridHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
const imgdown = 11;
      imgup = 10;
var i  : integer;
begin
    if not IsColumn then exit;
    with sgModules.Columns[Index].Title do begin
         for i:=0 to sgModules.Columns.Count-1 do          // unsort other columns
             if i<>Index then sgModules.Columns[i].Title.ImageIndex := -1;
         If ImageIndex = imgdown then begin
            ImageIndex := imgup;
            sgModules.SortOrder := soAscending
         end else begin
             ImageIndex := imgdown;
             sgModules.SortOrder := soDescending;
         end;
         sgModules.SortColRow(true,Index);
    end;
end;


procedure TFrmMain.QuitExecute(Sender: TObject);
begin
   if (not bConfirmExit) or
     (Application.MessageBox('Do you want to close ?','Confirm',MB_YESNO) = IDYES)
   then Close;

end;

procedure TFrmMain.SendConfigResponse;
var i : integer;
    moduletag,newtag,s,key,value : string;
begin
     s := '';
     moduletag := sgModules.Cells[0,iSelectedModule+1];
     newtag    := moduletag;
     for i := 1 to HBDetail.Rowcount-1 do begin   // Browse all configuration items
           key := HBDetail.GetKey(i);
            s += HBDetail.GetKeyValuePair(i) + #10;
            if key='newconf' then begin             // Handle special case of module name
               value := HBDetail.GetValue(i);
               sgModules.Cells[3,iSelectedModule+1] := value;
//               sgModules.Cells[0,iSelectedModule+1] := TxPLAddress.ComposeAddress( sgModules.Cells[1,iSelectedModule+1],
//                                                                       sgModules.Cells[2,iSelectedModule+1],
//                                                                       sgModules.Cells[3,iSelectedModule+1] );
               newtag := TxPLAddress.ComposeAddress( sgModules.Cells[1,iSelectedModule+1],
                                                                       sgModules.Cells[2,iSelectedModule+1],
                                                                       sgModules.Cells[3,iSelectedModule+1] );
                sgModules.Cells[0,iSelectedModule+1] := newtag;
            end;
     end;
     if length(s)>0 then
     xPLClient.SendMessage( xpl_mtCmnd, moduletag, 'config.response'#10'{'#10+ s + '}'#10);
     xPLClient.SendMessage( xpl_mtCmnd, newtag, 'config.current'#10'{'#10'command=request'#10'}'#10);
end;



procedure TFrmMain.RescanExecute(Sender: TObject);
begin
     CfgListList.Clear;
     CfgCurrList.Clear;
     CfgPlugIn.Clear;
     sgModules.RowCount := 1;
    xPLClient.SendMessage(xpl_mtCmnd,'*','hbeat.request'#10'{'#10'command=request'#10'}'#10);
end;

procedure TFrmMain.SaveExecute(Sender: TObject);
//var aFileName : string;
begin
    if xPLMsgSaveDlg.Execute then begin
  //     aFileName := xPLMsgSaveDlg.FileName;

    end;
end;

procedure TFrmMain.SendExecute(Sender: TObject);
begin
     SendConfigResponse;
end;

procedure TFrmMain.HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
var k : string;
    //aConfig : TxPLConfig;
    //CfgItemId : integer;
begin
     if iSelectedModule < 1 then exit;
     k := HBDetail.GetKey(aRow);
     label2.Caption:=k;
     //aConfig := TxPLConfig(CfgPlugin[iSelectedModule]);
     //if aConfig<>nil then begin
        //CfgItemId := aConfig.ItemByName(k);
        {if CfgItemId<>-1 then begin                   ADD HERE HOW TO GET DESCRIPTION OF THE ITEM
           Label2.Caption := aConfig.Item[CfgItemId].Description;
        end;}
     //end;
end;

procedure TFrmMain.HBDetailEditingDone(Sender: TObject);
var k : string;
    aConfig : TxPLConfig;
    CfgItemId : integer;
begin
     if iSelectedModule < 0 then exit;
     k := HBDetail.GetKey(HBDetail.Row);
     aConfig := TxPLConfig(CfgPlugin[iSelectedModule]);
     if aConfig<>nil then begin
        CfgItemId := aConfig.ItemByName(k);
        if CfgItemId<>-1 then begin
           //label3.Visible := not
           aConfig.Item[CfgItemId].SetValue(HBDetail.GetValue(HBDetail.Row));
        end;
     end;
end;

procedure TFrmMain.HBDetailEnter(Sender: TObject);
begin
     label2.Caption := HBDetail.GetKey(HBDetail.Row);

end;

procedure TFrmMain.sgModulesSelection(Sender: TObject; aCol, aRow: Integer);
var //j : integer;
    aBody : TxPLMsgBody;
    //s: string;
        //aConfig : TxPLConfig;
begin
   if aRow<1 then exit;

 {  if Application.MessageBox( pchar('Configuration for module "' + sgModules.Cells[0,iSelectedModule+1] + '" has changed.' +
                                 #10#13'Do you want to save changes'),'Save', MB_YESNO) = IDYES
                                 then SendConfigResponse;}

   iSelectedModule := aRow - 1;

   HBDetail.Visible := False;
   HBDetail.Clear;     
   //HBDetail.PossibleKeys.Clear;
   if (sgModules.Cells[5,aRow]='Ok') or (sgModules.Cells[6,aRow]='Ok') then begin
      HBDetail.Visible := True;

      aBody := TxPLMsgBody(CfgCurrList[iSelectedModule]);
      HBDetail.Assign(aBody);

 {     aBody := TxPLMsgBody(CfgListList[iSelectedModule]);
      for j:=0 to aBody.ItemCount-1 do begin
          s := aBody.Values[j];
          if CopyRight(s,1) =']' then
             //HBDetail.PossibleKeys.Add( CopyLeft(s, PosChar('[',s)-1))
          else
             if (HBDetail.Cols[1].IndexOf(s)=-1) then begin
                HBDetail.Cells[1,HBDetail.RowCount-1] := s;
                HBDetail.RowCount := HBDetail.RowCount +1;
             end;
      end;}
   end;
   //if (sgModules.Cells[7,aRow]='Ok') then begin
      //aConfig := TxPLConfig(CfgPlugin[iSelectedModule]);
      //for j:=0 to aConfig.Count-1 do HBDetail.PossibleKeys.Add(aConfig[j].Key);
   //end;

end;

procedure TFrmMain.OnMessageReceived(const axPLMessage: TxPLMessage);
var aBody : TxPLMsgBody;
    aConfig : TxPLConfig;
    i, plugid, devid : integer;
    aPlugIn : txPLPluginFile;
    aDevice : txPLDevice;
begin
   i := sgModules.Cols[0].IndexOf(axPLMessage.Header.Source.Tag)-1;
   if i>=0 then begin                                               // This module is already known
      if not ((axPLMessage.Body.Keys.Count>0 ) and (axPLMessage.Body.Keys[0]='command') and (axPLMessage.Body.Values[0]='request')) then begin      // Don't handle config request messages
         if axPLMessage.Body.Schema.Tag = 'config.current' then begin
            if axPLMessage.Body.Keys.Count > 0 then begin
               aBody := TxPLMsgBody(CfgCurrList[i]);
               aBody.Assign(axPLMessage.Body);
               sgModules.Cells[5,i+1] := 'Ok';
               sgModules.Cells[4,i+1] := aBody.GetValueByKey('interval');
               sgModules.Refresh ;
            end;
         end else if axPLMessage.Body.Schema.Tag = 'config.list' then begin
            aBody := TxPLMsgBody(CfgListList[i]);
            aBody.Assign(axPLMessage.Body);
            sgModules.Cells[6,i+1] := 'Ok';
            sgModules.Refresh ;
         end;
      end;
   end else                                                        // Tbis module is just discovered
       if ((axPLMessage.Schema.Tag='hbeat.app') or (axPLMessage.Schema.Tag='config.app')) then with axPLMessage do begin
          sgModules.RowCount := sgModules.RowCount+1;
          sgModules.Cells[0,sgModules.RowCount-1] := Source.Tag;
          sgModules.Cells[1,sgModules.RowCount-1] := Source.Vendor;
          sgModules.Cells[2,sgModules.RowCount-1] := Source.Device;
          sgModules.Cells[3,sgModules.RowCount-1] := Source.Instance;

          CfgListList.Add(TxPLMsgBody.Create);
          CfgCurrList.Add(TxPLMsgBody.Create);
          xPLClient.SendMessage(xpl_mtCmnd,Source.Tag,'config.list'#10'{'#10'command=request'#10'}'#10);
          xPLClient.SendMessage(xpl_mtCmnd,Source.Tag,'config.current'#10'{'#10'command=request'#10'}'#10); 

          PlugId := xPLClient.PluginList.Plugin.IndexOf(Source.Vendor);
          if PlugId=-1 then begin                                       // Have we got a plug-in file for this vendor
             sgModules.Cells[7,sgModules.RowCount-1] := 'NF';
             CfgPlugIn.Add(nil);
          end else begin                                                // We've got one, then now do we have a schema for this device ?
              aPlugIn := TxPLPluginFile(xPLClient.PluginList.Plugin.Objects[plugid]);
              DevId   := aPlugIn.Devices.IndexOf(Source.Device);
              if DevId = -1 then begin
                 sgModules.Cells[7,sgModules.RowCount-1] := 'NF';
                 CfgPlugIn.Add(nil);
              end else begin
                 sgModules.Cells[7,sgModules.RowCount-1] := 'Ok';
                 aConfig := TxPLConfig.Create(xPLClient);
                 aDevice := aPlugin.Device(Source.Device);
//                 aConfig.ReadFromXML( aPlugin.Device(Source.Device ));
                 aConfig.ReadFromXML( aDevice.Node);
                 CfgPlugin.Add(aConfig);
              end;
          end;
       end;
end;

initialization
  {$I frm_main.lrs}

end.

