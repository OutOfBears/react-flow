local BaseAnimation = require(script.Parent.Parent.Base)
local Promise = require(script.Parent.Parent.Parent.Promise)
local SpringValue = require(script.Parent.Parent.Parent.Utility.SpringValue)

local Spring = {}
Spring.__index = Spring

export type Spring = typeof(Spring.new())
export type SpringProperties = {
	damper: number?,
	speed: number?,
	start: any,
	target: any,
}

function Spring.new(props: SpringProperties)
	local self = setmetatable(BaseAnimation.new(), Spring) :: Spring

	self.props = props
	self.player = nil

	return self
end

function Spring:Play(from: any?)
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
	newSpring:SetGoal(baseToValue)

	local oldVelocity = self._oldSpring and self._oldSpring:GetVelocity()
	if oldVelocity then
		newSpring:Impulse(oldVelocity)
	end

	if force then
		newSpring:Impulse(force)
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
