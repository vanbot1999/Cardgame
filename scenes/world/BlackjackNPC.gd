# BkackjackNPC.gd
extends CharacterBody2D

@onready var interaction_area = $InteractionArea
@onready var interaction_icon = $InteractionIcon
var dialog_box_instance

var in_conversation = false

@export var blackjack_scene: PackedScene

func _ready():
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	# 预加载对话框场景
	var dialog_box_scene = preload("res://ui/BlackJackDialog/BlackJackDialog.tscn")
	dialog_box_instance = dialog_box_scene.instantiate()
	add_child(dialog_box_instance)
	dialog_box_instance.hide()
	# 确保信号正确连接
	dialog_box_instance.option_selected.connect(_on_dialog_option_selected)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		interaction_icon.show()
		body.can_interact = true
		body.interact_target = self

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		interaction_icon.hide()
		body.can_interact = false
		body.interact_target = null
		if in_conversation:
			dialog_box_instance.hide()
			in_conversation = false
			# 确保玩家离开时恢复移动
			body.can_move = true

func interact():
	if not in_conversation:
		# 获取玩家并禁用移动
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.can_move = false
			
		dialog_box_instance.show_dialog("要来玩21点吗？", "接受", "拒绝")
		in_conversation = true

func _on_dialog_option_selected(option_index):
	in_conversation = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
		
	if option_index == 0:  # 接受
		_switch_to_blackjack_scene()
	
	dialog_box_instance.hide()

func _switch_to_blackjack_scene():
	if blackjack_scene:
		get_tree().change_scene_to_packed(blackjack_scene)
	else:
		push_error("BlackJack scene is not assigned in BlackJackNPC!")
