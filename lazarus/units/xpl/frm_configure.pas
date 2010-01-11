unit frm_configure;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, XMLPropStorage;

type

  { TfrmConfigure }

  TfrmConfigure = class(TForm)
    tbRefresh: TToolButton;
    ToolBar3: TToolBar;
    XMLPropStorage: TXMLPropStorage;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var frmConfigure: TfrmConfigure;

implementation
uses frm_about;

initialization
  {$I frm_configure.lrs}

end.

