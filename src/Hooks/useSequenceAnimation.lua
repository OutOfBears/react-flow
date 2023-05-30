local Promise = require(script.Parent.Parent.Promise)

local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef

export type SequenceProps = { { timestamp: number } | any }

local Sequence = {}
Sequence.__index = Sequence

function Sequence.new(props: SequenceProps)
	local self = setmetatable({}, Sequence)

	self.playing = false
	self.listener = nil
	self.animation = props

	table.sort(props, function(a, b)
		return a.timestamp < b.timestamp
	end)

	local lastTimestamp

	for _, animation in props do
		local timestamp = animation.timestamp
		if lastTimestamp == timestamp then
			error("Duplicate timestamp found in sequence")
		end

		lastTimestamp = timestamp

		for name, animatable in animation do
			if name == "timestamp" then
				continue
			end

			animatable:SetListener(function(value)
				if self.listener then
					self.listener(name, value)
				end
			end)
		end
	end

	return self
end

function Sequence:SetListener(listener: (string, any) -> ())
	self.listener = listener
end

function Sequence:Play(fromProps: SequenceProps)
	if self.playing then
		self:Stop()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local promises = {}

		for _, sequenced in self.animation do
			local animationPromise = Promise.delay(sequenced.timestamp):andThen(function()
				local allAnimatables = {}

				for name, animatable in sequenced do
					if name == "timestamp" then
						continue
					end

					table.insert(allAnimatables, animatable:Play(fromProps[name]))
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

function Sequence:Stop()
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function useSequenceAnimation(props: SequenceProps)
	local animation = useRef()
	local current = animation.current

	if not current then
		current = Sequence.new(props)
		animation.current = current
	end

	return current
end

return useSequenceAnimation
