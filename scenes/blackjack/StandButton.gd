extends Button

@onready var card_system = $"../CardDeck"
@onready var dealer_hand = $"../DealerHand"
@onready var player_hand = $"../PlayerHand"
@onready var blackjack_button = $"../BlackjackButton"  # 主游戏逻辑脚本

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	disabled = true  # 初始禁用，直到游戏开始

func _on_pressed():
	disabled = true
	$"../HitButton".disabled = true  # 停牌后禁用"要牌"按钮
	
	# 1. 强制翻开庄家隐藏的第一张牌
	var first_card = dealer_hand.get_node("Card1")
	if "back" in first_card.texture.resource_path:
		var card_code = blackjack_button.get_dealer_card_code(1)
		if card_code != "":
			first_card.texture = card_system.get_card_texture(card_code)
	
	# 2. 庄家自动抽牌逻辑（点数<17且手牌未达上限时）
	var dealer_score = blackjack_button.calculate_hand_value(dealer_hand, false)
	while dealer_score < 17 and blackjack_button.dealer_hand_size < blackjack_button.MAX_HAND_SIZE:
		await get_tree().create_timer(0.5).timeout  # 抽牌动画延迟
		
		var dealer_card = card_system.draw_random_card(false)
		blackjack_button.setup_card(dealer_hand, blackjack_button.dealer_hand_size, dealer_card)
		blackjack_button.dealer_hand_size += 1
		
		# 重新计算庄家点数（包含新牌）
		dealer_score = blackjack_button.calculate_hand_value(dealer_hand, false)
	
	# 3. 最终胜负判定
	blackjack_button.end_game()  # 现在让 end_game() 自己计算胜负
