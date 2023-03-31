local Roact = require(script.Parent.Parent.Roact)
local useEffect = Roact.useEffect
local useState = Roact.useState

export type Callback = (...any) -> ()

local function useLatest(...: any...)
	local state, setState = useState()

	for _, value in { ... } do
		useEffect(function()
			setState(value)
		end, { value })
	end

	return state
end

return useLatest
