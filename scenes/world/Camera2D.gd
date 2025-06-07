extends Camera2D

# 相机Y轴向上的偏移量
@export var y_offset: float = -16  # 负值表示向上偏移

func _ready():
	# 设置边界（保持你的原有代码）
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
	
	# 应用Y轴偏移
	offset.y = y_offset
