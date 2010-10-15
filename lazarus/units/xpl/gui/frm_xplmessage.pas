unit frm_xPLMessage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  StdCtrls, ExtCtrls, EditBtn, Grids, Menus, ActnList, ComCtrls, Buttons, u_xPL_Message_gui, uxplmessage,
  KHexEditor, SynEdit, SynHighlighterPas, v_xplmsg_opendialog;

type

  { TfrmxPLMessage }
  TfrmxPLMessage = class(TForm)
    acLoad: TAction;
    acClose: TAction;
    ckBody: TCheckBox;
    ckMsgType: TCheckBox;
    ckInstance: TCheckBox;
    ckDevice: TCheckBox;
    DoSend: TAction;
    ActionList2: TActionList;
    edtName: TEdit;
    edtSource: TEdit;
    edtFilter: TEdit;
    ImageList1: TImageList;
    KHexEditor1: TKHexEditor;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    mmoMessage: TMemo;
    MsgCopy: TAction;
    MsgSave: TAction;
    PageControl1: TPageControl;
    mmoPSScript: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    SaveMessage: TxPLMsgSaveDialog;
    OpenMessage: TxPLMsgOpenDialog;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;

    procedure acCloseExecute(Sender: TObject);
    procedure acLoadExecute(Sender: TObject);
    procedure ckDeviceChange(Sender: TObject);
    procedure DoSendExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure mmoMessageExit(Sender: TObject);
    procedure MsgCopyExecute(Sender: TObject);
    procedure MsgSaveExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    Stream     : TStringStream;
    xPLMessage : TxPLMessage;
    procedure DisplayMessage;
  public
    buttonOptions : TButtonOptions;
  end;

implementation // TFrmxPLMessage ===============================================================
uses frm_About,
     app_main,
     clipbrd,
     LCLType,
     cStrings,
     cUtils,
     StrUtils;

// =============================================================================================
procedure TfrmxPLMessage.FormCreate(Sender: TObject);
begin
  Stream     := TStringStream.Create('');
end;

procedure TfrmxPLMessage.DoSendExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   xPLClient.Send(xPLMessage);
end;

procedure TfrmxPLMessage.acLoadExecute(Sender: TObject);
begin
  if not OpenMessage.Execute then exit;

  xPLMessage.LoadFromFile(OpenMessage.FileName);
  DisplayMessage;

end;

procedure TfrmxPLMessage.acCloseExecute(Sender: TObject);
begin
   Close;
end;

procedure TfrmxPLMessage.ckDeviceChange(Sender: TObject);
const
   K_PROC_NAME_TEMPLATE = 'procedure %s_%s_%s_%s(const aMessage : string);';
   K_PROC_CONFIG_TEMPLATE = 'procedure %s_%s_%s_Config();';
   K_PROC_EXPIRED_TEMPLATE = 'procedure %s_%s_%s_Expired();';
   K_PROC_HBEAT_TEMPLATE = 'procedure %s_%s_%s_Heartbeat(const aMessage : string);';
var i : integer;
begin
     mmoPSScript.Lines.Clear;
     mmoPSScript.Lines.Add('// Message handling preformatted procedure');
     mmoPSScript.Lines.Add( StrReplace('xpl-','',
                            Format(K_PROC_NAME_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                          IfThen(ckDevice.checked, xPLMessage.Header.Source.Device,''),
                                                          IfThen(ckInstance.checked, xPLMessage.Header.Source.Instance,''),
                                                          IfThen(ckMsgType.checked, xPLMessage.Header.MessageType,'')
                                                        ]), false));
     mmoPSScript.Lines.Add('begin');
     if ckBody.Checked then begin
        for i:=0 to xPLMessage.Body.Keys.Count-1 do begin
            mmoPSScript.Lines.Add(
               ifthen(i=0,'    if (',' ') +
               '   (xpl.MessageValueFromKey(''' + xplMessage.Body.Keys[i] + ''') = ''' + xplMessage.Body.Values[i] + ''')' +
               ifthen(i<>xPLMessage.Body.Keys.Count-1,' and ', ') then begin')
            );
        end;
        mmoPSScript.Lines.Add('   end;');
     end;
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_CONFIG_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_EXPIRED_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

     mmoPSScript.Lines.Add('');
     mmoPSScript.Lines.Add(Format(K_PROC_HBEAT_TEMPLATE,[ xPLMessage.Header.Source.Vendor,
                                                           xPLMessage.Header.Source.Device,
                                                           xPLMessage.Header.Source.Instance ]));
     mmoPSScript.Lines.Add('begin');
     mmoPSScript.Lines.Add('   // Your code here');
     mmoPSScript.Lines.Add('end;');

end;

procedure TfrmxPLMessage.FormDestroy(Sender: TObject);
begin
  Stream.Destroy;
end;

procedure TFrmxPLMessage.DisplayMessage;
var j : integer;
    arrStr : StringArray;
begin
   mmoMessage.Lines.Clear;
   arrStr := StrSplit(xPLMessage.RawXPL,#10);

   for j:=0 to high(arrStr) do
       if arrStr[j]<>'' then mmoMessage.Lines.Add(arrStr[j]);

   Stream.Position := 0;
   Stream.WriteString(xPLMessage.RawXPL);
   Stream.Position := 0;
   KHexEditor1.LoadFromStream(Stream);

   edtFilter.Text := xPLMessage.SourceFilterTag;
   edtSource.Text := xPLMessage.Source.Tag;
   edtName.Text   := xPLMessage.Name;
end;

procedure TfrmxPLMessage.FormShow(Sender: TObject);
begin
   xPLMessage := TxPLMessage(Owner);
   ToolBar3.Images := frmAbout.ilStandardActions;
   acLoad.Visible  := (boLoad in buttonOptions);
   MsgSave.Visible := (boSave in buttonOptions);
   MsgCopy.Visible := (boCopy in buttonOptions);
   DoSend.Visible  := (boSend in buttonOptions);
   DisplayMessage;
end;

procedure TfrmxPLMessage.mmoMessageExit(Sender: TObject);
var s : string;
    j : integer;
begin
   if not mmoMessage.Modified then exit;

   s:= '';

   for j:=0 to mmoMessage.Lines.Count-1 do
       s += (mmoMessage.Lines[j] + #10);

   xPLMessage.RawxPL := s;
   DisplayMessage;
end;

procedure TfrmxPLMessage.MsgCopyExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   Clipboard.AsText := TxPLMessage(Owner).RawxPL;
end;

procedure TfrmxPLMessage.MsgSaveExecute(Sender: TObject);
begin
   mmoMessageExit(sender);
   if SaveMessage.Execute then xPLMessage.SaveToFile(SaveMessage.FileName);
end;

procedure TfrmxPLMessage.PageControl1Change(Sender: TObject);
begin
   mmoMessageExit(sender);
end;

initialization
  {$I frm_xplmessage.lrs}

end.


