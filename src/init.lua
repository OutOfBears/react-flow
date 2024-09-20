local Animations = require(script.Animations)

return {
	Tween = Animations.Tween.definition,
	Spring = Animations.Spring.definition,

	useAnimation = require(script.Hooks.useAnimation),
	useGroupAnimation = require(script.Hooks.useGroupAnimation),
	useSequenceAnimation = require(script.Hooks.useSequenceAnimation),

	useSpring = require(script.Hooks.useSpring),
	useTween = require(script.Hooks.useTween),

	useBindings = require(script.Hooks.useBindings),
}
