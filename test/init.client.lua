local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage:WaitForChild("Packages")
ReplicatedStorage.ReactAnimation.Parent = Packages

local Test = require(script.Test)

local Roact = require(Packages.Roact)
local createElement = Roact.createElement
local mount = Roact.mount

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
	task.wait(4)
end

mount(createElement("ScreenGui", {}, { Test = createElement(Test) }), LocalPlayer:WaitForChild("PlayerGui"))
