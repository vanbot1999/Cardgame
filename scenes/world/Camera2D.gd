extends Camera2D

# 相机设置
@export var y_offset: float = -16
@export var look_up_offset: float = -64
@export var move_speed: float = 20.0
@export var return_speed: float = 20.0
@export var hold_duration: float = 0.5
@export var player_node: CharacterBody2D  # 手动拖拽玩家节点或留空自动获取

var target_offset: float = -16
var is_looking_up: bool = false
var hold_timer: float = 0.0

func _ready():
	# 自动获取玩家节点（如果未手动设置）
	if not player_node:
		player_node = get_tree().get_first_node_in_group("player")
	
	target_offset = y_offset
	
	# 设置边界
	var bounds = get_tree().get_first_node_in_group("world_bounds")
	if bounds:
		var shape = bounds.get_node("CollisionShape2D")
		if shape and shape.shape is RectangleShape2D:
			var bounds_pos = bounds.global_position
			var bounds_size = shape.shape.size
			
			limit_left = bounds_pos.x - bounds_size.x/2
			limit_right = bounds_pos.x + bounds_size.x/2
			limit_top = bounds_pos.y - bounds_size.y/2
			limit_bottom = bounds_pos.y + bounds_size.y/2
			limit_smoothed = true
	
	offset.y = y_offset

func _process(delta):
	# 如果玩家正在爬梯，禁用镜头偏移
	if player_node and player_node.is_climbing():
		hold_timer = 0.0
		is_looking_up = false
		target_offset = y_offset
		return
	
	# 正常镜头逻辑
	if Input.is_action_pressed("ui_up") and not is_looking_up:
		hold_timer += delta
		if hold_timer >= hold_duration:
			is_looking_up = true
			target_offset = look_up_offset
	else:
		hold_timer = 0.0
	
	offset.y = lerp(offset.y, target_offset, delta * (move_speed if is_looking_up else return_speed))

func _input(event):
	if event.is_action_released("ui_up"):
		is_looking_up = false
		hold_timer = 0.0
		target_offset = y_offset
