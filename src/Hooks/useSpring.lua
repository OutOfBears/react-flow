local RunService = game:GetService("RunService")

local React = require(script.Parent.Parent.React)
local useEffect = React.useEffect
local useState = React.useState
local useMemo = React.useMemo

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

local function useSpring(initial: LinearValue.LinearValueType, speed: number?, dampening: number?)
	speed = speed or 20
	dampening = dampening or 1

	local spring = useMemo(function()
		return SpringValue.new(initial, speed, dampening)
	end, {})

	local state, setState = useState(initial)

	useEffect(function()
		return function()
			SpringValues[spring] = nil
		end
	end, {})

	return state,
		function(animation: {
			goal: LinearValue.LinearValueType?,
			value: LinearValue.LinearValueType?,
			force: LinearValue.LinearValueType?,
		})
			if animation.goal then
				spring:SetGoal(animation.goal)
			end

			if animation.value then
				spring:SetValue(animation.value)
			end

			if animation.force then
				spring:Impulse(animation.force)
			end

			SpringValues[spring] = setState
		end,
		function()
			SpringValues[spring] = nil
		end
end

return useSpring
