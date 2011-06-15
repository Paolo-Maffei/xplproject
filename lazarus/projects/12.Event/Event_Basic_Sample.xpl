object TxPLMessage
  MessageType = cmnd
  hop = 1
  source.Vendor = 'clinique'
  source.Device = 'logger'
  source.Instance = 'lapfr0005'
  target.Vendor = 'clinique'
  target.Device = 'event'
  target.Instance = 'lapfr0005'
  schema.Classe = 'event'
  schema.Type_ = 'basic'
  Body.Keys.Strings = (
    'device'
    'type'
    'action'
    'date'
  )
  Body.Values.Strings = (
    'test2'
    'oneshot'
    'start'
    '20110608154110'
  )
end
