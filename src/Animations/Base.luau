local BaseAnimation = {}

function BaseAnimation.new()
	local self = {}

	self.listener = nil
	self.SetListener = function(_, listener: (any) -> ())
		self.listener = listener
	end

	return self
end

return BaseAnimation
