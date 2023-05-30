local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local createElement = React.createElement
local mount, unmount = React.mount, React.unmount

return function(container)
	local ReactAnimation = ReplicatedStorage.ReactAnimation
	ReactAnimation.Parent = Packages

	local Test = require(script.Parent.Test)
	local root = mount(createElement(Test), container)

	return function()
		unmount(root)
		ReactAnimation.Parent = ReplicatedStorage
	end
end
