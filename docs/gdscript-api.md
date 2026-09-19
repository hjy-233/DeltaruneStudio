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
```

`move` 和 `move_by` 的第三个参数可以覆盖角色配置中的移动速度：

```gdscript
await DRS.move("kris", Vector2(500, 240), 220.0)
```

角色移动会使用 Godot 碰撞，并按移动方向播放角色定义中的 `walk` 动画。停止后优先显示对应方向的 `idle`，没有 `idle` 时停在 `walk` 第一帧。

## 对话

```gdscript
await DRS.say("* Hello.")
await DRS.say("* This closes automatically.", 1.5)
```

第二个参数为 `0` 时等待玩家按下确认键；大于 `0` 时在指定秒数后自动关闭。第三个参数控制每秒显示字符数。

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
```

音频路径始终相对项目根目录。BGM 默认循环；音效播放完成后会自动释放播放器。

## 等待

```gdscript
await DRS.wait(0.5)
```
