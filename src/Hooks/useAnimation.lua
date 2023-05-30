local Promise = require(script.Parent.Parent.Promise)

local React = require(script.Parent.Parent.React)
local useRef = React.useRef

export type AnimationProps = {
	[string]: any,
}

local Animation = {}
Animation.__index = Animation

function Animation.new(props: AnimationProps)
	local self = setmetatable({}, Animation)

	self.playing = false
	self.listener = nil
	self.animation = props

	for name, animation in props do
		animation:SetListener(function(value)
			if self.listener then
				self.listener(name, value)
			end
		end)
	end

	return self
end

function Animation:SetListener(listener: (string, any) -> ())
	self.listener = listener
end

function Animation:Play(fromProps: AnimationProps)
	if self.playing then
		self:Stop()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local promises = {}

		for name, animatable in self.animation do
			local animationPromise = animatable:Play(fromProps[name])
			table.insert(promises, animationPromise)
		end

		local awaiter = Promise.all(promises):andThen(resolve)

		onCancel(function()
			awaiter:cancel()

			for _, promise in promises do
				promise:cancel()
			end
		end)
	end)

	self.playing = true
	self.player = animation

	return animation
end

function Animation:Stop()
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function useAnimation(props: AnimationProps)
	local animation = useRef()
	local current = animation.current

	if not current then
		current = Animation.new(props)
		animation.current = current
	end

	return current
end

return useAnimation
