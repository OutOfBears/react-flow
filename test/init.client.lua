local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage:WaitForChild("Packages")
ReplicatedStorage.ReactAnimation.Parent = Packages

local Test = require(script.Test)

local React = require(Packages.React)
local createElement = React.createElement
local mount = React.mount

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
	task.wait(4)
end

mount(createElement("ScreenGui", {}, { Test = createElement(Test) }), LocalPlayer:WaitForChild("PlayerGui"))
