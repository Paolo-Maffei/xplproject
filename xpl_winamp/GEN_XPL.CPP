//*************************************************
// xPL Winamp Plugin                           
// Version 1.0 Beta 3
// Written by John Bent
// http://www.xpl.myby.co.uk
//*************************************************
#include <windows.h>
#include <winsock.h>
#include <stdio.h>
#include "gen.h"
#include "winamp1.h"

// Name and version of this plug-in
#define APP_NAME "xPL Winamp Plug-in V1.0 Beta 3"

// Maximum allowed xPL message size
#define MAX_XPL_MSG_SIZE 1400

// My vendor ID
#define VENDOR_ID "johnb"

// Global variables
HINSTANCE g_hInstance;
HWND g_hWnd, g_hwndConfig;
HWND hSave, hLabel1, hLabel2, hLabel3;
HWND hInstanceName, hBroadcast, hInterval, hUseHub;

// The instance name being used
LPTSTR g_lpSource;

// The broadcast address for outbound messages
LPTSTR g_lpAddress;

// The path to the directory where Winamp is installed
LPTSTR g_lpWinampPath;

SOCKADDR_IN addr;
SOCKET sockSender, sockReceiver;
BOOL bUseHub;
UINT g_Port, g_ListenerPort;
UINT g_HBeatInterval;

// Function prototypes
VOID ConstructStatusBody(char *body);
VOID SendXplMessage(char *MsgType, char *MsgBody);
VOID SendHeartbeat();
VOID SendStatusMessage();
LRESULT CALLBACK WndProc(HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam);
LRESULT CALLBACK ConfigWndProc(HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam);
DWORD WINAPI StartThread(LPVOID);
BOOL ReadConfigFile();
VOID SaveConfigFile();
VOID config();
VOID quit();
INT init();

winampGeneralPurposePlugin plugin =
{
	GPPHDR_VER,
	APP_NAME,
	init,
	config,
	quit,
};

BOOL CleanupSocket()
{
  if (sockSender)
    closesocket(sockSender);

  if (sockReceiver)
    closesocket(sockReceiver);

  WSACleanup();
  return TRUE;
}

BOOL InitSocket()
{
  char TempBool = TRUE;
  WSADATA wsda;
  struct hostent *host;

  WSAStartup(MAKEWORD(1,1), &wsda);

  sockSender = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  if (sockSender==SOCKET_ERROR)
    return FALSE;

  // Allow this socket to send to the broadcast address
  setsockopt(sockSender,SOL_SOCKET,SO_BROADCAST,&TempBool,sizeof(INT));

  addr.sin_family = AF_INET;
  addr.sin_port = htons(3865);
  addr.sin_addr.s_addr = inet_addr(g_lpAddress);

  return TRUE;
}

// Exported function for WInamp to get details of this plug-in
extern "C"winampGeneralPurposePlugin *  PASCAL _export  winampGetGeneralPurposePlugin()                                    
{
  return &plugin;
}

// init is called by Winamp to initialise our plug-in
int init()
{
  CreateThread(NULL,
	0,
	StartThread,
	NULL,
	0,
	NULL);
  return 0;
}

VOID CleanupMemory()
{
  if (g_lpAddress) delete []g_lpAddress;
  if (g_lpSource) delete []g_lpSource;
  if (g_lpWinampPath) delete []g_lpWinampPath;
}

// quit is called by WInamp when we need to shut down our plug-in
VOID quit()
{
  PostMessage(g_hWnd,WM_QUIT,0,0);
}

// config is called by Winamp when the user wishes to see the configuration dialog
VOID config()
{
  SendMessage(g_hWnd,WM_USER,1001,1001);
}

