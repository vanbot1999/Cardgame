extends Button

@onready var card_system = $"../CardDeck"
@onready var player_hand = $"../PlayerHand"
@onready var enemy_hand = $"../EnemyHand"
@onready var deck_button = $"../DeckButton"

func _ready():
	connect("pressed", Callable(self, "_on_button_pressed"))
	disabled = true

func _on_button_pressed():
	# 显示对手手牌
	reveal_enemy_cards()
	
	# 计算双方分数
	var player_score = calculate_hand_score(player_hand)
	var enemy_score = calculate_hand_score(enemy_hand)
	
	# 显示结果
	show_result(player_score, enemy_score)
	
	# 禁用所有操作按钮
	deck_button.disabled = true
	disabled = true
	text = "已结算"
	modulate = Color(0.7, 0.7, 0.7)
	
	# 添加禁用效果
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.7, 0.3)
	
	# 禁用交互
	mouse_filter = MOUSE_FILTER_IGNORE

# 显示对手手牌
func reveal_enemy_cards():
	for i in range(1, 6):
		var card = enemy_hand.get_node("Card%d" % i)
		if card.visible:
			var card_code = get_enemy_card_code(i)
			if card_code != "":
				card.texture = card_system.get_card_texture(card_code)

# 获取对手卡牌代码
func get_enemy_card_code(slot_number):
	var enemy_cards = []
	for card_code in card_system.drawn_cards:
		if card_system.card_assignments.get(card_code) == false:
			enemy_cards.append(card_code)
	return enemy_cards[slot_number-1] if slot_number <= enemy_cards.size() else ""

# 计算手牌分数 (重命名后的函数)
func calculate_hand_score(hand):
	var score = 0
	for i in range(1, 6):
		var card = hand.get_node("Card%d" % i)
		if card.visible and card.texture:
			var tex_path = card.texture.resource_path
			if "back" in tex_path: continue
			
			var parts = tex_path.get_file().split("_")
			if parts.size() >= 3:
				var rank = parts[2].split(".")[0]
				match rank:
					"A": score += 1
					"J","Q","K": score += 10
					_: 
						if rank.is_valid_int():
							score += rank.to_int()
	return score

# 显示结果
func show_result(player_score, enemy_score):
	var result = "平局！"
	if player_score > enemy_score:
		result = "玩家获胜！"
	elif enemy_score > player_score:
		result = "对手获胜！"
	
	print("\n===== 游戏结算 =====")
	print("玩家总点数: %d" % player_score)
	print("对手总点数: %d" % enemy_score)
	print("结果: %s\n" % result)
