(***********************************************************)
(* xPLRFX                                                  *)
(* part of Digital Home Server project                     *)
(* http://www.digitalhomeserver.net                        *)
(* info@digitalhomeserver.net                              *)
(***********************************************************)
program xPLRFX;

{$mode objfpc}{$H+}

(*

Copyright 2011-2013, RFXCOM
ALL RIGHTS RESERVED. This document contains material protected under Netherlands Copyright Laws and Treaties and shall be subject to the exclusive jurisdiction of the Netherlands Courts. The information from this document may freely be used to create programs to exclusively interface with RFXCOM products only. Any other use or unauthorized reprint of this material is prohibited. No part of this document may be reproduced or transmitted in any form or by any means, electronic or mechanical, including photocopying, recording, or by any information storage and retrieval system without express written permission from RFXCOM.

//----------------------------------------------------------------------------
//                     Software License Agreement
//
// Copyright 2011-2013, RFXCOM
//
// ALL RIGHTS RESERVED. This code is owned by RFXCOM, and is protected under
// Netherlands Copyright Laws and Treaties and shall be subject to the
// exclusive jurisdiction of the Netherlands Courts. The information from this
// file may freely be used to create programs to exclusively interface with
// RFXCOM products only. Any other use or unauthorized reprint of this material
// is prohibited. No part of this file may be reproduced or transmitted in
// any form or by any means, electronic or mechanical, including photocopying,
// recording, or by any information storage and retrieval system without
// express written permission from RFXCOM.
//
// The above copyright notice shall be included in all copies or substantial
// portions of this Software.
//-----------------------------------------------------------------------------

*)

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LazSerialPort, main, uxPLRFX, uxPLRFXConst, uxPLRFXMessages,
  uxPLRFX_0x10, uxPLRFX_0x11, uxPLRFX_0x12, uxPLRFX_0x14, uxPLRFX_0x15,
  uxPLRFX_0x18, uxPLRFX_0x19, uxPLRFX_0x20, uxPLRFX_0x28, uxPLRFX_0x30,
  uxPLRFX_0x50, uxPLRFX_0x51, uxPLRFX_0x52, uxPLRFX_0x53, uxPLRFX_0x54,
  uxPLRFX_0x55, uxPLRFX_0x56, uxPLRFX_0x57, uxPLRFX_0x58, uxPLRFX_0x59,
  uxPLRFX_0x5A, uxPLRFX_0x5B, uxPLRFX_0x5D, uxPLRFX_0x70, about
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.

