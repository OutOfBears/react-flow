local Symbol = require(script.Symbols)

local Animations = {
	Spring = require("@self/Types/Spring"),
	Tween = require("@self/Types/Tween"),
}

local function fromDefinition(definitions)
	local animationSymbol, animationProps = definitions[1], definitions[2]
	local animationType = Symbol[animationSymbol]

	return Animations[animationType].new(animationProps)
end

Animations.fromDefinition = fromDefinition

return Animations
