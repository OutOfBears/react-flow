local RunService = game:GetService("RunService")

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

local Springs = {} :: {
	[Spring]: {
		completed: () -> nil,
		resolve: () -> (),
	},
}

function Spring.new(props: SpringProperties)
	local self = setmetatable(BaseAnimation.new(), Spring) :: Spring

	self.props = props
	self.player = nil

	return self
end

function Spring:Play(from: any?, force: Vector3?)
	if self.playing then
		self:Stop()
	end

	local baseFromValue = from or self.props.start :: any
	local baseToValue = self.props.target :: any

	assert(baseFromValue, "No from value provided")
	assert(baseToValue, "No to value provided")

	if from == baseToValue then
		return Promise.resolve()
	end

	local animation = Promise.new(function(resolve, _, onCancel)
		local newSpring = SpringValue.new(baseFromValue, self.props.speed, self.props.damper)

		newSpring:SetGoal(baseToValue)
		if force then
			newSpring:Impulse(force)
		end

		Springs[newSpring] = {
			resolve = resolve,
			update = function()
				if self.listener then
					self.listener(newSpring:GetValue())
				end
			end,
		}

		onCancel(function()
			Springs[newSpring] = nil
			resolve()
		end)
	end)

	self.playing = true
	self.player = animation

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

RunService:BindToRenderStep("UPDATE_REACT_SPRINGS", Enum.RenderPriority.First.Value, function(dt: number)
	for spring, data in Springs do
		local didUpdate = spring:Update(dt)
		data.update()

		if not didUpdate then
			Springs[spring] = nil
			data.resolve()
		end
	end
end)

return Spring
