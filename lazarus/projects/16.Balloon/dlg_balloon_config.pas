unit dlg_balloon_config;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  dlg_config;

type
  TForm1 = class(TDlgConfig)
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

initialization
  {$I dlg_balloon_config.lrs}

end.

