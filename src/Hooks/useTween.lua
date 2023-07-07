local React = require(script.Parent.Parent.React)
local useRef = React.useRef
local createBinding = React.createBinding

local Tween = require(script.Parent.Parent.Animations.Types.Tween)

local function useTween<T>(props: Tween.TweenProperties<T>)
	local controller = useRef()
	local tween = controller.current

	local binding, update = createBinding(props.start)

	if not tween then
		local newController = Tween.new(props)

		tween = {
			controller = newController,

			start = function(subProps: Tween.TweenProperties<T>)
				newController.props.info = subProps.info or newController.props.info
				newController.props.start = subProps.start or newController.props.start
				newController.props.target = subProps.target or newController.props.target
				newController.props.immediate = subProps.immediate or newController.props.immediate
				newController.props.delay = subProps.delay or newController.props.delay
				newController:Play(subProps.start or binding:getValue())
			end,

			stop = function()
				newController:Stop()
			end,
		}

		controller.current = tween
	end

	tween.controller:SetListener(update)

	return binding, tween.start, tween.stop
end

return useTween
