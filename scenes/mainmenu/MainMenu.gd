# MainMenu.gd
extends CanvasLayer

func _ready():
	# 绑定按钮信号
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world/GameScene.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
