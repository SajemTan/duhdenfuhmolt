require 'discordrb'
require 'yaml'

require './ortho.rb'
require './lexicon.rb'

bot = Discordrb::Commands::CommandBot.new token: File.read("Token").strip, prefix: "dfr!"

@lists = Hash.new { |hash, key| File.readlines("lists/#{key}") }
@blacklist = File.readlines("blacklist").to_set.map {|x| x.to_i}
@reactions = YAML.load_file("reactions").map {|k, v| [Regexp.new(k), v]}
@lexicon = Lexicon.new

def listsub(str)
    str.gsub(/(\{.+\})/) { |m|
        @lists[m[1..-2]].sample
    }
end

bot.ready { |event|
    Thread.new {
        while true do
            bot.update_status "online", "with a pile of #{@lists[:pasta].sample.capitalize}", nil
            sleep 90
        end
    }
}

bot.message { |event|
    if !@blacklist.include?(event.channel.id)
        text = event.message.text

        @reactions.each { |k, v|
            if text.match?(k)
                event.respond listsub(v)
            end
        }
    end

    event.message.text.match(/\[\[(.+)\]\]/) { |data|
        unless (d = @lexicon.define $1).empty?
            event.respond(format_entry_array($1, d))
        end
    }
}
            
bot.message_edit { |event|
    if !@blacklist.include?(event.message.channel.id) then
        event.message.create_reaction "\u{1F35E}"
    end
}

bot.command(
    :define,
    description: "Fetch all definitions for the word from the Sajem Tan dictionary",
    min_args: 1,
    usage: "define <word...>"
) { |event, *words|
    for word in words
        event.respond @lexicon.define_formatted word
    end
    nil
}

bot.command(
    :y,
    description: "Translates message into Y Tan",
    min_args: 1,
    usage: "y <message...>"
) { |event, *args|
    y args.join " "
}

bot.command(
    :flt,
    description: "Translates message into Foam Letter Tan",
    min_args: 1,
    usage: "flt <message...>"
) { |event, *args|
    flt args.join " "
}

bot.command(
    :nkt,
    description: "Translates message into Next Key Tan",
    min_args: 1,
    usage: "flt [<offset>] <message...>"
) { |event, *args|
    offset = 1
    if (a = args[0].to_i) != 0 or args[0].start_with? "0" then
        args = args.drop 1
        offset = a
    end
            
    nkt offset, args.join(" ")
}

bot.command(
    :random,
    description: "Generate a random number",
    min_args: 1,
    max_args: 2,
    usage: "random <max>|<min> <max>"
) { |event, first, second|
    if second
        rand first.to_i..second.to_i
    else
        rand 0..first.to_i
    end
}

bot.run
