{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit xpl_win;

interface

uses
   v_xplmsg_opendialog, v_msgtype_radio, uControls, v_msgbody_stringgrid, 
   frame_config, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('v_xplmsg_opendialog', @v_xplmsg_opendialog.Register);
  RegisterUnit('v_msgtype_radio', @v_msgtype_radio.Register);
  RegisterUnit('uControls', @uControls.Register);
  RegisterUnit('v_msgbody_stringgrid', @v_msgbody_stringgrid.Register);
end;

initialization
  RegisterPackage('xpl_win', @Register);
end.
