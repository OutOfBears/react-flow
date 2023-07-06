local React = require(script.Parent.Parent.React)
local useRef = React.useRef
local createBinding = React.createBinding

local Spring = require(script.Parent.Parent.Animations.Types.Spring)

local function makeSpring(props: Spring.SpringProperties, updater: (any) -> nil)
	local newSpring = Spring.new(props)
	newSpring:SetListener(updater)

	return newSpring
end

local function useSpring(props: Spring.SpringProperties)
	local controller = useRef()
	local spring = controller.current

	local binding, update = createBinding(props.start)

	if not spring then
		local newController = makeSpring(props, update)
		spring = {
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

	return binding, spring.start, spring.stop
end

return useSpring
