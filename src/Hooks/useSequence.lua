local Roact = require(script.Parent.Parent.Roact)
local useRef = Roact.useRef

local Animation = require(script.Parent.Parent.Animation)
export type Animation = typeof(Animation)

local function makeSequence(animations: { [string]: Animation })
	local currentSequence

	return {
		play = function(data: { reverse: boolean }?)
			local reverse = data and data.reverse
			local nonce = tick()
			currentSequence = nonce

			for _, animation in animations do
				animation.useStart.current = true

				task.delay(animation.timeStep or 0, function()
					if currentSequence == nonce then
						animation.useStart.current = false
						animation[reverse and "playReverse" or "play"]()
					end
				end)
			end
		end,

		stop = function()
			currentSequence = nil
			for _, animation in animations do
				animation.stop()
			end
		end,
	}
end

local function useSequence(animations: { [string]: Animation })
	local sequence = {}
	local sequenceRef = useRef()
	local currentSequence = sequenceRef.current

	if not currentSequence then
		currentSequence = makeSequence(animations)
		sequenceRef.current = currentSequence
	end

	for name, animation in animations do
		animation.useStart = useRef(true)
		sequence[name] = animation.useStart.current and animation.start or animation.value
	end

	return sequence, currentSequence.play, currentSequence.stop
end

return useSequence
