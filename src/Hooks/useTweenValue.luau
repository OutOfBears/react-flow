local React = require("../../React")
local Tween = require("../Animations/Types/Tween")
local Types = require("../Types")

local useBinding = React.useBinding
local useMemo = React.useMemo
local useEffect = React.useEffect

local function useTweenValue<T>(props: Types.TweenProperties<T>): React.Binding<T?>
	local initial = props.start or props.target
	local binding, update = useBinding(initial)

	local tween = useMemo(function()
		return Tween.new({
			info = props.info,
			start = initial,
			target = props.target,
			delay = props.delay,
		})
	end, {})

	tween:setListener(update)

	useEffect(function()
		return function()
			tween:stop()
		end
	end, {})

	useEffect(function()
		if props.target == nil then
			return
		end

		tween.props.info = props.info or tween.props.info
		tween.props.target = props.target
		tween.props.delay = props.delay
		tween.props.start = binding:getValue()

		tween:play(binding:getValue())
	end, { props.target } :: { any })

	return binding
end

return useTweenValue
