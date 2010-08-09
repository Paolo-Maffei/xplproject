unit uxPLConst;
{==============================================================================
  UnitName      = uxConst
  UnitDesc      = xPL constant and types library
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.91 : Suppressed string casting (tsMsgType from string[8] to string to avoid
        shortstring problem casting on linux portability
 }


{$mode objfpc}{$H+}

interface

type
   tsVendor   = string[8];
   tsDevice   = string[8];
   tsInstance = string[16];
   tsAddress  = string[8 + 1 + 8 + 1 + 16];
   tsClass    = string[8];
   tsType     = string[8];
   tsSchema   = string[8 + 1 + 8];
   tsMsgType  = string;                       //string[8];
   tsBodyElmtName  = string[16];
   tsBodyElmtValue = string[128];

   tsFilter   = string[8 + 1 + 8 + 1 + 8 + 1 + 16 + 1 + 8 + 1 + 8];                                          //   aMsgType.aVendor.aDevice.aInstance.aClass.aType

   TxPLSchemaClasse = ( xpl_scHBeat,    xpl_scConfig,  xpl_scAudio,   xpl_scControl,
                        xpl_scDateTime, xpl_scDb,      xpl_scDGuide,  xpl_scCID,
                        xpl_scOSD,      xpl_scRemote,  xpl_scSendMsg, xpl_scSensor,
                        xpl_scTTS,      xpl_scUps,     xpl_scWebCam,  xpl_scX10,
                        xpl_scOther );

//   TxPLMessageType  = ( xpl_mtTrig,     xpl_mtStat,    xpl_mtCmnd,    xpl_mtAny,   xpl_mtNone  );

   TxPLConfigType   = ( xpl_ctConfig,   xpl_ctReconf,  xpl_ctOption);


const
   // File extensions =======================================================================================
   K_FEXT_LOG         = '.log';
   K_FEXT_WAV         = '.wav';
   K_FEXT_XML         = '.xml';
   K_FEXT_PHP         = '.php';
   K_FEXT_TXT         = '.txt';

   // General ===============================================================================================
   K_STR_TRUE = 'true';
   K_STR_FALSE = 'false';

   // Websites ==============================================================================================
   K_XPL_VENDOR_SEED_LOCATION = 'http://xplproject.org.uk/plugins';                                          // URL where to download the main plugin file
   K_XPL_VENDOR_SEED_FILE     = 'plugins' + K_FEXT_XML;

   // Configuration modes ===================================================================================
   K_XPL_CONFIGOPTIONS : Array[0..2] of string = ('config','reconf','option');                               // Works with TxPLConfigType
   K_GROUP_NAME_ID     = 'xpl-group.';
   K_XPL_CONFIGFILTER  = 'filter';
   K_XPL_CONFIGGROUP   = 'group';

   // IP related strings
   K_IP_LOCALHOST     = '127.0.0.1';
   K_IP_BROADCAST     = '255.255.255.255';
   K_IP_DEFAULT_WEB_PORT = 8080;

   // Adress elements =======================================================================================
   K_REGEXPR_VENDOR   = '([0-9a-z]{1,8})';
   K_REGEXPR_DEVICE   = K_REGEXPR_VENDOR;
   K_REGEXPR_INSTANCE = '([0-9a-z/-]{1,16})';
   K_REGEXPR_DEVICE_ID= K_REGEXPR_VENDOR + '\-' + K_REGEXPR_DEVICE;                                          // Also used in vendor xml file
   K_REGEXPR_ADDRESS  = K_REGEXPR_DEVICE_ID + '\.' + K_REGEXPR_INSTANCE;
   K_REGEXPR_TARGET   = K_REGEXPR_ADDRESS + '|(\*)' ;                                                        //   /!\ alternative must be place after fixed part !!!
   K_FMT_ADDRESS      = '%s-%s.%s';
   K_FMT_FILTER       = '%s.%s.%s';
   K_ADDR_ANY_TARGET  = '*';

   // Message type elements =================================================================================
   K_MSG_TYPE_TRIG = 'xpl-trig';
   K_MSG_TYPE_STAT = 'xpl-stat';
   K_MSG_TYPE_CMND = 'xpl-cmnd';
   K_MSG_TYPE_ANY  = '*';
   K_RE_MSG_TYPE   = 'xpl-(trig|stat|cmnd)';
   K_MSG_TYPE_DESCRIPTORS : Array[0..3] of tsMsgType = ( K_MSG_TYPE_TRIG,K_MSG_TYPE_STAT,K_MSG_TYPE_CMND,K_MSG_TYPE_ANY);

   // Message header elements ===============================================================================
   K_MSG_HEADER_FORMAT = '%s'#10'{'#10'hop=%u'#10'source=%s'#10'target=%s'#10'}'#10;
   K_RE_HEADER_FORMAT  = '(xpl-(stat|cmnd|trig)).+[{\n](.+)[=](.+)[\n](.+)[=](.+)[\n](.+)[=](.+)[\n]';
   K_MSG_HEADER_HOP    = 'hop';
   K_MSG_HEADER_SOURCE = 'source';
   K_MSG_HEADER_TARGET = 'target';
   K_MSG_TARGET_ANY    = '*';

   // Message body elements =================================================================================
   K_RE_BODY_FORMAT    = '([_a-zA-Z\d\-\.]+.[_a-zA-Z\d\-]+\.[_a-zA-Z\d\-]+).+[{](.+)[}]';
   K_RE_BODY_LINE      = '(([0-9a-z-]{1,16})=([^\n]{0,128}))*';
   K_MSG_BODY_FORMAT   = '%s'#10'{'#10'%s'#10'}'#10;


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
   K_REGEXPR_SCHEMA_ELEMENT = '([0-9a-z/-]{1,8})';
   K_REGEXPR_SCHEMA = K_REGEXPR_SCHEMA_ELEMENT + '\.' + K_REGEXPR_SCHEMA_ELEMENT;
   K_FMT_SCHEMA     = '%s.%s';
   K_XPL_CLASS_DESCRIPTORS : Array[0..15] of string = (  'hbeat','config','audio','control','datetime',
                                                         'db','dguide','cid','osd','remote','sendmsg',
                                                         'sensor','tts','ups','webcam','x10' );
   K_SCHEMA_HBEAT_APP      = 'hbeat.app';
   K_SCHEMA_HBEAT_REQUEST  = 'hbeat.request';
   K_SCHEMA_SENSOR_BASIC   = 'sensor.basic';
   K_SCHEMA_SENSOR_REQUEST = 'sensor.request';
   K_SCHEMA_CONTROL_BASIC  = 'control.basic';
   K_SCHEMA_OSD_BASIC      = 'osd.basic';
   K_SCHEMA_TTS_BASIC      = 'tts.basic';
   K_SCHEMA_MEDIA_BASIC    = 'media.basic';
   K_SCHEMA_X10_BASIC      = 'x10.basic';
   K_SCHEMA_CONFIG_CURRENT = 'config.current';
   K_SCHEMA_CONFIG_LIST    = 'config.list';
   K_SCHEMA_DAWNDUSK_BASIC = 'dawndusk.basic';
   K_SCHEMA_DAWNDUSK_REQUEST = 'dawndusk.request';

   // Hub and listener constants ============================================================================
   XPL_BASE_DYNAMIC_PORT : Integer = 50000;                                                                  // First port used to try to open the listening port
   XPL_BASE_PORT_RANGE   : Integer = 512;                                                                    //       Range of port to scan for trying to bind socket
   XPL_UDP_BASE_PORT     : Integer = 3865;
   MAX_XPL_MSG_SIZE      : Integer = 1500;                                                                   // Maximum size of a xpl message
   NOHUB_HBEAT           : Integer = 3;                                                                      // seconds between HBEATs until hub is detected
   NOHUB_LOWERFREQ       : Integer = 30;                                                                     // lower frequency probing for hub
   NOHUB_TIMEOUT         : Integer = 120;                                                                    // after these nr of seconds lower the probing frequency to NOHUB_LOWERFREQ

   // Messages to display ==================================================================================
   K_MSG_HUB_FOUND       = 'xPL Network %s found';
   K_MSG_CONFIGURED      = 'Configuration %s';
   K_MSG_APP_STARTED     = 'Application %s started';
   K_MSG_APP_STOPPED     = 'Application %s stopped';
   K_MSG_UDP_ERROR       = 'Unable to initialize incoming UDP server';
   K_MSG_IP_ERROR        = 'Socket unable to bind to IP Addresses';
   K_MSG_BIND_OK         = 'Listener binded on port %u for address %s';
   K_MSG_BIND_RELEASED   = 'Listener released binded ports';
   K_MSG_CONFIG_LOADED   = 'Configuration loaded';
   K_MSG_CONFIG_RECEIVED = 'Configuration received from %s and saved';
   K_MSG_NETWORK_SETTINGS= 'xPL Network settings are not properly configured';
   K_MSG_ERROR_SENDING   = 'Error sending message : %s';
   K_MSG_ERROR_PLUGIN    = 'No device description found in vendor plugin file - please consider updating';
   K_MSG_ERROR_VENDOR    = 'Unable to open vendor file (%s)';
   K_MSG_OK_PLUGIN       = 'Configuration elements loaded from vendor plugin file';
   K_MSG_GENERIC_ERROR   = '%s error raised, with message : %s';
   K_MSG_LISTENER_STARTED= '%s v%s started';

   // Web applications templates ===========================================================================
   K_WEB_TEMPLATE_BEGIN = '<!-- Result template>';
   K_WEB_TEMPLATE_END   = '<Result template-->';
   K_WEB_RE_INCLUDE     = '<!--\s*\#\s*include\s+(file|virtual)\s*=\s*(["])([^"<>\|\~]+/)*([^"<>/\|\~]+)\2\s*-->';
   K_WEB_RE_VARIABLE    = '{%(.*?)_(.*?)%}';
   K_WEB_MSG_SRV_STOP   = 'Stopping web server';
   K_WEB_MSG_ROOT_DIR   = 'Webroot located in %s';
   K_WEB_MSG_PORT       = 'Starting web server on port %u';
   K_WEB_ERR_404        = 'The requested URL %s was not found on this server.';
   K_ERR_MSG_FNF        = 'File not found : %s';

   // Configuration items ==================================================================================
   K_FMT_CONFIG_FILE     = 'xpl_%s-%s.xml';                                                                 // Typically xpl_vendor-device.xml
   K_CONF_NEWCONF        = 'newconf';
   K_RE_NEWCONF          = '^' + K_REGEXPR_INSTANCE + '$';
   K_DESC_NEWCONF        = 'Specifies the instance name of the device';
   K_CONF_INTERVAL       = 'interval';
   K_RE_INTERVAL         = '^[56789]{1}$';
   K_DESC_INTERVAL       = 'Delay (in minutes), between heartbeats';
   K_CONF_FILTER         = 'filter';
   K_RE_FILTER           = '';
   K_DESC_FILTER         = 'Filter applied to broadcast message before beeing handled by the instance';
   K_CONF_GROUP          = 'group';
   K_RE_GROUP            = '^xpl-group\.[a-z0-9]{1,16}$';
   K_DESC_GROUP          = 'Identifies the groups the instance belongs to';
   K_XPL_CFG_MAX_FILTERS = 16;
   K_XPL_CFG_MAX_GROUPS  = 16;
   MIN_HBEAT             = 5;
   MAX_HBEAT             = 9;
   K_XPL_DEFAULT_HBEAT   = 5;

   // Global setting items =================================================================================
   K_XPL_ROOT_KEY               = '\Software\xPL\';
   K_XPL_FMT_APP_KEY            = K_XPL_ROOT_KEY + '%s\%s\';                                                // \software\xpl\vendor\device\
   K_XPL_REG_VERSION_KEY        = 'version';
   K_XPL_REG_PATH_KEY           = 'path';
   K_XPL_SETTINGS_NETWORK_ANY   = 'ANY';
   K_XPL_SETTINGS_NETWORK_LOCAL = 'ANY_LOCAL';
   K_REGISTRY_BROADCAST         = 'BroadcastAddress';
   K_REGISTRY_LISTENON          = 'ListenOnAddress';
   K_REGISTRY_LISTENTO          = 'ListenToAddresses';
   K_REGISTRY_ROOT_XPL_DIR      = 'RootxPLDirectory';
   K_REGISTRY_PROXY             = 'UseProxy';
   K_REGISTRY_HTTP_PROX_SRVR    = 'ProxyHttpSrvr';
   K_REGISTRY_HTTP_PROX_PORT    = 'ProxyHttpPort';
   K_XPL_SETTINGS_SUBDIR_CONF   = 'Config';
   K_XPL_SETTINGS_SUBDIR_PLUG   = 'Plugins';
   K_XPL_SETTINGS_SUBDIR_LOGS   = 'Logging';

   // HTML Formatting for standard action contained in menuItems ===========================================
   K_MNU_ITEM_MSG_AND_SUBMIT    = '<INPUT TYPE=HIDDEN NAME=xplMsg VALUE="%s"><INPUT TYPE=SUBMIT NAME="xPLWeb_menuitem" VALUE="%s">';
   K_MNU_ITEM_OPTION_LIST       = '<OPTION VALUE="%s">%s</OPTION>';
   K_MNU_ITEM_INPUT_TEXT        = '%s : <INPUT TYPE=TEXT NAME="%s">&nbsp;';
   K_MNU_ITEM_SELECT_LIST       = '<SELECT NAME="%s">%s</SELECT>&nbsp;';
   K_MNU_ITEM_ACTION_ZONE       = '<table class=action><tr><td><FORM ACTION=actions.html METHOD=POST>%s</FORM></td></tr></table>';
   K_MNU_ITEM_OPTION_SEP        = '|';                                                                      // Separator used in the xml file between valid choices
   K_MNU_ITEM_RE_PARAMETER      = '%(.*?)%';                                                                // Regular expression used to identify parameters in xplMsg in MenuItems


implementation

end.

