Attribute VB_Name = "ModMixerAPI"
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



' The Complete Mixer API ...

Type MIXERCAPS
     wMid As Integer
     wPid As Integer
     vDriverVersion As Long
     szPname As String * 32
     fdwSupport As Long
     cDestinations As Long
End Type

Type MIXERCONTROL
     cbStruct As Long
     dwControlID As Long
     dwControlType As Long
     fdwControl As Long
     cMultipleItems As Long
     szShortName As String * 16
     szName As String * 64
     lMinimum As Long
     lMaximum As Long
     Reserved(10) As Long
End Type

Type MIXERCONTROLDETAILS
     cbStruct As Long
     dwControlID As Long
     cChannels As Long
     item As Long
     cbDetails As Long
     paDetails As Long
End Type

Type MIXERCONTROLDETAILS_BOOLEAN
     fValue As Long
End Type

Type MIXERCONTROLDETAILS_LISTTEXT
     dwParam1 As Long
     dwParam2 As Long
     szName As String * 64
End Type

Type MIXERCONTROLDETAILS_SIGNED
     lValue As Long
End Type

Type MIXERCONTROLDETAILS_UNSIGNED
     dwValue As Long
End Type

Type Target
     dwType As Long
     dwDeviceID As Long
     wMid As Integer
     wPid As Integer
     vDriverVersion As Long
     szPname As String * 32
End Type

Type MIXERLINE
     cbStruct As Long
     dwDestination As Long
     dwSource As Long
     dwLineID As Long
     fdwLine As Long
     dwUser As Long
     dwComponentType As Long
     cChannels As Long
     cConnections As Long
     cControls As Long
     szShortName As String * 16
     szName As String * 64
     lpTarget As Target
End Type

Type MIXERLINECONTROLS
     cbStruct As Long
     dwLineID As Long
     dwControl As Long
     cControls As Long
     cbmxctrl As Long
     pamxctrl As Long
End Type

Declare Function mixerClose& Lib "winmm.dll" (ByVal hmx&)
Declare Function mixerGetControlDetails& Lib "winmm.dll" Alias "mixerGetControlDetailsA" (ByVal hmxobj&, pmxcd As MIXERCONTROLDETAILS, ByVal fdwDetails&)
Declare Function mixerGetDevCaps& Lib "winmm.dll" Alias "mixerGetDevCapsA" (ByVal uMxId&, pmxcaps As MIXERCAPS, ByVal cbmxcaps&)
Declare Function mixerGetID& Lib "winmm.dll" (ByVal hmxobj&, pumxID&, ByVal fdwId&)
Declare Function mixerGetLineControls& Lib "winmm.dll" Alias "mixerGetLineControlsA" (ByVal hmxobj&, pmxlc As MIXERLINECONTROLS, ByVal fdwControls&)
Declare Function mixerGetLineInfo& Lib "winmm.dll" Alias "mixerGetLineInfoA" (ByVal hmxobj&, pmxl As MIXERLINE, ByVal fdwInfo&)
Declare Function mixerGetNumDevs& Lib "winmm.dll" ()
Declare Function mixerMessage& Lib "winmm.dll" (ByVal hmx&, ByVal umsg&, ByVal dwParam1&, ByVal dwParam2&)
Declare Function mixerOpen& Lib "winmm.dll" (phmx&, ByVal uMxId&, ByVal dwCallback&, ByVal dwInstance&, ByVal fdwOpen&)
Declare Function mixerSetControlDetails& Lib "winmm.dll" (ByVal hmxobj&, pmxcd As MIXERCONTROLDETAILS, ByVal fdwDetails&)

Public Const MM_MIXM_LINE_CHANGE = &H3D0
Public Const MM_MIXM_CONTROL_CHANGE = &H3D1

Public Const MIXER_GETCONTROLDETAILSF_LISTTEXT = &H1&
Public Const MIXER_GETCONTROLDETAILSF_QUERYMASK = &HF&
Public Const MIXER_GETCONTROLDETAILSF_VALUE = &H0&

Public Const MIXER_GETLINECONTROLSF_ALL = &H0&
Public Const MIXER_GETLINECONTROLSF_ONEBYID = &H1&
Public Const MIXER_GETLINECONTROLSF_ONEBYTYPE = &H2&
Public Const MIXER_GETLINECONTROLSF_QUERYMASK = &HF&

Public Const MIXER_GETLINEINFOF_COMPONENTTYPE = &H3&
Public Const MIXER_GETLINEINFOF_DESTINATION = &H0&
Public Const MIXER_GETLINEINFOF_LINEID = &H2&
Public Const MIXER_GETLINEINFOF_QUERYMASK = &HF&
Public Const MIXER_GETLINEINFOF_SOURCE = &H1&
Public Const MIXER_GETLINEINFOF_TARGETTYPE = &H4&

