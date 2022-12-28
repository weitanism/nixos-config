import json
import subprocess
from dataclasses import dataclass

try:
    type(rofi)
except:
    from rofi import rofi


def alert(msg: str):
    subprocess.call(["notify-send", msg])


@dataclass
class Sink:
    index: int
    name: str
    description: str
    mute: bool
    active_port: str
    is_default: bool = False

    @classmethod
    def from_dict(cls, d):
        return cls(
          index=d["index"],
          name=d["name"],
          description=d["description"],
          mute=d["mute"],
          active_port=d["active_port"],
        )

    def brief(self):
        default = '*' if self.is_default else ' '
        mute = 'T' if self.mute else 'F'
        name = f'{self.name[:5]}..' if len(self.name) > 5 else self.name
        return f"{default} mute={mute} port=\"{self.active_port}\" description=\"{self.description}\""

    def display_order(self):
        order = 0
        if self.is_default:
            order -= 2
        if not self.mute:
            order -= 1
        return order


def pactl(*cmd) -> str:
    pactl_cmd = ["pactl", "--format=json", *cmd]
    print(pactl_cmd)
    p = subprocess.Popen(
        pactl_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    stdout, _ = p.communicate()
    return stdout.decode().strip()


def set_default_sink(sink: Sink):
    pactl("set-default-sink", sink.name)
    alert(f"set default sink to {sink.name} port={sink.active_port}")


def toggle_mute(sink: Sink):
    pactl("set-sink-mute", sink.name, "toggle")
    alert(f"toggle mute on sink {sink.name} port={sink.active_port}")


sinks_json = pactl("list", "sinks")
if not sinks_json:
    alert("Can't get info from pactl")
    exit(1)

# print(json.dumps(json.loads(sinks_json), indent=2))

sinks = [Sink.from_dict(s) for s in json.loads(sinks_json)]
default_sink_name = pactl("get-default-sink")
default_sink = None
for sink in sinks:
    if sink.name == default_sink_name:
        sink.is_default = True
        default_sink = sink
sinks.sort(key=lambda s: s.display_order())

# for s in sinks:
#     print(s)

item = rofi(
  [
    [f"set default ({default_sink.active_port})", None, [
      [sink.brief(), lambda: set_default_sink(sink)] for sink in sinks
    ]],
    ["toggle mute", None, [
      [sink.brief(), lambda: toggle_mute(sink)] for sink in sinks
    ]],
  ]
)

if item and item.userdata:
    item.userdata()