void PrepareConfig()
{
  char szInterval[3];
  wsprintf(szInterval,"%d",g_HBeatInterval);

  g_hwndConfig=CreateWindowEx(NULL,
		    "XPLWINAMPCONFIG",
	APP_NAME,
	WS_OVERLAPPEDWINDOW | WS_VISIBLE,
	20,
	20,
	340,
	245,
	g_hWnd,
	NULL,
	g_hInstance,
	NULL);

  hLabel1=CreateWindowEx(NULL,
		    "STATIC",
	"Instance:",
	WS_CHILD | WS_VISIBLE,
	10,
	10,
	140,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hInstanceName=CreateWindowEx(NULL,
		    "EDIT",
	g_lpSource,
	WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,
	170,
	10,
	130,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hLabel2=CreateWindowEx(NULL,
		    "STATIC",
	"Broadcast Address:",
	WS_CHILD | WS_VISIBLE,
	10,
	45,
	140,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hBroadcast=CreateWindowEx(NULL,
		    "EDIT",
	g_lpAddress,
	WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,
	170,
	45,
	130,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hLabel3=CreateWindowEx(NULL,
		    "STATIC",
	"Heartbeat Interval:",
	WS_CHILD | WS_VISIBLE,
	10,
	80,
	140,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hInterval=CreateWindowEx(NULL,
		    "EDIT",
	szInterval,
	WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,
	170,
	80,
	40,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hUseHub=CreateWindowEx(NULL,
		    "BUTTON",
	"Use Hub",
	WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,
	170,
	115,
	100,
	20,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);

  hSave=CreateWindowEx(NULL,
		    "BUTTON",
	"&Save",
	WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON | WS_TABSTOP,
	220,
	165,
	80,
	24,
	g_hwndConfig,
	NULL,
	g_hInstance,
	NULL);
  if (bUseHub)
    SendMessage(hUseHub,BM_SETCHECK,TRUE,TRUE);

  SetFocus(hInstanceName);
}

BOOL ReadConfigFile()
{
  char buff[255], LHS[255], RHS[255];
  GetModuleFileName(plugin.hDllInstance,buff,255);
  buff[strlen(buff)-3] = 'I';
  buff[strlen(buff)-2] = 'N';
  buff[strlen(buff)-1] = 'I';

  // Get the path to winamp.exe
  if (g_lpWinampPath) delete []g_lpWinampPath;
  g_lpWinampPath = new char[strlen(buff)+1];
  strcpy(g_lpWinampPath,buff);
  g_lpWinampPath[strlen(g_lpWinampPath)-19] = NULL;


  FILE *f = fopen(buff,"rt");
  UINT i;

  if (!f)
  {    MessageBox(0,"The initialisation file gen_xpl.ini could not be opened.",APP_NAME,MB_ICONSTOP);
    return FALSE;
  }

  // Set values to defaults
  bUseHub = FALSE;
  g_Port = 3639;

  while (fgets(buff, 255, f))
  {
    if (buff[0] != '#')
    {
      for (i=0; i<strlen(buff);i++)
        if (buff[i]=='=') break;
    
      memcpy(LHS,buff,i);
      strcpy(RHS,(buff+i+1));    
      LHS[i] = NULL;
      RHS[strlen(RHS)-1] = NULL;
  
      // ADDRESS
      if (strcmp(LHS,"ADDRESS")==0)
      {
        g_lpAddress = new char[strlen(RHS)+1];
        strcpy(g_lpAddress,RHS);
      }    
      // HEARTBEAT_INTERVAL
      if (strcmp(LHS,"HEARTBEAT_INTERVAL")==0)
      {
        g_HBeatInterval = atoi(RHS);
      }
  

      // SOURCE
      if (strcmp(LHS,"SOURCE")==0)
      {
        g_lpSource = new char[strlen(RHS)+1];
        strcpy(g_lpSource,RHS);
      }

      // Use Hub
      if (strcmp(LHS,"USE_HUB")==0)
      {
        if (strcmp(RHS,"YES")==0)
          bUseHub = TRUE;
      }
    }
  }

  fclose(f);

  // Validate input
  if (g_lpAddress==NULL)
  {
    MessageBox(0,"Error! No ADDRESS field found in INI file.",APP_NAME,MB_ICONSTOP);
    return FALSE;
  }

  if (g_HBeatInterval==0)
    g_HBeatInterval = 60;

  return TRUE;
}

BOOL BindReceiver()
{
  UINT temp_port; // Temporary port value
  SOCKADDR_IN addr;                    // The local interface address

  sockReceiver = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  if (sockReceiver==SOCKET_ERROR)
  {
    return FALSE;
  }

  if (!bUseHub)
  {
    g_ListenerPort = 3639; // Default XPL port
    addr.sin_family = AF_INET;
    addr.sin_port = htons(g_ListenerPort);
    addr.sin_addr.s_addr = INADDR_ANY;

    if(bind(sockReceiver, (struct sockaddr *) &addr, sizeof(addr)) == SOCKET_ERROR)
    {
      return FALSE;
    }
  } else {

    // We're using a hub
    temp_port = 50001; // First port to try
    while (temp_port < 50099)
    {
      addr.sin_family = AF_INET;
      addr.sin_port = htons(temp_port);
      addr.sin_addr.s_addr = INADDR_ANY;

      if(bind(sockReceiver, (struct sockaddr *) &addr, sizeof(addr)) == SOCKET_ERROR)
      {
        // Failed to bind, so increment port
        temp_port++;
      } else {
        // Bound successfully
        g_ListenerPort = temp_port;
        temp_port = 3700;
      }
    }
  }
  return TRUE;
}

VOID toupperstr(char *buff)
{
  for (UINT i=0; i<strlen(buff);i++)
    buff[i] = toupper(buff[i]);
}

VOID HandleAudioBasicCommand(char *pszRHS, char *schemaType)
{
  char param[255];
  int tempnull = 0, slen = lstrlen(pszRHS);
  char *buffptr;

  // If there is a parameter, find the whitespace that separates it from the command word
  do {
    tempnull++;
  } while (tempnull < slen && pszRHS[tempnull]!=32);
  if (pszRHS[tempnull]==32)
  {
    buffptr = pszRHS + tempnull + 1;
    strcpy(param,buffptr);
  } else {
    param[0] = NULL;
  }
  pszRHS[tempnull] = NULL;

  // BACK
  if (strcmp(pszRHS,"BACK")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,40044,0);
  }

  // CLEAR
  if (strcmp(pszRHS,"CLEAR")==0)
  {
    PostMessage(plugin.hwndParent,WM_USER,0,101);
  }

  // PLAY
  if (strcmp(pszRHS,"PLAY")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,WINAMP_BUTTON2,0);
  }

  // RANDOM
  if (strcmp(pszRHS,"RANDOM")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,WINAMP_FILE_SHUFFLE,0);
  }

  // SKIP
  if (strcmp(pszRHS,"SKIP")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,40048,0);
  }

  // STATUS
  if (strcmp(pszRHS,"STATUS")==0 && strcmp(schemaType,"REQUEST")==0)
  {
    SendStatusMessage();
  }

  // STOP
  if (strcmp(pszRHS,"STOP")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,WINAMP_BUTTON4,0);
  }

  // VOLUME
  if (strcmp(pszRHS,"VOLUME")==0)
  {
    int volume;
    if (param[0]=='+' || param[0]=='>')
    {
      // Increase volume
      buffptr = param + 1;
      volume = atoi(buffptr);
      for (int i=0; i<volume; i++)
        SendMessage(plugin.hwndParent,WM_COMMAND,WINAMP_VOLUMEUP,0);
    } else if (param[0]=='-' || param[0]=='<')
    {
      // Decrease volume
      buffptr = param + 1;
      volume = atoi(buffptr);
      for (int i=0; i<volume; i++)
        SendMessage(plugin.hwndParent,WM_COMMAND,WINAMP_VOLUMEDOWN,0);
    } else {
      // Set to direct level
      buffptr = param;
      volume = atoi(buffptr);
      if (volume >= 0 && volume <= 100)
      {
        volume = 255*(volume/100.0);        
        SendMessage(plugin.hwndParent,WM_USER,volume,122);
      }
    }

  }

}

VOID HandleAudioExtendedCommand(char *pszRHS)
{
  char param[255];
  int tempnull = 0, slen = lstrlen(pszRHS);
  char *buffptr;

  // If there is a parameter, find the whitespace that separates it from the command word
  do {
    tempnull++;
  } while (tempnull < slen && pszRHS[tempnull]!=32);
  if (pszRHS[tempnull]==32)
  {
    buffptr = pszRHS + tempnull + 1;
    strcpy(param,buffptr);
  } else {
    param[0] = NULL;
  }
  pszRHS[tempnull] = NULL;

  // FADEOUT
  if (strcmp(pszRHS,"FADEOUT")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,40147,0);
  }

  // ADDFILE
  if (strcmp(pszRHS,"ADDFILE")==0)
  {
    char tempbuff[255];
    wsprintf(tempbuff,"%swinamp.exe /ADD %s",g_lpWinampPath, param);
    WinExec(tempbuff,SW_NORMAL);
  }

  // PAUSE
  if (strcmp(pszRHS,"PAUSE")==0)
  {
    PostMessage(plugin.hwndParent,WM_COMMAND,40046,0);
  }

  // PLAYFILE
  if (strcmp(pszRHS,"PLAYFILE")==0)
  {
    char tempbuff[255];
    wsprintf(tempbuff,"%swinamp.exe /ADD %s",g_lpWinampPath,param);
    SendMessage(plugin.hwndParent,WM_USER,0,101);
    WinExec(tempbuff,SW_NORMAL);
    SendMessage(plugin.hwndParent,WM_COMMAND,WINAMP_BUTTON2,0);
  }


}

