local React = require(script.Parent.Parent.React)
local useBinding = React.useBinding
local useMemo = React.useMemo
local useRef = React.useRef

local GroupAnimationController = {}
GroupAnimationController.__index = GroupAnimationController

type StateSetters = {
	[string]: (any) -> nil,
}

export type Animation = {
	Play: (DefaultProperties) -> Animation,
	Stop: () -> nil,
}

export type GroupAnimation = {
	[string]: Animation,
}

export type DefaultProperties = {
	[string]: any,
}

function GroupAnimationController.new(props: GroupAnimation, default: DefaultProperties, setters: StateSetters)
	local self = setmetatable({}, GroupAnimationController)

	self.currentState = "Default"
	self.animations = props

	self.state = default
	self.setters = setters

	for state, animation in props do
		animation:SetListener(function(name, value)
			if self.currentState ~= state then
				return
			end

			self.state[name] = value
			self.setters[name](value)
		end)
	end

	return self
end

function GroupAnimationController:Play(newState: string)
	local animation = self.animations[newState]
	assert(animation, `No animation found for state {newState}`)

	self.currentState = newState

	if self.currentAnimation then
		self.currentAnimation:Stop()
	end

	self.currentAnimation = animation
	animation:Play(self.state)
end

function GroupAnimationController:Stop()
	if self.currentAnimation then
		self.currentAnimation:Stop()
		self.currentAnimation = nil
	end
end

function GroupAnimationController:UpdateSetters(setters: StateSetters)
	self.setters = setters
end

local function getStateContainer(defaults: DefaultProperties)
	local setters = {}
	local values = {}

	for name, value in defaults do
		local binding, updateBinding = useBinding(value)

		setters[name] = updateBinding
		values[name] = binding
	end

	return setters, values
end

local function useGroupAnimation(props: GroupAnimation, default: DefaultProperties)
	local defaults = useRef()
	if not defaults.current then
		defaults.current = default
	end

	local setters, values = getStateContainer(defaults.current)
	local controller = useMemo(function()
		local newController = GroupAnimationController.new(props, default, setters)

		return {
			updateSetters = function(newSetters: StateSetters)
				newController:UpdateSetters(newSetters)
			end,

			play = function(newState: string)
				assert(typeof(newState) == "string", "useGroupAnimation expects a string 'state'")

				newController:Play(newState)
			end,

			stop = function()
				newController:Stop()
			end,
		}
	end, {})

	controller.updateSetters(setters)

	return values, controller.play, controller.stop
end

return useGroupAnimation
