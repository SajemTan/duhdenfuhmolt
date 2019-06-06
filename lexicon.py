import asyncio
from json import loads
from utils import get_url_contents

lexicon = {}

async def update_lexicon():
    global lexicon
    
    data = await get_url_contents("https://mr-martian.github.io/Sajem_Tan/lexicon.js")
    data = data.split("var lexicon = ")[1].split("};")[0] + "}"
    data = "\n".join([i for i in data.split("\n") if "//" not in i])

    lexicon = loads(data)

def format_definition(ls):
    result = []
    for definition in ls:
        if isinstance(definition, str):
            result.append(definition)
        elif isinstance(definition, list):
            hint = definition[0]
            if hint == ("archaic" or "see also"):
                result.append(f"*{hint}:* {definition[1]}")
            elif hint == "example":
                result.append(f"*example:* {definition[1]} ({definition[2]})")
            elif hint == "suf-example":
                result.append(f"*example:* {definition[1]} \u2192 {definition[2]}")
    return "; ".join(result)

def define(word):
    global lexicon

    result = []
    for catname, category in lexicon.items():
        for entryname, entry in category.items():
            if isinstance(entry, list):
                if entryname == word:
                    result.append(f"**({catname})** {format_definition(entry)}")
            elif isinstance(entry, dict):
                for subentryname, subentry in entry.items():
                    if subentryname == word:
                        result.append(
                            f"**({catname} > {entryname})** {format_definition(subentry)}"
                        )
    return "__**{}**__\n\n{}".format(
        word, "\n".join(result)
    )
