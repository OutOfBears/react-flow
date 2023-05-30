local Animations = require(script.Animations)

return {
	Tween = Animations.Tween,
	Spring = Animations.Spring,

	useAnimation = require(script.Hooks.useAnimation),
	useGroupAnimation = require(script.Hooks.useGroupAnimation),
	useSequenceAnimation = require(script.Hooks.useSequenceAnimation),
}
