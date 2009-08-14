Attribute VB_Name = "ModMain"
Option Explicit

' ============================================================================
'
' Author:        Stuart Pennington.
' E-Mail:        stuart.pennington@btinternet.com
' Web Site:      http://www.btinternet.com/~stuart.pennington/NB4AH.html
'
' Project:       Audio Mixer.
' Test Platform: Windows 2000.
' Processor:     Pentium II - 400 MHz.
'
' ============================================================================



Public hMixer&         ' The Handle Of The Mixer.
Public MaxSources&     ' Number Of Output Sources Available.
Public ProductName$    ' Product Name Of The Mixer (Used In The Main Form's Caption).
Public xPL_Setting As String
Public xPL_View
Public chkAutoTick As Boolean 'is this a human click or an auto one?

Private Destinations&  ' Number Of Destination's That The Mixer Support's.

' Used For Aquiring Details About Any Given Mixer Control.
' Fader, Mute, PeakMeter...
Public MCD As MIXERCONTROLDETAILS

Private ML As MIXERLINE

Type RECT
     rLeft As Long
     rTop As Long
     rRight As Long
     rBottom As Long
End Type


' #########################################################################

' This Is A Type I've Created To Slim Down
' The Coding In The Main Form

Type MIXERSETTINGS
     MxrName As String      ' Text Description
     MxrVisible As Boolean  ' Hidden or Not?
     MxrChannels As Long    ' Indicates Whether A Line Is Mono Or Stereo.
     MxrLeftVol As Long     ' Left Volume Value (Balance).
     MxrRightVol As Long    ' Right Volume Value (Balance).
     MxrVol As Long         ' Fader Volume.
     MxrVolID As Long       ' Fader Control ID.
     MxrMute As Long        ' Mute Status.
     MxrMuteID As Long      ' Mute Control ID.
     MxrPeakID As Long      ' Peak Meter ID.
End Type

' A Dynamic Array Of The Aformentioned Type.

Public MixerState() As MIXERSETTINGS

' #########################################################################


' Addition API Subs And Function's.

Declare Function BitBlt& Lib "gdi32" (ByVal hDestDC&, ByVal x1&, ByVal y1&, ByVal nWidth&, ByVal nHeight&, ByVal hSrcDC&, ByVal xSrc&, ByVal ySrc&, ByVal dwRop&)
Declare Function DrawEdge& Lib "user32" (ByVal ahDc&, lpRect As RECT, ByVal nEdge&, ByVal nFlags&)
Declare Function SetRect& Lib "user32" (lpRect As RECT, ByVal x1&, ByVal y1&, ByVal x2&, ByVal y2&)

Declare Sub CopyStructFromPtr Lib "kernel32" Alias "RtlMoveMemory" (struct As Any, ByVal ptr&, ByVal cb&)
Declare Sub CopyPtrFromStruct Lib "kernel32" Alias "RtlMoveMemory" (ByVal ptr&, struct As Any, ByVal cb&)

Declare Function GlobalAlloc& Lib "kernel32" (ByVal wFlags&, ByVal dwBytes&)
Declare Function GlobalFree& Lib "kernel32" (ByVal hMem&)
Declare Function GlobalLock& Lib "kernel32" (ByVal hMem&)
Declare Function GlobalUnlock& Lib "kernel32" (ByVal hMem&)

' Maintainance String, App's Title.
Public Const Ttl = "xPL Enabled Mixer"

Private Sub Main()
   
   Dim strCmd As String

    #If Win32 Then
        ' Need To Check Out The Following Else We Can't Run.
        If Not MixerPresent Then End
        If Not OpenMixer Then End
        If Not GetDeviceCapabilities Then End
        
        xPL_Setting = "xPL.WMUTE-VOL32." + xPL_Source    ' set registry string
        
        ' If We Got Here, Let's Get Some Mixer Info.
        GetMixerInfo
        ' Display The App.
        FrmMxr.Show
    #Else
        ' Not 32 Bit OS.
        End
    #End If

