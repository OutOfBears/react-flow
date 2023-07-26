local React = require(script.Parent.Parent.React)
local useRef = React.useRef
local useBinding = React.useBinding

local SpringValue = require(script.Parent.Parent.Utility.SpringValue)
local Spring = require(script.Parent.Parent.Animations.Types.Spring)

local function useSpring(props: Spring.SpringProperties)
	local controller = useRef()
	local spring = controller.current

	local binding, update = useBinding(props.start)

	if not spring then
		local newController = SpringValue.new(props.start, props.speed, props.damper)

		spring = {
			controller = newController,

			start = function(subProps: Spring.SpringProperties)
				assert(typeof(subProps) == "table", "useSpring expects a table of properties")

				if subProps.target then
					newController:SetGoal(subProps.target)
				end

				if subProps.start then
					newController:SetValue(subProps.start)
				end

				if subProps.force then
					newController:Impulse(subProps.force)
				end

				if subProps.damper then
					newController:SetDamper(subProps.damper)
				end

				if subProps.speed then
					newController:SetSpeed(subProps.speed)
				end

				if subProps.target or subProps.start or subProps.force then
					if not newController:Playing() then
						newController:Run()
					end
				end
			end,

			stop = function()
				if newController:Playing() then
					newController:Stop()
				end
			end,
		}

		controller.current = spring
	end

	spring.controller:SetUpdater(update)

	return binding, spring.start, spring.stop
end

return useSpring
