local React = require(script.Parent.Parent.React)
local useRef = React.useRef
local createBinding = React.createBinding

local Spring = require(script.Parent.Parent.Animations.Types.Spring)

local function useSpring(props: Spring.SpringProperties)
	local controller = useRef()
	local spring = controller.current

	local binding, update = createBinding(props.start)

	if not spring then
		local newController = Spring.new(props)

		spring = {
			controller = newController,

			start = function(subProps: Spring.SpringProperties)
				newController.props.target = subProps.target or newController.props.target
				newController.props.speed = subProps.speed or newController.props.speed
				newController.props.damper = subProps.damper or newController.props.damper
				newController:Play(subProps.start or binding:getValue(), subProps.force)
			end,

			stop = function()
				newController:Stop()
			end,
		}

		controller.current = spring
	end

	spring.controller:SetListener(update)

	return binding, spring.start, spring.stop
end

return useSpring
