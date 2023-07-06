local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage:WaitForChild("Packages")
ReplicatedStorage.ReactAnimation.Parent = Packages

local Test = require(script.Test)

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local createElement = React.createElement

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
	task.wait(4)
end

local root = ReactRoblox.createRoot(LocalPlayer:WaitForChild("PlayerGui"))
root:render(createElement("ScreenGui", {}, { Test = createElement(Test) }))
