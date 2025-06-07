extends Button

@onready var card_system = $"../CardDeck"
@onready var dealer_hand = $"../DealerHand"
@onready var player_hand = $"../PlayerHand"
@onready var blackjack_button = $"../BlackjackButton"

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	disabled = true

func _on_pressed():
	disabled = true
	$"../HitButton".disabled = true
	
	# 1. 翻开庄家隐藏牌
	var first_card = dealer_hand.get_node("Card1")
	if first_card.texture and "back" in first_card.texture.resource_path:
		var card_code = blackjack_button.get_dealer_card_code(1)
		if card_code:
			first_card.texture = card_system.get_card_texture(card_code)
	
	# 2. 庄家要牌逻辑
	var dealer_score = blackjack_button.calculate_hand_value(dealer_hand, true)  # 注意这里改为true，表示是庄家
	print("庄家初始点数: ", dealer_score)
	
	# 明确庄家要牌条件：
	while blackjack_button.dealer_hand_size < blackjack_button.MAX_HAND_SIZE:
		dealer_score = blackjack_button.calculate_hand_value(dealer_hand, true)  # 每次循环重新计算
		
		# 检查停牌条件
		if dealer_score > 17:
			break  # 硬18点或更高必须停牌
		elif dealer_score == 17:
			# 如果是硬17点则停牌，软17点则继续
			if not has_soft_ace(dealer_hand):
				break
		elif dealer_score < 17:
			pass  # 继续要牌
		else:
			break  # 其他情况停止
			
		# 如果满足要牌条件，则要一张牌
		await get_tree().create_timer(0.5).timeout
		
		var dealer_card = card_system.draw_random_card(false)
		blackjack_button.setup_card(dealer_hand, blackjack_button.dealer_hand_size, dealer_card)
		blackjack_button.dealer_hand_size += 1
		
		print("庄家新牌点数: ", blackjack_button.calculate_hand_value(dealer_hand, true))
		
		# 如果庄家爆牌，立即停止
		if blackjack_button.calculate_hand_value(dealer_hand, true) > 21:
			break
	
	# 3. 结束游戏
	print("庄家最终点数: ", dealer_score)
	blackjack_button.end_game()

func has_soft_ace(hand):
	var total_with_ace_as_11 = 0
	var ace_count = 0
	
	# 先计算所有Ace都当作11时的总点数
	for i in range(1, blackjack_button.dealer_hand_size + 1):
		var card = hand.get_node("Card%d" % i)
		if not card.visible or not card.texture:
			continue
			
		var tex_path = card.texture.resource_path
		if not tex_path or "back" in tex_path:
			continue
			
		var file_name = tex_path.get_file()
		if "_" in file_name:
			var parts = file_name.split("_")
			var rank_num = int(parts[2].split(".")[0])
			
			if rank_num == 1:  # Ace
				total_with_ace_as_11 += 11
				ace_count += 1
			elif rank_num >= 11 and rank_num <= 13:  # J/Q/K
				total_with_ace_as_11 += 10
			else:
				total_with_ace_as_11 += rank_num
	
	# 如果没有Ace，肯定不是软17
	if ace_count == 0:
		return false
	
	# 如果总点数正好是17，且至少有一个Ace被计为11，则是软17
	return total_with_ace_as_11 == 17
