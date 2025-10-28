local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BaseAnimation = require(script.Parent.Parent.Base)
local Promise = require(script.Parent.Parent.Parent.Promise)
local LinearValue = require(script.Parent.Parent.Parent.Utility.LinearValue)
local Symbols = require(script.Parent.Parent.Symbols)

local Tween = {}
Tween.__index = Tween

type Callback<T> = (T) -> ()

export type Tween = typeof(Tween.new())
export type TweenProperties<T> = {
	info: TweenInfo,
	startImmediate: T?,
	start: T,
	target: T,
	delay: number?,
}

local callbacks = {}
local pooledUpdateConnection: RBXScriptConnection? = nil

local function pooledUpdate(callback: Callback<number>): () -> ()
    callbacks[callback] = true

    if not pooledUpdateConnection then
        pooledUpdateConnection = RunService.RenderStepped:Connect(function(dt)
            local ran = false

            for nextCallback in callbacks do
                ran = true
                nextCallback(dt)
            end

            if not ran and pooledUpdateConnection then
                pooledUpdateConnection:Disconnect()
                pooledUpdateConnection = nil
            end
        end)
    end

    return function()
        callbacks[callback] = nil
        if next(callbacks) == nil and pooledUpdateConnection then
            pooledUpdateConnection:Disconnect()
            pooledUpdateConnection = nil
        end
    end
end

local function playTween(tweenInfo, callback: (number) -> nil, completed: () -> nil)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		callback(numberValue.Value)
	end)

	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = 1,
	})

	tween.Completed:Once(function()
		numberValue:Destroy()
		completed()
	end)

	return function()
		callback(0)
		tween:Play()
	end, function()
		numberValue:Destroy()
		tween:Cancel()
	end
end

local function playTween2(tweenInfo: TweenInfo, callback: Callback<number>, completed: Callback<unknown>)
	local disconnect

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
		if disconnect then
			disconnect()
			disconnect = nil
		end
	end

	local function play()
		elapsed = 0
		repeats = 0

		if tweenDelay and tweenDelay > 0 then
			elapsed = -tweenDelay
		end

		if not disconnect then
			disconnect = pooledUpdate(function(dt)
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

function Tween.definition<T>(props: TweenProperties<T>)
	return {
		[1] = Symbols.Tween,
		[2] = props,
	}
end

function Tween.new<T>(props: TweenProperties<T>)
	local self = setmetatable(BaseAnimation.new(), Tween) :: Tween

	self.props = props
	self.player = nil

	return self
end

function Tween:Play(from: any?, immediate: boolean?)
	if self.playing then
		self:Stop()
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

	local fromValue = LinearValue.fromValue(baseFromValue)
	local toValue = LinearValue.fromValue(baseToValue)

	if immediate then
		self.listener(baseToValue)

		self.playing = false
		self.player = nil

		return Promise.resolve()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local play, cancel = playTween2(tweenInfo, function(value)
			local newValue = fromValue:Lerp(toValue, value):ToValue()
			self.listener(newValue)
		end, function()
			self.playing = false
			self.player = nil
			resolve()
		end)

		onCancel(cancel)

		if not delayTime then
			play()
		else
			if startImmediately then
				self.listener(baseFromValue)
			end

			task.wait(delayTime)
			play()
		end
	end)

	self.playing = true
	self.player = animation

	return animation
end

function Tween:Stop()
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

return Tween