End Sub
Private Function MixerPresent() As Boolean

    Dim Msg$  ' For Error String.

    ' The "mixerGetNumDevs" API Will Let Us Know If There Is A Mixer Onboard.
    If mixerGetNumDevs() Then
       MixerPresent = True      ' Yes, We Have One.
    Else
       ' No Mixer. This App Is Useless.
       ' Inform The User And Terminate On Return.
       Msg = "Unable to detect a mixer."
       Msg = Msg & vbCrLf & vbCrLf
       Msg = Msg & "Terminating..."
       MsgBox Msg, vbCritical, Ttl & " - Error"
    End If

End Function
Private Function OpenMixer() As Boolean

    Dim Msg$  ' For Error String.

    ' See If We Can Open The Mixer.
    ' If Successful, The Global "hMixer" Variable Will Contain It's Handle.
    If mixerOpen(hMixer, 0, 0, 0, 0) = 0 Then
       OpenMixer = True   ' Yes, We Opened The Mixer.
    Else
       ' Unable To Open The Mixer.
       ' Inform The User And Terminate On Return.
       Msg = "Unable to open mixer."
       Msg = Msg & vbCrLf & vbCrLf
       Msg = Msg & "Terminating..."
       MsgBox Msg, vbCritical, Ttl & " - Error"
    End If

End Function
Private Function GetDeviceCapabilities() As Boolean

    Dim Msg$                   ' For Error String.
    Dim MxrCaps As MIXERCAPS   ' Mixer Capabilities Structure.

    ' Query The Mixer's Capabilitie's.
    If mixerGetDevCaps(0, MxrCaps, Len(MxrCaps)) = 0 Then
       ' Only Interested In The "Destinations" Value And "Product Name".
       ' Destinations Can Be Speakers, Wave In, Voice Recognition Etc...
       Destinations = MxrCaps.cDestinations - 1
       ' Tidy Up The Pruduct Name Ready For Displaying In The Main Form's Caption.
       ProductName = Left(MxrCaps.szPname, InStr(MxrCaps.szPname, vbNullChar) - 1)
       ' Return Success.
       GetDeviceCapabilities = True
    Else
       ' Unable To Aquire Mixer Capabilites.
       ' Inform The User And Terminate On Return.
       Msg = "Unable to aquire mixer capabilities."
       Msg = Msg & vbCrLf & vbCrLf
       Msg = Msg & "Terminating..."
       MsgBox Msg, vbCritical, Ttl & " - Error"
    End If

