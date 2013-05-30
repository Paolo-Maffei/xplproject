{$DEFINE DEBUG}

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
{$endif}
