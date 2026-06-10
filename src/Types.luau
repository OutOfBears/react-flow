local React = require("./React")

export type ValueConstructor<T> = (...any) -> T

export type LinearValueType =
	number
	| UDim2
	| UDim
	| Vector2
	| Vector3
	| Color3
	| ColorSequenceKeypoint
	| NumberSequenceKeypoint
	| NumberRange
	| PhysicalProperties
	| BrickColor
	| CFrame

export type SpringProperties<T> = {
	damper: number?,
	speed: number?,
	start: T?,
	target: T?,
	force: T?,
	delay: number?,
}

export type TweenCallback<T> = (T) -> ()

export type TweenProperties<T> = {
	info: TweenInfo?,
	startImmediate: T?,
	start: T?,
	target: T?,
	delay: number?,
}

export type Listener = (...any) -> ()

export type AnimationProps = {
	[string]: any,
}

export type StateSetters = { [string]: (any) -> nil }
export type DefaultProperties = { [string]: any }

export type SequenceProps = { { timestamp: number, [string]: any } }

export type SpringStart<T> = (subProps: SpringProperties<T>, immediate: boolean?) -> ()
export type SpringStop = () -> ()

export type TweenStart<T> = (subProps: TweenProperties<T>, immediate: boolean?) -> ()
export type TweenStop = () -> ()

export type Binding = React.Binding<any>
export type TransparencyValue = number | NumberSequence | Binding | nil

return {}
