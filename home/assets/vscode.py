#!/usr/bin/env python3

import json
import os
from sys import argv, stderr

#
# exit codes:
# 0 - success
# 1 - theme name not passed as argument
# 2 - io errors
# 3 - json parsing errors
#

if __name__ == "__main__":
    settings_path = "$HOME/.config/Code/User/settings.json"
    settings_path = os.path.expandvars(settings_path)

    try:
        theme = argv[1]
    except NameError:
        print("Pass theme name as argument")
        exit(1)

    try:
        settings_file = open(settings_path, 'r')
        settings: dict = json.load(settings_file)
        settings_file.close()
    except OSError as err:
        print(f"Can't open code settings file: {err.strerror}", file=stderr)
        exit(2)
    except json.JSONDecodeError:
        print("Code settings is not valid json", file=stderr)
        exit(3)
    except UnicodeDecodeError:
        print("Code settings not contain UTF-8, UTF-16 or UTF-32 data", file=stderr)
        exit(3)

    settings["workbench.colorTheme"] = theme
    
    settings_file = open(settings_path, 'w')
    json.dump(settings, settings_file, indent=4)
    settings_file.close()        
