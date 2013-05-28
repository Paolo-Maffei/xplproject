unit datetime;
interface
uses
  SysUtils, PropEdits, Controls, Classes;

Type
  TExDateTimeProperty = class(TDateTimeProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;


implementation
uses
  Dialogs
  , Forms;

    function TExDateTimeProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paValueList,paDialog]
  end {GetAttributes};

  procedure TExDateTimeProperty.Edit;
  begin
    with TOpenDialog.Create(nil) do
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

end.

