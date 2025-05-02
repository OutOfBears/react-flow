local React = require(script.Parent.Parent.React)
local ReactUtil = require(script.Parent.Parent.Utility.ReactUtil)

local createElement = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local memo = React.memo

local function DynamicList(props: { children: {} })
	local children = props.children
	local list, setList = useState({})

	useEffect(function()
		setList(function(prevState)
			local state = table.clone(prevState)

			for key, child in children do
				state[key] = ReactUtil.updateReactChild(child)
			end

			for key, child in state do
				if children[key] then
					continue
				end

				child.props.remove = true
				child.props.destroy = function()
					setList(function(currentState)
						local clonedState = table.clone(currentState)
						clonedState[key] = nil
						return clonedState
					end)
				end

				state[key] = ReactUtil.updateReactChild(child)
			end

			return state
		end)
	end, { children })

	return createElement(React.Fragment, {}, list)
end

return memo(DynamicList)
