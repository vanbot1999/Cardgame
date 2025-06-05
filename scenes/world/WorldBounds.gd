extends Area2D

@export var boundary_size := Vector2(1280, 720)
@export var boundary_margin := 50.0

func _ready():
	add_to_group("world_bounds")
	
	# 创建碰撞形状
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = boundary_size + Vector2(boundary_margin * 2, boundary_margin * 2)
	collision_shape.shape = rectangle
	add_child(collision_shape)
	
	# 延迟一帧确保所有节点就绪
	call_deferred("_initialize_boundaries")

func _initialize_boundaries():
	# 获取场景中所有玩家
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		# 设置边界矩形（相对于边界节点的位置）
		player.boundary_rect = Rect2(
			position - boundary_size/2,
			boundary_size
		)
		player.boundary_initialized = true
	
	# 连接信号
	body_exited.connect(_on_body_exited)

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		body.call_deferred("_enforce_boundary")
