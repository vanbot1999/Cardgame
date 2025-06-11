extends Area2D

var is_teleporting: bool = false
var target_position := Vector2(34, -88)  # 明确的目标位置变量

func _ready():
	add_to_group("door")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.can_interact = true
		body.interact_target = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		# 只有当玩家真的不在任何门区域内时才取消交互
		if not _is_player_in_any_door(body):
			body.can_interact = false
			body.interact_target = null

func _is_player_in_any_door(player) -> bool:
	for door in get_tree().get_nodes_in_group("door"):
		if door != self and door.get_overlapping_bodies().has(player):
			return true
	return false

func interact(player):
	if is_teleporting:
		return

	is_teleporting = true
	player.can_move = false

	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "modulate:a", 0.0, 0.15)
	await tween.finished

	# 传送前先禁用交互
	player.can_interact = false
	player.interact_target = null
	
	# 执行传送
	player.global_position = target_position
	
	# 确保物理引擎更新
	await get_tree().physics_frame
	
	# 强制刷新所有门的交互状态
	_refresh_all_doors(player)
	
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "modulate:a", 1.0, 0.15)
	await tween.finished

	player.can_move = true
	is_teleporting = false

func _refresh_all_doors(player):
	# 刷新所有门的交互状态
	for door in get_tree().get_nodes_in_group("door"):
		if door.get_overlapping_bodies().has(player):
			player.can_interact = true
			player.interact_target = door
			break
