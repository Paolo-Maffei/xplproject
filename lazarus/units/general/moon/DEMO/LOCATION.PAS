unit location;
(*@/// interface *)
interface

uses
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  Windows,
(*$endif *)
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Mask, inifiles, consts, ah_tool;

type
  (*@/// TLocation=class(TObject) *)
  TLocation=class(TObject)
    name: string;
    latitude, longitude: extended;
    height: integer;
    procedure SaveToIni(nr:integer; IniFile : TIniFile);
    end;
  (*@\\\0000000321*)
  (*@/// Tfrm_locations = class(TForm) *)
  Tfrm_locations = class(TForm)
    lbx_location: TListBox;
    btn_plus: TSpeedButton;
    btn_minus: TSpeedButton;
    btn_new: TSpeedButton;
    btn_del: TSpeedButton;
    edt_name: TEdit;
    lbl_longitude: TLabel;
    edt_longitude: TMaskEdit;
    lbl_latitude: TLabel;
    edt_latitude: TMaskEdit;
    lbl_altitude: TLabel;
    edt_altitude: TMaskEdit;
    btn_ok: TButton;
    btn_cancel: TButton;
      btn_import: TButton;
      dlg: TOpenDialog;
    procedure lbx_locationClick(Sender: TObject);
    procedure btn_plusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_minusClick(Sender: TObject);
    procedure btn_newClick(Sender: TObject);
    procedure edtChange(Sender: TObject);
    procedure btn_delClick(Sender: TObject);
    procedure btn_okClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
      procedure btn_importClick(Sender: TObject);
  private
    locations: TList;
    changing: boolean;
  end;
  (*@\\\0000000501*)

procedure load_locations(const filename: string; var locations:TList; var current:integer);
procedure save_locations(const filename: string; locations: TList; current:integer);

var
  frm_locations: Tfrm_locations;
(*@\\\0000000A03*)
(*@/// implementation *)
implementation

uses
  main;

{$R *.DFM}
(*$i moontool.inc *)
(*$i ah_def.inc *)

(*$ifdef delphi_1 *)
(*@/// function trim(const s:string):string; *)
(*@/// function poscn(c:char; const s:string; n: integer):integer; *)
function poscn(c:char; const s:string; n: integer):integer;

{ Find the n'th occurence of a character different to c,
  if n<0 look from the back }

var
  i: integer;
begin
  if n=0 then  n:=1;
  if n>0 then begin
    for i:=1 to length(s) do begin
      if s[i]<>c then begin
        dec(n);
        result:=i;
        if n=0 then begin
          EXIT;
          end;
        end;
      end;
    end
  else begin
    for i:=length(s) downto 1 do begin
      if s[i]<>c then begin
        inc(n);
        result:=i;
        if n=0 then begin
          EXIT;
          end;
        end;
      end;
    end;
  poscn:=0;
  end;
(*@\\\*)
function trim(const s:string):string;
var
  h: integer;
begin
  (* trim from left *)
  h:=poscn(' ',s,1);
  if h>0 then
    result:=copy(s,h,length(s))
  else
    result:=s;
  (* trim from right *)
  h:=poscn(' ',result,-1);
  if h>0 then
    result:=copy(result,1,h);
  end;
(*@\\\0000000201*)
(*$endif *)

(*@/// class TLocation(TObject) *)
procedure TLocation.SaveToIni(nr:integer; IniFile : TIniFile);
var
  s: string;
begin
  s:='Location'+inttostr(nr);
  IniFile.WriteString(s,'Name',name);
  IniFile.WriteInteger(s,'Longitude',round(longitude*3600));
  IniFile.WriteInteger(s,'Latitude',round(latitude*3600));
  IniFile.WriteInteger(s,'Elevation',height);
  end;
(*@\\\*)

(*@/// procedure load_locations(const filename: string; var locations:TList; var current:integer); *)
procedure load_locations(const filename: string; var locations:TList; var current:integer);
var
  IniFile : TIniFile;
  h: TLocation;
  s: string;
  nr: integer;
begin
  if locations=NIL then
    locations:=TList.Create;
  IniFile:=NIL;
  try
    IniFile := TIniFile.Create(filename);
    nr:=0;
    repeat
      h:=tlocation.create;
      s:='Location'+inttostr(nr);
      h.name:=IniFile.ReadString(s,'Name','...');
      h.longitude:=IniFile.ReadInteger(s,'Longitude',0)/3600;
      h.latitude:=IniFile.ReadInteger(s,'Latitude',0)/3600;
      h.height:=IniFile.ReadInteger(s,'Elevation',0);
      if h.name='...' then
        BREAK;
      locations.add(h);
      h:=NIL;
      inc(nr);
    until false;
    h.free;
    current:=IniFile.ReadInteger('Current','Index',0);
  finally
    Inifile.Free;
    end;
  end;
(*@\\\0000001C05*)
(*@/// procedure save_locations(const filename: string; locations: TList; current:integer); *)
procedure save_locations(const filename: string; locations: TList; current:integer);
var
  IniFile : TIniFile;
  i,nr: integer;
begin
  if locations=NIL then EXIT;
  IniFile:=NIL;
  try
    IniFile := TIniFile.Create(filename);
    nr:=0;
    for i:=locations.count-1 downto 0 do begin
      if (locations.items[0]<>NIL) and
         (TObject(locations.items[0]) is TLocation) then begin
        TLocation(locations.items[0]).SaveToIni(nr,inifile);
        inc(nr);
        end;
      TObject(locations.items[0]).free;
      locations.delete(0);
      end;
    Inifile.writeinteger('Current','Index',current);
  finally
    Inifile.Free;
    end;
  end;
(*@\\\0000000901*)

(*@/// function FloatToDegree(value: extended):string; *)
function FloatToDegree(value: extended):string;
var
  d,m,s: integer;
begin
  if value<0 then
    result:='-'
  else
    result:='';
  value:=round(abs(value)*3600);
  s:=round(value) mod 60;
  m:=round((value-s)/60) mod 60;
  d:=round((value-s-m*60)/3600);
  result:=result+inttostr(d)+':'
                +inttostr(m)+':'
                +inttostr(s);
  end;
(*@\\\0000000C01*)
(*@/// function StrToDegree(const value:string):extended; *)
function StrToDegree(const value:string):extended;
var
  p,q,v,sgn: integer;
  s: string;
begin
  p:=pos(':',value)-1;
  v:=length(value);
  if p<0 then
    p:=v;
  try
    result:=strtoint(trim(copy(value,1,p)));
  except
    if (v>0) and (value[1] in ['+','-']) then begin
      s:=trim(copy(value,2,p-1));
      result:=strtoint(s);
      end
    else
      raise;
    end;
  sgn:=1;
  if (result<0) or (pos('-',value)>0) then begin
    sgn:=-1;
    result:=sgn*abs(result);
    end;
  if p<v then begin
    q:=posn(':',value,2);
    if (q<0) or (q>v) then
      q:=v-p
    else
      q:=q-p-2;
    s:=copy(value,p+2,q);
    result:=result+sgn*strtoint(s)/60;
    p:=p+q+2;
    end;
  if p<v then begin
    q:=posn(':',value,3);
    if (q<0) or (q>v) then
      q:=v-p
    else
      q:=q-p-2;
    s:=copy(value,p+1,q);
    result:=result+sgn*strtoint(s)/3600;
    end;
  end;
(*@\\\0000000C29*)

(*@/// procedure Tfrm_locations.lbx_locationClick(Sender: TObject); *)
procedure Tfrm_locations.lbx_locationClick(Sender: TObject);
var
  h: TLocation;
begin
  if lbx_location.itemindex>-1 then begin
    h:=TLocation(locations.items[lbx_location.itemindex]);
    try
      changing:=true;
      edt_name.text:=h.name;
      edt_longitude.text:=FloatToDegree(h.longitude);
      edt_latitude.text:=FloatToDegree(h.latitude);
      edt_altitude.text:=inttostr(h.height);
      edt_name.enabled:=true;
      edt_longitude.enabled:=true;
      edt_latitude.enabled:=true;
      edt_altitude.enabled:=true;
      btn_plus.enabled:=true;
    finally
      changing:=false;
      end;
    end
  else begin
    edt_name.enabled:=false;
    edt_longitude.enabled:=false;
    edt_latitude.enabled:=false;
    edt_altitude.enabled:=false;
    btn_plus.enabled:=false;
    end;
  btn_minus.enabled:=(lbx_location.itemindex>0) and (lbx_location.itemindex<lbx_location.items.count-1)
  end;
(*@\\\0000001E07*)
(*@/// procedure Tfrm_locations.edt_nameChange(Sender: TObject); *)
procedure Tfrm_locations.edtChange(Sender: TObject);
var
  p: integer;
  h: TLocation;
begin
  if not changing then begin
    p:=lbx_location.itemindex;
    if p>-1 then begin
      h:=TLocation(locations.items[p]);
      h.name:=edt_name.text;
      try
        h.longitude:=StrToDegree(edt_longitude.text);
      except
        end;
      try
        h.latitude:=StrToDegree(edt_latitude.text);
      except
        end;
      h.height:=strtoint(trim(edt_altitude.text));
      lbx_location.items.strings[p]:=h.name;
      lbx_location.itemindex:=p;
      end;
    end;
  end;
(*@\\\0000001331*)

(*@/// procedure Tfrm_locations.btn_delClick(Sender: TObject); *)
procedure Tfrm_locations.btn_delClick(Sender: TObject);
var
  p: integer;
begin
  p:=lbx_location.itemindex;
  if p>-1 then begin
    TObject(locations.items[p]).free;
    locations.delete(p);
    lbx_location.items.delete(p);
    lbx_location.itemindex:=p-1;
    lbx_locationClick(NIL);
    end;
  end;
(*@\\\0000000705*)
(*@/// procedure Tfrm_locations.btn_plusClick(Sender: TObject); *)
procedure Tfrm_locations.btn_plusClick(Sender: TObject);
var
  p: integer;
begin
  p:=lbx_location.itemindex;
  if (p>0) then begin
    locations.move(p,p-1);
    lbx_location.items.move(p,p-1);
    lbx_location.itemindex:=p-1;
    lbx_locationClick(NIL);
    end;
  end;
(*@\\\000000091F*)
(*@/// procedure Tfrm_locations.btn_minusClick(Sender: TObject); *)
procedure Tfrm_locations.btn_minusClick(Sender: TObject);
var
  p: integer;
begin
  p:=lbx_location.itemindex;
  if (p>0) and (p<lbx_location.items.count-1) then begin
    locations.move(p,p+1);
    lbx_location.items.move(p,p+1);
    lbx_location.itemindex:=p+1;
    lbx_locationClick(NIL);
    end;
  end;
(*@\\\0000000501*)
(*@/// procedure Tfrm_locations.btn_newClick(Sender: TObject); *)
procedure Tfrm_locations.btn_newClick(Sender: TObject);
var
  p: integer;
  h: TLocation;
begin
  h:=TLocation.create;
  h.name:=LoadStr(SNewLocation);
  p:=locations.add(h);
  lbx_location.items.add(h.name);
  lbx_location.itemindex:=p;
  lbx_locationClick(NIL);
  end;
(*@\\\0000000401*)

(*@/// procedure Tfrm_locations.btn_okClick(Sender: TObject); *)
procedure Tfrm_locations.btn_okClick(Sender: TObject);
begin
  save_locations(moontool_inifile,locations,lbx_location.itemindex);
  end;
(*@\\\0000000322*)

(*@/// procedure Tfrm_locations.FormShow(Sender: TObject); *)
procedure Tfrm_locations.FormShow(Sender: TObject);
var
  current, i: integer;
begin
  if locations<>NIL then begin
    while locations.count>0 do begin
      TObject(locations[0]).free;
      locations.delete(0);
      end;
    end;
  load_locations(moontool_inifile,locations,current);
  lbx_location.items.clear;
  for i:=0 to locations.count-1 do
    lbx_location.items.add(TLocation(locations[i]).name);
  lbx_location.itemindex:=current;
  lbx_locationClick(NIL);
  end;
(*@\\\0000000B12*)
(*@/// procedure Tfrm_locations.FormCreate(Sender: TObject); *)
procedure Tfrm_locations.FormCreate(Sender: TObject);
begin
  self.caption:=LoadStr(SEditLocation);
  lbl_latitude   .caption := LoadStr(SLatitude);
  lbl_longitude  .caption := LoadStr(SLongitude);
  lbl_altitude   .caption := LoadStr(SAltitude);
  edt_latitude   .hint    := LoadStr(SLatitudeHint);
  edt_longitude  .hint    := LoadStr(SLongitudeHint);
  edt_altitude   .hint    := LoadStr(SAltitudeHint);
  (*$ifdef delphi_ge_4 *)
  btn_ok.caption:=SOKButton;
  btn_cancel.caption:=SCancelButton;
  (*$else *)
  btn_ok.caption:=LoadStr(SOKButton);
  btn_cancel.caption:=LoadStr(SCancelButton);
  (*$endif *)
  btn_plus.hint:=LoadStr(SMoveUp);
  btn_minus.hint:=LoadStr(SMoveDown);
  btn_del.hint:=LoadStr(SDelete);
  btn_new.hint:=LoadStr(SNewLocation);
  helpcontext:=hc_locations;
  end;
(*@\\\0000000701*)

(*@/// procedure Tfrm_locations.btn_importClick(Sender: TObject); *)
procedure Tfrm_locations.btn_importClick(Sender: TObject);
begin
  if dlg.execute then
    case dlg.filterindex of
      1:  begin
        (* Syntax of STSplus city file: "Name", longitude (degree, + = east), latitude (degree, + = north), altitude (m) *)
        end;
    end;
end;
(*@\\\*)
(*@\\\0000001201*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\000E000401000431000431000431*)
