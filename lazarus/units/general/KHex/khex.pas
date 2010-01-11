{ Ce fichier a été automatiquement créé par Lazarus. Ne pas l'éditer !
  Cette source est seulement employée pour compiler et installer le paquet.
 }

unit khex; 

interface

uses
KHexEditor, khexeditordesign, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('khexeditordesign', @khexeditordesign.Register); 
end; 

initialization
  RegisterPackage('khex', @Register); 
end.
