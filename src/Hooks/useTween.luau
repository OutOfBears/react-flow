local React = require("../../React")
local Tween = require("../Animations/Types/Tween")
local Types = require("../Types")

local useMemo = React.useMemo
local useEffect = React.useEffect
local useBinding = React.useBinding

local function useTween<T>(props: Types.TweenProperties<T>): (React.Binding<T?>, Types.TweenStart<T>, Types.TweenStop)
	local binding, update = useBinding(props.start)

	local controller = useMemo(function()
		local tween = Tween.new(props)

		return {
			tween = tween,

			start = function(subProps: Types.TweenProperties<T>, immediate: boolean?)
				assert(typeof(subProps) == "table", "useTween expects a table of properties")

				tween.props.info = subProps.info or tween.props.info
				tween.props.start = subProps.start or binding:getValue()
				tween.props.target = subProps.target or tween.props.target
				tween.props.startImmediate = subProps.startImmediate or tween.props.startImmediate
				tween.props.delay = subProps.delay or tween.props.delay
				tween:play(subProps.start or binding:getValue(), immediate)
			end :: Types.TweenStart<T>,

			stop = function()
				tween:stop()
			end :: Types.TweenStop,
		}
	end, {})

	useEffect(function()
		return function()
			controller.stop()
		end
	end, {})

	controller.tween:setListener(update)

	return binding, controller.start, controller.stop
end

return useTween
