type MixedArray = { [string | number]: any } | { any }

local function deepCopy<T>(tbl: T): T
	local new = table.clone(tbl :: any)

	for key, value in tbl :: any do
		if type(value) == "table" then
			new[key] = deepCopy(value)
		end
	end

	return (new :: any) :: T
end

return {
	deepCopy = deepCopy,
}
