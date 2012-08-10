unit u_xPL_Filter_Header;
{==============================================================================
  UnitName      = uxPLHeader
  UnitDesc      = xPL Message Header management object and function
  UnitCopyright = GPL by Clinique / xPL Project
 ==============================================================================
 0.96 : Rawdata passed are no longer transformed to lower case, then Header has
        to lower it
 0.99 : Added usage of uRegExTools
 1.00 : Suppressed usage of uRegExTools to correct bug #FS47
 1.1    Switched schema from Body to Header
        optimizations in SetRawxPL to avoid inutile loops
 }

{$ifdef fpc}
   {$mode objfpc}{$H+}{$M+}
{$endif}

interface

uses Classes,
     u_xpl_header,
     u_xpl_address,
     u_xpl_schema,
     u_xpl_common;

type // TxPLFilterHeader ======================================================
     TxPLFilterHeader = class(TxPLHeader)
     protected
       procedure MessageTypeFromStr(const aString : string); override;
       function MessageTypeToStr : string; override;
     public
       procedure   ResetValues; override;
     end;

implementation //==============================================================

// TxPLFilterHeader Object ====================================================
procedure TxPLFilterHeader.ResetValues;
begin
   inherited;
   MessageType := any;
end;

procedure TxPLFilterHeader.MessageTypeFromStr(const aString: string);
begin
   if aString = 'xpl-*' then MessageType := any
                    else inherited;
end;

function TxPLFilterHeader.MessageTypeToStr: string;
begin
   if MessageType = any then result := 'xpl-*'
                        else Result:=inherited;
end;

initialization // =============================================================
   Classes.RegisterClass(TxPLFilterHeader);

end.
