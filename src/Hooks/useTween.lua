local TweenService = game:GetService("TweenService")

local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef
local useState = Roact.useState
local useEffect = Roact.useEffect

local LinearValue = require(script.Parent.Parent.Utility.LinearValue)
type LinearValue = typeof(LinearValue)

local function makeTween(updateState: (any) -> (), initial: LinearValue.LinearValueType, tweenInfo: TweenInfo)
	local start, goal, tween
	local current = LinearValue.fromValue(initial)

	local value = Instance.new("NumberValue")
	value:GetPropertyChangedSignal("Value"):Connect(function()
		current = start:Lerp(goal, value.Value)
		updateState(current:ToValue())
	end)

	return {
		destroy = function()
			value:Destroy()
		end,

		play = function(animation: {
			start: LinearValue.LinearValueType?,
			goal: LinearValue.LinearValueType?,
		})
			local startValue = animation.start
			local endValue = animation.goal

			local currentValue = current:ToValue()

			if startValue == currentValue and endValue == currentValue then
				return
			end

			if not startValue then
				startValue = currentValue
			end

			if tween then
				tween:Cancel()
			end

			start = LinearValue.fromValue(startValue)
			goal = LinearValue.fromValue(endValue)

			value.Value = 0

			tween = TweenService:Create(value, tweenInfo, { Value = 1 })
			tween:Play()
		end,

		stop = function()
			if tween then
				tween:Cancel()
				tween = nil
			end
		end,
	}
end

local function useTween(initial: LinearValue.LinearValueType, tweenInfo: TweenInfo)
	local current, setState = useState(initial)

	local tweenRef = useRef()
	local currentTweenRef = tweenRef.current

	if not currentTweenRef then
		currentTweenRef = makeTween(setState, initial, tweenInfo)
		tweenRef.current = currentTweenRef
	end

	useEffect(function()
		return function()
			local currentTween = tweenRef.current
			if currentTween then
				currentTween:destroy()
				tweenRef.current = nil
			end
		end
	end, {})

	return current, currentTweenRef.play, currentTweenRef.stop
end

return useTween