End Function
Private Sub GetMixerInfo()

    ' Purpose: Scans The Destination's Until The Speaker's Are Found.
    '          Then, Information About All Sources Connected To The Speaker's
    '          Are Saved Into The "MixerState" Array For Use In The Main Form

    Dim Dst&, Src&    ' Destination And Source Counter's.
    Dim ControlID&    ' ID Of A Given Control.
    
    For Dst = 0 To Destinations
        ' Prep The MIXERLINE Structure.
        ML.cbStruct = Len(ML)
        ML.dwDestination = Dst
        ' Get Destination Line Info.
        mixerGetLineInfo hMixer, ML, MIXER_GETLINEINFOF_DESTINATION

        ' Was The Component Type The Speaker's?
        If ML.dwComponentType = MIXERLINE_COMPONENTTYPE_DST_SPEAKERS Then

           ' How Many Item's Are Connected To The Speaker's?
           ' I'm Gonna Set An Upper Limit Of 10 And Set The "MaxSources" Variable.
           If ML.cConnections > 10 Then
              ML.cConnections = 10
              MaxSources = 10
           Else
              MaxSources = ML.cConnections  ' Less Than 10.
           End If

           ' Re-Dimension The "MixerState" Array.
           ' Note: The Array Is Zero Based, Element Zero Is For The Master Voume
           '       The Remaining Elements Are For The Source's.
           ReDim MixerState(MaxSources)

           ' Save The Number Of Channels For The Master Volume.
           MixerState(0).MxrChannels = ML.cChannels
           ' Update The Name Label On The Main Form, and store the name for later
           MixerState(0).MxrName = Left(ML.szName, InStr(ML.szName, vbNullChar) - 1)
           FrmMxr.LblName(0).Caption = MixerState(0).MxrName
            
           ' Call The "GetControlID" Function So We Can Get The Control ID
           ' Of The Master Volume.
           ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_VOLUME)
           If ControlID <> 0 Then
              ' Prep The MCD Structure For The Master Volume Fader.
              With MCD
                  .cbDetails = 4  ' Size Of A Long In Byte's.
                  .cbStruct = 24
                  .cChannels = ML.cChannels
                  .dwControlID = ControlID
                  .item = 0
                  .paDetails = VarPtr(MixerState(0).MxrVol)
              End With
              ' Get The Master Volume Setting.
              mixerGetControlDetails hMixer, MCD, MIXER_GETCONTROLDETAILSF_VALUE
              ' Track Bar Logic Is The Reverse Of Fader's On A Hardware Mixer
              ' So Reverse The Value.
              MixerState(0).MxrVol = 65535 - MixerState(0).MxrVol
              ' Save The Master Volume Control ID.
              MixerState(0).MxrVolID = MCD.dwControlID
           Else
              ' Couldn't Get It, Disable The Fader.
              FrmMxr.SldrVol(0).Enabled = 0
           End If

           ' Call The "GetControlID" Function So We Can Get The Control ID
           ' Of The Master Mute.
           ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_MUTE)
           If ControlID <> 0 Then
              ' Prep The MCD Structure For The Master Mute.
              With MCD
                  .cbDetails = 4  ' Size Of A Long In Byte's.
                  .cbStruct = Len(MCD)
                  .cChannels = ML.cChannels
                  .dwControlID = ControlID
                  .item = 0
                  .paDetails = VarPtr(MixerState(0).MxrMute)
              End With
              ' Get The Master Mute Setting.
              mixerGetControlDetails hMixer, MCD, MIXER_GETCONTROLDETAILSF_VALUE
              ' Save The Master Mute Control ID.
              MixerState(0).MxrMuteID = MCD.dwControlID
           Else
              ' Couldn't Get It, Disable The Master Mute.
              chkAutoTick = 1
              FrmMxr.ChkMute(0).Enabled = 0
           End If

           ' Does This Control Have A Peak Meter With It?
           ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_PEAKMETER)
           If ControlID <> 0 Then
              ' It Does, Save It's ID.
              MixerState(0).MxrPeakID = ControlID
           End If

           ' Now That We've Found The Speakers And The Master Volume,
           ' Let's Get The Source's...

           For Src = 0 To ML.cConnections - 1
               ' Prep The "MIXERLINE" Struct For Source's.
               ML.cbStruct = Len(ML)
               ML.dwDestination = Dst
               ML.dwSource = Src
               ' Get The Line Info For The Current Source.
               mixerGetLineInfo hMixer, ML, MIXER_GETLINEINFOF_SOURCE

               ' Save The Channels Of The Source.
               MixerState(Src + 1).MxrChannels = ML.cChannels
               ' Update The Name Label On The Main Form, and store the name for later
               MixerState(Src + 1).MxrName = Left(ML.szName, InStr(ML.szName, vbNullChar) - 1)
               FrmMxr.LblName(Src + 1).Caption = MixerState(Src + 1).MxrName

               ' Call The "GetControlID" Function So We Can Get The Control ID
               ' Of The Current Source Volume.
               ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_VOLUME)
               If ControlID <> 0 Then
                  ' Prep The MCD Structure For The Current Source Volume.
                  With MCD
                      .cbDetails = 4   ' Size Of A Long In Byte's.
                      .cbStruct = Len(MCD)
                      .cChannels = ML.cChannels
                      .dwControlID = ControlID
                      .item = 0
                      .paDetails = VarPtr(MixerState(Src + 1).MxrVol)
                  End With
                  ' Get The Current Source Volume Setting.
                  mixerGetControlDetails hMixer, MCD, MIXER_GETCONTROLDETAILSF_VALUE
                  ' Save The Volume Setting.
                  MixerState(Src + 1).MxrVol = 65535 - MixerState(Src + 1).MxrVol
                  ' Save The ID
                  MixerState(Src + 1).MxrVolID = MCD.dwControlID
               Else
                  ' Couldn't Get It, So Disable The Control.
                  FrmMxr.SldrVol(Src + 1).Enabled = 0
               End If

               ' Call The "GetControlID" Function So We Can Get The Control ID
               ' Of The Current Source Mute.
               ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_MUTE)
               If ControlID <> 0 Then
                  ' Prep The MCD Structure For The Current Source Mute.
                  With MCD
                      .cbDetails = 4   ' Size Of A Long In Byte's.
                      .cbStruct = Len(MCD)
                      .cChannels = ML.cChannels
                      .dwControlID = ControlID
                      .item = 0
                      .paDetails = VarPtr(MixerState(Src + 1).MxrMute)
                  End With
                  ' Get The Current Source Mute Setting.
                  mixerGetControlDetails hMixer, MCD, MIXER_GETCONTROLDETAILSF_VALUE
                  ' Save The Mute Control ID.
                  MixerState(Src + 1).MxrMuteID = MCD.dwControlID
               Else
                  ' Couldn't Get It, So Disable The Control.
                  chkAutoTick = 1
                  FrmMxr.ChkMute(Src + 1).Enabled = 0
               End If

               ' Does This Control Have A Peak Meter With It?
               ControlID = GetControlID(ML.dwComponentType, MIXERCONTROL_CONTROLTYPE_PEAKMETER)
               If ControlID <> 0 Then
                  ' It Does, Save It's Id.
                  MixerState(Src + 1).MxrPeakID = ControlID
               End If
               
               ' Should this Conrol Be Visible?
               MixerState(Src + 1).MxrVisible = GetSetting(xPL_Setting, "Properties", "Slider" + Str(Src + 1), True)
                
           Next
           ' We Found The Destination That Is The Speaker's, So Exit The Outer Loop.
           Exit For
        End If
    Next

