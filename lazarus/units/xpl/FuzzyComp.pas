//*****************************************************************
//   Unit : 3 Fuzzy Components
//        TCustomFuzzy, TFuzzyfication and TFuzzySolution
//   by Alexandre Beauvois 14/06/1998
//   Modified by Clinique for xPL Project in Vadodara 28/08/2009
//*****************************************************************

unit FuzzyComp;

interface
uses
    //Windows,
    Messages, SysUtils, Classes,
    Forms, Dialogs, Graphics, Controls,
    StdCtrls, ComCtrls, ExtCtrls;
    //, DsgnIntf;

const
    MaxMembers=15;
    AxeMargeX=0;
    AxeMargeY=20;
    AxeInfinity=999999999;
    MaxPoints=100;

resourcestring
              K_MBR_TYPE_LEFT  = 'Left Zone';
              K_MBR_TYPE_RIGHT = 'Right Zone';
              K_MBR_TYPE_TRIGL = 'Triangle';

type

    TAxe=class
    private
    public
       FMin,FMax:single;
       FUnite:integer;
       FWidth:Integer;
       FHomo:single;
       constructor create;
       function getmin:single;
       function getmax:single;
       procedure SetMinMax(A,B:single);
       procedure SetWidth(w:integer);
       function scale(P:single):integer;
    end;

    TMemberType = (tmLInfinity,tmTriangle,tmRInfinity);

    { TMember }

    TMember=class (TCollectionItem)
    private
       FA,FB:single;
       FMiddle:single;
       FColor:TColor;
       FName:string;
       FType:TMemberType;
       function GetMemberTypeAsString: string;
       procedure SetColor(C:TColor);
       procedure SetMemberTypeAsString(const AValue: string);
       procedure SetName(N:string);
       procedure SetType(T:TMemberType);
       procedure SetMiddle(M:single);
       procedure SetStartMember(A:single);
    public
       constructor Create(aCollection: TCollection);override;
       function OwnerShip(P:single):single;
       procedure Assign(Source: TPersistent);override;
    published
       property Color:TColor read FColor write SetColor;
       property Name:string read FName write SetName;
       property MemberType:TMemberType read FType write SetType;
       property MemberTypeAsString : string read GetMemberTypeAsString write SetMemberTypeAsString;
       property StartMember : single read FA write SetStartMember;
       property Middle : single read FMiddle write SetMiddle nodefault;
    end;
{$M+}
    TCustomFuzzy = class;

    TMembers=Class (TCollection)
      FFuzzy:TCustomFuzzy;
       function GetItem(Index: Integer): TMember;
       procedure SetItem(Index: Integer; Value: TMember);
     protected
       function GetOwner: TPersistent;override;
       procedure Update(Item: TCollectionItem);override;
     public
       constructor Create(Fuzzy: TCustomFuzzy);
       function GetMemberIndex(N:string):integer;
       function Add: TMember;
       property Items[Index: Integer]: TMember read GetItem write SetItem; default;
    end;

    TFuzzyType = (ftFuzzyfication,ftFuzzySolution);
    TFuzzyResults=Array[0..MaxMembers-1] of single;

    { TCustomFuzzy }

    TCustomFuzzy=class(TCustomControl)
    private
       FOnChange: TNotifyEvent;
       FMembers:TMembers;
       FFuzzyName:string;
       procedure SetMembers(Value: TMembers);
       procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
       procedure SetMaxi(X:single);
       function GetMaxi:single;
       procedure SetMini(X:single);
       function GetMini:single;
       procedure SetFuzzyName(FN:string);
    public
       Axe:TAxe;
       constructor create(Aowner:TComponent);override;
       function AddMember(N:string;M,A:single;T:TMemberType) : TMember;
       function AddMember(N:string;M,A:single;T:string) : TMember;
       function scaleY(P:single):integer;
       procedure Assign(aCustomFuzz : TCustomFuzzy);
    {   function singleOutput:single;}
       destructor destroy; override;
    protected
       procedure paint;override;
       procedure UpdateMember(Index: Integer);
       procedure Change; dynamic;
       property Maxi:single read GetMaxi write SetMaxi;
       property Mini:single read GetMini write SetMini;
       property Members: TMembers read FMembers write SetMembers;
    published
       property Align;
       property Color;
       property OnChange: TNotifyEvent read FOnChange write FOnChange;
       property FuzzyName: string read FFuzzyName write SetFuzzyName;
    end;

    { TFuzzyfication }

    TFuzzyfication=class(TCustomFuzzy)
    private
       FRealInput:single;
       FOutputs:TFuzzyResults;
       FFuzzyType:TFuzzyType;
       procedure SetRealInput(X:single);
       procedure SetOutPuts(Index:integer;y:single);
       function GetOutputs(Index:integer):single;
    protected
       procedure paint;override;
       procedure WMMbuttonDown(var Msg: TMessage); message WM_LbuttonDown;
    public
       property FuzzyType : TFuzzyType read FFuzzyType write FFuzzyType;
       constructor create(Aowner:Tcomponent);override;
       procedure Assign(aCustomFuzz : TCustomFuzzy);
       property Outputs[aIndex:integer]:single read GetOutputs write SetOutputs;
    published
       property Align;
       property color;
       property Maxi;
       property Mini;
       property Members;
       property RealInput:single read FRealInput write SetRealInput;

       property OnChange;
    end;

    TFuzzySolution=class(TCustomFuzzy)
    private
       FRealOutput:single;
       FCompatibility:single;
       FFuzzyType:TFuzzyType;
       FXValues,FYValues:array[0..MaxPoints-1] of single;
       FNbPoints:Integer;
       FDeltaX:single;
       procedure SetDeltaX(d:single);
       function GetRealOutput:single;
    protected
       procedure paint;override;
    public
       property FuzzyType : TFuzzyType read FFuzzyType write FFuzzyType;
       procedure FuzzyAgregate(MemberIndex:Integer;AlphaCut:single);
       procedure ClearSolution;
       constructor create(Aowner:Tcomponent);override;
    published
       property Align;
       property color;
       property Maxi;
       property Mini;
       property Members;
       property RealOutput:single read GetRealOutput write FRealOutput;
       property OnChange;
       property Compatibility:single read FCompatibility write FCompatibility;
       property DeltaX:single read FDeltaX write SetDeltaX;
    end;

