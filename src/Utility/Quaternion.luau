function fromMatrix(
	m00: number, m01: number, m02: number,
	m10: number, m11: number, m12: number,
	m20: number, m21: number, m22: number
): (number, number, number, number)
	local trace = m00 + m11 + m22

	if trace > 0 then
		local s = math.sqrt(trace + 1) * 2
		return (m21 - m12) / s, (m02 - m20) / s, (m10 - m01) / s, 0.25 * s
	elseif m00 > m11 and m00 > m22 then
		local s = math.sqrt(1 + m00 - m11 - m22) * 2
		return 0.25 * s, (m01 + m10) / s, (m02 + m20) / s, (m21 - m12) / s
	elseif m11 > m22 then
		local s = math.sqrt(1 + m11 - m00 - m22) * 2
		return (m01 + m10) / s, 0.25 * s, (m12 + m21) / s, (m02 - m20) / s
	else
		local s = math.sqrt(1 + m22 - m00 - m11) * 2
		return (m02 + m20) / s, (m12 + m21) / s, 0.25 * s, (m10 - m01) / s
	end
end

local function canonicalize(qx: number, qy: number, qz: number, qw: number): (number, number, number, number)
	if qw < 0 then
		return -qx, -qy, -qz, -qw
	end

	return qx, qy, qz, qw
end

return {
	fromMatrix = fromMatrix,
	canonicalize = canonicalize,
}
