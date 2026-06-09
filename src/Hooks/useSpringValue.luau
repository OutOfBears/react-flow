local React = require("../../React")
local SpringValue = require("../Utility/SpringValue")
local Spring = require("../Animations/Types/Spring")

local useBinding = React.useBinding
local useMemo = React.useMemo
local useEffect = React.useEffect

local function useSpringValue<T>(props: Spring.SpringProperties<T>): React.Binding<T?>
	local initial = props.start or props.target
	local binding, update = useBinding(initial)

	local spring = useMemo(function()
		return SpringValue.new(initial, props.speed, props.damper)
	end, {})

	spring:SetUpdater(update)

	useEffect(function()
		return function()
			spring:Stop()
		end
	end, {})

	useEffect(function()
		if props.speed then
			spring:SetSpeed(props.speed)
		end

		if props.damper then
			spring:SetDamper(props.damper)
		end
	end, { props.speed, props.damper } :: { any })

	useEffect(function()
		if props.target == nil then
			return
		end

		spring:SetGoal(props.target)

		if not spring:Playing() then
			spring:Run()
		end
	end, { props.target } :: { any })

	return binding
end

return useSpringValue
