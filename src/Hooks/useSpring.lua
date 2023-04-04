local RunService = game:GetService("RunService")

local Roact = require(script.Parent.Parent.Roact)
local useEffect = Roact.useEffect
local useState = Roact.useState
local useMemo = Roact.useMemo

local Utility = script.Parent.Parent.Utility
local LinearValue = require(Utility.LinearValue)
local SpringValue = require(Utility.SpringValue)
local SpringValues = {}

RunService:UnbindFromRenderStep("UPDATE_REACT_SPRING")
RunService:BindToRenderStep("UPDATE_REACT_SPRING", Enum.RenderPriority.First.Value, function(dt: number)
	for spring, setValue in pairs(SpringValues) do
		local didUpdate = spring:Update(dt)
		local updatedValue = spring:GetValue()

		if not didUpdate then
			SpringValues[spring] = nil
			updatedValue = spring:GetGoal()
		end

		setValue(updatedValue)
	end
end)

local function makeSpring(
	updateState: (any) -> (),
	initial: LinearValue.LinearValueType,
	speed: number?,
	dampening: number?
)
	local springValue = SpringValue.new(initial, speed, dampening)

	return {
		play = function(animation: {
			goal: LinearValue.LinearValueType?,
			value: LinearValue.LinearValueType?,
			force: LinearValue.LinearValueType?,
		})
			if animation.goal then
				springValue:SetGoal(animation.goal)
			end

			if animation.value then
				springValue:SetValue(animation.value)
			end

			if animation.force then
				springValue:Impulse(animation.force)
			end

			springValue:Run(updateState)
		end,

		stop = function()
			springValue:Stop()
		end,
	}
end

local function useSpring(initial: LinearValue.LinearValueType, speed: number?, dampening: number?)
	speed = speed or 20
	dampening = dampening or 1

	local state, setState = useState(initial)
	local spring = useMemo(function()
		return makeSpring(setState, initial, speed, dampening)
	end, { initial, speed, dampening })

	return state, spring.play, spring.stop
end

return useSpring