procedure Register;

implementation
uses Math;

procedure Register;
begin
    RegisterComponents('Fuzzy', [TCustomFuzzy]);
    RegisterComponents('Fuzzy', [TFuzzyfication]);
    RegisterComponents('Fuzzy', [TFuzzySolution]);
end;

{****************** TAxe ********************}
constructor TAxe.create;
 begin
      inherited Create;
      FMin:=0;
      FMax:=0;
      FHomo:=1;
      Funite:=10;
 end;
 function TAxe.getMin:single;
 begin
    GetMin:=FMin;
 end;
 function TAxe.getMax:single;
 begin
    GetMax:=FMax;
 end;
 procedure Taxe.SetMinMax(A,B:single);
 begin
      If A<=B then begin Fmin:=A;Fmax:=B; end else
      begin
         Fmin:=B;Fmax:=A;
      end;
      if (Fmax-Fmin)<>0 then
      FHomo:=Fwidth/(Fmax-Fmin)
      else
      FHomo:=0;
 end;
 procedure TAxe.SetWidth(W:integer);
 begin
      FWidth:=W;
 end;
 function TAxe.scale(P:single):integer;
 var RUnit:single;
 begin

      RUnit:=(FMax-FMin);
      if RUnit<>0 then
      scale:=round((P-FMin)/RUnit*FWidth)
      else Scale:=0;
 end;

 {****************** TMember ********************}
constructor TMember.Create(aCollection: TCollection);
begin
      FColor:=clwhite;
      FName:='New';
      FType:=tmTriangle;
      FA:=0;
      FB:=0;
      FMiddle:=0;
      inherited Create(aCollection);
