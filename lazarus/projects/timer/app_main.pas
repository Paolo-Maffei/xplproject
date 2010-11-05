unit app_main;

{$i compiler.inc}
   // Just a stub at the time between old app organisation and new one
interface

uses
  Forms,Classes, uxPLWebListener,SysUtils;

var  xPLApplication : TApplication;
     xPLClient      : TxPLWebListener;

const
     K_XPL_APP_VERSION_NUMBER = '1.6';
     K_DEFAULT_VENDOR         = 'clinique';
     K_DEFAULT_DEVICE         = 'timer';
     K_DEFAULT_PORT           = '8339';


implementation
uses frm_main;

initialization
   xPLApplication := Application;
//

end.

