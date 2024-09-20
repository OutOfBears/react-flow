local function symbol(name: string)
	local object = {}

	setmetatable(object, {
		__tostring = `Symbol({name})`,
	})

	return object
end

local SPRING_SYMBOL = symbol("Spring")
local TWEEN_SYMBOL = symbol("Tween")

return {
	["Spring"] = SPRING_SYMBOL,
	["Tween"] = TWEEN_SYMBOL,

	[SPRING_SYMBOL] = "Spring",
	[TWEEN_SYMBOL] = "Tween",
}
