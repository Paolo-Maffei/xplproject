unit TrayIcon;
(*@/// history *)
(*

  TTrayIcon

  Version 1.4

  Requires:  Any 32-bit version of Delphi (2 or greater)

  Function: Adds an icon to the Windows 95 Tool Tray and
            has events to respond to mouse clicks.

  Original author:  Derek Stutsman (dereks@metronet.com)
  Second author:    Pete Ness (102347.710@compuserve.com)
  Third author:     Greg Lief (greg@greglief.com)
  Fourth author:    Jesse C. Slicer (jslicer@planetkc.com)

  Release history:

  3/8/96 - Version 1.0 (Derek Stutsman)
     Initial release as TToolIcon.

  3/12/96 - Version 1.1 (Pete Ness)

     Various changes, renamed to TTrayIcon.

  3/29/96 - Version 1.2 (Pete Ness)
     Add default window handling to allow closing when Win95 shutdown.
     Previously, you had to manually close your application before closing
     Windows 95.

  4/17/96 - Version 1.3 (Pete Ness)
     Added a PopupMenu property to automatically handle right clicking on
     the tray icon.
     Fixed bug that would not allow you to instantiate a TTrayIcon instance
     at run-time.

  7/23/98 - Version 1.4 (Greg Lief)
     Added Images, Animate, and AnimateInterval properties, all of which
     serve to simplify the task of animating the tray icon.  Steps:

     1) Drop a TImageList component on your form and load it with the
        desired icons.
     2) Plug it into the TTrayIcon component via the Images property.
     3) Set the Active and Animate properties to True.
     4) Tweak the AnimateInterval property as desired.

  1999-Jul-28 - Version 1.5 (Jesse C. Slicer)
     - Dynamically request a window message for WM_TOOLTRAYICON and
       WM_RESETTOOLTIP instead of WM_USER+1 and WM_USER+2, respectively.  Many
       apps use the WM_USER+x methods and doing dynamically keeps conflicts from
       occurring.
     - Separated the different NIF_ tray icon notification messages for
       improved efficiency.  No need to continuously set the uCallbackMessage
       parameter if only the icon is being changed.
