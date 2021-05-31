def dup_upcase(array)
    return [*array, *array.map(&:upcase)]
end

def y(str)
    str.gsub(/[aeiou]/, "y").gsub(/[AEIOU]/, "Y")
end

@swaps = ["bd", "cg", "ef", "hn", "it", "jl", "mw", "oq", "px", "uv"]

def flt(str)
    str.chars.map { |c|
        ret = c
        for s in dup_upcase(@swaps) do
            if c == s[0] then
                ret = s[1]
                break
            elsif c == s[1] then
                ret = s[0]
                break
            end
        end
        ret
    }.join
end

@keyboard = ["qwertyuiop", "asdfghjkl", "zxcvbnm"]

def nkt(offset, str)
    str.chars.map { |c|
        ret = c

        for line in dup_upcase(@keyboard) do
            if (i = line.index c) then
                ret = line[(i + offset) % line.length]
                break
            end
        end
        ret
    }.join
end
