{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit xpl_win; 

interface

uses
  v_xplmsg_opendialog, v_msgtype_radio, v_class_combo, MStringGrid, MEdit, 
  MCheckListBox, MComboBox, v_msgbody_stringgrid, uControls, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('v_xplmsg_opendialog', @v_xplmsg_opendialog.Register); 
  RegisterUnit('v_msgtype_radio', @v_msgtype_radio.Register); 
  RegisterUnit('v_class_combo', @v_class_combo.Register); 
  RegisterUnit('MStringGrid', @MStringGrid.Register); 
  RegisterUnit('MEdit', @MEdit.Register); 
  RegisterUnit('MCheckListBox', @MCheckListBox.Register); 
  RegisterUnit('MComboBox', @MComboBox.Register); 
  RegisterUnit('v_msgbody_stringgrid', @v_msgbody_stringgrid.Register); 
  RegisterUnit('uControls', @uControls.Register); 
end; 

initialization
  RegisterPackage('xpl_win', @Register); 
end.
