local React = require("../React")
local Promise = require("../Promise")
local Animations = require("../Animations")
local Types = require("../Types")

local useMemo = React.useMemo

export type SequencedAnimations = {
	[string]: { [string]: Animations.AnimationFromDefinition<any> },
}
export type Sequence = {
	animations: { SequencedAnimations & { timestamp: number } },
	playing: boolean,
	listener: Types.Listener?,
	setListener: (Sequence, Types.Listener?) -> (),
	play: (Sequence, Types.SequenceProps, boolean) -> (),
	stop: (Sequence) -> (),
}

local function setListener(self: Sequence, listener: Types.Listener?)
	self.listener = listener
end

local function play(self: Sequence, fromProps: Types.SequenceProps, immediate: boolean?)
	if self.playing then
		self:stop()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local promises = {}
		local playing = {}

		for _, sequenced in self.animations do
			local animationPromise = Promise.delay(if immediate then 0 else sequenced.timestamp):andThen(function()
				local allAnimatables = {}

				for name, animatable in sequenced do
					if name == "timestamp" then
						continue
					end

					if playing[name] then
						playing[name]:cancel()
					end

					local promise = animatable:play(fromProps[name], immediate)
					playing[name] = promise

					table.insert(allAnimatables, promise)
				end

				return Promise.all(allAnimatables)
			end)

			table.insert(promises, animationPromise)
		end

		local awaiter = Promise.all(promises):andThen(resolve)

		onCancel(function()
			for _, promise in promises do
				promise:cancel()
			end

			awaiter:cancel()
		end)
	end)

	self.playing = true
	self.player = animation

	return animation
end

local function stop(self: Sequence)
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function Sequence(props: Types.SequenceProps)
	local object = {} :: Sequence
	local animations = {} :: SequencedAnimations

	object.animations = animations
	object.playing = false
	object.listener = nil

	object.stop = stop
	object.play = play
	object.setListener = setListener

	for i, animation in props do
		animations[i] = {
			timestamp = animation.timestamp,
		}

		for name, animatable: any in animation do
			if name == "timestamp" then
				continue
			end

			animations[i][name] = Animations.fromDefinition(animatable)
		end
	end

	table.sort(animations, function(a, b)
		return a.timestamp < b.timestamp
	end)

	local lastTimestamp

	for _, animation in animations do
		local timestamp = animation.timestamp
		if lastTimestamp == timestamp then
			error("Duplicate timestamp found in sequence")
		end

		lastTimestamp = timestamp

		for name, animatable in animation do
			if name == "timestamp" then
				continue
			end

			animatable:setListener(function(value)
				if object.listener then
					object.listener(name, value)
				end
			end)
		end
	end

	return object
end

local function useSequenceAnimation(props: Types.SequenceProps)
	return useMemo(function()
		return Sequence(props)
	end, {})
end

return useSequenceAnimation
