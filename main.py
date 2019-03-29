import discord
from discord.ext import commands
from os import listdir
from utils import get_yaml_contents

bot = commands.Bot(command_prefix='st!')

@bot.command()
async def emojify(ctx, s: str):
    e = ":exclamation:"
    q = ":question:"
    n = ":interrobang:"
    ri = ":regional_indicator_{}:"
    
    result = []
    for i in s.lower():
        last = None;
        try: last = result[-1]
        except IndexError: pass
        if i == " " or i == "\n": result.append(i)
        elif i == "!":
            if last == e:
                result.pop()
                result.append(":bangbang:")
            elif last == q:
                result.pop()
                result.append(n)
            else: result.append(e)
        elif i == "?":
            if last == e:
                result.pop()
                result.append(n)
            else: result.append(q)
        elif i in "am": result.append(":%s:"%i)
        elif i == "o": result.append(":o2:")
        elif i == "p": result.append(":parking:")
        elif i == "i": result.append(":information_source:")
        elif i == "b":
            if last == "a":
                result.append(":ab:")
            else:
                result.append(":b:")
        elif i == "g" and last == ri.format("n"):
            result.pop()
            result.append(":ng:")
        elif i == "k" and last == ":o:":
            result.pop()
            result.append(":ok:")
        else: result.append(ri.format(i))
    await ctx.send(" ".join(result))

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
        await ctx.send("List of help topics:\n\n{}".format(
            "\n".join(listdir("help"))
        ))
    else:
        f = get_yaml_contents("help/{}".format(topic))
    
        message = "Help for {} **{}**:\n\n".format(f["type"], topic)
        
        try:
            message = message + "__**Description:**__\n\n{}\n".format(
                f["description"]
            )
        except KeyError: pass
    
        try:
            message = message + "__**Examples:**__\n\n"
            for ex in f["examples"]:
                message = message + "**input:** `st!{} {}`\n**output:** {}".format(
                    topic, ex["in"], ex["out"]
                )
        except KeyError: pass
    
        await ctx.send(message)

bot.run("NDM0MTM2NzA2Mjk2NTc4MTAx.D384Zg.NTim37R4oEhokVTYyWzf1jcy-CU")