VOID HandleXPLMessage(LPCTSTR lpBuff)
{
  char tempsource[MAX_XPL_MSG_SIZE];
  char buff[MAX_XPL_MSG_SIZE], *buffptr = NULL;
  char lhs[40], rhs[40];
  char schemaType[16], tempchar;
  UINT pos = 0, tempnull = 0;

  // Copy the incoming message into a local buffer and convert to upper case
  strcpy(buff,lpBuff);
  toupperstr(buff);

  // We're only interested in cmnd messages
  buff[8] = NULL;
  if (strcmp(buff,"XPL-CMND")!=0)
    return; // Not interested


  buff[8] = '{';

  // Make sure the target is for us
  do {
    if (memcmp(buff+pos,"TARGET=",7)==0)
    {
      buffptr = buff+pos;
      pos = strlen(buff);
    } else if (buff[pos]=='}') {
      pos = strlen(buff);
    } else {
      pos++;
    }
  } while (pos<(strlen(buff))-7);

  if (buffptr==NULL)
    return;

  // Find the Lf character
  pos = 0;
    do {
      if (buffptr[pos]==10)
      {
        tempnull = pos;
        pos = strlen(buffptr);
      } else {
        pos++;
      }
  } while (pos<strlen(buffptr));

  if (tempnull==0)
    return; // No Lf character was found

  buffptr[tempnull] = NULL;
  buffptr = buffptr + 7;

  wsprintf(tempsource,"%s-winamp.%s",VENDOR_ID,g_lpSource);
  toupperstr(tempsource);

  if (strcmp(buffptr,"*") != 0 && strcmp(buffptr,tempsource) != 0)
    return; // Message is not for us

  // Message is for us
  buffptr = buffptr + tempnull-4;

  // Ensure the schema is audio.*
  tempchar = buffptr[6];
  buffptr[6] = NULL;
  if (strcmp(buffptr,"AUDIO.") != 0)
    return; // Schema type is unsupported

  // Extract the schema type
  buffptr[6] = tempchar;
  buffptr = buffptr + 6;
  tempnull = 0;
  do {
    tempnull++;
  } while (buffptr[tempnull]!=10);
  buffptr[tempnull] = NULL;
  strcpy(schemaType,buffptr);
  buffptr[tempnull] = 10;
  buffptr = buffptr - 6;


  // Find the first tag
  tempnull = 0;
  do {
    tempnull++;
  } while (buffptr[tempnull]!='{' && buffptr[tempnull]!=NULL);

  if (buffptr[tempnull]==NULL) return; // Invalid data

  buffptr = buffptr + tempnull + 2;

  do {
    // Find the equals
    tempnull = 0;
    do {
      tempnull++;
    } while (buffptr[tempnull]!='=' && buffptr[tempnull]!=NULL);
    buffptr[tempnull] = NULL;
    strcpy(lhs,buffptr);
    buffptr = buffptr + tempnull + 1;

    // Find the end of the tag
    tempnull = 0;
    do {
      tempnull++;
    } while (buffptr[tempnull]!=10 && buffptr[tempnull]!=NULL);
    buffptr[tempnull] = NULL;
    strcpy(rhs,buffptr);
    buffptr = buffptr + tempnull + 1;

    // Determine the tag
    if (strcmp(lhs,"COMMAND")==0)
      HandleAudioBasicCommand(rhs,schemaType);
    else if (strcmp(lhs,"EXTENDED")==0 && strcmp(schemaType,"WINAMP")==0)
      HandleAudioExtendedCommand(rhs);
  } while (buffptr[0]!=NULL && buffptr[0]!='}');

}

