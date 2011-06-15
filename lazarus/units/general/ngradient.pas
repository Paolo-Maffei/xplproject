unit ngradient;

{$mode objfpc}{$H+}

interface

uses
  Classes, Graphics;

type
  TnGradientInfo = record
    StartColor,StopColor:TColor;
    Direction: TGradientDirection;
    endPercent:single; // This is not the percent of the width, this is the percent of the end of the rect- which means, if this value is 1 - the rect could be from 0.99 to 1 and needs not be from 0 to 1
  end;

function DoubleGradientFill(ARect: TRect; AStart1,AStop1,AStart2,AStop2: TColor;
  ADirection1,ADirection2,APos: TGradientDirection; AValue: Single): TBitmap;
function nGradientFill(ARect: TRect;APos: TGradientDirection; AGradient: array of TnGradientInfo): TBitmap;

implementation

function nGradientFill(ARect: TRect;APos: TGradientDirection; AGradient: array of TnGradientInfo): TBitmap;
var
  i:integer;
  AnRect,OldRect: TRect;
begin
  Result := TBitmap.Create;
  Result.Width:=ARect.Right-ARect.Left;
  Result.Height:=ARect.Bottom-ARect.Top;
  OldRect := ARect;
  if APos = gdVertical then OldRect.Bottom := ARect.Top
     else OldRect.Right := ARect.Left ;   // upside down...  in case of i = 0...

  for i := 0 to high(AGradient) do
      begin
      AnRect:=OldRect;
      if APos = gdVertical then
         begin
         AnRect.Bottom:=Round((ARect.Bottom-ARect.Top) * AGradient[i].endPercent + ARect.Top);
         AnRect.Top:=OldRect.Bottom;
         end
        else
         begin
         AnRect.Right:=Round((ARect.Right-ARect.Left) * AGradient[i].endPercent + ARect.Left);
         AnRect.Left:=OldRect.Right;
         end;

      Result.Canvas.GradientFill(AnRect,AGradient[i].StartColor,AGradient[i].StopColor,AGradient[i].Direction);
      OldRect := AnRect;
      end;
end;


function DoubleGradientFill(ARect: TRect; AStart1,AStop1,AStart2,AStop2: TColor;
  ADirection1,ADirection2,APos: TGradientDirection; AValue: Single): TBitmap;
var
  ABitmap: TBitmap; ARect1,ARect2: TRect;
begin
  ABitmap := TBitmap.Create;
  ABitmap.Width:=ARect.Right;
  ABitmap.Height:=ARect.Bottom;
  if AValue <> 0 then begin
    ARect1:=ARect;
  end;
  if AValue <> 1 then begin
    ARect2:=ARect;
  end;
  if APos = gdVertical then begin
    ARect1.Bottom:=Round(ARect1.Bottom * AValue);
    ARect2.Top:=ARect1.Bottom;
  end
  else if APos = gdHorizontal then begin
    ARect1.Right:=Round(ARect1.Right * AValue);
    ARect2.Left:=ARect1.Right;
  end;
  if AValue <> 0 then begin
    ABitmap.Canvas.GradientFill(ARect1,AStart1,AStop1,ADirection1);
  end;
  if AValue <> 1 then begin
    ABitmap.Canvas.GradientFill(ARect2,AStart2,AStop2,ADirection2);
  end;
  Result:=ABitmap;
end;

end.
