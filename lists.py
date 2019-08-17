from random import seed, choice
from utils import get_contents

seed()

lists = {}

def random_element(l: str):
    global lists
    
    try: lists[l]
    except KeyError: lists[l] = get_contents("lists/" + l).split("\n")

    return choice(lists[l])