VOID HandleIncomingMessage()
{
  char buff[MAX_XPL_MSG_SIZE];
  int bytes_read;

  do {
    bytes_read = recv(sockReceiver,buff,MAX_XPL_MSG_SIZE,0);
    if (bytes_read > 0)
    {
      buff[bytes_read] = NULL;
      HandleXPLMessage(buff);
    }
  } while (bytes_read > 0);
}

LRESULT CALLBACK ConfigWndProc(HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
  switch(Message)
  {
    case WM_COMMAND:
      if ((HWND)lParam==hSave || wParam==IDOK)
      {
        SaveConfigFile();
        DestroyWindow(g_hwndConfig);
      }
      break;
  }
  return DefWindowProc(hWnd,Message,wParam,lParam);
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
  switch(Message)
  {
    case WM_CREATE:
      if (sockReceiver != 0)
      {
        WSAAsyncSelect(sockReceiver,hWnd,WM_USER,FD_READ);
        SetTimer(hWnd, 1, (g_HBeatInterval*60)*1000, NULL);
        WndProc(hWnd,WM_TIMER,0,0);
      }
      break;
    case WM_TIMER:
      SendHeartbeat();
      break;
    case WM_QUIT:
      CleanupSocket();
      CleanupMemory();
      break;
    case WM_USER:
      if (wParam==1001 && lParam==1001)
        PrepareConfig();
      else
        HandleIncomingMessage();
  }
  return DefWindowProc(hWnd,Message,wParam,lParam);
}

