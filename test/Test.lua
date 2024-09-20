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
local useBindingEffect = ReactAnimation.useBindings
local useAnimation = ReactAnimation.useAnimation
local Spring = ReactAnimation.Spring
local Tween = ReactAnimation.Tween

-- @helpers

local function createFrame(props, children)
	children = children or {}

	props.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(61, 61, 61)

	props.Size = props.Size or UDim2.fromScale(1, 1)
	props.SizeConstraint = Enum.SizeConstraint.RelativeXX
	props.Text = props.Name

	props.Font = props.Font or Enum.Font.GothamBlack
	props.TextSize = props.TextSize or 20
	props.TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255)

	local parentSize = props.ParentSize or UDim2.fromScale(0.1, 0.25)
	props.ParentSize = nil

	children.uiStroke = createElement("UIStroke", {
		Thickness = 2,
		Color = Color3.fromRGB(58, 58, 58),
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	children.uiCorner = createElement("UICorner", {
		CornerRadius = UDim.new(0, 8),
	})

	return createElement("Frame", {
		Size = parentSize,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
	}, {
		content = createElement("TextLabel", props, children),
	})
end

-- @tests

-- @TestAnimation

local function TestAnimation()
	local sequence, play, stop = useGroupAnimation({
		moveRight = useAnimation({
			position = Spring({
				target = UDim2.fromScale(0.8, 0),
				speed = 5,
				damper = 0.7,
			}),
		}),

		moveLeft = useAnimation({
			position = Spring({
				target = UDim2.fromScale(0.3, 0),
				speed = 5,
				damper = 0.7,
			}),
		}),
	}, {
		size = UDim2.fromOffset(200, 200),
		position = UDim2.fromScale(0.5, 0),
	})

	useEffect(function()
		local running = true
		local thread = task.spawn(function()
			while running do
				play("moveLeft")
				task.wait(2)
				play("moveRight")
				task.wait(2)
			end
		end)

		return function()
			running = false
			task.cancel(thread)
			stop()
		end
	end, {})

	return createFrame({
		Name = "Animation Group",
		Position = sequence.position,
		Size = sequence.size,
		ParentSize = UDim2.fromScale(1, 0.25),
	})
end

-- @TestSequence
local function TestSequence()
	local sequence, play, stop = useGroupAnimation({
		yo = useSequenceAnimation({
			{
				timestamp = 0,
				size = Tween({
					target = UDim2.fromOffset(200, 200),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
			{
				timestamp = 1,
				position = Tween({
					target = UDim2.fromScale(0.2, 0),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),

				size = Tween({
					target = UDim2.fromOffset(400, 400),
					info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
			{
				timestamp = 2,
				size = Tween({
					target = UDim2.fromOffset(100, 100),
					info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
				position = Tween({
					target = UDim2.fromScale(0.8, 0),
					info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
			{
				timestamp = 2.5,
				size = Tween({
					target = UDim2.fromOffset(200, 200),
					info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
				position = Tween({
					target = UDim2.fromScale(0.5, 0),
					info = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				}),
			},
		}),
	}, {
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromOffset(200, 200),
	})

	useEffect(function()
		local running = true
		local thread = task.spawn(function()
			while running do
				play("yo")
				task.wait(3)
			end
		end)

		return function()
			running = false
			task.cancel(thread)
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

	useBindingEffect(function(v)
		if v.X.Scale == 0 then
			update({ target = UDim2.fromScale(1, 0) })
		elseif (v :: UDim2).X.Scale == 1 then
			update({ target = UDim2.fromScale(0, 0) })
		end
	end, { value }, {})

	useBindingEffect(function(v2)
		if v2.R == 0 then
			update2({ start = Color3.new(0, 1, 9), target = Color3.new(1, 0, 0) })
		elseif v2.R == 1 then
			update2({ target = Color3.new(0, 1, 0) })
		end
	end, { value2 }, {})

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
		local thread = task.spawn(function()
			while running do
				update({ target = UDim2.fromScale(1, 0) })
				task.wait(3)

				if not running then
					break
				end

				update({ target = UDim2.fromScale(-1, 0) })
				task.wait(3)
			end
		end)

		return function()
			running = false
			task.cancel(thread)
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
		animation = createElement(TestAnimation),
	})
end

return Test
