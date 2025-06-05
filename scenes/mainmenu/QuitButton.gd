extends Button

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	print("退出按钮按下！")
	get_tree().quit()

