unit mooncomp;

 {$i ah_def.inc }

{ Copyright 1997-2001 Andreas Hörstemeier            Version 1.3b 2001-01-16 }
{ this component is public domain - please check the file moon.hlp for       }
{ more detailed info on usage and distributing                               }

(*$b-*)   { I may make use of the shortcut boolean eval }

(*@/// interface *)
interface

(*@/// uses *)
uses
(*$ifndef delphi_1 *)
  windows,
(*$else *)
  winprocs,
  wintypes,
(*$endif *)
  messages,
  graphics,
  classes,
  controls,
  extctrls,
  sysutils,
  ah_math,
  moon;
(*@\\\0000000E0B*)

(*$ifdef delphi_1 *)
  {$r moon.r16 }            { The File containing the bitmaps }
(*$else *)
  {$r moon.r32 }            { The File containing the bitmaps }
(*$endif *)

type
  TMoonSize=(ms64,ms32,ms16);
  TMoonStyle=(msClassic,msColor);
  TRotate=(rot_none,rot_90,rot_180,rot_270);
  (*@/// TMoon=class(TImage) *)
  TMoon=class(TImage)   (* Borland, why no TCustomImage??? *)
  private
    F_Align: TAlign;
    FBMP : TBitmap;
    FMaxWidth,FMaxHeight: integer;
    FMoonSize: TMoonSize;
    FAngle: extended;
    FDate: TDateTime;
    FDateChanged: boolean;
    FIcon: TIcon;
    FRotate: TRotate;
    fApollo: boolean;
    FApolloDate: TDateTime;
    FStyle: TMoonStyle;
    procedure Set_Size(Value:TMoonSize);
    procedure SetDate(value:TDateTime);
    procedure SetRotate(value:TRotate);
    procedure SetStyle(value:TMoonStyle);
    procedure DoNothing(value:TPicture);
    procedure DoNothingIcon(value:TIcon);
  protected
    procedure SetBitmap;
    procedure Draw_Moon(canvas:TCanvas; offset_x,offset_y,radius,apollo_x,apollo_y:integer);
    procedure WMSize (var Message: TWMSize); message wm_paint;
    function GetIcon:TIcon;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  published
    property Align: TAlign read F_Align default alNone;
    property MoonSize:TMoonSize read FMoonSize write Set_Size;
    property Date: TDateTime read FDate write SetDate stored FDateChanged;
    property Picture write donothing stored false;
    property Icon:TIcon read GetIcon write donothingIcon stored false;
    property Rotation:TRotate read FRotate write SetRotate;
    property ShowApollo11:boolean read fApollo write FApollo;
    property MoonStyle:TMoonStyle read fStyle write SetStyle;
    end;
  (*@\\\0000002101*)
(*@\\\0000000F0F*)
(*@/// implementation *)
implementation

(*@/// procedure rotate_bitmap(source:TBitmap; rotate:TRotate); *)
procedure rotate_bitmap(source:TBitmap; rotate:TRotate);
var
  tempimage: TBitmap;
  w,h,i,j: integer;
  s_wnd, h_wnd: THandle;
begin
  tempimage:=NIL;
  try
    tempimage:=TBitmap.Create;
    tempimage.assign(source);
    h:=source.height-1;
    w:=source.width-1;
    s_wnd:=source.canvas.handle;
    h_wnd:=tempimage.canvas.handle;
    case rotate of
      rot_none: ;
      (*@/// rot_90:   rotate pixel by pixel *)
      rot_90: begin
        for i:=0 to w do
          for j:=0 to h do begin
            setpixel(s_wnd,i,h-j,getpixel(h_wnd,j,i));
            { Much faster than using canvas.pixels[] }
            end;
          end;
      (*@\\\000000041C*)
      (*@/// rot_180:  rotate via the StretchBlt *)
      rot_180: begin
        source.canvas.copyrect(
          rect(w,h,0,0),
          tempimage.canvas,
          rect(0,0,w,h));
        end;
      (*@\\\*)
      (*@/// rot_270:  rotate pixel by pixel *)
      rot_270: begin
        for i:=0 to w do
          for j:=0 to h do begin
            setpixel(s_wnd,w-i,j,getpixel(h_wnd,j,i));
            end;
        end;
      (*@\\\000000041C*)
      end;
  finally
    tempimage.free;
    end;
  end;
(*@\\\0000001201*)

const
  ResString:array[TMoonSize] of string=('MOON_LARGE'#0,'MOON_SMALL'#0,
                                        'MOON_TINY'#0);
  ResStringBW:array[TMoonSize] of string=
    ('MOON_BW_LARGE'#0,'MOON_BW_SMALL'#0,
                                        'MOON_BW_TINY'#0);
  ResStringColor:array[TMoonSize] of string=('MOON_COLOR_LARGE'#0,
                                             'MOON_COLOR_SMALL'#0,
                                             'MOON_COLOR_TINY'#0);
  size_moon:array[TMoonSize,0..6] of integer=
    ((64,64,28,31,28,41,29),
     (32,32,14,15,14,20,15),
     (16,16,7,7,7,9,7));   { max_x,max_y,offset_y,offset_x,radius,xApollo,yApollo }

(*@/// constructor TMoon.Create(AOwner: TComponent); *)
constructor TMoon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBMP := TBitmap.Create;  {Note dynamic allocation of the pointer}
  SetDate(now);
  FDateChanged:=false;
  ficon:=TIcon.Create;
  Set_Size(ms64);
  f_align:=alNone;
  fApollo:=true;
  FApolloDate:=EncodeDate(1969,7,20)+EncodeTime(20,17,43,0);
  end;
(*@\\\0000000B01*)
(*@/// procedure TMoon.SetBitmap; *)
procedure TMoon.SetBitmap;
begin
  case FStyle of
    msClassic: FBMP.Handle := LoadBitmap(hInstance, @ResString[FMoonSize][1]);
    msColor:   FBMP.Handle := LoadBitmap(hInstance, @ResStringColor[FMoonSize][1]);
    end;
  Self.Picture.Graphic := FBMP as TGraphic;
  draw_moon(self.canvas,size_moon[FMoonSize,3],
    size_moon[FMoonSize,2],size_moon[FMoonSize,4],
    size_moon[FMoonSize,5],size_moon[FMoonSize,6]);
  rotate_bitmap(self.picture.bitmap,frotate);
  end;
(*@\\\0000000701*)
(*@/// procedure TMoon.WMSize(var Message: TWMSize); *)
procedure TMoon.WMSize(var Message: TWMSize);
begin
  inherited;
  if (csDesigning in ComponentState) then begin
    Width := FMaxWidth;
    Height := FMaxHeight;
    end;
  end;
(*@\\\*)
(*@/// procedure TMoon.Set_Size(Value:TMoonSize); *)
procedure TMoon.Set_Size(Value:TMoonSize);
begin
  FMoonSize:=value;
  FMaxHeight:=size_moon[FMoonSize,0];
  FMaxWidth:=size_moon[FMoonSize,1];
  Self.Height := FMaxHeight;
  Self.Width := FMaxWidth;
  setbitmap;
  end;
(*@\\\0000000803*)
(*@/// procedure TMoon.Draw_Moon(canvas:TCanvas; offset_x,offset_y,radius,apollo_x,apollo_y:integer); *)
procedure TMoon.Draw_Moon(canvas:TCanvas; offset_x,offset_y,radius,apollo_x,apollo_y:integer);
var
  y,radius2: integer;
  xm,scale: extended;
  xmax,xmin:integer;
begin

(* FAngle = 0   -> New Moon
   FAngle = 90  -> First Quarter
   FAngle = 180 -> Full Moon
   FAngle = 270 -> Last Quarter *)

  if fApollo and (FApolloDate<fdate) then begin
    canvas.pixels[apollo_x,apollo_y]:=clRed;
    end;
  canvas.brush.color:=clBlack;
  radius2:=radius*radius;
  scale:=cos_d(fangle);
  for y:=0 to radius do begin
    xm:=sqrt(radius2-y*y);
    xmax:=round(xm);
    xmin:=round(xm*scale);
    if fangle<180 then begin
      xmax:=offset_x-xmax-1;
      xmin:=offset_x-xmin;
      end
    else begin
      xmax:=offset_x+xmax+1;
      xmin:=offset_x+xmin;
      end;
    canvas.moveto(xmin,y+offset_y);
    canvas.lineto(xmax,y+offset_y);
    canvas.moveto(xmin,-y+offset_y);
    canvas.lineto(xmax,-y+offset_y);
    end;
  end;
(*@\\\*)
(*@/// procedure TMoon.SetDate(Value: TDateTime); *)
procedure TMoon.SetDate(Value: TDateTime);
begin
  FDate:=Value;
  FAngle:=put_in_360(moon_phase_angle(Value));
  setbitmap;
  FDateChanged:=true;
  end;
(*@\\\0000000601*)
(*@/// procedure TMoon.SetRotate(value:TRotate); *)
procedure TMoon.SetRotate(value:TRotate);
begin
  if frotate<>value then begin
    frotate:=value;
    setbitmap;
    end;
  end;
(*@\\\0000000301*)
(*@/// procedure TMoon.SetStyle(value:TMoonStyle); *)
procedure TMoon.SetStyle(value:TMoonStyle);
begin
  if fstyle<>value then begin
    fstyle:=value;
    setbitmap;
    end;
  end;
(*@\\\*)
(*@/// procedure TMoon.DoNothing(value:TPicture); *)
procedure TMoon.DoNothing(value:TPicture);
begin
  end;
(*@\\\*)
(*@/// procedure TMoon.DoNothingIcon(value:TIcon); *)
procedure TMoon.DoNothingIcon(value:TIcon);
begin
  end;
(*@\\\*)
(*@/// destructor TMoon.Destroy; *)
destructor TMoon.Destroy;
begin
  FBMP.free;
  ficon.free;
  inherited destroy;
  end;
(*@\\\*)
(*@/// function TMoon.GetIcon:TIcon; *)
function TMoon.GetIcon:TIcon;
var
  IconSizeX : integer;
  IconSizeY : integer;
  AndMask : TBitmap;
  XOrMask : TBitmap;
(*$ifdef delphi_1 *)
  BitmapX,BitmapA: wintypes.TBitmap;
  AndData, XOrData: pointer;
  AndLen, XorLen: integer;
(*$else *)
  IconInfo : TIconInfo;
(*$endif *)
  Size: TMoonSize;
begin
  AndMask:=NIL;
  XOrMask:=NIL;
  try
    {Get the icon size}
    IconSizeX := GetSystemMetrics(SM_CXICON);
    IconSizeY := GetSystemMetrics(SM_CYICON);

    Size:=ms32;
    if false then
    else if (IconSizeX=16) and (IconSizeY=16) then
      Size:=ms16
    else if (IconSizeX=32) and (IconSizeY=32) then
      Size:=ms32
    else if (IconSizeX=64) and (IconSizeY=64) then
      size:=ms64
    else
      (* ??? *);

    {Create the "And" mask}
    AndMask := TBitmap.Create;
    AndMask.Monochrome := true;
    AndMask.Width := IconSizeX;
    AndMask.Height := IconSizeY;

    FBMP.Handle := LoadBitmap(hInstance, @ResStringBW[Size][1]);
    AndMask.canvas.copyrect(Rect(0,0,size_moon[Size,0],size_moon[Size,1]),
                         FBMP.canvas,
                         Rect(0,0,size_moon[Size,0],size_moon[Size,1]));

    {Create the "XOr" mask}
    XOrMask := TBitmap.Create;
    XOrMask.Width := IconSizeX;
    XOrMask.Height := IconSizeY;

    {Draw on the "XOr" mask}
    case FStyle of
      msClassic: FBMP.Handle := LoadBitmap(hInstance, @ResString[Size][1]);
      msColor:   FBMP.Handle := LoadBitmap(hInstance, @ResStringColor[Size][1]);
      end;

    XOrMask.canvas.copyrect(Rect(0,0,size_moon[Size,0],size_moon[Size,1]),
                         FBMP.canvas,
                         Rect(0,0,size_moon[Size,0],size_moon[Size,1]));

    draw_moon(XOrMask.Canvas,size_moon[Size,3],
      size_moon[Size,2],size_moon[Size,4],
      size_moon[Size,5],size_moon[Size,6]);

    rotate_bitmap(XOrMask,frotate);
    rotate_bitmap(AndMask,frotate);

    (*@/// Create a icon *)
    (*$ifdef delphi_1 *)
    AndData:=NIL;
    XorData:=NIL;
    try
      GetObject(AndMask.handle, SizeOf(BitmapA), @BitmapA);
      AndLen := BitmapA.bmWidthBytes * BitmapA.bmHeight * BitmapA.bmPlanes;
      AndData := MemAlloc(AndLen);
      GetBitmapBits(AndMask.handle, AndLen, AndData);
      GetObject(XOrMask.handle, SizeOf(BitmapX), @BitmapX);
      XorLen := BitmapX.bmWidthBytes * BitmapX.bmHeight * BitmapX.bmPlanes;
      XorData := MemAlloc(XorLen);
      GetBitmapBits(XorMask.handle, XorLen, XorData);

      FIcon.Handle := CreateIcon(hinstance,IconSizeX,IconSizeY,
        BitmapX.bmPlanes,BitmapX.bmBitsPixel, AndData, XOrData);
    finally
      if AndData<>NIL then  FreeMem(AndData, AndLen);
      if XorData<>NIL then  FreeMem(XorData, XorLen);
      end;
    (*$else *)
    IconInfo.fIcon := true;
    IconInfo.xHotspot := 0;
    IconInfo.yHotspot := 0;
    IconInfo.hbmMask := AndMask.Handle;
    IconInfo.hbmColor := XOrMask.Handle;
    FIcon.Handle := CreateIconIndirect(IconInfo);
    (*$endif *)
    (*@\\\*)

    result := FIcon;
  finally
    AndMask.Free;
    XOrMask.Free;
    end;
  end;
(*@\\\0000004A07*)
(*@\\\0000001D01*)
(*$ifdef delphi_ge_2 *) (*$warnings off *) (*$endif *)
end.
(*@\\\003F000D01000D01000D01000E01000E05000011000E05*)
