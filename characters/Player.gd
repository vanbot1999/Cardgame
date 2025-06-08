extends CharacterBody2D

# 移动属性
@export var boundary_push_back_force := 10.0
@export var speed: float = 160.0
@export var acceleration: float = 50.0
@export var friction: float = 20.0
@export var climb_speed: float = 80.0  # 攀爬速度
@export var gravity: float = 5000.0  # 增加到2500
@export var max_fall_speed: float = 2000.0  # 增加到1000

# 状态变量
var can_move: bool = true
var can_interact: bool = false
var interact_target = null
var is_on_ladder: bool = false  # 是否在梯子上
var ladder_area: Area2D = null  # 当前所在的梯子区域

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var money_ui = $MoneyUI
@onready var money_control = $MoneyUI/Control
@onready var money_label: Label = $MoneyUI/Control/HBoxContainer/MoneyLabel
@onready var ladder_detector: Area2D = $LadderDetector

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
	ladder_detector.area_entered.connect(_on_ladder_area_entered)
	ladder_detector.area_exited.connect(_on_ladder_area_exited)
	await get_tree().process_frame

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		animated_sprite.play("Idle")
		move_and_slide()
		return
				
	# 应用重力（不在梯子上且不在地面时）
	if not is_on_ladder and not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# 处理输入
	var input_direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down") if is_on_ladder else 0.0
	)
	
	if not is_on_ladder and not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# 移动处理
	handle_movement(input_direction, delta)
	_pre_move_boundary_check(delta)
	move_and_slide()
	_enforce_boundary()

func handle_movement(input_direction: Vector2, delta: float):
	var target_velocity = Vector2(velocity.x, 0)  # 重置水平速度，保留垂直速度
	
	if is_on_ladder:
		# 梯子上的移动 - 允许垂直移动
		target_velocity = input_direction * Vector2(speed, climb_speed)
		
		# 梯子上的动画控制
		if input_direction.y < 0:
			animated_sprite.play("Climb_Up")
		elif input_direction.y > 0:
			animated_sprite.play("Climb_Down")
		elif input_direction.x != 0:
			animated_sprite.play("Run")
			animated_sprite.flip_h = input_direction.x < 0
		else:
			animated_sprite.play("Idle")
	else:
		# 地面移动 - 只处理水平移动
		target_velocity.x = input_direction.x * speed
		
		# 地面动画控制
		if abs(input_direction.x) > 0:
			animated_sprite.play("Run")
			animated_sprite.flip_h = input_direction.x < 0
		else:
			animated_sprite.play("Idle")
	
	# 应用速度
	if input_direction.length() > 0:
		velocity.x = target_velocity.x
		if is_on_ladder:  # 只在梯子上控制垂直速度
			velocity.y = target_velocity.y
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		if is_on_ladder:  # 梯子上才应用垂直摩擦力
			velocity.y = lerp(velocity.y, 0.0, friction * delta)
			
# 梯子区域检测
func _on_ladder_area_entered(area: Area2D):
	if area.is_in_group("ladder"):
		is_on_ladder = true
		ladder_area = area

func _on_ladder_area_exited(area: Area2D):
	if area == ladder_area:
		is_on_ladder = false
		ladder_area = null
		velocity.y = 0
		
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

func is_climbing() -> bool:
	return is_on_ladder and abs(Input.get_axis("ui_up", "ui_down")) > 0