DWORD WINAPI StartThread(LPVOID)
{
  HWND hWnd;
  MSG Message;
  WNDCLASS WndClass;

  // Initialise variables
  g_lpAddress = g_lpSource = g_lpWinampPath = NULL;
  g_hInstance=plugin.hDllInstance;
  sockSender = sockReceiver = 0;

  if (!ReadConfigFile())
  {
    return 0;
  }

  if (!InitSocket())
  {
    MessageBox(0,"Error initialising WinSock.",APP_NAME,MB_ICONSTOP);
    return 0;
  }

  if (!BindReceiver())
  {
    sockReceiver = 0;
    MessageBox(0,"The xPL plug-in was not able to set itself up to receive xPL messages.\nIf you are using an xPL hub on this computer, go into the plug-in's configuration dialog and make sure the Use Hub checkbox is selected.\n\nNote: You must use an xPL hub if you wish to run more than one xPL application on your computer at any one time.",APP_NAME,MB_ICONSTOP);
  }

  // Register Main window class
  WndClass.cbClsExtra=0;
  WndClass.cbWndExtra=0;
  WndClass.hbrBackground=GetSysColorBrush(COLOR_DESKTOP);
  WndClass.hCursor=LoadCursor(NULL,IDC_ARROW);
  WndClass.hIcon=LoadIcon(NULL,"END");
  WndClass.hInstance=g_hInstance;
  WndClass.lpfnWndProc=WndProc;
  WndClass.lpszClassName="WIN_ONE";
  WndClass.lpszMenuName="MENU";
  WndClass.style=CS_HREDRAW | CS_VREDRAW;
  RegisterClass(&WndClass);
  WndClass.lpfnWndProc=ConfigWndProc;
  WndClass.lpszClassName="XPLWINAMPCONFIG";
  RegisterClass(&WndClass);

  hWnd=CreateWindowEx(NULL,
		    "WIN_ONE",
	APP_NAME,
	WS_OVERLAPPEDWINDOW,
	0,
	0,
	100,
	100,
	NULL,
                    NULL,
                    g_hInstance,
                    NULL);

  g_hWnd = hWnd;
  while (GetMessage(&Message,0,0,0)) // Get Msg from sys Q in Struct
  {
    if (!IsDialogMessage(g_hwndConfig,&Message))
    {
      TranslateMessage(&Message); // Sends key press messages to app Q
      DispatchMessage(&Message);  // Send win msg to appropriate window
    }
  }
  return 0;
}

VOID SendHeartbeat()
{
  hostent *pht;
  LPTSTR lpszBuff = new char[MAX_XPL_MSG_SIZE];
  LPTSTR lpszBody = new char[MAX_XPL_MSG_SIZE+1];
  LPTSTR lpszLocalIP;
  sockaddr_in addr2;
  char szLocalHost[255];

  gethostname(szLocalHost,255);
  pht = gethostbyname(szLocalHost);
  memset(&addr2,0,sizeof(addr));
  memcpy((char *)&addr2.sin_addr, pht->h_addr, pht->h_length);   /* set address */

  lpszLocalIP = inet_ntoa(addr2.sin_addr);

  ConstructStatusBody(lpszBody);
  wsprintf(lpszBuff,"xpl-stat\n{\nhop=1\nsource=%s-winamp.%s\ntarget=*\n}\n"
	"hbeat.app\n{\ninterval=%d\nport=%d\n"
	"remote-ip=%s\n"
	"pid=%d\n"
	"schema=audio.basic\n"
	"%s"
	"}\n",
	VENDOR_ID,
	g_lpSource,
	g_HBeatInterval,
	g_ListenerPort,
	lpszLocalIP,
	g_hInstance,
	lpszBody
	);
  sendto(sockSender, lpszBuff, strlen(lpszBuff), 0, (struct sockaddr *) &addr, sizeof(addr));
  delete []lpszBuff;
  delete []lpszBody;
}

