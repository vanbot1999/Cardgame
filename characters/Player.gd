extends CharacterBody2D

@export var boundary_push_back_force := 10.0
@export var speed: float = 200.0
@export var acceleration: float = 50.0
@export var friction: float = 20.0
@export var climb_speed: float = 80.0
@export var gravity: float = 10000.0
@export var max_fall_speed: float = 5000.0

# 状态变量（简化梯子逻辑）
var can_move: bool = true
var can_interact: bool = false
var interact_target = null
var is_climbing: bool = false

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var money_ui = $MoneyUI
@onready var money_label: Label = $MoneyUI/Control/HBoxContainer/MoneyLabel
@onready var ladder_ray_cast: RayCast2D = $LadderRayCast

# 边界控制
var boundary_rect := Rect2()
var boundary_initialized := false

# 金钱系统
@export var money := 100:
	set(value):
		money = max(0, value)
		update_money_display()

func _ready():
	add_to_group("player")
	await get_tree().process_frame

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		animated_sprite.play("Idle")
		move_and_slide()
		return
	
	# 梯子检测逻辑
	var ladder_collider = ladder_ray_cast.get_collider()
	is_climbing = ladder_collider != null and ladder_collider.is_in_group("ladder")
	
	# 根据状态选择移动模式
	if is_climbing:
		_handle_ladder_movement()
	else:
		_handle_ground_movement(delta)
	
	# 保留原有边界检查和移动
	_pre_move_boundary_check(delta)
	move_and_slide()
	_enforce_boundary()
	
func _handle_ground_movement(delta):
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# 水平移动
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir:
		velocity.x = input_dir * speed
		animated_sprite.play("Run")
		animated_sprite.flip_h = input_dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
		animated_sprite.play("Idle")
	
func _handle_ladder_movement():
	var vertical_input = Input.get_axis("ui_up", "ui_down")
	var horizontal_input = Input.get_axis("ui_left", "ui_right")
	
	# 垂直移动（爬梯子）
	velocity.y = vertical_input * climb_speed
	
	# 水平移动（在梯子上）
	if horizontal_input:
		velocity.x = horizontal_input * speed
		animated_sprite.flip_h = horizontal_input < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	
	# 动画控制
	if vertical_input < 0:
		animated_sprite.play("Climb_Up")
	elif vertical_input > 0:
		animated_sprite.play("Climb_Down")
	else:
		# 没有垂直输入时，检查水平移动
		if horizontal_input != 0:
			animated_sprite.play("Run")
		else:
			animated_sprite.play("Idle")
	
# 边界检查方法
func _pre_move_boundary_check(delta: float):
	if boundary_initialized:
		var predicted_position = position + velocity * delta
		if not boundary_rect.has_point(predicted_position):
			if predicted_position.x < boundary_rect.position.x or predicted_position.x > boundary_rect.end.x:
				velocity.x = 0
			if predicted_position.y < boundary_rect.position.y or predicted_position.y > boundary_rect.end.y:
				velocity.y = 0

func _enforce_boundary():
	if boundary_initialized:
		position.x = clamp(position.x, boundary_rect.position.x, boundary_rect.end.x)
		position.y = clamp(position.y, boundary_rect.position.y, boundary_rect.end.y)
		velocity.x = 0
		velocity.y = 0

func update_money_display():
	if money_label != null:
		money_label.text = str(money)
	else:
		print("警告：money_label 未找到！")
		money_label = get_node_or_null("MoneyUI/Control/HBoxContainer/MoneyLabel")
		if money_label:
			money_label.text = str(money)

func _input(event: InputEvent):
	if event.is_action_pressed("interact") and can_interact and interact_target:
		interact_target.interact()

func add_money(amount: int):
	money += amount

func subtract_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		return true
	return false
