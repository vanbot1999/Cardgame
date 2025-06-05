extends Button

@onready var card_system = $"../CardDeck"
@onready var player_hand = $"../PlayerHand"
@onready var blackjack_button = $"../BlackjackButton"

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	disabled = true

func _on_pressed():
	# 玩家要牌
	var player_card = card_system.draw_random_card(true)
	blackjack_button.setup_card(player_hand, blackjack_button.player_hand_size, player_card)
	blackjack_button.player_hand_size += 1
	
	blackjack_button.update_score_display()
	
	# 检查是否爆牌或达到21点
	var player_score = blackjack_button.calculate_hand_value(player_hand, false)
	if player_score >= 21:
		disabled = true
		$"../StandButton".disabled = true
		if player_score > 21:
			blackjack_button.end_game()  # Removed the false argument
		else:  # 正好21点，自动停牌
			$"../StandButton"._on_pressed()