end;
procedure TMember.SetName(N:string);
begin
    FName:=N;
    changed(false);
end;
procedure TMember.SetColor(C:TColor);
begin
    FColor:=C;
    changed(false);
end;

function TMember.GetMemberTypeAsString: string;
begin
     case MemberType of
          tmLInfinity : result := K_MBR_TYPE_LEFT;
          tmTriangle  : result := K_MBR_TYPE_TRIGL;
          tmRInfinity : result := K_MBR_TYPE_RIGHT;
     end;
end;

procedure TMember.SetMemberTypeAsString(const AValue: string);
begin
     if aValue = K_MBR_TYPE_LEFT  then MemberType := tmLInfinity;
     if aValue = K_MBR_TYPE_TRIGL then MemberType := tmTriangle;
     if aValue = K_MBR_TYPE_RIGHT  then MemberType := tmRInfinity;
end;

procedure TMember.SetType(T:TMemberType);
begin
    FType:=T;
    changed(true);
end;
procedure TMember.SetMiddle(M:single);
begin
    //if M<=FA then FA:=M;
    FMiddle:=M;
    FB:=2*FMiddle-FA;
    changed(true);
end;
procedure TMember.SetStartMember(A:single);
begin
   //if A>=FMiddle then FMiddle:=A;
   FA:=A;
   FB:=2*FMiddle-FA;
   changed(true);
end;
procedure TMember.Assign(Source: TPersistent);
begin
  if Source is TMember then
  begin
    SetMiddle(TMember(Source).FMiddle);
    SetStartMember(TMember(Source).FA);
    FColor := TMember(Source).FColor;
    FName := TMember(Source).FName;
    FType := TMember(Source).FType;
    Exit;
  end;
  inherited Assign(Source);
end;

