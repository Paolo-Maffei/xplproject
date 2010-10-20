unit moon_reg;
  (*$i ah_def.inc *)
(*@/// interface *)
interface

uses
  classes,
  (*$ifdef delphi_ge_6 *)
  designintf,
  (*$else *)
  dsgnintf,
  (*$endif *)
  mooncomp,
  ah_ide;

procedure Register;
(*@\\\000000060B*)
(*@/// implementation *)
implementation

{$ifdef delphi_1}
  {$R moon.d16}
{$else}
  {$R moon.d32}
{$endif}


(*@/// procedure Register; *)
procedure Register;
(*$ifdef delphi_ge_6 *)
const
  TInputCategory = 'Input';
  TVisualCategory = 'Visual';
  TMiscellaneousCategory = 'Miscellaneous';
(*$endif *)
begin
  RegisterPropertyEditor(TypeInfo(TDateTime),NIL,'',t_ah_datetimeproperty);
  RegisterComponents('Custom', [TMoon]);
(*$ifdef delphi_ge_5 *)
  RegisterPropertiesInCategory(TInputCategory, TMoon,
    ['Date']);
  RegisterPropertiesInCategory(TVisualCategory, TMoon,
    ['MoonStyle','MoonSize','Rotation']);
  RegisterPropertiesInCategory(TMiscellaneousCategory, TMoon,
    ['ShowApollo11']);
(*$endif *)
  end;
(*@\\\*)
(*@\\\0000000A01*)
(*$ifdef delphi_ge_2 *) (*$warnings off *) (*$endif *)
end.
(*@\\\003F000501000501000501000601000501000011000501*)
