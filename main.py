from re import search
import asyncio
import discord
from discord.ext import commands
from os import listdir
from utils import get_contents, get_yaml_contents
import lexicon
from lists import random_element

bot = commands.Bot(command_prefix='st!')
reactions = get_yaml_contents("reactions")
blacklist = [int(x) for x in get_contents("blacklist").split()]
replacements = {}

for k, v in get_yaml_contents("replacements").items():
    krev = k[::-1]
    try:
        replacements[krev[0]]
    except KeyError:
        replacements[krev[0]] = []
    
    replacements[krev[0]].append((krev[1:], v))

replacements = {k: sorted(v, key=lambda x: len(x[0]), reverse=True) for k, v in replacements.items()}

print(replacements)

# {k[::-1]: v for k, v in get_yaml_contents("replacements").items()}
# replacekeys = sorted(replacements.keys(), key=len)

@bot.listen("on_ready")
async def lexicon_load():
    print("Bot Ready.")
    await lexicon.update_lexicon()
    print("Lexicon Ready.")

@bot.listen("on_ready")
async def pasta_game():
    while True:
        await bot.change_presence(
            activity=discord.Game(
                "with a pile of " + random_element("pasta").title()
            )
        )
        await asyncio.sleep(150)
    
@bot.listen()
async def on_message(message):
    if message.author == bot.user:
        return
    
    global reactions

    for key, react in reactions.items():
        if (
                search(key, message.content.lower()) and
                message.channel.id not in blacklist
        ):
            await message.channel.send(
                    react.format(
                        rt=random_element("triangle"),
                        ri=random_element("indeed")
                    )
            )

@bot.listen()
async def on_reaction_add(reaction, user):
    if user.id == 247134460024193027:
        await reaction.message.add_reaction(reaction)
    
@bot.command()
async def lexupdate(ctx):
    await lexicon.update_lexicon()
    await ctx.send("Updated lexicon")

@bot.command()
async def define(ctx, s: str):
    await ctx.send(lexicon.define(s))

@bot.command()
async def emojify(ctx, s: str):
    response = ""

    for idx, ch in enumerate(s.lower()):
        if ch in replacements:
            before = response
            for k, v in replacements[ch]:
                try:
                    for idx2, ch2 in enumerate(k):
                        if response[-1 - idx2] != ch2:
                            break
                    else:
                        response = response[:len(response) - len(k)] + v
                        break
                except IndexError:
                    break
            if before == response:
                response += ch
        else:
            response += ch
    await ctx.send(response)

#    new = []
#    for idx, i in enumerate(response):
#        inside_emoji = False
#        for char in i:
#            if char == ":":
#                if not inside_emoji:
#                    new.append("")
#                new[-1] += char
#                inside_emoji = not inside_emoji
#            elif inside_emoji:
#                new[-1] += char
#            else:
#                if char.isalpha():
#                    new.append(f":regional_indicator_{char}:")
#                else:
#                    new.append(char)
#        new.append(":")
#    await ctx.send(" ".join(new[:-1]))

@bot.command()
async def y(ctx, s: str):
    await ctx.send("".join(["y" if char in "aeiou" else "Y" if char in "AEIOU" else char for char in s]))

@bot.command()
async def flt(ctx, s: str):
    swaps = ["bd", "cg", "ef", "hn", "it", "jl", "mw", "oq", "px", "uv"]
    message = ""
    
    for char in s:
        for pair in swaps:
            i = None
            try: i = ~-pair.index(char.lower())
            except ValueError: continue

            message = message + (pair[i] if char == char.lower() else pair[i].upper())
            break
        else: message = message + char
    await ctx.send(message)

@bot.command()
async def nkt(ctx, dist: int, s: str):
    keyboard = ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
    message = ""

    for char in s:
        for row in keyboard:
            i = None
            try: i = row.index(char.lower()) + dist
            except ValueError: continue

            i = i % len(row)
            message = message + (row[i] if char == char.lower() else row[i].upper())
            break
        else: message = message + char
    await ctx.send(message)

bot.remove_command("help")

@bot.command()
async def help(ctx, topic: str = ""):
    if topic == "":
        await ctx.send(
                "List of help topics:\n\n" + "\n".join(listdir("help"))
        )
    else:
        f = get_yaml_contents("help/" + topic)
    
        message = f"Help for {f['type']} **{topic}**:\n\n"
        
        try:
            message += f"__**Description:**__\n\n{f['description']}\n"
        except KeyError: pass
    
        try:
            message = message + "__**Examples:**__\n\n"
            for ex in f["examples"]:
                message = message + f"**input:** `st!{topic} {ex['in']}`\n"
                try: message = message + f"**output:** {ex['out']}\n"
                except KeyError: pass
        except KeyError: pass
    
        await ctx.send(message)

bot.run(get_contents("Token").strip())
asyncio.run(lexicon.update_lexicon())
