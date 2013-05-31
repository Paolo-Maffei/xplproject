{$DEFINE DEBUG}

{$IFDEF UNIX}
   {$DEFINE UseCThreads}
{$ENDIF}

{$IFDEF DEBUG}
   {$ASSERTIONS ON}
   {$OPTIMIZATION OFF}
   {$STACKFRAMES ON}
   {$D+}                                // Debug informations
{$ELSE}
   {$ASSERTIONS OFF}
   {$OPTIMIZATION ON}
   {$STACKFRAMES OFF}
   {$D-}
{$ENDIF}

{$ifdef fpc}
   {$mode objfpc}{$H+}
   {$COPERATORS ON}
{$endif}
