local React = require("../React")
local Types = require("../Types")

local useBinding = React.useBinding
local useMemo = React.useMemo

export type Animation = {
	play: (Types.DefaultProperties, boolean?) -> Animation,
	stop: () -> nil,
}
export type GroupAnimation = { [string]: Animation }
export type GroupAnimationController = {
	currentstate: string,
	animations: GroupAnimation,
	state: Types.DefaultProperties,
	setters: Types.StateSetters,
	play: (GroupAnimationController, string, boolean?) -> (),
	stop: (GroupAnimationController) -> (),
	updateSetters: (GroupAnimationController, Types.StateSetters) -> (),
}

local function getStateContainer(defaults: Types.DefaultProperties)
	local setters = {}
	local values = {} :: { [string]: unknown }

	for name, value in defaults do
		local binding, updateBinding = useBinding(value)

		setters[name] = updateBinding
		values[name] = binding
	end

	return setters, values
end

local function updateSetters(self: GroupAnimationController, setters: Types.StateSetters)
	self.setters = setters
end

local function play(self: GroupAnimationController, newState: string, immediate: boolean?)
	local animation = self.animations[newState]
	assert(animation, `No animation found for state {newState}`)

	self.currentState = newState

	if self.currentAnimation then
		self.currentAnimation:stop()
	end

	self.currentAnimation = animation
	animation:play(self.state, immediate)
end

local function stop(self: GroupAnimationController)
	if self.currentAnimation then
		self.currentAnimation:stop()
		self.currentAnimation = nil
	end
end

local function GroupAnimationController(props: GroupAnimation, default: Types.DefaultProperties, setters: Types.StateSetters)
	local object = {} :: GroupAnimationController

	object.currentState = "Default"
	object.animations = props

	object.state = default
	object.setters = setters

	object.play = play
	object.stop = stop
	object.updateSetters = updateSetters

	for state, animation in props do
		animation:setListener(function(name, value)
			if object.currentState ~= state then
				return
			end

			object.state[name] = value
			object.setters[name](value)
		end)
	end

	return object
end

local function useGroupAnimation(props: GroupAnimation, default: Types.DefaultProperties)
	local defaults = useMemo(function()
		return default
	end, {})

	local setters, values = getStateContainer(defaults)
	local controller = useMemo(function()
		local newController = GroupAnimationController(props, defaults, setters)

		return {
			updateSetters = function(newSetters: Types.StateSetters)
				newController:updateSetters(newSetters)
			end,

			play = function(newState: string, immediate: boolean?)
				assert(typeof(newState) == "string", "useGroupAnimation expects a string 'state'")
				newController:play(newState, immediate)
			end,

			stop = function()
				newController:stop()
			end,
		}
	end, {}) :: {
		updateSetters: (setters: Types.StateSetters) -> (),
		play: (state: string, immediate: boolean?) -> (),
		stop: () -> (),
	}

	controller.updateSetters(setters)

	return values, controller.play, controller.stop
end

return useGroupAnimation
