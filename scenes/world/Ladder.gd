extends Area2D

# 设置只检测玩家
@export var player_collision_mask_bit := 1  # 确保这与玩家所在的碰撞层匹配

# 梯子顶部和底部的全局 Y 坐标（可以在 Inspector 中设置或自动计算）
@export var top_y: float
@export var bottom_y: float

func _ready():
	# 如果没有手动设置，自动计算梯子碰撞形状的顶部和底部
	if not top_y or not bottom_y:
		var shape = $CollisionShape2D.shape
		if shape:
			var extents = shape.extents if shape is RectangleShape2D else shape.height / 2
			top_y = global_position.y - extents.y
			bottom_y = global_position.y + extents.y

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("玩家进入梯子区域: ", body.name)
		body.is_on_ladder = true  # 直接设置玩家状态

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("玩家离开梯子区域: ", body.name)
		body.is_on_ladder = false
		body.velocity.y = 0
