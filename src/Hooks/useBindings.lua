local React = require(script.Parent.Parent.React)
local useEffect = React.useEffect
-- TODO: Remove this when we have a better way to subscribe to bindings
local subscribeToBinding = React.__subscribeToBinding

local function useBindings(callback: (any...) -> (), bindings: { any }, deps: { table })
	useEffect(function()
		local disconnects = {}
		local values = {}

		local running = true

		for i, binding in bindings do
			values[i] = binding:getValue()
		end

		for i, binding in bindings do
			local idx = i

			disconnects[idx] = subscribeToBinding(binding, function(newValue)
				if not running then
					warn("Binding updated after unmount")
					return
				end

				values[idx] = newValue
				callback(unpack(values))
			end)
		end

		callback(unpack(values))

		return function()
			for _, disconnect in disconnects do
				disconnect()
			end

			running = false
			table.clear(disconnects)
			table.clear(values)
		end
	end, { unpack(bindings), unpack(deps or {}) })
end

return useBindings
