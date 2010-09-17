unit consolechannel;

{ Copyright (C) 2006 Luiz Américo Pereira Câmara

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  {$ifndef fpc}fpccompat,{$endif} Classes, SysUtils, multilog;

type

  { Tconsolechannel }

  Tconsolechannel = class (TLogChannel)
  private
    FRelativeIdent: Integer;
    FBaseIdent: Integer;
    FShowHeader: Boolean;
    FShowTime: Boolean;
    FShowPrefix: Boolean;
    FShowStrings: Boolean;
    procedure SetShowTime(const AValue: Boolean);
    procedure UpdateIdentation;
    procedure WriteStrings(AStream: TStream);
    procedure WriteComponent(AStream: TStream);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Deliver(const AMsg: TLogMessage);override;
    procedure Init; override;
    property ShowHeader: Boolean read FShowHeader write FShowHeader;
    property ShowPrefix: Boolean read FShowPrefix write FShowPrefix;
    property ShowTime: Boolean read FShowTime write SetShowTime;
  end;

implementation

const
  LogPrefixes: array [ltInfo..ltCounter] of String = (
    'INFO',
    'ERROR',
    'WARNING',
    'VALUE',
    '>>ENTER METHOD',
    '<<EXIT METHOD',
    'CONDITIONAL',
    'CHECKPOINT',
    'STRINGS',
    'CALL STACK',
    'OBJECT',
    'EXCEPTION',
    'BITMAP',
    'HEAP INFO',
    'MEMORY',
    '','','','','',
    'WATCH',
    'COUNTER');

{ Tconsolechannel }

procedure Tconsolechannel.UpdateIdentation;
var
  S:String;
begin
  S:='';
  if FShowTime then
    S:=FormatDateTime('dd/mm hh:nn',Time);
  FBaseIdent:=Length(S)+3;
end;

procedure Tconsolechannel.SetShowTime(const AValue: Boolean);
begin
  FShowTime:=AValue;
  UpdateIdentation;
end;

procedure Tconsolechannel.WriteStrings(AStream: TStream);
var
  i: Integer;
begin
  if AStream.Size = 0 then Exit;
  with TStringList.Create do
  try
    AStream.Position:=0;
    LoadFromStream(AStream);
    for i:= 0 to Count - 1 do
      WriteLn(Space(FRelativeIdent+FBaseIdent)+Strings[i]);
  finally
    Destroy;
  end;
end;

procedure Tconsolechannel.WriteComponent(AStream: TStream);
var
  TextStream: TStringStream;
  S:String;
begin
  TextStream:=TStringStream.Create(S);
  AStream.Seek(0,soFromBeginning);
  ObjectBinaryToText(AStream,TextStream);
  //todo: better handling of format
  Write(TextStream.DataString);
  TextStream.Destroy;
end;

constructor Tconsolechannel.Create;
begin
  FShowPrefix := True;
  FShowTime := True;
  FShowStrings := True;
  Active := True;
end;

destructor Tconsolechannel.Destroy;
begin
  //remove it?
end;

procedure Tconsolechannel.Clear;
begin

end;

procedure Tconsolechannel.Deliver(const AMsg: TLogMessage);
begin
  //Exit method identation must be set before
  if AMsg.MsgType = ltExitMethod then
    if FRelativeIdent >= 2 then
      Dec(FRelativeIdent,2);
  if FShowTime then
    Write(FormatDateTime('dd/mm hh:nn',AMsg.MsgTime)+' ');
  Write(Space(FRelativeIdent));
  if FShowPrefix then
    Write(LogPrefixes[AMsg.MsgType]+': ');
  Writeln(AMsg.MsgText);
  if FShowStrings and (AMsg.Data <> nil) then
  begin
    case AMsg.MsgType of
      ltStrings,ltCallStack,ltHeapInfo,ltException:WriteStrings(AMsg.Data);
      ltObject:WriteComponent(AMsg.Data);
    end;
  end;
  //Update enter method identation
  if AMsg.MsgType = ltEnterMethod then
    Inc(FRelativeIdent,2);
end;

procedure Tconsolechannel.Init;
begin
  if FShowHeader then
    WriteLn('=== Log Session Started at ',DateTimeToStr(Now),' by ',ApplicationName,' ===');
  UpdateIdentation;
end;

end.

