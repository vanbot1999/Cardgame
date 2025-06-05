extends Button

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	print("跳转到world场景！")
	get_tree().change_scene_to_file("res://scenes/world/GameScene.tscn")
