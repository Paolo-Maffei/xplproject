unit u_xpl_processor;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses Classes
     , SysUtils
     , u_xpl_address
     , u_xpl_custom_message
     ;

type // TxPLProcessor =========================================================
     TxPLProcessor = class(TObject)
     private
     public
        function Transform(const aAddress : TxPLAddress; const aString : string) : string;
     end;

const K_PROCESSOR_KEYWORDS : Array[0..14] of String = ( 'TIMESTAMP','DATE_YMD','DATE_UK',
                                              'DATE_US','DATE','DAY', 'MONTH',
                                              'YEAR','TIME','HOUR','MINUTE','SECOND',
                                              'DAWN','DUSK','NOON');

implementation // =============================================================
uses StrUtils
     , DateUtils
     ;

const K_FORMATS  : Array[0..14] of String = ( 'yyyymmddhhnnss','yyyy/mm/dd', 'dd/mm/yyyy',
                                              'mm/dd/yyyy','dd/mm/yyyy','dd', 'm',
                                              'yyyy', 'hh:nn:ss','hh','nn','ss','yyyymmddhhnnss',
                                              'yyyymmddhhnnss','yyyymmddhhnnss');

// TxPLProcessor ==============================================================
function TxPLProcessor.Transform(const aAddress : TxPLAddress; const aString: string): string;
var b,e : integer;
    constant, rep  : string;

begin
   result := aString;
   if AnsiPos('{',result) = 0 then exit;                                       // Nothing to search replace;
      result := StringReplace(result, '{VDI}'     , aAddress.RawxPL,[rfReplaceAll,rfIgnoreCase]);
      result := StringReplace(result, '{INSTANCE}', aAddress.Instance,[rfReplaceAll,rfIgnoreCase]);
      result := StringReplace(result, '{DEVICE}'  , aAddress.Device,[rfReplaceAll,rfIgnoreCase]);
      result := StringReplace(result, '{SCHEMA}'  , aAddress.RawxPL,[rfReplaceAll,rfIgnoreCase]);

   b := AnsiPos('{SYS::',Uppercase(result));
   while b<>0 do begin
      inc(b,6);
      e := PosEx('}',result, b);
      constant := Copy(result,b, e-b);
      rep := K_FORMATS[AnsiIndexStr(AnsiUpperCase(constant),K_PROCESSOR_KEYWORDS)];
      result := StringReplace( result, '{SYS::' + constant+'}', FormatDateTime(rep,now),[rfReplaceAll,rfIgnoreCase]);
      b := PosEx('{SYS::',Uppercase(result),b);
   end;
end;

end.

