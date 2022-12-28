import subprocess

item = rofi(
  [
    "item 1",
    ["item with userdata(ls)", "ls"],
    ["item with submenu", None, [
      "submenu item 1",
      ["submenu with userdata(ls -lh)", "ls -lh"],
      ["submenu with submenu", None, [
        "subsubmenu item 1",
      ]],
    ]],
  ]
)
print(item)
if item and item.userdata:
    subprocess.call(item.userdata, shell=True)