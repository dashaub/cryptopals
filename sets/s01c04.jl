include("s01c03.jl")

using DataFrames

solutions = DataFrame()
for ciphertext in readlines(open("4.txt"))
    println(ciphertext)
    decrypted = crack_single_xor(ciphertext)
    append!(solutions, decrypted)
end

first(sort(solutions, :loss), 5)