Function TMember.OwnerShip(P:single):single;
begin
     {si la forme de la fonction d'appartenance est Triangulaire !}
     if ((FMiddle-FA)<>0) and (P>FA) and (P<FB) then
     begin
          if P<FMiddle then OwnerShip:=(P-FA)/(FMiddle-FA);
          if P>FMiddle then OwnerShip:=(FB-P)/(FB-FMiddle);
     end;
     if (P<=FA) OR (P>=FB) then OwnerShip:=0;{si P est hors du segment...}
     if (FType=tmLInfinity) AND (P<=FMiddle) then OwnerShip:=1;
     if (FType=tmRInfinity) AND (P>=FMiddle) then OwnerShip:=1;
     if P=FMiddle then OwnerShip:=1;
 end;
  {****************** TMembers ********************}
 constructor TMembers.Create(Fuzzy: TCustomFuzzy);
begin
  inherited Create(TMember);
  FFuzzy:=Fuzzy;
end;

function TMembers.Add: TMember;
begin
  Result := TMember(inherited Add);
//    Result := TMember.Create(self);
//    Result:=FItemClass.Create(Self);
end;

function TMembers.GetItem(Index: Integer): TMember;
begin
  Result := TMember(inherited GetItem(Index));
end;

procedure TMembers.SetItem(Index: Integer; Value: TMember);
begin
  inherited SetItem(Index, Value);
end;

function TMembers.GetOwner: TPersistent;
begin
  Result := FFuzzy;
end;

procedure TMembers.Update(Item: TCollectionItem);
//var AMember:TMember;
//  var a : single;
//      b : single;

begin
//   if Item <> nil then
//      FFuzzy.UpdateMember(Item.Index);
        if Item = nil then exit; // GLH
try
    if TMember(Item).StartMember<FFuzzy.Mini then FFuzzy.Mini:=TMember(Item).StartMember;
    if TMember(Item).Middle+abs(TMember(Item).StartMember)>FFuzzy.Maxi then FFuzzy.Maxi:=TMember(Item).Middle+abs(TMember(Item).StartMember);
except
end;
    FFuzzy.invalidate;
  {else
    FStatusBar.UpdateMembers;       }
end;
function TMembers.GetMemberIndex(N:string):integer;
var i:integer;
begin
   for i:=0 to count-1 do
    if TMember(Items[i]).Name=N then
    begin
                        GetMemberIndex:=i;
                        exit;
    end
    else GetMemberIndex:=-1;
end;

 {*************************** TCustomFuzzy **************************}

 constructor TCustomFuzzy.create(Aowner:Tcomponent);
 begin
      Inherited Create(Aowner);
      Parent:=TWinControl(AOwner);
      Axe:=TAxe.Create;
      FMembers:=TMembers.Create(Self);
      SetBounds(0,0,170,100);
      addMember('Low',0,-20,tmLInfinity);
      addMember('Nul',50,0,tmTriangle);
      addMember('Important',80,50,tmRInfinity);
 end;
 procedure TCustomFuzzy.SetFuzzyName(FN:string);
 begin
      FFuzzyName:=FN;
      invalidate;
 end;
procedure TCustomFuzzy.SetMembers(Value: TMembers);
begin
  FMembers.Assign(Value);
end;
procedure TCustomfuzzy.Change;
begin
 if Assigned(FOnChange) then FOnChange(Self);
end;
procedure TCustomFuzzy.UpdateMember(Index: Integer);
begin
     Invalidate;
end;
procedure TCustomFuzzy.SetMaxi(X:single);
begin
    Axe.setMinMax(Axe.GetMin,X);
    Invalidate;
end;
function TCustomFuzzy.GetMaxi:single;
begin
      GetMaxi:=Axe.getmax;
end;
procedure TCustomFuzzy.SetMini(X:single);
begin
    Axe.setMinMax(X,Axe.getmax);
    invalidate;
end;
function TCustomFuzzy.GetMini:single;
begin
     GetMini:=Axe.getmin;
end;
function TCustomFuzzy.scaleY(P:single):integer;
// var RUnit:single;
 begin
      if Height<>0 then
           ScaleY:=round(Height-AxeMargeY-P*(Height-AxeMargeY))
      else ScaleY:=0;
 end;

procedure TCustomFuzzy.Assign(aCustomFuzz: TCustomFuzzy);
begin
   OnChange := aCustomFuzz.OnChange;
   FuzzyName:= aCustomFuzz.FuzzyName;
   Members.Clear;
   Members.Assign(aCustomFuzz.Members);
end;

 function TCustomFuzzy.AddMember(N:string;M,A:single;T:TMemberType) : TMember;
 var //NewMember:TMember;
     FBMax:single;
     i:integer;
 begin
     //NewMember:=FMembers.add;
     Result :=FMembers.add;
     if Result <>Nil then
     with Result do
     begin
         SetType(T);
         SetMiddle(M);
         SetStartMember(A);
         if FA<Axe.GetMin then Axe.setMinMax(FA,Axe.GetMax);
         if FB>Axe.GetMax then Axe.setMinMax(Axe.GetMin,FB);
         SetName(N);
         SetColor(FMembers.Count*66);
     end;
     FBmax:=0;
     for i:=0 to FMembers.Count-1 do
       if TMember(FMembers.Items[i]).FB>FBMax then FBMax:=TMember(FMembers.Items[i]).FB;
     Maxi:=FBMax;  
 end;

 function TCustomFuzzy.AddMember(N: string; M, A: single; T: string): TMember;
 var s : TMemberType;
 begin
      if T = K_MBR_TYPE_LEFT   then s := tmLInfinity;
      if T = K_MBR_TYPE_TRIGL  then s := tmTriangle;
      if T = K_MBR_TYPE_RIGHT  then s := tmRInfinity;
      AddMember(N,M,A,S);
 end;

 procedure TCustomFuzzy.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
 begin
      inherited SetBounds(ALeft, ATop, AWidth, AHeight);
      Axe.SetWidth(AWidth-2*AxeMargeX);
 end;
 procedure TCustomFuzzy.paint;
 var i : integer;
//     OutX:single;
 begin
      inherited Paint;
      with Axe do
      begin
           canvas.Pen.Color:=clRed;
           canvas.MoveTo(AxeMargeX,Height-AxeMArgeY);
           canvas.LineTo(Width,Height-AxeMargeY);
           i:=0;
           repeat
              inc(i);
              canvas.MoveTo(Scale(Mini+FUnite*i),Height-AxeMArgeY-2);
              canvas.LineTo(Scale(Mini+FUnite*i),Height-AxeMargeY+2);
           until Scale(Mini+FUnite*i)>Width;
      end;
      For i:=0 to FMembers.Count-1 do
      with TMember(FMembers.Items[i]) do
      begin
           canvas.Pen.color:=Color;
           canvas.MoveTo(Axe.Scale(Middle),0);
           if FType=tmLInfinity then
           canvas.LineTo(Axe.Scale(Axe.GetMin),0) else
           canvas.LineTo(Axe.Scale(FA),Height-AxeMargeY);
           canvas.MoveTo(Axe.Scale(Middle),0);
           if FType=tmRInfinity then
           canvas.LineTo(Axe.Scale(Axe.GetMax),0) else
           canvas.LineTo(Axe.Scale(FB),Height-AxeMargeY);
           canvas.font.color:=color;
           canvas.Brush.color:=self.color;
           canvas.TextOut(Axe.Scale(Middle),AxeMargeY+3+i*8,FName);
{         canvas.MoveTo(0,round((1-OwnerShip(FsingleInput))*(Height-AxeMargeY)));
         canvas.LineTo(width,round((1-OwnerShip(FsingleInput))*(Height-AxeMargeY)));}
      canvas.Brush.color:=self.color;
      canvas.font.color:=clYellow;
      canvas.TextOut(AxeMargeX+2,3,FFuzzyName);
      end;
 end;
 destructor TCustomFuzzy.destroy;
// var i: integer;
 begin
      FMembers.Destroy;
      Axe.Free;
      inherited Destroy;
 end;
{**************************** TFuzzyfication *********************************}
procedure TFuzzyfication.SetOutPuts(Index:integer;y:single);
begin
                        {   For i:=0 to FMembers.Count-1 do}
      FOutPuts[index]:=y;{TMember(FMembers.Items[index]).OwnerShip(FsingleInput);}
end;

function TFuzzyfication.GetOutputs(Index:integer):single;
 begin
     GetOutputs:=FOutputs[index];
 end;


procedure TFuzzyfication.SetRealInput(X:single);
var i:Integer;
begin
     FRealInput:=X;
     Axe.setMinMax(Axe.GetMin,Axe.GetMax);
     For i:=0 to FMembers.Count-1 do
         FOutputs[i]:=TMember(FMembers.Items[i]).OwnerShip(FRealInput);
     change;
     Invalidate;
end;


constructor TFuzzyfication.create(Aowner:Tcomponent);
begin
    inherited create(AOwner);
    FuzzyType:=ftFuzzyfication;
    FRealInput:=0;
 end;

procedure TFuzzyfication.Assign(aCustomFuzz: TCustomFuzzy);
begin
  inherited Assign(aCustomFuzz);
  Mini := aCustomFuzz.Mini;
  Maxi := aCustomFuzz.Maxi;
end;

 procedure TFuzzyfication.WMMbuttonDown(var Msg: TMessage);
 var x:integer;
 begin
      x:=msg.lparamlo;
      if Axe.FHomo<>0 then
      RealInput:=(X-axeMargeX)/Axe.Fhomo+Axe.FMin
      else
      RealInput:=0;
 end;

procedure TFuzzyfication.paint;
 var i : integer;
 begin
      inherited Paint;
      if (FRealInput>=Axe.FMin) and (FRealInput<=Axe.Fmax) then
      begin
         canvas.Pen.Color:=clYellow;
         canvas.MoveTo(Axe.scale(FRealInput),0);
         canvas.LineTo(Axe.scale(FRealInput),Height);
      end;
      canvas.Font.color:=clBlack;
      For i:=0 to FMembers.Count-1 do
      with TMember(FMembers.Items[i]) do
      canvas.TextOut(AxeMargeX+2+i*50,Height-AxeMargeY+3,'Y('+IntToStr(i)+')='+ FloatToStrF(OwnerShip(FRealInput),ffFixed,5,2));
 end;

{************************* TFuzzySolution ******************************}
constructor TFuzzySolution.create(Aowner:Tcomponent);
begin
    inherited create(AOwner);
    FuzzyType:=ftFuzzySolution;
    FRealOutput:=0;
    FCompatibility:=0;
    System.Fillchar(FXValues,sizeof(FXValues),#0);
    System.Fillchar(FYValues,sizeof(FYValues),#0);
    FNbPoints:=0;
    FDeltaX:=2;
end;
procedure TFuzzySolution.SetDeltaX(d:single);
begin
   FDeltaX:=d;
   invalidate;
   change;
end;
procedure TFuzzySolution.ClearSolution;
begin
   FRealOutput:=0;
   FCompatibility:=0;
   System.Fillchar(FXValues,sizeof(FXValues),#0);
   System.Fillchar(FYValues,sizeof(FYValues),#0);
   FNbPoints:=0;
   invalidate;
   change;
end;
//Agregation
//Controler que le Member FuzzySet est bien égal à un member de TFuzzySolution
procedure TFuzzySolution.FuzzyAgregate(MemberIndex:Integer;AlphaCut:single);
begin
   FNbPoints:=0;
   FXValues[FNbPoints]:=Axe.GetMin;
   repeat
         inc(FNbPoints);
         if FXValues[FNbPoints-1]+FDeltax<Axe.GetMax then
         begin
             FXValues[FNbPoints]:=FXValues[FNbPoints-1]+FDeltax;
             FYValues[FNbPoints]:=Math.MaxValue([FYValues[FNbPoints],Math.MinValue([Members[MemberIndex].OwnerShip(FXValues[FNbPoints]),AlphaCut])]);
         end
         else
         begin
             FXValues[FNbPoints]:=Axe.GetMax;
             FYValues[FNbPoints]:=Math.MaxValue([FYValues[FNbPoints],Math.MinValue([Members[MemberIndex].OwnerShip(FXValues[FNbPoints]),AlphaCut])]);
         end;
   until (FXValues[FNbPoints]=Axe.GetMax) OR (FNbPoints>=MaxPoints);
   invalidate;
   change;
end;

 // Focalisation
function TFuzzySolution.GetRealOutput:single;
 var i:integer;
     sum,S:single;
     //DeltaXValue,Surface
     YValue,MaxiValue:single;
 begin
      sum:=0;
      S:=0;
      MaxiValue:=0;
      For i:=0 to (FNbPoints-1)-1 do
      begin
           YValue:=FYValues[i];
           if YValue>MaxiValue then MaxiValue:=YValue;
           S:=S+FDeltaX*YValue;
           sum:=sum+(FDeltaX*YValue)*FXValues[i+1];
      end;
      if S<>0 then
      GetRealOutput:=Sum/S
      else
      GetRealOutput:=0;
      Compatibility:=MaxiValue;
      Change;
 end;

procedure TFuzzySolution.paint;
 var i : integer;
     x : single;
     x1,y1,x2,y2:integer;
 begin
      inherited Paint;
      For i:=0 to (FNbPoints-1)-1 do
      begin
         canvas.Pen.Color:=clYellow;
         X1:=Axe.scale(FXValues[i]);
         Y1:=scaleY(FYValues[i]);
         canvas.MoveTo(X1,Y1);
         X2:=Axe.scale(FXValues[i+1]);
         Y2:=scaleY(FYValues[i+1]);
         canvas.LineTo(X2,Y2);
      end;
      x:=RealOutput;
      if (x>=Axe.FMin) and (x<=Axe.Fmax) then
      begin
         canvas.Pen.Color:=clYellow;
         canvas.MoveTo(Axe.scale(x),0);
         canvas.LineTo(Axe.scale(x),Height-AxeMargeY);
      end;
 end;
end.
