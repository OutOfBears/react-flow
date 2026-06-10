local React = require("../../React")
local SpringValue = require("../Utility/SpringValue")
local Types = require("../Types")

local useBinding = React.useBinding
local useMemo = React.useMemo
local useEffect = React.useEffect

local function useSpringValue<T>(props: Types.SpringProperties<T>): React.Binding<T?>
	local initial = props.start or props.target
	local binding, update = useBinding(initial)

	local spring = useMemo(function()
		return SpringValue(initial, props.speed, props.damper)
	end, {})

	spring:setUpdater(update)

	useEffect(function()
		return function()
			spring:stop()
		end
	end, {})

	useEffect(function()
		if props.speed then
			spring:setSpeed(props.speed)
		end

		if props.damper then
			spring:setDamper(props.damper)
		end
	end, { props.speed, props.damper } :: { any })

	useEffect(function()
		if props.target == nil then
			return
		end

		spring:setGoal(props.target)

		if not spring:playing() then
			spring:run()
		end
	end, { props.target } :: { any })

	return binding
end

return useSpringValue
