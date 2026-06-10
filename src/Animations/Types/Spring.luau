local BaseAnimation = require("../Base")
local Promise = require("../../Promise")
local SpringValue = require("../../Utility/SpringValue")
local Symbols = require("../Symbols")
local Types = require("../../Types")

export type Spring<T> = BaseAnimation.BaseAnimation & {
	_oldSpring: any?,

	props: Types.SpringProperties<T>,
	player: any?,
	playing: boolean?,

	play: (self: Spring<T>, from: T?, immediate: boolean?) -> any,
	stop: (self: Spring<T>) -> (),
}

local function definition<T>(props: Types.SpringProperties<T>)
	return {
		[1] = Symbols.Spring,
		[2] = props,
	}
end

local function play<T>(self: Spring<T>, from: T?, immediate: boolean?)
	if self.playing then
		self:stop()
	end

	local baseFromValue = self.props.start or from :: T
	local baseToValue = self.props.target :: T
	local force = self.props.force :: T?

	assert(baseFromValue, "No start value provided")
	assert(baseToValue, "No target value provided")

	if baseFromValue == baseToValue and not force then
		return Promise.resolve()
	end

	local newSpring = SpringValue(baseFromValue, self.props.speed, self.props.damper)
	newSpring:setImmediate(immediate)
	newSpring:setGoal(baseToValue)
	newSpring:setDelay(self.props.delay)

	local oldVelocity = self._oldSpring and self._oldSpring:getVelocity()
	if oldVelocity then
		newSpring:impulse(oldVelocity)
	end

	if force then
		newSpring:impulse(force)
	end

	if self._oldSpring then
		self._oldSpring:destroy()
	end

	local animation = newSpring:run(function()
		if self.listener then
			self.listener(newSpring:getValue())
		end
	end)

	self.playing = true
	self.player = animation
	self._oldSpring = newSpring

	return animation
end

local function stop<T>(self: Spring<T>)
	if not self.playing then
		return
	end

	if self.player then
		self.player:cancel()
		self.player = nil
	end

	self.playing = false
end

local function Spring<T>(props: Types.SpringProperties<T>): Spring<T>
	local object = BaseAnimation.new() :: Spring<T>

	object.props = props
	object.player = nil

	object.play = play
	object.stop = stop

	return object
end

return {
	new = Spring,
	definition = definition,
}