VOID SaveConfigFile()
{
  char buff[255];
  GetModuleFileName(plugin.hDllInstance,buff,255);
  buff[strlen(buff)-3] = 'I';
  buff[strlen(buff)-2] = 'N';
  buff[strlen(buff)-1] = 'I';
  FILE *f = fopen(buff,"wt");

  // Update the globals from the controls in the dialog box
  // SOURCE
  SendMessage(hInstanceName,WM_GETTEXT,(WPARAM)255,(LPARAM)&buff);
  delete []g_lpSource;
  g_lpSource = new char[strlen(buff)+1];
  strcpy(g_lpSource,buff);

  // ADDRESS
  SendMessage(hBroadcast,WM_GETTEXT,(WPARAM)255,(LPARAM)&buff);
  delete []g_lpAddress;
  g_lpAddress = new char[strlen(buff)+1];
  strcpy(g_lpAddress,buff);

  // HBEAT_INTERVAL
  SendMessage(hInterval,WM_GETTEXT,(WPARAM)255,(LPARAM)&buff);
  g_HBeatInterval = atoi(buff);

  // Use Hub
  if (SendMessage(hUseHub,BM_GETCHECK,0,0)==BST_CHECKED)
  {
    if (!bUseHub)
    {
      bUseHub = TRUE;
      MessageBox(g_hwndConfig,"You must restart Winamp before the xPL plug-in will start using a hub.",APP_NAME,MB_ICONINFORMATION);
    }
  } else {
    if (bUseHub)
    {
      bUseHub = FALSE;
      MessageBox(g_hwndConfig,"You must restart Winamp before the xPL plug-in will stop using a hub.",APP_NAME,MB_ICONINFORMATION);
    }
  }

  fprintf(f,"# Winamp xPL Plug-In Initialisation File\n");
  fprintf(f,"# http://www.xpl.myby.co.uk\n");
  fprintf(f,"#\n# ADDRESS specifies the broadcast address for outgoing xPL messages\n");
  fprintf(f,"ADDRESS=%s\n",g_lpAddress);
  fprintf(f,"\n# SOURCE specifies the instance name to be used by the plug-in\n");
  fprintf(f,"SOURCE=%s\n",g_lpSource);  
  fprintf(f,"\n# HEARTBEAT_INTERVAL indicates the interval between hbeat messages - must be between 5 and 30\n");
  fprintf(f,"HEARTBEAT_INTERVAL=%d\n",g_HBeatInterval);

  fprintf(f,"\n# USE_HUB specifies whether the plug-in will use a locally running xPL hub. Set to YES to use a hub, and NO to receive messages directly.\n");
  if (bUseHub)
    fprintf(f,"USE_HUB=YES\n");
  else
    fprintf(f,"USE_HUB=NO\n");
  fclose(f);
}

VOID ConstructStatusBody(char *body)
{
  int statusCode = SendMessage(plugin.hwndParent,WM_USER,0,104);
  char status[16];

  switch(statusCode)
  {
    case 1:
      strcpy(status,"playing");
      break;
    case 3:
      strcpy(status,"paused");
      break;
    default:
      strcpy(status,"stopped");
      break;
  }

  wsprintf(body,"status=%s\n",status);
}

VOID SendStatusMessage()
{
  char *body = new char[255];
  char msg[255];
  ConstructStatusBody(body);
  wsprintf(msg,"audio.basic\n{\n%s}\n",body);
  SendXplMessage("stat",msg);
  delete []body;
}

VOID SendXplMessage(char *MsgType, char *MsgBody)
{
  LPTSTR lpszBuff = new char[MAX_XPL_MSG_SIZE];
  LPTSTR lpszBody = new char[MAX_XPL_MSG_SIZE+1];
  LPTSTR lpszLocalIP;
  sockaddr_in addr2;
  memset(&addr2,0,sizeof(addr));

  wsprintf(lpszBuff,"xpl-%s\n{\nhop=1\nsource=%s-winamp.%s\ntarget=*\n}\n%s",
	MsgType,
	VENDOR_ID,
	g_lpSource,
	MsgBody
	);
  sendto(sockSender, lpszBuff, strlen(lpszBuff), 0, (struct sockaddr *) &addr, sizeof(addr));
  delete []lpszBuff;
  delete []lpszBody;
}
