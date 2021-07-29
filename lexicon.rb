require 'net/http'
require 'json'

class Lexicon 
    def initialize
        @raw = JSON.parse(
            Net::HTTP.get('sajemtan.github.io', '/lexicon.js')
                .split("var lexicon =")[1]
                .split("};")[0] +
                "}"
        )
    end

    def define(str)
        result = []
        @raw.each { |catname, category|
            category.each { |entryname, entry|
                if entry.class == Array and entryname == str
                    result << [catname, entry]
                    # "**(#{catname})** #{format_def(entry)}"
                elsif entry.class == Hash
                    entry.each { |subentname, subentry|
                        if subentname == str
                            result << ["#{catname} > #{entryname}", subentry]
                            # "**(#{catname} > #{entryname})** #{format_def(subentry)}"
                        end
                    }
                end
            }
        }

        result

        # if result.length > 0
        #     "__**#{str}**__\n\n#{result.join "\n"}"
        # else
        #     "No results found for #{str}"
        # end
    end

    def define_formatted(str)
        format_entry_array(str, define(str))
    end
end

def format_entry(pos, data)
    result = []

    data.each { |e|
        if e.class == String
            result << e
        elsif e.class == Array
            case e[0]
                when "archaic"
                    result << "*archaic, see:* #{e[1]}"
                when "see also"
                    result << "*see also:* **#{e[1]}**"
                when "example"
                    result << "*example:* #{e[1]} (#{e[2]})"
                when "suf-example"
                    result << "*example:* #{e[1]} \u2192 #{e[2]}"
            end
        end
    }

    "**(#{pos})** #{result.join "; "}"
end

def format_entry_array(str, data)
    if data.empty?
        "No results found for #{str}"
    else
        "__**#{str}**__\n\n#{data.map {|e| format_entry(*e)}.join "\n"}"
    end
end
