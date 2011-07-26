object TxPLMessage
  MessageType = cmnd
  hop = 1
  source.Vendor = 'clinique'
  source.Device = 'sender'
  source.Instance = 'instance'
  schema.Classe = 'exec'
  schema.Type_ = 'basic'
  Body.Keys.Strings = (
    'pid'
    'program'
  )
  Body.Values.Strings = (
    'test'
    'cmd.exe'
  )
  TimeStamp =  4.0750401127893521E+0004
  MsgName = 'xPL Exec Test message'
end