Public Const MIXER_OBJECTF_AUX = &H50000000
Public Const MIXER_OBJECTF_HANDLE = &H80000000
Public Const MIXER_OBJECTF_HMIDIIN = &HC0000000
Public Const MIXER_OBJECTF_HMIDIOUT = &HB0000000
Public Const MIXER_OBJECTF_HMIXER = &H80000000
Public Const MIXER_OBJECTF_HWAVEIN = &HA0000000
Public Const MIXER_OBJECTF_HWAVEOUT = &H90000000
Public Const MIXER_OBJECTF_MIDIIN = &H40000000
Public Const MIXER_OBJECTF_MIDIOUT = &H30000000
Public Const MIXER_OBJECTF_MIXER = &H0&
Public Const MIXER_OBJECTF_WAVEIN = &H20000000
Public Const MIXER_OBJECTF_WAVEOUT = &H10000000

Public Const MIXER_SETCONTROLDETAILSF_CUSTOM = &H1&
Public Const MIXER_SETCONTROLDETAILSF_QUERYMASK = &HF&
Public Const MIXER_SETCONTROLDETAILSF_VALUE = &H0&

Public Const MIXERCONTROL_CONTROLF_DISABLED = &H80000000
Public Const MIXERCONTROL_CONTROLF_MULTIPLE = &H2&
Public Const MIXERCONTROL_CONTROLF_UNIFORM = &H1&

Public Const MIXERCONTROL_CT_CLASS_CUSTOM = &H0&
Public Const MIXERCONTROL_CT_CLASS_FADER = &H50000000
Public Const MIXERCONTROL_CT_CLASS_LIST = &H70000000
Public Const MIXERCONTROL_CT_CLASS_MASK = &HF0000000
Public Const MIXERCONTROL_CT_CLASS_METER = &H10000000
Public Const MIXERCONTROL_CT_CLASS_NUMBER = &H30000000
Public Const MIXERCONTROL_CT_CLASS_SLIDER = &H40000000
Public Const MIXERCONTROL_CT_CLASS_SWITCH = &H20000000
Public Const MIXERCONTROL_CT_CLASS_TIME = &H60000000

Public Const MIXERCONTROL_CT_UNITS_BOOLEAN = &H10000
Public Const MIXERCONTROL_CT_UNITS_CUSTOM = &H0&
Public Const MIXERCONTROL_CT_UNITS_DECIBELS = &H40000
Public Const MIXERCONTROL_CT_UNITS_MASK = &HFF0000
Public Const MIXERCONTROL_CT_UNITS_PERCENT = &H50000
Public Const MIXERCONTROL_CT_UNITS_SIGNED = &H20000
Public Const MIXERCONTROL_CT_UNITS_UNSIGNED = &H30000

Public Const MIXERCONTROL_CT_SC_LIST_MULTIPLE = &H1000000
Public Const MIXERCONTROL_CT_SC_LIST_SINGLE = &H0&
Public Const MIXERCONTROL_CT_SC_METER_POLLED = &H0&
Public Const MIXERCONTROL_CT_SC_SWITCH_BOOLEAN = &H0&
Public Const MIXERCONTROL_CT_SC_SWITCH_BUTTON = &H1000000
Public Const MIXERCONTROL_CT_SC_TIME_MICROSECS = &H0&
Public Const MIXERCONTROL_CT_SC_TIME_MILLISECS = &H1000000
Public Const MIXERCONTROL_CT_SUBCLASS_MASK = &HF000000

