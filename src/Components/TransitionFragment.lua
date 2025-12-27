local React = require(script.Parent.Parent.React)
local ReactUtil = require(script.Parent.Parent.Utility.ReactUtil)

local createElement = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local memo = React.memo
local cloneElement = React.cloneElement

local function TransitionFragment(props: React.ElementProps<any>)
	local children = props.children or {}
	local transitionChildren, updateTransitionChildren = useState({} :: { [any]: React.ReactElement<any> })

	useEffect(function()
		updateTransitionChildren(function(prevState)
			local nextState = table.clone(prevState)
			local hasChanges = false

			-- Add or update active children
			for key, child in children do
				local updated = ReactUtil.updateReactChild(child)
				if nextState[key] == nil then
					-- Newly added: mark as entering
					local wrapped = cloneElement(updated, {
						entering = true,
						exiting = false,
						onEnterComplete = function()
							updateTransitionChildren(function(currentState)
								local cloned = table.clone(currentState)
								local currentChild = cloned[key]

								if currentChild then
									cloned[key] = cloneElement(currentChild, { entering = false })
								end

								return cloned
							end)
						end,
						onExitComplete = function() end,
					})

					nextState[key] = ReactUtil.updateReactChild(wrapped)
					hasChanges = true
				elseif nextState[key] ~= updated then
					nextState[key] = updated
					hasChanges = true
				end
			end
			-- Handle removals: mark existing entries not in children
			for key, newChild in nextState do
				if children[key] == nil and newChild ~= nil then
					if not newChild.props or not newChild.props.exiting then
						local wrapped = cloneElement(newChild, {
							entering = false,
							exiting = true,
							onEnterComplete = function() end,
							onExitComplete = function()
								updateTransitionChildren(function(currentState)
									local cloned = table.clone(currentState)
									cloned[key] = nil

									return cloned
								end)
							end,
						})

						nextState[key] = ReactUtil.updateReactChild(wrapped)
						hasChanges = true
					end
				end
			end

			if hasChanges then
				return nextState
			else
				return prevState
			end
		end)
	end, { children })

	return createElement(React.Fragment, {}, transitionChildren :: any)
end

return memo(TransitionFragment)
