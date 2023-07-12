local TweenService = game:GetService("TweenService")

local BaseAnimation = require(script.Parent.Parent.Base)
local Promise = require(script.Parent.Parent.Parent.Promise)
local LinearValue = require(script.Parent.Parent.Parent.Utility.LinearValue)

local Tween = {}
Tween.__index = Tween

export type Tween = typeof(Tween.new())
export type TweenProperties<T> = {
	info: TweenInfo,
	start: T,
	target: T,
	immediate: boolean?,
	delay: number?,
}

local function playTween(tweenInfo, callback: (number) -> nil, completed: () -> nil)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		callback(numberValue.Value)
	end)

	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = 1,
	})

	tween.Completed:Connect(function()
		numberValue:Destroy()
		completed()
	end)

	return function()
		tween:Play()
	end, function()
		numberValue:Destroy()
		tween:Cancel()
	end
end

function Tween.new<T>(props: TweenProperties<T>)
	local self = setmetatable(BaseAnimation.new(), Tween) :: Tween

	self.props = props
	self.player = nil

	return self
end

function Tween:Play(from: any?)
	if self.playing then
		self:Stop()
	end

	local tweenInfo = self.props.info :: TweenInfo
	local baseFromValue = self.props.start or from :: any
	local baseToValue = self.props.target :: any

	-- start immediately will start the tween but not update the listener
	local startImmediately = self.props.immediate == true
	local delayTime = self.props.delay :: number

	if not delayTime then
		assert(startImmediately == false, "Cannot start immediately without a delay")
	else
		if startImmediately then
			assert(delayTime < tweenInfo.Time, "DelayTime must be less than Time")
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

	local animation = Promise.new(function(resolve, _, onCancel)
		local canUpdate = true

		local play, cancel = playTween(tweenInfo, function(value)
			if not canUpdate then
				return
			end

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
				canUpdate = false
				play()

				task.wait(delayTime)
				canUpdate = true
			else
				task.wait(delayTime)
				play()
			end
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
