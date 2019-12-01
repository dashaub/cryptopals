using DataFrames

import Random
import StatsBase

eng_digraphs = ["th", "he", "in", "er", "an", "re", "nd", "at", "on",
                "nt", "ha", "es", "st", "en", "ed", "to", "it", "ou",
                "ea", "hi", "is", "or", "ti", "as", "te", "et", "ng",
                "of", "al", "de", "se", "le", "sa", "si", "ar", "ve",
                "ra", "ve", "ra", "ld", "ur"]
eng_trigraphs = ["the", "and", "tha", "ent", "ing", "ion", "tio", "for",
                 "nde", "has", "nce", "edt", "tis", "oft", "sth", "men"]

"""
Find the number of n-gram matches in the text.
"""
function match_ngram(x::String, reference::Array{String,1})::Real
    x = lowercase(x)
    matches = []
    for ngram in reference
        match = length(collect(eachmatch(Regex(ngram), x, overlap=true)))
        append!(matches, match)
    end

    return sum(matches)
end

english_sample = "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way – in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only."
for i in 0:1000
    rand_text = Random.randstring('a':'z', length(english_sample))

    text_bigrams = match_ngram(english_sample, eng_digraphs)
    text_trigrams = match_ngram(english_sample, eng_trigraphs)
    rand_bigrams = match_ngram(rand_text, eng_digraphs)
    rand_trigrams = match_ngram(rand_text, eng_trigraphs)

    @assert text_bigrams >= rand_bigrams
    @assert text_trigrams >= text_trigrams
    @assert text_bigrams >= text_trigrams
    @assert rand_bigrams >= rand_trigrams
end

eng_freq = Dict('a' => 0.08167, 'b' => 0.01492, 'c' => 0.02782,
                'd' => 0.04253, 'e' => 0.12702, 'f' => 0.02228,
                'g' => 0.02015, 'h' => 0.06094, 'i' => 0.06966,
                'j' => 0.00153, 'k' => 0.00772, 'l' => 0.04025,
                'm' => 0.02406, 'n' => 0.06749, 'o' => 0.07507,
                'p' => 0.01929, 'q' => 0.00095, 'r' => 0.05987,
                's' => 0.06327, 't' => 0.09056, 'u' => 0.02758,
                'v' => 0.00978, 'w' => 0.02360, 'x' => 0.00150,
                'y' => 0.01974, 'z' => 0.00074)
corpus = "pg10.txt"

lines = []
eng_freq = Dict{Char,Real}()
for line in readlines(open(corpus))
    line = lowercase(line)
    for char in line
        count = get(eng_freq, char, 0)
        eng_freq[char] = count + 1
    end
end
total = sum(values(eng_freq))
eng_freq = Dict(k => v / total for (k, v) in eng_freq)

"""
Calculate the character similarity between a mapping and reference.
"""
function similarity(x::String, reference::Dict{Char})::Real
    score = 0
    x = lowercase(x)
    text_freq = StatsBase.countmap([c for c in x])
    text_sum = sum(values(text_freq))
    text_freq = Dict(k => text_freq[k] / text_sum for k = keys(text_freq))
    for key in keys(reference)
        score += abs(reference[key] - get(text_freq, key, 0))
    end

    return score
end

for i in 0:10000
    rand_text = Random.randstring('a':'z', length(english_sample))
    @assert similarity(english_sample, eng_freq) < similarity(rand_text, eng_freq)
end

message = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

struct Metrics
   key::UInt8
   loss::Real 
   bigram_score::Real
   trigram_score::Real
   decrypted::String
   
   function Metrics(key, loss, bigram_score, trigram_score, decrypted)
    new(key, loss, bigram_score, trigram_score, decrypted) 
   end   
end

"""
Calculate the candidate solutions from a single xor cipher.
"""
function crack_single_xor(message::String)
    results = DataFrame()
    for key in 0x00:0xff
        message_buffer = hex2bytes(message)
        decrypted = String(xor.(key, message_buffer))
        try
            similarity_score = similarity(decrypted, eng_freq)
            bigram_score = match_ngram(decrypted, eng_digraphs)
            trigram_score = match_ngram(decrypted, eng_trigraphs)
            row = Dict("key" => key, "loss" => similarity_score,
                       "bigram_score" => bigram_score,
                       "trigram_score" => trigram_score,
                       "decrypted" => decrypted)
            append!(results, row)
                       
        catch e
        end
    end
    return sort(results, :loss)
end

res = crack_single_xor(message)