*)
(*@\\\0000003701*)
(*@/// interface *)
interface

uses
  Windows, Messages, Classes, Graphics, Controls, ShellAPI, Menus, ExtCtrls,
  Forms;

const
  sWM_TOOLTRAYICON: PChar   = 'WM_TOOLTRAYICON';
  sWM_RESETTOOLTIP: PChar   = 'WM_RESETTOOLTIP';
  iDEFAULT_ANIMATE_INTERVAL = 100;

var
  WM_TOOLTRAYICON : UINT    = 0;
  WM_RESETTOOLTIP : UINT    = 0;

type
  TModIconTypes             = (modUnknown, modMessage, modIcon, modToolTip);
  TModIconOps               = set of TModIconTypes;

  (*@/// TTrayIcon                 = class(TComponent) *)
  TTrayIcon                 = class(TComponent)
  private
    //Private declarations
    IconData      : TNotifyIconData;
    FAnimate,
    FActive,
    FShowDesigning: Boolean;
    FAnimateInterval,
    FCurrentImage : Integer;
    FIcon,
    FOriginalIcon : TIcon;   //storage location used if developer chooses to animate tray icon
    FToolTip      : string;
    FWindowHandle : HWND;
    FTimer        : TTimer;
    FOnClick,
    FOnDblClick   : TNotifyEvent;
    FOnRightClick : TMouseEvent;
    FPopupMenu    : TPopupMenu;
    FImages       : TImageList;

    function AddIcon: Boolean;
    function ModifyIcon(modIconOps: TModIconOps): Boolean;
    function DeleteIcon: Boolean;

    procedure SetActive(bValue: Boolean);
    procedure SetAnimate(bValue: Boolean);
    procedure SetAnimateInterval(iValue: Integer);
    procedure SetShowDesigning(bValue: Boolean);
    procedure SetIcon(icnValue: TIcon);
    procedure SetToolTip(const sValue: string);
    procedure WndProc(var msg: TMessage);

    procedure FillDataStructure(modIconOps: TModIconOps);
    procedure ChangeIcon(Sender: TObject);

  protected
    //Protected declarations
    procedure Notification(AComponent: TComponent;
                           Operation : TOperation); override;
    procedure DoDblClick(Sender: TObject);
    procedure DoClick(Sender: TObject);
    procedure DoRightClick(Sender: TObject);

  public
    //Public declarations
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Handle         : HWND         read FWindowHandle;

  published
    //Published declarations
    property Active         : Boolean      read FActive          write SetActive;
    property Animate        : Boolean      read FAnimate         write SetAnimate;
    property AnimateInterval: Integer      read FAnimateInterval write SetAnimateInterval default iDEFAULT_ANIMATE_INTERVAL;
    property ShowDesigning  : Boolean      read FShowDesigning   write SetShowDesigning;
    property Icon           : TIcon        read FIcon            write SetIcon;
    property Images         : TImageList   read FImages          write FImages;
    property ToolTip        : string       read FTooltip         write SetToolTip;

    property OnClick        : TNotifyEvent read FOnClick         write FOnClick;
    property OnDblClick     : TNotifyEvent read FOnDblClick      write FOnDblClick;
    property OnRightClick   : TMouseEvent  read FOnRightClick    write FonRightClick;
    property PopupMenu      : TPopupMenu   read FPopupMenu       write FPopupMenu;
  end;
  (*@\\\*)

procedure Register;
(*@\\\*)
(*@/// implementation *)
implementation
uses
  Dialogs, SysUtils;

const
  cCR = #13;


(*@/// constructor TTrayIcon.Create(AOwner: TComponent); *)
constructor TTrayIcon.Create(AOwner: TComponent);
{$IFDEF VER90}  //Delphi 2 doesn't support resourcestring
const
{$ELSE}
resourcestring
{$ENDIF}
  rsAboutBox = 'TTrayIcon version 1.5' + cCR +
               'Original author: Derek Stutsman' + cCR +
               'More mods by Pete Ness' + cCR +
               'Yet more mods by Greg Lief' + cCR +
               'Even more mods by Jesse C. Slicer';

begin //constructor TTrayIcon.Create
  inherited Create(AOwner);
  FWindowHandle    := AllocateHWnd(WndProc);
  WM_TOOLTRAYICON  := RegisterWindowMessage(sWM_TOOLTRAYICON);
  WM_RESETTOOLTIP  := RegisterWindowMessage(sWM_RESETTOOLTIP);
  FIcon            := TIcon.Create;
  FOriginalIcon    := TIcon.Create;
  FAnimateInterval := iDEFAULT_ANIMATE_INTERVAL;
  FTimer           := TTimer.Create(Self);
  with FTimer do
  begin //with
    Enabled        := False;
    OnTimer        := ChangeIcon;
  end; //with
  if csDesigning in ComponentState then
    MessageDlg(rsAboutBox, mtInformation, [mbOK], 0);
end; //constructor TTrayIcon.Create
(*@\\\*)
(*@/// destructor TTrayIcon.Destroy; *)
destructor TTrayIcon.Destroy;
begin //destructor TTrayIcon.Destroy
  if (not (csDesigning in ComponentState) and FActive) or
     ((csDesigning in ComponentState) and FShowDesigning) then
    DeleteIcon;
  FTimer.Free;
  FOriginalIcon.Free;
  FIcon.Free;
  DeAllocateHWnd(FWindowHandle);
  inherited Destroy;
end; //destructor TTrayIcon.Destroy
(*@\\\*)
(*@/// procedure TTrayIcon.Notification(AComponent: TComponent; *)
procedure TTrayIcon.Notification(AComponent: TComponent;
                                 Operation : TOperation);
begin //procedure TTrayIcon.Notification
  if (AComponent = FImages) and (Operation = opRemove) then
  begin //if..then
    Animate := False;
    FImages := nil;
  end; //if..then
end; //procedure TTrayIcon.Notification
(*@\\\*)
(*@/// procedure TTrayIcon.DoDblClick(Sender: TObject); *)
procedure TTrayIcon.DoDblClick(Sender: TObject);
begin //procedure TTrayIcon.DoDblClick
  if Assigned(FOnDblClick) then
    FOnDblClick(Sender);
end; //procedure TTrayIcon.DoDblClick
(*@\\\*)
(*@/// procedure TTrayIcon.DoClick(Sender: TObject); *)
procedure TTrayIcon.DoClick(Sender: TObject);
begin //procedure TTrayIcon.DoClick
  if Assigned(FOnClick) then
    FOnClick(Sender);
end; //procedure TTrayIcon.DoClick
(*@\\\*)
(*@/// procedure TTrayIcon.DoRightClick(Sender: TObject); *)
procedure TTrayIcon.DoRightClick(Sender: TObject);
var
  MouseCo: TPoint;

begin //procedure TTrayIcon.DoRightClick
  GetCursorPos(MouseCo);
  if Assigned(FPopupMenu) then
  begin //if..then
    SetForegroundWindow(Application.Handle);
    Application.ProcessMessages;
    FPopupMenu.Popup(MouseCo.x, MouseCo.y);
  end; //if..then
  if Assigned(FOnRightClick) then
    FOnRightClick(Sender, mbRight, [], MouseCo.x, MouseCo.y);
end; //procedure TTrayIcon.DoRightClick
(*@\\\*)
(*@/// function TTrayIcon.AddIcon: Boolean; *)
function TTrayIcon.AddIcon: Boolean;
begin //function TTrayIcon.AddIcon
  FillDataStructure([modMessage, modIcon, modToolTip]);
  Result := Shell_NotifyIcon(NIM_ADD, @IconData);
  //For some reason, if there is no tool tip set up, then the icon
  //doesn't display.  This fixes that.
  if FToolTip = '' then
    PostMessage(FWindowHandle, WM_RESETTOOLTIP, 0, 0);
end; //function TTrayIcon.AddIcon
(*@\\\*)
(*@/// function TTrayIcon.ModifyIcon(modIconOps: TModIconOps): Boolean; *)
function TTrayIcon.ModifyIcon(modIconOps: TModIconOps): Boolean;
begin //function TTrayIcon.ModifyIcon
  FillDataStructure(modIconOps);
  if FActive then
    Result := Shell_NotifyIcon(NIM_MODIFY, @IconData)
  else
    Result := True;
end; //function TTrayIcon.ModifyIcon
(*@\\\*)
(*@/// function TTrayIcon.DeleteIcon: Boolean; *)
function TTrayIcon.DeleteIcon: Boolean;
begin //function TTrayIcon.DeleteIcon
  Result := Shell_NotifyIcon(NIM_DELETE, @IconData);
end; //function TTrayIcon.DeleteIcon
(*@\\\*)
(*@/// procedure TTrayIcon.SetActive(bValue: Boolean); *)
procedure TTrayIcon.SetActive(bValue: Boolean);
begin //procedure TTrayIcon.SetActive
  if bValue <> FActive then
  begin //if..then
    FActive := bValue;
    if not (csdesigning in ComponentState) then
      if FActive then
        AddIcon
      else
        DeleteIcon;
  end; //if..then
end; //procedure TTrayIcon.SetActive
(*@\\\*)
(*@/// procedure TTrayIcon.SetAnimate(bValue: Boolean); *)
procedure TTrayIcon.SetAnimate(bValue: Boolean);
begin //procedure TTrayIcon.SetAnimate
  if (not bValue) or
     (Assigned(FImages) and (FImages.Count > 0) and FActive) then
  begin //if..then 1
     FAnimate        := bValue;
     if FAnimate then
     begin //if..then 2
       FOriginalIcon.Assign(fIcon);
       FCurrentImage := 0;
     end; //if..then 2
     FTimer.Enabled  := FAnimate;
     if not bValue then
       SetIcon(FOriginalIcon);
  end; //if..then 1
end; //procedure TTrayIcon.SetAnimate
(*@\\\*)
(*@/// procedure TTrayIcon.SetAnimateInterval(iValue: Integer); *)
procedure TTrayIcon.SetAnimateInterval(iValue: Integer);
begin //procedure TTrayIcon.SetAnimateInterval
  if iValue > 0 then
  begin //if..then
    FAnimateInterval := iValue;
    FTimer.Interval  := FAnimateInterval;
  end; //if..then
end; //procedure TTrayIcon.SetAnimateInterval
(*@\\\*)
(*@/// procedure TTrayIcon.SetShowDesigning(bValue: Boolean); *)
procedure TTrayIcon.SetShowDesigning(bValue: Boolean);
begin //procedure TTrayIcon.SetShowDesigning
  if csDesigning in ComponentState then
    if bValue <> FShowDesigning then
    begin //if..then
      FShowDesigning := bValue;
      if FShowDesigning then
        AddIcon
      else
        DeleteIcon;
   end; //if..then
end; //procedure TTrayIcon.SetShowDesigning
(*@\\\*)
(*@/// procedure TTrayIcon.SetIcon(icnValue: TIcon); *)
procedure TTrayIcon.SetIcon(icnValue: TIcon);
begin //procedure TTrayIcon.SetIcon
  if icnValue <> FIcon then
  begin //if..then
    FIcon.Assign(icnValue);
    ModifyIcon([modIcon]);
  end; //if..then
end; //procedure TTrayIcon.SetIcon
(*@\\\*)
(*@/// procedure TTrayIcon.SetToolTip(const sValue: string); *)
procedure TTrayIcon.SetToolTip(const sValue: string);
begin //procedure TTrayIcon.SetToolTip
   //This routine ALWAYS re-sets the field value and re-loads the
   //icon.  This is so the ToolTip can be set blank when the component
   //is first loaded.  If this is changed, the icon will be blank on
   //the tray when no ToolTip is specified.
   FToolTip := Copy(sValue, 1, 62);
   ModifyIcon([modToolTip, modIcon]);
end; //procedure TTrayIcon.SetToolTip
(*@\\\*)
(*@/// procedure TTrayIcon.WndProc(var msg: TMessage); *)
procedure TTrayIcon.WndProc(var msg: TMessage);
begin //procedure TTrayIcon.WndProc
  with msg do
    if msg = WM_RESETTOOLTIP then
       SetToolTip(FToolTip)
    else
      if msg = WM_TOOLTRAYICON then
        case lParam of
          WM_LBUTTONDBLCLK: DoDblClick(Self);
          WM_LBUTTONUP    : DoClick(Self);
          WM_RBUTTONUP    : DoRightClick(Self);
        end
      else //Handle all messages with the default handler
        Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end; //procedure TTrayIcon.WndProc
(*@\\\*)
(*@/// procedure TTrayIcon.FillDataStructure(modIconOps: TModIconOps); *)
procedure TTrayIcon.FillDataStructure(modIconOps: TModIconOps);
begin //procedure TTrayIcon.FillDataStructure
  with IconData do
  begin //with
     cbSize             := SizeOf(TNotifyIconData);
     wnd                := FWindowHandle;
     uID                := 0; //is not passed in with message so make it 0
     uFlags             := 0;
     if modMessage in modIconOps then
     begin //if..then
       uFlags           := uFlags or NIF_MESSAGE;
       uCallbackMessage := WM_TOOLTRAYICON;
     end; //if..then
     if modIcon in modIconOps then
     begin //if..then
       uFlags           := uFlags or NIF_ICON;
       hIcon            := FIcon.Handle;
     end; //if..then
     if modToolTip in modIconOps then
     begin //if..then
       uFlags           := uFlags or NIF_TIP;
       StrPCopy(szTip, FToolTip);
     end; //if..then
  end; //with
end; //procedure TTrayIcon.FillDataStructure
(*@\\\*)
(*@/// procedure TTrayIcon.ChangeIcon(Sender: TObject); *)
procedure TTrayIcon.ChangeIcon(Sender: TObject);
var
  icnTempIcon: TIcon;

begin //procedure TTrayIcon.ChangeIcon
   icnTempIcon       := TIcon.Create;
   try
     if FCurrentImage = Pred(FImages.Count) then
       FCurrentImage := 0
     else
       Inc(FCurrentImage);
     FImages.GetIcon(FCurrentImage, icnTempIcon);
     SetIcon(icnTempIcon);
   finally
     icnTempIcon.Free;
   end; //try..finally
end; //procedure TTrayIcon.ChangeIcon
(*@\\\*)

(*@/// procedure Register; *)
procedure Register;
begin //procedure Register
{$IFDEF VER90}  //Delphi 2 uses the Win95 palette page
  RegisterComponents('Win95', [TTrayIcon]);
{$ELSE}         //Delphi 3 and 4 use the Win32 palette page
  RegisterComponents('Win32', [TTrayIcon]);
{$ENDIF}
end; //procedure Register
(*@\\\*)
(*@\\\0000001C01*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end. //unit TrayIcon
(*@\\\000E000501000531000601000601*)
