import Base64
"""
Convert a hex string into a base64 string.
"""
function hex_to_base64(x::String)::String
    return Base64.base64encode(hex2bytes(x))
end

test_input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
@assert hex_to_base64(test_input) == expected
