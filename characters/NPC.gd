# NPC.gd
extends CharacterBody2D

# 移动属性
@export var move_speed: float = 50.0
@export var move_range: float = 100.0  # NPC移动范围
var move_direction: Vector2 = Vector2.RIGHT
var initial_position: Vector2

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea
@onready var interaction_icon = $InteractionIcon
var dialog_box_instance

var in_conversation = false

@export var table_scene: PackedScene

func _ready():
	initial_position = position
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	# 预加载对话框场景
	var dialog_box_scene = preload("res://ui/DialogBox.tscn")
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
		# 获取玩家并禁用移动
		player.can_move = false  # 现在可以直接使用传入的 player
		dialog_box_instance.show_dialog("要来玩比大小吗？", "接受", "拒绝")
		in_conversation = true

func _on_dialog_option_selected(option_index):
	in_conversation = false
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
		
	if option_index == 0:  # 接受
		_switch_to_table_scene()
	
	dialog_box_instance.hide()

func _switch_to_table_scene():
	if table_scene:
		get_tree().change_scene_to_packed(table_scene)
	else:
		push_error("Table scene is not assigned in NPC!")

#func _physics_process(delta):
	#if in_conversation:
		#return  # 对话时停止移动
	#
	## 简单的来回移动逻辑
	#if position.distance_to(initial_position) > move_range:
		#move_direction *= -1  # 反向移动
		#if animated_sprite:
			#animated_sprite.flip_h = move_direction.x < 0
	#
	## 设置速度并移动
	#velocity = move_direction * move_speed
	#move_and_slide()
	#
	## 根据移动状态切换动画
	#if animated_sprite:
		#if velocity != Vector2.ZERO:
			#animated_sprite.play("Walk")
		#else:
			#animated_sprite.play("Idle")
