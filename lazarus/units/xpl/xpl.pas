{ Ce fichier a été automatiquement créé par Lazarus. Ne pas l'éditer !
  Cette source est seulement employée pour compiler et installer le paquet.
 }

unit XPL; 

interface

uses
  v_msgbody_stringgrid, v_xplmsg_opendialog, MStringGrid, MCheckListBox, 
  MEdit, v_msgtype_radio, v_class_combo, MComboBox, FuzzyComp, uControls, 
  TreeListView, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('v_msgbody_stringgrid', @v_msgbody_stringgrid.Register); 
  RegisterUnit('v_xplmsg_opendialog', @v_xplmsg_opendialog.Register); 
  RegisterUnit('MStringGrid', @MStringGrid.Register); 
  RegisterUnit('MCheckListBox', @MCheckListBox.Register); 
  RegisterUnit('MEdit', @MEdit.Register); 
  RegisterUnit('v_msgtype_radio', @v_msgtype_radio.Register); 
  RegisterUnit('v_class_combo', @v_class_combo.Register); 
  RegisterUnit('MComboBox', @MComboBox.Register); 
  RegisterUnit('FuzzyComp', @FuzzyComp.Register); 
  RegisterUnit('uControls', @uControls.Register); 
  RegisterUnit('TreeListView', @TreeListView.Register); 
end; 

initialization
  RegisterPackage('XPL', @Register); 
end.
