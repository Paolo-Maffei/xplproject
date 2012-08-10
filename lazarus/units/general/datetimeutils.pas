{*
 * DateTimeUtils.pas
 *
 * Auxilary functions for date/time manipulation.
 *
 * Copyright (c) 2006-2007 by the MODELbuilder developers team
 * Originally written by Darius Blaszijk, <dhkblaszyk@zeelandnet.nl>
 * Creation date: 31-Oct-2006
 * Website: www.modelbuilder.org
 *
 * This file is part of the MODELbuilder project and licensed
 * under the LGPL, see COPYING.LGPL included in this distribution,
 * for details about the copyright.
 *
 *}

unit DateTimeUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Miscelaneous;

function DateTimeToISO8601(DateTime: TDateTime): string;
function ISO8601ToDateTime(DateTime: string): TDateTime;
function TimeToISO8601(DateTime: TDateTime): string;
function ISO8601ToTime(DateTime: string): TDateTime;
function FmtStringToDateTime(FormatStr: string; DateTimeStr: string;
  var DateTime: TDateTime; BaseYear: integer = 0): boolean;

implementation

function DateTimeToISO8601(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', DateTime) + 'T' +
            FormatDateTime('hh:mm:ss', DateTime)
end;

function ISO8601ToDateTime(DateTime: string): TDateTime;
var
  y, m, d, h, n, s: word;
begin
  y := StrToInt(Copy(DateTime, 1, 4));
  m := StrToInt(Copy(DateTime, 6, 2));
  d := StrToInt(Copy(DateTime, 9, 2));
  h := StrToInt(Copy(DateTime, 12, 2));
  n := StrToInt(Copy(DateTime, 15, 2));
  s := StrToInt(Copy(DateTime, 18, 2));

  Result := EncodeDate(y,m,d) + EncodeTime(h,n,s,0);
end;

function TimeToISO8601(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('hh:mm:ss', DateTime)
end;

function ISO8601ToTime(DateTime: string): TDateTime;
var
  h, n, s: word;
begin
  h := StrToInt(Copy(DateTime, 1, 2));
  n := StrToInt(Copy(DateTime, 4, 2));
  s := StrToInt(Copy(DateTime, 7, 2));

  Result := EncodeTime(h,n,s,0);
end;

//convert a string given a format string to datetime

{  date time formatting characters:
      d      : day of month
      m      : month
      y      : year
      h      : hour
      n      : minute
      s      : second
}
function FmtStringToDateTime(FormatStr: string; DateTimeStr: string;
  var DateTime: TDateTime; BaseYear: integer = 0): boolean;
var
  d, m, y, h, n, s: string;
  len:  integer;
  i:    integer;
  Date: TDateTime;
  Time: TDateTime;
begin
  d := '';
  m := '';
  y := '';
  h := '';
  n := '';
  s := '';

  len := Min(length(FormatStr), length(DateTimeStr));

  for i := 1 to len do
    case FormatStr[i] of
      'd': d := d + DateTimeStr[i];
      'm': m := m + DateTimeStr[i];
      'y': y := y + DateTimeStr[i];
      'h': h := h + DateTimeStr[i];
      'n': n := n + DateTimeStr[i];
      's': s := s + DateTimeStr[i];
    end;

  if d = '' then d := '0';
  if m = '' then m := '0';
  if y = '' then y := '0';
  if h = '' then h := '0';
  if n = '' then n := '0';
  if s = '' then s := '0';

  if IsNumeric(d) and IsNumeric(m) and IsNumeric(y) and IsNumeric(h) and
    IsNumeric(n) and IsNumeric(s) then
  begin
    Result := TryEncodeDate(StrToInt(y) + BaseYear, StrToInt(m), StrToInt(d), Date);
    if not Result then
      exit;
    Result   := TryEncodeTime(StrToInt(h), StrToInt(n), StrToInt(s), 0, Time);
    DateTime := Date + Time;
  end
  else
    Result := False;
end;

end.

