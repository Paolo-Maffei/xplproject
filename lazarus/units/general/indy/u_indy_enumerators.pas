unit u_indy_enumerators;

{$mode objfpc}

interface

uses Classes
     , IdSocketHandle
     ;

type { TIdSocketHandleEnumerator }
     TIdSocketHandleEnumerator = class
         private
            fHandles : TIdSocketHandles;
            fCurrent : integer;
            function GetCurrent: TIdSocketHandle;
         public
            constructor Create(const A: TIdSocketHandles);
            property Current: TIdSocketHandle read GetCurrent;
            function MoveNext: Boolean;
     end;

   operator Enumerator(const a : TIdSocketHandles) : TIdSocketHandleEnumerator;

implementation

{ TIdSocketHandleEnumerator }

operator Enumerator(const a : TIdSocketHandles) : TIdSocketHandleEnumerator;
begin
   Result := TIdSocketHandleEnumerator.Create(a);
end;


function TIdSocketHandleEnumerator.GetCurrent: TIdSocketHandle;
begin
   result := fHandles.Items[fCurrent];
end;

constructor TIdSocketHandleEnumerator.Create(const A: TIdSocketHandles);
begin
   fHandles := a;
   fCurrent := -1;
end;

function TIdSocketHandleEnumerator.MoveNext: Boolean;
begin
   inc(fCurrent);
   result := fCurrent<fHandles.Count;
end;


end.

