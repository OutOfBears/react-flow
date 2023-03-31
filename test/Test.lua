local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local React = require(Packages.React)
local useEffect = React.useEffect
local createElement = React.createElement

local RoactAnimation = require(Packages.ReactAnimation)
local useTween = RoactAnimation.useTween
local useSpring = RoactAnimation.useSpring

-- @helpers
local function createFrame(props, children)
	props.Size = UDim2.fromScale(1, 1)
	props.SizeConstraint = Enum.SizeConstraint.RelativeXX
	props.Text = props.Name

	return createElement("Frame", {
		Size = UDim2.fromScale(0.1, 0.5),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
	}, {
		content = createElement("TextLabel", props, children),
	})
end

-- @tests
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
	})
end

return Test
