local EPSILON = 1e-2

local React = require("../React")
local Types = require("../Types")

local useBindings = require("./useBindings")
local useBinding = React.useBinding

local function modifyNumberTransparency(modifier: number, transparency: number): number
	local value = 1 - ((1 - transparency) * (1 - modifier))

	-- clamp and round to 0 or 1
	if value < EPSILON then
		return 0
	elseif value > 1 - EPSILON then
		return 1
	end

	return value
end

local function modifyNumberSequenceTransparency(modifier: number, sequence: NumberSequence): NumberSequence
	local newKeypoints = table.create(#sequence.Keypoints)

	for _, keypoint in pairs(sequence.Keypoints) do
		local time = keypoint.Time
		local envelope = keypoint.Envelope
		local value = modifyNumberTransparency(modifier, keypoint.Value)

		table.insert(newKeypoints, NumberSequenceKeypoint.new(time, value, envelope))
	end

	return NumberSequence.new(newKeypoints)
end

local function useTransparencyModifier(modifier: Types.Binding): (Types.TransparencyValue) -> Types.TransparencyValue
	return function(transparency: Types.TransparencyValue): Types.Binding
		local isTransparencyBinding = type(transparency) == "table" and transparency.getValue
		local baseTransparency = isTransparencyBinding and (transparency :: Types.Binding):getValue() or transparency or 0

		local emptyBinding = useBinding(nil)
		local modifiedTransparency, updateModifiedTransparency = useBinding(baseTransparency)

		useBindings(function(modifierValue, transparencyValue)
			transparencyValue = transparencyValue or baseTransparency

			if modifierValue then
				local modifierFunction = typeof(transparencyValue) == "number" and modifyNumberTransparency
					or modifyNumberSequenceTransparency

				updateModifiedTransparency(modifierFunction(modifierValue, transparencyValue))
			else
				updateModifiedTransparency(transparencyValue)
			end
		end, { modifier or emptyBinding, isTransparencyBinding and transparency or emptyBinding }, {
			baseTransparency,
		})

		return modifiedTransparency
	end
end

return useTransparencyModifier
