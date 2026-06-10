local React = require("../../React")
local SpringValue = require("../Utility/SpringValue")
local Types = require("../Types")

local useBinding = React.useBinding
local useMemo = React.useMemo
local useEffect = React.useEffect

local function useSpring<T>(props: Types.SpringProperties<T>): (React.Binding<T?>, Types.SpringStart<T>, Types.SpringStop)
	local binding, update = useBinding(props.start)
	local controller = useMemo(function()
		local spring = SpringValue(props.start, props.speed, props.damper)

		return {
			spring = spring,

			start = function(subProps: Types.SpringProperties<T>, immediate: boolean?)
				assert(typeof(subProps) == "table", "useSpring expects a table of properties")

				spring:setImmediate(immediate)

				if subProps.delay then
					spring:setDelay(subProps.delay)
				end

				if subProps.target then
					spring:setGoal(subProps.target)
				end

				if subProps.start then
					spring:setValue(subProps.start)
				end

				if subProps.force then
					spring:impulse(subProps.force)
				end

				if subProps.damper then
					spring:setDamper(subProps.damper)
				end

				if subProps.speed then
					spring:setSpeed(subProps.speed)
				end

				if subProps.target or subProps.start or subProps.force then
					if not spring:playing() then
						spring:run()
					end
				end
			end,

			stop = function()
				if spring:playing() then
					spring:stop()
				end
			end,
		}
	end, {})

	useEffect(function()
		local spring = controller.spring

		return function()
			spring:stop()
		end
	end, {})

	controller.spring:setUpdater(update)

	return binding, controller.start, controller.stop
end

return useSpring
