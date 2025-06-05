# Player.gd
extends CharacterBody2D

@export var boundary_push_back_force := 10.0  # 边界反弹力度

# 移动参数
@export var speed: float = 100.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

# 移动控制
var can_move: bool = true
var can_interact = false
var interact_target = null

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# 边界控制
var boundary_rect := Rect2()
var boundary_initialized := false

func _ready():
	add_to_group("player")

func _input(event):
	if event.is_action_pressed("interact") and can_interact and interact_target:
		interact_target.interact()

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		animated_sprite.stop()
		return
		
	# 获取输入方向
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 应用加速度
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
		
		# 根据移动方向选择动画
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if input_direction.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		animated_sprite.stop()
	
	# 移动前边界检查
	_pre_move_boundary_check(delta)
	
	# 执行移动
	move_and_slide()
	
	# 移动后强制边界约束
	_enforce_boundary()

# 移动前边界检查
func _pre_move_boundary_check(delta):
	if boundary_initialized:
		# 预测下一帧位置
		var predicted_position = position + velocity * delta
		
		# 检查是否超出边界
		if not boundary_rect.has_point(predicted_position):
			# 如果预测位置超出边界，调整速度
			if predicted_position.x < boundary_rect.position.x or predicted_position.x > boundary_rect.end.x:
				velocity.x = 0
			if predicted_position.y < boundary_rect.position.y or predicted_position.y > boundary_rect.end.y:
				velocity.y = 0

# 强制边界约束
func _enforce_boundary():
	if boundary_initialized:
		var clamped_position = position.clamp(boundary_rect.position, boundary_rect.end)
		if position != clamped_position:
			position = clamped_position
			velocity = Vector2.ZERO  # 碰到边界时重置速度
