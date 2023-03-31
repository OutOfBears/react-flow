local TweenService = game:GetService("TweenService")

local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef
local useState = Roact.useState
local useEffect = Roact.useEffect
local useMemo = Roact.useMemo

local LinearValue = require(script.Parent.Parent.Utility.LinearValue)
type LinearValue = typeof(LinearValue)

local function useTween(initial: LinearValue.LinearValueType, tweenInfo: TweenInfo)
	local initialRef = useRef()
	local goalRef = useRef()
	local tweenRef = useRef()

	local current, setState = useState(function()
		return LinearValue.fromValue(initial)
	end)

	local numberValue = useMemo(function()
		return Instance.new("NumberValue")
	end, {})

	useEffect(function()
		local connection = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			setState(initialRef.current:Lerp(goalRef.current, numberValue.Value))
		end)

		return function()
			if tweenRef.current then
				tweenRef.current:Cancel()
				tweenRef.current = nil
			end

			connection:Disconnect()
		end
	end, {})

	return current:ToValue(),
		function(animation: {
			start: LinearValue.LinearValueType?,
			goal: LinearValue.LinearValueType?,
		})
			local startValue = animation.start
			local endValue = animation.goal

			if not endValue or (goalRef.current and goalRef.current:ToValue() == endValue) then
				return
			end

			if not startValue then
				startValue = current:ToValue()
			end

			if tweenRef.current then
				tweenRef.current:Cancel()
			end

			initialRef.current = LinearValue.fromValue(startValue)
			goalRef.current = LinearValue.fromValue(endValue)

			numberValue.Value = 0

			tweenRef.current = TweenService:Create(numberValue, tweenInfo, { Value = 1 })
			tweenRef.current:Play()
		end,
		function()
			if tweenRef.current then
				tweenRef.current:Cancel()
				tweenRef.current = nil
			end
		end
end

return useTween
