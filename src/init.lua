local Animations = require(script.Animations)

return {
	Tween = Animations.Tween,
	Spring = Animations.Spring,

	useAnimation = require(script.Hooks.useAnimation),
	useGroupAnimation = require(script.Hooks.useGroupAnimation),
	useSequenceAnimation = require(script.Hooks.useSequenceAnimation),

	useSpring = require(script.Hooks.useSpring),
	useTween = require(script.Hooks.useTween),

	useBindings = require(script.Hooks.useBindings),
}
