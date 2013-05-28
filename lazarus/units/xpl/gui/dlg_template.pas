unit dlg_template;
{==============================================================================
  UnitName      = dlg_template
  UnitDesc      = Ancestor for most of the Dialog boxes in the project
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
}

{$mode objfpc}{$H+}
{$r *.lfm}

interface

uses Classes, SysUtils, LSControls, LResources, Forms, Controls, Graphics,
     ActnList, Buttons, XMLPropStorage, ExtCtrls;

type // TDlgTemplate ==========================================================
     TDlgTemplate = class(TForm)
        DlgAcClose: TAction;
        DlgActions: TActionList;
        DlgtbClose: TLSBitBtn;
        DlgBottomBar: TPanel;
        DlgToolBar: TPanel;
        XMLPropStorage1: TXMLPropStorage;
        procedure DlgacCloseExecute(Sender: TObject);
        procedure FormCloseQuery(Sender: TObject; var {%H-}CanClose: boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
     protected
        procedure SetButtonImage(const aButton : TLSBitBtn; const aAction : TAction; const aImgIndex : integer);
        procedure SetButtonImage(const aButton : TLSSpeedButton; const aAction : TAction; const aImgIndex : integer); overload;
        procedure SetButtonImage(const aButton : TLSBitBtn; const aImgIndex : integer); overload;
     end;

implementation //==============================================================
uses u_xpl_gui_resource
     , u_xpl_application
     ;

// Form procedures ============================================================
procedure TDlgTemplate.FormCreate(Sender: TObject);
begin
   inherited;

   DlgActions.Images := xPLGUIResource.Images16;

   SetButtonImage(DlgTbClose, DlgAcClose, K_IMG_CLOSE);

   if Assigned(xPLApplication) then begin
      XMLPropStorage1.FileName := xPLApplication.SettingsFile;
      XMLPropStorage1.Restore;
   end;
end;

procedure TDlgTemplate.FormShow(Sender: TObject);
begin
   inherited;
   DlgToolBar.Visible := DlgToolBar.Height > 6;                                // si > 6 c'est qu'il y a des composants dans la barre, je n'ai pas réussi à le faire avec componentcount<>0
end;

procedure TDlgTemplate.SetButtonImage(const aButton: TLSBitBtn; const aAction : TAction; const aImgIndex: integer);
begin
   aAction.ImageIndex := aImgIndex;
   aButton.Action := aAction;
   aButton.Layout:= blGlyphLeft;
end;

procedure TDlgTemplate.SetButtonImage(const aButton: TLSSpeedButton; const aAction: TAction; const aImgIndex: integer);
begin
   aAction.ImageIndex := aImgIndex;
   aButton.Action := aAction;
   aButton.Layout:= blGlyphLeft;
end;

procedure TDlgTemplate.SetButtonImage(const aButton: TLSBitBtn; const aImgIndex: integer);
begin
   aButton.Images := DlgActions.Images;
   aButton.ImageIndex := aImgIndex;
   aButton.Layout := blGlyphleft;
end;

procedure TDlgTemplate.DlgacCloseExecute(Sender: TObject);
begin
   Close;
end;

procedure TDlgTemplate.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   XMLPropStorage1.Save;
end;

end.
