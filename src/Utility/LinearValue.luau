local Quaternion = require("./Quaternion")
local Types = require("../Types")

export type LinearValue<T> = {
	ccstr: Types.ValueConstructor<T>,
	values: { number },
	toValue: (LinearValue<T>) -> T,
	lerp: (LinearValue<T>, LinearValue<T>, number) -> LinearValue<T>,
}

local VALUE_CONSTRUCTORS: (...any) -> any = {
	UDim2 = UDim2.new,
	UDim = UDim.new,
	Vector2 = Vector2.new,
	Vector3 = Vector3.new,
	Color3 = Color3.new,
	ColorSequenceKeypoint = ColorSequenceKeypoint.new,
	NumberSequenceKeypoint = NumberSequenceKeypoint.new,
	NumberRange = NumberRange.new,
	PhysicalProperties = PhysicalProperties.new,
	BrickColor = BrickColor.new,
	CFrame = CFrame.new,
}

local VALUE_DECONSTRUCTORS = {
	number = function(value: number)
		return value
	end,
	UDim2 = function(value: UDim2)
		return value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset
	end,
	UDim = function(value: UDim)
		return value.Scale, value.Offset
	end,
	Vector2 = function(value: Vector2)
		return value.X, value.Y
	end,
	Vector3 = function(value: Vector3)
		return value.X, value.Y, value.Z
	end,
	Color3 = function(value: Color3)
		return value.R, value.G, value.B
	end,
	ColorSequenceKeypoint = function(value: ColorSequenceKeypoint)
		return value.Time, value.Value
	end,
	NumberSequenceKeypoint = function(value: NumberSequenceKeypoint)
		return value.Time, value.Value, value.Envelope
	end,
	NumberRange = function(value: NumberRange)
		return value.Min, value.Max
	end,
	PhysicalProperties = function(value: PhysicalProperties)
		return value.Density, value.Friction, value.Elasticity
	end,
	BrickColor = function(value: BrickColor)
		return value.Color.R, value.Color.G, value.Color.B
	end,
	CFrame = function(value: CFrame)
		local x, y, z, m00, m01, m02, m10, m11, m12, m20, m21, m22 = value:GetComponents()
		local qx, qy, qz, qw = Quaternion.canonicalize(Quaternion.fromMatrix(m00, m01, m02, m10, m11, m12, m20, m21, m22))
		return x, y, z, qx, qy, qz, qw
	end,
}

local LinearValue

local function resolveFromLinearValue<T>(ccstr: Types.ValueConstructor<T>?, values: { number }): T
	if ccstr then
		return ccstr(unpack(values))
	end

	return unpack(values)
end

local function toValue<T>(self: LinearValue<T>)
	return resolveFromLinearValue(self.ccstr, self.values)
end

local function lerp<T>(self: LinearValue<T>, other: LinearValue<T>, alpha: number)
	local values = {}

	for i = 1, #self.values do
		values[i] = math.lerp(self.values[i], other.values[i], alpha)
	end

	return LinearValue(resolveFromLinearValue(self.ccstr, values))
end

function LinearValue<T>(value: T): LinearValue<T>
	local object: LinearValue<T> = {}

	local valueType = typeof(value)
	local deconstructor = VALUE_DECONSTRUCTORS[valueType]

	object.values = deconstructor and { deconstructor(value) }
	object.ccstr = VALUE_CONSTRUCTORS[valueType]

	if not object.values then
		error(`Unsupported type: {valueType}`, 2)
	end

	object.toValue = toValue
	object.lerp = lerp

	table.freeze(object)

	return object
end

return LinearValue
