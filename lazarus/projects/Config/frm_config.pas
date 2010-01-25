unit frm_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, uxPLListener, uxPLMessage, PairSplitter,
  Buttons, Grids, uxPLSettings;

Const
     K_XPL_CONFIG_VERSION_NUMBER : string = '0.1.1';
     K_XPL_CONFIG_VERSION_DATE   : string = '2009/05/10';


type TFrmConfig = class(TForm)
        btnGetConf: TBitBtn;
        BtnAbout: TBitBtn;
        BtnClose: TBitBtn;
        btnSave: TBitBtn;
    cbListe: TComboBox;
    ImageList1: TImageList;
    Label1: TLabel;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Panel1: TPanel;
    sgHBDetail: TStringGrid;
    StatusBar1: TStatusBar;
    sgModules: TStringGrid;

    procedure BtnAboutClick(Sender: TObject);
    procedure btnGetConfClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbListeEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgHBDetailEditingDone(Sender: TObject);
    procedure sgHBDetailGetEditText(Sender: TObject; ACol, ARow: Integer;       var Value: string);
    procedure sgHBDetailSelectEditor(Sender: TObject; aCol, aRow: Integer;      var Editor: TWinControl);
    procedure sgHBDetailSetEditText(Sender: TObject; ACol, ARow: Integer;       const Value: string);
    procedure sgModulesHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure sgModulesSelection(Sender: TObject; aCol, aRow: Integer);
  private
    sEditedText : string;
    iMessageCount : integer;
    aListener : TxPLListener;
    HBList    : TList;
    CfgListList : TList;
    CfgCurrList : TList;
    procedure OnMessageReceived(axPLMessage : TxPLMessage);
    procedure SendConfigResponse;
    procedure OnJoined(aJoined : boolean);
  public
    iSelectedModule : integer;
  end; 

var FrmConfig: TFrmConfig;

implementation { TFrmConfig ======================================================}
uses frm_about, uxPLAddress,uxPLMsgBody, uxPLMsgHeader, cStrings, LCLType;

// Handling of column sorting
procedure TFrmConfig.sgModulesHeaderClick(Sender: TObject; IsColumn: Boolean; Index: Integer);
var i  : integer;
    so : TSortOrder;
begin
    if not IsColumn then exit;
    with sgModules.Columns[Index].Title do begin
         for i:=0 to sgModules.Columns.Count-1 do          // unsort other columns
             if i<>Index then sgModules.Columns[i].Title.ImageIndex := -1;
         If ImageIndex = 2 then begin
            ImageIndex := 1;
            sgModules.SortOrder := soAscending
         end else begin
             ImageIndex := 2;
             sgModules.SortOrder := soDescending;
         end;
         sgModules.SortColRow(true,Index);
    end;
end;

procedure TFrmConfig.BtnAboutClick(Sender: TObject);
begin frmAbout.ShowModal; end;

procedure TFrmConfig.btnGetConfClick(Sender: TObject);
begin
  aListener.SendMessage(xpl_mtCmnd,'*','hbeat.request'+chr(10)+'{'+chr(10)+'command=request'+chr(10)+'}'+chr(10));
end;

procedure TFrmConfig.FormCreate(Sender: TObject);
var i : integer;
begin
  aListener := TxPLListener.Create(self,'clinique','config');
  aListener.OnxPLReceived  := @OnMessageReceived;
  aListener.OnxPLJoinedNet := @OnJoined;
  iMessageCount := 0;

  HBList    := TList.Create;
  CfgListList := TList.Create;
  CfgCurrList := TList.Create;

  BtnSave.Enabled := false;

  for i:=0 to sgModules.Columns.Count-1 do
      sgModules.Columns[i].Title.ImageIndex := -1;           // No sort order by default ==> no image
  sgHBDetail.RowCount :=0;
  sgHBDetail.ColCount := 2;
  aListener.Listen;
  BtnGetConfClick(self);
end;


procedure TFrmConfig.FormDestroy(Sender: TObject);
begin
  aListener.destroy;
  HBList.Destroy;
  CfgListList.Destroy;
  CfgCurrList.Destroy;
end;

procedure TFrmConfig.cbListeEditingDone(Sender: TObject);
begin
     if cbListe.Text='' then exit;

     if sgHbDetail.Cells[sgHbDetail.Col,sgHbDetail.Row]<>cbListe.Text then
        sgHbDetail.Cells[sgHbDetail.Col,sgHbDetail.Row]:=cbListe.Text;
end;

procedure TFrmConfig.sgHBDetailEditingDone(Sender: TObject);
begin
   if sgHbDetail.Cells[0,sgHBDetail.Rowcount-1]<>'' then sgHbDetail.Rowcount := sgHBDetail.Rowcount+1;
end;

procedure TFrmConfig.sgHBDetailGetEditText(Sender: TObject; ACol,ARow: Integer; var Value: string);
begin
   sEditedText := Value;
end;

procedure TFrmConfig.sgHBDetailSetEditText(Sender: TObject; ACol,ARow: Integer; const Value: string);
begin
     if Value<>sEditedText then BtnSave.Enabled := true;
end;

procedure TFrmConfig.btnSaveClick(Sender: TObject);
begin
     SendConfigResponse;
     BtnSave.Enabled := False;
end;

procedure TFrmConfig.OnMessageReceived(axPLMessage : TxPLMessage);
var aBody : TxPLMsgBody;
    i : integer;
    s : string;
