local RunService = game:GetService("RunService")

local LinearValue = require("./LinearValue")
local PooledConnection = require("./PooledConnection")
local Promise = require("../Promise")
local Types = require("../Types")

export type SpringValue<T> = {
	current: LinearValue.LinearValue<T>,
	goal: LinearValue.LinearValue<T>,
	velocities: { number },
	speed: number,
	damper: number,
	immediate: boolean,
	updater: ((any) -> ())?,
	delay: number?,

	destroy: (SpringValue<T>) -> (),
	impulse: (SpringValue<T>, Types.LinearValueType) -> (),
	getVelocity: (SpringValue<T>) -> T,
	setGoal: (SpringValue<T>, Types.LinearValueType) -> (),
	setSpeed: (SpringValue<T>, number) -> (),
	setDamper: (SpringValue<T>, number) -> (),
	setImmediate: (SpringValue<T>, boolean) -> (),
	setDelay: (SpringValue<T>, number?) -> (),
	setUpdater: (SpringValue<T>, (any) -> ()) -> (),
	getGoal: (SpringValue<T>) -> T,
	setValue: (SpringValue<T>, Types.LinearValueType) -> (),
	getValue: (SpringValue<T>) -> T,
	update: (SpringValue<T>, number) -> boolean,
	playing: (SpringValue<T>) -> boolean,
	stop: (SpringValue<T>) -> (),
	run: (SpringValue<T>, ((any) -> ())?) -> any,
}

local EPSILON = 1e-2

local activeSprings = {}
local renderSteppedPool = PooledConnection(RunService.RenderStepped)
local tickConnection: PooledConnection.PooledConnection? = nil

local SpringValue

local function tick(dt: number)
	local empty = true

	for spring, resolve in activeSprings do
		empty = false

		local didUpdate = spring:update(dt)
		local value = spring:getValue()

		if spring.updater then
			spring.updater(value)
		end

		if not didUpdate then
			activeSprings[spring] = nil
			resolve()
		end
	end

	if empty and tickConnection then
		tickConnection:Disconnect()
		tickConnection = nil
	end
end

local function ensurePooledUpdate()
	if tickConnection then
		return
	end

	tickConnection = renderSteppedPool:Connect(tick)
end

-- credit to @Quenty
-- https://github.com/Quenty/NevermoreEngine/blob/main/src/spring/src/Shared/Spring.lua
local function computeCoefficients(damper: number, speed: number, dt: number)
	local d = damper
	local s = speed
	local t = s * dt
	local d2 = d * d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d * t) / h
		co, si = ep * math.cos(h * t), ep * math.sin(h * t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d * t)
		co, si = ep, ep * t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h) * t) / (2 * h)
		local v = math.exp((-d - h) * t) / (2 * h)
		co, si = u + v, u - v
	end

	local a0 = h * co + d * si
	local a1 = 1 - a0
	local a2 = si / s
	local b0 = -s * si
	local b1 = s * si
	local b2 = h * co - d * si

	return a0, a1, a2, b0, b1, b2
end

local function destroy<T>(self: SpringValue<T>)
	activeSprings[self] = nil
end

local function impulse<T>(self: SpringValue<T>, value: Types.LinearValueType)
	local impulseValues = LinearValue(value).values
	for i = 1, #impulseValues do
		self.velocities[i] += impulseValues[i]
	end
end

local function getVelocity<T>(self: SpringValue<T>)
	if self.current.ccstr then
		return self.current.ccstr(unpack(self.velocities))
	end

	return unpack(self.velocities)
end

local function alignQuaternionSign<T>(self: SpringValue<T>)
	if self.goal.ccstr ~= CFrame.new then
		return
	end

	local currentValues = self.current.values
	local goalValues = self.goal.values

	local dot = currentValues[4] * goalValues[4]
		+ currentValues[5] * goalValues[5]
		+ currentValues[6] * goalValues[6]
		+ currentValues[7] * goalValues[7]

	if dot < 0 then
		goalValues[4] = -goalValues[4]
		goalValues[5] = -goalValues[5]
		goalValues[6] = -goalValues[6]
		goalValues[7] = -goalValues[7]
	end
