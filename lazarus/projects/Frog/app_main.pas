unit app_main;

{$i compiler.inc}
   // Just a stub at the time between old app organisation and new one
interface

uses
  Forms,Classes, uxPLWebListener,SysUtils;

var  xPLApplication : TApplication;
     xPLClient      : TxPLWebListener;

implementation
uses frm_main;

initialization
   xPLApplication := Application;
//

end.

