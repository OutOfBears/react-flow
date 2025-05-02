local function deepCopy<T>(tbl: T): T
	if type(tbl) ~= "table" then
		return tbl
	end

	local copy = {}

	for key, value in tbl do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end

	return (copy :: any) :: T
end

return {
	deepCopy = deepCopy,
}
