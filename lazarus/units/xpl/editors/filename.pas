unit FileName;
interface
uses
  SysUtils, PropEdits, Controls, Classes;

Type
  TFileNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  procedure Register;

implementation
uses
  Dialogs
  , Forms;

    function TFileNameProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paDialog]
  end {GetAttributes};

  procedure TFileNameProperty.Edit;
  begin
    with TOpenDialog.Create(Application) do
    try
      Title := GetName; { name of property as OpenDialog caption }
      Filename := GetValue;
      Filter := 'All Files (*.*)|*.*';
      HelpContext := 0;
      Options := Options + [ofShowHelp, ofPathMustExist, ofFileMustExist];
      if Execute then SetValue(Filename);
    finally
      Free
    end
  end {Edit};

  procedure Register;
  begin
    RegisterPropertyEditor(TypeInfo(TFileName),TxPLAction_Execute, 'FileName', TFileNameProperty);
  end;
end.

