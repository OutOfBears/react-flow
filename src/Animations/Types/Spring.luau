local BaseAnimation = require("../Base")
local Promise = require("../../Promise")
local SpringValue = require("../../Utility/SpringValue")
local Symbols = require("../Symbols")

local Spring = {}
Spring.__index = Spring

export type SpringProperties<T> = {
	damper: number?,
	speed: number?,
	start: T?,
	target: T?,
	force: T?,
	delay: number?,
}

export type Spring<T> = {
	props: SpringProperties<T>,
	player: any?,
	playing: boolean?,
	listener: ((T) -> ())?,
	_oldSpring: any?,

	Play: (self: Spring<T>, from: T?, immediate: boolean?) -> any,
	Stop: (self: Spring<T>) -> (),
	SetListener: (self: Spring<T>, listener: (T) -> ()) -> (),
}

function Spring.definition<T>(props: SpringProperties<T>)
	return {
		[1] = Symbols.Spring,
		[2] = props,
	}
end

function Spring.new<T>(props: SpringProperties<T>): Spring<T>
	local self = setmetatable(BaseAnimation.new(), Spring) :: Spring<T>

	self.props = props
	self.player = nil

	return self
end

function Spring:Play(from: any?, immediate: boolean?)
	if self.playing then
		self:Stop()
	end

	local baseFromValue = self.props.start or from :: any
	local baseToValue = self.props.target :: any
	local force = self.props.force :: any

	assert(baseFromValue, "No start value provided")
	assert(baseToValue, "No target value provided")

	if baseFromValue == baseToValue and not force then
		return Promise.resolve()
	end

	local newSpring = SpringValue.new(baseFromValue, self.props.speed, self.props.damper)
	newSpring:SetImmediate(immediate)
	newSpring:SetGoal(baseToValue)
	newSpring:SetDelay(self.props.delay)

	local oldVelocity = self._oldSpring and self._oldSpring:GetVelocity()
	if oldVelocity then
		newSpring:Impulse(oldVelocity)
	end

	if force then
		newSpring:Impulse(force)
	end

	if self._oldSpring then
		self._oldSpring:Destroy()
	end

	local animation = newSpring:Run(function()
		if self.listener then
			self.listener(newSpring:GetValue())
		end
	end)

	self.playing = true
	self.player = animation
	self._oldSpring = newSpring

	return animation
end

function Spring:Stop()
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

return Spring
