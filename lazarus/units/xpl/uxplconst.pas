unit uxPLConst;

{$mode objfpc}{$H+}

interface

const
   // Message type elements =================================================================================
   K_MSG_TYPE_TRIG = 'xpl-trig';
   K_MSG_TYPE_STAT = 'xpl-stat';
   K_MSG_TYPE_CMND = 'xpl-cmnd';
   K_MSG_TYPE_ANY  = '*';
   K_RE_MSG_TYPE   = 'xpl-(trig|stat|cmnd)';

   // Message header elements ===============================================================================
   K_MSG_HEADER_FORMAT = '%s'#10'{'#10'hop=%u'#10'source=%s'#10'target=%s'#10'}'#10;
   K_RE_HEADER_FORMAT  = '(xpl-(stat|cmnd|trig)).+[{\n](.+)[=](.+)[\n](.+)[=](.+)[\n](.+)[=](.+)[\n]';
   K_MSG_HEADER_HOP    = 'hop';
   K_MSG_HEADER_SOURCE = 'source';
   K_MSG_HEADER_TARGET = 'target';
   K_MSG_TARGET_ANY    = '*';

   // Message body elements =================================================================================
   K_RE_BODY_FORMAT    = '([_a-zA-Z\d\-\.]+.[_a-zA-Z\d\-]+\.[_a-zA-Z\d\-]+).+[{](.+)[}]';

   // Message elements ======================================================================================
   K_RE_MESSAGE        = '\A(.+})(.+})';

   // Heart beat message elements ===========================================================================
   K_HBEAT_ME_APPNAME  = 'appname';
   K_HBEAT_ME_VERSION  = 'version';
   K_HBEAT_ME_INTERVAL = 'interval';
   K_HBEAT_ME_PORT     = 'port';
   K_HBEAT_ME_REMOTEIP = 'remote-ip';
   K_HBEAT_ME_WEB_PORT = 'webport';

   // Common schemas ========================================================================================
   K_SCHEMA_HBEAT_APP      = 'hbeat.app';
   K_SCHEMA_HBEAT_REQUEST  = 'hbeat.request';
   K_SCHEMA_SENSOR_BASIC   = 'sensor.basic';
   K_SCHEMA_SENSOR_REQUEST = 'sensor.request';
   K_SCHEMA_CONTROL_BASIC  = 'control.basic';
   K_SCHEMA_TTS_BASIC      = 'tts.basic';

   // Hub and listener constants ============================================================================
   XPL_BASE_DYNAMIC_PORT : Integer = 50000;           // First port used to try to open the listening port
   XPL_BASE_PORT_RANGE   : Integer = 512;             //       Range of port to scan for trying to bind socket
   XPL_UDP_BASE_PORT     : Integer = 3865;
   MAX_XPL_MSG_SIZE      : Integer = 1500;            // Maximum size of a xpl message
   NOHUB_HBEAT           : Integer = 3;               // seconds between HBEATs until hub is detected
   NOHUB_LOWERFREQ       : Integer = 30;              // lower frequency probing for hub
   NOHUB_TIMEOUT         : Integer = 120;             // after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ

   // Messages to display ==================================================================================
   K_MSG_HUB_FOUND       = 'xPL Network joined';
   K_MSG_CONFIGURED      = 'Configuration Done';
   K_MSG_APP_STARTED     = 'Application %s started';
   K_MSG_APP_STOPPED     = 'Application %s stopped';
   K_MSG_UDP_ERROR       = 'Unable to initialize incoming UDP server';
   K_MSG_IP_ERROR        = 'Socket unable to bind to IP Addresses';
   K_MSG_BIND_OK         = 'Client binded on port %u for address %s';

   // Web applications templates ===========================================================================
   K_WEB_TEMPLATE_BEGIN = '<!-- Result template>';
   K_WEB_TEMPLATE_END   = '<Result template-->';

implementation

end.

