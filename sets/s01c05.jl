import Base64

plaintext = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"
encoded = [UInt8(x) for x in plaintext]
key = [UInt8(x) for x in "ICE"]

ciphertext = Array{UInt8,1}()
for i in 1:length(encoded)
    key_ind = 1 + (i - 1) % length(key)
    encrypted = xor(encoded[i], key[key_ind])
    append!(ciphertext, xor(encoded[i], key[key_ind]))
end
actual = bytes2hex(ciphertext)

expected = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

@assert actual == expected
