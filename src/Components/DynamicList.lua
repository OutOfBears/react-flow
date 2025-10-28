local React = require(script.Parent.Parent.React)
local ReactUtil = require(script.Parent.Parent.Utility.ReactUtil)

local createElement = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local memo = React.memo
local cloneElement = React.cloneElement

-- DynamicList reconciles a dictionary of keyed children.
-- Fixes: previous code wrapped ALL children with removal props each render causing churn & potential loops.
-- Strategy: only wrap children flagged for removal; avoid mutating props; bail out when no change.
local function DynamicList(props: { children: {} })
	local children = props.children
	local list, setList = useState({})

	useEffect(function()
		setList(function(prevState)
			local nextState = table.clone(prevState)
			local changed = false

			-- Add or update active children
			for key, child in children do
				local updated = ReactUtil.updateReactChild(child)
				if nextState[key] ~= updated then
					nextState[key] = updated
					changed = true
				end
			end

			-- Handle removals: mark existing entries not in children
			for key, existing in nextState do
				if children[key] == nil and existing ~= nil then
					if not (existing.props and existing.props.remove) then
						local wrapped = cloneElement(existing, {
							remove = true,
							destroy = function()
								setList(function(currentState)
									local cloned = table.clone(currentState)
									cloned[key] = nil
									return cloned
								end)
							end,
						})
						nextState[key] = ReactUtil.updateReactChild(wrapped)
						changed = true
					end
				end
			end

			if changed then
				return nextState
			end
			return prevState
		end)
	end, { children })

	return createElement(React.Fragment, {}, list)
end

return memo(DynamicList)
