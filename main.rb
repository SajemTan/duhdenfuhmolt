require 'discordrb'
require 'sqlite3'
require 'yaml'

require './ortho.rb'
require './lexicon.rb'

bot = Discordrb::Commands::CommandBot.new token: File.read("Token").strip, prefix: "df!"

@lists = Hash.new { |hash, key| File.readlines("lists/#{key}") }
@blacklist = File.readlines("blacklist").to_set.map {|x| x.to_i}
@reactions = YAML.load_file("reactions").map {|k, v| [Regexp.new(k, Regexp::IGNORECASE), v]}
@lexicon = Lexicon.new
@db = SQLite3::Database.open "df.db"

def listsub(str)
    str.gsub(/(\{.+\})/) { |m|
        @lists[m[1..-2]].sample
    }
end

bot.ready { |event|
    Thread.new {
        while true do
            bot.update_status "online", "with a stack of #{@lists[:pasta].sample.capitalize} -- df!help", nil
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

    if rand(1..8) <= 1
        puts "awarding potato"
        id = event.message.author.id
        result = @db.get_first_row "SELECT * FROM users WHERE id = ?", [id]

        if result
            @db.execute "REPLACE INTO users VALUES (?, ?)", [id, result[1] + 1]
        else
            @db.execute "INSERT INTO users VALUES (?, 1)", [id]
        end

        event.message.create_reaction "\u{1F954}"
    end

    event.message.text.scan(/\[\[(.+?)\]\]/).each { |data,|
        unless (d = @lexicon.define data).empty?
            event.respond(format_entry_array(data, d))
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

bot.command(
    :potato,
    description: "List everyone's potato count",
    usage: "potato"
) { |event|
    potato = @db.execute "SELECT * FROM USERS"
    potato.sort_by! { |id, count| -count }

    result = "**\u{1F954} POTATO LEADERBOARD \u{1F954}**\n" 
    potato.each { |u|
        member = event.server.member(u[0], request = true)

        if member
            result += "`#{u[1].to_s.rjust 5}` \u{1F954} "

            result += "**#{member.username}**\n"
        end
    }

    result
}

bot.run
