local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef

local Animation = require(script.Parent.Parent.Animation)
export type Animation = typeof(Animation)

local function useSequence(animations: { [string]: Animation })
	local sequence = {}
	local runningRef = useRef()

	for name, animation in animations do
		sequence[name] = animation.value
	end

	return sequence,
		function()
			local nonce = tick()
			runningRef.current = nonce

			for _, animation in animations do
				task.delay(animation.timeStep or 0, function()
					if runningRef.current == nonce then
						animation.play()
					end
				end)
			end
		end,
		function()
			runningRef.current = nil
			for _, animation in animations do
				animation.stop()
			end
		end
end

local function Component(props)
	local sequence, play = useSequence({
		disappear = Animation("Spring", 0, { start = 0, goal = 1, speed = 20, damper = 1 }),
		test = Animation("Tween", 0.1, { start = 0, goal = 1, tweenInfo = TweenInfo.new(1) }),
	})

	play()
end

return useSequence
