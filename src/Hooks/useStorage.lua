local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef

local function useStorage(name: string?)
	name = name or "global"

	local globalStack = useRef({})

	local currenStack = globalStack.current
	local stack = currenStack[name]
	if not stack then
		stack = {}
		currenStack[name] = stack
	end

	return stack
end

return useStorage
