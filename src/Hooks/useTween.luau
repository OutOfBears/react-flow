local React = require("../../React")
local Tween = require("../Animations/Types/Tween")

local useMemo = React.useMemo
local useEffect = React.useEffect
local useBinding = React.useBinding

type TweenStart<T> = (subProps: Tween.TweenProperties<T>, immediate: boolean?) -> ()
type TweenStop = () -> ()

local function useTween<T>(props: Tween.TweenProperties<T>): (React.Binding<T?>, TweenStart<T>, TweenStop)
	local binding, update = useBinding(props.start)

	local controller = useMemo(function()
		local tween = Tween.new(props)

		return {
			tween = tween,

			start = function(subProps: Tween.TweenProperties<T>, immediate: boolean?)
				assert(typeof(subProps) == "table", "useTween expects a table of properties")

				tween.props.info = subProps.info or tween.props.info
				tween.props.start = subProps.start or binding:getValue()
				tween.props.target = subProps.target or tween.props.target
				tween.props.startImmediate = subProps.startImmediate or tween.props.startImmediate
				tween.props.delay = subProps.delay or tween.props.delay
				tween:Play(subProps.start or binding:getValue(), immediate)
			end :: TweenStart<T>,

			stop = function()
				tween:Stop()
			end :: TweenStop,
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
