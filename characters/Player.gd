extends CharacterBody2D

@export var boundary_push_back_force := 10.0
@export var speed: float = 100.0
@export var acceleration: float = 15.0
@export var friction: float = 10.0

var can_move: bool = true
var can_interact = false
var interact_target = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
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
		animated_sprite.play("Idle")
		return
		
	# 只获取左右输入
	var input_direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		0  # 垂直方向设为0
	)
	
	# 应用加速度
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
		
		# 根据移动方向选择动画
		if input_direction.x != 0:
			animated_sprite.play("Run")
			animated_sprite.flip_h = input_direction.x < 0
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		animated_sprite.play("Idle")
	
	# 移动前边界检查
	_pre_move_boundary_check(delta)
	
	# 执行移动
	move_and_slide()
	
	# 强制y轴位置不变
	position.y = 8 # 或者你想要的固定y值
	
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
