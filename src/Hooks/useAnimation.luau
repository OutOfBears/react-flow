local React = require("../React")
local Promise = require("../Promise")
local Animations = require("../Animations")
local Types = require("../Types")

local useMemo = React.useMemo

export type SingleAnimation = {
	playing: boolean,
	listener: Types.Listener?,
	animations: { [string]: Animations.AnimationFromDefinition<any> },
	setListener: (SingleAnimation, Types.Listener?) -> (),
	play: (SingleAnimation, Types.AnimationProps, boolean?) -> (),
	stop: (SingleAnimation) -> (),
}

local function setListener(self: SingleAnimation, listener: Types.Listener?)
	self.listener = listener
end

local function play(self: SingleAnimation, fromProps: Types.AnimationProps, immediate: boolean?)
	if self.playing then
		self:stop()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local promises = {}

		for name, animatable in self.animation do
			local animationPromise = animatable:play(fromProps[name], immediate)
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

local function stop(self: SingleAnimation)
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function Animation(props: Types.AnimationProps)
	local object = {} :: SingleAnimation
	local animations = {} :: { [string]: Animations.AnimationFromDefinition<any> }

	object.playing = false
	object.listener = nil
	object.animation = animations

	object.play = play
	object.stop = stop
	object.setListener = setListener

	for name, animation in props do
		animations[name] = Animations.fromDefinition(animation)
	end

	for name, animation in animations do
		animation:setListener(function(value)
			if object.listener then
				object.listener(name, value)
			end
		end)
	end

	return object
end

local function useAnimation(props: Types.AnimationProps)
	return useMemo(function()
		return Animation(props)
	end, {}) :: SingleAnimation
end

return useAnimation
