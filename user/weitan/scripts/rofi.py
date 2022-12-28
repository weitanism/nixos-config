import subprocess
from dataclasses import dataclass
from typing import Any, List, Optional


@dataclass
class MenuItem:
    # Text to be displayed in the menu.
    description: str
    userdata: Any = None
    submenu: Optional["Menu"] = None


@dataclass
class Menu:
    items: List[MenuItem]
    _parent_menu: Optional["Menu"] = None


def build_menu(menu_json) -> Optional[Menu]:
    """
    Build a Menu from json format input.
    Example input:
    [
      "text item 1",
      "text item 2",
      ["item with submenu", None, [
        "submenu text item 1",
        "submenu text item 2",
      ]],
    ]
    """
    if not isinstance(menu_json, list):
        return None

    menu = Menu([])
    for item_json in menu_json:
        item = build_menu_item(item_json)
        if item:
            menu.items.append(item)
        else:
            print(f"Ignore invalid menu item: ${item_json}")
    return menu

def build_menu_item(item_json) -> Optional[MenuItem]:
    if isinstance(item_json, str):
        return MenuItem(description=item_json)
    if isinstance(item_json, list):
        if len(item_json) == 1:
            return MenuItem(description=item_json[0])
        elif len(item_json) == 2:
            return MenuItem(description=item_json[0], userdata=item_json[1])
        elif len(item_json) == 3:
            submenu = build_menu(item_json[2])
            if not submenu:
                print(f"Ignore invalid submenu: {item_json[2]}")
            return MenuItem(description=item_json[0], userdata=item_json[1], submenu=submenu)
    return None


def rofi(menu_or_json) -> Optional[MenuItem]:
    if isinstance(menu_or_json, Menu):
        menu = menu_or_json
    else:
        menu = build_menu(menu_or_json)
        if not menu:
            print(f"Invalid menu: {menu_or_json}")
            return None
    return _rofi(menu)


PREV_MENU_TEXT = "< [back]"

def _rofi(menu: Menu) -> Optional[MenuItem]:
    """
    Invoke rofi as dmenu and return user selected item
    """
    menu_item_texts = [
       ("> " if item.submenu else "  ") + item.description + f" -- ({idx})" for idx,item in enumerate(menu.items)
    ]
    if menu._parent_menu:
        menu_item_texts.insert(0, PREV_MENU_TEXT)
    cmd = [
        "rofi",
        "-dmenu",
        "-i",
        "-sorting-method",
        "fzf",
        "-sort",
        "-matching",
        "fuzzy",
    ]
    # print(" ".join(cmd))
    p = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = p.communicate(input="\n".join(menu_item_texts).encode())
    selected_item_text = stdout.decode().rstrip("\n")
    if not selected_item_text:
        return None

    if selected_item_text not in menu_item_texts:
        print(f'Error: invalid selection "{selected_item_text}"')
        return None

    if selected_item_text == PREV_MENU_TEXT:
        return rofi(menu._parent_menu)

    try:
        idx = int(selected_item_text.rsplit("(", 1)[-1].split(")", 1)[0])
        selected_item = menu.items[idx]
    except ValueError:
        return None
    if selected_item.submenu is not None:
        selected_item.submenu._parent_menu = menu
        return rofi(selected_item.submenu)
    else:
        return selected_item

