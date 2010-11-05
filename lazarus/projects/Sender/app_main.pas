unit app_main;

{$mode objfpc}{$H+}

interface

uses Classes,
     uxPLMessage,
     u_xpl_sender;

var SendMsg   : TxPLMessage;
    xPLClient : TxPLSender;

const //======================================================================================
     K_XPL_APP_VERSION_NUMBER = '1.6.2';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'sender';

implementation

end.

