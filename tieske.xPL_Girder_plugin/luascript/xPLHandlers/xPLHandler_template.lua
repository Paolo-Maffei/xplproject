--[[

This file is an xPL message handler template to be used with the xPLGirder plugin.
It allows for the easy handling of specific xPL message types.

Use the items below to create the handler, instructions are in the comments.

The file should be located inside the Girder program directory, in directory
'luascript\xPLHandlers', it will be loaded when the xPLGirder component initializes.

]]--



local myNewHandler = {

	ID = "UniqueHandlerID",		-- enter a unique string to identify this handler



	--[[
	first define a list of filters to trigger the message handler. Any filter that has a positive
	match will trigger the handler. Each Handler will be called once per message, so if this handler
	has 2 filters that match only the first will call the handler.

	a filter is a dot ('.') separated string with xPL message elements, each element may be
	wildcarded with an asterix ('*').

		filter = [msgtype].[vendor].[device].[instance].[class].[type]

	The default filter '*.*.*.*.*.*' will call the handler for each message received

	]]--

	Filters = {
		"*.*.*.*.*.*"
	},

	Initialize = function (self)
		-- function called upon initialization of this handler
		print ("Initializing the xPL handler ID: " .. self.ID)
	end,

	ShutDown = function (self)
		-- function called upon shuttingdown this handler
		print ("Shutting down the xPL handler ID: " .. self.ID)
	end,

	MessageHandler = function (self, msg, filter)
		--[[
		The handler function below will handle the actual message. The parameters are the xPL message
		and the filter string that passed the message.

		The return value should be a boolean indicating whether the standard xPLGirder event should
		be suppressed.
			msg is a table with the following keys;
			msg.type		message type, either one of 'xpl-cmnd', 'xpl-trig', or 'xpl-stat'.
			msg.hop			message hop-count
			msg.source		source address
			msg.target		target address (or wildcard)
			msg.schema		message schema
			msg.body		contains sub-tables, each with a 'key' and a 'value' field, so to access;
							first key value  :   msg.body[1].key
							first value value:	 msg.body[1].value
		]]--




		-- add your code here to handle the actual message
		print ("Got one on filter: " .. filter .. " from source: " .. msg.source)





		-- Determine the return value
		-- false: The standard xPLGirder event will still be created (if all other handlers also
		--        return false)
		-- true:  The standard xPLGirder event is suppressed, this should be used when the handler
		--        has created a more specific event from the xPL message than the regular xPLGirder
		--        event.
		return false
	end,
}


-- finally deliver the handler to the xPLGirder component
return myNewHandler
