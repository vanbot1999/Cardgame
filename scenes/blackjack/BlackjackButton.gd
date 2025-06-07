extends Button

@export var card_scale = Vector2(0.2, 0.2)
@export var hand_margin = 150
@export var horizontal_spacing = 180.0
@export var left_margin : float = 300

var player_hand_size = 0
var dealer_hand_size = 0
const MAX_HAND_SIZE = 5

@onready var card_system = $"../CardDeck"
@onready var player_hand = $"../PlayerHand"
@onready var dealer_hand = $"../DealerHand"
@onready var score_label = $"../PlayerScoreDisplay"
@onready var hit_button = $"../HitButton"
@onready var stand_button = $"../StandButton"

func _ready():
	score_label.visible = false
	connect("pressed", Callable(self, "_on_button_pressed"))
	init_hand_position(player_hand, false)
	init_hand_position(dealer_hand, true)
	# 初始状态设置为"开始游戏"
	text = "开始游戏"
	disabled = false  # 初始启用开始按钮

func init_hand_position(hand_container: Node2D, is_dealer: bool):
	var viewport_size = get_viewport_rect().size
	var available_width = viewport_size.x - left_margin
	var start_x = left_margin + (available_width - (MAX_HAND_SIZE * horizontal_spacing)) / 2
	var pos_y = hand_margin if is_dealer else viewport_size.y - hand_margin
	
	for i in range(1, MAX_HAND_SIZE + 1):
		var card = hand_container.get_node("Card" + str(i))
		card.visible = false
		card.scale = card_scale
		card.position = Vector2(
			start_x + (i-1)*horizontal_spacing,
			pos_y
		)

func _on_button_pressed():
	if text == "重新开始":
		# 重置游戏状态
		reset_game()
	
	# 开始新游戏逻辑
	text = "游戏中..."  # 游戏进行中时改变按钮文本
	disabled = true  # 游戏进行中禁用按钮
	
	# 重置游戏状态
	player_hand_size = 0
	dealer_hand_size = 0
	card_system.reset_deck()
	$"../ResultLabel".visible = false
	
	# 隐藏所有卡牌
	for i in range(1, MAX_HAND_SIZE + 1):
		player_hand.get_node("Card%d" % i).visible = false
		dealer_hand.get_node("Card%d" % i).visible = false
	
	# 玩家两张牌
	for i in range(2):
		var player_card = card_system.draw_random_card(true)
		setup_card(player_hand, player_hand_size, player_card)
		player_hand_size += 1
	
	# 庄家两张牌(第一张隐藏)
	var dealer_card1 = card_system.draw_random_card(false)
	setup_card(dealer_hand, dealer_hand_size, dealer_card1, true)  # 第一张隐藏
	dealer_hand_size += 1
	
	var dealer_card2 = card_system.draw_random_card(false)
	setup_card(dealer_hand, dealer_hand_size, dealer_card2)
	dealer_hand_size += 1
	
	# 更新UI状态
	hit_button.disabled = false
	stand_button.disabled = false
	score_label.visible = true
	
	update_score_display()
	check_blackjack()

func calculate_hand_value(hand, is_dealer: bool):
	var total = 0
	var ace_count = 0
	var hand_size = dealer_hand_size if is_dealer else player_hand_size

	for i in range(1, hand_size + 1):
		var card = hand.get_node("Card%d" % i)
		if not card.visible or not card.texture:
			continue  # 跳过未显示的牌

		var tex_path = card.texture.resource_path
		
		# 只检查牌是否有效
		if not tex_path or "back" in tex_path:
			continue  # 跳过无效或背面牌（虽然理论上end_game后不应该有）

		# 解析牌面数字（文件名示例：card_clubs_1.png）
		var file_name = tex_path.get_file()  # "card_clubs_1.png"
		if "_" in file_name:
			var parts = file_name.split("_")  # ["card", "clubs", "1.png"]
			var rank_num = int(parts[2].split(".")[0])  # 提取 "1" → 1

			# 计算牌值（A=11, J/Q/K=10, 其他按数字）
			if rank_num == 1:  # A
				total += 11
				ace_count += 1
			elif rank_num >= 11 and rank_num <= 13:  # J/Q/K
				total += 10
			else:  # 2-10
				total += rank_num

	# 处理Ace的软计数（若总分>21，A可转为1）
	while total > 21 and ace_count > 0:
		total -= 10
		ace_count -= 1

	return total
	