begin
     s := axPLMessage.Source.Device;
     if s = 'xplw800' then begin
        s:= '';
     end;
   i := sgModules.Cols[0].IndexOf(axPLMessage.Header.Source.Tag)-1;
   if i>=0 then begin                                               // This module is already known
      if not ((axPLMessage.Body.Keys.Count>0 ) and (axPLMessage.Body.Keys[0]='command') and (axPLMessage.Body.Values[0]='request')) then begin      // Don't handle config request messages
         if axPLMessage.Body.Schema.Tag = 'config.current' then begin
            if axPLMessage.Body.Keys.Count > 0 then begin
               s:= axPLMessage.Source.Tag;
               aBody := TxPLMsgBody(CfgCurrList[i]);
               aBody.Assign(axPLMessage.Body);
               sgModules.Cells[4,i+1] := 'Setup';      // i+1 because there's a header to the grid
               sgModules.Refresh ;
            end;
         end else if axPLMessage.Body.Schema.Tag = 'config.list' then begin
             s:= axPLMessage.Source.Tag;
            aBody := TxPLMsgBody(CfgListList[i]);
            aBody.Assign(axPLMessage.Body);
            sgModules.Cells[4,i+1] := 'Defined';    // i+1 because there's a header to the grid
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
          sgModules.Cells[4,sgModules.RowCount-1] := 'Detected';

          aBody := TxPLMsgBody.Create;
          aBody.Assign(axPLMessage.Body);
          HBList.Add(aBody);
          CfgListList.Add(TxPLMsgBody.Create);
          CfgCurrList.Add(TxPLMsgBody.Create);
          aListener.SendMessage(xpl_mtCmnd,Source.Tag,'config.list'+chr(10)+'{'+chr(10)+'command=request'+chr(10)+'}'+chr(10));
          aListener.SendMessage(xpl_mtCmnd,Source.Tag,'config.current'+chr(10)+'{'+chr(10)+'command=request'+chr(10)+'}'+chr(10));
       end;
end;


procedure TFrmConfig.sgHBDetailSelectEditor(Sender: TObject; aCol,aRow: Integer; var Editor: TWinControl);
begin
     if aCol=0 then begin
        if sgHBDetail.Cells[aCol,aRow]='' then begin
           Editor := cbListe;
            cbListe.BoundsRect:=sgHBDetail.CellRect(aCol,aRow);
        end else Editor := nil;
     end;
end;

procedure TFrmConfig.SendConfigResponse;
var i : integer;
    moduletag,s,key,value : string;
begin
     s := '';
     moduletag := sgModules.Cells[0,iSelectedModule+1];
     for i := 0 to sgHBDetail.Rowcount-1 do begin   // Browse all configuration items
         key  := sgHBDetail.Cells[0,i];
         value := sgHBDetail.Cells[1,i];
//         if value <> '' then begin                  // If a value is to be setup
            s += (key + '=' + value) + chr(10) ;   // Get new configuration string
            if key='newconf' then begin            // Handle special case of module name
               sgModules.Cells[3,iSelectedModule+1] := value;
               sgModules.Cells[0,iSelectedModule+1] := ComposeAddress( sgModules.Cells[1,iSelectedModule+1],
                                                                       sgModules.Cells[2,iSelectedModule+1],
                                                                       sgModules.Cells[3,iSelectedModule+1] );
            end;
//         end;
     end;
     if length(s)>0 then
     aListener.SendMessage( xpl_mtCmnd,
                            moduletag,
                            'config.response'+chr(10)+'{'+chr(10)+ s + '}'+chr(10));
end;

procedure TFrmConfig.sgModulesSelection(Sender: TObject; aCol, aRow: Integer);
var j : integer;
    aBody : TxPLMsgBody;
    s,ss,status : string;
begin
   if aRow<1 then exit;

   if BtnSave.Enabled then begin                        // a module has been edited and modified
      if Application.MessageBox( pchar('Configuration for module "' + sgModules.Cells[0,iSelectedModule+1] + '" has changed.' +
                                 chr(10) + chr(13) + 'Do you want to save changes'),'Save', MB_YESNO) = IDYES
      then SendConfigResponse;
   end;

   sgHBDetail.Visible := False;
   sgHBDetail.Clear ;
   sgHBDetail.ColCount := 2;
   iSelectedModule := aRow - 1;
   BtnSave.Enabled := false;
   cbListe.Items.Clear;
   status := sgModules.Cells[4,aRow];

   if (status='Setup') or (status='Defined') then begin
      sgHBDetail.Visible := True;

      aBody := TxPLMsgBody(CfgCurrList[iSelectedModule]);
      for J:=0 to aBody.ItmCount-1 do begin
         sgHBDetail.Cells[0,j] := aBody.Keys[j];
         sgHBDetail.Cells[1,j] := aBody.Values[j];
         sgHBDetail.RowCount := sgHBDetail.RowCount + 1;
      end;

      aBody := TxPLMsgBody(CfgListList[iSelectedModule]);
      for j:=0 to aBody.ItmCount-1 do begin
          s := aBody.Values[j];
          if CopyRight(s,1) =']' then
             cbListe.Items.Add( CopyLeft(s, PosChar('[',s)-1))
          else
             if (sgHBDetail.Cols[0].IndexOf(s)=-1) then begin
                sgHBDetail.Cells[0,sgHBDetail.RowCount-1] := s;
                sgHBDetail.RowCount := sgHBDetail.RowCount +1;
             end;
      end;
 
   end;
end;

procedure TFrmConfig.OnJoined(aJoined: boolean);
var sHubStatus : string;
begin
  if aJoined then sHubStatus := 'Hub found' else sHubStatus := 'Hub not found';
  StatusBar1.Panels[0].Text := sHubStatus;
end;

initialization
  {$I frm_config.lrs}

end.

