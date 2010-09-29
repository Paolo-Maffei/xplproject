unit app_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uxPLClient, uxPLMessage;

var xPLClient : TxPLClient;
    SendMsg   : TxPLMessage;

const //======================================================================================
     K_XPL_APP_VERSION_NUMBER = '1.6';
     K_DEFAULT_VENDOR = 'clinique';
     K_DEFAULT_DEVICE = 'sender';

implementation

end.