Public Const MIXERCONTROL_CONTROLTYPE_BASS = &H50030002
Public Const MIXERCONTROL_CONTROLTYPE_BOOLEAN = &H20010000
Public Const MIXERCONTROL_CONTROLTYPE_BOOLEANMETER = &H10010000
Public Const MIXERCONTROL_CONTROLTYPE_BUTTON = &H21010000
Public Const MIXERCONTROL_CONTROLTYPE_CUSTOM = &H0&
Public Const MIXERCONTROL_CONTROLTYPE_DECIBELS = &H30040000
Public Const MIXERCONTROL_CONTROLTYPE_EQUALIZER = &H50030004
Public Const MIXERCONTROL_CONTROLTYPE_FADER = &H50030000
Public Const MIXERCONTROL_CONTROLTYPE_LOUDNESS = &H20010004
Public Const MIXERCONTROL_CONTROLTYPE_MICROTIME = &H60030000
Public Const MIXERCONTROL_CONTROLTYPE_MILLITIME = &H61030000
Public Const MIXERCONTROL_CONTROLTYPE_MIXER = &H71010001
Public Const MIXERCONTROL_CONTROLTYPE_MONO = &H20010003
Public Const MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT = &H71010000
Public Const MIXERCONTROL_CONTROLTYPE_MUTE = &H20010002
Public Const MIXERCONTROL_CONTROLTYPE_MUX = &H70010001
Public Const MIXERCONTROL_CONTROLTYPE_ONOFF = &H20010001
Public Const MIXERCONTROL_CONTROLTYPE_PAN = &H40020001
Public Const MIXERCONTROL_CONTROLTYPE_PEAKMETER = &H10020001
Public Const MIXERCONTROL_CONTROLTYPE_PERCENT = &H30050000
Public Const MIXERCONTROL_CONTROLTYPE_QSOUNDPAN = &H40020002
Public Const MIXERCONTROL_CONTROLTYPE_SIGNED = &H30020000
Public Const MIXERCONTROL_CONTROLTYPE_SIGNEDMETER = &H10020000
Public Const MIXERCONTROL_CONTROLTYPE_SINGLESELECT = &H70010000
Public Const MIXERCONTROL_CONTROLTYPE_SLIDER = &H40020000
Public Const MIXERCONTROL_CONTROLTYPE_STEREOENH = &H20010005
Public Const MIXERCONTROL_CONTROLTYPE_TREBLE = &H50030003
Public Const MIXERCONTROL_CONTROLTYPE_UNSIGNED = &H30030000
Public Const MIXERCONTROL_CONTROLTYPE_UNSIGNEDMETER = &H10030000
Public Const MIXERCONTROL_CONTROLTYPE_VOLUME = &H50030001

Public Const MIXERLINE_COMPONENTTYPE_DST_FIRST = &H0&
Public Const MIXERLINE_COMPONENTTYPE_DST_DIGITAL = &H1&
Public Const MIXERLINE_COMPONENTTYPE_DST_HEADPHONES = &H5&
Public Const MIXERLINE_COMPONENTTYPE_DST_LAST = &H8&
Public Const MIXERLINE_COMPONENTTYPE_DST_LINE = &H2&
Public Const MIXERLINE_COMPONENTTYPE_DST_MONITOR = &H3&
Public Const MIXERLINE_COMPONENTTYPE_DST_SPEAKERS = &H4&
Public Const MIXERLINE_COMPONENTTYPE_DST_TELEPHONE = &H6&
Public Const MIXERLINE_COMPONENTTYPE_DST_UNDEFINED = &H0&
Public Const MIXERLINE_COMPONENTTYPE_DST_VOICEIN = &H8&
Public Const MIXERLINE_COMPONENTTYPE_DST_WAVEIN = &H7&

Public Const MIXERLINE_COMPONENTTYPE_SRC_FIRST = &H1000&
Public Const MIXERLINE_COMPONENTTYPE_SRC_ANALOG = &H100A&
Public Const MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY = &H1009&
Public Const MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC = &H1005&
Public Const MIXERLINE_COMPONENTTYPE_SRC_DIGITAL = &H1001&
Public Const MIXERLINE_COMPONENTTYPE_SRC_LAST = &H100A&
Public Const MIXERLINE_COMPONENTTYPE_SRC_LINE = &H1002&
Public Const MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE = &H1003&
Public Const MIXERLINE_COMPONENTTYPE_SRC_PCSPEAKER = &H1007&
Public Const MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER = &H1004&
Public Const MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE = &H1006&
Public Const MIXERLINE_COMPONENTTYPE_SRC_UNDEFINED = &H1000&
Public Const MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT = &H1008&

Public Const MIXERLINE_LINEF_ACTIVE = &H1&
Public Const MIXERLINE_LINEF_DISCONNECTED = &H8000&
Public Const MIXERLINE_LINEF_SOURCE = &H80000000

Public Const MIXERLINE_TARGETTYPE_AUX = 5
Public Const MIXERLINE_TARGETTYPE_MIDIIN = 4
Public Const MIXERLINE_TARGETTYPE_MIDIOUT = 3
Public Const MIXERLINE_TARGETTYPE_UNDEFINED = 0
Public Const MIXERLINE_TARGETTYPE_WAVEIN = 2
Public Const MIXERLINE_TARGETTYPE_WAVEOUT = 1

Public Const MIXERR_BASE = 1024
Public Const MIXERR_INVALCONTROL = 1025
Public Const MIXERR_INVALLINE = 1024
Public Const MIXERR_INVALVALUE = 1026
Public Const MIXERR_LASTERROR = 1026
