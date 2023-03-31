local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)
local useEffect = Roact.useEffect
local createElement = Roact.createElement

local ReactAnimation = require(Packages.RoactAnimation)
local Animation = ReactAnimation.Animation
local useTween = ReactAnimation.useTween
local useSpring = ReactAnimation.useSpring
local useSequence = ReactAnimation.useSequence
local useLatest = ReactAnimation.useLatest

-- @helpers
local function createFrame(props, children)
	props.Size = props.Size or UDim2.fromScale(1, 1)
	props.SizeConstraint = Enum.SizeConstraint.RelativeXX
	props.Text = props.Name

	return createElement("Frame", {
		Size = UDim2.fromScale(0.1, 0.25),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
	}, {
		content = createElement("TextLabel", props, children),
	})
end

-- @tests
-- @TestSequence
local function TestSequence()
	local sequence, play, stop = useSequence({
		position = Animation(
			"Spring",
			0,
			{ start = UDim2.fromScale(-1, 0), goal = UDim2.fromScale(1, 0), speed = 20, damper = 0.7 }
		),

		size = Animation(
			"Tween",
			0.2,
			{ start = UDim2.fromScale(0.5, 0.5), goal = UDim2.fromScale(1.2, 1.2), tweenInfo = TweenInfo.new(1) }
		),
	})

	useEffect(function()
		play()

		return stop
	end, {})

	return createFrame({
		Name = "Sequence",
		Position = sequence.position,
		Size = sequence.size,
	})
end

-- @TestPriority
local function TestPriority()
	local sequence1, play1 = useSequence({
		position = Animation(
			"Spring",
			0,
			{ start = UDim2.fromScale(-1, 0), goal = UDim2.fromScale(1, 0), speed = 20, damper = 0.7 }
		),

		size = Animation(
			"Tween",
			1,
			{ start = UDim2.fromScale(0.5, 0.5), goal = UDim2.fromScale(1.2, 1.2), tweenInfo = TweenInfo.new(1) }
		),
	})

	local sequence2, play2 = useSequence({
		position = Animation(
			"Spring",
			0.1,
			{ start = UDim2.fromScale(1, 0), goal = UDim2.fromScale(-1, 0), speed = 20, damper = 0.7 }
		),

		size = Animation(
			"Tween",
			0.2,
			{ start = UDim2.fromScale(0.7, 0.7), goal = UDim2.fromScale(0.1, 0.1), tweenInfo = TweenInfo.new(1) }
		),
	})

	useEffect(function()
		play1()
		play2()
	end, {})

	return createFrame({
		Name = "Priority",
		Position = useLatest(sequence1.position, sequence2.position),
		Size = useLatest(sequence1.size, sequence2.size),
	})
end

-- @TestTween
local function TestTween()
	local value, update = useTween(UDim2.fromScale(0, 0), TweenInfo.new(1))
	local value2, update2 = useTween(Color3.new(), TweenInfo.new(1))

	if value.X.Scale == 0 then
		update({ goal = UDim2.fromScale(1, 0) })
	elseif (value :: UDim2).X.Scale == 1 then
		update({ goal = UDim2.fromScale(0, 0) })
	end

	if value2.R == 0 then
		update2({ start = Color3.new(1, 0, 0), goal = Color3.new(1, 0, 0) })
	elseif value2.R == 1 then
		update2({ goal = Color3.new(0, 0, 0) })
	end

	return createFrame({
		Name = "Tween",
		Position = value,
		BackgroundColor3 = value2,
	})
end

-- @TestSpring
local function TestSpring()
	local value, update = useSpring(UDim2.fromScale(-1, 0), 10, 0.5)

	useEffect(function()
		local running = true

		task.spawn(function()
			while running do
				update({ goal = UDim2.fromScale(1, 0) })
				task.wait(3)

				if running then
					update({ goal = UDim2.fromScale(-1, 0) })
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
		sequence = createElement(TestSequence),
		priority = createElement(TestPriority),
	})
end

return Test
