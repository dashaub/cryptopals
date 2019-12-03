import BitBasis

using DataFrames

p1 = "this is a test"
p2 = "wokka wokka!!!"
t1 = map(UInt8, collect(p1))
t2 = map(UInt8, collect(p2))

@assert sum(BitBasis.bdistance.(t1, t2)) == 37

ciphertext = join(i for i in eachline(open("6.txt")))
ciphertext_bytes = Base64.base64decode(ciphertext)

df = DataFrame()
num_blocks = 32
key_sizes = 2:40
for k in key_sizes
    block1 = ciphertext_bytes[1:num_blocks*k]
    block2 = ciphertext_bytes[(1 + num_blocks*k):(2*num_blocks*k)]
    norm_dist = sum(BitBasis.bdistance.(block1, block2)) / k
    edit_distance = Dict("key_size" => k, "edit_distance" => norm_dist)
    append!(df, edit_distance)
end
sort!(df, :edit_distance)
best_k = first(df)[:key_size]
