import os
import time
import json


def get_commands_list(comamnds_dir: str, cache_dir: str) -> list[str]:
    os.makedirs(cache_dir, exist_ok=True)
    files = os.walk(comamnds_dir)
    commands = list[str]()
    if os.path.exists(cache_dir + "commands_list.json"):
        with open(cache_dir + "commands_list.json", "r") as f:
            cache = json.load(f)
            if time.time() - cache["timestamp"] < 3600:
                return cache["commands"]
    for _, _, file_list in files:
        for file_name in file_list:
            if file_name.endswith(".md"):
                commands.append(file_name[:-3])
    
    commands.sort()
    with open(cache_dir + "commands_list.json", "w+") as f:
        json.dump({
            "timestamp": time.time(),
            "commands": commands
        }, f)
    return commands