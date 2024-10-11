local Tween = require(script.Parent.Parent.Animations.Types.Tween)
local React = require(script.Parent.Parent.React)

local useMemo = React.useMemo
local useEffect = React.useEffect
local useBinding = React.useBinding

local function useTween<T>(props: Tween.TweenProperties<T>)
	local binding, update = useBinding(props.start)

	local controller = useMemo(function()
		local tween = Tween.new(props)

		return {
			tween = tween,

			start = function(subProps: Tween.TweenProperties<T>)
				assert(typeof(subProps) == "table", "useTween expects a table of properties")

				tween.props.info = subProps.info or tween.props.info
				tween.props.start = subProps.start or binding:getValue()
				tween.props.target = subProps.target or tween.props.target
				tween.props.immediate = subProps.immediate or tween.props.immediate
				tween.props.delay = subProps.delay or tween.props.delay
				tween:Play(subProps.start or binding:getValue())
			end,

			stop = function()
				tween:Stop()
			end,
		}
	end, {})

	useEffect(function()
		return function()
			controller.stop()
		end
	end, {})

	controller.tween:SetListener(update)

	return binding, controller.start, controller.stop
end

return useTween
