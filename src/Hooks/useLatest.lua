local Roact = require(script.Parent.Parent.Roact)
local useEffect = Roact.useEffect
local useState = Roact.useState

local function useLatest(...: any...)
	local initialValue = select(1, ...)
	local state, setState = useState(initialValue)

	for _, value in { ... } do
		useEffect(function()
			setState(value)
		end, { value })
	end

	return state
end

return useLatest
