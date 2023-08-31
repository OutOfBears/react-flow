local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local React = require(Packages.React)
local useEffect = React.useEffect
local createElement = React.createElement

local ReactAnimation = require(Packages.ReactAnimation)
local useGroupAnimation = ReactAnimation.useGroupAnimation
local useSequenceAnimation = ReactAnimation.useSequenceAnimation
local useSpring = ReactAnimation.useSpring
local useTween = ReactAnimation.useTween
local useBindings = ReactAnimation.useBindings
-- local useAnimation = ReactAnimation.useAnimation
-- local Spring = ReactAnimation.Spring
local Tween = ReactAnimation.Tween

-- @helpers
local RNG = Random.new()

local function createFrame(props, children)
	props.Size = props.Size or UDim2.fromScale(1, 1)
	props.SizeConstraint = Enum.SizeConstraint.RelativeXX
	props.Text = props.Name

	local parentSize = props.ParentSize or UDim2.fromScale(0.1, 0.25)
	props.ParentSize = nil

	return createElement("Frame", {
		Size = parentSize,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
	}, {
		content = createElement("TextLabel", props, children),
	})
end

-- @tests
-- @TestSequence
local function TestSequence()
	-- local sequence, play, stop = useGroupAnimation({
	-- 	moveRight = useAnimation({
	-- 		-- position = Spring({
	-- 		-- 	target = UDim2.fromScale(0.8, 0),
	-- 		-- 	speed = 5,
	-- 		-- 	damper = 0.7,
	-- 		-- }),

	-- 		position = Tween({
	-- 			target = UDim2.fromScale(0.8, 0),
	-- 			info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
	-- 		}),
	-- 	}),

	-- 	moveLeft = useAnimation({
	-- 		-- position = Spring({
	-- 		-- 	target = UDim2.fromScale(0.3, 0),
	-- 		-- 	speed = 5,
	-- 		-- 	damper = 0.7,
	-- 		-- }),

	-- 		position = Tween({
	-- 			target = UDim2.fromScale(0.3, 0),
	-- 			info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
	-- 		}),
	-- 	}),
	-- }, {
	-- 	position = UDim2.fromScale(0.5, 0),
	-- })

	local sequence, play, stop = useGroupAnimation({
		yo = useSequenceAnimation({
			{
				timestamp = 0,
				size = Tween({
					target = UDim2.fromOffset(400, 400),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
			{
				timestamp = 1,
				position = Tween({
					target = UDim2.fromScale(0.3, 0),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
			{
				timestamp = 2,
				position = Tween({
					target = UDim2.fromScale(0.8, 0),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
		}),
	}, {
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromOffset(200, 200),
	})

	useEffect(function()
		local running = true

		task.spawn(function()
			while running do
				play("yo")
				task.wait(3)
			end
		end)

		return function()
			running = false
			stop()
		end
	end, {})

	return createFrame({
		Name = "Sequence",
		Position = sequence.position,
		Size = sequence.size,
		ParentSize = UDim2.fromScale(1, 0.25),
	})
end

-- -- @TestTween
local function TestTween()
	local value, update = useTween({
		info = TweenInfo.new(1),
		start = UDim2.fromScale(0, 0),
	})

	local value2, update2 = useTween({
		info = TweenInfo.new(1),
		start = Color3.new(),
	})

	useBindings(function(v, v2)
		if v.X.Scale == 0 then
			update({ target = UDim2.fromScale(1, 0) })
		elseif (v :: UDim2).X.Scale == 1 then
			update({ target = UDim2.fromScale(0, 0) })
		end

		if v2.R == 0 then
			update2({ start = Color3.new(1, 0, 0), target = Color3.new(1, 0, 0) })
		elseif v2.R == 1 then
			update2({ target = Color3.new(0, 0, 0) })
		end
	end, { value, value2 })

	return createFrame({
		Name = "Tween",
		Position = value,
		BackgroundColor3 = value2,
	})
end

-- -- @TestSpring
local function TestSpring()
	local value, update = useSpring({
		start = UDim2.fromScale(0, 0),
		speed = 5,
		damper = 0.7,
	})

	useEffect(function()
		local running = true

		task.spawn(function()
			while running do
				update({ target = UDim2.fromScale(1, 0) })
				task.wait(3)

				if running then
					update({ target = UDim2.fromScale(-1, 0) })
					task.wait(3)
				end
			end
		end)

		return function()
			running = false
		end
	end, {})

	return createFrame({
		Name = "Spring",
		Position = value,
	})
end

-- @entry
local function Test()
	return createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		uiListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		tween = createElement(TestTween),
		spring = createElement(TestSpring),
		-- sequence = createElement(TestSequence),
	})
end

return Test