end

local function setGoal<T>(self: SpringValue<T>, goal: Types.LinearValueType)
	self.goal = LinearValue(goal)
	alignQuaternionSign(self)
end

local function setSpeed<T>(self: SpringValue<T>, speed: number)
	self.speed = speed
end

local function setDamper<T>(self: SpringValue<T>, damper: number)
	self.damper = damper
end

local function setImmediate<T>(self: SpringValue<T>, immediate: boolean)
	self.immediate = immediate
end

local function setDelay<T>(self: SpringValue<T>, delay: number?)
	if delay then
		assert(delay >= 0, "Delay must be a non-negative number")
	end

	self.delay = delay
end

local function playing<T>(self: SpringValue<T>)
	return activeSprings[self] ~= nil
end

local function getValue<T>(self: SpringValue<T>)
	return self.current:toValue()
end

local function setUpdater<T>(self: SpringValue<T>, updater: (any) -> ())
	self.updater = updater

	if playing(self) and updater then
		updater(getValue(self))
	end
end

local function getGoal<T>(self: SpringValue<T>)
	return self.goal:toValue()
end

local function setValue<T>(self: SpringValue<T>, value: Types.LinearValueType)
	self.current = LinearValue(value)
	alignQuaternionSign(self)
end

local function update<T>(self: SpringValue<T>, dt: number)
	local currentValues = self.current.values
	local goalValues = self.goal.values
	local velocities = self.velocities
	local updated = false

	local a0, a1, a2, b0, b1, b2 = computeCoefficients(self.damper, self.speed, dt)

	for i = 1, #currentValues do
		local goalValue = goalValues[i]
		local current = currentValues[i]
		local velocity = velocities[i]

		local position = a0 * current + a1 * goalValue + a2 * velocity
		local newVelocity = b0 * current + b1 * goalValue + b2 * velocity

		currentValues[i] = position
		velocities[i] = newVelocity

		if math.abs(position - goalValue) > EPSILON or math.abs(newVelocity) > EPSILON then
			updated = true
		end
	end

	return updated
end

local function stop<T>(self: SpringValue<T>)
	local resolve = activeSprings[self]
	if resolve then
		activeSprings[self] = nil
		resolve()
	end
end

local function run<T>(self: SpringValue<T>, updater: ((any) -> ())?)
	if updater then
		self.updater = updater
	end

	if self.immediate then
		local current = self.current.values
		local goal = self.goal.values
		for i = 1, #current do
			current[i] = goal[i]
		end

		if self.updater then
			self.updater(getValue(self))
		end

		return Promise.resolve()
	end

	return Promise.new(function(resolve, _, onCancel)
		local cancelled = false
		onCancel(function()
			cancelled = true
			stop(self)
		end)

		if self.delay then
			task.wait(self.delay)

			if cancelled then
				return
			end
		end

		if updater then
			updater(getValue(self))
		end

		activeSprings[self] = resolve
		ensurePooledUpdate()
	end)
end

function SpringValue<T>(initial: Types.LinearValueType, speed: number?, damper: number?): SpringValue<T>
	local object: SpringValue<T> = {} :: any

	object.current = LinearValue(initial)
	object.goal = LinearValue(initial)
	object.velocities = table.create(#object.current.values, 0)
	object.speed = speed or 1
	object.damper = damper or 1
	object.immediate = false
	object.updater = nil
	object.delay = nil

	object.destroy = destroy
	object.impulse = impulse
	object.getVelocity = getVelocity
	object.setGoal = setGoal
	object.setSpeed = setSpeed
	object.setDamper = setDamper
	object.setImmediate = setImmediate
	object.setDelay = setDelay
	object.setUpdater = setUpdater
	object.getGoal = getGoal
	object.setValue = setValue
	object.getValue = getValue
	object.update = update
	object.playing = playing
	object.stop = stop
	object.run = run

	return object
end

return SpringValue
