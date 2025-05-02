local TableUtil = require(script.Parent.TableUtil)

local function updateReactChild(child)
	local cloned = TableUtil.deepCopy(child)
	cloned.type = child.type

	return cloned
end

return {
	updateReactChild = updateReactChild,
}
