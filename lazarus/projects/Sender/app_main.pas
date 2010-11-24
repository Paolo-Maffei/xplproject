unit app_main;

{$mode objfpc}{$H+}

interface

uses Classes,
     u_xpl_sender,
     u_xpl_message_GUI;

var  xPLClient : TxPLSender;
     xPLMessageGUI : TxPLMessageGUI;

const //======================================================================================
     K_XPL_APP_VERSION_NUMBER = '1.6.3';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'sender';

implementation

end.

