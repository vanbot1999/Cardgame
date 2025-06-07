# PauseMenu.gd
extends CanvasLayer

@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var resume_button = $VBoxContainer/ResumeButton
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	hide()  # 初始隐藏菜单
	get_tree().paused = false
	
	# 连接按钮信号
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	
	# 设置处理模式为始终处理
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if animated_sprite:
		animated_sprite.play("dance")
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().current_scene.name == "MainMenu":
		if visible:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true
		get_viewport().set_input_as_handled()

func _on_resume_pressed():
	hide()
	get_tree().paused = false

func _on_main_menu_pressed():
	hide()  # 先隐藏暂停菜单
	get_tree().paused = false  # 取消暂停
	# 短暂延迟确保状态更新，然后切换场景
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/mainmenu/MainMenu.tscn")