func reset_game():
	# 重置按钮状态
	hit_button.disabled = true
	stand_button.disabled = true
	
	# 隐藏结果和分数显示
	$"../ResultLabel".visible = false
	score_label.visible = false
	
	# 重置手牌大小
	player_hand_size = 0
	dealer_hand_size = 0
	
	# 隐藏所有卡牌
	for i in range(1, MAX_HAND_SIZE + 1):
		player_hand.get_node("Card%d" % i).visible = false
		dealer_hand.get_node("Card%d" % i).visible = false
	
	# 重置牌组
	card_system.reset_deck()

func setup_card(hand, index, card_code, is_hidden=false):
	var card = hand.get_node("Card%d" % (index + 1))
	if card and card_code:
		if is_hidden:
			card.texture = load("res://assets/cards/card_back.png")
		else:
			card.texture = card_system.get_card_texture(card_code)
		card.visible = true

func update_score_display():
	var player_score = calculate_hand_value(player_hand, false)
	score_label.text = "点数: %d" % player_score
	
	# 检查是否爆牌
	if player_score > 21:
		score_label.text += " (爆牌)"
		hit_button.disabled = true
		stand_button.disabled = true
		# 延迟调用end_game，确保UI更新完成
		call_deferred("end_game")
		
			
func check_blackjack():
	var player_value = calculate_hand_value(player_hand, false)
	var dealer_value = calculate_hand_value(dealer_hand, true)
	
	if player_value == 21:
		if dealer_value == 21:
			end_game()  # 平局
		else:
			# 玩家Blackjack
			$"../ResultLabel".text = "玩家Blackjack！"
			$"../ResultLabel".visible = true
			text = "重新开始"
			disabled = false
	elif dealer_value == 21:
		# 庄家Blackjack
		$"../ResultLabel".text = "庄家Blackjack！"
		$"../ResultLabel".visible = true
		text = "重新开始"
		disabled = false
		
func end_game():
	# 翻开庄家所有牌（包括隐藏的第一张）
	for i in range(1, dealer_hand_size + 1):
		var card = dealer_hand.get_node("Card%d" % i)
		if "back" in card.texture.resource_path:
			var card_code = get_dealer_card_code(i)
			if card_code:
				card.texture = card_system.get_card_texture(card_code)

	# 计算最终分数
	var player_score = calculate_hand_value(player_hand, false)
	var dealer_score = calculate_hand_value(dealer_hand, false)

	# 确定结果
	var result_text = ""
	if player_score > 21:
		result_text = "玩家爆牌！庄家获胜"
	elif dealer_score > 21:
		result_text = "庄家爆牌！玩家获胜"
	elif player_score == 21 and player_hand_size == 2:
		if dealer_score == 21 and dealer_hand_size == 2:
			result_text = "双方Blackjack！平局"
		else:
			result_text = "玩家Blackjack！"
	elif dealer_score == 21 and dealer_hand_size == 2:
		result_text = "庄家Blackjack！"
	elif player_score > dealer_score:
		result_text = "玩家获胜！%d vs %d" % [player_score, dealer_score]
	elif dealer_score > player_score:
		result_text = "庄家获胜！%d vs %d" % [dealer_score, player_score]
	else:
		result_text = "平局！%d vs %d" % [player_score, dealer_score]

	# 显示结果
	$"../ResultLabel".text = result_text
	$"../ResultLabel".visible = true
	score_label.text = "玩家: %d | 庄家: %d" % [player_score, dealer_score]

	# 重置按钮
	text = "重新开始"
	disabled = false
	
func get_dealer_card_code(slot_number):
	var dealer_cards = []
	for card_code in card_system.drawn_cards:
		if card_system.card_assignments.get(card_code) == false:
			dealer_cards.append(card_code)
	return dealer_cards[slot_number-1] if slot_number <= dealer_cards.size() else ""
