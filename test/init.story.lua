local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local createElement = React.createElement

return function(container)
	local ReactAnimation = ReplicatedStorage.ReactAnimation
	ReactAnimation.Parent = Packages

	local Test = require(script.Parent.Test)
	local root = ReactRoblox.createRoot(container)
	root:render(createElement(Test))

	return function()
		ReactAnimation.Parent = ReplicatedStorage
		root:unmount()
	end
end
