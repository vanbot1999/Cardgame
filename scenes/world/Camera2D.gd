extends Camera2D

func _ready():
	# 获取边界矩形（假设你已经有一个边界区域）
	var bounds = get_tree().get_first_node_in_group("world_bounds")
	if bounds:
		var shape = bounds.get_node("CollisionShape2D")
		if shape and shape.shape is RectangleShape2D:
			var bounds_pos = bounds.global_position
			var bounds_size = shape.shape.size
			
			# 设置相机边界
			limit_left = bounds_pos.x - bounds_size.x/2
			limit_right = bounds_pos.x + bounds_size.x/2
			limit_top = bounds_pos.y - bounds_size.y/2
			limit_bottom = bounds_pos.y + bounds_size.y/2
			
			# 启用边界限制
			limit_smoothed = true  # 平滑过渡
