local Animations = require("@self/Animations")

return {
	Tween = Animations.Tween.definition,
	Spring = Animations.Spring.definition,

	useAnimation = require("@self/Hooks/useAnimation"),
	useGroupAnimation = require("@self/Hooks/useGroupAnimation"),
	useSequenceAnimation = require("@self/Hooks/useSequenceAnimation"),

	useSpring = require("@self/Hooks/useSpring"),
	useTween = require("@self/Hooks/useTween"),

	useSpringValue = require("@self/Hooks/useSpringValue"),
	useTweenValue = require("@self/Hooks/useTweenValue"),

	useBindings = require("@self/Hooks/useBindings"),
	useTransparencyModifier = require("@self/Hooks/useTransparencyModifier"),

	TransitionFragment = require("@self/Components/TransitionFragment"),
	DynamicList = require("@self/Components/DynamicList"),
}
