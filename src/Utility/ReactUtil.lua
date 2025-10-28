-- ReactUtil provides lightweight helpers for dealing with React element descriptors.
-- Deep copying a React element (as previously done) can erase Luau's refined type info
-- and produce 'unknown' for consumers. For reconciliation we only need to ensure
-- that a new table reference exists when we conceptually changed props.

local function updateReactChild(child: any)
	-- If child is nil or not a table, just return it.
	if type(child) ~= "table" then
		return child
	end

	-- Shallow copy preserves element shape and keeps type field intact.
	local cloned = {}
	for k, v in child do
		cloned[k] = v
	end
	return cloned
end

return {
	updateReactChild = updateReactChild,
}
