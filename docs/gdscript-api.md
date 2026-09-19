# Deltarune Studio GDScript API

项目入口脚本由 `project.json` 的 `entryScript` 指定，默认路径是：

```text
scripts/manual/main.gd
```

入口脚本必须继承 `Node` 并实现 `run()`：

```gdscript
extends Node

func run() -> void:
	await DRS.move("kris", Vector2(420, 320))
	await DRS.say("* The room is quiet.", 1.0)
```

`DRS` 是生成 Godot 项目中的全局 Autoload。项目脚本只依赖下列稳定接口，不应访问 `runtime/main.gd` 的内部节点。

## 角色

```gdscript
DRS.character("kris")
await DRS.move("kris", Vector2(320, 240))
await DRS.move_by("kris", Vector2(64, 0))
await DRS.face("kris", "up")
await DRS.teleport("kris", Vector2(160, 320))
await DRS.set_animation("kris", "sit")
await DRS.set_expression("kris", "surprised", 1.5)
await DRS.clear_animation("kris")
await DRS.set_character_visible("kris", false)
```

`move` 和 `move_by` 的第三个参数可以覆盖角色配置中的移动速度：

```gdscript
await DRS.move("kris", Vector2(500, 240), 220.0)
```

角色移动会使用 Godot 碰撞，并按移动方向播放角色定义中的 `walk` 动画。停止后优先显示对应方向的 `idle`，没有 `idle` 时停在 `walk` 第一帧。

### 玩家控制

```gdscript
DRS.enable_player_control("kris")
DRS.set_player_control_speed(190.0)
DRS.disable_player_control()
```

启用后可用 WASD 或方向键移动角色。移动沿用角色配置中的速度、碰撞和方向动画；调用 `set_player_control_speed` 可临时覆盖速度。对话和同一角色的脚本移动会暂时锁住输入，结束后自动恢复；经过 Door 切换房间后，只要目标房间存在相同角色 ID，控制会继续生效。

状态查询：

```gdscript
DRS.is_player_control_enabled()
DRS.controlled_character_id()
```

角色跟随会记录目标真正经过的路径，而不是直接冲向目标：

```gdscript
await DRS.follow("ralsei", "kris", 48.0)
await DRS.stop_follow("ralsei")
```

## 对话

```gdscript
await DRS.say("* Hello.")
await DRS.say("* This closes automatically.", 1.5)
await DRS.say_light("* Light World style.")
await DRS.say_dark("* Dark World style.")
await DRS.say_portrait(
	"* A portrait dialogue.",
	"resources/portraits/susie.png",
	DRS.DIALOGUE_STYLE_DARK
)
var answer := await DRS.choice(["Go inside", "Leave"])
```

第二个参数为 `0` 时等待玩家按下确认键；大于 `0` 时在指定秒数后自动关闭。第三个参数控制每秒显示字符数。

`say` 的第四个参数可以直接选择 `"light_world"` 或 `"dark_world"`：

```gdscript
await DRS.say("* Styled text.", 1.0, 40.0, DRS.DIALOGUE_STYLE_DARK)
```

两种对话框都使用 Runtime 内置的原始 PNG 模板。输入控制会在对话期间暂停；输入确认键可以立即完成当前打字效果，再次确认关闭对话框。

## 摄像机

```gdscript
await DRS.camera_follow("kris")
await DRS.camera_focus(Vector2(400, 200), 0.5)
await DRS.camera_zoom(1.5, 0.4)
await DRS.camera_shake(6.0, 0.3)
await DRS.camera_reset()
```

## 交互

```gdscript
DRS.register_interactable("bookshelf", _read_books, 56.0, true)
DRS.enable_interaction("kris")
await DRS.wait_for_interaction("bookshelf")

func _read_books() -> void:
	await DRS.say_dark("* A dusty book.")
```

第四个参数控制是否要求角色面向对象。Door 和 Area2D Trigger 可以单独启用或禁用：

```gdscript
await DRS.set_door_enabled("church_door", true)
await DRS.set_trigger_enabled("intro_trigger", false)
```

## 状态

```gdscript
DRS.set_flag("met_ralsei")
if DRS.flag("met_ralsei"):
	DRS.set_value("money", 20)
DRS.add_value("money", 5)
var money = DRS.value("money", 0)
```

当前状态属于本次运行；未来存档系统会序列化同一组 Flag 和 Value。

## 场景对象

```gdscript
await DRS.show("lamp")
await DRS.hide("lamp")
await DRS.set_texture("screen", "resources/props/static.png")
await DRS.move_object("cart", Vector2(420, 260), 120.0)
await DRS.remove("broken_box")
```

## 画面效果

```gdscript
await DRS.fade_out(0.25)
await DRS.fade_in(0.25)
await DRS.flash(Color.WHITE, 0.15)
await DRS.show_image("resources/props/photo.png", 2.0)
DRS.hide_image()
```

## 房间

```gdscript
await DRS.change_room("scenes/hall/room.json", "hall_entry", "kris")
```

参数依次是目标房间、目标出生点 ID、需要带入目标房间的角色 ID。后两项可以省略。

## 音频

```gdscript
DRS.play_bgm("resources/audio/theme.ogg")
DRS.play_sound("resources/audio/door.wav")
await DRS.stop_bgm(0.5)
await DRS.crossfade_bgm("resources/audio/danger.ogg", 1.0)
DRS.set_bgm_volume(-8.0)
DRS.play_sound_at("resources/audio/door.wav", Vector2(400, 200))
```

音频路径始终相对项目根目录。BGM 默认循环；音效播放完成后会自动释放播放器。

## 等待

```gdscript
await DRS.wait(0.5)
```
