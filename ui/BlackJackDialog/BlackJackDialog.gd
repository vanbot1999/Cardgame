# BlackJackDialogBox.gd
extends CanvasLayer

signal option_selected(option_index)

@onready var label = $TextureRect/Label
@onready var option1_button: Button = $TextureRect/Option1
@onready var option2_button: Button = $TextureRect/Option2

func show_dialog(text: String, option1_text: String, option2_text: String):
	label.text = text
	option1_button.text = option1_text
	option2_button.text = option2_text
	show()

func _ready():
	# 显式连接信号，避免编辑器连接丢失
	option1_button.pressed.connect(_on_option_pressed.bind(0))
	option2_button.pressed.connect(_on_option_pressed.bind(1))
	
	# 确保按钮可交互
	option1_button.mouse_filter = Control.MOUSE_FILTER_STOP
	option2_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_option_pressed(option_index: int):
	option_selected.emit(option_index)
	hide()
