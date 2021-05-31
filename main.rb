require 'discordrb'

require './ortho.rb'

bot = Discordrb::Commands::CommandBot.new token: File.readlines("Token")[0], prefix: "dfr!"

lists = Hash.new { |hash, key| File.readlines("lists/#{key}") }
blacklist = File.readlines("blacklist").to_set.map {|x| x.to_i}

bot.ready { |event|
    Thread.new {
        while true do
            bot.update_status "online", "with a pile of #{lists[:pasta].sample.capitalize}", nil
            sleep 90
        end
    }
}

bot.message_edit { |event|
    if !blacklist.include?(event.message.channel.id) then
        event.message.create_reaction "\u{1F35E}"
    end
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
