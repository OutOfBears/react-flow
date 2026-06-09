local React = require("../../React")
local SpringValue = require("../Utility/SpringValue")
local Spring = require("../Animations/Types/Spring")

local useBinding = React.useBinding
local useMemo = React.useMemo
local useEffect = React.useEffect

type SpringStart<T> = (subProps: Spring.SpringProperties<T>, immediate: boolean?) -> ()
type SpringStop = () -> ()

local function useSpring<T>(props: Spring.SpringProperties<T>): (React.Binding<T?>, SpringStart<T>, SpringStop)
	local binding, update = useBinding(props.start)
	local controller = useMemo(function()
		local spring = SpringValue.new(props.start, props.speed, props.damper)

		return {
			spring = spring,

			start = function(subProps: Spring.SpringProperties<T>, immediate: boolean?)
				assert(typeof(subProps) == "table", "useSpring expects a table of properties")

				spring:SetImmediate(immediate)

				if subProps.delay then
					spring:SetDelay(subProps.delay)
				end

				if subProps.target then
					spring:SetGoal(subProps.target)
				end

				if subProps.start then
					spring:SetValue(subProps.start)
				end

				if subProps.force then
					spring:Impulse(subProps.force)
				end

				if subProps.damper then
					spring:SetDamper(subProps.damper)
				end

				if subProps.speed then
					spring:SetSpeed(subProps.speed)
				end

				if subProps.target or subProps.start or subProps.force then
					if not spring:Playing() then
						spring:Run()
					end
				end
			end,

			stop = function()
				if spring:Playing() then
					spring:Stop()
				end
			end,
		}
	end, {})

	useEffect(function()
		local spring = controller.spring

		return function()
			spring:Stop()
		end
	end, {})

	controller.spring:SetUpdater(update)

	return binding, controller.start, controller.stop
end

return useSpring
