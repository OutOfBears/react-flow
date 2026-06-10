local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BaseAnimation = require("../Base")
local Promise = require("../../Promise")
local LinearValue = require("../../Utility/LinearValue")
local PooledConnection = require("../../Utility/PooledConnection")
local Symbols = require("../Symbols")
local Types = require("../../Types")

export type Tween<T> = BaseAnimation.BaseAnimation & {
	props: Types.TweenProperties<T>,
	player: any?,
	playing: boolean?,

	play: (self: Tween<T>, from: T?, immediate: boolean?) -> any,
	stop: (self: Tween<T>) -> (),
}

local renderSteppedPool = PooledConnection(RunService.RenderStepped)

local function playTween(
	tweenInfo: TweenInfo,
	callback: Types.TweenCallback<number>,
	completed: Types.TweenCallback<unknown>
)
	local connection: PooledConnection.PooledConnection?

	local repeats = 0
	local elapsed = 0

	local tweenTime = tweenInfo.Time
	local tweenDelay = tweenInfo.DelayTime

	local tweenRepeatCount = tweenInfo.RepeatCount
	local tweenReverses = tweenInfo.Reverses

	local tweenEasing = tweenInfo.EasingStyle
	local tweenDirection = tweenInfo.EasingDirection

	assert(tweenReverses == false, "Tween reverses is not supported")

	local function stop()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	local function play()
		elapsed = 0
		repeats = 0

		if tweenDelay and tweenDelay > 0 then
			elapsed = -tweenDelay
		end

		if not connection then
			connection = renderSteppedPool:Connect(function(dt)
				elapsed += dt

				local alpha = math.clamp(elapsed / tweenTime, 0, 1)
				local value = TweenService:GetValue(alpha, tweenEasing, tweenDirection)

				callback(value)

				if alpha >= 1 then
					if tweenRepeatCount ~= 0 and repeats < tweenRepeatCount then
						repeats += 1
						elapsed = 0
						return
					end

					stop()
					completed()
				end
			end)
		end
	end

	return play, stop
end

local function definition<T>(props: Types.TweenProperties<T>)
	return {
		[1] = Symbols.Tween,
		[2] = props,
	}
end

local function play<T>(self: Tween<T>, from: any?, immediate: boolean?)
	if self.playing then
		self:stop()
	end

	local tweenInfo = self.props.info :: TweenInfo
	local baseFromValue = self.props.startImmediate or self.props.start or from :: any
	local baseToValue = self.props.target :: any

	-- start immediately will start the tween but not update the listener
	local startImmediately = self.props.startImmediate ~= nil
	local delayTime = self.props.delay :: number

	if not delayTime then
		assert(startImmediately == false, "Cannot start immediately without a delay")
	else
		if startImmediately then
			assert(delayTime > 0, "DelayTime must be greater than zero")
		end
	end

	assert(baseFromValue, "No start value provided")
	assert(baseToValue, "No target value provided")

	assert(tweenInfo, "No tween info provided")
	assert(tweenInfo.RepeatCount == 0, "RepeatCount must be 0")
	assert(tweenInfo.Reverses == false, "Reverses must be false")
	assert(tweenInfo.DelayTime == 0, "DelayTime must be 0")

	if baseFromValue == baseToValue then
		return Promise.resolve()
	end

	local fromValue = LinearValue(baseFromValue)
	local toValue = LinearValue(baseToValue)

	if immediate then
		self.listener(baseToValue)

		self.playing = false
		self.player = nil

		return Promise.resolve()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local playTweenAnimation, cancel = playTween(tweenInfo, function(value)
			local newValue = fromValue:lerp(toValue, value):toValue()
			self.listener(newValue)
		end, function()
			self.playing = false
			self.player = nil
			resolve()
		end)

		onCancel(cancel)

		if not delayTime then
			playTweenAnimation()
		else
			if startImmediately then
				self.listener(baseFromValue)
			end

			task.wait(delayTime)
			playTweenAnimation()
		end
	end)

	self.playing = true
	self.player = animation

	return animation
end

local function stop<T>(self: Tween<T>)
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function Tween<T>(props: Types.TweenProperties<T>): Tween<T>
	local object = BaseAnimation.new() :: Tween<T>

	object.props = props
	object.player = nil

	object.play = play
	object.stop = stop

	return object
end

return {
	new = Tween,
	definition = definition,
}
