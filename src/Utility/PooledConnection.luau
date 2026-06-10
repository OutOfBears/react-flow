export type ConnectionCallback = (...any) -> ()

export type PooledConnection = {
	Connected: boolean,
	Disconnect: (self: PooledConnection) -> (),
}

export type ConnectionPool = {
	Connect: (self: ConnectionPool, callback: ConnectionCallback) -> PooledConnection,
	DisconnectAll: (self: ConnectionPool) -> (),
}

local connectionPools = {} :: { [RBXScriptConnection]: ConnectionPool }

local function PooledConnection(connection: RBXScriptConnection)
	if connectionPools[connection] then
		return connectionPools[connection]
	end

	local object = {} :: ConnectionPool

	local callbacks = {} :: { [ConnectionCallback]: PooledConnection }
	local globalConnection: RBXScriptConnection?

	function object:DisconnectAll()
		if globalConnection then
			globalConnection:Disconnect()
			globalConnection = nil
		end

		for _, callback in callbacks do
			callback.Connected = false
		end

		callbacks = {}
	end

	function object:Connect(callback: ConnectionCallback)
		local existing = callbacks[callback]
		if existing then
			return existing
		end

		if not globalConnection then
			globalConnection = connection:Connect(function(...)
				for currentCallback in callbacks do
					currentCallback(...)
				end
			end)
		end

		local connected = {
			Connected = true,
			Disconnect = function(thisConnection: PooledConnection)
				if not thisConnection.Connected then
					return
				end

				thisConnection.Connected = false
				callbacks[callback] = nil

				if next(callbacks) == nil and globalConnection then
					globalConnection:Disconnect()
					globalConnection = nil
				end
			end,
		}

		callbacks[callback] = connected
		return connected
	end

	connectionPools[connection] = object

	return object
end

return PooledConnection
