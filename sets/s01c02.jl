"""
Perform xor on two byte arrays.
"""
function string_xor(x::Array{UInt8,1}, y::Array{UInt8,1})::Array{UInt8,1}
    return xor.(x, y)
end

str_1 = "1c0111001f010100061a024b53535009181c"
str_2 = "686974207468652062756c6c277320657965"
expected = "746865206b696420646f6e277420706c6179"

@assert string_xor(hex2bytes(str_1), hex2bytes(str_2)) == hex2bytes(expected)
@assert string_xor(hex2bytes(str_2), hex2bytes(str_1)) == hex2bytes(expected)
