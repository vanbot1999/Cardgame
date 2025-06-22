# NPC.gd
extends CharacterBody2D

var initial_position: Vector2

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea
@onready var interaction_icon = $InteractionIcon
var dialog_box_instance

var in_conversation = false

func _ready():
	initial_position = position
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	# 预加载对话框场景
	var dialog_box_scene = preload("res://ui/ShopDialog/ShopDialogBox.tscn")
	dialog_box_instance = dialog_box_scene.instantiate()
	add_child(dialog_box_instance)
	dialog_box_instance.hide()
	dialog_box_instance.option_selected.connect(_on_dialog_option_selected)
	
	# 确保有动画时播放Idle动画
	if animated_sprite:
		animated_sprite.play("Idle")
		
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

func interact(player):
	if not in_conversation:
		player.can_move = false
		dialog_box_instance.show_dialog("需要救济金吗", "接受（+50）", "拒绝")
		in_conversation = true

func _on_dialog_option_selected(option_index):
	in_conversation = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
		
		if option_index == 0:  # 接受选项
			player.add_money(50)
	
	dialog_box_instance.hide()
