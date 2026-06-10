local Animations = require(script.Animations)

return {
	Tween = Animations.Tween.definition,
	Spring = Animations.Spring.definition,

	useAnimation = require(script.Hooks.useAnimation),
	useGroupAnimation = require(script.Hooks.useGroupAnimation),
	useSequenceAnimation = require(script.Hooks.useSequenceAnimation),

	useSpring = require(script.Hooks.useSpring),
	useTween = require(script.Hooks.useTween),

	useSpringValue = require(script.Hooks.useSpringValue),
	useTweenValue = require(script.Hooks.useTweenValue),

	useBindings = require(script.Hooks.useBindings),
	useTransparencyModifier = require(script.Hooks.useTransparencyModifier),

	TransitionFragment = require(script.Components.TransitionFragment),
	DynamicList = require(script.Components.DynamicList),
}
