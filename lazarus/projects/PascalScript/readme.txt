Changes History : 
	0.7 : This version drops the 'autosense' configuration element and use a system compatible with
		global caching as designed in xPL Hal manager 2. Then the files CacheManager.custom.xml and 
		CacheManager.standard.xml can directly be used to survey specific variables.

	0.8 Functions and procedure available for the scripting has been updated :
			Procedure SendMsg( aMsgType : TxPLMessageType; aTarget, aSchema, aBody : string);
			function  Exists(aString : string; bDelete : boolean) : boolean;
			function  MessageType : string;
			function  MessageSender : string;
			function  MessageSchema : string;
			function  Msg_Class : string;
			function  Msg_Sender_Device: string;
			function  MessageValues : integer;
			function  MessageKey (i : integer) : string;
			function  MessageValue(i : integer) : string;
			function  MessageValueFromKey(s : string) : string;
			function  GlobalValue(aString : string) : string;
			function  GlobalFormer(aString : string) : string;
			function  GlobalCreated(aString : string) : TDateTime;
			function  GlobalModified(aString : string) : TDateTime;
			procedure Value(aString, aValue : string);
			procedure Log(aString : string);

