xPL App Title: xPLVoice

Default Source.Instance:
TONYT-VOICE.<hostname>HHMMSS

Default Filter(s):
xpl-cmnd.*.*.*

Default Group(s):
none

Schema(s):
VOICE.BASIC


Purpose:
Provide xPL voice commands to an xPL system


Installation:
Requires SAPI 5.1 engine
Accepts Standard xPL Settings
Additional Remote Config Items:
ZONE=<zone>
CONFIRM=<Y or N> defines if command should be spoken back
ACTIVATE=<word/phrase> optionally specifies a command to activate listening
SUSPEND=<word/phrase> optionally specifies a command to suspend listening
TIMEOUT=<1 to 60> number of seconds without a command before returning to commands.xml context

Notes:
CONFIRM defaults to N
If ACTIVATE has no value then always listens, otherwise waits for command
commands.xml is the default file, loaded at startup

By using the context command in the schema it is possible to use different files

Rename commands.xml.sam to commands.xml to use sample file

Acknowledgements:
