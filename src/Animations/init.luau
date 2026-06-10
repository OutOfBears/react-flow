local Symbol = require(script.Symbols)

local Animations = {
	Spring = require(script.Types.Spring),
	Tween = require(script.Types.Tween),
}

export type AnimationFromDefinition<T> = {
	listener: ((...any) -> ())?,
	setListener: (AnimationFromDefinition<T>, ((...any) -> ())?) -> (),

	play: (AnimationFromDefinition<T>, from: T?, immediate: boolean?) -> (),
	stop: (AnimationFromDefinition<T>) -> (),
}

local function fromDefinition<T>(definitions): AnimationFromDefinition<T>
	local animationSymbol, animationProps = definitions[1], definitions[2]
	local animationType = Symbol[animationSymbol]

	return Animations[animationType].new(animationProps)
end

Animations.fromDefinition = fromDefinition

return Animations
