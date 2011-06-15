unit u_xpl_triggers;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , u_xpl_globals
     , u_xpl_collection
     ;

type

{ TxPLtrigger }
    TxPLTriggerType = (trgTimers,trgSingle,trgRecurring,trgGlobalChange,trgCondition,trgMessage);

    TxPLtrigger = class(TxPLGlobalValue)
    private
       fTrigType : TxPLTriggerType;
    public
    published
       property TrigType : TxPLTriggerType read fTrigType write fTrigType;
       property DisplayName;
       property Comment;
    end;

{ TxPLtriggers }
    TxPLTriggers = specialize TxPLCollection<TxPLtrigger>;


(*
TxPLtriggers = class(TCollection)
private
  FOnGlobalChange: TxPLGlobalChangedEvent;
   fOwner: TPersistent;
   FOntriggerChange: TxPLGlobalChangedEvent;
   procedure SetItems(Index: integer; const AValue: TxPLtrigger);


  function GetItems(index: integer): TxPLtrigger;

protected
  function GetOwner: TPersistent; override;
public
   constructor Create(aOwner: TPersistent);

   function Add(const aName : string) : TxPLtrigger;
   function FindItemName(const aName: string): TxPLtrigger;
   function GetItemId(const aName: string): integer;
   property Items[Index: integer]: TxPLtrigger Read GetItems Write SetItems; default;

published
   property OnGlobalChange : TxPLGlobalChangedEvent read FOnGlobalChange write fOnGlobalChange;
end;*)

implementation

{ TxPLtriggers }

 { TxPLtriggers =============================================================}

{ TxPLtrigger }

end.

