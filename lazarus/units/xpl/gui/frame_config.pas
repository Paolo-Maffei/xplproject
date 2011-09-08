unit frame_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, ExtCtrls, ComCtrls,
  StdCtrls, Spin, v_msgbody_stringgrid, u_xpl_body, u_xpl_config,
  u_configuration_record, u_xpl_messages, Grids;

type

  { TframeConfig }

  TframeConfig = class(TFrame)
    edtInstance: TEdit;
    HBDetail: TBodyMessageGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblRegExpr: TLabel;
    lblError: TLabel;
    Memo1: TMemo;
    mmoFilters: TMemo;
    mmoGroups: TMemo;
    PageControl1: TPageControl;
    seInterval: TSpinEdit;
    tsCoreItems: TTabSheet;
    tsSpecific: TTabSheet;
    procedure HBDetailEditingDone(Sender: TObject);
    procedure HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
  private
    fConfig : TConfigurationRecord;
    fConfigCurrent : TConfigCurrentStat;
  public
    procedure SetConfigRecord(const aConfig : TConfigurationRecord);
    procedure SetConfigCurrent(const Current : TConfigCurrentStat);
    procedure Assign(const aResponse : TConfigResponseCmnd); reintroduce;
  end; 

implementation //==============================================================

uses uRegExpr
     ;

{ TframeConfig }

procedure TframeConfig.HBDetailEditingDone(Sender: TObject);
begin
  if lblRegExpr.Caption = '' then exit;
  with TRegExpr.Create do try
     Expression := lblRegExpr.Caption;
     lblError.Visible := not Exec( HBDetail.GetValue(HBDetail.Row));
  finally
     free;
  end;
  if lblError.Visible then lblError.Caption := 'Value error for : ' + HBDetail.GetKey(HBDetail.Row);
end;

procedure TframeConfig.HBDetailSelection(Sender: TObject; aCol, aRow: Integer);
var i : integer;
begin
   memo1.lines.Clear;
   lblRegExpr.Caption := '';
   if not Assigned(fConfig) or fConfig.XMLCfgAvail then exit;
   for i := 0 to fConfig.Plug_Detail.ConfigItems.Count-1 do
       if fConfig.Plug_Detail.ConfigItems[i].Name = HBDetail.GetKey(aRow) then begin
          Memo1.Lines.Add(fConfig.Plug_Detail.ConfigItems[i].Description);
          lblRegExpr.Caption := fConfig.Plug_Detail.ConfigItems[i].Format;
       end;
end;

procedure TframeConfig.SetConfigCurrent(const Current: TConfigCurrentStat);
var i : integer;
begin
   if not assigned(fConfigCurrent) then fConfigCurrent := TConfigCurrentStat.Create(self);
   fConfigCurrent.Assign(Current);

   edtInstance.Caption := fConfigCurrent.NewConf;
   seInterval.Value    := fConfigCurrent.interval;

   mmoFilters.Lines.Assign(fConfigCurrent.filters);
   mmoGroups.Lines.Assign(fConfigCurrent.groups);

   HBDetail.Clear;
   HBDetail.PossibleKeys.Clear;
   HBDetail.Visible := True;

   for i := Pred(fConfigCurrent.Body.ItemCount) downto 0 do                         // Delete standard items from the message
       if fConfigCurrent.IsCoreValue(i) then fConfigCurrent.Body.DeleteItem(i);     // they're not needed to be displayed in
                                                                                    // the hBDetail grid

   PageControl1.ActivePage := tsCoreItems;
   if fConfigCurrent.Body.ItemCount>0 then HBDetail.Assign(fConfigCurrent.Body);

   tsSpecific.TabVisible := (fConfigCurrent.Body.ItemCount >0);

end;

procedure TframeConfig.Assign(const aResponse : TConfigResponseCmnd);
begin
   aResponse.NewConf  := edtInstance.Caption;
   aResponse.interval := seInterval.Value;
   aResponse.filters  := TStringList(mmoFilters.Lines);
   aResponse.Groups   := TStringList(mmoGroups.Lines);
   HBDetail.CopyTo(aResponse.Body);
end;

procedure TframeConfig.SetConfigRecord(const aConfig: TConfigurationRecord);
var j : integer;
begin
   fConfig := aConfig;
   lblError.Visible := false;

   SetConfigCurrent(fConfig.Config.CurrentConfig);
   for j:=0 to fConfig.Config.ConfigItems.Count-1 do
       if fConfig.Config.ConfigItems[j].ItemMax > 1 then
          HBDetail.PossibleKeys.Add(fConfig.Config.ConfigItems[j].DisplayName);
end;

initialization
  {$I frame_config.lrs}

end.

