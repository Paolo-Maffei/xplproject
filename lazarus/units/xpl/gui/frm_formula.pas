unit frm_formula;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ActnList, ComCtrls, StdCtrls,  Menus, RTTIGrids, formula,
  u_xpl_formulas;

type

  { TfrmFormula }

  TfrmFormula = class(TForm)
    acCancel: TAction;
    acOk: TAction;
    ActionList: TActionList;
    edtName: TEdit;
    F: TArtFormula;
    BtnEvaluate: TButton;
    edtExpression: TEdit;
    edtResult: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    mnuStatistic: TMenuItem;
    mnuTrigo: TMenuItem;
    mnuMisc: TMenuItem;
    mnuNumeric: TMenuItem;
    popFunctions: TPopupMenu;
    popVariables: TPopupMenu;
    tbLaunch: TToolButton;
    ToolBar: TToolBar;
    tbFunctions: TToolButton;
    tbVariables: TToolButton;
    ToolButton3: TToolButton;
    ToolButton8: TToolButton;
    procedure acCancelExecute(Sender: TObject);
    procedure acOkExecute(Sender: TObject);
    procedure BtnEvaluateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbFunctionsClick(Sender: TObject);
    procedure tbVariablesClick(Sender: TObject);
  private
    { private declarations }
    Formula : TxPLFormula;
    Formulas: TxPLFormulas;
    procedure FunctionMenuClick(sender : TObject);
    procedure VariableMenuClick(sender : TObject);
  public
    { public declarations }
  end; 

var
  frmFormula: TfrmFormula;

  function ShowFrmFormula(const aFormula : TxPLFormula; const aFormulas : TxPLFormulas) : integer;

implementation // ==============================================================
uses u_xpl_gui_resource
     ;

const

     tableMisc    : array [0..1] of FTableItem = (
                  (name:'RND';paramcount:0),
                  (name:'IFF';paramcount:3)
     );

     tableNum     : array [0..7] of FTableItem = (
                  (name:'LOG';paramcount:1),
                  (name:'LG';paramcount:1),
                  (name:'EXP';paramcount:1),
                  (name:'SQRT';paramcount:1),
                  (name:'INT';paramcount:1),
                  (name:'FRAC';paramcount:1),
                  (name:'ABS';paramcount:1),
                  (name:'SIGN';paramcount:1)
     );

     tableTrig    : array [0..11] of FTableItem = (
                  (name:'SIN'; paramcount:1),
                  (name:'COS';paramcount:1),
                  (name:'TAN';paramcount:1),
                  (name:'ATAN';paramcount:1),
                  (name:'ASIN';paramcount:1),
                  (name:'ACOS';paramcount:1),
                  (name:'ASINH';paramcount:1),
                  (name:'ACOSH';paramcount:1),
                  (name:'ATANH';paramcount:1),
                  (name:'COSH';paramcount:1),
                  (name:'SINH';paramcount:1),
                  (name:'TANH';paramcount:1)
     );

     tableStat    : array [0..9] of FTableItem = (
                  (name:'MAX';paramcount:-1),
                  (name:'MIN';paramcount:-1),
                  (name:'AVG';paramcount:-1),
                  (name:'STDDEV';paramcount:-1),
                  (name:'STDDEVP';paramcount:-1),
                  (name:'SUM';paramcount:-1),
                  (name:'SUMOFSQUARES';paramcount:-1),
                  (name:'COUNT';paramcount:-1),
                  (name:'VARIANCE';paramcount:-1),
                  (name:'VARIANCEP';paramcount:-1)
     );

function ShowFrmFormula(const aFormula : TxPLFormula; const aFormulas : TxPLFormulas) : integer;
begin
   if not assigned(frmFormula) then Application.CreateForm(TfrmFormula,frmFormula);
   FrmFormula.Formula := aFormula;
   FrmFormula.Formulas := aFormulas;
   result := frmFormula.ShowModal;
end;

procedure TfrmFormula.FormCreate(Sender: TObject);
   procedure FillMenu(const aMenu : TMenuItem; const aTable : array of FTableItem);
      var mnu : TMenuItem;
          i : integer;

      begin
         for i:=low(aTable) to high(aTable) do begin
             mnu := TMenuItem.Create(self);
             aMenu.Add(mnu);
             mnu.Caption:=aTable[i].name;
             mnu.Tag:=aTable[i].paramcount;
             mnu.OnClick:=@FunctionMenuClick;
         end;
      end;
begin
   Toolbar.Images := xPLGUIResource.Images;
   FillMenu(mnuStatistic,TableStat);
   FillMenu(mnuTrigo,TableTrig);
   FillMenu(mnuMisc,TableMisc);
   FillMenu(mnuNumeric,TableNum);
end;

procedure TfrmFormula.FormShow(Sender: TObject);
var i : integer;
    mnu : TMenuItem;
begin
   edtExpression.Text := Formula.Expression;
   edtName.Text       := Formula.DisplayName;
   edtResult.Text     := Formula.Value;
   popVariables.Items.Clear;
   for i:=0 to Formulas.Globals.Count-1 do begin
       mnu := TMenuItem.Create(self);
       mnu.Caption := Formulas.Globals.Items[i].DisplayName;
       mnu.OnClick := @VariableMenuClick;
       popVariables.Items.Add(mnu);
   end;
end;

procedure TfrmFormula.tbFunctionsClick(Sender: TObject);
begin
   popFunctions.PopUp;
end;

procedure TfrmFormula.tbVariablesClick(Sender: TObject);
begin
   popVariables.PopUp;
end;

procedure TfrmFormula.FunctionMenuClick(sender: TObject);
var mnu : TMenuItem;
    i, nb  : integer;
    parm : string;
begin
   mnu := TMenuItem(Sender);
   nb  := mnu.Tag;
   parm := '(';
   if nb = -1 then parm := '.,...'
   else for i:=1 to nb do parm := parm + ',';
   parm := parm  + ')';
   edtExpression.Text:=edtExpression.Text + ' ' +
                       TMenuItem(sender).Caption + parm;
end;

procedure TfrmFormula.VariableMenuClick(sender: TObject);
begin
   edtExpression.Text := edtExpression.Text + ' {' + TMenuItem(sender).Caption + '}';
end;

procedure TfrmFormula.BtnEvaluateClick(Sender: TObject);
begin
   try
      EdtResult.Text := Formulas.Compute(edtExpression.Text);
   except
      on E:Exception do begin
          EdtResult.Text:=E.Message;
         ActiveControl := edtExpression;
         edtExpression.SelStart := F.ErrPos-1;
      end;
   end;
end;

procedure TfrmFormula.acOkExecute(Sender: TObject);
begin
   Formula.Expression := edtExpression.Text;
   Formula.DisplayName := edtName.Text;
   Formula.Value    := edtResult.Text;
   Close;
   ModalResult := mrOk;
end;

procedure TfrmFormula.acCancelExecute(Sender: TObject);
begin
   Close;
end;

initialization
  {$I frm_formula.lrs}

end.

