export type BaseAnimation = {
	listener: ((any) -> ())?,
	setListener: (BaseAnimation, (any) -> ()?) -> (),
}

local function setListener(self: BaseAnimation, callback: ((any) -> ())?)
	self.listener = callback
end

local function BaseAnimation()
	local object = {}

	object.listener = nil
	object.setListener = setListener

	return object
end

return {
	new = BaseAnimation,
}
