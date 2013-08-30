unit about;

{$mode objfpc}{$H+}

interface

(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    CloseButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Label1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.Label1Click(Sender: TObject);
begin

end;

end.

