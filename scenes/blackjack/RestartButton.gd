extends Button

@onready var blackjack_button = $"../BlackjackButton"
@onready var hit_button = $"../HitButton"
@onready var stand_button = $"../StandButton"
@onready var result_label = $"../ResultLabel"
@onready var score_label = $"../PlayerScoreDisplay"

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	disabled = true  # 初始时禁用，直到游戏结束

func _on_pressed():
	# 重置游戏状态
	reset_game()
	
	# 触发新的游戏开始
	blackjack_button._on_button_pressed()

func reset_game():
	# 重置按钮状态
	disabled = true
	hit_button.disabled = true
	stand_button.disabled = true
	
	# 隐藏结果和分数显示
	result_label.visible = false
	score_label.visible = false
	
	# 重置手牌大小
	blackjack_button.player_hand_size = 0
	blackjack_button.dealer_hand_size = 0
	
	# 隐藏所有卡牌
	for i in range(1, blackjack_button.MAX_HAND_SIZE + 1):
		blackjack_button.player_hand.get_node("Card%d" % i).visible = false
		blackjack_button.dealer_hand.get_node("Card%d" % i).visible = false
