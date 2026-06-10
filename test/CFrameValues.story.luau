local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local packages = ReplicatedStorage.Packages

local ORIGIN = CFrame.new(0, 10, 0)
local LANE_SPACING = 6
local TOGGLE_INTERVAL = 2
local SPRING_CONFIGS = {
	{ name = "Underdamped", color = Color3.fromRGB(255, 120, 120), speed = 6, damper = 0.3, lane = -1 },
	{ name = "CriticallyDamped", color = Color3.fromRGB(120, 255, 160), speed = 6, damper = 1.0, lane = 0 },
	{ name = "Overdamped", color = Color3.fromRGB(120, 180, 255), speed = 6, damper = 1.6, lane = 1 },
}

local function createPart(name: string, color: Color3, cframe: CFrame): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true

	part.CanCollide = false
	part.Size = Vector3.new(3, 3, 3)

	part.Color = color
	part.Material = Enum.Material.Neon

	part.CFrame = cframe

	return part
end

return function(_container)
	local ReactAnimation = ReplicatedStorage.ReactAnimation
	ReactAnimation.Parent = packages

	local SpringValue = require(packages.ReactAnimation.Utility.SpringValue)
	local LinearValue = require(packages.ReactAnimation.Utility.LinearValue)

	local folder = Instance.new("Folder")
	folder.Name = "CFrameValueStory"
	folder.Parent = workspace

	local connections: { RBXScriptConnection } = {}
	local threads: { thread } = {}
	local springs: { any } = {}

	local function laneOrigin(lane: number)
		return ORIGIN * CFrame.new(lane * LANE_SPACING, 0, 0)
	end

	local targetOffsets = {
		CFrame.new(0, 0, 0),
		CFrame.new(0, 6, 0) * CFrame.Angles(0, math.pi / 2, 0),
		CFrame.new(0, 4, 6) * CFrame.Angles(math.pi, 0, math.pi / 3),
		CFrame.new(0, 2, -6) * CFrame.Angles(0, -math.pi, math.pi / 2),
	}

	for _, cfg in SPRING_CONFIGS do
		local origin = laneOrigin(cfg.lane)

		local part = createPart(cfg.name, cfg.color, origin)
		part.Parent = folder

		local spring = SpringValue(part.CFrame, cfg.speed, cfg.damper)
		spring:setUpdater(function(cframe: CFrame)
			part.CFrame = cframe
		end)

		spring:run()

		table.insert(springs, spring)
		table.insert(
			threads,
			task.spawn(function()
				local index = 1

				while true do
					spring:setGoal(origin * targetOffsets[index])

					if not spring:playing() then
						spring:run()
					end

					index = (index % #targetOffsets) + 1
					task.wait(TOGGLE_INTERVAL)
				end
			end)
		)
	end

	local linearOrigin = laneOrigin(2.5)
	local linearPart = createPart("LinearLerp", Color3.fromRGB(255, 220, 120), linearOrigin)

	local linearStart = LinearValue(linearOrigin)
	local linearGoal = LinearValue(linearOrigin * CFrame.new(0, 6, 0) * CFrame.Angles(math.pi, math.pi / 2, 0))

	local clock = 0
	local lerpConnection = RunService.Heartbeat:Connect(function(dt: number)
		clock += dt

		local alpha = (math.sin(clock * 1.5) + 1) / 2
		linearPart.CFrame = linearStart:lerp(linearGoal, alpha):toValue()
	end)

	table.insert(connections, lerpConnection)

	return function()
		for _, conn in connections do
			conn:Disconnect()
		end

		for _, thread in threads do
			task.cancel(thread)
		end

		for _, spring in springs do
			spring:destroy()
		end

		folder:Destroy()
		ReactAnimation.Parent = ReplicatedStorage
	end
end
