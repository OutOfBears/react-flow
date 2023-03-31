local LinearValue = require(script.Parent.LinearValue)

local SpringValue = {}
SpringValue.__index = SpringValue

local EPSILON = 0.0001

function SpringValue.new(initial: LinearValue.LinearValueType, speed: number?, damper: number?)
	local target = LinearValue.fromValue(initial)

	return setmetatable({
		_current = target,
		_goal = target,
		_velocities = {},
		_speed = speed or 1,
		_damper = damper or 1,
	}, SpringValue)
end

function SpringValue:Impulse(impulse: LinearValue.LinearValueType)
	local impulseValues = LinearValue.fromValue(impulse)._value
	for i = 1, #impulseValues do
		self._velocities[i] = (self._velocities[i] or 0) + impulseValues[i]
	end
end

function SpringValue:SetGoal(goal: LinearValue.LinearValueType)
	self._goal = LinearValue.fromValue(goal)
end

function SpringValue:GetGoal()
	return self._goal:ToValue()
end

function SpringValue:SetValue(value: LinearValue.LinearValueType)
	self._current = LinearValue.fromValue(value)
end

function SpringValue:GetValue()
	return self._current:ToValue()
end

function SpringValue:Update(dt: number)
	local currentValues = self._current._value
	local goalValues = self._goal._value
	local velocities = self._velocities

	local newValues = {}
	local updated = false

	for i = 1, #currentValues do
		local goalValue = goalValues[i]
		local position, newVelocity = self:getPositionVelocity(dt, currentValues[i], velocities[i] or 0, goalValue)

		newValues[i] = position
		velocities[i] = newVelocity

		if math.abs(position - goalValue) > EPSILON or math.abs(newVelocity) > EPSILON then
			updated = true
		end
	end

	self._current = LinearValue.new(self._current._ccstr, unpack(newValues))
	return updated
end

-- credit to @Quenty
-- https://github.com/Quenty/NevermoreEngine/blob/main/src/spring/src/Shared/Spring.lua
function SpringValue:getPositionVelocity(dt: number, current: number, velocity: number, target: number)
	local p0 = current
	local v0 = velocity
	local p1 = target
	local d = self._damper
	local s = self._speed

	local t = s * dt
	local d2 = d * d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d * t) / h
		co, si = ep * math.cos(h * t), ep * math.sin(h * t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d * t) / h
		co, si = ep, ep * t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h) * t) / (2 * h)
		local v = math.exp((-d - h) * t) / (2 * h)
		co, si = u + v, u - v
	end

	local a0 = h * co + d * si
	local a1 = 1 - (h * co + d * si)
	local a2 = si / s

	local b0 = -s * si
	local b1 = s * si
	local b2 = h * co - d * si

	return a0 * p0 + a1 * p1 + a2 * v0, b0 * p0 + b1 * p1 + b2 * v0
end

return SpringValue