End Sub
Public Function GetControlID&(ByVal ComponentType&, ByVal ControlType&)

   ' Purpose: Return's The Requested Control ID.

   Dim hMem&
   Dim MC As MIXERCONTROL
   Dim MxrLine As MIXERLINE
   Dim MLC As MIXERLINECONTROLS

   ' Prep The MxrLine Structure.
   MxrLine.cbStruct = Len(MxrLine)
   MxrLine.dwComponentType = ComponentType  ' This Value Sent In.

   ' Get The Line Info.
   If mixerGetLineInfo(hMixer, MxrLine, MIXER_GETLINEINFOF_COMPONENTTYPE) = 0 Then
      ' Prep The MLC Structure.
      MLC.cbStruct = Len(MLC)
      MLC.dwLineID = ML.dwLineID
      MLC.dwControl = ControlType     ' This Value Sent In.
      MLC.cControls = 1
      MLC.cbmxctrl = Len(MC)

      hMem = GlobalAlloc(&H40, Len(MC))
      MLC.pamxctrl = GlobalLock(hMem)

      MC.cbStruct = Len(MC)

      ' Get The Line Control.
      If mixerGetLineControls(hMixer, MLC, MIXER_GETLINECONTROLSF_ONEBYTYPE) = 0 Then
         ' Copy The Data To The MC Structure.
         CopyStructFromPtr MC, MLC.pamxctrl, Len(MC)
         ' Return The Control ID.
         GetControlID = MC.dwControlID
      End If

      GlobalUnlock hMem
      GlobalFree hMem
   End If

End Function

