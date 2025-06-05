extends Node2D

@onready var bgm = $BGMPlayer

func _ready():
	# 如果未设置Autoplay，用代码启动
	if not bgm.playing:
		bgm.play()
		
# 淡入效果示例
func fade_in(duration: float = 1.0):
	bgm.volume_db = -80  # 初始静音
	bgm.play()
	create_tween().tween_property(bgm, "volume_db", 0.0, duration)
